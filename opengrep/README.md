# Maintaining the Opengrep PowerShell parser

This fork supplies a parser to Opengrep. It is not a separate scanning tool.
Development happens on `opengrep-dev`.

## Where changes go

There are two kinds of changes, and they live in different places.

**PowerShell grammar fixes go in the root `grammar.js`.** These are fixes for
valid PowerShell that the grammar rejects or reads wrongly. Each fix is made on
its own branch from Airbus's `main`, so it can be offered to Airbus as is. Opengrep
does not wait for Airbus: the branch is merged into `opengrep-dev` right away.
If Airbus does not want a fix, it stays here. See
[Fixing the grammar](#fixing-the-grammar).

**Opengrep-only additions go under this `opengrep/` directory.** These are
things Airbus would not want, such as rule syntax (`$...ARGS`), and the files
that build Opengrep's parser:

| Path | Purpose |
| --- | --- |
| `grammar.cjs` | Loads the root grammar and adds Opengrep rule syntax. Do not put PowerShell fixes here. |
| `prepare-grammar.cjs` | Creates a CommonJS copy in the build directory for the older generator. It does not edit the root grammar. |
| `generate.sh` | Generates the C and OCaml parser files using an initialized Opengrep checkout. |
| `test.sh` | Tests the generated grammar against the root tests and the Opengrep-only tests. |
| `test/` | Tests for Opengrep rule syntax. |
| `ocaml/` | Generated parser library used by Opengrep; do not hand-edit it. |
| `upstream-commit` | Airbus revision last merged into `opengrep-dev`. |
| `tree-sitter-version` | CLI version used to generate Opengrep's parser. |
| `ocaml-generator-commit` | Last verified revision of Opengrep's OCaml parser generator. |

The initial upstream baseline is
`c96b28ed405e3172e0a4b6a97fc132ce2e3b6304`. The Opengrep generator revision is
`1392efc21e60d5acde72d0d1c6586f5692fedace`.

Grammar fixes merged into `opengrep-dev` (Airbus status as of 2026-10-20):

| Branch | Fix | Airbus |
| --- | --- | --- |
| `fix/empty-program` | Accept files with no statements: empty, comment-only, or only a `param` block. | Not yet offered. |

Opengrep-only addition in `grammar.cjs`:

- Recognize `$...ARGS` and similar named ellipses. This is for Opengrep rules,
  not normal PowerShell source.

The ESM-to-CommonJS change is only a build adaptation. It is made in the build
directory, not in the root grammar. Compatibility generation uses Tree-sitter
0.22.6 to produce ABI-14 output for Opengrep's existing runtime.

Normal Opengrep builds use the checked-in generated files. They do not need
Node.js or the Tree-sitter CLI. Regeneration requires those tools and the normal
Opengrep OCaml build dependencies.

## Build and test

Set `OPENGREP_ROOT` to the absolute path of an initialized Opengrep checkout.
Activate that checkout's OCaml/native-library environment first. On the original
Debian development machine:

```sh
source /home/parsia/.local/share/opengrep-build/env.sh
export OPENGREP_ROOT=/home/parsia/dev/opengrep
```

From this fork's root:

```sh
bash opengrep/generate.sh "$OPENGREP_ROOT"
bash opengrep/test.sh "$OPENGREP_ROOT"
```

Temporary generation files go under the Opengrep checkout's
`_build/powershell-grammar/fork/`. Grammar tests use a fresh
`_build/powershell-grammar/tests.*` directory on each run so removed upstream tests
cannot linger. These scripts never modify the root grammar, scanner, generated
files, or tests.

The grammar corpus runs before OCaml simplification. Simplification exposes
normally hidden nodes, so comparing its trees directly with Airbus's expected
trees would produce false failures. The focused Opengrep tests below exercise
the actual simplified C/OCaml parser and its conversion into Opengrep's AST.

Then, from the Opengrep checkout, run only the affected tests:

```sh
cd "$OPENGREP_ROOT"
make core
make build-core-test
./test run -j0 -t lang.powershell
./test run -j0 -s powershell
```

The tag selects PowerShell parsing, matching, rule, range, and basic taint tests.
The substring also selects filename/shebang discovery and malformed-input tests.
Do not use `--update`, `test approve`, or `dune promote` just to hide failures.
Review and explain any intentional expected-output changes first.

## Fixing the grammar

Make each fix small and about one problem, so Airbus can review it on its own.

1. Start a branch from Airbus's `main`, not from `opengrep-dev`:

   ```sh
   git fetch upstream
   git switch -c fix/short-name upstream/main
   ```

2. Reduce a real example to a small made-up one. Check it with PowerShell's own
   parser (`[System.Management.Automation.Language.Parser]::ParseInput`) and
   confirm that the current grammar gets it wrong. Do not copy third-party
   scripts into tests.
3. Add the example to the matching `test/corpus/*.txt` file.
4. Edit the root `grammar.js`. Regenerate the root `src/` with the same
   Tree-sitter CLI version Airbus used for its committed `src/parser.c`
   (the version is in the file's first line; 0.25.10 as of 2026-10-20):

   ```sh
   npx tree-sitter-cli@0.25.10 generate
   npx tree-sitter-cli@0.25.10 test
   npm ci --ignore-scripts && npx eslint grammar.js
   ```

   Keep Airbus's `src/tree_sitter/*.h` headers if the CLI rewrites them; they
   are not part of the fix. Before editing, regenerating `upstream/main` with
   this CLI should leave `src/parser.c` unchanged. If it does not, the version
   is wrong.
5. Commit the grammar, regenerated `src/`, and tests on the branch. Say in the
   message what PowerShell accepts, what the grammar did, and how many
   real-world files it affects, if known.
6. Merge the branch into `opengrep-dev` with `git merge --no-ff`, then
   regenerate and test Opengrep's parser as described in
   [Build and test](#build-and-test). A grammar change can change the generated
   OCaml types; update Opengrep's PowerShell converter in the same Opengrep
   change if needed.
7. Add the branch to the table in [Where changes go](#where-changes-go).
8. Offer the branch to Airbus as a pull request when ready. This is optional
   and separate; Opengrep does not depend on it. If Airbus merges a different
   fix for the same problem, prefer theirs on the next update.

## Updating from Airbus

1. Start with clean worktrees in this fork and in Opengrep. Save or commit local
   work first. Keep the current working parser commit available as a baseline.
2. Add the original repository as a remote once:

   ```sh
   git remote add upstream https://github.com/airbus-cert/tree-sitter-powershell.git
   ```

   If `upstream` already exists, inspect its URL instead of adding it again.

3. Fetch and merge its changes into the development branch:

   ```sh
   git switch opengrep-dev
   git fetch upstream
   git merge upstream/main
   ```

   A merge preserves history on a shared branch and does not require a force
   push. Prefer merging a reviewed upstream commit when updates need to be
   smaller than the current upstream branch.

4. Review upstream changes to grammar rules, scanners, tests, and tool versions.
   Root `grammar.js` conflicts are expected when Airbus changes a rule we
   fixed. Resolve `grammar.js` and `test/corpus/` by hand, then regenerate
   `src/`; do not merge generated `src/` files line by line. If Airbus merged
   one of our fixes, or fixed the same problem differently, keep Airbus's
   version and update the table in [Where changes go](#where-changes-go).
   Also check that `opengrep/grammar.cjs` still matches the rules it extends.
5. Update the Opengrep-only extension or build adaptation if needed. Keep
   PowerShell fixes in the root grammar and Opengrep-only syntax in
   `opengrep/`, so fixes can still be offered to Airbus independently.
6. Regenerate. Never resolve generated-parser conflicts by editing C/OCaml
   output manually. Regenerate the root `src/` with Airbus's CLI version and
   `opengrep/ocaml/` with our generator.
7. Run the grammar tests and focused Opengrep tests above. Run the same
   real-world PowerShell corpus before and after the update when available.
   Compare failures, untranslated syntax, matches, and captures. Do not improve
   the reported rate by silently excluding files.
8. Record the actual merged upstream revision in `upstream-commit`. If the
   generator/runtime compatibility changes, update the tool-version records
   deliberately and test against Opengrep before claiming compatibility.
   Regenerate twice and compare the output to check reproducibility.
9. Commit the extension changes, regenerated output, provenance, and tests in
   this fork. Publish that commit to the fork before publishing an Opengrep
   commit that points to it:

   ```sh
   git push -u origin opengrep-dev
   ```

   Publishing is a separate action; the generation and test scripts never push.
10. In Opengrep, stage the parser submodule at the tested commit:

    ```sh
    git add languages/powershell/tree-sitter/opengrep-powershell
    ```

    Commit that pointer along with any needed conversion-code or test changes.
    A submodule pins a commit, not a moving branch. The configured branch helps
    deliberate updates; a normal `git submodule update --init --recursive`
    checks out the pinned commit.

Do not point Opengrep at a fork commit that exists only on one machine when
sharing the change. Do not force-push or rewrite a parser commit already used by
an Opengrep commit.

## Verified migration baseline

On 2026-10-19, with the tool revisions recorded above:

- All 165 inherited grammar tests and 3 added grammar tests passed.
- `opam exec -- dune build -j 6 _build/install/default/bin/opengrep src/tests/test.exe`
  passed from the containing Opengrep checkout.
- `./test run -j0 -t lang.powershell`: 30 tests passed.
- `./test run -j0 -s powershell`: 17 tests passed, including discovery and
  malformed-input checks. Some tests also appear in the tagged selection.
- A normal CLI scan returned the three expected matches and preserved the
  `(1 + 2)` capture's source range.
- All generated parser files matched the pre-migration files byte for byte.
- The root Airbus files had no modifications.

The full Opengrep suite was intentionally not rerun for this migration. The
real-world PowerShell corpus has not yet been supplied or tested.

## Licensing

Airbus's grammar and scanner use the root MIT license. Preserve that notice and
any notices in the generated headers, bindings, and generator-derived files.
Adding the parser to Opengrep does not change the original grammar's license.
