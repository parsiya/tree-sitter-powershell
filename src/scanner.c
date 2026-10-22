// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See the LICENSE file in the project root for full license information.

#include "tree_sitter/parser.h"
#include <wctype.h>

enum TOKEN_TYPE {
    STATEMENT_TERMINATOR,
    BARE_DASHES,
    COMMAND_ARRAY_ITEM_START,
    SPACES_BEFORE_COMMA
};

/* --- API --- */

void *tree_sitter_powershell_external_scanner_create();

void tree_sitter_powershell_external_scanner_destroy(void *p);

unsigned tree_sitter_powershell_external_scanner_serialize(void *payload, char *buffer);

void tree_sitter_powershell_external_scanner_deserialize(void *payload, const char *buffer, unsigned length);

bool tree_sitter_powershell_external_scanner_scan(void *payload, TSLexer *lexer, const bool *valid_symbols);

/* --- Internal Functions --- */

static void skip(TSLexer *lexer) { lexer->advance(lexer, true); }

static bool command_array_space(int32_t c)
{
    return iswspace(c) || c == 0x85 || c == 0xa0 || c == 0x1680 ||
           (c >= 0x2000 && c <= 0x200a) || c == 0x2028 || c == 0x2029 ||
           c == 0x202f || c == 0x205f || c == 0x3000;
}

static bool scan_spaces_before_comma(TSLexer *lexer, const bool *valid_symbols, bool *skipped_backtick)
{
    if (!valid_symbols[SPACES_BEFORE_COMMA]) return false;
    bool skipped = false;
    for (;;) {
        if (lexer->lookahead == ' ' || lexer->lookahead == '\t') {
            skip(lexer);
        } else if (lexer->lookahead == '`') {
            *skipped_backtick = true;
            skip(lexer);
            if (lexer->lookahead == '\r') skip(lexer);
            if (lexer->lookahead != '\n') return false;
            skip(lexer);
        } else {
            break;
        }
        skipped = true;
    }
    if (!skipped || lexer->lookahead != ',') return false;
    lexer->mark_end(lexer);
    lexer->result_symbol = SPACES_BEFORE_COMMA;
    return true;
}

// After a command comma, escaped whitespace is trivia, not an array value.
// Leave comments to the ordinary extras lexer so they stay visible in the CST.
static bool scan_command_array_item_start(TSLexer *lexer, const bool *valid_symbols)
{
    if (!valid_symbols[COMMAND_ARRAY_ITEM_START]) return false;
    for (;;) {
        if (command_array_space(lexer->lookahead)) {
            skip(lexer);
        } else if (lexer->lookahead == '`') {
            lexer->mark_end(lexer);
            skip(lexer);
            if (!command_array_space(lexer->lookahead)) {
                lexer->result_symbol = COMMAND_ARRAY_ITEM_START;
                return true;
            }
            skip(lexer);
        } else {
            lexer->mark_end(lexer);
            if (lexer->lookahead == '#' || lexer->lookahead == ',') return false;
            if (lexer->lookahead == '<') {
                skip(lexer);
                if (lexer->lookahead == '#') return false;
            }
            lexer->result_symbol = COMMAND_ARRAY_ITEM_START;
            return true;
        }
    }
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
    // The statement terminator consumes nothing, so it must be tried last: when
    // both are valid, a `--` has to win over the empty terminator.
    if (scan_command_array_item_start(lexer, valid_symbols)) return true;
    bool skipped_backtick = false;
    if (scan_spaces_before_comma(lexer, valid_symbols, &skipped_backtick)) return true;
    if (skipped_backtick) return false;
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
