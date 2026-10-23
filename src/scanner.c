// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See the LICENSE file in the project root for full license information.

#include "tree_sitter/parser.h"
#include "parameter_letters.h"
#include <wctype.h>

enum TOKEN_TYPE {
    STATEMENT_TERMINATOR,
    BARE_DASHES,
    ELSE_CLAUSE_AHEAD,
    SCRIPT_BLOCK_ARGUMENT_START,
    SPACES_BEFORE_COMMA,
    COMMAND_WORD_START,
    COMMAND_WORD_PART,
    COMMAND_WORD_EXPRESSION,
    QUOTED_ARGUMENT_BOUNDARY,
    PARAMETER_ARGUMENT_SEPARATOR,
    PARAMETER_ARGUMENT_START,
    COLON_WORD_CONTINUATION,
    COMPLETED_EXPRESSION_BOUNDARY,
    COMPLETED_MEMBER_BOUNDARY,
    ERROR_SENTINEL,
    PATH_COMMAND_NAME_CONTINUATION,
    COMMAND_NAME_ESCAPE,
    TRAILING_DOT_TYPE_NAME,
    COMMAND_NAME_START_ESCAPE,
    COMMAND_ARRAY_ITEM_START,
    PARAMETER_DOT_BOUNDARY,
    PARAMETER_DOT_LITERAL_BOUNDARY,
    QUALIFIED_VARIABLE,
    QUALIFIED_VARIABLE_IN_STRING
};

/* --- API --- */

void *tree_sitter_powershell_external_scanner_create();

void tree_sitter_powershell_external_scanner_destroy(void *p);

unsigned tree_sitter_powershell_external_scanner_serialize(void *payload, char *buffer);

void tree_sitter_powershell_external_scanner_deserialize(void *payload, const char *buffer, unsigned length);

bool tree_sitter_powershell_external_scanner_scan(void *payload, TSLexer *lexer, const bool *valid_symbols);

/* --- Internal Functions --- */

static void skip(TSLexer *lexer) { lexer->advance(lexer, true); }

static bool line_end(int32_t c) { return c == '\r' || c == '\n'; }

static void skip_line_end(TSLexer *lexer)
{
    if (lexer->lookahead == '\r') skip(lexer);
    if (lexer->lookahead == '\n') skip(lexer);
}

static bool command_array_space(int32_t c)
{
    return iswspace(c) || c == 0x85 || c == 0xa0 || c == 0x1680 ||
           (c >= 0x2000 && c <= 0x200a) || c == 0x2028 || c == 0x2029 ||
           c == 0x202f || c == 0x205f || c == 0x3000;
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

static bool is_quote(int32_t c)
{
    return c == '"' || c == '\'' || (c >= 0x2018 && c <= 0x201e);
}

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
        while (lexer->lookahead != 0 && !line_end(lexer->lookahead)) skip(lexer);
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

static bool command_word_end(int32_t c)
{
    return c == 0 || iswspace(c) || c == 0xa0 || c == '(' || c == ')' ||
           c == '{' || c == '}' || c == ';' || c == ',' || c == '|' || c == '&';
}

static bool variable_char(int32_t c)
{
    return (c < 0x80 && iswalnum(c)) || is_unicode_parameter_letter(c) ||
           is_unicode_variable_digit(c) || c == '_' || c == '?';
}

// The first colon needs a name; subsequent single colons belong to the path,
// even at its end. A double colon always starts static member access.
static unsigned scan_variable_path(TSLexer *lexer, bool *static_access)
{
    if (!variable_char(lexer->lookahead) || lexer->lookahead == '?') return 0;
    while (variable_char(lexer->lookahead)) lexer->advance(lexer, false);
    lexer->mark_end(lexer);
    unsigned colons = 0;
    while (lexer->lookahead == ':') {
        lexer->advance(lexer, false);
        if (lexer->lookahead == ':') {
            *static_access = true;
            break;
        }
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
    bool static_access = false;
    if (scan_variable_path(lexer, &static_access) < 2) return false;
    lexer->result_symbol = in_string ? QUALIFIED_VARIABLE_IN_STRING : QUALIFIED_VARIABLE;
    return true;
}

static unsigned scan_variable_name(TSLexer *lexer, bool *static_access)
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
        return scan_variable_path(lexer, static_access);
    }
    return 0;
}

static bool digit(int32_t c) { return c >= '0' && c <= '9'; }

// Preserve the inherited numeric CST for a complete negative number. In command
// mode consumers must interpret that existing shape as a word, not negation.
static bool scan_number_prefix(TSLexer *lexer)
{
    bool hex = false;
    bool real = false;
    bool digits = false;
    if (lexer->lookahead == '0') {
        lexer->advance(lexer, false);
        digits = true;
        if (towlower(lexer->lookahead) == 'x') {
            lexer->advance(lexer, false);
            hex = true;
            digits = false;
        }
    }
    while (digit(lexer->lookahead) ||
           (hex && ((lexer->lookahead >= 'a' && lexer->lookahead <= 'f') ||
                    (lexer->lookahead >= 'A' && lexer->lookahead <= 'F')))) {
        lexer->advance(lexer, false);
        digits = true;
    }
    if (!hex && lexer->lookahead == '.') {
        real = true;
        lexer->advance(lexer, false);
        digits = false;
        while (digit(lexer->lookahead)) {
            lexer->advance(lexer, false);
            digits = true;
        }
    }
    if (!digits) return false;
    if (!hex && towlower(lexer->lookahead) == 'e') {
        lexer->advance(lexer, false);
        if (lexer->lookahead == '+' || lexer->lookahead == '-')
            lexer->advance(lexer, false);
        if (!digit(lexer->lookahead)) return false;
        while (digit(lexer->lookahead)) lexer->advance(lexer, false);
    } else if (!real && (towlower(lexer->lookahead) == 'l' ||
                        (!hex && towlower(lexer->lookahead) == 'd'))) {
        lexer->advance(lexer, false);
    }
    int32_t c = towlower(lexer->lookahead);
    if (c == 'k' || c == 'm' || c == 'g' || c == 't' || c == 'p') {
        lexer->advance(lexer, false);
        if (towlower(lexer->lookahead) != 'b') return false;
        lexer->advance(lexer, false);
    }
    return true;
}

// Only start a word when it is not a standalone expression. Once an unquoted
// word has begun, adjacent quotes and $() belong to it. Leave those expressions
// in the tree so that nested commands remain visible to syntax consumers.
static bool scan_command_word(TSLexer *lexer, const bool *valid_symbols)
{
    if (valid_symbols[ERROR_SENTINEL]) return false;
    bool part = valid_symbols[COMMAND_WORD_PART];
    bool start = valid_symbols[COMMAND_WORD_START] && !part;
    lexer->mark_end(lexer);

    if (is_quote(lexer->lookahead)) {
        if (!valid_symbols[COMMAND_WORD_EXPRESSION]) return false;
        lexer->result_symbol = COMMAND_WORD_EXPRESSION;
        return true;
    }
    if (start && (lexer->lookahead == ':' || lexer->lookahead == '@' ||
                  lexer->lookahead == '>' || lexer->lookahead == '#' ||
                  lexer->lookahead == '<')) return false;

    bool joined = false;
    bool consumed = false;
    bool parameter = start && lexer->lookahead == '-';
    bool parameter_name = false;
    bool quoted = false;
    bool redirection_prefix = lexer->lookahead == '*' ||
        (lexer->lookahead >= '0' && lexer->lookahead <= '9');
    if (start && lexer->lookahead == '$') {
        lexer->advance(lexer, false);
        if (lexer->lookahead == '(') return false;
        bool static_access = false;
        unsigned colons = scan_variable_name(lexer, &static_access);
        if (command_word_end(lexer->lookahead) || lexer->lookahead == '.' ||
            lexer->lookahead == '[' || lexer->lookahead == '>' ||
            (static_access && colons >= 2)) {
            if (colons >= 2 && valid_symbols[QUALIFIED_VARIABLE]) {
                lexer->result_symbol = QUALIFIED_VARIABLE;
                return true;
            }
            return false;
        }
        joined = consumed = true;
    }

    unsigned dashes = 0;
    bool only_dashes = true;
    bool parameter_dot = false;
    if (parameter) {
        lexer->advance(lexer, false);
        parameter_dot = ((lexer->lookahead < 0x80 && iswalpha(lexer->lookahead)) ||
                         is_unicode_parameter_letter(lexer->lookahead) ||
                         lexer->lookahead == '_' || lexer->lookahead == '?' ||
                         lexer->lookahead == '`');
        consumed = true;
        dashes = 1;
        if (digit(lexer->lookahead) || lexer->lookahead == '.') {
            parameter = false;
            joined = true;
            only_dashes = false;
            if (scan_number_prefix(lexer) && command_word_end(lexer->lookahead)) return false;
        }
        lexer->mark_end(lexer);
    }
    for (;;) {
        int32_t c = lexer->lookahead;
        if (command_word_end(c)) break;
        // A later quote must not turn -Name.Property into one joined word.
        if (parameter_dot && c == '.') return false;
        if (c == '[') parameter_dot = false;
        if (c == '>') {
            if (start && redirection_prefix) return false;
        } else if ((c < '0' || c > '9') && !(c == '*' && !consumed)) {
            redirection_prefix = false;
        }
        if (parameter && ((c < 0x80 && iswalpha(c)) || is_unicode_parameter_letter(c) ||
                          c == '_' || c == '?')) parameter_name = true;
        if (c == '-') dashes++;
        else only_dashes = false;
        if (is_quote(c)) {
            joined = quoted = true;
            break;
        }
        // Keep the existing parameter representation for -Name:value and
        // --option=value; only an attached quote makes -o"value" a word.
        if (parameter && (c == ':' || c == '=')) return false;
        if (c == '$') {
            lexer->mark_end(lexer);
            lexer->advance(lexer, false);
            if (lexer->lookahead == '(') {
                if (parameter_name) return false;
                if (!consumed) {
                    if (!valid_symbols[COMMAND_WORD_EXPRESSION]) return false;
                    lexer->result_symbol = COMMAND_WORD_EXPRESSION;
                    return true;
                }
                lexer->result_symbol = part ? COMMAND_WORD_PART : COMMAND_WORD_START;
                return true;
            }
            bool static_access = false;
            scan_variable_name(lexer, &static_access);
            joined = true;
        } else {
            lexer->advance(lexer, false);
            if (c == '`') {
                if (parameter_dot && lexer->lookahead == '.') return false;
                if (!consumed && !part &&
                    command_array_space(lexer->lookahead)) return false;
                if (lexer->eof(lexer)) return false;
                if (lexer->lookahead) lexer->advance(lexer, false);
                joined = true;
            }
        }
        consumed = true;
        lexer->mark_end(lexer);
    }
    if (only_dashes && dashes > 0 && dashes <= 2 &&
        lexer->lookahead != ',' && valid_symbols[BARE_DASHES]) {
        lexer->result_symbol = BARE_DASHES;
        return true;
    }
    if (!consumed || (start && (!joined || (parameter_name && !quoted)))) return false;
    lexer->mark_end(lexer);
    lexer->result_symbol = part ? COMMAND_WORD_PART : COMMAND_WORD_START;
    return true;
}

// A leading | or || continues the preceding pipeline, but an empty line
// terminates it. Comment-only lines do not count as empty lines.
static bool statement_continuation_follows(TSLexer *lexer, const bool *valid_symbols)
{
    bool allow_pipe = true;
    bool allow_else = valid_symbols[ELSE_CLAUSE_AHEAD];
    skip_line_end(lexer); // The newline after the left-hand side.
    for (;;) {
        while (!line_end(lexer->lookahead) && iswspace(lexer->lookahead)) skip(lexer);
        if (lexer->lookahead == '#') {
            while (lexer->lookahead && !line_end(lexer->lookahead)) skip(lexer);
        } else if (lexer->lookahead == '<') {
            allow_else = false;
            skip(lexer);
            if (lexer->lookahead != '#') return false;
            skip(lexer);
            unsigned depth = 1;
            while (depth && lexer->lookahead) {
                if (lexer->lookahead == '<') {
                    skip(lexer);
                    if (lexer->lookahead == '#') {
                        skip(lexer);
                        depth++;
                    }
                } else if (lexer->lookahead == '#') {
                    skip(lexer);
                    if (lexer->lookahead == '>') {
                        skip(lexer);
                        depth--;
                    }
                } else {
                    skip(lexer);
                }
            }
            if (depth) return false;
            while (!line_end(lexer->lookahead) && iswspace(lexer->lookahead)) skip(lexer);
            if (!line_end(lexer->lookahead)) continue;
        } else if (line_end(lexer->lookahead)) {
            allow_pipe = false;
            if (!allow_else) return false;
        } else {
            if (lexer->lookahead == '|') return allow_pipe;
            return allow_else && else_follows(lexer);
        }
        if (!line_end(lexer->lookahead)) return false;
        skip_line_end(lexer);
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
            if (line_end(lexer->lookahead)) return !statement_continuation_follows(lexer, valid_symbols);
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
            if (!line_end(lexer->lookahead)) return false;
            skip_line_end(lexer);
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

static bool scan_argument_boundary(TSLexer *lexer, const bool *valid_symbols)
{
    if (valid_symbols[ERROR_SENTINEL]) return false;
    bool quoted = valid_symbols[QUOTED_ARGUMENT_BOUNDARY];
    bool value = valid_symbols[COMPLETED_EXPRESSION_BOUNDARY];
    bool member = valid_symbols[COMPLETED_MEMBER_BOUNDARY];
    if (!quoted && !value && !member) return false;
    int32_t c = lexer->lookahead;
    // Keep expression suffixes, punctuation and elements that already work
    // without spaces on their existing grammar paths.
    if (c == 0 || iswspace(c) || c == '.' || c == '[' || c == ':' ||
        c == ';' || c == '|' || c == '&' || c == ')' || c == '}' ||
        c == ',' || c == '>' || c == '<' ||
        c == '`' || c == '#' || c == 0xfeff ||
        c == 0x2060 || c == 0x200b || c == 0xa0) return false;
    if ((c == '(' || c == '{') && !value) return false;
    lexer->mark_end(lexer);
    if (c == '-') {
        if (!quoted && !value) return false;
        lexer->advance(lexer, false);
        if (!digit(lexer->lookahead) && lexer->lookahead != '.') return false;
    } else if (c == '?') {
        lexer->advance(lexer, false);
        if (lexer->lookahead == '.' || lexer->lookahead == '[') return false;
    } else if (c == '*' || (c >= '0' && c <= '9')) {
        do {
            lexer->advance(lexer, false);
        } while (lexer->lookahead >= '0' && lexer->lookahead <= '9');
        if (lexer->lookahead == '>') return false;
    }
    lexer->result_symbol = quoted ? QUOTED_ARGUMENT_BOUNDARY :
        value ? COMPLETED_EXPRESSION_BOUNDARY : COMPLETED_MEMBER_BOUNDARY;
    return true;
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
    // A dot ends a parameter name and starts a command word, not a member.
    if (!valid_symbols[ERROR_SENTINEL] &&
        (valid_symbols[PARAMETER_DOT_BOUNDARY] ||
         valid_symbols[PARAMETER_DOT_LITERAL_BOUNDARY]) && lexer->lookahead == '.') {
        lexer->mark_end(lexer);
        lexer->advance(lexer, false);
        bool literal = lexer->lookahead == '$' || lexer->lookahead == '"' ||
                       lexer->lookahead == '\'';
        lexer->result_symbol = literal ? PARAMETER_DOT_LITERAL_BOUNDARY : PARAMETER_DOT_BOUNDARY;
        return valid_symbols[lexer->result_symbol];
    }
    if (valid_symbols[COMMAND_ARRAY_ITEM_START] && !valid_symbols[ERROR_SENTINEL])
        return scan_command_array_item_start(lexer, valid_symbols);
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
    if (scan_path_command_name_continuation(lexer, valid_symbols)) return true;
    if (!valid_symbols[ERROR_SENTINEL]) {
        if (valid_symbols[TRAILING_DOT_TYPE_NAME]) return scan_trailing_dot_type_name(lexer);
        if (valid_symbols[PARAMETER_ARGUMENT_START]) {
            return scan_parameter_argument_start(lexer, valid_symbols);
        }
        // An attachment colon must directly follow its parameter.
        if (valid_symbols[PARAMETER_ARGUMENT_SEPARATOR] && lexer->lookahead == ':') {
            lexer->advance(lexer, false);
            lexer->mark_end(lexer);
            lexer->result_symbol = PARAMETER_ARGUMENT_SEPARATOR;
            return true;
        }
        if (valid_symbols[COLON_WORD_CONTINUATION] &&
            (lexer->lookahead == '$' || is_quote(lexer->lookahead))) {
            lexer->mark_end(lexer);
            lexer->result_symbol = COLON_WORD_CONTINUATION;
            return true;
        }
    }
    // Before anything that skips spaces: the `{` must directly follow.
    if (scan_script_block_argument_start(payload, lexer, valid_symbols)) return true;

    // Dash/suffix/redirection lookahead cannot be rewound before another scanner.
    if ((valid_symbols[QUOTED_ARGUMENT_BOUNDARY] ||
         valid_symbols[COMPLETED_EXPRESSION_BOUNDARY] ||
         valid_symbols[COMPLETED_MEMBER_BOUNDARY]) &&
        (lexer->lookahead == '-' || lexer->lookahead == '?' || lexer->lookahead == '*' ||
         (lexer->lookahead >= '0' && lexer->lookahead <= '9')))
        return scan_argument_boundary(lexer, valid_symbols);
    if (scan_argument_boundary(lexer, valid_symbols)) return true;

    bool word = valid_symbols[COMMAND_WORD_START] || valid_symbols[COMMAND_WORD_PART] ||
                valid_symbols[COMMAND_WORD_EXPRESSION];
    if ((valid_symbols[QUALIFIED_VARIABLE] || valid_symbols[QUALIFIED_VARIABLE_IN_STRING]) &&
        !valid_symbols[ERROR_SENTINEL] &&
        (valid_symbols[QUALIFIED_VARIABLE_IN_STRING] || !word || lexer->lookahead == '@')) {
        while (!valid_symbols[QUALIFIED_VARIABLE_IN_STRING] &&
               command_array_space(lexer->lookahead)) {
            if (valid_symbols[STATEMENT_TERMINATOR] &&
                (lexer->lookahead == '\r' || lexer->lookahead == '\n')) break;
            skip(lexer);
        }
        if (lexer->lookahead == '$' || lexer->lookahead == '@')
            return scan_qualified_variable(lexer, valid_symbols);
    }

    // Word pieces never skip whitespace. A failed lookahead may have advanced
    // the lexer, so do not try the other scanners afterwards.
    if ((valid_symbols[COMMAND_WORD_START] || valid_symbols[COMMAND_WORD_PART] ||
         valid_symbols[COMMAND_WORD_EXPRESSION]) &&
        !command_word_end(lexer->lookahead))
        return scan_command_word(lexer, valid_symbols);

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
