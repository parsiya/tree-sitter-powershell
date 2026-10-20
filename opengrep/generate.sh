#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: bash opengrep/generate.sh OPENGREP_CHECKOUT" >&2
  exit 1
fi

repository=$(cd "$(dirname "$0")/.." && pwd)
root=$(cd "$1" && pwd)
build_dir="$root/_build/powershell-grammar/fork"
destination="$repository/opengrep/ocaml"
core="$root/libs/ocaml-tree-sitter-core"
generator="$root/_build/default/libs/ocaml-tree-sitter-core/src/gen/bin/Ocaml_tree_sitter_main.exe"
version=$(cat "$repository/opengrep/tree-sitter-version")

if [[ ! -f "$core/scripts/ocaml-tree-sitter-gen-ocaml" ]]; then
  echo "Not an initialized Opengrep checkout: $root" >&2
  exit 1
fi

if [[ "$(tree-sitter --version)" != "tree-sitter $version"* ]]; then
  echo "PowerShell parser generation requires tree-sitter $version." >&2
  exit 1
fi

cd "$root"
dune build libs/ocaml-tree-sitter-core/src/gen/bin/Ocaml_tree_sitter_main.exe
mkdir -p "$build_dir/src" "$build_dir/bin"
node "$repository/opengrep/prepare-grammar.cjs" "$repository" "$build_dir"
cp "$repository/src/scanner.c" "$build_dir/src/scanner.c"
ln -sf "$generator" "$build_dir/bin/ocaml-tree-sitter"

(
  cd "$build_dir"
  tree-sitter generate --no-bindings
  "$generator" simplify src/grammar.json src/grammar.simplified.json
  mv src/grammar.simplified.json src/grammar.json
  tree-sitter generate src/grammar.json --no-bindings
  PATH="$build_dir/bin:$PATH" "$core/scripts/ocaml-tree-sitter-gen-ocaml" \
    --lang powershell --src src --dst ocaml-src
)

for file in "$destination"/lib/* "$destination"/bin/*; do
  if [[ -f "$file" ]]; then
    case "$file" in
      "$destination"/lib/*.ml|"$destination"/lib/*.mli|"$destination"/lib/*.c|\
      "$destination"/lib/*.h|"$destination"/lib/dune|"$destination"/bin/Main.ml|\
      "$destination"/bin/dune)
        if [[ ! -f "$build_dir/ocaml-src/${file#"$destination"/}" ]]; then
          echo "Stale generated file requires review: $file" >&2
          exit 1
        fi
        ;;
    esac
  fi
done

mkdir -p "$destination"
cp -R "$build_dir/ocaml-src/lib" "$build_dir/ocaml-src/bin" "$destination/"
cp "$repository/LICENSE" "$destination/LICENSE"
