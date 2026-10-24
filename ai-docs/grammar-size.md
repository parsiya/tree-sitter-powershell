# Grammar size

ABI14 parser Opengrep uses (`opengrep/ocaml/lib/parser.c`). See
[WORKFLOW.md](WORKFLOW.md#grammar-size-check-after-each-batch) for when to run
a grammar review.

| Date | After | Grammar commit | States | `parser.c` bytes | Note |
| --- | --- | --- | ---: | ---: | --- |
| 2026-10-23 | batch-003 | `90ecb7a` | 5551 | 13820231 | review (starting point; no review done yet) |
| 2026-10-23 | batch-004 | `3812529` | 6864 | 16846988 | +24% states; review due before batch-005 |
| 2026-10-23 | batch-004 | review of `2f8d138` | 5931 | 14155881 | review: inline tokens named as rules (for newline, keyword-dash command names, unary keyword operators, `$`/`@` variables), duplicate rules removed, chain comments, scanner tidy; −13.6% states |
| 2026-10-23 | batch-005 | sources of `099dfda` | 5943 | 14166361 | +0.2% states since the review |
| 2026-10-23 | workflow support | sources of `458ed5a` | 5945 | 14132308 | +0.2% states since the review; `InlineScript` is a command |
| 2026-10-23 | batch-006 | sources of `6f4108a` | 6041 | 14900670 | +1.9% states since the review; certification blocked by batch-004 invalid-input smoke finding loss |
| 2026-10-23 | batch-007 | sources of `287171e` | 7546 | 17609037 | +27.2% states since the review; separate grammar review recommended, not started |
| 2026-10-23 | batch-008 | sources of `ba8265885` | 8796 | 21925791 | Shared batches 008-020 integration; +48.3% since review; separate review recommended, not started |
| 2026-10-23 | batch-009 | sources of `ba8265885` | 8796 | 21925791 | Shared integration; generic rule chain copied; review recommended |
| 2026-10-23 | batch-010 | sources of `ba8265885` | 8796 | 21925791 | Shared integration; NUL source and smoke-report-size blockers remain |
| 2026-10-23 | batch-011 | sources of `ba8265885` | 8796 | 21925791 | Shared integration; deferred resource blocker remains |
| 2026-10-23 | batch-012 | sources of `ba8265885` | 8796 | 21925791 | Shared integration; +48.3% since review |
| 2026-10-23 | batch-013 | sources of `ba8265885` | 8796 | 21925791 | Shared integration; parenthesized finding fails smoke verifier |
| 2026-10-23 | batch-014 | sources of `ba8265885` | 8796 | 21925791 | Shared integration; +48.3% since review |
| 2026-10-23 | batch-015 | sources of `ba8265885` | 8796 | 21925791 | Shared integration; parenthesized finding fails smoke verifier |
| 2026-10-23 | batch-016 | sources of `ba8265885` | 8796 | 21925791 | Shared integration; +48.3% since review |
| 2026-10-23 | batch-017 | sources of `ba8265885` | 8796 | 21925791 | Shared integration; +48.3% since review |
| 2026-10-23 | batch-018 | sources of `ba8265885` | 8796 | 21925791 | Shared integration; HPE resource blockers remain |
| 2026-10-23 | batch-019 | sources of `ba8265885` | 8796 | 21925791 | Shared integration; deferred resource blocker remains |
| 2026-10-23 | batch-020 | sources of `ba8265885` | 8796 | 21925791 | Shared integration; certification blocked; no baseline promotion |
| 2026-10-23 | batches 001-020 | review of `1b8d5c2` | 8649 | 21608112 | review: declaration keyword tokens and real-number token; -147 states (-1.67%), -317679 bytes (-1.45%); behavior unchanged; existing smoke verifier blocker remains |
| 2026-10-23 | batches 021-040 | sources of `ab5607955` | 9267 | 23077037 | Shared integration; +7.1% since review; `_adjacent_dash_colon_arguments` copies `_adjacent_angle_arguments`; review recommended |
| 2026-10-23 | batches 041-050 | sources of `db999e2` | 9353 | 23347616 | Shared integration; +8.1% since review; no new rule chain copied; earlier review recommendation stands |
| 2026-10-24 | batches 001-050 | review of `4d9471c` | 9317 | 23264331 | Shared named string tokens; -36 states (-0.38%), -83285 bytes (-0.36%); descriptive converter constructors |

## Review of `4d9471c`
Named eight string-token rules and reused identical immediate dollar and
double-quote tokens across strings and command names. Kept ordinary and
nested-string branches separate, with unchanged regexes, precedence and
scanner behavior. Explicit dollar aliases preserve anonymous leaves.
Generated OCaml bindings use descriptive constructors; converter changes
only rename matches. Large states remain 2791, symbols 626; production IDs
decrease from 201 to 189. Parse speed was not benchmarked.

Quick validation passes 2104 grammar tests and 6 ABI14 C tests. All 149156
category/problem results and 123 proof-suite outcomes match unchanged base.
Full-tree comparison covers 158056 readable files, including 35 with
non-UTF-8 filenames: no valid-tree changes, 1839 permitted recovery-only
changes, source hashes unchanged. Paths and evidence are linked in
`ai-docs/local/results/grammar-review.md`; no expectations changed.

Integrated source, compatibility, build and unit checks pass (306 tagged /
181 substring tests). Full run `review-string-full-20261024` passes all
stages, including corpus conversion and byte-checked smoke scans across
50 batches. Batches 001-040 have zero corpus regressions and unchanged
smoke finding/error keys against the promoted baseline; batches 041-050
pass checks but have no promoted baseline comparison. Existing deferred
issues remain. Validation ran before committing; no baseline was promoted.

## Review of `1b8d5c2`
Only declaration keyword tokens (N1) and the numeric part of N2 were approved.
Naming `function`, `filter`, and `workflow` saves 105 states and 188161 bytes;
naming the internal real-number token saves another 42 states and 129518 bytes.
Scanner code, external-token order, regexes and language behavior are unchanged.
Regenerated OCaml types require three converter constructor-match renames.

Each change passed quick validation (2083 grammar tests, 6 ABI14 C tests),
80406 per-file category/problem comparisons and all 109 proof-suite outcome
comparisons against unchanged base. All 84009 readable corpus trees are
identical, including errors and 33 files with non-UTF-8 filenames checked via
raw filename bytes. Input hashes remained unchanged; no expectations changed.

Integrated run `review-n1-n2-full-20261023` passes source, compatibility,
grammar, build, unit (301 tagged / 176 substring) and corpus stages. All 20
corpus batches retain the clean base's categories; smoke finding/error keys
match for batches 001-009. Batch-010's smoke verifier crashes reading its
692140582-byte JSON report, as in clean-base run `b620-committed-20261023`.
Later smoke batches are not reached. Full certification remains blocked and
no baseline is promoted. Parse timings do not establish a speedup.
