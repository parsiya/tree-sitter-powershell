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
