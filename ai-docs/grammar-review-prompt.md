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

Found in the 2026-10-23 review (keep in mind; do not re-measure from scratch):
Opengrep's `simplify` (`Missing_node`) turns every inline regex, `token()` or
`token.immediate()` inside a rule into a named preserved alias. In a rule with
many `choice`/`optional` productions, or one used in several contexts, this
multiplies ABI14 states; the 0.22 parser does not show it. Giving such a token
its own rule removes the cost. The chains above were left as they are: they
differ in `??`, unary comma and node names, and cost few states themselves.

## Grammar-author tips to apply during review
Condensed from Tree-sitter's
[Tips and Tricks for a grammar author](https://github.com/tree-sitter/tree-sitter/wiki/Tips-and-Tricks-for-a-grammar-author/).
Use these as measured experiments, not automatic rewrites.

- Run `tree-sitter generate --report-states-for-rule -` to rank all rules by
  state count; use `--report-states-for-rule RULE` to inspect one rule's states.
  A high count alone is not a defect: binary expressions naturally combine
  many operators and operands. Inspect unexpectedly large structural rules,
  especially sequences containing several `choice`, `optional` and `repeat`
  expressions, before simplifying expression rules.
- Try extracting a coherent sequence into a hidden rule (name prefixed with
  `_`). For a `for` statement, keep `for`, parentheses and the body in the
  visible rule; extract the initializer, condition, update and their separating
  semicolons together. Preserve fields, alternatives and optionality.
- Split other combinatorial sequences at meaningful boundaries. The wiki's
  typedef example extracts the type portion (qualifiers, type field,
  qualifiers) and the comma-separated declarators into separate hidden rules,
  leaving the optional prefix, trailing attributes and semicolon outside.
  Reuse existing list helpers; do not introduce rule factories.
- Hidden rules avoid additional visible wrapper nodes in Tree-sitter's CST;
  they do not guarantee unchanged fields, boundaries or Opengrep's generated
  OCaml CST types. Apply the existing tree-identity and converter gates.
- Regenerate and measure after each extraction. Refactoring can increase
  states; try a different boundary or discard an unsuccessful experiment.
  Re-rank all rules afterwards: factoring one rule can reduce other rules'
  states too. In the wiki's tree-sitter-c v0.20.5 example, total/large states
  went from 2243/666 to 2048/610 after the `for` extraction, then to 1825/510
  after typedef factoring. These are examples, not targets or guarantees.
- Measure the transformed ABI14 parser, not just the 0.22 source grammar.
  Keep the preserved-token alias caveat above in mind; extracting tokens and
  extracting hidden sequences address different sources of state growth.

For scanner changes or investigation:

- Trace both `advance` and `skip` wrappers temporarily, logging the operation,
  current `lexer->lookahead` and call-site `__LINE__` before advancing. Wrapper
  macros can capture the caller's line; `advance` calls
  `lexer->advance(lexer, false)`, while `skip` calls
  `lexer->advance(lexer, true)`. Remove or disable tracing before validation
  and timing; do not leave debug output in the committed scanner.
- Write down the accepted and rejected lookahead scenarios before changing a
  complicated scanner branch. Check `valid_symbols[TOKEN]` before scanning
  that token; return `false` when its spelling or required context fails.
- Call `lexer->mark_end(lexer)` immediately after the token's last character
  when recognizing it requires lookahead beyond its extent. Advance through
  that lookahead with `skip = false`; use `skip = true` only for leading
  trivia before the token, not for lookahead after the marked end.
- The wiki's illustrative token is `-a` only when followed by zero or more
  whitespace characters, a backslash, then a newline or `$`. Consume `-a`,
  mark its end, advance through whitespace and the backslash, and check the
  next character without including that context in the token. Set
  `lexer->result_symbol` to the matching external token before returning
  `true` (the wiki's abbreviated sample omits this assignment). This example
  explains scanner mechanics; it is not a PowerShell syntax rule.

The wiki can also be kept offline with
`git clone https://github.com/tree-sitter/tree-sitter.wiki.git tmp/tree-sitter.wiki`
from the workspace root; cloning is optional, not a review prerequisite.

## Phase 1: report only, then stop

Do not edit anything in this phase. Write `ai-docs/local/results/grammar-review.md`
with:

- current metrics (see Tools);
- a ranked list of proposals. For each, give the expected readability and
  performance effect, risk, and whether it changes the converter-visible CST;
- what you recommend not doing, and why.

Stop and ask the user which proposals to implement.

## Phase 2: implement approved proposals, one commit each, then squash

Work in a worktree (`git worktree add -b og/grammar-cleanup ai-docs/local/worktrees/og-grammar-cleanup opengrep-dev`).
Each change must pass the behaviour-identity gate below before the next starts.
Then commit it on `og/grammar-cleanup`, one commit per proposal, and record its
size and gate result in the report. These commits are known-good checkpoints:
if a later change goes wrong, reset the branch to the last one.

When every approved change has passed, fold the branch into one commit on
`opengrep-dev`: `git merge --squash og/grammar-cleanup` in the parent checkout,
then regenerate `opengrep/ocaml/`, adapt the converter and run `validate full`.
Commit the grammar, scanner, regenerated `opengrep/ocaml/`, grammar-size row and
doc notes together as the one review commit. Add one Opengrep commit for the
converter and pin. Then remove the worktree and delete the branch
(`git branch -D`, since a squash merge does not mark it as merged).

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
    that could move node boundaries or names. Ignore the per-file `"ms"`
    timing field.
  - Decided (2026-10-23 review); do not ask again: a file whose tree contains
    an `ERROR` or `MISSING` node both before and after the change may get a
    different tree. On a syntax error tree-sitter guesses a repair, and that
    guess depends on the parse table's internals, so any table change
    (fewer states, renamed tokens) can move it slightly. These files are
    broken either way: invalid PowerShell or non-UTF-8 bytes, which `--tree`
    still parses. Accept such differences and list the affected files in
    the report. Every file without errors must keep a byte-identical tree;
    a difference there fails the gate.
- **Converter impact:** generated `opengrep/ocaml/lib/CST.ml` must not change
  unless the user approved it. Check with
  `node ai-docs/tools/validate.mjs full --only source,compat --label L`
  (parent checkout only), then `git diff opengrep/ocaml/lib/CST.ml`.
  Revert the regenerated files afterwards if the change is not being kept.
- **Size:** the `#define` lines `STATE_COUNT`, `LARGE_STATE_COUNT`,
  `SYMBOL_COUNT` and `PRODUCTION_ID_COUNT` in the quick run's
  `compat-abi14/src/parser.c`, plus the size of `parser.c`.
- **Hotspots:** `tree-sitter generate --report-states-for-rule RULE` (0.22.6)
  shows the states for a rule; use `-` instead of `RULE` to rank all rules.
  `tree-sitter generate --log` explains state splitting, extracted keywords
  and recovery tokens. Generator warnings identify unnecessary conflicts and
  unused rules; investigate rather than blindly removing declarations.
  Run generation only in scratch/worktree output, never over root generated
  files. Pin generator version, ABI, grammar transformation and inputs for
  repeatable comparisons. The generator already optimizes parse tables;
  these diagnostics do not automatically refactor `grammar.js`.
- **Runtime diagnostics:** `tree-sitter parse --debug FILE` exposes lexing and
  parsing decisions; `--debug-graph` produces Graphviz stack/tree traces for
  investigating ambiguity and branching. Use small synthetic reproductions
  with the candidate parser in scratch, not corpus execution. Check the
  pinned CLI's `--help` before using options from newer documentation.
- **Speed:** the `ts_ms` field per file in the grammar results; compare totals
  between base and candidate runs on the same idle machine. Repeat runs;
  timing is noisy, not a deterministic identity or size check. Fewer states
  alone do not prove a faster parser.

## Boundaries

- Do not hand-edit generated files (`src/parser.c`, `src/grammar.json`,
  `src/node-types.json`, `opengrep/ocaml/`). Validation regenerates them.
- External token order must stay identical in `grammar.js` and `scanner.c`.
- Corpus files are immutable. Never delete, skip or weaken tests or expectations.
- Commit explicit files only. No co-author trailer, no push. Per-proposal
  commits stay on `og/grammar-cleanup`; `opengrep-dev` gets one squashed review
  commit (see phase 2).
- Converter edits are parent work: if an approved change alters `CST.ml`,
  adapt the converter and run `validate full`.
- When finished, add a row marked "review" to `ai-docs/grammar-size.md`, in
  the review commit. It cannot name its own hash: write the base commit it
  reviewed, for example `review of 2f8d138`.
