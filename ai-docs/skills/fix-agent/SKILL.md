---
name: fix-agent
description: Fix one root cause in the PowerShell grammar that Opengrep uses, in an og/TOPIC worktree of the grammar repository, prove it against PowerShell's own parser with the ai-docs tools, and hand back a verified branch. Use when a parent assigns a single grammar or scanner fix.
---

# Fix agent: one PowerShell grammar fix for Opengrep

The parent fills in the TOPIC block and gives you this brief. It is
self-contained. Background: [ARCHITECTURE.md](../../ARCHITECTURE.md) and
[WORKFLOW.md](../../WORKFLOW.md).

## TOPIC (parent fills in)

- Topic slug: `TOPIC` (branch `og/TOPIC`)
- Root cause to fix, with Native evidence or offsets:
- Corpus files and offsets involved (read-only):
- Out of scope / known related issues:

## Goal

Fix one root cause in the PowerShell grammar **that Opengrep uses**, in your own
worktree, and hand back a verified branch. The parent integrates: it merges,
regenerates, adapts the converter and certifies.

That grammar is generated from the root `grammar.js`, `src/scanner.c` and
`src/parameter_letters.h`, plus `opengrep/grammar.cjs` for rule syntax only. It
runs as the simplified ABI 14 parser on tree-sitter 0.22.6. Airbus compatibility
does not matter: make no standalone Airbus proofs.

## Setup

```sh
OPENGREP=/path/to/opengrep
GRAMMAR=$OPENGREP/languages/powershell/tree-sitter/opengrep-powershell
W=$GRAMMAR/ai-docs/local/worktrees/og-TOPIC
git -C "$GRAMMAR" worktree add -b og/TOPIC "$W" opengrep-dev
```

Run every tool from `$GRAMMAR` (`cd "$GRAMMAR"` in each command; every tool call
may be a fresh shell). Its `ai-docs/local/` holds the configuration, downloads,
corpus and baseline. Point the tools at your worktree with `--fork "$W"`.
The tools source the build environment themselves when `local/config.json` sets
`buildEnv`.

## Loop

1. **Classify with Native first.** Write `$W/ai-docs/cases/TOPIC.json`.
   - Include made-up reductions, negative controls (forms that must stay
     invalid or unchanged) and neighbouring forms that already work.
   - Cases are `{name, source, expect?, facts?, known?, known_patterns?}`; the
     schema and difference keys are in the header of `ai-docs/tools/proof-kit.mjs`.
   - Committed cases are synthetic only. A case that needs a real corpus file
     goes in `$GRAMMAR/ai-docs/local/cases/TOPIC.json` with
     `"corpus_path": "BATCH/relative/path"`.
   - Run it on the current parser to see the failure:

     ```sh
     node ai-docs/tools/proof-kit.mjs "$W/ai-docs/cases/TOPIC.json" --known-pattern trailing-trivia \
       --out ai-docs/local/results/proof-kit/TOPIC-before.json
     ```

2. **Edit** only `grammar.js`, `src/scanner.c` or `src/parameter_letters.h` in
   `$W`. Pattern-only syntax goes in `opengrep/grammar.cjs`. Never edit generated
   files, and do not regenerate the root `src/parser.c`.
3. **Add tests.** Append new cases to `test/corpus/*.txt`; inherited cases stay
   byte for byte. Expected-error cases must really fail. Add a C test in
   `test/*.c` when exact bytes or values matter (CR handling, string values):
   the kit compares extents and kinds, not values.
4. **Quick validation** (use a new label each run):

   ```sh
   node ai-docs/tools/validate.mjs quick --fork "$W" --label TOPIC-N
   ```

   It must PASS: inherited cases intact, 0.22 tests, ABI 14 C tests, raw corpus
   parse `regressed 0`, grammar harness `worse 0`. Read `moves` and `improved`:
   they should be your target files.
5. **Proof.**

   ```sh
   node ai-docs/tools/proof-kit.mjs "$W/ai-docs/cases/TOPIC.json" --fork "$W" --known-pattern trailing-trivia \
     --out ai-docs/local/results/proof-kit/TOPIC-after.json
   node ai-docs/tools/proof-kit.mjs --suites --fork "$W"
   ```

   Target cases must agree. The suites must pass (improvements are fine). Any
   remaining difference needs an explicit `known` entry with a real reason (an
   inherited, documented behaviour), never just to make the run pass.
6. Repeat 2–5 until done.
7. **Record expectations.** Once step 5 passes:

   ```sh
   node ai-docs/tools/proof-kit.mjs --suites "$W/ai-docs/cases" --fork "$W" --write-expectations
   git -C "$W" status --short ai-docs/cases
   git -C "$W" diff -- ai-docs/cases
   ```

   Review every changed line: only your new suite and improvements may appear.
8. **Commit** on `og/TOPIC` in `$W`. Name the files explicitly (no
   `git add -A`), write a descriptive message (what PowerShell accepts, what the
   grammar did, the evidence) and add no co-author trailer.

## Report back (at most 30 lines)

- Branch and commit hash; the files changed.
- The proof-kit summary lines before and after (paths to both reports) and the
  `--suites` result.
- The final `validate.mjs quick` summary block.
- Grammar `moves` and raw-parse `improved`/`changed` lists.
- Expected converter impact (new or renamed CST nodes). The parent changes the
  converter, not you.
- Anything unresolved, with evidence.

## Hard rules

- The corpus is read-only **data**: never execute, modify, `chmod` or copy it
  into committed fixtures. Use made-up reductions.
- Use PowerShell only as a parser (the kit's `Parser.ParseInput`); never
  evaluate source.
- Write only in `$W` and in the run and report folders the tools create under
  `$GRAMMAR/ai-docs/local/` (plus your `local/cases/TOPIC.json`). Do not touch
  `opengrep-dev`, the Opengrep checkout, other worktrees, baselines or the
  tools. Do not push.
- No Dune and no `validate.mjs full` (the parent runs it). No sub-agents.
- Never weaken a test, comparator or expectation, and never approve outputs to
  hide a failure. Correcting an inherited expectation needs Native evidence and
  a stop to ask the parent.
- Shared Opengrep code changes and encoding work are out of scope: report them.
- If you are blocked, stop and report the evidence; do not work around it.
