#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <tree_sitter/api.h>

extern const TSLanguage *tree_sitter_powershell(void);

static int parse_file(TSParser *parser, const char *path, int index) {
  FILE *file = fopen(path, "rb");
  if (!file) {
    fprintf(stderr, "%s: %s\n", path, strerror(errno));
    return 2;
  }
  if (fseek(file, 0, SEEK_END) != 0) {
    perror(path);
    fclose(file);
    return 2;
  }
  long length = ftell(file);
  if (length < 0 || (unsigned long)length > UINT32_MAX) {
    fprintf(stderr, "%s: unsupported file length\n", path);
    fclose(file);
    return 2;
  }
  rewind(file);
  char *source = malloc((size_t)length + 1);
  if (!source) {
    fprintf(stderr, "%s: allocation failed\n", path);
    fclose(file);
    return 2;
  }
  if (fread(source, 1, (size_t)length, file) != (size_t)length) {
    fprintf(stderr, "%s: read failed\n", path);
    free(source);
    fclose(file);
    return 2;
  }
  fclose(file);
  ts_parser_reset(parser);
  struct timespec start, finish;
  clock_gettime(CLOCK_MONOTONIC, &start);
  TSTree *tree = ts_parser_parse_string(parser, NULL, source, (uint32_t)length);
  clock_gettime(CLOCK_MONOTONIC, &finish);
  double elapsed_ms = (finish.tv_sec - start.tv_sec) * 1000.0 +
                      (finish.tv_nsec - start.tv_nsec) / 1000000.0;
  free(source);
  printf("{\"index\":%d,\"elapsed_ms\":%.3f,", index, elapsed_ms);
  if (!tree) {
    printf("\"status\":\"timeout\"}\n");
    fflush(stdout);
    return 0;
  }

  TSNode root = ts_tree_root_node(tree);
  unsigned errors = 0, missing = 0, samples = 0;
  printf("\"status\":\"%s\",\"end_byte\":%u,\"samples\":[",
         ts_node_has_error(root) ? "grammar_error" : "ok",
         ts_node_end_byte(root));
  TSTreeCursor cursor = ts_tree_cursor_new(root);
  for (;;) {
    TSNode node = ts_tree_cursor_current_node(&cursor);
    int error = ts_node_is_error(node);
    int absent = ts_node_is_missing(node);
    errors += error;
    missing += absent;
    if ((error || absent) && samples < 5) {
      TSPoint point = ts_node_start_point(node);
      printf("%s{\"kind\":\"%s\",\"line\":%u,\"column\":%u,"
             "\"start_byte\":%u,\"end_byte\":%u}",
             samples ? "," : "", absent ? "missing" : "error",
             point.row + 1, point.column, ts_node_start_byte(node),
             ts_node_end_byte(node));
      samples++;
    }
    if (ts_tree_cursor_goto_first_child(&cursor)) continue;
    while (!ts_tree_cursor_goto_next_sibling(&cursor)) {
      if (!ts_tree_cursor_goto_parent(&cursor)) goto done;
    }
  }
done:
  printf("],\"errors\":%u,\"missing\":%u}\n", errors, missing);
  fflush(stdout);
  ts_tree_cursor_delete(&cursor);
  ts_tree_delete(tree);
  return 0;
}

int main(int argc, char **argv) {
  if (argc < 2) {
    fprintf(stderr, "usage: %s SOURCE...\n", argv[0]);
    return 2;
  }
  TSParser *parser = ts_parser_new();
  if (!ts_parser_set_language(parser, tree_sitter_powershell())) {
    fprintf(stderr, "incompatible Tree-sitter runtime\n");
    ts_parser_delete(parser);
    return 2;
  }
  ts_parser_set_timeout_micros(parser, 1000000);
  int result = 0;
  for (int i = 1; i < argc; i++) {
    result = parse_file(parser, argv[i], i - 1);
    if (result) break;
  }
  ts_parser_delete(parser);
  return result;
}
