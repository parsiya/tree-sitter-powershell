/* A backtick line continuation may end a statement at the end of the input,
 * before `}`, `)` or `;`, and an empty line after it ends the statement. The
 * source bytes are escaped so that the exact line endings are tested, which
 * a corpus test cannot do for a trailing newline.
 *
 * From the repository root, using a tree-sitter runtime compatible with src/:
 * cc -std=c11 -I src $(pkg-config --cflags tree-sitter) \
 *   test/continuation_statement_end.c src/parser.c src/scanner.c \
 *   $(pkg-config --libs tree-sitter) -o continuation-statement-end
 * ./continuation-statement-end
 */
#include <assert.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <tree_sitter/api.h>

extern const TSLanguage *tree_sitter_powershell(void);

typedef struct {
    const char *source;
    bool valid;
    unsigned statements; /* top-level statements when valid, else 0 */
} Case;

static const Case cases[] = {
    {"Get-Date -a `\n", true, 1},
    {"Get-Date -a `\r\n", true, 1},
    {"Get-Date -a `\r", true, 1},
    {"Get-Date -a `\n\n  \n", true, 1},
    {"Get-Date -a `\n   ", true, 1},
    {"Get-Date -a ` ", true, 1},
    {"Get-Date `\n", true, 1},
    {"Get-Date 'a' `\n", true, 1},
    {"Get-Date $a `\n", true, 1},
    {"Get-X | Get-Y -a `\n", true, 1},
    {"Get-X -a `\n `\n", true, 1},
    {"Get-X -a `\n\nGet-Y", true, 2},
    {"Get-X -a `\r\n\r\nGet-Y\r\n", true, 2},
    {"Get-X -a `\n; Get-Y", true, 2},
    {"Get-X -a `\nGet-Y `\n", true, 1},
    {"Get-X -a `\n| Get-Y", true, 1},
    {"if (1) {\n  Get-X -a `\n}", true, 1},
    {"if (1) {\r\n  Get-X -a `\r\n}\r\n", true, 1},
    {"if (1) {\n  Get-X -a `\n\n    \n}", true, 1},
    {"(Get-X -a `\n)", true, 1},
    {"{ ($a) `\n }", true, 1},
    {"{ ($a) `\r\n }", true, 1},
    {"{ 1 `\n}", true, 1},
    {"{ $a.b() `\n}", true, 1},
    {"$a = 1 `\n", true, 1},
    {"$a = 1 `\r\n", true, 1},
    {"{ $a = Get-X -a `\n}", true, 1},
    {"while ($a) {\n  $a = 1 `\n}", true, 1},
    {"function f { return $a `\n}", true, 1},
    {"@{ a = 1 `\n}", true, 1},
    {"$a `\n;1", true, 2},
    /* A backtick that is not followed by whitespace is not a continuation. */
    {"Get-X -a `q", true, 1},
    {"Get-Date -a `", false, 0},
    {"$a `", false, 0},
    {"$a = 1 `", false, 0},
    {"Get-X 1, `\n", false, 0},
    {"$a = `\n", false, 0},
    {"$a `\n$b", false, 0},
};

/* The Opengrep parser wraps each statement in a `statement` node. */
static unsigned count_statements(TSNode root)
{
    TSNode list = ts_node_named_child(root, 0);
    if (ts_node_is_null(list)) return 0;
    unsigned count = 0;
    for (uint32_t i = 0; i < ts_node_named_child_count(list); i++) {
        TSNode node = ts_node_named_child(list, i);
        if (strcmp(ts_node_type(node), "statement") == 0) node = ts_node_named_child(node, 0);
        const char *type = ts_node_type(node);
        if (strcmp(type, "comment") != 0 && strcmp(type, "empty_statement") != 0 &&
            strcmp(type, "statement_terminator") != 0) count++;
    }
    return count;
}

int main(void)
{
    TSParser *parser = ts_parser_new();
    assert(ts_parser_set_language(parser, tree_sitter_powershell()));
    for (unsigned i = 0; i < sizeof cases / sizeof cases[0]; i++) {
        const Case *c = &cases[i];
        TSTree *tree = ts_parser_parse_string(parser, NULL, c->source, (uint32_t)strlen(c->source));
        assert(tree);
        TSNode root = ts_tree_root_node(tree);
        if (ts_node_has_error(root) == c->valid) {
            fprintf(stderr, "unexpected result for case %u: %s\n", i, c->source);
            return 1;
        }
        if (c->valid && count_statements(root) != c->statements) {
            fprintf(stderr, "wrong statement count for case %u: %s\n", i, c->source);
            return 1;
        }
        ts_tree_delete(tree);
    }
    ts_parser_delete(parser);
    puts("Continuations end statements at the end of the input, before closers and before empty lines");
    return 0;
}
