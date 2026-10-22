# tree-sitter-powershell

Powershell grammar for [tree-sitter](https://github.com/tree-sitter/tree-sitter)

## String delimiters

String delimiters follow PowerShell's native quote families: ASCII `'` and
U+2018–U+201B are single quotes; ASCII `"` and U+201C–U+201E are double quotes.
Opening, closing and doubled quotes may mix within a family, including
here-string delimiters. U+201F is ordinary text, not a quote delimiter.
Quoted pieces within a command word remain part of that word; a leading
quoted argument remains separate from an adjacent argument.
Here-strings stop at the first closing-delimiter line, including when their
body is empty or contains only blank lines; subsequent statements stay separate.

## Command words

In command arguments, `generic_token` represents an entire unquoted word,
including adjacent variables and quoted pieces: `$root/path`, `appid=$id`,
`-o"$folder"` and `/name:"two words"`. Quoted pieces remain `string_literal`
children, and embedded `$()` remains a `sub_expression` child so nested
commands are visible in the syntax tree. Unquoted text and variables outside
quotes are available from the word's source text.

Standalone numbers, variables and expressions retain their expression nodes.
Bare command names are literal rather than expandable. A nonbreaking space
separates command words just like an ordinary space.

## Variable names

Unbraced variable names support Unicode letters and decimal digits in the basic
multilingual plane, as PowerShell's UTF-16 character classification does.
Combining marks, other number categories, and supplementary-plane characters
require braced names (`${...}`). Function names also support Unicode.

## Command arguments

Percentage arguments such as `300%` and `-100%` are parsed as unquoted words,
including in comma-separated argument lists. In expressions, `%` remains the
remainder operator; ordinary negative numbers and numeric suffixes retain their
existing syntax trees.

Completed expressions can end a command argument without whitespace:
`Write-Output $($left)$($right)""` has three arguments, as does
`Write-Output "prefix"$item.Version"suffix"`. Members, indexes and method calls
remain part of their receiver expression. By contrast, `pre$($left)tail` and
`$left$($right)tail` each remain one expandable word. Adjacency does not extend
expression mode: `$result = $($left)$($right)` is invalid.
Synthetic CST regressions and boundary controls are in
`test/corpus/completed_expression_arguments.txt`.

## Command parameters

Named command parameters accept Unicode letters in the basic multilingual plane,
including Unicode 16 letters: `New-Image -提示词 $value`. Unlike variable names,
parameter names can contain combining marks and symbols after the first letter.
A colon introduces an attached argument, as in `-提示词:$value`.
The joined-word scanner uses the checked-in `src/parameter_letters.h` to
recognize the same parameter starts without relying on the process locale.
Regenerate it after changing parameter-name rules:
`node scripts/generate-parameter-letters.mjs`.
The same header also derives variable-digit ranges from the grammar so Unicode
variable receivers remain expressions rather than being swallowed as words.

## Simple names

Simple names (including unquoted hashtable keys, members, class/enum names and
named attribute arguments) accept BMP Unicode letters and underscores, followed
by BMP letters, decimal digits or underscores. As in PowerShell, combining marks,
other numeric categories and supplementary-plane letters are not simple-name
characters. Quoted keys and members are unchanged.
Unicode class names also work in type references and base-class lists.
## Parameter blocks

Parameter blocks do not need a newline or semicolon before their body:
`function Example { param([string]$Message) Write-Output $Message }`.
Ordinary separators between subsequent statements are still required.

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