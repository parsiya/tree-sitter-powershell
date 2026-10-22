// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See the LICENSE file in the project root for full license information.

#include "tree_sitter/parser.h"
#include <wctype.h>

enum TOKEN_TYPE {
    STATEMENT_TERMINATOR,
    BARE_DASHES,
    COMPLETED_EXPRESSION_BOUNDARY,
    COMPLETED_MEMBER_BOUNDARY,
    SUBEXPRESSION_WORD_PREFIX,
    SUBEXPRESSION_WORD_PART,
    SUBEXPRESSION_WORD_EXPRESSION,
    ERROR_SENTINEL
};

/* --- API --- */

void *tree_sitter_powershell_external_scanner_create();

void tree_sitter_powershell_external_scanner_destroy(void *p);

unsigned tree_sitter_powershell_external_scanner_serialize(void *payload, char *buffer);

void tree_sitter_powershell_external_scanner_deserialize(void *payload, const char *buffer, unsigned length);

bool tree_sitter_powershell_external_scanner_scan(void *payload, TSLexer *lexer, const bool *valid_symbols);

/* --- Internal Functions --- */

static void skip(TSLexer *lexer) { lexer->advance(lexer, true); }

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

static bool word_end(int32_t c)
{
    return c == 0 || iswspace(c) || c == '(' || c == ')' || c == '{' ||
           c == '}' || c == ';' || c == ',' || c == '|' || c == '&';
}

// A subexpression embedded in a word does not complete a command argument.
// Recognize its prefix before allowing the completed-expression boundary.
static bool scan_subexpression_word(TSLexer *lexer, const bool *valid_symbols)
{
    bool part = valid_symbols[SUBEXPRESSION_WORD_PART];
    bool start = valid_symbols[SUBEXPRESSION_WORD_PREFIX] && !part;
    bool expression = valid_symbols[SUBEXPRESSION_WORD_EXPRESSION];
    if ((!start && !part && !expression) || valid_symbols[ERROR_SENTINEL]) return false;
    lexer->mark_end(lexer);

    int32_t first = lexer->lookahead;
    if (first == '"' || first == '\'') {
        if (!expression) return false;
        lexer->result_symbol = SUBEXPRESSION_WORD_EXPRESSION;
        return true;
    }
    if (start && (first == '-' || first == '@' || first == '[' ||
                  first == '>' || first == '<' || first == '#' || first == ':'))
        return false;

    bool consumed = false, escaped = false;
    if (start && first == '$') {
        lexer->advance(lexer, false);
        if (lexer->lookahead == '(') return false;
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
        if (word_end(lexer->lookahead) || lexer->lookahead == '.' ||
            lexer->lookahead == '[') return false;
        consumed = true;
        lexer->mark_end(lexer);
    }

    for (;;) {
        int32_t c = lexer->lookahead;
        if (word_end(c) || c == '"' || c == '\'') break;
        if (c == '$') {
            lexer->mark_end(lexer);
            lexer->advance(lexer, false);
            if (lexer->lookahead == '(') {
                if (!consumed) {
                    if (!expression) return false;
                    lexer->result_symbol = SUBEXPRESSION_WORD_EXPRESSION;
                } else {
                    lexer->result_symbol = part ? SUBEXPRESSION_WORD_PART : SUBEXPRESSION_WORD_PREFIX;
                }
                return true;
            }
        } else {
            lexer->advance(lexer, false);
            if (c == '`') {
                if (!consumed && !part &&
                    (lexer->lookahead == '\r' || lexer->lookahead == '\n')) return false;
                if (lexer->lookahead) lexer->advance(lexer, false);
                escaped = true;
            }
        }
        consumed = true;
        lexer->mark_end(lexer);
    }
    if (!consumed || (start && !escaped)) return false;
    lexer->result_symbol = part ? SUBEXPRESSION_WORD_PART : SUBEXPRESSION_WORD_PREFIX;
    return true;
}

static bool scan_completed_expression_boundary(TSLexer *lexer, const bool *valid_symbols)
{
    if (valid_symbols[ERROR_SENTINEL]) return false;
    bool value = valid_symbols[COMPLETED_EXPRESSION_BOUNDARY];
    bool member = valid_symbols[COMPLETED_MEMBER_BOUNDARY];
    if (!value && !member) return false;
    int32_t c = lexer->lookahead;
    if (c == 0 || iswspace(c)) return false;
    switch (c) {
        case '.':
        case ':':
        case '[':
        case '#':
        case '`':
        case ',':
        case ';':
        case '|':
        case '&':
        case ')':
        case '}':
        case '>':
        case '<':
        case '-':
            return false;
        case '(':
            if (!value) return false;
    }
    lexer->mark_end(lexer);
    lexer->result_symbol = value ? COMPLETED_EXPRESSION_BOUNDARY : COMPLETED_MEMBER_BOUNDARY;
    return true;
}

/* --- API Implementation --- */

bool tree_sitter_powershell_external_scanner_scan(void *payload, TSLexer *lexer, const bool *valid_symbols)
{
    if (scan_completed_expression_boundary(lexer, valid_symbols)) return true;
    if ((valid_symbols[SUBEXPRESSION_WORD_PREFIX] || valid_symbols[SUBEXPRESSION_WORD_PART] ||
         valid_symbols[SUBEXPRESSION_WORD_EXPRESSION]) && !word_end(lexer->lookahead) &&
        (lexer->lookahead != '-' || valid_symbols[SUBEXPRESSION_WORD_PART]))
        return scan_subexpression_word(lexer, valid_symbols);
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
