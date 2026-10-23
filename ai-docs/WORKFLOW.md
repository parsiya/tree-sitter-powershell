# Check the batch, fix, test, repeat

Run tools from the grammar repository root. Configuration, corpus links and
results are in `ai-docs/local/`. Existing tools handle generation and the build environment.

## Check the batch

```sh
node ai-docs/tools/validate.mjs full --label NAME
```

Read the summary. Inspect only failing logs and remaining grammar/conversion
differences. A baseline comparison passing does not erase known failures.

## Fix failures

The parent groups failures by root cause and assigns independent fixes to
subagents. Each worker uses its own worktree:

```sh
git worktree add -b og/TOPIC ai-docs/local/worktrees/og-TOPIC opengrep-dev
```

The worker makes a small synthetic reproduction, checks the relevant behaviour
against Native PowerShell, fixes the grammar and adds regression tests.
Keep proofs focused on the actual failure and nearby valid/invalid controls.

```sh
node ai-docs/tools/proof-kit.mjs CASES.json --fork WORKTREE --known-pattern trailing-trivia
node ai-docs/tools/validate.mjs quick --fork WORKTREE --label TOPIC-N
```

Iterate targeted checks and quick validation. At handback, run
`node ai-docs/tools/proof-kit.mjs --suites --fork WORKTREE` once, record only
reviewed new/improved expectations, and commit explicit files.
Report the branch/commit, test result, converter impact and any blocker.
Workers do not report elapsed time; the parent records each worker's time and
attempts from the agent runtime.

## Integrate and repeat

The parent merges fixes with `--no-ff`, resolves source conflicts, and adapts
the PowerShell converter/tests. External-token order must match in grammar and scanner.
Before the first build, regenerate with `validate full --only source,compat`,
read the `git diff opengrep/ocaml/lib/CST.ml`, and write the converter changes
for every changed type at once rather than one compile error per build.
Rerun `validate full`; it regenerates `opengrep/ocaml/`. Fix reported failures
and repeat. Fixes can expose new problems in files that previously failed
earlier, so expect a short second worker round after the first integration. Run `node ai-docs/tools/proof-kit.mjs --suites` once on the integrated parser.
Never hand-edit generated output.

When checks pass, commit the grammar and Opengrep integration with explicit files.
Commit once at the end of the batch: worker commits and their merges are the only
commits made during it. Exception: if a session must stop partway, commit
tested integrated work so it is not lost; never commit untested work. Doc and
process edits made between batches also go into one commit, not one per change.
Do not commit excessively. The regenerated parser, the grammar-size row and the
batch's doc notes go into the same final commit, never into a commit of their own.
Run full on the clean committed trees, then:

```sh
node ai-docs/tools/validate.mjs promote NAME
```

## Grammar size check after each batch

At the end of each batch, add a row to [grammar-size.md](grammar-size.md) in the
batch's final commit:

```sh
grep '^#define STATE_COUNT' opengrep/ocaml/lib/parser.c
wc -c < opengrep/ocaml/lib/parser.c
```

Compare the new row with the last row marked "review". If the state count has
grown more than 10% since then, or a worker reported copying a rule chain, tell
the user in the batch report and suggest a grammar review; do not start it
yourself. The user runs the review in a new top-level Opus 5.5 session, using
[grammar-review-prompt.md](grammar-review-prompt.md). The review first
suggests cleanups and stops; the user picks which ones to do. The review is one
grammar commit (see the review prompt), including a new row marked "review".

## Correcting an existing test expectation

If Native evidence proves an expectation wrong, correct it with the fix,
including inherited Airbus expectations. Preserve inputs and coverage, explain
the correction, and never approve unexplained regressions. Different CST names
alone do not establish incorrect behaviour.

Log real blockers and continue independent work. Keep all checks and full JSON
reports, but use compact console output. Do not add process, scripts or reports
unless required to fix the batch or explicitly requested.
