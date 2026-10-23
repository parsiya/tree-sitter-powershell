# Prompt: review and tidy the PowerShell grammar (for Opus 5.5)

You are reviewing the PowerShell tree-sitter grammar used by Opengrep.

- Grammar repo: `/home/parsia/dev/opengrep/languages/powershell/tree-sitter/opengrep-powershell`
  (branch `opengrep-dev`). Read its `AGENTS.md` first and follow its boundaries.
- Opengrep converter: `/home/parsia/dev/opengrep/languages/powershell/generic/Parse_powershell_tree_sitter.ml`.

## Goal and priorities

Make `grammar.js` and `src/scanner.c` easier for an AI to read and change
safely, without changing behaviour.

1. **Readability for an AI comes first.** Explicit and slightly longer is
   better than clever and shorter. Do not introduce rule-generating helper
   functions, parameterized rule factories or indirection just to remove lines.
2. **Performance second.** Parser size and parse time matter: since grammar
   `90ecb7a`, batch-004 grew the ABI14 parser from 5551 to 6864 states and
   from 13.8 MB to 16.8 MB of `parser.c`.
3. **Fewer lines is not a goal by itself.**

Known near-duplicate rule chains (expression rules without comma arrays):
`_attribute_*`, `_class_default_*`, `_paren_*`. They exist because commas mean
something different in those positions. Decide whether merging any of them
helps readability or performance. Leaving them as they are, with a clear
comment explaining why the copy exists, is an acceptable answer.

## Phase 1: report only, then stop

Do not edit anything in this phase. Write `ai-docs/local/results/grammar-review.md`
with:

- current metrics (see Tools);
- a ranked list of proposals. For each, give the expected readability and
  performance effect, risk, and whether it changes the converter-visible CST;
- what you recommend not doing, and why.

Stop and ask the user which proposals to implement.

## Phase 2: implement approved proposals, one per commit

Work in a worktree (`git worktree add -b og/grammar-cleanup ai-docs/local/worktrees/og-grammar-cleanup opengrep-dev`).
Each change must pass the behaviour-identity gate below before the next starts.

## Tools (deterministic; use these instead of judgment where possible)

- **Behaviour identity**
  - `node ai-docs/tools/validate.mjs quick --fork W --label L --keep-scratch`
    must pass. Its per-file grammar results
    (`ai-docs/local/runs/L/grammar/BATCH/files.jsonl`, `category` and `problems`)
    must be identical to a quick run of the unchanged base, for every batch.
  - `node ai-docs/tools/proof-kit.mjs --suites --fork W` must pass with no
    changed expectations.
  - The strongest check is to dump full trees with the kept `ts-dump --tree`
    binaries of both runs. Feed every readable file of every corpus batch
    (NUL-separated paths on stdin) and diff the outputs. Use it for any change
    that could move node boundaries or names.
- **Converter impact:** generated `opengrep/ocaml/lib/CST.ml` must not change
  unless the user approved it. Check with
  `node ai-docs/tools/validate.mjs full --only source,compat --label L`
  (parent checkout only), then `git diff opengrep/ocaml/lib/CST.ml`.
  Revert the regenerated files afterwards if the change is not being kept.
- **Size:** the `#define` lines `STATE_COUNT`, `LARGE_STATE_COUNT`,
  `SYMBOL_COUNT` and `PRODUCTION_ID_COUNT` in the quick run's
  `compat-abi14/src/parser.c`, plus the size of `parser.c`.
- **Hotspots:** `tree-sitter generate --report-states-for-rule RULE` (0.22.6)
  shows which rules create many states. Generator warnings show unnecessary
  conflicts and unused rules.
- **Speed:** the `ts_ms` field per file in the grammar results; compare totals
  between base and candidate runs on the same idle machine.

## Boundaries

- Do not hand-edit generated files (`src/parser.c`, `src/grammar.json`,
  `src/node-types.json`, `opengrep/ocaml/`). Validation regenerates them.
- External token order must stay identical in `grammar.js` and `scanner.c`.
- Corpus files are immutable. Never delete, skip or weaken tests or expectations.
- Commit explicit files only. No co-author trailer, no push.
- Converter edits are parent work: if an approved change alters `CST.ml`,
  adapt the converter and run `validate full`.
- When finished, add a row marked "review" to `ai-docs/grammar-size.md`.
