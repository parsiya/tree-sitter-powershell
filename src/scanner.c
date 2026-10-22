// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See the LICENSE file in the project root for full license information.

#include "tree_sitter/parser.h"
#include <wctype.h>

enum TOKEN_TYPE {
    STATEMENT_TERMINATOR,
    BARE_DASHES,
    COMMAND_NAME_ESCAPE,
    COMMAND_NAME_START_ESCAPE,
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

static int hex_digit(int32_t c)
{
    if (c >= '0' && c <= '9') return c - '0';
    if (c >= 'a' && c <= 'f') return c - 'a' + 10;
    if (c >= 'A' && c <= 'F') return c - 'A' + 10;
    return -1;
}

static bool command_name_space(int32_t c)
{
    return (c >= '\t' && c <= '\r') || c == ' ' || c == 0x85 || c == 0xa0 ||
        c == 0x1680 || (c >= 0x2000 && c <= 0x200a) || c == 0x2028 ||
        c == 0x2029 || c == 0x202f || c == 0x205f || c == 0x3000;
}

// Unlike trivia between tokens, an escape inside a name retains the next
// character, including whitespace and line endings.
static bool scan_command_name_escape(TSLexer *lexer, const bool *valid_symbols)
{
    bool start = valid_symbols[COMMAND_NAME_START_ESCAPE];
    if ((!start && !valid_symbols[COMMAND_NAME_ESCAPE]) || valid_symbols[ERROR_SENTINEL] ||
        lexer->lookahead != '`') return false;
    lexer->advance(lexer, false);
    if (lexer->eof(lexer)) return false;
    if (start && command_name_space(lexer->lookahead)) return false;
    int32_t escaped = lexer->lookahead;
    lexer->advance(lexer, false);
    if (escaped == 'u' && lexer->lookahead == '{') {
        lexer->advance(lexer, false);
        uint32_t value = 0;
        unsigned digits = 0;
        int digit;
        while ((digit = hex_digit(lexer->lookahead)) >= 0 && digits < 6) {
            value = value * 16 + digit;
            digits++;
            lexer->advance(lexer, false);
        }
        if (!digits || lexer->lookahead != '}' || value > 0x10ffff) return false;
        lexer->advance(lexer, false);
    }
    lexer->mark_end(lexer);
    lexer->result_symbol = start ? COMMAND_NAME_START_ESCAPE : COMMAND_NAME_ESCAPE;
    return true;
}

bool tree_sitter_powershell_external_scanner_scan(void *payload, TSLexer *lexer, const bool *valid_symbols)
{
    if (valid_symbols[COMMAND_NAME_START_ESCAPE] && !valid_symbols[ERROR_SENTINEL]) {
        while (command_name_space(lexer->lookahead)) {
            if (valid_symbols[STATEMENT_TERMINATOR] &&
                (lexer->lookahead == '\r' || lexer->lookahead == '\n')) break;
            skip(lexer);
        }
    }
    if ((valid_symbols[COMMAND_NAME_ESCAPE] || valid_symbols[COMMAND_NAME_START_ESCAPE]) &&
        !valid_symbols[ERROR_SENTINEL] && lexer->lookahead == '`')
        return scan_command_name_escape(lexer, valid_symbols);
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
