# tree-sitter-powershell

Powershell grammar for [tree-sitter](https://github.com/tree-sitter/tree-sitter)

## Adjacent command arguments

In argument mode, a completed expression can end an argument without whitespace.
For example, `Write-Output $($left)$($right)""` has three arguments, as does
`Write-Output "prefix"$item.Version"suffix"`. Members, indexes and method calls
remain part of their receiver expression.

This differs from an embedded subexpression in an unquoted word:
`Write-Output pre$($left)tail` and `Write-Output $left$($right)tail` each have
one expandable argument. Their embedded subexpressions remain visible inside
`generic_token` nodes. Adjacency does not extend expression mode:
`$result = $($left)$($right)` is invalid.

Synthetic CST regressions and boundary controls are in
`test/corpus/completed_expression_arguments.txt`.

## References

* [Powershell 7.3](https://learn.microsoft.com/en-us/powershell/scripting/lang-spec/chapter-15?view=powershell-7.3)