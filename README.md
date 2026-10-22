# tree-sitter-powershell

Powershell grammar for [tree-sitter](https://github.com/tree-sitter/tree-sitter)

## Slash-leading command names

Command names can begin with `/`, including `/opt/tools/example`, `/`, `//`
and `///`. In command position, `//` is a command, not a comment. Slash paths
can contain quoted segments or backtick-escaped characters, and can appear
in pipelines, assignment values, hashtable values and invocation with `.` or
`&`. Relative `./` and `../` prefixes remain part of the command name rather
than a dot-invocation operator.
Invoked path pieces must be adjacent, so a quoted or escaped piece remains in
the command name while the next space-separated argument stays separate.

This does not introduce slash paths into expression-only positions or change
division (`8 / 2`, `$left/$right`) or compound division (`$value /= 2`).
The synthetic `absolute_command_paths` corpus covers these boundaries,
including redirection and paths containing quoted or escaped pieces.

## References

* [Powershell 7.3](https://learn.microsoft.com/en-us/powershell/scripting/lang-spec/chapter-15?view=powershell-7.3)