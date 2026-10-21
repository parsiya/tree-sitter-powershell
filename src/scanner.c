// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See the LICENSE file in the project root for full license information.

#include "tree_sitter/parser.h"
#include <wctype.h>

enum TOKEN_TYPE {
    STATEMENT_TERMINATOR,
    BARE_DASHES,
    PARAMETER_ARGUMENT_SEPARATOR,
    PARAMETER_ARGUMENT_START,
    COLON_WORD_CONTINUATION,
    PARAMETER_ARGUMENT_BOUNDARY,
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

// A required attached value may follow horizontal trivia, block comments or
// explicit line continuations, but not the end of a command or a line comment.
static bool scan_parameter_argument_start(TSLexer *lexer, const bool *valid_symbols)
{
    if (!valid_symbols[PARAMETER_ARGUMENT_START]) return false;
    lexer->mark_end(lexer);
    for (;;) {
        int32_t c = lexer->lookahead;
        if (c == ' ' || c == '\t' || c == '\v' || c == '\f' ||
            c == 0x85 || c == 0xA0 || c == 0x1680 ||
            (c >= 0x2000 && c <= 0x200A) || c == 0x202F ||
            c == 0x205F || c == 0x3000) {
            lexer->advance(lexer, false);
            continue;
        }
        if (c == '`') {
            lexer->advance(lexer, false);
            if (lexer->lookahead == '\r') lexer->advance(lexer, false);
            if (lexer->lookahead == '\n') {
                lexer->advance(lexer, false);
                continue;
            }
        } else if (c == '<') {
            lexer->advance(lexer, false);
            if (lexer->lookahead == '#') {
                lexer->advance(lexer, false);
                unsigned depth = 1;
                while (depth) {
                    if (lexer->eof(lexer)) return false;
                    c = lexer->lookahead;
                    lexer->advance(lexer, false);
                    if (c == '<' && lexer->lookahead == '#') {
                        lexer->advance(lexer, false);
                        depth++;
                    } else if (c == '#' && lexer->lookahead == '>') {
                        lexer->advance(lexer, false);
                        depth--;
                    }
                }
                continue;
            }
        } else if (c == 0 || c == '\r' || c == '\n' || c == '#' ||
                   c == ';' || c == '|' || c == '&' || c == ')' ||
                   c == '}' || c == '>') {
            return false;
        }
        lexer->result_symbol = PARAMETER_ARGUMENT_START;
        return true;
    }
}

/* --- API Implementation --- */

bool tree_sitter_powershell_external_scanner_scan(void *payload, TSLexer *lexer, const bool *valid_symbols)
{
    if (valid_symbols[ERROR_SENTINEL]) return false;
    if (valid_symbols[PARAMETER_ARGUMENT_START]) {
        return scan_parameter_argument_start(lexer, valid_symbols);
    }
    // Parser state, not a preceding expression's text, licenses an attachment.
    // Do not skip trivia: `-Name :value` has a separate literal argument.
    if (valid_symbols[PARAMETER_ARGUMENT_SEPARATOR] && lexer->lookahead == ':') {
        lexer->advance(lexer, false);
        lexer->mark_end(lexer);
        lexer->result_symbol = PARAMETER_ARGUMENT_SEPARATOR;
        return true;
    }
    if (valid_symbols[COLON_WORD_CONTINUATION] &&
        (lexer->lookahead == '$' || lexer->lookahead == '"' || lexer->lookahead == '\'')) {
        lexer->mark_end(lexer);
        lexer->result_symbol = COLON_WORD_CONTINUATION;
        return true;
    }
    if (valid_symbols[PARAMETER_ARGUMENT_BOUNDARY]) {
        int32_t c = lexer->lookahead;
        bool boundary = !(c == 0 || iswspace(c) || c == '.' || c == '[' || c == ':' ||
            c == ';' || c == '|' || c == '&' || c == ')' || c == '}' ||
            c == ',' || c == '>' || c == '<' || c == '(' || c == '{' ||
            c == '-' || c == '`' || c == '#' || c == 0xfeff ||
            c == 0x2060 || c == 0x200b || c == 0xa0);
        if (boundary) {
            lexer->mark_end(lexer);
            lexer->result_symbol = PARAMETER_ARGUMENT_BOUNDARY;
            return true;
        }
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
