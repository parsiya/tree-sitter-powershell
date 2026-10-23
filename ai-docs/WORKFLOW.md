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

## Integrate and repeat

The parent merges fixes with `--no-ff`, resolves source conflicts, and adapts
the PowerShell converter/tests. External-token order must match in grammar and scanner.
Rerun `validate full`; it regenerates `opengrep/ocaml/`. Fix reported failures
and repeat. Run `node ai-docs/tools/proof-kit.mjs --suites` once on the integrated parser.
Never hand-edit generated output.

When checks pass, commit the grammar and Opengrep integration with explicit files.
Run full on the clean committed trees, then:

```sh
node ai-docs/tools/validate.mjs promote NAME
```

## Correcting an existing test expectation

If Native evidence proves an expectation wrong, correct it with the fix,
including inherited Airbus expectations. Preserve inputs and coverage, explain
the correction, and never approve unexplained regressions. Different CST names
alone do not establish incorrect behaviour.

Log real blockers and continue independent work. Keep all checks and full JSON
reports, but use compact console output. Do not add process, scripts or reports
unless required to fix the batch or explicitly requested.
