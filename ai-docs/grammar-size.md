# Grammar size

ABI14 parser Opengrep uses (`opengrep/ocaml/lib/parser.c`). See
[WORKFLOW.md](WORKFLOW.md#grammar-size-check-after-each-batch) for when to run
a grammar review.

| Date | After | Grammar commit | States | `parser.c` bytes | Note |
| --- | --- | --- | ---: | ---: | --- |
| 2026-10-23 | batch-003 | `90ecb7a` | 5551 | 13820231 | review (starting point; no review done yet) |
| 2026-10-23 | batch-004 | `3812529` | 6864 | 16846988 | +24% states; review due before batch-005 |
| 2026-10-23 | batch-004 | review of `2f8d138` | 5931 | 14155881 | review: inline tokens named as rules (for newline, keyword-dash command names, unary keyword operators, `$`/`@` variables), duplicate rules removed, chain comments, scanner tidy; −13.6% states |
