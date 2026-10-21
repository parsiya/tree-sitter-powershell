# tree-sitter-powershell

Powershell grammar for [tree-sitter](https://github.com/tree-sitter/tree-sitter)

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

## Command parameters

Named command parameters accept Unicode letters in the basic multilingual plane,
including Unicode 16 letters: `New-Image -提示词 $value`. Unlike variable names,
parameter names can contain combining marks and symbols after the first letter.
A colon introduces an attached argument, as in `-提示词:$value`.
The joined-word scanner uses the checked-in `src/parameter_letters.h` to
recognize the same parameter starts without relying on the process locale.
Regenerate it after changing parameter-name rules:
`node scripts/generate-parameter-letters.mjs`.

## References

* [Powershell 7.3](https://learn.microsoft.com/en-us/powershell/scripting/lang-spec/chapter-15?view=powershell-7.3)