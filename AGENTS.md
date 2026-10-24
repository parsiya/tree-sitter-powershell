# PowerShell grammar work

Goal: make the grammar and Opengrep correctly parse the batch being worked on.
Airbus compatibility is not a goal. Use the existing tools; do not turn a batch
fix into a tooling, audit or documentation project unless the user asks.

## Process

1. Check the batch with `node ai-docs/tools/validate.mjs full --label NAME`.
   Use a new label each time. Read the summary, then only the failing stage's log.
2. Group actual failures by root cause. The parent assigns each independent
   grammar fix to a subagent in its own `og/TOPIC` worktree from `opengrep-dev`.
   Give each subagent the [fix-agent brief](ai-docs/skills/fix-agent/SKILL.md),
   topic, grammar root, worktree/branch, reproduction or failing file/offset,
   and scope. Run independent workers in parallel. The parent reviews and
   merges their returned branches and handles converter integration.
3. Workers make a small reproduction, check Native PowerShell where needed,
   fix it, add regression tests and run targeted checks before `validate quick`.
   Run existing proof suites once at handback, not after every edit.
4. The parent merges fixes, adapts the PowerShell converter and tests, and
   reruns the batch check. Repeat until fixed or genuinely blocked.
5. Run the proof suites once on the integrated parser. Commit tested changes;
   certify clean trees and promote the passing run as the next baseline.

A regression PASS is not proof that every input is correct: inspect remaining
grammar disagreements and conversion errors too. Record each blocker in the
campaign blockers log as soon as it is found (see WORKFLOW.md), then move to
independent work. Packages that block a passing run for non-grammar reasons
are quarantined byte-identical into a later batch (WORKFLOW.md). Do not invent work after the batch is clear.

## Boundaries

- Change `grammar.js`, `src/scanner.c`, `src/parameter_letters.h` and tests.
  Rule-only syntax belongs in `opengrep/grammar.cjs`.
- Test Opengrep's ABI 14 parser on tree-sitter 0.22.6. Do not regenerate root
  `src/parser.c`, `src/grammar.json` or `src/node-types.json`, or hand-edit generated files.
- Native evidence can justify correcting any test expectation, including
  upstream ones. Preserve inputs and coverage; never hide a regression.
- Original corpus files and package archives are immutable, read-only data.
  Never execute, repair, reformat, normalize encoding/BOM/line endings, chmod,
  split, truncate or exclude a source file to make a check pass. Grammar and
  Opengrep must work on the original complete input bytes. Authorized batching
  may relocate unchanged files; verify content hashes rather than assuming this.
  Never copy corpus code into tests; use made-up reductions and Native parse-only
  checks. Correcting a proven-wrong expected tree or finding is not permission
  to change its input, skip a test or hide an unsupported file.
  Verify corpus integrity before claiming certification. Report unexpected
  source changes and provenance gaps; never silently refresh their baseline.
- Encoding and shared Opengrep code changes are deferred; record those blockers.
- Workers do not run Dune/full validation or spawn agents. The parent owns integration.
- Stage explicit files, no co-author trailers, no pushes.
- Keep output compact. Inspect specific JSON entries, not whole reports or generated diffs.
- A handoff contains current state, remaining problems and the next command only.
  No completed-task lists or mandatory history/audit reading.

Commands: [ai-docs/WORKFLOW.md](ai-docs/WORKFLOW.md). Read other docs only when needed.
