# tree-sitter-powershell

Powershell grammar for [tree-sitter](https://github.com/tree-sitter/tree-sitter)

Unbraced variable names support Unicode letters and decimal digits in the basic
multilingual plane, as PowerShell's UTF-16 character classification does.
Combining marks, other number categories, and supplementary-plane characters
require braced names (`${...}`). Function names also support Unicode.

## References

* [Powershell 7.3](https://learn.microsoft.com/en-us/powershell/scripting/lang-spec/chapter-15?view=powershell-7.3)