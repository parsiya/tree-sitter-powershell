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
    QUOTED_ARGUMENT_BOUNDARY
};

/* --- API --- */

void *tree_sitter_powershell_external_scanner_create();

void tree_sitter_powershell_external_scanner_destroy(void *p);

unsigned tree_sitter_powershell_external_scanner_serialize(void *payload, char *buffer);

void tree_sitter_powershell_external_scanner_deserialize(void *payload, const char *buffer, unsigned length);

bool tree_sitter_powershell_external_scanner_scan(void *payload, TSLexer *lexer, const bool *valid_symbols);

/* --- Internal Functions --- */

static void skip(TSLexer *lexer) { lexer->advance(lexer, true); }

static bool is_quote(int32_t c)
{
    return c == '"' || c == '\'' || (c >= 0x2018 && c <= 0x201e);
}

// A quoted piece within a word does not end it. Keep its string syntax visible,
// rather than letting the ordinary word token consume quotes and split at spaces.
static bool scan_command_word(TSLexer *lexer, const bool *valid_symbols)
{
    bool part = valid_symbols[COMMAND_WORD_PART];
    bool start = valid_symbols[COMMAND_WORD_START] && !part;
    if (!start && !part && !valid_symbols[COMMAND_WORD_EXPRESSION]) return false;
    lexer->mark_end(lexer);
    if (is_quote(lexer->lookahead)) {
        if (!valid_symbols[COMMAND_WORD_EXPRESSION]) return false;
        lexer->result_symbol = COMMAND_WORD_EXPRESSION;
        return true;
    }
    if (start && (lexer->lookahead == '$' || lexer->lookahead == '@' ||
                  lexer->lookahead == '[' || lexer->lookahead == '-' ||
                  lexer->lookahead == '>' || lexer->lookahead == '<' ||
                  lexer->lookahead == '#')) return false;
    bool consumed = false;
    bool escaped = false;
    for (;;) {
        int32_t c = lexer->lookahead;
        if (!c || iswspace(c) || c == '(' || c == ')' || c == '{' ||
            c == '}' || c == ';' || c == ',' || c == '|' || c == '&') break;
        if (is_quote(c)) break;
        lexer->advance(lexer, false);
        if (c == '`' && lexer->lookahead) {
            if (!consumed && !part &&
                (lexer->lookahead == '\r' || lexer->lookahead == '\n')) return false;
            lexer->advance(lexer, false);
            escaped = true;
        }
        consumed = true;
        lexer->mark_end(lexer);
    }
    if (!consumed || (start && !escaped && !is_quote(lexer->lookahead))) return false;
    lexer->result_symbol = part ? COMMAND_WORD_PART : COMMAND_WORD_START;
    return true;
}

static bool scan_quoted_argument_boundary(TSLexer *lexer, const bool *valid_symbols)
{
    if (!valid_symbols[QUOTED_ARGUMENT_BOUNDARY]) return false;
    int32_t c = lexer->lookahead;
    if (!c || iswspace(c) || c == '.' || c == '[' || c == ':' ||
        c == ';' || c == '|' || c == '&' || c == ')' || c == '}' ||
        c == ',' || c == '>' || c == '<' || c == '-' || c == '`' ||
        c == '#' || c == '(' || c == '{') return false;
    lexer->mark_end(lexer);
    lexer->result_symbol = QUOTED_ARGUMENT_BOUNDARY;
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
    if (scan_quoted_argument_boundary(lexer, valid_symbols)) return true;
    if (valid_symbols[COMMAND_WORD_START] || valid_symbols[COMMAND_WORD_PART] ||
        valid_symbols[COMMAND_WORD_EXPRESSION]) {
        // A failed word lookahead can advance the lexer.
        if (lexer->lookahead && !iswspace(lexer->lookahead) &&
            lexer->lookahead != ')' && lexer->lookahead != '}' &&
            lexer->lookahead != ';' && lexer->lookahead != ',' &&
            lexer->lookahead != '|' && lexer->lookahead != '&')
            return scan_command_word(lexer, valid_symbols);
    }
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
