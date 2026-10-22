/*
 * CR bytes are C escapes so Git's corpus text normalization cannot erase them.
 * Build with src/parser.c, src/scanner.c and a tree-sitter runtime:
 * cc -std=c11 -D_DEFAULT_SOURCE -I src -I "$RUNTIME/include" -I "$RUNTIME/src" \
 *   test/lone_cr_here_string_values.c src/parser.c src/scanner.c \
 *   "$RUNTIME/src/lib.c" -o lone-cr-here-string-values
 * --manifest emits sources/values for an independent Native ParseInput check.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tree_sitter/api.h>

extern const TSLanguage *tree_sitter_powershell(void);

typedef struct {
  const char *name;
  const char *literal;
  const char *value;
  unsigned variables;
  unsigned subexpressions;
} Case;

static const Case cases[] = {
  {"body-cr", "@\"\nalpha\rbeta\n\"@", "alpha\rbeta", 0, 0},
  {"body-lf", "@\"\nalpha\nbeta\n\"@", "alpha\nbeta", 0, 0},
  {"body-crlf", "@\"\nalpha\r\nbeta\n\"@", "alpha\r\nbeta", 0, 0},
  {"body-blank-cr", "@\"\nalpha\r\rbeta\n\"@", "alpha\r\rbeta", 0, 0},
  {"hash-cr", "@\"\nalpha\r# body\n\"@", "alpha\r# body", 0, 0},
  {"quote-cr", "@\"\nalpha\r\"quoted\"\n\"@", "alpha\r\"quoted\"", 0, 0},
  {"leading-cr", "@\"\n\ralpha\n\"@", "\ralpha", 0, 0},
  {"trailing-crlf", "@\"\nalpha\r\n\"@", "alpha", 0, 0},
  {"variables-cr", "@\"\n$before\r$after\n\"@", "$before\r$after", 2, 0},
  {"variables-lf", "@\"\n$before\n$after\n\"@", "$before\n$after", 2, 0},
  {"variables-crlf", "@\"\n$before\r\n$after\n\"@", "$before\r\n$after", 2, 0},
  {"subexpressions-cr", "@\"\n$(1)\r$(2)\n\"@", "$(1)\r$(2)", 0, 2},
  {"escaped-dollar-cr", "@\"\n`$before\r`$after\n\"@", "$before\r$after", 0, 0},
  {"escaped-cr", "@\"\nalpha`\rbeta\n\"@", "alpha\rbeta", 0, 0},
  {"escaped-lf", "@\"\nalpha`\nbeta\n\"@", "alpha\nbeta", 0, 0},
  {"escaped-crlf", "@\"\nalpha`\r\nbeta\n\"@", "alpha\r\nbeta", 0, 0},
  {"escaped-crlf-footer", "@\"\nalpha`\r\n\"@", "alpha\r", 0, 0},
  {"header-cr", "@\"\ralpha\n\"@", "alpha", 0, 0},
  {"footer-cr", "@\"\nalpha\r\"@", "alpha", 0, 0},
  {"both-cr", "@\"\ralpha\r\"@", "alpha", 0, 0},
  {"empty-cr", "@\"\r\"@", "", 0, 0},
  {"blank-cr", "@\"\r\r\"@", "", 0, 0},
  {"empty-lf", "@\"\n\"@", "", 0, 0},
  {"empty-crlf", "@\"\r\n\"@", "", 0, 0},
};

static unsigned count(TSNode n, const char *type) {
  unsigned total = !strcmp(ts_node_type(n), type);
  for (uint32_t i = 0; i < ts_node_child_count(n); i++)
    total += count(ts_node_child(n, i), type);
  return total;
}

static TSNode find(TSNode n, const char *type) {
  if (!strcmp(ts_node_type(n), type)) return n;
  for (uint32_t i = 0; i < ts_node_child_count(n); i++) {
    TSNode found = find(ts_node_child(n, i), type);
    if (!ts_node_is_null(found)) return found;
  }
  return (TSNode){0};
}

static void json(const char *s) {
  putchar('"');
  for (; *s; s++) {
    unsigned char c = (unsigned char)*s;
    if (c == '"' || c == '\\') printf("\\%c", c);
    else if (c < 32) printf("\\u%04x", c);
    else putchar(c);
  }
  putchar('"');
}

int main(int argc, char **argv) {
  bool manifest = argc == 2 && !strcmp(argv[1], "--manifest");
  TSParser *parser = ts_parser_new();
  if (!ts_parser_set_language(parser, tree_sitter_powershell())) return 2;
  if (manifest) putchar('[');
  for (unsigned i = 0; i < sizeof(cases) / sizeof(cases[0]); i++) {
    const Case *c = &cases[i];
    char source[512], decoded[512];
    snprintf(source, sizeof(source), "$value = %s\nWrite-Output sentinel\n", c->literal);
    if (manifest) {
      if (i) putchar(',');
      printf("{\"name\":"); json(c->name);
      printf(",\"source\":"); json(source);
      printf(",\"value\":"); json(c->value);
      putchar('}');
      continue;
    }
    TSTree *tree = ts_parser_parse_string(parser, NULL, source, (uint32_t)strlen(source));
    TSNode root = ts_tree_root_node(tree);
    TSNode literal = find(root, "expandable_here_string_literal");
    TSNode command = find(root, "command");
    bool ok = !ts_node_has_error(root) && !ts_node_is_null(literal) &&
      ts_node_start_byte(literal) == 9 && ts_node_end_byte(literal) == 9 + strlen(c->literal) &&
      count(root, "command") == 1 && !ts_node_is_null(command) &&
      ts_node_start_byte(command) == 10 + strlen(c->literal) &&
      ts_node_end_byte(command) == strlen(source) - 1 &&
      count(literal, "variable") == c->variables &&
      count(literal, "sub_expression") == c->subexpressions;
    const char *start = c->literal + 2;
    if (*start == '\r') start++;
    if (*start == '\n') start++;
    const char *end = c->literal + strlen(c->literal) - 2;
    if (end > start && end[-1] == '\n') {
      end--;
      if (end > start && end[-1] == '\r' && (end - start < 2 || end[-2] != '`')) end--;
    } else if (end > start && end[-1] == '\r') end--;
    char *out = decoded;
    while (start < end) {
      if (*start == '`') start++;
      *out++ = *start++;
    }
    *out = '\0';
    ok = ok && !strcmp(decoded, c->value);
    ts_tree_delete(tree);
    if (!ok) { fprintf(stderr, "FAILED: %s\n", c->name); return 1; }
  }
  ts_parser_delete(parser);
  if (manifest) puts("]");
  else puts("24 byte-preserved here-string values, interpolation counts and sentinel extents passed");
  return 0;
}
