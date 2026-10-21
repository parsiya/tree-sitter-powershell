# tree-sitter-powershell

Powershell grammar for [tree-sitter](https://github.com/tree-sitter/tree-sitter)

## Command arguments

Percentage arguments such as `300%` and `-100%` are parsed as unquoted words,
including in comma-separated argument lists. In expressions, `%` remains the
remainder operator; ordinary negative numbers and numeric suffixes retain their
existing syntax trees.

## References

* [Powershell 7.3](https://learn.microsoft.com/en-us/powershell/scripting/lang-spec/chapter-15?view=powershell-7.3)