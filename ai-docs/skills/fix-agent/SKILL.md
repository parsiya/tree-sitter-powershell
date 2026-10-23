---
name: fix-agent
description: Fix one assigned PowerShell grammar root cause in an isolated og/TOPIC worktree, test it with the existing tools, and return the branch to the parent.
---

# Fix one grammar failure

The parent supplies the topic, grammar root, failing file/offset or reproduction,
and scope. Work only in your assigned worktree:

```sh
W="$GRAMMAR/ai-docs/local/worktrees/og-TOPIC"
git -C "$GRAMMAR" worktree add -b og/TOPIC "$W" opengrep-dev
```

Run tools from `$GRAMMAR`, pointing `--fork` at your worktree.

1. Make a small synthetic reproduction and check Native with
   `node ai-docs/tools/proof-kit.mjs --source 'snippet'`.
2. Add a focused `ai-docs/cases/TOPIC.json` and grammar regression test.
   Include nearby valid/invalid controls; expand only when failures require it.
3. Fix the grammar/scanner. Run the topic's proof before broader checks:

   ```sh
   node ai-docs/tools/proof-kit.mjs "$W/ai-docs/cases/TOPIC.json" --fork "$W" --known-pattern trailing-trivia
   node ai-docs/tools/validate.mjs quick --fork "$W" --label TOPIC-N
   ```

4. Iterate until the target agrees with Native and quick passes without regressions.
5. Record only reviewed expectations for your suite:
   `node ai-docs/tools/proof-kit.mjs --suites --suite TOPIC --fork "$W" --write-expectations`.
   Inspect the expectation changes, run
   `node ai-docs/tools/proof-kit.mjs --suites --fork "$W"` once, then commit
   explicit files without a co-author trailer.

Existing expectations may be corrected when Native evidence proves them wrong.
Never delete/skip tests or weaken checks. Add C byte/value tests when those matter:
the proof kit compares validity, kinds and extents, not literal values.

Corpus files are read-only; never execute them or copy their code into tests.
Do not edit generated files, tools, the parent checkout or other worktrees.
No Dune, full validation, nested agents or pushes. Parent handles converter integration.

Return at most five lines: branch/commit, targeted result, quick/suite result,
converter impact, and unresolved blocker. If blocked, preserve the work and
report the exact failure; do not start a separate investigation project.
