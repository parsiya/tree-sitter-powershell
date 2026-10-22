# tree-sitter-powershell

Powershell grammar for [tree-sitter](https://github.com/tree-sitter/tree-sitter)

String delimiters follow PowerShell's native quote families: ASCII `'` and
U+2018–U+201B are single quotes; ASCII `"` and U+201C–U+201E are double quotes.
Opening, closing and doubled quotes may mix within a family, including
here-string delimiters. U+201F is ordinary text, not a quote delimiter.
Quoted pieces within a command word remain part of that word; a leading
quoted argument remains separate from an adjacent argument.

## References

* [Powershell 7.3](https://learn.microsoft.com/en-us/powershell/scripting/lang-spec/chapter-15?view=powershell-7.3)