# Synthetic case suites

Each `SUITE.json` here is a list of proof-kit cases (schema: header of
`../tools/proof-kit.mjs`) that compares the parser Opengrep uses with
PowerShell's own parser, at exact byte offsets. Every suite reduces one grammar
fix or investigation (CR statement boundaries, smart quotes, numeric dash
words, ...). `SUITE.expected.json` records that suite's current result.

## Rules

- **Synthetic only.** Committed cases are made-up `source` snippets (plus two
  byte fixtures in `proof-kit-selftest/`, and a few of Opengrep's own
  `tests/` files inlined under their repository names). Never commit code
  from the PowerShell Gallery or any other corpus, not even short excerpts:
  write a reduction with invented names and values instead.
- **Corpus cases stay local.** Cases that need a real corpus file go in the
  Git-ignored `../local/cases/SUITE.json` (same schema), using
  `"corpus_path": "BATCH/relative/path"` (resolved against the corpus root from
  `../tools/config.mjs`) or `path_bytes_base64` for a non-UTF-8 file name
  (resolved against the cases file). Their expectations live next to them.

## Run

```sh
node ai-docs/tools/proof-kit.mjs --suites
```

Runs every suite here and, when present, every suite in `ai-docs/local/cases`
(reported separately), always with `--known-pattern trailing-trivia`. Add
`--fork WORKTREE` (or `--parser-dir DIR`) to test a grammar change, or pass
folders to run other suites. A suite passes when no case has a difference
that is not in its expectation and no case status got worse; recorded
differences that disappear and better statuses are reported as improvements.
Exit 0 = every suite matches, 1 = a suite fails, 2 = usage or build error.

## Update expectations (deliberately)

Tree-sitter corpus expectations, including Airbus's originals, can be wrong.
Correct them when Native evidence establishes that the grammar fix is right;
preserve their inputs and coverage. See
[the workflow policy](../WORKFLOW.md#correcting-an-existing-test-expectation).
The proof-kit expectations below record comparisons with Native, not an
alternative authority for PowerShell behaviour.

Expectations are never updated automatically. After a reviewed grammar change
(or when adding a suite or case):

```sh
node ai-docs/tools/proof-kit.mjs --suites --suite NAME --write-expectations   # only NAME
git diff ai-docs/cases/*.expected.json   # one line per case: review every change
```

Commit the expectation changes with the grammar change that caused them.

## Invocation member command names

`member-command-names` checks expression command names after `.` and `&`,
including member chains, calls, indexes, adjacent arguments, real paths and
invalid controls. Native classifies `. $_.FullName; & $item.Path` as member
expressions at bytes 2:13 and 17:27, not expandable path text. This also proves
the correction to the inherited `expressions.txt` expectation: its receiver
and property must remain visible to Opengrep's matching and taint conversion.

The `parameter-dot` tab-separated `.$value` control retains exactly its
inherited six differences, including the same missing command boundary.
Only the extra element's wrapper changes from
`command_name_expr>path_command_name>variable` to `command_name_expr>variable`;
the expectation retains the error and its original 22:28 extent.

The member suite documents independent inherited type-leading invocation
words, embedded path variables and invocation-mode nullable index words.
The last already had the same kind differences in the original ABI14 parser;
this fix removes its syntax rejection without claiming to fix those kinds.

## Counts

Migrated 2026-10-22 from 50 local case files (5,139 cases). Columns: original
cases, committed (after dropping exact duplicates, including new synthetic
reductions), duplicates dropped, moved to `local/cases` (gallery files),
excluded, new synthetic reductions. Suites without a name in code are not
committed (they became empty).

| Suite | Original | Committed | Duplicates | Local | Excluded | New |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `absolute-command-independent-blocker` | 2 | 2 | 0 | 0 | 0 | 0 |
| `absolute-command-native` | 25 | 25 | 0 | 0 | 0 | 0 |
| `absolute-command-quote-overlap` | 172 | 172 | 0 | 0 | 0 | 0 |
| `absolute-command-redirection-baseline` | 5 | 5 | 0 | 0 | 0 | 0 |
| `absolute-command-root` | 69 | 69 | 0 | 0 | 0 | 0 |
| `attributed-expressions` | 20 | 20 | 0 | 0 | 0 | 0 |
| `comma-continuation-native` | 17 | 17 | 0 | 0 | 0 | 0 |
| `comma-here-compat` | 13 | 12 | 0 | 1 | 0 | 0 |
| `comma-proof` | 110 | 108 | 1 | 3 | 0 | 2 |
| `command-parenthesis` | 88 | 87 | 0 | 1 | 0 | 0 |
| `command-parenthesis-lone-cr` | 4 | 4 | 0 | 0 | 0 | 0 |
| `command-parenthesis-native` | 11 | 11 | 0 | 0 | 0 | 0 |
| `completed-expression-combined` | 66 | 66 | 0 | 0 | 0 | 0 |
| `completed-expression-native` | 20 | 20 | 0 | 0 | 0 | 0 |
| `completed-expression-standalone` | 48 | 48 | 0 | 0 | 0 | 0 |
| `cr-statement` | 104 | 105 | 0 | 2 | 0 | 3 |
| `dash-argument-native` | 19 | 19 | 0 | 0 | 0 | 0 |
| `leading-command` | 138 | 137 | 1 | 0 | 0 | 0 |
| `leading-command-escape-native` | 21 | 21 | 0 | 0 | 0 | 0 |
| `leading-command-unicode-escape` | 5 | 5 | 0 | 0 | 0 | 0 |
| `leading-pipeline-native` | 17 | 17 | 0 | 0 | 0 | 0 |
| `leading-pipeline-proof` | 117 | 107 | 10 | 0 | 0 | 0 |
| `lone-cr-c-boundary` | 24 | 24 | 0 | 0 | 0 | 0 |
| `lone-cr` | 123 | 114 | 8 | 1 | 0 | 0 |
| `native-class` | 7 | 7 | 0 | 0 | 0 | 0 |
| `native-option` | 13 | 13 | 0 | 0 | 0 | 0 |
| `native-parser` | 55 | 55 | 0 | 0 | 1 | 1 |
| native-remaining | 307 | 0 | 0 | 307 | 0 | 0 |
| `native-trap` | 4 | 4 | 0 | 0 | 0 | 0 |
| `native-words` | 4 | 4 | 0 | 0 | 0 | 0 |
| nested-array-original-source | 2 | 0 | 0 | 2 | 0 | 0 |
| `nested-array-proof` | 84 | 83 | 1 | 0 | 0 | 0 |
| `nested-array-type-native` | 23 | 23 | 0 | 0 | 0 | 0 |
| `numeric-dash` | 185 | 152 | 32 | 1 | 0 | 0 |
| `numeric-dash-followup` | 199 | 161 | 37 | 1 | 0 | 0 |
| `param-block` | 32 | 32 | 0 | 0 | 0 | 0 |
| `parameter-dot` | 135 | 107 | 26 | 2 | 0 | 0 |
| `plus-argument-native` | 24 | 24 | 0 | 0 | 0 | 0 |
| `plus-command` | 50 | 50 | 0 | 0 | 0 | 0 |
| plus-original-file | 6 | 0 | 0 | 6 | 0 | 0 |
| `proof-kit-selftest` | 21 | 21 | 0 | 0 | 0 | 0 |
| proof-kit-selftest-wrong | 7 | 0 | 0 | 0 | 7 | 0 |
| `qualified-variable` | 290 | 285 | 4 | 1 | 0 | 0 |
| `remaining-native` | 27 | 27 | 0 | 0 | 0 | 0 |
| `smart-quote-native` | 65 | 65 | 0 | 0 | 0 | 0 |
| `smart-quote-proof` | 1665 | 1653 | 12 | 0 | 0 | 0 |
| `smart-quote-sequence` | 575 | 575 | 0 | 0 | 0 | 0 |
| `trailing-dot` | 103 | 99 | 3 | 1 | 0 | 0 |
| `using-variable-native` | 11 | 11 | 0 | 0 | 0 | 0 |
| `variable-suffix-native` | 7 | 7 | 0 | 0 | 0 | 0 |
| **Total** | **5,139** | **4,673** | **135** | **329** | **8** | **6** |

Excluded: one Opengrep test file whose line also occurs in the corpus (kept
locally as is), and the 7 cases of `proof-kit-selftest-wrong`, a kit
negative control in which every case is meant to fail.
