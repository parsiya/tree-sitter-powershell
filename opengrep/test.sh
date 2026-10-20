#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: bash opengrep/test.sh OPENGREP_CHECKOUT" >&2
  exit 1
fi

repository=$(cd "$(dirname "$0")/.." && pwd)
root=$(cd "$1" && pwd)
bash "$repository/opengrep/generate.sh" "$root"
build_dir=$(mktemp -d "$root/_build/powershell-grammar/tests.XXXXXX")
mkdir -p "$build_dir/src" "$build_dir/test/corpus"
node "$repository/opengrep/prepare-grammar.cjs" "$repository" "$build_dir"
cp "$repository/src/scanner.c" "$build_dir/src/scanner.c"
cp "$repository"/test/corpus/*.txt "$build_dir/test/corpus/"
cp "$repository"/opengrep/test/*.txt "$build_dir/test/corpus/"
cd "$build_dir"
tree-sitter generate --no-bindings
tree-sitter test
