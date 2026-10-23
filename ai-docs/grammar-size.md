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
