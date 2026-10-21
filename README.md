# tree-sitter-powershell

Powershell grammar for [tree-sitter](https://github.com/tree-sitter/tree-sitter)

Named command parameters accept Unicode letters in the basic multilingual plane,
including Unicode 16 letters: `New-Image -提示词 $value`. Unlike variable names,
parameter names can contain combining marks and symbols after the first letter.
A colon introduces an attached argument, as in `-提示词:$value`.

## References

* [Powershell 7.3](https://learn.microsoft.com/en-us/powershell/scripting/lang-spec/chapter-15?view=powershell-7.3)