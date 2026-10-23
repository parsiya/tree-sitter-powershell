# AGENTS.md

Instructions for AI agents working in this repository. Read this first; the
details are in [ai-docs/](ai-docs/README.md).

## What this repository is

This is the PowerShell tree-sitter grammar used by **Opengrep**. It is checked
out as an Opengrep submodule at `languages/powershell/tree-sitter/opengrep-powershell`.

- **Only the grammar Opengrep uses matters.** That is the root `grammar.js` and
  `src/scanner.c` (with `src/parameter_letters.h`), plus `opengrep/grammar.cjs`
  for rule-only syntax. It's built by tree-sitter CLI 0.22.6, simplified, and
  run as the ABI 14 parser in `opengrep/ocaml/lib/`.
- The root `src/parser.c`, `src/grammar.json` and `src/node-types.json` come
  from upstream's own generator. Opengrep doesn't use them and the tools don't
  test them, so don't regenerate them.
- Upstream (Airbus) compatibility is not a goal right now.

## Before you start

Run everything from this repository's root.

1. Check `ai-docs/local/config.json` exists. If it doesn't, follow
   [ai-docs/README.md](ai-docs/README.md) (quick start). The corpus,
   downloads, runs and baselines all live in Git-ignored `ai-docs/local/`.
2. `node ai-docs/tools/validate.mjs quick --label start-$(date +%s)` must
   pass on a clean checkout before you change anything. If it fails, stop and
   report the summary: the environment is broken, not your change.

## What you may change

| Change | Where |
| --- | --- |
| Real PowerShell syntax | `grammar.js`, `src/scanner.c`, `src/parameter_letters.h` |
| Rule-only (pattern) syntax | `opengrep/grammar.cjs` |
| Grammar tests | Add cases to `test/corpus/*.txt` and `opengrep/test/*.txt`; correct proven-wrong expectations as below; byte-exact C tests in `test/*.c` |
| Proofs | new or extended suites in `ai-docs/cases/` and their `.expected.json` |

**Never** hand-edit generated files (`src/parser.c`, `src/grammar.json`,
`src/node-types.json`, anything under `opengrep/ocaml/`). Don't edit
`ai-docs/tools/` unless that's your task.

## Correctness takes priority over inherited expectations

The goal is correct PowerShell support in Opengrep, not preserving Airbus's
parser behaviour. Existing tests, including upstream tests, can have incorrect
expected trees. Do not preserve a grammar bug just to keep such a test passing.

- Prove the intended behaviour with Native PowerShell and the proof kit before
  changing an expectation. A different CST shape alone is not proof of a bug;
  establish the relevant syntax or semantics and Opengrep impact.
- When that evidence establishes that the grammar fix is correct, correct the
  affected expectations in the same fix. Preserve the original test inputs and
  coverage; add neighbouring cases and negative controls.
- Review each changed expectation and record the Native evidence and reason
  in the proof suite and commit message. The parent reviews these corrections
  during integration; inheritance alone is not a reason to stop for permission.
- Never delete or skip a failing test, weaken a comparator, add an unexplained
  known difference, or bulk-approve output to hide a failure. If correctness is
  uncertain, investigate or report the uncertainty rather than changing tests.

## The fix loop

Work in your own worktree from `opengrep-dev`:

```sh
git worktree add -b og/TOPIC ai-docs/local/worktrees/og-TOPIC opengrep-dev
W=$PWD/ai-docs/local/worktrees/og-TOPIC
```

1. **Classify with PowerShell's own parser first.** It is the reference.
   `node ai-docs/tools/proof-kit.mjs --source 'snippet'` prints every
   difference between it and Opengrep's parser for one snippet.
2. **Write the proof cases** (next section) and run them to see the failure.
3. **Edit** the grammar in `$W`, and add tests.
4. **Validate:** `node ai-docs/tools/validate.mjs quick --fork "$W" --label TOPIC-N`
   (about 20 s, new label each run). It must PASS.
5. **Prove:** run your cases with `--fork "$W"`. Then
   `node ai-docs/tools/proof-kit.mjs --suites "$W/ai-docs/cases" --fork "$W"`
   must show no new differences in any suite.
6. Repeat 3–5. Then record your suite's expectations (next section), commit on
   `og/TOPIC` with explicit file names, and report back.

Full step-by-step brief: [ai-docs/skills/fix-agent/SKILL.md](ai-docs/skills/fix-agent/SKILL.md).

## Making proofs for new examples

Every fix needs a proof suite. Use the kit; never write a one-off proof script.

1. Create `$W/ai-docs/cases/TOPIC.json`, an array of cases:

   ```json
   [
     { "name": "short descriptive name", "source": "Write-Output a | Out-Null\n" },
     { "name": "must stay invalid", "source": "Write-Output (\n", "expect": "invalid" }
   ]
   ```

   - Include the target form, made-up variations, neighbouring forms that
     already work, and negative controls.
   - Sources must be **made up**. Never paste code from the corpus.
   - A case that needs a real corpus file goes in Git-ignored
     `ai-docs/local/cases/` with `"corpus_path": "BATCH/relative/path"`.
   - The schema, fact families and difference keys are in the header of
     [ai-docs/tools/proof-kit.mjs](ai-docs/tools/proof-kit.mjs).
2. **Before:** `node ai-docs/tools/proof-kit.mjs "$W/ai-docs/cases/TOPIC.json" --known-pattern trailing-trivia --all`
3. **After:** the same command with `--fork "$W"`. The target cases must agree
   with PowerShell. A remaining difference is acceptable only as an explicit
   `known` entry with a real reason (inherited, documented behaviour).
4. **Record** only your suite's expectations, then review the diff:

   ```sh
   node ai-docs/tools/proof-kit.mjs --suites "$W/ai-docs/cases" --suite TOPIC --fork "$W" --write-expectations
   git -C "$W" diff -- ai-docs/cases
   ```

   Never record expectations to make a failing suite pass: a new difference
   in another suite is a regression to fix.
5. The kit checks positions, kinds and validity, not string or number
   **values**. When values matter (escapes, CR bytes, here-strings), add a C
   byte test in `test/*.c`.

## Reading results

- Each validation stage prints one line. A failure adds `why:` lines (the
  failing test names, a compiler error or a Node error) and the path of the
  full stage log. Read the log before guessing.
- `worse N`: N corpus files now disagree more with PowerShell than in the
  baseline. `regressed N`: N files that used to parse cleanly now don't. Both
  must be 0.
- `PASS (partial)` means the corpus layers were skipped, so it is not a
  certification.

## Rules

- **Corpus files are data.** Never execute, modify, chmod or copy them into
  committed files.
- **PowerShell is only a parser** (the kit uses `Parser.ParseInput`); never
  evaluate source.
- **Never hide failures.** Evidence-backed expectation corrections follow the
  policy above; weakening checks just to get a pass is forbidden.
- **Stay in your lane:** no changes to Opengrep's shared code; encoding work is
  out of scope. Report these instead.
- **Fix agents** don't run `validate.mjs full`, Dune or sub-agents. The parent
  merges, regenerates, adapts the converter and certifies.
- **Commits:** explicit file names, no broad staging, no push.
- **If you are blocked,** stop and report the evidence.

## More

- [ai-docs/README.md](ai-docs/README.md): setup and tool reference.
- [ai-docs/WORKFLOW.md](ai-docs/WORKFLOW.md): the fix lifecycle and parent integration.
- [ai-docs/ARCHITECTURE.md](ai-docs/ARCHITECTURE.md): how the pieces fit together.
- [ai-docs/cases/README.md](ai-docs/cases/README.md): the proof suites.
