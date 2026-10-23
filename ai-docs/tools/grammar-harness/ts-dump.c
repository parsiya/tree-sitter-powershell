/* Parse files with a tree-sitter-powershell parser and print, per file, the
   errors plus the spans of commands, command elements and redirections.
   Comments are not command elements and do not interrupt comma merging. Paths
   are read NUL-separated from stdin. A UTF-8 BOM is skipped so offsets match
   the native dumper.

   Node names: TS_DUMP_NAMES=FILE (from abi14-names.mjs) reports a simplified
   ABI14 parser's tree with the unsimplified grammar's names. Nodes that grammar
   hides are replaced by their children, aliased nodes get the alias name. This
   only renames; spans and errors come from the parser unchanged. Without the
   variable, node types are reported as the parser names them.

   --tree (proof-kit.mjs): Opengrep's view instead of the harness's. Each file's
   bytes are parsed unchanged, a UTF-8 BOM included, as Opengrep's frontend
   passes them; "n" lists every reported node in document order as
   [type, start, end, parent, flags, field]: parent is the index of the nearest
   reported ancestor (-1 for the root), flags 1 named, 2 ERROR, 4 MISSING, and
   field the field name or null. */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <tree_sitter/api.h>

extern const TSLanguage *tree_sitter_powershell(void);

typedef struct { uint32_t s, e; const char *type; } Span;

/* ------------------------------------------------------------ node names */

#define NO_PARENT UINT32_MAX
static const char hidden[] = "";
typedef struct { uint32_t key; const char *type; } Context;
static uint32_t symbols;
static const char **defaults; /* per symbol: NULL = own name, hidden, or a name */
static Context *contexts;
static size_t context_count;

static int compare_contexts(const void *a, const void *b) {
  uint32_t x = ((const Context *)a)->key, y = ((const Context *)b)->key;
  return x < y ? -1 : x > y;
}

static int compare_names(const void *a, const void *b) {
  return strcmp(*(const char *const *)a, *(const char *const *)b);
}

static TSSymbol symbol_for(const TSLanguage *language, const char *name) {
  int named = name[0] != '"';
  if (!named) name++;
  return ts_language_symbol_for_name(language, name, (uint32_t)strlen(name), named);
}

static void load_names(const TSLanguage *language, const char *file) {
  FILE *in = fopen(file, "r");
  if (!in) { fprintf(stderr, "%s: cannot open\n", file); exit(2); }
  symbols = ts_language_symbol_count(language);
  defaults = calloc(symbols, sizeof(*defaults));
  size_t cap = 256, known_count = 0, known_cap = 256;
  contexts = malloc(cap * sizeof(*contexts));
  char **known = malloc(known_cap * sizeof(*known));
  char line[4096];
  while (fgets(line, sizeof(line), in)) {
    char *parent = strtok(line, "\t\n"), *child = strtok(NULL, "\t\n"),
         *result = strtok(NULL, "\t\n");
    if (!parent || !child || !result || (result[0] != '-' && result[0] != '=' && result[0] != '"')) {
      fprintf(stderr, "%s: malformed line\n", file);
      exit(2);
    }
    const char *type = result[0] == '-' ? hidden : strdup(result + 1);
    if (!strcmp(parent, "*")) {
      if (known_count == known_cap) known = realloc(known, (known_cap *= 2) * sizeof(*known));
      known[known_count++] = strdup(child);
    }
    /* Rules that the generator dropped as unreachable have no symbol. */
    TSSymbol c = symbol_for(language, child);
    TSSymbol p = strcmp(parent, "*") ? symbol_for(language, parent) : 0;
    if (!c || (strcmp(parent, "*") && !p)) continue;
    if (!strcmp(parent, "*")) {
      defaults[c] = type;
      continue;
    }
    if (context_count == cap) contexts = realloc(contexts, (cap *= 2) * sizeof(*contexts));
    contexts[context_count++] = (Context){(uint32_t)p * symbols + c, type};
  }
  fclose(in);
  qsort(contexts, context_count, sizeof(*contexts), compare_contexts);
  qsort(known, known_count, sizeof(*known), compare_names);
  /* A map from another grammar revision must not rename silently. */
  for (TSSymbol s = 1; s < symbols; s++) {
    const char *name = ts_language_symbol_name(language, s);
    if (ts_language_symbol_type(language, s) == TSSymbolTypeRegular &&
        !bsearch(&name, known, known_count, sizeof(*known), compare_names)) {
      fprintf(stderr, "%s: no entry for parser symbol %s\n", file, name);
      exit(2);
    }
  }
}

/* The reported type of NODE under a parent with symbol PARENT, or NULL when
   the node is hidden in the reported tree. */
static const char *view_type(uint32_t parent, TSNode node) {
  const char *type = ts_node_type(node);
  if (!defaults) return type;
  TSSymbol symbol = ts_node_symbol(node);
  if (symbol >= symbols) return type; /* ERROR */
  const char *mapped = defaults[symbol];
  if (parent < symbols) {
    Context key = {parent * symbols + symbol, NULL};
    Context *found = bsearch(&key, contexts, context_count, sizeof(*contexts), compare_contexts);
    if (found) mapped = found->type;
  }
  return mapped == hidden ? NULL : mapped ? mapped : type;
}

static uint32_t symbol_of(TSNode node) { return ts_node_symbol(node); }

/* Depth-first walk over the reported tree's nodes. The cursor visits hidden
   nodes too; each step records the parser symbol and reported type. */
typedef struct { uint32_t symbol; const char *type; } Frame;
typedef struct { TSTreeCursor cursor; Frame *frames; uint32_t depth, cap; } Walk;

static void walk_record(Walk *w) {
  TSNode n = ts_tree_cursor_current_node(&w->cursor);
  if (w->depth == w->cap) w->frames = realloc(w->frames, (w->cap *= 2) * sizeof(*w->frames));
  w->frames[w->depth] = (Frame){symbol_of(n),
    view_type(w->depth ? w->frames[w->depth - 1].symbol : NO_PARENT, n)};
}

static void walk_start(Walk *w, TSNode root) {
  w->cursor = ts_tree_cursor_new(root);
  w->cap = 64;
  w->depth = 0;
  w->frames = malloc(w->cap * sizeof(*w->frames));
  walk_record(w);
}

/* Move to the next node in document order; descend unless SKIP_CHILDREN. */
static int walk_next(Walk *w, int skip_children) {
  if (!skip_children && ts_tree_cursor_goto_first_child(&w->cursor)) {
    w->depth++;
    walk_record(w);
    return 1;
  }
  while (!ts_tree_cursor_goto_next_sibling(&w->cursor)) {
    if (!ts_tree_cursor_goto_parent(&w->cursor)) return 0;
    w->depth--;
  }
  walk_record(w);
  return 1;
}

static void walk_end(Walk *w) {
  ts_tree_cursor_delete(&w->cursor);
  free(w->frames);
}

/* The nearest reported ancestor of the current node, or "" at the root. */
static const char *walk_parent_type(const Walk *w) {
  for (uint32_t d = w->depth; d-- > 0;)
    if (w->frames[d].type) return w->frames[d].type;
  return "";
}

/* ------------------------------------------------------------ output */

static void print_type(const char *type) {
  putchar('"');
  for (const char *p = type; *p; p++) {
    if (*p == '"' || *p == '\\') putchar('\\');
    putchar(*p);
  }
  putchar('"');
}

/* First reported child of NODE (through hidden nodes) that contains an error. */
static int first_error_child(TSNode node, TSNode *found, const char **type) {
  uint32_t parent = symbol_of(node);
  for (uint32_t i = 0; i < ts_node_child_count(node); i++) {
    TSNode child = ts_node_child(node, i);
    if (!ts_node_has_error(child)) continue;
    const char *t = view_type(parent, child);
    if (t) { *found = child; *type = t; return 1; }
    if (first_error_child(child, found, type)) return 1;
  }
  return 0;
}

static void print_errors(TSNode root) {
  Walk w;
  walk_start(&w, root);
  int count = 0;
  printf("\"err\":[");
  for (int more = 1; more;) {
    TSNode n = ts_tree_cursor_current_node(&w.cursor);
    int error = ts_node_is_error(n), missing = ts_node_is_missing(n);
    if (w.frames[w.depth].type && (error || missing) && count < 20) {
      printf("%s{\"s\":%u,\"e\":%u,\"m\":%d,\"r\":%u,\"p\":", count ? "," : "",
             ts_node_start_byte(n), ts_node_end_byte(n), missing,
             ts_node_start_point(n).row + 1);
      print_type(walk_parent_type(&w));
      putchar('}');
      count++;
    }
    more = walk_next(&w, error);
  }
  if (count == 0 && ts_node_has_error(root)) {
    /* A missing hidden token is not reported by the walk; report the deepest
       reported node that contains it. */
    TSNode n = root;
    const char *type = view_type(NO_PARENT, root);
    while (first_error_child(n, &n, &type)) {}
    printf("{\"s\":%u,\"e\":%u,\"m\":1,\"h\":1,\"r\":%u,\"p\":",
           ts_node_start_byte(n), ts_node_end_byte(n), ts_node_start_point(n).row + 1);
    print_type(type);
    putchar('}');
  }
  putchar(']');
  walk_end(&w);
}

typedef struct { Span *spans; uint32_t n, cap; int merge, stop; } Elements;

static void add_element(Elements *el, TSNode child, const char *type) {
  if (!strcmp(type, "command_argument_sep") || !strcmp(type, "redirection") ||
      !strcmp(type, "comment")) return;
  if (!strcmp(type, ",")) { el->merge = 1; return; }
  if (!strcmp(type, "stop_parsing")) { el->stop = 1; return; }
  if (el->merge && el->n > 0) {
    el->spans[el->n - 1].e = ts_node_end_byte(child);
    el->merge = 0;
    return;
  }
  el->merge = 0;
  if (el->n == el->cap) el->spans = realloc(el->spans, (el->cap = el->cap * 2 + 8) * sizeof(Span));
  el->spans[el->n++] = (Span){ts_node_start_byte(child), ts_node_end_byte(child), type};
}

static void collect_elements(Elements *el, TSNode node) {
  uint32_t parent = symbol_of(node);
  for (uint32_t i = 0; i < ts_node_child_count(node); i++) {
    TSNode child = ts_node_child(node, i);
    const char *type = view_type(parent, child);
    if (type) add_element(el, child, type);
    else collect_elements(el, child);
  }
}

static void print_command(TSNode command, int *first) {
  TSNode elements = ts_node_child_by_field_name(command, "command_elements", 16);
  Elements el = {0};
  if (!ts_node_is_null(elements)) collect_elements(&el, elements);
  printf("%s{\"s\":%u,\"e\":%u,\"sp\":%d,\"el\":[", *first ? "" : ",",
         ts_node_start_byte(command), ts_node_end_byte(command), el.stop);
  for (uint32_t i = 0; i < el.n; i++) {
    printf("%s[%u,%u,", i ? "," : "", el.spans[i].s, el.spans[i].e);
    print_type(el.spans[i].type);
    putchar(']');
  }
  printf("]}");
  *first = 0;
  free(el.spans);
}

static int reported_as(const Walk *w, const char *type) {
  return w->frames[w->depth].type && !strcmp(w->frames[w->depth].type, type);
}

static void print_structure(TSNode root) {
  Walk w;
  int first_command = 1, first_redirection = 1;
  /* Two passes keep the JSON arrays separate without buffering. */
  printf(",\"cmd\":[");
  walk_start(&w, root);
  do {
    if (reported_as(&w, "command"))
      print_command(ts_tree_cursor_current_node(&w.cursor), &first_command);
  } while (walk_next(&w, 0));
  walk_end(&w);
  printf("],\"rd\":[");
  walk_start(&w, root);
  do {
    if (reported_as(&w, "redirection")) {
      TSNode n = ts_tree_cursor_current_node(&w.cursor);
      printf("%s[%u,%u]", first_redirection ? "" : ",", ts_node_start_byte(n),
             ts_node_end_byte(n));
      first_redirection = 0;
    }
  } while (walk_next(&w, 0));
  walk_end(&w);
  putchar(']');
}

/* Node types can be anonymous tokens such as "\n"; escape them as JSON. */
static void print_json_string(const char *s) {
  putchar('"');
  for (const unsigned char *p = (const unsigned char *)s; *p; p++) {
    if (*p == '"' || *p == '\\') printf("\\%c", *p);
    else if (*p < 0x20) printf("\\u%04x", *p);
    else putchar(*p);
  }
  putchar('"');
}

static void print_tree(TSNode root) {
  Walk w;
  uint32_t cap = 64, count = 0;
  int64_t *ids = malloc(cap * sizeof(*ids));
  printf(",\"n\":[");
  walk_start(&w, root);
  do {
    if (w.depth >= cap) ids = realloc(ids, (cap = w.depth * 2 + 2) * sizeof(*ids));
    int64_t parent = w.depth ? ids[w.depth - 1] : -1;
    const char *type = w.frames[w.depth].type;
    if (!type) {
      ids[w.depth] = parent;
      continue;
    }
    TSNode n = ts_tree_cursor_current_node(&w.cursor);
    const char *field = ts_tree_cursor_current_field_name(&w.cursor);
    if (count) putchar(',');
    putchar('[');
    print_json_string(type);
    printf(",%u,%u,%lld,%d,", ts_node_start_byte(n), ts_node_end_byte(n), (long long)parent,
           ts_node_is_named(n) | ts_node_is_error(n) << 1 | ts_node_is_missing(n) << 2);
    if (field) print_json_string(field);
    else printf("null");
    putchar(']');
    ids[w.depth] = count++;
  } while (walk_next(&w, 0));
  walk_end(&w);
  free(ids);
  putchar(']');
}

static char *read_path(void) {
  size_t cap = 256, n = 0;
  char *path = malloc(cap);
  int ch;
  while ((ch = getchar()) != EOF && ch != '\0') {
    if (n + 1 >= cap) path = realloc(path, cap *= 2);
    path[n++] = (char)ch;
  }
  if (ch == EOF && n == 0) { free(path); return NULL; }
  path[n] = '\0';
  return path;
}

int main(int argc, char **argv) {
  int debug = 0, tree_mode = 0;
  for (int i = 1; i < argc; i++) {
    if (!strcmp(argv[i], "--sexp")) debug = 1;
    else if (!strcmp(argv[i], "--tree")) tree_mode = 1;
    else { fprintf(stderr, "usage: ts-dump [--sexp] [--tree] < NUL-separated paths\n"); return 2; }
  }
  TSParser *parser = ts_parser_new();
  if (!ts_parser_set_language(parser, tree_sitter_powershell())) {
    fprintf(stderr, "incompatible tree-sitter runtime\n");
    return 2;
  }
  const char *names = getenv("TS_DUMP_NAMES");
  if (names && *names) load_names(tree_sitter_powershell(), names);
  ts_parser_set_timeout_micros(parser, 2000000);
  char *path;
  for (int index = 0; (path = read_path()); index++) {
    FILE *file = fopen(path, "rb");
    if (!file) { fprintf(stderr, "%s: cannot open\n", path); return 2; }
    fseek(file, 0, SEEK_END);
    long size = ftell(file);
    rewind(file);
    char *source = malloc((size_t)size + 1);
    if (fread(source, 1, (size_t)size, file) != (size_t)size) {
      fprintf(stderr, "%s: read failed\n", path);
      return 2;
    }
    fclose(file);
    uint32_t skip = !tree_mode && size >= 3 && (unsigned char)source[0] == 0xEF &&
                    (unsigned char)source[1] == 0xBB &&
                    (unsigned char)source[2] == 0xBF ? 3 : 0;
    ts_parser_reset(parser);
    struct timespec start, finish;
    clock_gettime(CLOCK_MONOTONIC, &start);
    TSTree *tree = ts_parser_parse_string(parser, NULL, source + skip,
                                          (uint32_t)size - skip);
    clock_gettime(CLOCK_MONOTONIC, &finish);
    double ms = (finish.tv_sec - start.tv_sec) * 1000.0 +
                (finish.tv_nsec - start.tv_nsec) / 1e6;
    if (!tree) {
      printf("{\"i\":%d,\"st\":\"timeout\",\"ms\":%.1f}\n", index, ms);
    } else {
      TSNode root = ts_tree_root_node(tree);
      if (debug) {
        char *sexp = ts_node_string(root);
        fprintf(stderr, "%s\n", sexp);
        free(sexp);
      }
      printf("{\"i\":%d,\"st\":\"%s\",\"ms\":%.1f", index,
             ts_node_has_error(root) ? "error" : "ok", ms);
      if (tree_mode) {
        print_tree(root);
      } else {
        putchar(',');
        print_errors(root);
        print_structure(root);
      }
      printf("}\n");
      ts_tree_delete(tree);
    }
    fflush(stdout);
    free(source);
    free(path);
  }
  ts_parser_delete(parser);
  return 0;
}
