/*
 * Build with src/parser.c, src/scanner.c and a tree-sitter runtime:
 * cc -std=c11 -D_DEFAULT_SOURCE -I src -I "$RUNTIME/include" -I "$RUNTIME/src" \
 *   test/string_delimiter_values.c src/parser.c src/scanner.c \
 *   "$RUNTIME/src/lib.c" -o string-delimiter-values
 *
 * --manifest emits synthetic sources and PowerShell 7.6.7 ParseInput-verified
 * String.Value expectations for an independent native parser check.
 */
#include <stdio.h>
#include <string.h>
#include <tree_sitter/api.h>
#include "tree_sitter/parser.h"

const TSLanguage *tree_sitter_powershell(void);

typedef struct {
  const char *name;
  const char *source;
  const char *value;
  unsigned variables;
  unsigned subexpressions;
} Case;

static const Case cases[] = {
  {"empty", "\"\"", "", 0, 0},
  {"one-space", "\" \"", " ", 0, 0},
  {"spaces", "\"   \"", "   ", 0, 0},
  {"hash-only", "\"#\"", "#", 0, 0},
  {"hash-prefix", "\" \t## text\"", " \t## text", 0, 0},
  {"hash-suffix", "\"text \t## \"", "text \t## ", 0, 0},
  {"hash-both", "\" \t## text ##\t \"", " \t## text ##\t ", 0, 0},
  {"newline-hash", "\"\n# text\n##\n\"", "\n# text\n##\n", 0, 0},
  {"comment-interpolation", "\" # $(1 + 2) ## \"", " # $(1 + 2) ## ", 0, 1},
  {"block-comment-text", "\" <# $x #> \"", " <# $x #> ", 1, 0},
  {"variables", "\" # $x ${other} ## \"", " # $x ${other} ## ", 2, 0},
  {"escaped-quotes", "\" # `\"text`\" \"\"more\"\" # \"", " # \"text\" \"more\" # ", 0, 0},
  {"escaped-dollars", "\" # `$x `$(1) # \"", " # $x $(1) # ", 0, 0},
  {"escaped-newline", "\" # a`\nb # \"", " # a\nb # ", 0, 0},
  {"trailing-dollars", "\" # $$ \"", " # $$ ", 1, 0},
  {"here-empty", "@\"\n\"@", "", 0, 0},
  {"here-one-blank", "@\"\n\n\"@", "", 0, 0},
  {"here-two-blanks", "@\"\n\n\n\"@", "\n", 0, 0},
  {"here-leading-blank", "@\"\n\ntext\n\"@", "\ntext", 0, 0},
  {"here-trailing-blank", "@\"\ntext\n\n\"@", "text\n", 0, 0},
  {"here-trailing-blanks", "@\"\ntext\n\n\n\"@", "text\n\n", 0, 0},
  {"here-blanks-both", "@\"\n\n\ntext\n\n\n\"@", "\n\ntext\n\n", 0, 0},
  {"here-space", "@\"\n \n\"@", " ", 0, 0},
  {"here-comment-text", "@\"\n # $(1 + 2) ## \n<# $x #>\n\n\"@", " # $(1 + 2) ## \n<# $x #>\n", 1, 1},
  {"here-escaped-prefix", "@\"\ntext\n`$(1)\n`$x\n``$x\n${other}\n\n\"@", "text\n$(1)\n$x\n`$x\n${other}\n", 2, 0},
  {"here-quoted-prefix", "@\"\ntext\n\"quoted\"\n\n\"@", "text\n\"quoted\"\n", 0, 0},
  {"here-escaped-quotes", "@\"\n`\"text`\" \"\"more\"\"\n\n\"@", "\"text\" \"\"more\"\"\n", 0, 0},
  {"here-escaped-newline", "@\"\ntext`\nnext\n\n\"@", "text\nnext\n", 0, 0},
  {"here-opening-spaces", "@\"  \ntext\n\n\"@", "text\n", 0, 0},
  {"verbatim-empty", "''", "", 0, 0},
  {"verbatim-space", "' '", " ", 0, 0},
  {"verbatim-hashes", "' \t## text ##\t '", " \t## text ##\t ", 0, 0},
  {"verbatim-escapes", "' `$x ''quote'' '", " `$x 'quote' ", 0, 0},
  {"verbatim-here-blanks", "@'\n\n # $x <# $(1) #>\n\n\n'@", "\n # $x <# $(1) #>\n\n", 0, 0},
  {"verbatim-here-quotes", "@'\n ''literal'' `\"$x\"\n\n'@", " ''literal'' `\"$x\"\n", 0, 0},
};

static void json_string(const char *s) {
  putchar('"');
  for (; *s; s++) {
    unsigned char c = (unsigned char)*s;
    if (c == '"' || c == '\\') printf("\\%c", c);
    else if (c < 32) printf("\\u%04x", c);
    else putchar(c);
  }
  putchar('"');
}

static void line_endings(char *out, const char *in, bool crlf) {
  while (*in) {
    if (crlf && *in == '\n') *out++ = '\r';
    *out++ = *in++;
  }
  *out = '\0';
}

static TSNode find_type(TSNode node, const char *type) {
  if (ts_node_is_null(node)) return node;
  if (!strcmp(ts_node_type(node), type)) return node;
  for (uint32_t i = 0; i < ts_node_child_count(node); i++) {
    TSNode found = find_type(ts_node_child(node, i), type);
    if (!ts_node_is_null(found)) return found;
  }
  return (TSNode){0};
}

static TSNode find_string(TSNode node) {
  return find_type(node, "string_literal");
}

static unsigned count_type(TSNode node, const char *type) {
  unsigned count = !strcmp(ts_node_type(node), type);
  for (uint32_t i = 0; i < ts_node_child_count(node); i++)
    count += count_type(ts_node_child(node, i), type);
  return count;
}

static bool check(TSParser *parser, const Case *c, const char *source,
                  const char *expected) {
  uint32_t length = (uint32_t)strlen(source);
  TSTree *tree = ts_parser_parse_string(parser, NULL, source, length);
  TSNode root = ts_tree_root_node(tree);
  TSNode literal = find_string(root);
  bool ok = !ts_node_has_error(root) && !ts_node_is_null(literal);
  if (!ok) {
    ts_tree_delete(tree);
    return false;
  }
  TSNode string = ts_node_child(literal, 0);
  bool here = source[0] == '@';
  bool verbatim = source[here ? 1 : 0] == '\'';
  uint32_t start = 1, end = length - 1;
  if (here) {
    start = (uint32_t)(strchr(source, '\n') - source + 1);
    end = length - 2;
    if (end > start && source[end - 1] == '\n') {
      end--;
      if (end > start && source[end - 1] == '\r') end--;
    }
  }
  if (!verbatim) {
    uint32_t count = ts_node_child_count(string);
    if (count < 2) ok = false;
    else {
      TSNode left = ts_node_child(string, 0);
      TSNode right = ts_node_child(string, count - 1);
      ok &= ts_node_start_byte(left) == 0 && ts_node_end_byte(left) == start;
      ok &= ts_node_start_byte(right) == end && ts_node_end_byte(right) == length;
      uint32_t next = start;
      for (uint32_t i = 1; i + 1 < count; i++) {
        TSNode content = ts_node_child(string, i);
        ok &= ts_node_start_byte(content) == next;
        next = ts_node_end_byte(content);
      }
      ok &= next == end;
    }
  }
  ok &= count_type(string, "comment") == 0;
  ok &= count_type(string, "variable") == c->variables;
  ok &= count_type(string, "sub_expression") == c->subexpressions;

  char value[4096];
  size_t size = 0;
  for (uint32_t i = start; i < end; i++) {
    char ch = source[i];
    if (!verbatim && ch == '`' && i + 1 < end) ch = source[++i];
    else if (!here && i + 1 < end &&
             ch == (verbatim ? '\'' : '"') && source[i + 1] == ch) i++;
    value[size++] = ch;
  }
  value[size] = '\0';
  ok &= !strcmp(value, expected);
  ts_tree_delete(tree);
  return ok;
}

static unsigned check_word_boundaries(TSParser *parser) {
  static const struct {
    const char *source;
    const char *argument;
    unsigned commands;
  } words[] = {
    {"Write-Output prefix`\nsuffix", "prefix`\nsuffix", 1},
    {"Write-Output prefix`\r\nsuffix", "prefix`\r", 2},
    {"Write-Output prefix$value`\r\nsuffix", "prefix$value`\r", 2},
    {"Write-Output `\r\nsuffix", "suffix", 1},
    {"Write-Output prefix\"a`\r\nb\"suffix", "prefix\"a`\r\nb\"suffix", 1},
    {"Write-Output prefix\"$value`\r\nsuffix\"", "prefix\"$value`\r\nsuffix\"", 1},
  };
  unsigned failures = 0;
  for (unsigned i = 0; i < sizeof(words) / sizeof(words[0]); i++) {
    TSTree *tree = ts_parser_parse_string(parser, NULL, words[i].source, strlen(words[i].source));
    TSNode root = ts_tree_root_node(tree);
    TSNode command = find_type(root, "command");
    TSNode elements = ts_node_child_by_field_name(command, "command_elements", 16);
    TSNode argument = find_type(elements, "generic_token");
    bool ok = !ts_node_has_error(root) &&
      count_type(root, "command") == words[i].commands &&
      !ts_node_is_null(argument);
    if (ok) {
      unsigned start = ts_node_start_byte(argument), end = ts_node_end_byte(argument);
      ok = end - start == strlen(words[i].argument) &&
        !memcmp(words[i].source + start, words[i].argument, end - start);
    }
    if (!ok) {
      fprintf(stderr, "FAIL word boundary %u\n", i);
      failures++;
    }
    ts_tree_delete(tree);
  }
  printf("Word escape boundaries: %zu/%zu passed\n",
         sizeof(words) / sizeof(words[0]) - failures,
         sizeof(words) / sizeof(words[0]));
  return failures;
}

int main(int argc, char **argv) {
  bool manifest = argc == 2 && !strcmp(argv[1], "--manifest");
  TSLanguage language = *tree_sitter_powershell();
  TSSymbolMetadata *metadata = malloc(
    (language.symbol_count + language.alias_count) * sizeof(*metadata));
  memcpy(metadata, language.symbol_metadata,
         (language.symbol_count + language.alias_count) * sizeof(*metadata));
  /* Regex terminals are normally hidden. Expose them without changing lexing
   * or parsing, so delimiter and content token spans can be tested separately. */
  for (uint32_t i = 1; i < language.token_count; i++) metadata[i].visible = true;
  language.symbol_metadata = metadata;
  TSParser *parser = ts_parser_new();
  if (!ts_parser_set_language(parser, &language)) return 2;
  unsigned failures = 0, total = 0;
  if (manifest) puts("[");
  for (size_t i = 0; i < sizeof(cases) / sizeof(*cases); i++) {
    for (unsigned crlf = 0; crlf < 2; crlf++) {
      char source[4096], expected[4096];
      line_endings(source, cases[i].source, crlf);
      line_endings(expected, cases[i].value, crlf);
      if (manifest) {
        if (total) puts(",");
        printf("{\"name\":\"%s-%s\",\"source\":", cases[i].name, crlf ? "crlf" : "lf");
        json_string(source);
        printf(",\"expected\":");
        json_string(expected);
        putchar('}');
      } else if (!check(parser, &cases[i], source, expected)) {
        fprintf(stderr, "FAIL %s-%s\n", cases[i].name, crlf ? "crlf" : "lf");
        failures++;
      }
      total++;
    }
  }
  if (manifest) puts("\n]");
  else {
    printf("String delimiter/value boundaries: %u/%u passed\n", total - failures, total);
    failures += check_word_boundaries(parser);
  }
  ts_parser_delete(parser);
  free(metadata);
  return failures ? 1 : 0;
}
