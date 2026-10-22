# tree-sitter-powershell

Powershell grammar for [tree-sitter](https://github.com/tree-sitter/tree-sitter)

## Line-boundary regression tests

The corpus tests use ordinary text files. `test/cr_statement_boundaries.c` also
checks literal CR, LF and CRLF command boundaries using escaped C strings, so Git
newline normalization cannot change the tested bytes. Its header documents the
build command. These tests check complete command extents, nested commands and
assignments, preserve CR inside quoted data, and retain Tree-sitter's LF-based
point coordinates.

## References

* [Powershell 7.3](https://learn.microsoft.com/en-us/powershell/scripting/lang-spec/chapter-15?view=powershell-7.3)