// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See the LICENSE file in the project root for full license information.

#include "tree_sitter/parser.h"
#include <wctype.h>

enum TOKEN_TYPE {
    STATEMENT_TERMINATOR,
    BARE_DASHES,
    COMMAND_WORD_START,
    COMMAND_WORD_PART,
    COMMAND_WORD_EXPRESSION,
    ERROR_SENTINEL,
    QUOTED_ARGUMENT_BOUNDARY,
    COMPLETED_EXPRESSION_BOUNDARY
};

/* --- API --- */

void *tree_sitter_powershell_external_scanner_create();

void tree_sitter_powershell_external_scanner_destroy(void *p);

unsigned tree_sitter_powershell_external_scanner_serialize(void *payload, char *buffer);

void tree_sitter_powershell_external_scanner_deserialize(void *payload, const char *buffer, unsigned length);

bool tree_sitter_powershell_external_scanner_scan(void *payload, TSLexer *lexer, const bool *valid_symbols);

/* --- Internal Functions --- */

static void skip(TSLexer *lexer) { lexer->advance(lexer, true); }

static bool digit(int32_t c) { return c >= '0' && c <= '9'; }

// Preserve the inherited numeric CST for a complete negative number. In command
// mode consumers must interpret that existing shape as a word, not negation.
static bool scan_number_prefix(TSLexer *lexer)
{
    bool hex = false;
    bool real = false;
    bool digits = false;
    if (lexer->lookahead == '0') {
        lexer->advance(lexer, false);
        digits = true;
        if (lexer->lookahead == 'x') {
            lexer->advance(lexer, false);
            hex = true;
            digits = false;
        }
    }
    while (digit(lexer->lookahead) ||
           (hex && ((lexer->lookahead >= 'a' && lexer->lookahead <= 'f') ||
                    (lexer->lookahead >= 'A' && lexer->lookahead <= 'F')))) {
        lexer->advance(lexer, false);
        digits = true;
    }
    if (!hex && lexer->lookahead == '.') {
        real = true;
        lexer->advance(lexer, false);
        digits = false;
        while (digit(lexer->lookahead)) {
            lexer->advance(lexer, false);
            digits = true;
        }
    }
    if (!digits) return false;
    if (!hex && lexer->lookahead == 'e') {
        lexer->advance(lexer, false);
        if (lexer->lookahead == '+' || lexer->lookahead == '-')
            lexer->advance(lexer, false);
        if (!digit(lexer->lookahead)) return false;
        while (digit(lexer->lookahead)) lexer->advance(lexer, false);
    } else if (!real && (lexer->lookahead == 'l' || (!hex && lexer->lookahead == 'd'))) {
        lexer->advance(lexer, false);
    }
    int32_t c = lexer->lookahead;
    if (c == 'k' || c == 'm' || c == 'g' || c == 't' || c == 'p') {
        lexer->advance(lexer, false);
        if (lexer->lookahead != 'b') return false;
        lexer->advance(lexer, false);
    }
    return true;
}

static bool command_word_end(int32_t c)
{
    return c == 0 || iswspace(c) || c == 0xa0 || c == '(' || c == ')' ||
           c == '{' || c == '}' || c == ';' || c == ',' || c == '|' || c == '&';
}

static bool is_quote(int32_t c) { return c == '"' || c == '\''; }

static bool scan_argument_boundary(TSLexer *lexer, const bool *valid_symbols)
{
    lexer->mark_end(lexer);
    lexer->advance(lexer, false);
    if (!digit(lexer->lookahead) && lexer->lookahead != '.') return false;
    lexer->result_symbol = valid_symbols[QUOTED_ARGUMENT_BOUNDARY] ?
        QUOTED_ARGUMENT_BOUNDARY : COMPLETED_EXPRESSION_BOUNDARY;
    return true;
}

static void scan_variable_name(TSLexer *lexer)
{
    if (lexer->lookahead == '{') {
        do {
            lexer->advance(lexer, false);
        } while (lexer->lookahead && lexer->lookahead != '}');
        if (lexer->lookahead) lexer->advance(lexer, false);
    } else {
        while (iswalnum(lexer->lookahead) || lexer->lookahead == '_' ||
               lexer->lookahead == '?' || lexer->lookahead == ':')
            lexer->advance(lexer, false);
    }
}

// The joined-word path is also used by the combined development grammar.
// Restrict new starts here to digit/dot-leading dash words.
static bool scan_command_word(TSLexer *lexer, const bool *valid_symbols)
{
    bool part = valid_symbols[COMMAND_WORD_PART];
    bool start = valid_symbols[COMMAND_WORD_START] && !part;
    lexer->mark_end(lexer);
    if (is_quote(lexer->lookahead)) {
        if (!valid_symbols[COMMAND_WORD_EXPRESSION]) return false;
        lexer->result_symbol = COMMAND_WORD_EXPRESSION;
        return true;
    }
    bool consumed = false;
    if (start) {
        if (lexer->lookahead != '-') return false;
        lexer->advance(lexer, false);
        if (!digit(lexer->lookahead) && lexer->lookahead != '.') {
            if (!valid_symbols[BARE_DASHES]) return false;
            if (lexer->lookahead == '-') lexer->advance(lexer, false);
            switch (lexer->lookahead) {
                case 0: case ' ': case '\t': case '\r': case '\n':
                case ';': case '|': case '&': case ')': case '}':
                    lexer->mark_end(lexer);
                    lexer->result_symbol = BARE_DASHES;
                    return true;
                default: return false;
            }
        }
        if (scan_number_prefix(lexer) && command_word_end(lexer->lookahead)) return false;
        consumed = true;
        lexer->mark_end(lexer);
    }
    for (;;) {
        int32_t c = lexer->lookahead;
        if (command_word_end(c)) break;
        if (is_quote(c)) break;
        if (c == '$') {
            lexer->mark_end(lexer);
            lexer->advance(lexer, false);
            if (lexer->lookahead == '(') {
                if (!consumed) {
                    if (!valid_symbols[COMMAND_WORD_EXPRESSION]) return false;
                    lexer->result_symbol = COMMAND_WORD_EXPRESSION;
                } else {
                    lexer->result_symbol = part ? COMMAND_WORD_PART : COMMAND_WORD_START;
                }
                return true;
            }
            scan_variable_name(lexer);
        } else {
            lexer->advance(lexer, false);
            if (c == '`') {
                if (lexer->eof(lexer)) return false;
                lexer->advance(lexer, false);
            }
        }
        consumed = true;
        lexer->mark_end(lexer);
    }
    if (!consumed) return false;
    lexer->result_symbol = part ? COMMAND_WORD_PART : COMMAND_WORD_START;
    return true;
}

static bool scan_statement_terminator(void *payload, TSLexer *lexer, const bool *valid_symbols)
{
    if (valid_symbols[STATEMENT_TERMINATOR]) {
        lexer->result_symbol = STATEMENT_TERMINATOR;
        // This token has no characters -- everything is lookahead to determine its existence
        lexer->mark_end(lexer);

        for (;;) {
            if (lexer->lookahead == 0) return true;
            if (lexer->lookahead == '}') return true;
            if (lexer->lookahead == ';') return true;
            if (lexer->lookahead == ')') return true;
            if (lexer->lookahead == '\n') return true;
            if (!iswspace(lexer->lookahead)) return false;
            skip(lexer);
        }
    }

    return false;
}

// A bare `-` or `--` argument: `--` ends option parsing for a native command
// (`git log -- path`, `cargo test -- --nocapture`) and `-` names stdin
// (`tar -xf -`). `--` is also the decrement operator and `-` the unary minus,
// so the lexer cannot tell them apart by length or precedence: the token is
// recognised only when the dashes are followed by whitespace or the end of the
// command.
static bool scan_bare_dashes(void *payload, TSLexer *lexer, const bool *valid_symbols)
{
    if (!valid_symbols[BARE_DASHES]) return false;

    while (lexer->lookahead == ' ' || lexer->lookahead == '\t') skip(lexer);
    if (lexer->lookahead != '-') return false;
    lexer->advance(lexer, false);
    if (lexer->lookahead == '-') lexer->advance(lexer, false);
    lexer->mark_end(lexer);

    switch (lexer->lookahead) {
        case 0:
        case ' ':
        case '\t':
        case '\r':
        case '\n':
        case ';':
        case '|':
        case '&':
        case ')':
        case '}':
            lexer->result_symbol = BARE_DASHES;
            return true;
        default:
            return false;
    }
}

/* --- API Implementation --- */

bool tree_sitter_powershell_external_scanner_scan(void *payload, TSLexer *lexer, const bool *valid_symbols)
{
    // A failed dash lookahead has advanced, so return directly and let the
    // lexer rewind before trying an ordinary parameter or subtraction token.
    if (!valid_symbols[ERROR_SENTINEL] && lexer->lookahead == '-' &&
        (valid_symbols[QUOTED_ARGUMENT_BOUNDARY] || valid_symbols[COMPLETED_EXPRESSION_BOUNDARY]))
        return scan_argument_boundary(lexer, valid_symbols);
    if (!valid_symbols[ERROR_SENTINEL] &&
        (valid_symbols[COMMAND_WORD_START] || valid_symbols[COMMAND_WORD_PART] ||
         valid_symbols[COMMAND_WORD_EXPRESSION]) &&
        !command_word_end(lexer->lookahead))
        return scan_command_word(lexer, valid_symbols);
    // The statement terminator consumes nothing, so it must be tried last: when
    // both are valid, a `--` has to win over the empty terminator.
    if (scan_bare_dashes(payload, lexer, valid_symbols)) return true;
    return scan_statement_terminator(payload, lexer, valid_symbols);
}

void *tree_sitter_powershell_external_scanner_create()
{
    return NULL;
}

void tree_sitter_powershell_external_scanner_destroy(void *p)
{
}

unsigned tree_sitter_powershell_external_scanner_serialize(void *payload, char *buffer)
{
    return 0;
}

void tree_sitter_powershell_external_scanner_deserialize(void *payload, const char *buffer, unsigned length)
{
}
