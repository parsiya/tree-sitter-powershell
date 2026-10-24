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

## Grammar-author tips for every fix
Workers must read this section before editing grammar or scanner code.
Condensed from Tree-sitter's
[Tips and Tricks for a grammar author](https://github.com/tree-sitter/tree-sitter/wiki/Tips-and-Tricks-for-a-grammar-author/).
Apply locally while fixing syntax; leave unrelated optimization to an approved
grammar review.

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
	OCaml CST types. Preserve unaffected valid trees, test intended syntax
	changes, and report converter impact for parent integration.
- Regenerate and measure after each extraction. Refactoring can increase
	states; try a different boundary or discard an unsuccessful experiment.
	Re-rank all rules afterwards: factoring one rule can reduce other rules'
	states too. In the wiki's tree-sitter-c v0.20.5 example, total/large states
	went from 2243/666 to 2048/610 after the `for` extraction, then to 1825/510
	after typedef factoring. These are examples, not targets or guarantees.
- Measure the transformed ABI14 parser, not just the 0.22 source grammar.
	Opengrep's `simplify` (`Missing_node`) preserves inline regexes, `token()`
	and `token.immediate()` as named aliases. In branching or widely reused
	rules, those aliases can multiply ABI14 states without showing comparable
	growth in the 0.22 parser. Giving a token its own rule can avoid that cost;
	verify tree and converter effects rather than applying this blindly.

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
from the workspace root; cloning is optional, not a fix prerequisite.

## Deterministic optimization checks
Use the existing quick-run scratch outputs; do not regenerate root files.
Keep generator version (0.22.6), ABI14, grammar transformation and input bytes
fixed when comparing base and candidate.

- Compare `STATE_COUNT`, `LARGE_STATE_COUNT`, `SYMBOL_COUNT`,
	`PRODUCTION_ID_COUNT` and byte size of `compat-abi14/src/parser.c` in each
	quick run. State counts and size are repeatable; parse timings are noisy.
- Use state reports and `tree-sitter generate --log` for state splitting,
	extracted keywords and recovery-token diagnostics. Investigate warnings
	about unnecessary conflicts and unused rules; do not delete declarations
	without testing. The generator already optimizes parse tables, but does
	not automatically rewrite the grammar for you.
- Use `tree-sitter parse --debug FILE` for lexing/parsing decisions and
	`--debug-graph` for Graphviz stack/tree traces when investigating branching.
	Run small synthetic reproductions with the candidate parser in scratch.
	Check the pinned CLI's `--help`; newer documented options may not exist.
- Use quick validation and proof suites for regressions. For behavior-neutral
	optimization, follow the review prompt's complete tree-identity gate;
	the parent checks generated `CST.ml` with source/compat validation.
- Compare repeated base/candidate `ts_ms` totals on the same idle machine.
	Fewer states do not prove faster parsing. Do not make timing a deterministic
	pass/fail gate or broaden a syntax fix into a benchmarking project.

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

## Record blockers as they are found

Record each real blocker in the campaign blockers log
(`artifacts/powershell-recon/CAMPAIGN-BLOCKERS.md` in the Opengrep checkout)
as soon as it is found, before continuing independent work: preflight
deferrals, worker-reported blockers, process breaches and validation
failures. Do not batch them for the end of the batch; update an entry when its
status changes.

## Quarantine packages that block a passing run

When a package blocks a passing full run for a reason outside the grammar
batch (NUL/encoding, resource limits, smoke-verifier or engine limits,
Native-invalid source losing findings), move its whole package folder,
byte-identical, out of the tested batches into a new quarantine batch after
the last extracted batch (for example `extracted/batch-069`), which is not
linked into `ai-docs/local/corpus/`. Record each moved package, its original
batch, the reason and its file hashes before and after the move in the
campaign blockers log. Never edit, split or drop files. After each move,
rerun the affected batch's checks (grammar, corpus and smoke) and record the
result with the blocker entry; a batch is clear only when that rerun passes.
Then rerun full validation
on the remaining batches; if that drops files from the baseline, promote a
fresh passing run and keep the old baseline in history. Quarantined packages
stay open blockers.

Keep all checks and full JSON
reports, but use compact console output. Do not add process, scripts or reports
unless required to fix the batch or explicitly requested.
