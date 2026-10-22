# tree-sitter-powershell

Powershell grammar for [tree-sitter](https://github.com/tree-sitter/tree-sitter)

## Escaped command names

Ordinary command names can begin with a backtick-escaped character. For example,
`` `$example.Name = `$example.Name `` is a command named `$example.Name`, not
an assignment. The `command_name` node retains the original spelling, including
escapes and adjacent quoted pieces. Escape decoding is left to consumers:
`` Wri`te-Output `` contains a tab, not the name `Write-Output`.

At a token boundary, backtick-escaped whitespace is trivia. Inside an already
started name, it is part of the name. An attached backtick-LF retains a literal
LF; an attached backtick-CRLF escapes the CR while the LF still ends the
statement. Space-separated backtick-LF/CRLF remains continuation trivia.
Unicode `` `u{...} `` escapes stay together, including their braces.

## References

* [Powershell 7.3](https://learn.microsoft.com/en-us/powershell/scripting/lang-spec/chapter-15?view=powershell-7.3)