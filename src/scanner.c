// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See the LICENSE file in the project root for full license information.

#include "tree_sitter/parser.h"
#include <wctype.h>

enum TOKEN_TYPE {
    STATEMENT_TERMINATOR,
    BARE_DASHES,
    QUALIFIED_VARIABLE,
    QUALIFIED_VARIABLE_IN_STRING,
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

static bool variable_char(int32_t c)
{
    return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') ||
           (c >= '0' && c <= '9') || c == '_' || c == '?';
}

// The first colon needs a name; subsequent single colons belong to the path,
// even at its end. A double colon always starts static member access.
static unsigned scan_variable_path(TSLexer *lexer)
{
    if (!variable_char(lexer->lookahead) || lexer->lookahead == '?') return 0;
    while (variable_char(lexer->lookahead)) lexer->advance(lexer, false);
    lexer->mark_end(lexer);
    unsigned colons = 0;
    while (lexer->lookahead == ':') {
        lexer->advance(lexer, false);
        if (lexer->lookahead == ':') break;
        if (!colons && !variable_char(lexer->lookahead)) break;
        colons++;
        while (variable_char(lexer->lookahead)) lexer->advance(lexer, false);
        lexer->mark_end(lexer);
    }
    return colons;
}

static bool scan_qualified_variable(TSLexer *lexer, const bool *valid_symbols)
{
    bool in_string = valid_symbols[QUALIFIED_VARIABLE_IN_STRING];
    if (lexer->lookahead != '$' && lexer->lookahead != '@') return false;
    if (in_string && lexer->lookahead == '@') return false;
    lexer->advance(lexer, false);
    if (scan_variable_path(lexer) < 2) return false;
    // Outside a string, an adjacent word suffix must still win the longest
    // token match. Its converter, not this variable token, owns interpolation.
    int32_t c = lexer->lookahead;
    if (!in_string && c && !iswspace(c) && c != '.' && c != '[' && c != ':' &&
        c != ')' && c != '}' && c != ';' && c != ',' && c != '|' && c != '&')
        return false;
    lexer->result_symbol = in_string ? QUALIFIED_VARIABLE_IN_STRING : QUALIFIED_VARIABLE;
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
    if ((valid_symbols[QUALIFIED_VARIABLE] || valid_symbols[QUALIFIED_VARIABLE_IN_STRING]) &&
        !valid_symbols[ERROR_SENTINEL]) {
        while (!valid_symbols[QUALIFIED_VARIABLE_IN_STRING] && iswspace(lexer->lookahead)) {
            if (valid_symbols[STATEMENT_TERMINATOR] &&
                (lexer->lookahead == '\r' || lexer->lookahead == '\n')) break;
            skip(lexer);
        }
        if (lexer->lookahead == '$' || lexer->lookahead == '@')
            return scan_qualified_variable(lexer, valid_symbols);
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
