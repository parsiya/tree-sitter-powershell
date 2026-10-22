/* Keep CR source bytes escaped: text-file newline normalization must not turn
 * these controls into LF/CRLF tests.
 *
 * From the repository root, using a tree-sitter runtime compatible with src/:
 * cc -std=c11 -I src $(pkg-config --cflags tree-sitter) \
 *   test/cr_statement_boundaries.c src/parser.c src/scanner.c \
 *   $(pkg-config --libs tree-sitter) -o cr-statement-boundaries
 * ./cr-statement-boundaries
 */
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <tree_sitter/api.h>

extern const TSLanguage *tree_sitter_powershell(void);

typedef struct {
    const char *source;
    const char *commands[5];
    unsigned assignments;
} Case;

static void check_node(TSNode node, const Case *c, unsigned *commands,
                       unsigned *assignments)
{
    assert(!ts_node_has_error(node));
    assert(!ts_node_is_error(node));
    assert(!ts_node_is_missing(node));
    const char *type = ts_node_type(node);
    if (strcmp(type, "assignment_expression") == 0) (*assignments)++;
    if (strcmp(type, "command") == 0) {
        const char *expected = c->commands[(*commands)++];
        assert(expected);
        uint32_t start = ts_node_start_byte(node);
        uint32_t end = ts_node_end_byte(node);
        assert(end - start == strlen(expected));
        assert(memcmp(c->source + start, expected, end - start) == 0);
        TSPoint point = ts_node_start_point(node);
        unsigned row = 0, column = 0;
        for (uint32_t i = 0; i < start; i++) {
            if (c->source[i] == '\n') { row++; column = 0; }
            else column++;
        }
        assert(point.row == row && point.column == column);
    }
    for (uint32_t i = 0; i < ts_node_child_count(node); i++)
        check_node(ts_node_child(node, i), c, commands, assignments);
}

#define LINES(nl) \
    {"Write-Output first" nl "Write-Output second" nl, \
     {"Write-Output first", "Write-Output second"}, 0}, \
    {"if ($true) {" nl "Write-Output first" nl "Write-Output second" nl "}" nl, \
     {"Write-Output first", "Write-Output second"}, 0}, \
    {"$x = Write-Output first" nl "$y = Write-Output second" nl, \
     {"Write-Output first", "Write-Output second"}, 2}, \
    {"$x = @(Write-Output first" nl "Write-Output second)" nl, \
     {"Write-Output first", "Write-Output second"}, 1}, \
    {"Write-Output $(Write-Output first" nl "Write-Output second)" nl, \
     {"Write-Output $(Write-Output first" nl "Write-Output second)", \
      "Write-Output first", "Write-Output second"}, 0}, \
    {"Write-Output -Name value" nl "Write-Output -Other second" nl, \
     {"Write-Output -Name value", "Write-Output -Other second"}, 0}, \
    {"Write-Output -Name" nl "Write-Output second" nl, \
     {"Write-Output -Name", "Write-Output second"}, 0}, \
    {"Write-Output $first" nl "Write-Output $second" nl, \
     {"Write-Output $first", "Write-Output $second"}, 0}, \
    {"Write-Output \"first\"" nl "Write-Output 'second'" nl, \
     {"Write-Output \"first\"", "Write-Output 'second'"}, 0}, \
    {"Write-Output 'first\rsecond'" nl "Write-Output \"third\rfourth\"" nl, \
     {"Write-Output 'first\rsecond'", "Write-Output \"third\rfourth\""}, 0}, \
    {"# first" nl "Write-Output second" nl "# third" nl "Write-Output last" nl, \
     {"Write-Output second", "Write-Output last"}, 0}, \
    {"Write-Output first" nl "# second" nl "Write-Output last" nl, \
     {"Write-Output first", "Write-Output last"}, 0}, \
    {"for ($i = 0" nl "$i -lt 1" nl "$i++) { Write-Output first" nl \
     "Write-Output second }" nl "Write-Output last" nl, \
     {"Write-Output first", "Write-Output second", "Write-Output last"}, 1}

int main(void)
{
    const Case cases[] = {LINES("\n"), LINES("\r\n"), LINES("\r")};
    TSParser *parser = ts_parser_new();
    assert(ts_parser_set_language(parser, tree_sitter_powershell()));
    for (unsigned i = 0; i < sizeof(cases) / sizeof(cases[0]); i++) {
        const Case *c = &cases[i];
        TSTree *tree = ts_parser_parse_string(parser, NULL, c->source,
                                             (uint32_t)strlen(c->source));
        assert(tree);
        unsigned commands = 0, assignments = 0;
        check_node(ts_tree_root_node(tree), c, &commands, &assignments);
        assert(c->commands[commands] == NULL);
        assert(assignments == c->assignments);
        ts_tree_delete(tree);
    }
    ts_parser_delete(parser);
    puts("39 exact-byte statement/command boundary controls passed");
    return 0;
}
