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

static bool command_word_end(int32_t c)
{
    return c == 0 || iswspace(c) || c == 0xa0 || c == '(' || c == ')' ||
           c == '{' || c == '}' || c == ';' || c == ',' || c == '|' || c == '&';
}

static void scan_variable_name(TSLexer *lexer)
{
    if (lexer->lookahead == '{') {
        do {
            lexer->advance(lexer, false);
        } while (lexer->lookahead && lexer->lookahead != '}');
        if (lexer->lookahead) lexer->advance(lexer, false);
    } else if (lexer->lookahead == '$' || lexer->lookahead == '?' ||
               lexer->lookahead == '^') {
        lexer->advance(lexer, false);
    } else {
        while (iswalnum(lexer->lookahead) || lexer->lookahead == '_' ||
               lexer->lookahead == '?') lexer->advance(lexer, false);
        if (lexer->lookahead == ':') {
            lexer->advance(lexer, false);
            while (iswalnum(lexer->lookahead) || lexer->lookahead == '_' ||
                   lexer->lookahead == '?') lexer->advance(lexer, false);
        }
    }
}

// In argument mode, even a bare '+' starts a word rather than a unary
// expression. Keep adjacent quotes and subexpressions visible inside it.
static bool scan_command_word(TSLexer *lexer, const bool *valid_symbols)
{
    if (valid_symbols[ERROR_SENTINEL]) return false;
    bool part = valid_symbols[COMMAND_WORD_PART];
    if (!part && (!valid_symbols[COMMAND_WORD_START] || lexer->lookahead != '+'))
        return false;
    lexer->mark_end(lexer);
    bool consumed = false;
    for (;;) {
        int32_t c = lexer->lookahead;
        if (command_word_end(c)) break;
        if (c == '"' || c == '\'') {
            if (consumed) break;
            if (!valid_symbols[COMMAND_WORD_EXPRESSION]) return false;
            lexer->result_symbol = COMMAND_WORD_EXPRESSION;
            return true;
        }
        if (c == '$') {
            lexer->mark_end(lexer);
            lexer->advance(lexer, false);
            if (lexer->lookahead == '(') {
                if (!consumed) {
                    if (!valid_symbols[COMMAND_WORD_EXPRESSION]) return false;
                    lexer->result_symbol = COMMAND_WORD_EXPRESSION;
                    return true;
                }
                lexer->result_symbol = part ? COMMAND_WORD_PART : COMMAND_WORD_START;
                return true;
            }
            scan_variable_name(lexer);
        } else {
            lexer->advance(lexer, false);
            if (c == '`' && lexer->lookahead) {
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
    if ((valid_symbols[COMMAND_WORD_START] || valid_symbols[COMMAND_WORD_PART] ||
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
