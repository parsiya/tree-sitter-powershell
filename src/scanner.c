// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See the LICENSE file in the project root for full license information.

#include "tree_sitter/parser.h"
#include <wctype.h>

enum TOKEN_TYPE {
    STATEMENT_TERMINATOR,
    BARE_DASHES,
    TRAILING_DOT_TYPE_NAME
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

/* --- API Implementation --- */

static bool type_name_letter(int32_t c)
{
    return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_';
}

static bool scan_trailing_dot_type_name(TSLexer *lexer)
{
    while (iswspace(lexer->lookahead)) skip(lexer);
    if (!type_name_letter(lexer->lookahead)) return false;

    unsigned dots = 0;
    for (;;) {
        int32_t c = lexer->lookahead;
        if (c == '.') {
            dots++;
        } else if (type_name_letter(c) || (c >= '0' && c <= '9')) {
            if (dots > 1) return false;
            dots = 0;
        } else {
            break;
        }
        lexer->advance(lexer, false);
    }
    // Look past the whole name: matching only "System." would steal the prefix
    // of an ordinary qualified name such as "System.String".
    if (!dots) return false;
    lexer->mark_end(lexer);
    lexer->result_symbol = TRAILING_DOT_TYPE_NAME;
    return true;
}

bool tree_sitter_powershell_external_scanner_scan(void *payload, TSLexer *lexer, const bool *valid_symbols)
{
    if (valid_symbols[TRAILING_DOT_TYPE_NAME]) return scan_trailing_dot_type_name(lexer);
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
