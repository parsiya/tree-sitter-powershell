// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See the LICENSE file in the project root for full license information.

#include "tree_sitter/parser.h"
#include <wctype.h>

enum TOKEN_TYPE {
    STATEMENT_TERMINATOR,
    BARE_DASHES,
    ELSE_CLAUSE_AHEAD,
    SCRIPT_BLOCK_ARGUMENT_START,
    SPACES_BEFORE_COMMA,
    // Never used by the grammar: it is only valid during error recovery.
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

static bool is_word_char(int32_t c)
{
    return iswalnum(c) || c == '_' || c == '-';
}

// After a newline, `else` or `elseif` continues an if statement used as a
// value, as in `$x = if ($a) { 1 }` followed by `else { 2 }` on the next line.
// Look past blank lines and line comments for one of those keywords. Only
// called where the grammar allows an elseif or else clause to start.
static bool else_follows(TSLexer *lexer)
{
    for (;;) {
        while (iswspace(lexer->lookahead)) skip(lexer);
        if (lexer->lookahead != '#') break;
        while (lexer->lookahead != 0 && lexer->lookahead != '\n') skip(lexer);
    }

    const char *keyword = "else";
    for (const char *c = keyword; *c; c++) {
        if (towlower(lexer->lookahead) != (wint_t)(unsigned char)*c) return false;
        skip(lexer);
    }
    if (towlower(lexer->lookahead) == 'i') {
        skip(lexer);
        if (towlower(lexer->lookahead) != 'f') return false;
        skip(lexer);
    }
    return !is_word_char(lexer->lookahead);
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
            if (lexer->lookahead == '\n') {
                return !(valid_symbols[ELSE_CLAUSE_AHEAD] && else_follows(lexer));
            }
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

// `$x.Where{ $_ }`: a script block right after a member name is a method
// argument. There must be no whitespace before the `{` (`$x.Name { }` is not a
// method call), so this empty token only checks that `{` comes next.
static bool scan_script_block_argument_start(void *payload, TSLexer *lexer, const bool *valid_symbols)
{
    if (!valid_symbols[SCRIPT_BLOCK_ARGUMENT_START] || valid_symbols[ERROR_SENTINEL]) return false;
    if (lexer->lookahead != '{') return false;
    lexer->result_symbol = SCRIPT_BLOCK_ARGUMENT_START;
    lexer->mark_end(lexer);
    return true;
}

// Spaces before a comma: `-Color $a , $b` is one array argument, but the
// space would otherwise be lexed as the separator before the next argument.
// The spaces (and line continuations) are skipped and an empty extra token is
// returned, so that the comma is then lexed as usual.
static bool scan_spaces_before_comma(void *payload, TSLexer *lexer, const bool *valid_symbols, bool *skipped_backtick)
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

/* --- API Implementation --- */

bool tree_sitter_powershell_external_scanner_scan(void *payload, TSLexer *lexer, const bool *valid_symbols)
{
    // Before anything that skips spaces: the `{` must directly follow.
    if (scan_script_block_argument_start(payload, lexer, valid_symbols)) return true;

    bool skipped_backtick = false;
    if (scan_spaces_before_comma(payload, lexer, valid_symbols, &skipped_backtick)) return true;
    // Skipped characters cannot be restored, and the other external tokens
    // cannot follow a backtick anyway.
    if (skipped_backtick) return false;

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
