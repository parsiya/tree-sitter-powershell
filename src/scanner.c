// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See the LICENSE file in the project root for full license information.

#include "tree_sitter/parser.h"
#include <wctype.h>

enum TOKEN_TYPE {
    STATEMENT_TERMINATOR,
    BARE_DASHES,
    PATH_COMMAND_NAME_CONTINUATION,
    COMMAND_NAME_ESCAPE,
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

/* --- API Implementation --- */

static bool scan_command_name_escape(TSLexer *lexer, const bool *valid_symbols)
{
    if (!valid_symbols[COMMAND_NAME_ESCAPE] || valid_symbols[ERROR_SENTINEL] ||
        lexer->lookahead != '`') return false;
    lexer->advance(lexer, false);
    if (lexer->eof(lexer)) return false;
    lexer->advance(lexer, false);
    lexer->mark_end(lexer);
    lexer->result_symbol = COMMAND_NAME_ESCAPE;
    return true;
}

// A path's pieces must touch. In particular, quoted and escaped pieces must
// not absorb the next argument after an invocation operator.
static bool scan_path_command_name_continuation(TSLexer *lexer, const bool *valid_symbols)
{
    if (!valid_symbols[PATH_COMMAND_NAME_CONTINUATION] || valid_symbols[ERROR_SENTINEL]) return false;
    int32_t c = lexer->lookahead;
    if ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'z') ||
        (c >= 'A' && c <= 'Z') || c == '_' || c == '?' || c == '-' ||
        c == '.' || c == '\\' || c == '/' || c == '$' || c == '@' ||
        c == '"' || c == '\'' || c == '`' || (c >= 0x2018 && c <= 0x201e)) {
        lexer->mark_end(lexer);
        lexer->result_symbol = PATH_COMMAND_NAME_CONTINUATION;
        return true;
    }
    return false;
}

bool tree_sitter_powershell_external_scanner_scan(void *payload, TSLexer *lexer, const bool *valid_symbols)
{
    if (valid_symbols[COMMAND_NAME_ESCAPE] && !valid_symbols[ERROR_SENTINEL] &&
        lexer->lookahead == '`')
        return scan_command_name_escape(lexer, valid_symbols);
    if (scan_path_command_name_continuation(lexer, valid_symbols)) return true;
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
