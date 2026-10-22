# tree-sitter-powershell

Powershell grammar for [tree-sitter](https://github.com/tree-sitter/tree-sitter)

Parameter blocks do not need a newline or semicolon before their body:
`function Example { param([string]$Message) Write-Output $Message }`.
Ordinary separators between subsequent statements are still required.

## References

* [Powershell 7.3](https://learn.microsoft.com/en-us/powershell/scripting/lang-spec/chapter-15?view=powershell-7.3)