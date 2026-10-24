// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See the LICENSE file in the project root for full license information.

#include "tree_sitter/parser.h"
#include "parameter_letters.h"
#include <stdlib.h>
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
    QUALIFIED_VARIABLE_IN_STRING,
    TRY_CLAUSE_AHEAD,
    NUMERIC_COMMAND_NAME,
    TRAILING_DOT_REAL_LITERAL,
    VARIABLE_COMMAND_NAME_CONTINUATION,
    INVOCATION_ARGUMENT_BOUNDARY,
    VARIABLE_BEFORE_LITERAL_DOT,
    COMMAND_NAME_SUBEXPRESSION,
    ANGLE_ARGUMENT_BOUNDARY,
    LEADING_BOM,
    STRING_SUBEXPRESSION_START,
    STRING_SUBEXPRESSION_END,
    QUOTE_UNIT_OPEN,
    QUOTE_UNIT_CLOSE,
    QUOTE_UNIT_ESCAPE,
    EXPANDABLE_STRING_AHEAD,
    COMMAND_NAME_DOLLAR,
    INLINESCRIPT_NAME,
    FUNCTION_CONTEXT_PLAIN,
    FUNCTION_CONTEXT_WORKFLOW,
    FUNCTION_CONTEXT_END,
    LABEL,
    FLOW_CONTROL_COLON_WORD
};

// Native reads a doubled quote inside the subexpression of an expandable
// string as one quote, so the scanner counts the open string subexpressions.
// Native reads `inlinescript` as a keyword only in a workflow body; a nested
// function ends that context. Bit N of workflow_bits says whether the function
// at depth N + 1 is a workflow; levels beyond 64 share the last bit.
typedef struct {
    unsigned char string_subexpression_depth;
    unsigned char function_depth;
    unsigned long long workflow_bits;
} Scanner;

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

// Whitespace as Native PowerShell sees it (Char.IsWhiteSpace); iswspace depends
// on the locale and misses the Unicode spaces. U+FEFF, U+2060 and U+200B are not
// whitespace.
static bool command_array_space(int32_t c)
{
    return (c >= '\t' && c <= '\r') || c == ' ' || c == 0x85 || c == 0xa0 ||
           c == 0x1680 || (c >= 0x2000 && c <= 0x200a) || c == 0x2028 ||
           c == 0x2029 || c == 0x202f || c == 0x205f || c == 0x3000;
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

// Native quote families: ' and U+2018-U+201B, " and U+201C-U+201E.
static bool single_quote(int32_t c)
{
    return c == '\'' || (c >= 0x2018 && c <= 0x201b);
}

static bool double_quote(int32_t c)
{
    return c == '"' || (c >= 0x201c && c <= 0x201e);
}

static bool is_quote(int32_t c)
{
    return single_quote(c) || double_quote(c);
}

enum option_quote { OPTION_QUOTE_BAD, OPTION_QUOTE_PLAIN, OPTION_QUOTE_EXPANDABLE };

static bool variable_char(int32_t c);

// Skip a quoted value of a `--name=` option, as the parameter token matches it.
// A double-quoted value with a variable or subexpression is reported early, with
// the lexer inside the string, so that the caller can end the word before it.
static enum option_quote skip_option_quote(TSLexer *lexer)
{
    bool single = lexer->lookahead == '\'' ||
                  (lexer->lookahead >= 0x2018 && lexer->lookahead <= 0x201b);
    lexer->advance(lexer, false);
    for (;;) {
        int32_t c = lexer->lookahead;
        if (c == 0 || c == '\r' || c == '\n') return OPTION_QUOTE_BAD;
        lexer->advance(lexer, false);
        if (single ? (c == '\'' || (c >= 0x2018 && c <= 0x201b))
                   : (c == '"' || (c >= 0x201c && c <= 0x201e))) return OPTION_QUOTE_PLAIN;
        if (single) continue;
        if (c == '`') {
            if (lexer->lookahead == 0 || lexer->lookahead == '\r' ||
                lexer->lookahead == '\n') return OPTION_QUOTE_BAD;
            lexer->advance(lexer, false);
        } else if (c == '$') {
            int32_t d = lexer->lookahead;
            if (d == '(' || d == '{' || d == '$' || d == '^' || variable_char(d))
                return OPTION_QUOTE_EXPANDABLE;
        }
    }
}

static bool is_word_char(int32_t c)
{
    return iswalnum(c) || c == '_' || c == '-';
}

// Clauses continue compound statements even when an enclosing assignment
// could otherwise end at the newline.
static bool clause_follows(TSLexer *lexer, bool allow_else, bool allow_try)
{
    for (;;) {
        while (command_array_space(lexer->lookahead)) skip(lexer);
        if (lexer->lookahead != '#') break;
        while (lexer->lookahead != 0 && !line_end(lexer->lookahead)) skip(lexer);
    }

    const char *keyword;
    if (allow_else && towlower(lexer->lookahead) == 'e') keyword = "else";
    else if (allow_try && towlower(lexer->lookahead) == 'c') keyword = "catch";
    else if (allow_try && towlower(lexer->lookahead) == 'f') keyword = "finally";
    else return false;
    for (const char *c = keyword; *c; c++) {
        if (towlower(lexer->lookahead) != (wint_t)(unsigned char)*c) return false;
        skip(lexer);
    }
    if (keyword[0] == 'e' && towlower(lexer->lookahead) == 'i') {
        skip(lexer);
        if (towlower(lexer->lookahead) != 'f') return false;
        skip(lexer);
    }
    return !is_word_char(lexer->lookahead);
}

// En dash, em dash and horizontal bar also start a command parameter.
static bool is_unicode_dash(int32_t c)
{
    return c >= 0x2013 && c <= 0x2015;
}

static bool command_word_end(int32_t c)
{
    return c == 0 || command_array_space(c) || c == '(' || c == ')' ||
           c == '{' || c == '}' || c == ';' || c == ',' || c == '|' || c == '&';
}

// Operator characters that cannot start a parameter name after a dash.
static bool dash_word_symbol(int32_t c)
{
    return c == '=' || c == '+' || c == '*' || c == '/' || c == '%' || c == '[';
}

static bool literal_dot_follows(TSLexer *lexer)
{
    if (lexer->lookahead != '.') return false;
    lexer->advance(lexer, false);
    return lexer->eof(lexer) || command_array_space(lexer->lookahead) ||
           lexer->lookahead == '.';
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

// Opengrep's `$...NAME` metavariable is a variable, not a word.
static bool named_ellipsis_follows(TSLexer *lexer)
{
    for (int dots = 0; dots < 3; dots++) {
        if (lexer->lookahead != '.') return false;
        lexer->advance(lexer, false);
    }
    return (lexer->lookahead >= 'A' && lexer->lookahead <= 'Z') || lexer->lookahead == '_';
}

// A command name may begin with a `$` that no variable name follows; the rest
// of the word comes from the immediate name parts, including a quoted part
// (`$"text {0}" -f $x`). The `$` was just consumed.
static bool scan_command_name_dollar(TSLexer *lexer)
{
    lexer->mark_end(lexer);
    int32_t c = lexer->lookahead;
    if (variable_char(c) || c == '$' || c == '^' || c == '{' || c == '(' || c == ':' ||
        c == '`' || (c == '.' && named_ellipsis_follows(lexer))) return false;
    // A dash or `>` run would otherwise lex as an operator, not as the name's tail.
    while (lexer->lookahead == '-' || lexer->lookahead == '>') {
        lexer->advance(lexer, false);
        lexer->mark_end(lexer);
    }
    lexer->result_symbol = COMMAND_NAME_DOLLAR;
    return true;
}

static bool scan_qualified_variable(Scanner *scanner, TSLexer *lexer, const bool *valid_symbols)
{
    bool in_string = valid_symbols[QUALIFIED_VARIABLE_IN_STRING];
    if (lexer->lookahead != '$' && lexer->lookahead != '@') return false;
    if (in_string && lexer->lookahead == '@') return false;
    bool sigil_dollar = lexer->lookahead == '$';
    lexer->advance(lexer, false);
    if (in_string && sigil_dollar && valid_symbols[EXPANDABLE_STRING_AHEAD] &&
        valid_symbols[STRING_SUBEXPRESSION_START] &&
        lexer->lookahead == '(') {
        lexer->advance(lexer, false);
        lexer->mark_end(lexer);
        if (scanner->string_subexpression_depth < 255) scanner->string_subexpression_depth++;
        lexer->result_symbol = STRING_SUBEXPRESSION_START;
        return true;
    }
    if (!in_string && sigil_dollar && valid_symbols[COMMAND_NAME_DOLLAR] &&
        scan_command_name_dollar(lexer)) return true;
    bool static_access = false;
    if (scan_variable_path(lexer, &static_access) < 2) return false;
    lexer->result_symbol = in_string ? QUALIFIED_VARIABLE_IN_STRING : QUALIFIED_VARIABLE;
    return true;
}

static unsigned scan_variable_name(TSLexer *lexer, bool *static_access, bool *valid_name)
{
    if (valid_name) *valid_name = true;
    if (lexer->lookahead == '{') {
        lexer->advance(lexer, false);
        if (valid_name && (!lexer->lookahead || lexer->lookahead == '}'))
            *valid_name = false;
        while (lexer->lookahead && lexer->lookahead != '}')
            lexer->advance(lexer, false);
        if (lexer->lookahead) lexer->advance(lexer, false);
    } else if (lexer->lookahead == '$' || lexer->lookahead == '?' ||
               lexer->lookahead == '^') {
        lexer->advance(lexer, false);
    } else {
        if (valid_name) *valid_name = variable_char(lexer->lookahead);
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

// Only the initial digits are emitted; the ordinary name rule consumes the
// rest. Look ahead first so a numeric prefix followed by '.' stays an expression,
// while an invalid numeric suffix (7z, 1.2tool) still starts a command name.
// A complete trailing-dot number needs an external token to avoid stealing '..'.
static bool scan_numeric_start(TSLexer *lexer, const bool *valid_symbols)
{
    bool hex = false;
    bool fraction = lexer->lookahead == '.';
    bool digits = false;
    if (lexer->lookahead == '0') {
        lexer->advance(lexer, false);
        digits = true;
        lexer->mark_end(lexer);
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
        if (!hex) lexer->mark_end(lexer);
    }
    bool number = digits;
    bool real = false;
    if (!hex && lexer->lookahead == '.') {
        lexer->advance(lexer, false);
        if (digits && lexer->lookahead == '.') return false;
        if (digits && (command_word_end(lexer->lookahead) || lexer->lookahead == '#') &&
            valid_symbols[TRAILING_DOT_REAL_LITERAL]) {
            lexer->mark_end(lexer);
            lexer->result_symbol = TRAILING_DOT_REAL_LITERAL;
            return true;
        }
        digits = false;
        while (digit(lexer->lookahead)) {
            lexer->advance(lexer, false);
            digits = true;
            if (fraction) lexer->mark_end(lexer);
        }
        if (fraction && !digits) return false;
        number = real = digits;
    }
    if (number && !hex && towlower(lexer->lookahead) == 'e') {
        lexer->advance(lexer, false);
        if (lexer->lookahead == '+' || lexer->lookahead == '-')
            lexer->advance(lexer, false);
        number = digit(lexer->lookahead);
        while (digit(lexer->lookahead)) lexer->advance(lexer, false);
    } else if (number && !real && (towlower(lexer->lookahead) == 'l' ||
                                 (!hex && towlower(lexer->lookahead) == 'd'))) {
        lexer->advance(lexer, false);
    }
    int32_t c = towlower(lexer->lookahead);
    if (number && (c == 'k' || c == 'm' || c == 'g' || c == 't' || c == 'p')) {
        lexer->advance(lexer, false);
        number = towlower(lexer->lookahead) == 'b';
        if (number) lexer->advance(lexer, false);
    }
    c = lexer->lookahead;
    // A comment can follow a number directly: `22#25`.
    if (number && (c == '.' || command_word_end(c) || c == '#' || c == '[' ||
                  c == '+' || c == '-' || c == '*' || c == '/' ||
                  c == '<' || c == '!')) return false;
    lexer->result_symbol = NUMERIC_COMMAND_NAME;
    return valid_symbols[NUMERIC_COMMAND_NAME];
}

static bool continuation_ends_statement(TSLexer *lexer, const bool *valid_symbols);

// Only start a word when it is not a standalone expression. Once an unquoted
// word has begun, adjacent quotes and $() belong to it. Leave those expressions
// in the tree so that nested commands remain visible to syntax consumers.
static bool scan_command_word(TSLexer *lexer, const bool *valid_symbols, bool quote_units)
{
    if (valid_symbols[ERROR_SENTINEL]) return false;
    bool part = valid_symbols[COMMAND_WORD_PART];
    bool start = (valid_symbols[COMMAND_WORD_START] ||
                  valid_symbols[VARIABLE_BEFORE_LITERAL_DOT]) && !part;
    lexer->mark_end(lexer);

    if (is_quote(lexer->lookahead)) {
        if (!valid_symbols[COMMAND_WORD_EXPRESSION]) return false;
        lexer->result_symbol = COMMAND_WORD_EXPRESSION;
        return true;
    }
    if (start && (lexer->lookahead == ':' ||
                  lexer->lookahead == '>' || lexer->lookahead == '#' ||
                  lexer->lookahead == '<')) return false;

    bool joined = false;
    bool consumed = false;
    bool unicode_dash = start && is_unicode_dash(lexer->lookahead);
    bool parameter = start && (lexer->lookahead == '-' || unicode_dash);
    bool parameter_name = false;
    bool quoted = false;
    bool escaped_quote = false;
    bool redirection_prefix = lexer->lookahead == '*' ||
        (lexer->lookahead >= '0' && lexer->lookahead <= '9');
    if (start && (lexer->lookahead == '$' || lexer->lookahead == '@')) {
        bool splat = lexer->lookahead == '@';
        lexer->advance(lexer, false);
        // `@$name/path` is an expandable word, while `@${name}` and `@$(...)`
        // begin with the splatted variable `@$`.
        bool at_expansion = false;
        if (splat && lexer->lookahead == '$') {
            lexer->advance(lexer, false);
            if (!variable_char(lexer->lookahead)) return false;
            at_expansion = true;
        }
        if (lexer->lookahead == '(' || (splat && !variable_char(lexer->lookahead)))
            return false;
        bool automatic = lexer->lookahead == '$' || lexer->lookahead == '?' ||
                         lexer->lookahead == '^';
        bool static_access = false;
        bool valid_name;
        int32_t name_start = lexer->lookahead;
        unsigned colons = scan_variable_name(lexer, &static_access, &valid_name);
        // A `$` that no variable name follows is an ordinary word character.
        bool bare_dollar = !splat && !at_expansion && !valid_name &&
                           name_start != '{' && name_start != ':';
        if (bare_dollar && name_start == '.' && named_ellipsis_follows(lexer)) return false;
        // In command mode `$name.` is a variable followed by a literal word,
        // not member access across the whitespace after the dot.
        if (!at_expansion && valid_name && !automatic && lexer->lookahead == '.' &&
            valid_symbols[VARIABLE_BEFORE_LITERAL_DOT]) {
            lexer->mark_end(lexer);
            if (!literal_dot_follows(lexer)) {
                if (colons < 2 || !valid_symbols[QUALIFIED_VARIABLE]) return false;
                lexer->result_symbol = QUALIFIED_VARIABLE;
                return true;
            }
            lexer->result_symbol = VARIABLE_BEFORE_LITERAL_DOT;
            return true;
        }
        if (!at_expansion && !bare_dollar &&
            (command_word_end(lexer->lookahead) || lexer->lookahead == '.' ||
            lexer->lookahead == '[' || lexer->lookahead == '>' ||
            (static_access && colons >= 2))) {
            if (colons >= 2 && valid_symbols[QUALIFIED_VARIABLE]) {
                lexer->result_symbol = QUALIFIED_VARIABLE;
                return true;
            }
            return false;
        }
        joined = consumed = true;
        if (bare_dollar) lexer->mark_end(lexer);
    }

    unsigned dashes = 0;
    bool only_dashes = true;
    bool parameter_dot = false;
    // `--name=$(...)` is a word, not a parameter, once a subexpression follows.
    bool option_word = false;
    bool option_separator = false;
    // `--name:value` and `--name=${var}` are words: the parameter token cannot hold them.
    bool option_value_word = false;
    if (parameter) {
        lexer->advance(lexer, false);
        option_word = !unicode_dash && lexer->lookahead == '-';
        parameter_dot = ((lexer->lookahead < 0x80 && iswalpha(lexer->lookahead)) ||
                         is_unicode_parameter_letter(lexer->lookahead) ||
                         lexer->lookahead == '_' || lexer->lookahead == '?' ||
                         lexer->lookahead == '`');
        consumed = true;
        dashes = 1;
        // `->` is a plain word: `>` after a lone dash is not a redirection.
        if (lexer->lookahead == '>') {
            parameter = false;
            joined = true;
            only_dashes = false;
        } else if (digit(lexer->lookahead) || lexer->lookahead == '.') {
            parameter = false;
            joined = true;
            only_dashes = false;
            if (scan_number_prefix(lexer) && command_word_end(lexer->lookahead)) return false;
        } else if (!unicode_dash && dash_word_symbol(lexer->lookahead)) {
            // `-=x`: no parameter name follows the dash, so this is a plain word.
            parameter = false;
            joined = true;
            only_dashes = false;
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
            // A quoted `--name="value"` stays a parameter unless `$(` follows.
            if (option_separator) {
                enum option_quote kind = skip_option_quote(lexer);
                if (kind == OPTION_QUOTE_BAD) return false;
                if (kind == OPTION_QUOTE_EXPANDABLE) {
                    lexer->result_symbol = part ? COMMAND_WORD_PART : COMMAND_WORD_START;
                    return true;
                }
                // `-a="x"` stays a parameter; only `--a="x"` continues as a word.
                if (!option_word) return false;
                consumed = true;
                lexer->mark_end(lexer);
                continue;
            }
            joined = quoted = true;
            break;
        }
        // Keep the existing parameter representation for -Name:value and
        // --option=value; only an attached quote makes -o"value" a word.
        if (parameter && (c == ':' || c == '=')) {
            if (!option_word && c == ':') return false;
            if (option_word && c == ':' && !option_separator && parameter_name)
                option_value_word = true;
            option_separator = true;
        }
        if (c == '$') {
            lexer->mark_end(lexer);
            lexer->advance(lexer, false);
            if (option_word && option_separator && lexer->lookahead == '{')
                option_value_word = true;
            if (lexer->lookahead == '(') {
                if (parameter_name && !option_word) return false;
                if (!consumed) {
                    if (!valid_symbols[COMMAND_WORD_EXPRESSION]) return false;
                    lexer->result_symbol = COMMAND_WORD_EXPRESSION;
                    return true;
                }
                lexer->result_symbol = part ? COMMAND_WORD_PART : COMMAND_WORD_START;
                return true;
            }
            bool static_access = false;
            scan_variable_name(lexer, &static_access, NULL);
            joined = true;
        } else {
            lexer->advance(lexer, false);
            if (c == '`') {
                // A backtick-escaped quote opens a string in a string
                // subexpression, even directly after a word.
                if (quote_units && double_quote(lexer->lookahead)) {
                    if (consumed) {
                        // The word ends before the backtick.
                        joined = quoted = escaped_quote = true;
                        break;
                    }
                    if (valid_symbols[QUOTE_UNIT_OPEN]) {
                        lexer->advance(lexer, false);
                        lexer->mark_end(lexer);
                        lexer->result_symbol = QUOTE_UNIT_OPEN;
                        return true;
                    }
                    // The string follows the empty token.
                    lexer->result_symbol = COMMAND_WORD_EXPRESSION;
                    return valid_symbols[COMMAND_WORD_EXPRESSION];
                }
                if (parameter_dot && lexer->lookahead == '.') return false;
                if (!consumed && !part && command_array_space(lexer->lookahead)) {
                    // Escaped whitespace is trivia, so it may end the statement.
                    // The token is empty and starts where this word attempt did.
                    return !valid_symbols[STATEMENT_TERMINATOR] ? false :
                        continuation_ends_statement(lexer, valid_symbols);
                }
                if (lexer->eof(lexer)) return false;
                if (lexer->lookahead) lexer->advance(lexer, false);
                joined = true;
            }
        }
        consumed = true;
        lexer->mark_end(lexer);
    }
    if (only_dashes && !unicode_dash && dashes > 0 && dashes <= 2 &&
        lexer->lookahead != ',' && valid_symbols[BARE_DASHES]) {
        lexer->result_symbol = BARE_DASHES;
        return true;
    }
    if (!consumed || (start && !option_value_word && (!joined || (parameter_name && !quoted)))) return false;
    if (!escaped_quote) lexer->mark_end(lexer);
    lexer->result_symbol = part ? COMMAND_WORD_PART : COMMAND_WORD_START;
    return true;
}

// A leading | or || continues the preceding pipeline, but an empty line
// terminates it. Comment-only lines do not count as empty lines.
static bool statement_continuation_follows(TSLexer *lexer, const bool *valid_symbols)
{
    bool allow_pipe = true;
    bool allow_else = valid_symbols[ELSE_CLAUSE_AHEAD];
    bool allow_try = valid_symbols[TRY_CLAUSE_AHEAD];
    skip_line_end(lexer); // The newline after the left-hand side.
    for (;;) {
        while (!line_end(lexer->lookahead) && command_array_space(lexer->lookahead)) skip(lexer);
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
            while (!line_end(lexer->lookahead) && command_array_space(lexer->lookahead)) skip(lexer);
            if (!line_end(lexer->lookahead)) continue;
        } else if (line_end(lexer->lookahead)) {
            allow_pipe = false;
            if (!allow_else && !allow_try) return false;
        } else {
            if (lexer->lookahead == '|') return allow_pipe;
            return (allow_else || allow_try) && clause_follows(lexer, allow_else, allow_try);
        }
        if (!line_end(lexer->lookahead)) return false;
        skip_line_end(lexer);
    }
}

// At a possible end of the statement. A backtick before whitespace (a line
// continuation, or escaped whitespace) is trivia, so the statement can end
// after it: `Get-X -a `\n}`. An empty line or the end of the input ends the
// statement; a comment, a pipe or another token does not.
static bool statement_terminator_follows(TSLexer *lexer, const bool *valid_symbols)
{
    for (;;) {
        int32_t c = lexer->lookahead;
        if (c == 0 || c == '}' || c == ';' || c == ')') return true;
        if (c == '`') {
            skip(lexer);
            if (lexer->eof(lexer) || !command_array_space(lexer->lookahead)) return false;
            if (lexer->lookahead == '\r') {
                skip(lexer);
                if (lexer->lookahead == '\n') skip(lexer);
            } else {
                skip(lexer);
            }
            continue;
        }
        if (line_end(c)) return !statement_continuation_follows(lexer, valid_symbols);
        if (!command_array_space(c)) return false;
        skip(lexer);
    }
}

// The caller has consumed a backtick that is followed by whitespace, after
// marking the start of the token.
static bool continuation_ends_statement(TSLexer *lexer, const bool *valid_symbols)
{
    if (lexer->lookahead == '\r') {
        skip(lexer);
        if (lexer->lookahead == '\n') skip(lexer);
    } else {
        skip(lexer);
    }
    if (!statement_terminator_follows(lexer, valid_symbols)) return false;
    lexer->result_symbol = STATEMENT_TERMINATOR;
    return true;
}

static bool scan_statement_terminator(void *payload, TSLexer *lexer, const bool *valid_symbols)
{
    if (valid_symbols[STATEMENT_TERMINATOR]) {
        lexer->result_symbol = STATEMENT_TERMINATOR;
        // This token has no characters -- everything is lookahead to determine its existence
        lexer->mark_end(lexer);
        return statement_terminator_follows(lexer, valid_symbols);
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

    while (!line_end(lexer->lookahead) && command_array_space(lexer->lookahead)) skip(lexer);
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
            if (!command_array_space(lexer->lookahead)) return false;
            lexer->result_symbol = BARE_DASHES;
            return true;
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
static bool scan_spaces_before_comma(void *payload, TSLexer *lexer, const bool *valid_symbols,
                                     bool *skipped_backtick, bool *stray_backtick)
{
    if (!valid_symbols[SPACES_BEFORE_COMMA]) return false;

    // The empty statement terminator also starts here, if no comma follows.
    lexer->mark_end(lexer);
    bool skipped = false;
    for (;;) {
        if (lexer->lookahead == ' ' || lexer->lookahead == '\t') {
            skip(lexer);
        } else if (lexer->lookahead == '`') {
            *skipped_backtick = true;
            skip(lexer);
            if (line_end(lexer->lookahead)) {
                skip_line_end(lexer);
            } else if (command_array_space(lexer->lookahead)) {
                // Escaped whitespace is trivia too: `@( $x.Name` )`.
                skip(lexer);
            } else {
                *stray_backtick = true;
                return false;
            }
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
    if (c == '`') {
        lexer->mark_end(lexer);
        lexer->advance(lexer, false);
        if (command_array_space(lexer->lookahead)) {
            if (lexer->lookahead == '\r') {
                lexer->advance(lexer, false);
                if (lexer->lookahead == '\n') lexer->advance(lexer, false);
            } else {
                lexer->advance(lexer, false);
            }
            while (!line_end(lexer->lookahead) && command_array_space(lexer->lookahead))
                lexer->advance(lexer, false);
            // Escaped whitespace is trivia at a completed expression boundary.
            // A following parameter still needs its ordinary separator path.
            if (command_word_end(lexer->lookahead) || lexer->lookahead == '-' ||
                lexer->lookahead == '#' || lexer->lookahead == '>') {
                if (!valid_symbols[STATEMENT_TERMINATOR] ||
                    !statement_terminator_follows(lexer, valid_symbols)) return false;
                lexer->result_symbol = STATEMENT_TERMINATOR;
                return true;
            }
        } else if (lexer->eof(lexer)) {
            return false;
        }
        lexer->result_symbol = quoted ? QUOTED_ARGUMENT_BOUNDARY :
            value ? COMPLETED_EXPRESSION_BOUNDARY : COMPLETED_MEMBER_BOUNDARY;
        return true;
    }
    if (c == '.' && (member || quoted)) {
        lexer->mark_end(lexer);
        if (!literal_dot_follows(lexer)) return false;
        lexer->result_symbol = member ? COMPLETED_MEMBER_BOUNDARY : QUOTED_ARGUMENT_BOUNDARY;
        return true;
    }
    // Keep expression suffixes, punctuation and elements that already work
    // without spaces on their existing grammar paths.
    if (c == 0 || command_array_space(c) || c == '.' || c == '[' || c == ':' ||
        c == ';' || c == '|' || c == '&' || c == ')' || c == '}' ||
        c == ',' || c == '>' || c == '<' ||
        c == '#') return false;
    if ((c == '(' || c == '{') && !value) return false;
    lexer->mark_end(lexer);
    if (c == '-') {
        if (!quoted && !value) return false;
        lexer->advance(lexer, false);
        if (!digit(lexer->lookahead) && lexer->lookahead != '.' && lexer->lookahead != '[')
            return false;
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

static void push_function_context(Scanner *scanner, bool workflow)
{
    unsigned depth = scanner->function_depth;
    if (depth < 64) {
        unsigned long long bit = 1ULL << depth;
        scanner->workflow_bits = workflow ? (scanner->workflow_bits | bit)
                                          : (scanner->workflow_bits & ~bit);
    }
    if (depth < 255) scanner->function_depth++;
}

static bool in_workflow(const Scanner *scanner)
{
    unsigned depth = scanner->function_depth;
    if (!depth) return false;
    if (depth > 64) depth = 64;
    return (scanner->workflow_bits >> (depth - 1)) & 1;
}

static bool word_char_ci(TSLexer *lexer, const char *word)
{
    for (; *word; word++) {
        int32_t c = lexer->lookahead;
        if (c != *word && c != *word - 'a' + 'A') return false;
        lexer->advance(lexer, false);
    }
    return true;
}

// The word `inlinescript` ending at a Native token delimiter. The grammar then
// requires the script block, so a bare or parameter-first keyword is an error
// instead of an ordinary command. The caller has skipped the whitespace before
// the word; the token is the word.
static bool scan_inlinescript_name(TSLexer *lexer)
{
    if (!word_char_ci(lexer, "inlinescript")) return false;
    int32_t c = lexer->lookahead;
    if (c != 0 && !command_array_space(c) && c != '{' && c != '}' && c != '(' &&
        c != ')' && c != ';' && c != ',' && c != '|' && c != '&')
        return false;
    lexer->mark_end(lexer);
    lexer->result_symbol = INLINESCRIPT_NAME;
    return true;
}

// Native reads `:name` as a loop label only when a loop or switch keyword
// follows, after any whitespace, newlines and comments. Otherwise it is an
// ordinary command word. The caller has skipped to the colon; the token is the
// colon and the name.
static bool scan_label(TSLexer *lexer)
{
    lexer->advance(lexer, false);
    int32_t c = lexer->lookahead;
    if (!((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_')) return false;
    do {
        lexer->advance(lexer, false);
        c = lexer->lookahead;
    } while ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
    lexer->mark_end(lexer);

    for (;;) {
        c = lexer->lookahead;
        if (command_array_space(c)) {
            lexer->advance(lexer, false);
        } else if (c == '#') {
            while (lexer->lookahead != 0 && !line_end(lexer->lookahead)) lexer->advance(lexer, false);
        } else if (c == '<') {
            lexer->advance(lexer, false);
            if (lexer->lookahead != '#') return false;
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
        } else {
            break;
        }
    }

    char word[8];
    unsigned length = 0;
    while (length < sizeof(word) && lexer->lookahead < 0x80 && iswalpha(lexer->lookahead)) {
        word[length++] = (char)towlower(lexer->lookahead);
        lexer->advance(lexer, false);
    }
    if (length == sizeof(word) || !command_word_end(lexer->lookahead)) return false;
    static const char *const keywords[] = {"for", "foreach", "while", "do", "switch"};
    for (unsigned i = 0; i < sizeof(keywords) / sizeof(keywords[0]); i++) {
        const char *keyword = keywords[i];
        unsigned k = 0;
        while (k < length && keyword[k] == word[k]) k++;
        if (k == length && keyword[k] == 0) {
            lexer->result_symbol = LABEL;
            return true;
        }
    }
    return false;
}

// Zero-width, directly before a colon word that follows `break` or `continue`
// on the same line.
static bool scan_flow_control_colon_word(TSLexer *lexer)
{
    while (!line_end(lexer->lookahead) && command_array_space(lexer->lookahead)) skip(lexer);
    if (lexer->lookahead != ':') return false;
    lexer->mark_end(lexer);
    lexer->advance(lexer, false);
    if (lexer->lookahead == ':') return false;
    lexer->result_symbol = FLOW_CONTROL_COLON_WORD;
    return true;
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
static bool scan_command_name_escape(TSLexer *lexer, const bool *valid_symbols, bool quote_units)
{
    bool start = valid_symbols[COMMAND_NAME_START_ESCAPE];
    if ((!start && !valid_symbols[COMMAND_NAME_ESCAPE]) || valid_symbols[ERROR_SENTINEL] ||
        lexer->lookahead != '`') return false;
    lexer->advance(lexer, false);
    if (lexer->eof(lexer)) return false;
    if (start && command_name_space(lexer->lookahead)) return false;
    // A backtick-escaped quote opens a string in a string subexpression.
    if (start && quote_units && valid_symbols[QUOTE_UNIT_OPEN] &&
        double_quote(lexer->lookahead)) {
        lexer->advance(lexer, false);
        lexer->mark_end(lexer);
        lexer->result_symbol = QUOTE_UNIT_OPEN;
        return true;
    }
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
    bool variable = valid_symbols[VARIABLE_COMMAND_NAME_CONTINUATION];
    if ((!variable && !valid_symbols[PATH_COMMAND_NAME_CONTINUATION]) ||
        valid_symbols[ERROR_SENTINEL]) return false;
    int32_t c = lexer->lookahead;
    // In invocation position a dot after the initial variable belongs to
    // expression syntax, not to a literal command path.
    if (variable && c == '.') return false;
    lexer->mark_end(lexer);
    if (variable && c == '?') {
        lexer->advance(lexer, false);
        if (lexer->lookahead == '[') return false;
    }
    if ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'z') ||
        (c >= 'A' && c <= 'Z') || c == '_' || c == '?' || c == '-' ||
        c == '.' || c == '\\' || c == '/' || c == '$' || c == '@' ||
        c == '`' || is_quote(c)) {
        lexer->result_symbol = variable ? VARIABLE_COMMAND_NAME_CONTINUATION :
                                         PATH_COMMAND_NAME_CONTINUATION;
        return true;
    }
    return false;
}

static bool type_name_letter(int32_t c)
{
    return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_';
}

static bool scan_invocation_argument_boundary(TSLexer *lexer, const bool *valid_symbols)
{
    if (!valid_symbols[INVOCATION_ARGUMENT_BOUNDARY] || valid_symbols[ERROR_SENTINEL])
        return false;
    int32_t c = lexer->lookahead;
    lexer->mark_end(lexer);
    if (c == '.') {
        lexer->advance(lexer, false);
        c = lexer->lookahead;
        // A dot without a member starts a separate argument in command mode.
        if (c != '.' && c != '#' &&
            (!command_word_end(c) || c == '(' || c == '{')) return false;
    } else if (c != '/' && c != '\\') {
        return false;
    }
    lexer->result_symbol = INVOCATION_ARGUMENT_BOUNDARY;
    return true;
}

// `<tag>`: the command name `<` is directly followed by its first argument.
static bool scan_angle_argument_boundary(TSLexer *lexer)
{
    int32_t c = lexer->lookahead;
    if (command_word_end(c) || c == '<' || c == '>' || c == '`') return false;
    lexer->mark_end(lexer);
    lexer->result_symbol = ANGLE_ARGUMENT_BOUNDARY;
    return true;
}

static bool scan_trailing_dot_type_name(TSLexer *lexer)
{
    while (command_array_space(lexer->lookahead)) skip(lexer);
    if (!type_name_letter(lexer->lookahead)) return false;

    unsigned dots = 0;
    for (;;) {
        int32_t c = lexer->lookahead;
        if (c == '.') {
            dots++;
        } else if (type_name_letter(c) || (c >= '0' && c <= '9') || c == '`') {
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

// Inside a command name, `$(` takes everything up to its matching parenthesis
// as literal text, like Native: quotes and comments do not hide parentheses.
// `${` likewise ends at the first unescaped `}`.
static bool scan_command_name_subexpression(TSLexer *lexer)
{
    if (lexer->lookahead == '{') {
        lexer->advance(lexer, false);
        while (!lexer->eof(lexer) && lexer->lookahead != '}') {
            bool escape = lexer->lookahead == '`';
            lexer->advance(lexer, false);
            if (escape && !lexer->eof(lexer)) lexer->advance(lexer, false);
        }
        if (lexer->eof(lexer)) return false;
        lexer->advance(lexer, false);
    } else {
        unsigned depth = 0;
        do {
            if (lexer->eof(lexer)) return false;
            if (lexer->lookahead == '(') depth++;
            else if (lexer->lookahead == ')') depth--;
            lexer->advance(lexer, false);
        } while (depth);
    }
    lexer->mark_end(lexer);
    lexer->result_symbol = COMMAND_NAME_SUBEXPRESSION;
    return true;
}

// The first unit of a quote run in a string: one quote, a doubled pair, or a
// backtick-escaped quote. A second adjacent unit is an escaped quote.
static bool scan_quote_unit_content(TSLexer *lexer)
{
    if (lexer->lookahead == '`') {
        lexer->advance(lexer, false);
        if (lexer->lookahead == '`') {
            // Native escapes a quote after an even run of backticks, too.
            unsigned ticks = 1;
            while (lexer->lookahead == '`') {
                lexer->advance(lexer, false);
                ticks++;
            }
            if (ticks % 2 || !double_quote(lexer->lookahead)) return false;
            lexer->advance(lexer, false);
            lexer->mark_end(lexer);
            lexer->result_symbol = QUOTE_UNIT_ESCAPE;
            return true;
        }
        if (!double_quote(lexer->lookahead)) return false;
        lexer->advance(lexer, false);
    } else if (double_quote(lexer->lookahead)) {
        lexer->advance(lexer, false);
        if (double_quote(lexer->lookahead)) lexer->advance(lexer, false);
    } else {
        return false;
    }
    lexer->mark_end(lexer);
    lexer->result_symbol = QUOTE_UNIT_CLOSE;
    if (lexer->lookahead == '`') {
        lexer->advance(lexer, false);
        if (!double_quote(lexer->lookahead)) return true;
        lexer->advance(lexer, false);
    } else if (double_quote(lexer->lookahead)) {
        lexer->advance(lexer, false);
        if (double_quote(lexer->lookahead)) lexer->advance(lexer, false);
    } else {
        return true;
    }
    lexer->mark_end(lexer);
    lexer->result_symbol = QUOTE_UNIT_ESCAPE;
    return true;
}

// The opening unit: one quote, a doubled pair or a backtick-escaped quote.
// The caller has not consumed anything.
static bool scan_quote_unit_open(TSLexer *lexer)
{
    if (lexer->lookahead == '`') {
        lexer->advance(lexer, false);
        if (!double_quote(lexer->lookahead)) return false;
        lexer->advance(lexer, false);
    } else {
        if (!double_quote(lexer->lookahead)) return false;
        lexer->advance(lexer, false);
        if (double_quote(lexer->lookahead)) lexer->advance(lexer, false);
    }
    lexer->mark_end(lexer);
    lexer->result_symbol = QUOTE_UNIT_OPEN;
    return true;
}

// The order of the checks below matters: a scanner that has advanced the
// lexer cannot hand over to another one. The order is: string-subexpression
// end and quote units, the leading BOM, the boundary, escape and continuation
// tokens, argument boundaries, qualified variables, command words, spaces
// before a comma, bare dashes and last the zero-width statement terminator.
// During error recovery every external token is valid (ERROR_SENTINEL too),
// so most checks are skipped while `recovering`.
bool tree_sitter_powershell_external_scanner_scan(void *payload, TSLexer *lexer, const bool *valid_symbols)
{
    Scanner *scanner = payload;
    const bool recovering = valid_symbols[ERROR_SENTINEL];
    if (!recovering) {
        // Empty tokens: only one of them is valid in any parser state.
        if (valid_symbols[FUNCTION_CONTEXT_PLAIN] || valid_symbols[FUNCTION_CONTEXT_WORKFLOW]) {
            push_function_context(scanner, valid_symbols[FUNCTION_CONTEXT_WORKFLOW]);
            lexer->result_symbol = valid_symbols[FUNCTION_CONTEXT_WORKFLOW]
                ? FUNCTION_CONTEXT_WORKFLOW : FUNCTION_CONTEXT_PLAIN;
            return true;
        }
        if (valid_symbols[FUNCTION_CONTEXT_END]) {
            if (scanner->function_depth) scanner->function_depth--;
            lexer->result_symbol = FUNCTION_CONTEXT_END;
            return true;
        }
        if (valid_symbols[STRING_SUBEXPRESSION_END]) {
            if (scanner->string_subexpression_depth) scanner->string_subexpression_depth--;
            lexer->result_symbol = STRING_SUBEXPRESSION_END;
            return true;
        }
        if (valid_symbols[QUOTE_UNIT_CLOSE] &&
            (lexer->lookahead == '`' || double_quote(lexer->lookahead)))
            return scan_quote_unit_content(lexer);
    }
    // Native PowerShell drops one UTF-8 BOM that starts a file; any other U+FEFF
    // (and U+2060, U+200B) is an ordinary character. The grammar only accepts
    // this token before the first statement, so a BOM at column 0 there is the
    // file's BOM.
    if (valid_symbols[LEADING_BOM] && !recovering &&
        lexer->lookahead == 0xfeff && lexer->get_column(lexer) == 0) {
        lexer->advance(lexer, false);
        lexer->mark_end(lexer);
        lexer->result_symbol = LEADING_BOM;
        return true;
    }
    if (valid_symbols[COMMAND_NAME_SUBEXPRESSION] && !recovering &&
        (lexer->lookahead == '(' || lexer->lookahead == '{'))
        return scan_command_name_subexpression(lexer);
    // A dot ends a parameter name and starts a command word, not a member.
    if (!recovering &&
        (valid_symbols[PARAMETER_DOT_BOUNDARY] ||
         valid_symbols[PARAMETER_DOT_LITERAL_BOUNDARY]) && lexer->lookahead == '.') {
        lexer->mark_end(lexer);
        lexer->advance(lexer, false);
        bool literal = lexer->lookahead == '$' || lexer->lookahead == '"' ||
                       lexer->lookahead == '\'';
        lexer->result_symbol = literal ? PARAMETER_DOT_LITERAL_BOUNDARY : PARAMETER_DOT_BOUNDARY;
        return valid_symbols[lexer->result_symbol];
    }
    if (valid_symbols[ANGLE_ARGUMENT_BOUNDARY] && !recovering &&
        scan_angle_argument_boundary(lexer))
        return true;
    if (valid_symbols[COMMAND_ARRAY_ITEM_START] && !recovering)
        return scan_command_array_item_start(lexer, valid_symbols);
    if (valid_symbols[COMMAND_NAME_START_ESCAPE] && !recovering) {
        while (command_name_space(lexer->lookahead)) {
            if (valid_symbols[STATEMENT_TERMINATOR] &&
                (lexer->lookahead == '\r' || lexer->lookahead == '\n')) break;
            skip(lexer);
        }
    }
    // A failed match has consumed characters, so no other token is tried.
    if (valid_symbols[INLINESCRIPT_NAME] && !recovering && in_workflow(scanner) &&
        (lexer->lookahead == 'i' || lexer->lookahead == 'I'))
        return scan_inlinescript_name(lexer);
    if ((valid_symbols[COMMAND_NAME_ESCAPE] || valid_symbols[COMMAND_NAME_START_ESCAPE]) &&
        !recovering && lexer->lookahead == '`')
        return scan_command_name_escape(lexer, valid_symbols,
                                         scanner->string_subexpression_depth == 1);
    bool numeric_name = valid_symbols[NUMERIC_COMMAND_NAME];
    // Argument words (including attached quotes) belong to scan_command_word.
    bool numeric_literal = valid_symbols[TRAILING_DOT_REAL_LITERAL] &&
        !valid_symbols[COMMAND_WORD_START] && !valid_symbols[COMMAND_WORD_PART] &&
        !valid_symbols[COMMAND_WORD_EXPRESSION];
    if ((numeric_name || numeric_literal) && !recovering &&
        (digit(lexer->lookahead) || (numeric_name && lexer->lookahead == '.')))
        return scan_numeric_start(lexer, valid_symbols);
    if (valid_symbols[VARIABLE_COMMAND_NAME_CONTINUATION] && lexer->lookahead == '?')
        return scan_path_command_name_continuation(lexer, valid_symbols);
    if (scan_path_command_name_continuation(lexer, valid_symbols)) return true;
    if (valid_symbols[INVOCATION_ARGUMENT_BOUNDARY] && lexer->lookahead == '.')
        return scan_invocation_argument_boundary(lexer, valid_symbols);
    if (scan_invocation_argument_boundary(lexer, valid_symbols)) return true;
    if (!recovering) {
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
         lexer->lookahead == '`' ||
         (lexer->lookahead == '.' && (valid_symbols[COMPLETED_MEMBER_BOUNDARY] ||
                                      valid_symbols[QUOTED_ARGUMENT_BOUNDARY])) ||
         (lexer->lookahead >= '0' && lexer->lookahead <= '9')))
        return scan_argument_boundary(lexer, valid_symbols);
    if (scan_argument_boundary(lexer, valid_symbols)) return true;

    bool word = valid_symbols[COMMAND_WORD_START] || valid_symbols[COMMAND_WORD_PART] ||
                valid_symbols[COMMAND_WORD_EXPRESSION] ||
                valid_symbols[VARIABLE_BEFORE_LITERAL_DOT];
    if ((valid_symbols[QUALIFIED_VARIABLE] || valid_symbols[QUALIFIED_VARIABLE_IN_STRING] ||
         valid_symbols[COMMAND_NAME_DOLLAR]) &&
        !recovering &&
        (valid_symbols[QUALIFIED_VARIABLE_IN_STRING] || !word)) {
        while (!valid_symbols[QUALIFIED_VARIABLE_IN_STRING] &&
               command_array_space(lexer->lookahead)) {
            if (valid_symbols[STATEMENT_TERMINATOR] &&
                (lexer->lookahead == '\r' || lexer->lookahead == '\n')) break;
            skip(lexer);
        }
        if (valid_symbols[QUOTE_UNIT_OPEN] && scanner->string_subexpression_depth == 1 &&
            (double_quote(lexer->lookahead) || lexer->lookahead == '`'))
            return scan_quote_unit_open(lexer);
        if (lexer->lookahead == '$' || lexer->lookahead == '@')
            return scan_qualified_variable(scanner, lexer, valid_symbols);
    }

    if (word && valid_symbols[QUOTE_UNIT_OPEN] && !recovering &&
        scanner->string_subexpression_depth == 1 && double_quote(lexer->lookahead))
        return scan_quote_unit_open(lexer);

    // Word pieces never skip whitespace. A failed lookahead may have advanced
    // the lexer, so do not try the other scanners afterwards.
    if (word &&
        !command_word_end(lexer->lookahead))
        return scan_command_word(lexer, valid_symbols, scanner->string_subexpression_depth == 1);

    // The string follows a word piece, for example `f a"b c"`.
    if (valid_symbols[QUOTE_UNIT_OPEN] && !recovering && !word &&
        scanner->string_subexpression_depth == 1 &&
        (double_quote(lexer->lookahead) || lexer->lookahead == '`'))
        return scan_quote_unit_open(lexer);

    bool skipped_backtick = false;
    bool stray_backtick = false;
    if (!recovering && valid_symbols[LABEL]) {
        while (command_array_space(lexer->lookahead)) skip(lexer);
        if (lexer->lookahead == ':') return scan_label(lexer);
    }
    if (!recovering && valid_symbols[FLOW_CONTROL_COLON_WORD] &&
        scan_flow_control_colon_word(lexer))
        return true;
    if (scan_spaces_before_comma(payload, lexer, valid_symbols, &skipped_backtick, &stray_backtick))
        return true;
    // Skipped characters cannot be restored, and the other external tokens
    // cannot follow a backtick anyway.
    if (skipped_backtick) {
        if (stray_backtick || !valid_symbols[STATEMENT_TERMINATOR] ||
            !statement_terminator_follows(lexer, valid_symbols)) return false;
        lexer->result_symbol = STATEMENT_TERMINATOR;
        return true;
    }

    // The statement terminator consumes nothing, so it must be tried last: when
    // both are valid, a `--` has to win over the empty terminator.
    if (scan_bare_dashes(payload, lexer, valid_symbols)) return true;
    return scan_statement_terminator(payload, lexer, valid_symbols);
}

void *tree_sitter_powershell_external_scanner_create()
{
    return calloc(1, sizeof(Scanner));
}

void tree_sitter_powershell_external_scanner_destroy(void *p)
{
    free(p);
}

unsigned tree_sitter_powershell_external_scanner_serialize(void *payload, char *buffer)
{
    Scanner *scanner = payload;
    // Empty when idle: a non-empty state changes error recovery on invalid input.
    if (!scanner->string_subexpression_depth && !scanner->function_depth) return 0;
    buffer[0] = (char)scanner->string_subexpression_depth;
    buffer[1] = (char)scanner->function_depth;
    for (unsigned i = 0; i < 8; i++)
        buffer[2 + i] = (char)(scanner->workflow_bits >> (8 * i));
    return 10;
}

void tree_sitter_powershell_external_scanner_deserialize(void *payload, const char *buffer, unsigned length)
{
    Scanner *scanner = payload;
    scanner->string_subexpression_depth = 0;
    scanner->function_depth = 0;
    scanner->workflow_bits = 0;
    if (length < 10) return;
    scanner->string_subexpression_depth = (unsigned char)buffer[0];
    scanner->function_depth = (unsigned char)buffer[1];
    for (unsigned i = 0; i < 8; i++)
        scanner->workflow_bits |= (unsigned long long)(unsigned char)buffer[2 + i] << (8 * i);
}
