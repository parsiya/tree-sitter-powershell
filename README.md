# tree-sitter-powershell

Powershell grammar for [tree-sitter](https://github.com/tree-sitter/tree-sitter)

Simple names (including unquoted hashtable keys, members, class/enum names and
named attribute arguments) accept BMP Unicode letters and underscores, followed
by BMP letters, decimal digits or underscores. As in PowerShell, combining marks,
other numeric categories and supplementary-plane letters are not simple-name
characters. Quoted keys and members are unchanged.

## References

* [Powershell 7.3](https://learn.microsoft.com/en-us/powershell/scripting/lang-spec/chapter-15?view=powershell-7.3)