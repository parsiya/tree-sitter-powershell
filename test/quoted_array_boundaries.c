#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <tree_sitter/api.h>

const TSLanguage *tree_sitter_powershell(void);

static TSNode find(TSNode node, const char *type, uint32_t start, uint32_t end) {
  if (!strcmp(ts_node_type(node), type) &&
      ts_node_start_byte(node) == start && ts_node_end_byte(node) == end)
    return node;
  for (uint32_t i = 0; i < ts_node_child_count(node); i++) {
    TSNode found = find(ts_node_child(node, i), type, start, end);
    if (!ts_node_is_null(found)) return found;
  }
  return (TSNode){0};
}

static uint32_t offset(const char *source, const char *text) {
  const char *p = strstr(source, text);
  assert(p);
  return (uint32_t)(p - source);
}

int main(void) {
  const char *source =
    "Show-Thing -Text 'prefix', \"Status $($entry.Name): ', \""
    "$($failure.Message) -Tone Blue, Gray";
  // PowerShell 7.6.7 Parser.ParseInput: apostrophe/comma are literal payload.
  const char *value = "Status $($entry.Name): ', ";
  uint32_t start = offset(source, "\"Status");
  uint32_t end = start + (uint32_t)strlen(value) + 2;
  uint32_t next = offset(source, "$($failure.Message)");
  TSParser *parser = ts_parser_new();
  assert(ts_parser_set_language(parser, tree_sitter_powershell()));
  TSTree *tree = ts_parser_parse_string(parser, NULL, source, (uint32_t)strlen(source));
  assert(tree);
  TSNode root = ts_tree_root_node(tree);
  assert(!ts_node_has_error(root));
  TSNode literal = find(root, "string_literal", start, end);
  assert(!ts_node_is_null(literal));
  TSNode quoted = ts_node_child(literal, 0);
  uint32_t count = ts_node_child_count(quoted);
  assert(count >= 3);
  TSNode left = ts_node_child(quoted, 0);
  TSNode right = ts_node_child(quoted, count - 1);
  assert(ts_node_start_byte(left) == start && ts_node_end_byte(left) == start + 1);
  assert(ts_node_start_byte(right) == end - 1 && ts_node_end_byte(right) == end);
  assert(source[start] == '"' && source[end - 1] == '"');
  assert(!memcmp(source + start + 1, value, strlen(value)));
  uint32_t covered = start + 1;
  for (uint32_t i = 1; i + 1 < count; i++) {
    TSNode part = ts_node_child(quoted, i);
    assert(ts_node_start_byte(part) == covered);
    covered = ts_node_end_byte(part);
  }
  assert(covered == end - 1 && next == end);
  uint32_t inner = offset(source, "$($entry.Name)");
  assert(!ts_node_is_null(find(quoted, "sub_expression", inner, inner + 14)));
  assert(ts_node_is_null(find(quoted, "sub_expression", next, next + 19)));
  assert(!ts_node_is_null(find(root, "sub_expression", next, next + 19)));
  TSNode array = find(root, "array_literal_expression", offset(source, "'prefix'"), end);
  // ABI14 simplification retains the aliased rule's original name.
  if (ts_node_is_null(array))
    array = find(root, "completed_argument_array", offset(source, "'prefix'"), end);
  assert(!ts_node_is_null(array));
  uint32_t prefix = offset(source, "'prefix'");
  assert(!ts_node_is_null(find(array, "string_literal", prefix, prefix + 8)));
  ts_tree_delete(tree);
  ts_parser_delete(parser);
  puts("Quoted array payload bytes and adjacent subexpression boundary preserved");
  return 0;
}
