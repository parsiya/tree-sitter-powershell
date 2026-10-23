#include <assert.h>
#define main ts_dump_main
#include "../ai-docs/tools/grammar-harness/ts-dump.c"
#undef main

static TSNode source_node(TSNode root, const char *source, const char *text) {
  const char *start = strstr(source, text);
  assert(start);
  uint32_t s = (uint32_t)(start - source), e = s + (uint32_t)strlen(text);
  TSNode node = ts_node_descendant_for_byte_range(root, s, e);
  assert(ts_node_start_byte(node) == s && ts_node_end_byte(node) == e);
  return node;
}

int main(void) {
  const char *source =
    "Write-Output Red, # line\n Blue, <# block #> Green -Quiet\n";
  TSParser *parser = ts_parser_new();
  assert(ts_parser_set_language(parser, tree_sitter_powershell()));
  TSTree *tree = ts_parser_parse_string(parser, NULL, source, (uint32_t)strlen(source));
  assert(tree);
  TSNode root = ts_tree_root_node(tree);
  assert(!ts_node_has_error(root));
  Elements el = {0};
  add_element(&el, source_node(root, source, "Red"), "generic_token");
  add_element(&el, source_node(root, source, ","), ",");
  add_element(&el, source_node(root, source, "# line"), "comment");
  assert(el.n == 1 && el.merge);
  add_element(&el, source_node(root, source, "Blue"), "generic_token");
  add_element(&el, source_node(root, source, ","), ",");
  add_element(&el, source_node(root, source, "<# block #>"), "comment");
  assert(el.n == 1 && el.merge);
  add_element(&el, source_node(root, source, "Green"), "generic_token");
  assert(el.n == 1 && !el.merge);
  assert(el.spans[0].s == (uint32_t)(strstr(source, "Red") - source));
  assert(el.spans[0].e == (uint32_t)(strstr(source, "Green") - source) + 5);
  add_element(&el, source_node(root, source, "-Quiet"), "command_parameter");
  add_element(&el, source_node(root, source, "# line"), "comment");
  assert(el.n == 2 && !el.merge);
  assert(!strcmp(el.spans[1].type, "command_parameter"));
  free(el.spans);
  ts_tree_delete(tree);
  ts_parser_delete(parser);
  puts("Line/block comments preserve comma merging and remain outside command elements");
  return 0;
}
