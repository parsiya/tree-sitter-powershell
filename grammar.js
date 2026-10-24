const PREC = {
  KEYWORD: 1,
  UNARY: 2,
  CAST: 3,
  ELEMENT_ACCESS: 4,
  EMPTY: 5,
  PARAM: 6,
};

// Native quote families allow mixed opening, closing and doubled delimiters.
// U+201F is deliberately not a double-quote delimiter.
const SINGLE_QUOTE = /['\u2018-\u201B]/;
const DOUBLE_QUOTE = /["\u201C-\u201E]/;

// Keywords that start a statement and so need a command-name alternative.
const STATEMENT_KEYWORDS = [
  'break', 'continue', 'throw', 'return', 'exit', 'try', 'trap', 'if', 'function',
  'filter', 'workflow', 'switch', 'for', 'foreach', 'while', 'parallel', 'using',
  'begin', 'process', 'end', 'dynamicparam',
];

// Words that Native reads as a keyword only when no word character follows.
const ADJACENT_KEYWORDS = [...STATEMENT_KEYWORDS, 'clean', 'do', 'param', 'data'];

// Native operators accept en dash, em dash and horizontal bar for their dash.
const DASH = String.raw`[-\u2013-\u2015]`;

// Number suffixes are case-insensitive in PowerShell: 1KB, 1kb and 0X1F.
const NUMBER_MULTIPLIER = /[kKmMgGtTpP][bB]/;
const NUMBER_EXPONENT = /[eE][+-]?[0-9]+/;
// PowerShell 7 type suffixes: y, uy, s, us, u, l, ul, n, d (`d` is a digit in hex).
const NUMBER_TYPE_SUFFIX = /[yYsSlLnNdD]|[uU][yYsSlL]?/;
const HEX_TYPE_SUFFIX = /[yYsSlLnN]|[uU][yYsSlL]?/;

// Whitespace for class bodies: tree-sitter's \s is ASCII only, but Native
// PowerShell (Char.IsWhiteSpace) also accepts these Unicode spaces and NEL.
// U+FEFF, U+2060 and U+200B are not whitespace.
const WS = String.raw`\t-\r \u0085\u00a0\u1680\u2000-\u200a\u2028\u2029\u202f\u205f\u3000`;
// The same without line breaks or the ASCII space, for trivia that follows a
// separator.
const HSPACE = String.raw`\t\v\f\u0085\u00a0\u1680\u2000-\u200a\u2028\u2029\u202f\u205f\u3000`;

// Characters that cannot appear in the first part of a command name.
const COMMAND_NAME_STOP = `\\{\\}\\(\\);,\\|\\&\`"'\\u2018-\\u201E${WS}\\[\\]\\+\\-\\*\\/\\$@<\\!`;
const COMMAND_NAME_CONTINUATION = `[^\\{\\}\\(\\);,\\|\\&\`"'\\u2018-\\u201E${WS}]`;
// PowerShell tests UTF-16 characters with Char.IsLetterOrDigit, not Unicode
// identifier rules: combining marks and supplementary-plane letters end a name.
// Explicit letter ranges also cover tree-sitter 0.22's missing UnicodeData
// First/Last range interiors and the BMP letters added in Unicode 16.
const VARIABLE_NAME = new RegExp(
  String.raw`([^\P{L}\u{10000}-\u{10FFFF}]|[^\P{Nd}\u{10000}-\u{10FFFF}]|` +
  String.raw`[_\u1C89-\u1C8A\u3400-\u4DBF\u4E00-\u9FFF\uA7CB-\uA7CD\uA7DA-\uA7DC\uAC00-\uD7A3])+`,
  'u',
);

// Parameter names start with a BMP letter, not a digit or combining mark.
// Include Unicode 16 additions and the range interiors missing in tree-sitter 0.22.
const PARAMETER_LETTER =
  String.raw`([^\P{L}\u{10000}-\u{10FFFF}]|` +
  String.raw`[\u1C89-\u1C8A\u3400-\u4DBF\u4E00-\u9FFF\uA7CB-\uA7CD\uA7DA-\uA7DC\uAC00-\uD7A3])`;

// Unlike variable names, parameter names allow marks, symbols and digits after
// the first character. A colon ends the name and introduces an attached argument.
const PARAMETER_CHAR =
  String.raw`[^\x00\t-\r "'&(),.:;\[{}|\u0085\u00A0\u1680\u2000-\u200A\u2018-\u201E\u2028\u2029\u202F\u205F\u3000]`;

// Simple names start with a BMP letter or underscore; continuations also allow
// decimal digits. Include Unicode 16 letters and range interiors missing in CLI 0.22.
const SIMPLE_NAME_LETTER = new RegExp(PARAMETER_LETTER, 'u');
// CLR arities allow literal backticks (also doubled in PowerShell source).
// The initial type-name character is still restricted below.
const TYPE_IDENTIFIER = new RegExp('(' + VARIABLE_NAME.source + '|`)+', 'u');
// Assembly-qualified type names: `, Assembly[, Key = Value]...` up to the
// closing bracket. Native accepts empty parts and stray names after the
// assembly, but a part holds at most one `=` and no inner whitespace, and the
// specifier never crosses a line or contains brackets.
const ASSEMBLY_SPACE = String.raw`[\t\p{Zs}]`;
const ASSEMBLY_CHAR =
  String.raw`[^\x00\t-\r =,\[\]\u0085\u00A0\u1680\u2000-\u200A\u2028\u2029\u202F\u205F\u3000]`;
const ASSEMBLY_PART =
  `${ASSEMBLY_SPACE}*${ASSEMBLY_CHAR}*${ASSEMBLY_SPACE}*` +
  `(=${ASSEMBLY_SPACE}*${ASSEMBLY_CHAR}*${ASSEMBLY_SPACE}*)?`;
const ASSEMBLY_QUALIFIER = new RegExp(
  `,${ASSEMBLY_SPACE}*(${ASSEMBLY_CHAR}+${ASSEMBLY_SPACE}*(,${ASSEMBLY_PART})*|(,${ASSEMBLY_PART})+)`,
  'u',
);
const VARIABLE_REFERENCE = new RegExp(
  `${VARIABLE_NAME.source}(\\?|${VARIABLE_NAME.source})*`,
  'u',
);

export default grammar({
  name: 'powershell',

  externals: ($) => [
    $._statement_terminator,
    $._bare_dashes,
    // Never produced. It marks where an elseif or else clause can start, so
    // that the scanner can tell when a newline does not end the statement.
    $._else_clause_ahead,
    $._script_block_argument_start,
    $._spaces_before_comma,
    $._command_word_start,
    $._command_word_part,
    $._command_word_expression,
    $._quoted_argument_boundary,
    $._parameter_argument_separator,
    $._parameter_argument_start,
    $._colon_word_continuation,
    $._completed_expression_boundary,
    $._completed_member_boundary,
    $._error_sentinel,
    $._path_command_name_continuation,
    $._command_name_escape,
    $._trailing_dot_type_name,
    $._command_name_start_escape,
    $._command_array_item_start,
    $._parameter_dot_boundary,
    $._parameter_dot_literal_boundary,
    $._qualified_variable,
    $._qualified_variable_in_string,
    $._try_clause_ahead,
    $._numeric_command_name,
    $._trailing_dot_real_literal,
    $._variable_command_name_continuation,
    $._invocation_argument_boundary,
    $._variable_before_literal_dot,
    $._command_name_subexpression,
    $._angle_argument_boundary,
    // A UTF-8 BOM at the very start of the input (see scanner.c).
    $._leading_bom,
    $._string_subexpression_start,
    $._string_subexpression_end,
    $._quote_unit_open,
    $._quote_unit_close,
    $._quote_unit_escape,
    // Never produced. It marks the content of an expandable string, as opposed
    // to a here-string, so that the scanner can track its subexpressions.
    $._expandable_string_ahead,
    $._command_name_dollar,
    // The keyword `inlinescript`, whose script block must follow, possibly after
    // newlines. Only produced in a workflow body, where Native makes it a
    // keyword (see scanner.c).
    $._inlinescript_name,
    // Never produced as text. They mark the start of a function or workflow
    // body, and the end of any, so that the scanner knows the context.
    $._function_context_plain,
    $._function_context_workflow,
    $._function_context_end,
    // `:name` before a loop or switch keyword. Elsewhere Native reads a colon
    // word as an ordinary command word (see scanner.c).
    $.label,
    // Never produced as text. `break` and `continue` take no label from a
    // colon word: the word starts the next statement, with no terminator.
    $._flow_control_colon_word,
    // Empty token between a `-Name:` command name and a touching argument.
    $._dash_colon_argument_boundary,
    // At a command position `!word` is a command name, not a negation
    // (`if (!Test-Path $p)`); the scanner produces the `!` only before a
    // letter, `_` or `.`. `!1`, `!-x`, `!=` and `!$x` stay expressions.
    $._bang_command_name,
    // Empty token before a `(` that directly touches the preceding argument.
    $._adjacent_paren_boundary,
    // Empty token before the `:` of an enum base type, which must start on the
    // enum's line (see scanner.c).
    $._enum_base_colon_ahead,
  ],

  extras: ($) => [
    $.comment,
    /\s/,
    /`\n/,
    /`\r\n/,
    /`[ \t\v\f\r\u0085\u00a0\u1680\u2000-\u200a\u2028\u2029\u202f\u205f\u3000]/,
    // Unicode spaces. U+FEFF, U+2060 and U+200B are not whitespace in Native
    // PowerShell; a file's leading BOM is _leading_bom.
    new RegExp(String.raw`[${WS}]`),
    // Spaces before a comma (see scanner.c)
    $._spaces_before_comma,
  ],

  conflicts: ($) => [
    [$._literal, $.member_name],
    [$.class_property_definition, $.attribute],
    [$.class_method_definition, $.attribute],
    // Keep declaration attributes possible until their following keyword is known.
    [$.attributed_expression, $.attribute],
    [$.expandable_string_literal],
    [$.path_command_name, $._value],
    [$._command_argument, $.array_literal_expression],
    [$._command_array_tail, $._completed_argument_array],
    [$._command_expression_array, $._command_mixed_array, $._completed_argument_array],
    [$._command_mixed_array, $._completed_argument_array],
    [$._command_pipeline_prefix_expression, $._primary_expression],
    [$.array_literal_expression, $.range_argument_expression],
    [$.member_access, $._generic_method_name],
    [$._generic_member_access, $._generic_method_name],
  ],

  rules: {
    program: ($) =>
      seq(
        optional($._leading_bom),
        repeat(
          seq(
            $.using_statement,
            $._statement_terminator,
            optional($._using_separator),
          ),
        ),
        optional($.param_block),
        // A script can use begin/process/end blocks like a function body.
        optional(choice($.statement_list, $.named_block_list)),
      ),

    // `;` after a using statement. A separate token, so that the parser does
    // not read it as an empty statement and end the using statements early.
    _using_separator: ($) => token(prec(1, ';')),

    // `using` statements must come before any other statement in a script.
    using_statement: ($) =>
      seq(
        reservedWord('using'),
        choice(
          seq(
            reservedWord('namespace'),
            // PowerShell 7 rejects a quoted namespace, but the parser still
            // reads the line as a using statement.
            field('name', choice(alias($._type_name, $.type_name), $.string_literal)),
          ),
          seq(
            reservedWord('module'),
            field(
              'name',
              choice(
                $.string_literal,
                $.hash_literal_expression,
                $._command_word,
              ),
            ),
          ),
          seq(
            reservedWord('assembly'),
            field('name', choice($.string_literal, $._command_word)),
          ),
        ),
      ),

    // Comments
    comment: ($) =>
      token(
        choice(
          /#[^\r\n]*/,
          seq('<#', repeat(choice(/[^#`]+/, /#+[^>#]/, /`.{1}|`\r?\n/)), /#+>/),
        ),
      ),

    // Literal
    _literal: ($) =>
      choice($.integer_literal, $.string_literal, $.real_literal),

    // Integer Literals
    integer_literal: ($) =>
      choice($.decimal_integer_literal, $.hexadecimal_integer_literal),

    decimal_integer_literal: ($) =>
      token(
        seq(
          /[0-9]+/,
          optional(NUMBER_TYPE_SUFFIX),
          optional(NUMBER_MULTIPLIER),
        ),
      ),

    // `0b101` binary literals share this node so the CST stays unchanged.
    hexadecimal_integer_literal: ($) =>
      token(
        choice(
          seq(
            /0[xX]/,
            /[0-9a-fA-F]+/,
            optional(HEX_TYPE_SUFFIX),
            optional(NUMBER_MULTIPLIER),
          ),
          seq(
            /0[bB]/,
            /[01]+/,
            optional(NUMBER_TYPE_SUFFIX),
            optional(NUMBER_MULTIPLIER),
          ),
        ),
      ),

    // Real Literals
    real_literal: ($) =>
      choice(
        $._trailing_dot_real_literal,
        $._real_literal_token,
      ),

    _real_literal_token: ($) =>
      token(
        choice(
          seq(
            /[0-9]+\.[0-9]+/,
            optional(NUMBER_EXPONENT),
            optional(NUMBER_TYPE_SUFFIX),
            optional(NUMBER_MULTIPLIER),
          ),
          seq(
            /\.[0-9]+/,
            optional(NUMBER_EXPONENT),
            optional(NUMBER_TYPE_SUFFIX),
            optional(NUMBER_MULTIPLIER),
          ),
          seq(
            /[0-9]+/,
            NUMBER_EXPONENT,
            optional(NUMBER_TYPE_SUFFIX),
            optional(NUMBER_MULTIPLIER),
          ),
        ),
      ),

    // String literal
    string_literal: ($) =>
      choice(
        $.expandable_string_literal,
        $.verbatim_string_characters,
        $.expandable_here_string_literal,
        $.verbatim_here_string_characters,
      ),

    // Inside the subexpression of an expandable string Native reads a doubled
    // quote as one quote: `"a$("" x "")"` holds the string ` x `. The scanner
    // counts the open subexpressions of such strings and splits runs of quotes
    // into units: one quote, a doubled pair or a backtick-escaped quote.
    expandable_string_literal: ($) =>
      choice(
        seq(
          DOUBLE_QUOTE,
          repeat(
            choice(
              // Comment markers inside strings are text, not extra comments.
              token.immediate(prec(1, /[^\$"\u201C-\u201E`]+/)),
              alias($._qualified_variable_in_string, $.variable),
              $.variable,
              $.sub_expression,
              token.immediate(/\$(`.{1}|`\r?\n|[\s\\])/),
              token.immediate(/`.{1}|`\r?\n/),
              token.immediate(seq(DOUBLE_QUOTE, DOUBLE_QUOTE)),
              token.immediate('$'),
              $._expandable_string_ahead,
            ),
          ),
          repeat(token.immediate('$')),
          token.immediate(DOUBLE_QUOTE),
        ),
        seq(
          $._quote_unit_open,
          repeat(
            choice(
              token.immediate(prec(1, /[^\$"\u201C-\u201E`]+/)),
              alias($._qualified_variable_in_string, $.variable),
              $.variable,
              $.sub_expression,
              token.immediate(/\$(`[^"\u201C-\u201E]|`\r?\n|[\s\\])/),
              token.immediate(/`[^"\u201C-\u201E]|`\r?\n/),
              $._quote_unit_escape,
              token.immediate('$'),
              $._expandable_string_ahead,
            ),
          ),
          $._quote_unit_close,
        ),
      ),

    expandable_here_string_literal: ($) =>
      seq(
        // Native skips any whitespace (not only spaces) between header and newline.
        /@["\u201C-\u201E][ \t\v\f\u0085\u00a0\u1680\u2000-\u200a\u2028\u2029\u202f\u205f\u3000]*(\r\n|\n|\r)/,
        choice(
          // An empty here-string closes immediately after its opening newline.
          token.immediate(prec(2, /["\u201C-\u201E]@/)),
          seq(
            repeat(
              choice(
                token.immediate(prec(1, /[^\$\r\n`]+/)),
                alias($._qualified_variable_in_string, $.variable),
                $.variable,
                $.sub_expression,
                // Leave the next line's escape or interpolation prefix intact.
                token.immediate(/\r\n|\n|\r/),
                token.immediate('$'),
                // Escape CR alone, leaving a following LF eligible to close.
                token.immediate(/`[^\r\n]|`\r|`\n/),
              ),
            ),
            // Only the final newline belongs to the closing delimiter.
            token.immediate(prec(1, /(\r\n|\n|\r)["\u201C-\u201E]@/)),
          ),
        ),
      ),

    verbatim_string_characters: ($) =>
      token(seq(SINGLE_QUOTE, repeat(choice(/[^'\u2018-\u201B]+/, seq(SINGLE_QUOTE, SINGLE_QUOTE))), SINGLE_QUOTE)),

    verbatim_here_string_characters: ($) =>
      token(
        seq(
          /@['\u2018-\u201B][ \t\v\f\u0085\u00a0\u1680\u2000-\u200a\u2028\u2029\u202f\u205f\u3000]*(\r\n|\n|\r)/,
          // A content line cannot begin with a closing delimiter. In particular,
          // an empty or blank-only body must not consume a later here-string.
          repeat(seq(
            optional(choice(
              /[^'\u2018-\u201B\r\n][^\r\n]*/,
              seq(SINGLE_QUOTE, optional(/[^@\r\n][^\r\n]*/)),
            )),
            /\r\n|\n|\r/,
          )),
          SINGLE_QUOTE,
          '@',
        ),
      ),

    // Simple names
    simple_name: ($) =>
      token(
        seq(
          choice(SIMPLE_NAME_LETTER, '_'),
          repeat(choice(SIMPLE_NAME_LETTER, /[^\P{Nd}\u{10000}-\u{10FFFF}]/u, '_')),
        ),
      ),

    // Nested CLR types form one identifier; dots still separate namespaces.
    type_identifier: ($) =>
      token(seq(
        choice(SIMPLE_NAME_LETTER, '_'),
        optional(TYPE_IDENTIFIER),
        repeat(seq('+', TYPE_IDENTIFIER)),
      )),

    type_name: ($) =>
      choice(
        $._type_name,
        alias($._trailing_dot_type_name, $.type_identifier),
      ),

    _type_name: ($) =>
      choice(
        $.type_identifier,
        seq(
          alias($._type_name, $.type_name),
          '.',
          alias(
            token(seq(TYPE_IDENTIFIER, repeat(seq('+', TYPE_IDENTIFIER)))),
            $.type_identifier,
          ),
        ),
      ),

    array_type_name: ($) =>
      seq(
        choice(
          $.type_name,
          // Wrap one complete element type so each array keeps its own rank.
          alias($._array_type_spec, $.type_spec),
          alias($._generic_type_spec, $.type_spec),
        ),
        '[',
      ),
    generic_type_name: ($) => seq($.type_name, '['),

    // Operators and punctuators
    assignement_operator: ($) =>
      choice('=', '!=', '+=', '*=', '/=', '%=', choice('-=', alias($._unicode_minus_assign, '-=')), '??='),

    file_redirection_operator: ($) =>
      choice(
        '>',
        '>>',
        '1>',
        '1>>',
        '2>',
        '2>>',
        '3>',
        '3>>',
        '4>',
        '4>>',
        '5>',
        '5>>',
        '6>',
        '6>>',
        '*>',
        '*>>',
      ),

    merging_redirection_operator: ($) =>
      choice(
        '*>&1',
        '2>&1',
        '3>&1',
        '4>&1',
        '5>&1',
        '6>&1',
        '*>&2',
        '1>&2',
        '3>&2',
        '4>&2',
        '5>&2',
        '6>&2',
      ),

    comparison_operator: ($) =>
      choice(
        reservedWord('-as'),
        reservedWord('-ccontains'),
        reservedWord('-ceq'),
        reservedWord('-cge'),
        reservedWord('-cgt'),
        reservedWord('-cin'),
        reservedWord('-cle'),
        reservedWord('-clike'),
        reservedWord('-clt'),
        reservedWord('-cmatch'),
        reservedWord('-cne'),
        reservedWord('-cnotcontains'),
        reservedWord('-cnotin'),
        reservedWord('-cnotlike'),
        reservedWord('-cnotmatch'),
        reservedWord('-contains'),
        reservedWord('-creplace'),
        alias($._csplit_operator, '-csplit'),
        reservedWord('-eq'),
        reservedWord('-ge'),
        reservedWord('-gt'),
        reservedWord('-icontains'),
        reservedWord('-ieq'),
        reservedWord('-ige'),
        reservedWord('-igt'),
        reservedWord('-iin'),
        reservedWord('-ile'),
        reservedWord('-ilike'),
        reservedWord('-ilt'),
        reservedWord('-imatch'),
        reservedWord('-in'),
        reservedWord('-ine'),
        reservedWord('-inotcontains'),
        reservedWord('-inotin'),
        reservedWord('-inotlike'),
        reservedWord('-inotmatch'),
        reservedWord('-ireplace'),
        reservedWord('-is'),
        reservedWord('-isnot'),
        alias($._isplit_operator, '-isplit'),
        alias($._join_operator, '-join'),
        reservedWord('-le'),
        reservedWord('-like'),
        reservedWord('-lt'),
        reservedWord('-match'),
        reservedWord('-ne'),
        reservedWord('-notcontains'),
        reservedWord('-notin'),
        reservedWord('-notlike'),
        reservedWord('-notmatch'),
        reservedWord('-replace'),
        reservedWord('-shl'),
        reservedWord('-shr'),
        alias($._split_operator, '-split'),
      ),

    format_operator: ($) => reservedWord('-f'),

    // Variables
    variable: ($) =>
      choice(
        // Lookahead keeps a path's single colons distinct from static `::`.
        $._qualified_variable,
        '$$',
        '@$',
        '$^',
        '$?',
        '$_',
        $._dollar_variable,
        $._splatted_variable,
        $.braced_variable,
      ),

    // `$name`, `$scope:name`. The two variable tokens are named rules:
    // inline, Opengrep's simplified grammar would alias them in every variable
    // production, which adds parser states.
    _dollar_variable: ($) =>
      token(
        seq(
          '$',
          choice(
            seq(optional(seq(VARIABLE_NAME, ':')), choice(VARIABLE_REFERENCE, '?')),
            emptyScopeVariable(),
          ),
        ),
      ),

    // `@name` (splatting), `@scope:name`
    _splatted_variable: ($) =>
      token(
        seq(
          '@',
          choice(
            seq(optional(seq(VARIABLE_NAME, ':')), choice(VARIABLE_REFERENCE, '?')),
            emptyScopeVariable(),
          ),
        ),
      ),

    braced_variable: ($) => /\$\{[^}]+\}/,

    // Commands
    // A word cannot start like a redirection (`<`, `>`, `2>`, `*>`), so that
    // `tool arg 2>$null` ends the word before the redirection. Inside a word,
    // `>` is an ordinary character: `a=b>c` is one argument.
    generic_token: ($) =>
      choice(
        token(
          choice(
            // Brackets are literal in argument mode, including `[Type]::Member`.
            new RegExp(String.raw`[^\(\)\$\"\'\u2018-\u201E\+\-\{\}@\|\x60,;\&:${WS}<>0-9*][^"'\u2018-\u201E\x60\&${WS}\(\)\{\}\|;,]*`),
            new RegExp(String.raw`[0-9*]([^"'\u2018-\u201E\x60\&${WS}\(\)\{\}\|;,>][^"'\u2018-\u201E\x60\&${WS}\(\)\{\}\|;,]*)?`),
            // Percentages are words in argument mode, not unary expressions.
            new RegExp(String.raw`-(?:[0-9]|\.[0-9])[^\&${WS}\(\)\{\}\|;,\x60]*%[^\&${WS}\(\)\{\}\|;,\x60]*`),
          ),
        ),
        seq(
          // After lexer extras, '+' must still start a word, not unary plus.
          choice(
            $._command_word_start,
            token(prec(1, new RegExp(String.raw`\+[^${WS}"'\u2018-\u201E\x60$(){}|;,&]*`))),
          ),
          repeat(
            choice(
              $._command_word_part,
              seq(
                $._command_word_expression,
                choice($.string_literal, $.sub_expression),
              ),
            ),
          ),
        ),
      ),

    // Does not start with `"`, so a quoted switch clause condition such as
    // `"a b" { }` is read as a string and not as the longer word `"a`.
    _command_token: ($) => token(new RegExp(String.raw`[^\(\)\{\}${WS};\&"'\u2018-\u201E][^\(\)\{\}${WS};\&]*`)),

    // A clause word never starts with `$`: `$x.Method('a') { }` is an expression.
    // A backtick before whitespace is a line continuation, not a word.
    _switch_clause_token: ($) => token(new RegExp(String.raw`(?:[^\(\)\{\}${WS};\&"'\u2018-\u201E\$\x60]|\x60[^${WS}])[^\(\)\{\}${WS};\&]*`)),

    // Parameters
    // Native also takes an en dash, em dash or horizontal bar as the dash. The
    // precedence keeps such a name ahead of the generic word it also matches.
    _single_command_parameter: ($) => choice(
      token(new RegExp(
        String.raw`-(${PARAMETER_LETTER}|[_?\x60])${PARAMETER_CHAR}*`,
        'u',
      )),
      token(prec(1, new RegExp(
        String.raw`[\u2013-\u2015](${PARAMETER_LETTER}|[_?\x60])${PARAMETER_CHAR}*`,
        'u',
      ))),
    ),

    command_parameter: ($) =>
      choice(
        $._single_command_parameter,
        token(
          choice(
            // Keep the inherited multiple-dash representation outside this fix.
            new RegExp(
              String.raw`--${PARAMETER_CHAR}*`,
              'u',
            ),
            // `--format=%H`, `--pretty=format:"%B"`: a native option with an attached value
            seq(
              new RegExp(String.raw`--?(${PARAMETER_LETTER}|_)${PARAMETER_CHAR}*=`, 'u'),
              repeat(choice(
                new RegExp(String.raw`[^${WS}"'\u2018-\u201E\x60;|&(){}]`),
                new RegExp(String.raw`\x60[^\r\n]`),
                seq(DOUBLE_QUOTE, /[^"\u201C-\u201E\r\n]*/, DOUBLE_QUOTE),
                seq(SINGLE_QUOTE, /[^'\u2018-\u201B\r\n]*/, SINGLE_QUOTE),
              )),
            ),
          ),
        ),
        // A bare `--` or `-` argument (see scanner.c).
        $._bare_dashes,
      ),

    _verbatim_command_argument_chars: ($) =>
      repeat1(choice(/"[^"]*"/, /&[^&]*/, /[^\|\r\n]+/)),

    // Grammar

    // Statements
    script_block: ($) =>
      choice(
        // Prefer a script block expression's existing outer param_block.
        prec(1, field('script_block_body', $.script_block_body)),
        prec.left(
          seq(
            seq($.param_block, repeat(';')),
            field('script_block_body', optional($.script_block_body)),
          ),
        ),
      ),

    param_block: ($) =>
      seq(
        optional($.attribute_list),
        reservedWord('param'),
        '(',
        optional($.parameter_list),
        ')',
      ),

    parameter_list: ($) =>
      seq($.script_parameter, repeat(seq(',', $.script_parameter))),

    script_parameter: ($) =>
      seq(
        optional($.attribute_list),
        $.variable,
        optional($.script_parameter_default),
      ),

    // Native disables the comma operator in a default: a comma starts the next
    // parameter (`param($a = [string], $b = 1)`; `param($a = ,1)` is invalid).
    script_parameter_default: ($) =>
      seq('=', $._class_parameter_default_expression),

    script_block_body: ($) =>
      choice(
        field('named_block_list', $.named_block_list),
        field('statement_list', $.statement_list),
      ),

    named_block_list: ($) => repeat1($.named_block),

    named_block: ($) => seq($.block_name, $.statement_block, repeat(';')),

    block_name: ($) =>
      choice(
        reservedWord('dynamicparam'),
        reservedWord('begin'),
        reservedWord('process'),
        reservedWord('end'),
        reservedWord('clean'),
      ),

    statement_block: ($) =>
      seq('{', field('statement_list', optional($.statement_list)), '}'),

    statement_list: ($) => repeat1($._statement),

    _statement: ($) => choice($._assigned_statement, $.empty_statement),

    // An assignment needs a value: `$x = ;` is an error.
    _assigned_statement: ($) =>
      prec.right(
        choice(
          $.if_statement,
          seq(optional($.label), $._labeled_statement),
          $.function_statement,
          $.class_statement,
          $.enum_statement,
          seq($.flow_control_statement, $._statement_terminator),
          alias($._colon_flow_control, $.flow_control_statement),
          alias($._labeled_flow_control, $.flow_control_statement),
          $.trap_statement,
          $.try_statement,
          $.data_statement,
          $.parallel_statement,
          $.sequence_statement,
          seq(alias($._pipeline_chains, $.pipeline), $._statement_terminator),
          // `npm run dev &` (PowerShell 7): runs the pipeline as a background job
          seq(alias($._pipeline_chains, $.pipeline), $.background_operator),
          // The value ends the statement: it holds its own terminator, or is
          // a compound statement such as `$a = if ($b) { 1 } -join ''`.
          alias($._assignment_pipeline, $.pipeline),
        ),
      ),

    empty_statement: ($) => prec(PREC.EMPTY, ';'),

    background_operator: ($) => '&',

    if_statement: ($) =>
      prec.left(
        seq(
          reservedWord('if'),
          '(',
          field('condition', $.pipeline),
          ')',
          $.statement_block,
          field('elseif_clauses', optional($.elseif_clauses)),
          field('else_clause', optional($.else_clause)),
        ),
      ),

    elseif_clauses: ($) => prec.left(repeat1($.elseif_clause)),

    elseif_clause: ($) =>
      seq(
        optional($._else_clause_ahead),
        reservedWord('elseif'),
        '(',
        field('condition', $.pipeline),
        ')',
        $.statement_block,
      ),

    else_clause: ($) =>
      seq(
        optional($._else_clause_ahead),
        reservedWord('else'),
        $.statement_block,
      ),

    _labeled_statement: ($) =>
      choice(
        $.switch_statement,
        $.foreach_statement,
        $.for_statement,
        $.while_statement,
        $.do_statement,
      ),

    switch_statement: ($) =>
      seq(
        reservedWord('switch'),
        optional($.switch_parameters),
        $.switch_condition,
        $.switch_body,
      ),

    switch_parameters: ($) => repeat1($.switch_parameter),

    switch_parameter: ($) =>
      choice(
        prefixReservedWord('-regex'),
        prefixReservedWord('-wildcard'),
        prefixReservedWord('-exact'),
        prefixReservedWord('-casesensitive'),
        prefixReservedWord('-parallel'),
      ),

    switch_condition: ($) =>
      choice(
        seq('(', $.pipeline, ')'),
        seq(prefixReservedWord('-file'), $.switch_filename),
      ),

    switch_filename: ($) => choice($._command_token, $._primary_expression),

    switch_body: ($) => seq('{', optional($.switch_clauses), '}'),

    switch_clauses: ($) => repeat1($.switch_clause),

    switch_clause: ($) =>
      seq(
        $.switch_clause_condition,
        $.statement_block,
        // Clauses may share a line: `switch ($x) { 1 { 'a' } 2 { 'b' } }`
        optional($._statement_terminator),
        repeat(';'),
      ),

    switch_clause_condition: ($) =>
      choice($._switch_clause_token, $._primary_expression),

    foreach_statement: ($) =>
      seq(
        reservedWord('foreach'),
        optional($.foreach_parameter),
        '(',
        $.variable,
        reservedWord('in'),
        $.pipeline,
        ')',
        $.statement_block,
      ),

    // `-throttlelimit` is only valid next to `-parallel`, in either order.
    foreach_parameter: ($) =>
      seq(
        repeat($.foreach_throttle_limit),
        reservedWord('-parallel'),
        repeat(choice(reservedWord('-parallel'), $.foreach_throttle_limit)),
      ),

    foreach_throttle_limit: ($) =>
      seq(
        reservedWord('-throttlelimit'),
        choice($._command_token, $._primary_expression),
      ),

    for_statement: ($) =>
      seq(
        reservedWord('for'),
        '(',
        optional(
          choice(
            seq(
              field('for_initializer', $.for_initializer),
              $._statement_terminator,
              optional(
                seq(choice(';', $._for_newline), optional($._for_after_separator)),
              ),
            ),
            seq(';', optional($._for_after_separator)),
          ),
        ),
        ')',
        $.statement_block,
      ),

    // After the first separator. Newlines directly after a `;` or the opening
    // parenthesis are whitespace; only one after a clause separates clauses.
    _for_after_separator: ($) =>
      choice(
        seq(
          field('for_condition', $.for_condition),
          $._statement_terminator,
          optional(
            seq(choice(';', $._for_newline), optional($._for_iterator_clause)),
          ),
        ),
        seq(';', optional($._for_iterator_clause)),
      ),

    _for_iterator_clause: ($) =>
      seq(field('for_iterator', $.for_iterator), $._statement_terminator),

    // A newline between for clauses, used like `;`. A named token: inline,
    // Opengrep's simplified grammar would alias it in each of the many
    // for_statement productions, which adds about 400 parser states.
    _for_newline: ($) => token.immediate(/\r\n|\r|\n/),

    for_initializer: ($) => $.pipeline,

    for_condition: ($) => $.pipeline,

    for_iterator: ($) => $.pipeline,

    while_statement: ($) =>
      seq(
        reservedWord('while'),
        '(',
        field('condition', $.while_condition),
        ')',
        $.statement_block,
      ),

    while_condition: ($) => $.pipeline,

    do_statement: ($) =>
      seq(
        reservedWord('do'),
        $.statement_block,
        choice(reservedWord('while'), reservedWord('until')),
        '(',
        field('condition', $.while_condition),
        ')',
      ),

    function_statement: ($) =>
      seq(
        choice(
          seq(
            choice(alias($._function_keyword, 'function'), alias($._filter_keyword, 'filter')),
            $._function_context_plain,
          ),
          seq(alias($._workflow_keyword, 'workflow'), $._function_context_workflow),
        ),
        $.function_name,
        optional($.function_parameter_declaration),
        '{',
        optional($.script_block),
        '}',
        $._function_context_end,
      ),

    _function_keyword: ($) => reserved(caseInsensitive('function')),
    _filter_keyword: ($) => reserved(caseInsensitive('filter')),
    _workflow_keyword: ($) => reserved(caseInsensitive('workflow')),

    function_name: ($) => $._command_token,

    function_parameter_declaration: ($) =>
      seq('(', optional($.parameter_list), ')'),

    flow_control_statement: ($) =>
      choice(
        reservedWord('break'),
        reservedWord('continue'),
        seq(reservedWord('throw'), optional($.pipeline)),
        seq(reservedWord('return'), optional($.pipeline)),
        seq(reservedWord('exit'), optional($.pipeline)),
      ),

    _colon_flow_control: ($) =>
      seq(
        choice(reservedWord('break'), reservedWord('continue')),
        $._flow_control_colon_word,
      ),

    // Native ends the statement at the label: the next statement may follow
    // on the same line, as in `continue outer if ($a) { }`.
    _labeled_flow_control: ($) =>
      seq(
        choice(reservedWord('break'), reservedWord('continue')),
        $.label_expression,
      ),

    label_expression: ($) => choice($.simple_name, $.unary_expression),

    trap_statement: ($) =>
      seq(reservedWord('trap'), optional($.type_literal), $.statement_block),

    try_statement: ($) =>
      seq(
        reservedWord('try'),
        $.statement_block,
        choice(
          seq($.catch_clauses, optional($.finally_clause)),
          optional($.finally_clause),
        ),
      ),

    catch_clauses: ($) => prec.left(repeat1($.catch_clause)),

    catch_clause: ($) =>
      seq(
        optional($._try_clause_ahead),
        reservedWord('catch'),
        optional($.catch_type_list),
        $.statement_block,
      ),

    catch_type_list: ($) =>
      seq($.type_literal, repeat(seq(',', $.type_literal))),

    finally_clause: ($) =>
      seq(optional($._try_clause_ahead), reservedWord('finally'), $.statement_block),

    data_statement: ($) =>
      seq(
        reservedWord('data'),
        optional($.data_name),
        optional($.data_commands_allowed),
        $.statement_block,
      ),

    data_name: ($) => $.simple_name,

    data_commands_allowed: ($) =>
      seq(reservedWord('-supportedcommand'), $.data_commands_list),

    data_commands_list: ($) =>
      seq($.data_command, repeat(seq(',', $.data_command))),

    data_command: ($) => $.command_name_expr,

    parallel_statement: ($) => seq(reservedWord('parallel'), $.statement_block),

    sequence_statement: ($) => seq(reservedWord('sequence'), $.statement_block),

    pipeline: ($) => choice($._assignment_pipeline, $._pipeline_chains),

    _assignment_pipeline: ($) => $.assignment_expression,

    _pipeline_chains: ($) =>
      seq(
        $.pipeline_chain,
        repeat(seq($.pipeline_chain_tail, $.pipeline_chain)),
      ),

    pipeline_chain: ($) =>
      choice(
        seq(
          $._expression,
          optional($.redirections),
          optional($._pipeline_tail),
        ),
        seq(
          $.command,
          optional($.verbatim_command_argument),
          optional($._pipeline_tail),
        ),
      ),

    pipeline_chain_tail: ($) => choice('&&', '||'),

    // Distinct a normal expression to a left assignement expession
    left_assignment_expression: ($) => $._expression,

    assignment_expression: ($) =>
      seq(
        $.left_assignment_expression,
        $.assignement_operator,
        field('value', $._assigned_statement),
      ),

    _pipeline_tail: ($) => repeat1(seq('|', $.command)),

    command: ($) =>
      prec.right(
        choice(
          seq(
            field('command_name', $.command_name),
            field('command_elements', optional($.command_elements)),
          ),
          seq(
            field('command_name', alias($._angle_command_name, $.command_name)),
            field('command_elements', optional(choice(
              $.command_elements,
              alias($._adjacent_angle_arguments, $.command_elements),
            ))),
          ),
          seq(
            field('command_name', alias($._dash_colon_command_name, $.command_name)),
            field('command_elements', optional(choice(
              $.command_elements,
              alias($._adjacent_dash_colon_arguments, $.command_elements),
            ))),
          ),
          seq(
            $.command_invokation_operator,
            field('command_name', alias($._angle_command_name, $.command_name)),
            field('command_elements', optional(choice(
              $.command_elements,
              alias($._adjacent_angle_arguments, $.command_elements),
            ))),
          ),
          seq(
            $.command_invokation_operator,
            // optional($.command_module),
            field('command_name', $.command_name_expr),
            field('command_elements', optional(choice(
              $.command_elements,
              alias($._adjacent_invocation_arguments, $.command_elements),
            ))),
          ),
          seq(
            field('command_name', alias($._inlinescript_name, $.command_name)),
            field('command_elements', alias($._inlinescript_elements, $.command_elements)),
          ),
        ),
      ),

    // The script block comes first, as the scanner has checked; parameters
    // follow. Same tree as the block of an ordinary command, but it may
    // start on a later line.
    _inlinescript_elements: ($) =>
      prec.right(
        seq(
          optional($.command_argument_sep),
          alias($._inlinescript_block_argument, $.array_literal_expression),
          repeat($._command_element),
        ),
      ),

    _inlinescript_block_argument: ($) =>
      alias($._inlinescript_block_value, $.unary_expression),

    _inlinescript_block_value: ($) => $.script_block_expression,

    command_invokation_operator: ($) => choice('.', '&'),

    _adjacent_invocation_arguments: ($) =>
      prec.right(
        seq(
          $._invocation_argument_boundary,
          $._argument_after_quote,
          repeat($._command_element),
        ),
      ),

    // A statement starting with `<`, `>` or `>>` is a command with that name;
    // the rest of the word (`<foo>`, `</foo>`, `>1`) is its first argument (see scanner.c).
    _angle_command_name: ($) => choice('<', '>', '>>'),

    _adjacent_angle_arguments: ($) =>
      prec.right(
        seq(
          $._angle_argument_boundary,
          choice($._argument_after_quote, $.command_parameter),
          repeat($._command_element),
        ),
      ),

    _adjacent_dash_colon_arguments: ($) =>
      prec.right(
        seq(
          $._dash_colon_argument_boundary,
          $._argument_after_quote,
          repeat($._command_element),
        ),
      ),

    // This rule is ignored as it does not appear as a rule
    // command_module: $ => $.primary_expression,

    _expandable_string_literal_immediate: ($) =>
      seq(
        repeat(
          choice(
            /[^\$"\u201C-\u201E`]+/,
            $.variable,
            /\$`(.{1}|`\r?\n)/,
            /`.{1}|`\r?\n/,
            seq(DOUBLE_QUOTE, DOUBLE_QUOTE),
            $.sub_expression,
          ),
        ),
        repeat('$'),
        DOUBLE_QUOTE,
      ),

    _string_literal_immediate: ($) =>
      seq(
        /[^'\u2018-\u201B]+/,
        SINGLE_QUOTE,
      ),

    // A slash starts a command only where a command name is expected. Keep
    // relative slash prefixes together so `./tool` is not dot invocation.
    _slash_command_name: ($) =>
      seq(
        choice('/', /\.{1,2}\//),
        repeat($._command_name_part),
      ),

    // A `$(` inside a name is literal text up to its matching parenthesis.
    // A dash touching a name is scanned as an escape token (see scanner.c), so
    // the longer parameter token cannot take it (`Add-`x`, `Run-Item$x`).
    _command_name_part: ($) =>
      choice(
        token.immediate(new RegExp(String.raw`[^\{\}\(\);,\|\&\x60"'\u2018-\u201E${WS}\$]+`)),
        seq(token.immediate('$'), optional($._command_name_subexpression)),
        $._command_name_escape,
        seq(token.immediate(DOUBLE_QUOTE), $._expandable_string_literal_immediate),
        seq(token.immediate(SINGLE_QUOTE), $._string_literal_immediate),
        token.immediate(seq(DOUBLE_QUOTE, DOUBLE_QUOTE)),
        token.immediate(seq(SINGLE_QUOTE, SINGLE_QUOTE)),
      ),

    command_name: ($) => choice($._slash_command_name, $._ordinary_command_name),

    _ordinary_command_name: ($) =>
      seq(
        optional($._bang_command_name),
        choice(
          // At a token boundary escaped whitespace is trivia, not a name.
          $._command_name_start_escape,
          $._command_name_dollar,
          new RegExp(`[^${COMMAND_NAME_STOP}\\u2013-\\u20150-9.>][^${COMMAND_NAME_STOP}]*`),
          // `*Die x`: a glob-like word is a command name.
          new RegExp(`\\*[^${COMMAND_NAME_STOP}]*`),
          // Dot-prefixed names remain commands unless a number starts the word.
          new RegExp(
            `\\.([^${COMMAND_NAME_STOP}0-9][^${COMMAND_NAME_STOP}]*)?`,
          ),
          $._numeric_command_name,
          $._keyword_dash_command_name,
          seq($._keyword_single_quote_command_name, $._string_literal_immediate),
          seq($._keyword_double_quote_command_name, $._expandable_string_literal_immediate),
          $._keyword_empty_quote_command_name,
          $._dash_command_name,
          seq($._keyword_dollar_command_name, optional($._command_name_subexpression)),
          // `Classify` is a command: this outranks the lexical precedence of the
          // `class` and `enum` keyword tokens, which would otherwise cut the word short.
          token(prec(2, new RegExp(caseInsensitive('class') + COMMAND_NAME_CONTINUATION + '+'))),
          token(prec(2, new RegExp(caseInsensitive('enum') + COMMAND_NAME_CONTINUATION + '+'))),
        ),
        repeat($._command_name_part),
      ),

    // A statement keyword directly followed by one of `-@[]*+/!<` starts a
    // command name such as `if-x` or `throw[T]::M()`, not a statement. tree-sitter
    // cannot make the lexer skip the keyword token, so every keyword that starts
    // a statement must be listed here
    // (https://github.com/airbus-cert/tree-sitter-powershell/issues/24).
    // One named token: inline, Opengrep's simplified grammar would alias each
    // alternative in _ordinary_command_name, which adds about 200 parser states.
    _keyword_dash_command_name: ($) =>
      token(new RegExp(`(${ADJACENT_KEYWORDS.map(caseInsensitive).join('|')})[-@\\[\\]*+/!<]`)),

    // `$` continues a literal command name too, and may open a subexpression.
    _keyword_dollar_command_name: ($) =>
      token(new RegExp(`(${ADJACENT_KEYWORDS.map(caseInsensitive).join('|')})\\$`)),

    // A statement keyword directly followed by a quote is the start of a
    // command name (`throw'x'`), as for a dash above.
    _keyword_single_quote_command_name: ($) =>
      token(new RegExp(`(${STATEMENT_KEYWORDS.map(caseInsensitive).join('|')})${SINGLE_QUOTE.source}`)),

    _keyword_double_quote_command_name: ($) =>
      token(new RegExp(`(${STATEMENT_KEYWORDS.map(caseInsensitive).join('|')})${DOUBLE_QUOTE.source}`)),

    _keyword_empty_quote_command_name: ($) =>
      token(new RegExp(
        `(${STATEMENT_KEYWORDS.map(caseInsensitive).join('|')})` +
        `(${SINGLE_QUOTE.source}${SINGLE_QUOTE.source}|${DOUBLE_QUOTE.source}${DOUBLE_QUOTE.source})`,
      )),

    // A dash word with a colon (`-Name:`) is a command name; an argument may touch it.
    _dash_colon_command_name: ($) =>
      token(prec(PREC.KEYWORD, new RegExp(`${dashCommandName().source}:`, 'u'))),

    // An `@` continues a word but cannot start one (`@x` is a splat).
    path_command_name_token: ($) => /[0-9a-zA-Z_?\-\.\\\/][0-9a-zA-Z_?\-\.\\\/@]*/,

    // A variable alone (or followed by member access) is an expression.
    // Only an adjacent word suffix can turn it into an expandable path.
    path_command_name: ($) =>
      seq(
        choice(
          $.path_command_name_token,
          seq(
            $.variable,
            $._variable_command_name_continuation,
            $._path_command_name_part,
          ),
        ),
        repeat(seq(
          $._path_command_name_continuation,
          $._path_command_name_part,
        )),
      ),

    _path_command_name_part: ($) =>
      choice(
        $.path_command_name_token,
        $.variable,
        $.sub_expression,
        seq(token.immediate(DOUBLE_QUOTE), $._expandable_string_literal_immediate),
        seq(token.immediate(SINGLE_QUOTE), $._string_literal_immediate),
        token.immediate(seq(DOUBLE_QUOTE, DOUBLE_QUOTE)),
        token.immediate(seq(SINGLE_QUOTE, SINGLE_QUOTE)),
        $._command_name_escape,
      ),

    command_name_expr: ($) =>
      choice($.command_name, $.path_command_name, $._primary_expression),

    command_elements: ($) => prec.right(repeat1($._command_element)),

    _command_element: ($) =>
      prec.right(
        choice(
          seq(
            $.command_parameter,
            optional(seq(
              alias($._parameter_argument_separator, $.command_argument_sep),
              $._parameter_argument_start,
              // Keep horizontal trivia outside the required value's extent.
              repeat(choice(
                $.command_argument_sep,
                alias(token(prec(1, new RegExp(`[${HSPACE}]+`))), $.command_argument_sep),
              )),
              $._command_parameter_argument,
            )),
          ),
          seq(
            alias($._single_command_parameter, $.command_parameter),
            choice(
              seq($._parameter_dot_boundary, $._argument_after_quote),
              seq(
                $._parameter_dot_literal_boundary,
                $.parameter_dot_literal,
                $._argument_after_quote,
              ),
            ),
          ),
          prec.dynamic(1, $._adjacent_expression_arguments),
          seq($._command_argument, optional($.argument_list)),
          seq(
            $.command_argument_sep,
            $.generic_token,
            alias(token.immediate(new RegExp(`[${HSPACE}]+`)), $.command_argument_sep),
            optional($._argument_after_quote),
          ),
          seq(
            $.command_argument_sep,
            $.quoted_command_argument,
            $._quoted_argument_boundary,
            $._argument_after_quote,
          ),
          $.redirection,
          $.stop_parsing,
        ),
      ),

    // A named token keeps this argument visible after grammar simplification.
    parameter_dot_literal: ($) => token.immediate('.'),

    // Stop parsing is a token that end the parsing of command line.
    // Native ends it at `|` or `&&` outside double quotes; single quotes do not protect one.
    // An unterminated double quote runs to the end of the line.
    stop_parsing: ($) => choice('--%', new RegExp(
      String.raw`--%(?:(?:[^|&"\r\n]|&[^&|\r\n]|"[^"\r\n]*")+(?:"[^"\r\n]*)?|"[^"\r\n]*)`,
    )),

    // A colon is a separator only immediately after a command parameter.
    // A lexical precedence keeps the separator ahead of the equivalent extras.
    command_argument_sep: ($) => prec.right(token(prec(1, new RegExp(`[ ${HSPACE}]+`)))),

    _command_word: ($) => choice($.generic_token, $.colon_command_argument),

    _command_parameter_argument: ($) =>
      choice(
        seq(
          choice($._command_word, $.parameter_argument_word),
          repeat($._command_array_tail),
        ),
        seq(
          $.parameter_argument_word,
          $._quoted_argument_boundary,
          $._argument_after_quote,
        ),
        seq(
          $.quoted_command_argument,
          $._quoted_argument_boundary,
          $._argument_after_quote,
        ),
        seq($._completed_command_argument, $._argument_after_quote),
        alias($._command_expression_array, $.array_literal_expression),
        $._command_mixed_array,
      ),

    // Dash-leading tokens are strings, not new parameters or unary expressions,
    // when a parameter colon has requested a value.
    parameter_argument_word: ($) => token.immediate(prec(1, new RegExp(
      String.raw`-+(?:${PARAMETER_LETTER}|[_?\x60-])${PARAMETER_CHAR}*:?|-[0-9.][^${WS}"'\u2018-\u201E\x60$(){}|;,&]*|-`,
      'u',
    ))),

    // A colon starts a new command word after an expression, not a member suffix.
    // Only the immediate colon following a parameter is an attachment separator.
    colon_command_argument: ($) =>
      choice(
        // Label-like words remain literal: `:word$value` does not expand.
        alias(token(new RegExp(
          `:(?:${PARAMETER_LETTER}|_)[^${WS}(){}|;&,]*`,
          'u',
        )), $.generic_token),
        prec.right(seq(
          ':',
          repeat(choice(
            $.colon_word_text,
            seq(
              $._colon_word_continuation,
              choice($.variable, $.string_literal, $.sub_expression, token.immediate('$')),
            ),
          )),
        )),
      ),

    colon_word_text: ($) =>
      choice(
        token.immediate(prec(1, new RegExp(String.raw`[^${WS}"'\u2018-\u201E\x60$();|&,{}]+`))),
        // CLI 0.22 misreads the union of \s and \S inside a character class.
        token.immediate(/`[^\r\n]|`[\r\n]/),
      ),

    // Adapt the grammar to have same behavior

    _command_argument: ($) =>
      prec.right(
        PREC.PARAM,
        choice(
          // A command suffix can contain a pipeline. Member access is excluded:
          // a member followed by '(' must still parse as a real method call.
          prec.dynamic(-1, seq(
            $.command_argument_sep,
            choice(
              $._command_word,
              // The parenthesis must touch the array: a newline ends the command.
              seq(
                alias($._command_pipeline_prefix_array, $.array_literal_expression),
                $._adjacent_paren_boundary,
              ),
            ),
            choice(
              // Outrank adjacent-expression alternatives without changing their trees.
              // `w 'a'(1)'b'`: a word or quote may follow the closing parenthesis.
              seq(
                prec.dynamic(3, $.argument_list),
                optional(seq($._completed_expression_boundary, $._argument_after_quote)),
              ),
              prec.dynamic(-1, $.parenthesized_expression),
              // `New-Object uri(Get-Item x).t`: the parenthesis is the receiver
              // of a member, element or call, as after a separator.
              seq(
                alias($._paren_member_array, $.array_literal_expression),
                optional(seq($._completed_member_boundary, $._argument_after_quote)),
              ),
              seq(
                alias($._paren_call_array, $.array_literal_expression),
                optional(seq($._completed_expression_boundary, $._argument_after_quote)),
              ),
            ),
          )),
          seq(
            $.command_argument_sep,
            optional(
              seq(
                $._command_word,
                // `Select-Object Id, Name`: an unquoted comma list is one array argument
                repeat($._command_array_tail),
              ),
            ),
          ),
          seq(
            $.command_argument_sep,
            alias($._command_expression_array, $.array_literal_expression),
          ),
          // `New-Object T "a", $b, word`: a comma list that starts with an
          // expression and has unquoted words. array_literal_expression wins
          // when both match.
          prec.dynamic(
            -1,
            seq($.command_argument_sep, $._command_mixed_array),
          ),
          seq(
            $.colon_command_argument,
            repeat($._command_array_tail),
          ),
          $.parenthesized_expression,
          $.script_block_expression,
        ),
      ),

    _command_array_tail: ($) =>
      seq(
        ',',
        $._command_array_item_start,
        choice(
          $._command_array_word,
          alias($._command_unary_expression, $.unary_expression),
        ),
      ),

    _command_array_word: ($) =>
      choice($._command_word, alias($.command_parameter, $.generic_token)),

    _command_expression_array: ($) =>
      prec.left(
        seq(
          alias($._command_unary_expression, $.unary_expression),
          repeat(seq(
            ',',
            $._command_array_item_start,
            alias($._command_unary_expression, $.unary_expression),
          )),
        ),
      ),

    _command_mixed_array: ($) =>
      seq(
        alias($._command_unary_expression, $.unary_expression),
        repeat(seq(
          ',',
          $._command_array_item_start,
          alias($._command_unary_expression, $.unary_expression),
        )),
        ',',
        $._command_array_item_start,
        $._command_array_word,
        repeat($._command_array_tail),
      ),

    _command_unary_expression: ($) =>
      prec.right(
        choice(
          $._primary_expression,
          alias($._command_unary_operator, $.expression_with_unary_operator),
        ),
      ),

    // A command comma requests a value; another comma is not unary array syntax.
    _command_unary_operator: ($) =>
      choice(
        seq(alias($._not_operator, '-not'), $.unary_expression),
        seq('!', $.unary_expression),
        seq(alias($._bnot_operator, '-bnot'), $.unary_expression),
        seq('+', $.unary_expression),
        seq(choice('-', alias($._unicode_minus, '-')), $.unary_expression),
        $.pre_increment_expression,
        $.pre_decrement_expression,
        $.cast_expression,
        $.attributed_expression,
        seq(alias($._split_operator, '-split'), $.unary_expression),
        seq(alias($._csplit_operator, '-csplit'), $.unary_expression),
        seq(alias($._isplit_operator, '-isplit'), $.unary_expression),
        seq(alias($._join_operator, '-join'), $.unary_expression),
      ),

    // Unary keyword operators, also used by comparison_operator (-split, -csplit, -isplit, -join)
    // so that each stays one token. Aliased back to the keyword, so trees are
    // unchanged. Named rules: inline, Opengrep's simplified grammar would alias
    // them in every unary production, which adds about 250 parser states.
    _not_operator: ($) => reserved(caseInsensitive('-not')),
    _bnot_operator: ($) => reserved(caseInsensitive('-bnot')),
    _split_operator: ($) => reserved(caseInsensitive('-split')),
    _csplit_operator: ($) => reserved(caseInsensitive('-csplit')),
    _isplit_operator: ($) => reserved(caseInsensitive('-isplit')),
    _join_operator: ($) => reserved(caseInsensitive('-join')),

    // `-Name args` at a statement start is a command named `-Name`. A word whose
    // leading letters spell a unary keyword stays that operator (see dashCommandName).
    _dash_command_name: ($) => prec(PREC.KEYWORD, dashCommandName()),

    // En dash, em dash and horizontal bar also spell `-`, `-=` and `--`.
    _unicode_minus: ($) => /[\u2013-\u2015]/,
    _unicode_minus_assign: ($) => /[\u2013-\u2015]=/,
    _unicode_decrement: ($) => /[\u2013-\u2015][\u2013-\u2015-]|-[\u2013-\u2015]/,
    // A leading quoted string ends an argument even without following spaces.
    // Keep each adjacent argument visible directly under command_elements.
    quoted_command_argument: ($) => $.string_literal,

    // A bare variable is not complete: $left$($right)tail remains one word.
    _adjacent_expression_arguments: ($) =>
      prec.right(
        PREC.PARAM,
        choice(
          seq(
            $.command_argument_sep,
            $._completed_command_argument,
            $._argument_after_quote,
          ),
          seq(
            choice($.parenthesized_expression, $.script_block_expression),
            $._completed_expression_boundary,
            $._argument_after_quote,
          ),
          // `Fix($a).Trim()`: with no separator the member access, call or
          // index applies to the parenthesis, as it does after a separator.
          // A bare member must not take the expression boundary: `(` after it
          // starts the method arguments.
          seq(
            alias($._paren_member_array, $.array_literal_expression),
            optional(seq(
              $._completed_member_boundary,
              $._argument_after_quote,
            )),
          ),
          seq(
            alias($._paren_call_array, $.array_literal_expression),
            optional(seq(
              $._completed_expression_boundary,
              $._argument_after_quote,
            )),
          ),
        ),
      ),

    // Postfix access on a parenthesis argument with no separator before it:
    // `Fix($a).Trim()`, `Get($x)[0]`. The _paren_* rules repeat member_access,
    // element_access and invokation_expression, because those accept any
    // primary expression as the base, while here the base must be a
    // parenthesized expression or another _paren_* access. A trailing comma
    // list continues the argument as an array, as after a separator.
    _paren_member_array: ($) =>
      seq(
        alias($._paren_member_value, $.unary_expression),
        repeat($._paren_postfix_array_item),
      ),

    _paren_call_array: ($) =>
      seq(
        alias($._paren_call_value, $.unary_expression),
        repeat($._paren_postfix_array_item),
      ),

    _paren_postfix_array_item: ($) =>
      seq(
        ',',
        $._command_array_item_start,
        choice(
          alias($._command_unary_expression, $.unary_expression),
          $._command_array_word,
        ),
      ),

    _paren_member_value: ($) =>
      alias($._paren_member_access, $.member_access),

    _paren_call_value: ($) =>
      choice(
        alias($._paren_element_access, $.element_access),
        alias($._paren_invokation, $.invokation_expression),
      ),

    _paren_chain: ($) =>
      choice($.parenthesized_expression, $._paren_member_value, $._paren_call_value),

    _paren_member_access: ($) =>
      prec.left(
        choice(
          seq($._paren_chain, $._member_access_operator, $.member_name),
          seq($._paren_chain, '::', $.member_name),
        ),
      ),

    _paren_element_access: ($) =>
      prec(
        PREC.ELEMENT_ACCESS,
        seq(
          $._paren_chain,
          choice('[', $.null_conditional_element_operator),
          $._expression,
          ']',
        ),
      ),

    _paren_invokation: ($) =>
      prec.right(
        PREC.PARAM + 1,
        choice(
          seq($._paren_chain, $._member_access_operator, $.member_name, prec.dynamic(3, $.argument_list)),
          seq($._paren_chain, '::', $.member_name, prec.dynamic(3, $.argument_list)),
        ),
      ),

    _completed_command_argument: ($) =>
      alias($._completed_argument_array, $.array_literal_expression),

    _completed_argument_array: ($) =>
      choice(
        // A quote completes the whole comma argument, not just its final item.
        seq(
          repeat1(seq(
            choice(
              alias($._command_unary_expression, $.unary_expression),
              $._command_word,
            ),
            ',',
            $._command_array_item_start,
          )),
          alias($._quoted_array_value, $.unary_expression),
          $._quoted_argument_boundary,
        ),
        seq(
          alias($._completed_argument_value, $.unary_expression),
          $._completed_expression_boundary,
        ),
        seq(
          alias($._completed_argument_member, $.unary_expression),
          $._completed_member_boundary,
        ),
      ),

    _quoted_array_value: ($) => $.string_literal,

    _completed_argument_value: ($) =>
      choice(
        $.parenthesized_expression,
        $.sub_expression,
        $.array_expression,
        $.script_block_expression,
        $.hash_literal_expression,
        $.element_access,
        $.invokation_expression,
      ),

    _completed_argument_member: ($) =>
      // Ordinary variables must remain on the command-array expression path.
      choice($.member_access, alias($._variable_before_literal_dot, $.variable)),

    _argument_after_quote: ($) =>
      choice(
        seq(
          $._command_word,
          repeat($._command_array_tail),
        ),
        alias($._command_expression_array, $.array_literal_expression),
        $._command_mixed_array,
        seq($._completed_command_argument, $._argument_after_quote),
        seq(
          $.quoted_command_argument,
          $._quoted_argument_boundary,
          $._argument_after_quote,
        ),
      ),

    _command_pipeline_prefix_array: ($) =>
      prec.left(seq(
        alias($._command_pipeline_prefix_expression, $.unary_expression),
        repeat(seq(
          ',',
          alias($._command_pipeline_prefix_expression, $.unary_expression),
        )),
      )),

    _command_pipeline_prefix_expression: ($) =>
      choice(
        $._value,
        $.element_access,
        $.invokation_expression,
        $.post_increment_expression,
        $.post_decrement_expression,
      ),

    verbatim_command_argument: ($) =>
      seq('--%', $._verbatim_command_argument_chars),

    redirections: ($) => repeat1($.redirection),

    redirection: ($) =>
      choice(
        $.merging_redirection_operator,
        seq($.file_redirection_operator, $.redirected_file_name),
      ),

    redirected_file_name: ($) =>
      choice(
        $._command_argument,
        $._primary_expression,
        // A file name right after the operator: `>>log.txt`
        $.generic_token,
      ),

    // Class
    class_attribute: ($) =>
      choice(token(reservedWord('hidden')), token(reservedWord('static'))),

    class_property_definition: ($) =>
      seq(
        repeat(choice($.attribute, $.class_attribute)),
        // Keep the final type separate from the preceding attributes.
        optional(prec.dynamic(1, $.type_literal)),
        $.variable,
        optional(seq('=', $._expression)),
      ),

    class_method_parameter: ($) =>
      seq(
        optional($.type_literal),
        $.variable,
        optional($.class_method_parameter_default),
      ),

    class_method_parameter_default: ($) =>
      seq('=', $._class_parameter_default_expression),

    // A comma separates the parameters, so a default is an expression without
    // comma arrays: the chain below mirrors `_expression` down to its operands.
    // Used by script and class method parameters.
    // Its operand is a _command_unary_expression, which has no unary comma
    // either. Same node names as `_expression` (aliases).
    _class_parameter_default_expression: ($) =>
      choice(
        alias($._class_default_logical, $.logical_expression),
        alias($._class_default_ternary, $.ternary_expression),
      ),

    _class_default_ternary: ($) =>
      prec.right(
        seq(
          field('condition', alias($._class_default_logical, $.logical_expression)),
          '?',
          field('consequence', $._class_parameter_default_expression),
          ':',
          field('alternative', $._class_parameter_default_expression),
        ),
      ),

    _class_default_logical: ($) =>
      prec.left(
        choice(
          alias($._class_default_bitwise, $.bitwise_expression),
          seq(
            alias($._class_default_logical, $.logical_expression),
            choice(
              reservedWord('-and'),
              reservedWord('-or'),
              reservedWord('-xor'),
            ),
            alias($._class_default_bitwise, $.bitwise_expression),
          ),
        ),
      ),

    _class_default_bitwise: ($) =>
      prec.left(
        choice(
          alias($._class_default_comparison, $.comparison_expression),
          seq(
            alias($._class_default_bitwise, $.bitwise_expression),
            choice(
              reservedWord('-band'),
              reservedWord('-bor'),
              reservedWord('-bxor'),
            ),
            alias($._class_default_comparison, $.comparison_expression),
          ),
        ),
      ),

    _class_default_comparison: ($) =>
      prec.left(
        choice(
          alias($._class_default_additive, $.additive_expression),
          alias($._class_default_null_coalescing, $.null_coalescing_expression),
          seq(
            alias($._class_default_comparison, $.comparison_expression),
            $.comparison_operator,
            choice(
              alias($._class_default_additive, $.additive_expression),
              alias($._class_default_null_coalescing, $.null_coalescing_expression),
            ),
          ),
        ),
      ),

    _class_default_null_coalescing: ($) =>
      prec.left(
        seq(
          choice(
            alias($._class_default_additive, $.additive_expression),
            alias($._class_default_null_coalescing, $.null_coalescing_expression),
          ),
          '??',
          alias($._class_default_additive, $.additive_expression),
        ),
      ),

    _class_default_additive: ($) =>
      prec.left(
        choice(
          alias($._class_default_multiplicative, $.multiplicative_expression),
          seq(
            alias($._class_default_additive, $.additive_expression),
            choice('+', choice('-', alias($._unicode_minus, '-'))),
            alias($._class_default_multiplicative, $.multiplicative_expression),
          ),
        ),
      ),

    _class_default_multiplicative: ($) =>
      prec.left(
        choice(
          alias($._class_default_format, $.format_expression),
          seq(
            alias($._class_default_multiplicative, $.multiplicative_expression),
            choice('/', '\\', '%', '*'),
            alias($._class_default_format, $.format_expression),
          ),
        ),
      ),

    _class_default_format: ($) =>
      prec.left(
        choice(
          alias($._class_default_range, $.range_expression),
          seq(
            alias($._class_default_format, $.format_expression),
            $.format_operator,
            alias($._class_default_range, $.range_expression),
          ),
        ),
      ),

    _class_default_range: ($) =>
      prec.left(
        choice(
          alias($._class_default_array, $.array_literal_expression),
          seq(
            alias($._class_default_range, $.range_expression),
            '..',
            alias($._class_default_array, $.array_literal_expression),
          ),
        ),
      ),

    // Like a command array item, a default has no unary comma: a comma ends it.
    // A bare type ends at the comma too, it does not cast `,x` (_attribute_type_value).
    // A generic method call is an expression operand, as in unary_expression.
    _class_default_array: ($) =>
      choice(
        alias($._command_unary_expression, $.unary_expression),
        alias($._attribute_type_value, $.unary_expression),
        alias($._generic_primary_expression, $.unary_expression),
      ),

    class_method_parameter_list: ($) =>
      seq($.class_method_parameter, repeat(seq(',', $.class_method_parameter))),

    class_method_definition: ($) =>
      seq(
        repeat(choice($.attribute, $.class_attribute)),
        optional(prec.dynamic(1, $.type_literal)),
        $.simple_name,
        '(',
        optional($.class_method_parameter_list),
        ')',
        optional($.class_base_constructor_call),
        '{',
        optional($.script_block),
        '}',
      ),

    // `MyError($Message) : base($Message) { }`
    class_base_constructor_call: ($) =>
      seq(':', reservedWord('base'), $.argument_list),

    class_statement: ($) =>
      seq(
        optional($.attribute_list),
        token(reservedWord('class')),
        $.simple_name,
        optional(seq(':', $.type_spec, repeat(seq(',', $.type_spec)))),
        '{',
        repeat(
          choice(
            seq(
              $.class_property_definition,
              $._statement_terminator,
              repeat(';'),
            ),
            $.class_method_definition,
          ),
        ),
        '}',
      ),

    // Enums
    enum_statement: ($) =>
      seq(
        optional($.attribute_list),
        token(reservedWord('enum')),
        $.simple_name,
        optional(seq($._enum_base_colon_ahead, ':', $.type_spec)),
        '{',
        repeat(seq($.enum_member, $._statement_terminator, repeat(';'))),
        '}',
      ),

    enum_member: ($) =>
      seq(
        $.simple_name,
        optional(
          seq(
            '=',
            // A plain number stays an integer_literal; `[Byte]6` and `1 + 2`
            // are other constant expressions
            choice(prec(PREC.KEYWORD, $.integer_literal), $._expression),
          ),
        ),
      ),

    // Expressions
    _expression: ($) => choice($.logical_expression, $.ternary_expression),

    // `$cond ? $a : $b` (PowerShell 7): binds looser than every binary operator
    ternary_expression: ($) =>
      prec.right(
        seq(
          field('condition', $.logical_expression),
          '?',
          field('consequence', $._expression),
          ':',
          field('alternative', $._expression),
        ),
      ),

    logical_expression: ($) =>
      prec.left(
        choice(
          $.bitwise_expression,
          seq(
            $.logical_expression,
            choice(
              reservedWord('-and'),
              reservedWord('-or'),
              reservedWord('-xor'),
            ),
            $.bitwise_expression,
          ),
        ),
      ),

    bitwise_expression: ($) =>
      prec.left(
        choice(
          $.comparison_expression,
          seq(
            $.bitwise_expression,
            choice(
              reservedWord('-band'),
              reservedWord('-bor'),
              reservedWord('-bxor'),
            ),
            $.comparison_expression,
          ),
        ),
      ),

    comparison_expression: ($) =>
      prec.left(
        choice(
          $.additive_expression,
          $.null_coalescing_expression,
          seq(
            $.comparison_expression,
            $.comparison_operator,
            choice($.additive_expression, $.null_coalescing_expression),
          ),
        ),
      ),

    // `$a ?? $b` (PowerShell 7): binds tighter than comparisons, looser than `+`
    null_coalescing_expression: ($) =>
      prec.left(
        seq(
          choice($.additive_expression, $.null_coalescing_expression),
          '??',
          $.additive_expression,
        ),
      ),

    additive_expression: ($) =>
      prec.left(
        choice(
          $.multiplicative_expression,
          seq(
            $.additive_expression,
            choice('+', choice('-', alias($._unicode_minus, '-'))),
            $.multiplicative_expression,
          ),
        ),
      ),

    multiplicative_expression: ($) =>
      prec.left(
        choice(
          $.format_expression,
          seq(
            $.multiplicative_expression,
            choice('/', '\\', '%', '*'),
            $.format_expression,
          ),
        ),
      ),

    format_expression: ($) =>
      prec.left(
        choice(
          $.range_expression,
          seq($.format_expression, $.format_operator, $.range_expression),
        ),
      ),

    range_expression: ($) =>
      prec.left(
        choice(
          $.array_literal_expression,
          seq($.range_expression, '..', $.array_literal_expression),
        ),
      ),

    array_literal_expression: ($) =>
      prec.left(seq($.unary_expression, repeat(seq(',', $.unary_expression)))),

    unary_expression: ($) =>
      prec.right(
        choice(
          $._primary_expression,
          $._generic_primary_expression,
          $.expression_with_unary_operator,
        ),
      ),

    expression_with_unary_operator: ($) =>
      choice(
        seq(',', $.unary_expression),
        $._command_unary_operator,
      ),

    pre_increment_expression: ($) => seq('++', $.unary_expression),
    pre_decrement_expression: ($) => seq(choice('--', alias($._unicode_decrement, '--')), $.unary_expression),

    cast_expression: ($) =>
      prec(PREC.CAST, seq($.type_literal, $.unary_expression)),

    attributed_expression: ($) =>
      seq(alias($._attribute_with_arguments, $.attribute), $.unary_expression),

    attributed_variable: ($) => seq($.type_literal, $.variable),

    _primary_expression: ($) =>
      choice(
        $._value,
        $.member_access,
        $.element_access,
        $.invokation_expression,
        $.post_increment_expression,
        $.post_decrement_expression,
      ),

    _value: ($) =>
      choice(
        $.parenthesized_expression,
        $.sub_expression,
        $.array_expression,
        $.script_block_expression,
        $.hash_literal_expression,
        $._literal,
        $.type_literal,
        $.variable,
      ),

    parenthesized_expression: ($) => seq('(', $.pipeline, ')'),

    sub_expression: ($) =>
      choice(
        seq('$(', field('statements', optional($.statement_list)), ')'),
        // In an expandable string; see expandable_string_literal.
        seq(
          alias($._string_subexpression_start, '$('),
          field('statements', optional($.statement_list)),
          ')',
          $._string_subexpression_end,
        ),
      ),

    array_expression: ($) =>
      seq('@(', field('statements', optional($.statement_list)), ')'),

    script_block_expression: ($) =>
      seq('{', optional($.param_block), optional($.script_block), '}'),

    hash_literal_expression: ($) =>
      seq('@{', optional($.hash_literal_body), '}'),

    hash_literal_body: ($) => repeat1($.hash_entry),

    hash_entry: ($) =>
      seq(
        $.key_expression,
        '=',
        $._statement,
        $._statement_terminator,
        repeat(';'),
      ),

    key_expression: ($) => choice($.simple_name, $.unary_expression),

    post_increment_expression: ($) =>
      prec(PREC.UNARY, seq($._primary_expression, '++')),

    post_decrement_expression: ($) =>
      prec(PREC.UNARY, seq($._primary_expression, choice('--', alias($._unicode_decrement, '--')))),

    member_access: ($) =>
      prec.left(
        choice(
          seq(
            $._primary_expression,
            $._member_access_operator,
            $.member_name,
          ),
          seq($._primary_expression, '::', $.member_name),
        ),
      ),

    // Unbraced variables consume a trailing '?': $x?.P accesses $x?, not $x.
    _member_access_operator: ($) =>
      choice(token.immediate('.'), $.null_conditional_member_operator),

    null_conditional_member_operator: ($) => token.immediate('?.'),

    null_conditional_element_operator: ($) => token.immediate('?['),

    member_name: ($) =>
      choice(
        alias($._foreach_member_name, $.simple_name),
        alias($._foreach_prefixed_member_name, $.simple_name),
        $.simple_name,
        $.string_literal,
        $.expression_with_unary_operator,
        $._value,
      ),

    element_access: ($) =>
      prec(
        PREC.ELEMENT_ACCESS,
        seq(
          $._primary_expression,
          choice('[', $.null_conditional_element_operator),
          $._expression,
          ']',
        ),
      ),

    // Finish a method call before reducing the enclosing command argument.
    invokation_expression: ($) =>
      prec.right(
        PREC.PARAM + 1,
        choice(
          seq(
            $._primary_expression,
            $._member_access_operator,
            $.member_name,
            $.argument_list,
          ),
          seq($._primary_expression, '::', $.member_name, $.argument_list),
          // `$x.Where{ ... }`: a script block right after the member name is the only argument
          seq(
            $._primary_expression,
            $._member_access_operator,
            $.member_name,
            $._script_block_argument_start,
            $.script_block_expression,
          ),
          seq(
            $._primary_expression,
            '::',
            $.member_name,
            $._script_block_argument_start,
            $.script_block_expression,
          ),
          $.invokation_foreach_expression,
        ),
      ),

    _foreach_member_name: ($) => token.immediate(reservedWord('foreach')),

    // The keyword token outranks a longer simple_name, so `.ForEachStatement` needs its own token.
    _foreach_prefixed_member_name: ($) =>
      token.immediate(
        prec(
          PREC.KEYWORD,
          seq(
            new RegExp(caseInsensitive('foreach')),
            repeat1(choice(SIMPLE_NAME_LETTER, /[^\P{Nd}\u{10000}-\u{10FFFF}]/u, '_')),
          ),
        ),
      ),

    // Keep the shorthand distinct without consuming the dot as part of the name.
    invokation_foreach_expression: ($) =>
      prec(
        PREC.KEYWORD,
        seq(
          $._primary_expression,
          $._member_access_operator,
          $._foreach_member_name,
          choice($.script_block_expression, $.argument_list),
        ),
      ),

    argument_list: ($) =>
      seq(
        '(',
        field('argument_expression_list', optional($.argument_expression_list)),
        ')',
      ),

    // `[Array]::Sort[string]($a)`, `$x.M[int]($a).N`: explicit generic method type
    // arguments. Only an expression operand (unary_expression) reads one, not a
    // command argument: Native rejects `foo $x.M[int]($a)`. A call on the result
    // needs its own rules, because _primary_expression has no generic call.
    _generic_primary_expression: ($) =>
      choice(
        alias($._generic_invokation, $.invokation_expression),
        alias($._generic_member_access, $.member_access),
        alias($._generic_element_access, $.element_access),
        alias($._generic_result_call, $.invokation_expression),
        alias($._generic_post_increment, $.post_increment_expression),
        alias($._generic_post_decrement, $.post_decrement_expression),
      ),

    _generic_post_increment: ($) =>
      prec(PREC.UNARY, seq($._generic_primary_expression, '++')),

    _generic_post_decrement: ($) =>
      prec(
        PREC.UNARY,
        seq($._generic_primary_expression, choice('--', alias($._unicode_decrement, '--'))),
      ),

    _generic_invokation: ($) =>
      prec.right(
        PREC.PARAM + 1,
        choice(
          seq(
            $._primary_expression,
            $._member_access_operator,
            $._generic_method_name,
            $.generic_method_arguments,
            alias($._generic_call_arguments, $.argument_list),
          ),
          seq(
            $._primary_expression,
            '::',
            $._generic_method_name,
            $.generic_method_arguments,
            alias($._generic_call_arguments, $.argument_list),
          ),
          seq(
            $._generic_primary_expression,
            $._member_access_operator,
            $._generic_method_name,
            $.generic_method_arguments,
            alias($._generic_call_arguments, $.argument_list),
          ),
          seq(
            $._generic_primary_expression,
            '::',
            $._generic_method_name,
            $.generic_method_arguments,
            alias($._generic_call_arguments, $.argument_list),
          ),
        ),
      ),

    _generic_member_access: ($) =>
      prec.left(
        choice(
          seq($._generic_primary_expression, $._member_access_operator, $.member_name),
          seq($._generic_primary_expression, '::', $.member_name),
        ),
      ),

    _generic_element_access: ($) =>
      prec(
        PREC.ELEMENT_ACCESS,
        seq(
          $._generic_primary_expression,
          choice('[', $.null_conditional_element_operator),
          $._expression,
          ']',
        ),
      ),

    _generic_result_call: ($) =>
      prec.right(
        PREC.PARAM + 1,
        choice(
          seq($._generic_primary_expression, $._member_access_operator, $.member_name, $.argument_list),
          seq($._generic_primary_expression, '::', $.member_name, $.argument_list),
          seq(
            $._generic_primary_expression,
            $._member_access_operator,
            $.member_name,
            $._script_block_argument_start,
            $.script_block_expression,
          ),
          seq(
            $._generic_primary_expression,
            '::',
            $.member_name,
            $._script_block_argument_start,
            $.script_block_expression,
          ),
          alias($._generic_foreach_call, $.invokation_foreach_expression),
        ),
      ),

    _generic_foreach_call: ($) =>
      prec(
        PREC.KEYWORD,
        seq(
          $._generic_primary_expression,
          $._member_access_operator,
          $._foreach_member_name,
          choice($.script_block_expression, $.argument_list),
        ),
      ),

    // Native rejects a space between the generic type arguments and `(`.
    _generic_call_arguments: ($) =>
      seq(
        alias(token.immediate('('), '('),
        field('argument_expression_list', optional($.argument_expression_list)),
        ')',
      ),

    argument_expression_list: ($) =>
      prec.left(
        seq($.argument_expression, repeat(seq(',', $.argument_expression))),
      ),

    // Method call arguments. A comma separates the arguments, so this copy of
    // the `_expression` chain has no comma arrays (an operand may still be a
    // unary `,x`). Unlike the attribute and class-default copies it has its
    // own visible node names, which the converter maps separately.
    argument_expression: ($) =>
      choice($.logical_argument_expression, $.ternary_argument_expression),

    ternary_argument_expression: ($) =>
      prec.right(
        seq(
          field('condition', $.logical_argument_expression),
          '?',
          field(
            'consequence',
            choice($.logical_argument_expression, $.ternary_argument_expression),
          ),
          ':',
          field(
            'alternative',
            choice($.logical_argument_expression, $.ternary_argument_expression),
          ),
        ),
      ),

    logical_argument_expression: ($) =>
      prec.left(
        choice(
          $.bitwise_argument_expression,
          seq(
            $.logical_argument_expression,
            choice(
              reservedWord('-and'),
              reservedWord('-or'),
              reservedWord('-xor'),
            ),
            $.bitwise_argument_expression,
          ),
        ),
      ),

    bitwise_argument_expression: ($) =>
      prec.left(
        choice(
          $.comparison_argument_expression,
          seq(
            $.bitwise_argument_expression,
            choice(
              reservedWord('-band'),
              reservedWord('-bor'),
              reservedWord('-bxor'),
            ),
            $.comparison_argument_expression,
          ),
        ),
      ),

    comparison_argument_expression: ($) =>
      prec.left(
        choice(
          $.additive_argument_expression,
          $.null_coalescing_argument_expression,
          seq(
            $.comparison_argument_expression,
            $.comparison_operator,
            choice(
              $.additive_argument_expression,
              $.null_coalescing_argument_expression,
            ),
          ),
        ),
      ),

    null_coalescing_argument_expression: ($) =>
      prec.left(
        seq(
          choice(
            $.additive_argument_expression,
            $.null_coalescing_argument_expression,
          ),
          '??',
          $.additive_argument_expression,
        ),
      ),

    additive_argument_expression: ($) =>
      prec.left(
        choice(
          $.multiplicative_argument_expression,
          seq(
            $.additive_argument_expression,
            choice('+', choice('-', alias($._unicode_minus, '-'))),
            $.multiplicative_argument_expression,
          ),
        ),
      ),

    multiplicative_argument_expression: ($) =>
      prec.left(
        choice(
          $.format_argument_expression,
          seq(
            $.multiplicative_argument_expression,
            choice('/', '\\', '%', '*'),
            $.format_argument_expression,
          ),
        ),
      ),

    format_argument_expression: ($) =>
      prec.left(
        choice(
          $.range_argument_expression,
          seq(
            $.format_argument_expression,
            $.format_operator,
            $.range_argument_expression,
          ),
        ),
      ),

    range_argument_expression: ($) =>
      prec.left(
        choice(
          $.unary_expression,
          seq($.range_argument_expression, '..', $.unary_expression),
        ),
      ),

    type_literal: ($) =>
      seq('[', $.type_spec, optional($.assembly_qualifier), ']'),

    assembly_qualifier: ($) => token(ASSEMBLY_QUALIFIER),

    type_spec: ($) =>
      choice(
        $._array_type_spec,
        $._generic_type_spec,
        $.type_name,
      ),

    _array_type_spec: ($) =>
      seq($.array_type_name, optional($.dimension), ']'),

    _generic_type_spec: ($) =>
      seq($.generic_type_name, $.generic_type_arguments, ']'),

    dimension: ($) => repeat1(','),

    // Wrapping member_name makes `$x.Foo[$i]` (element access) and `$x.Foo[T]()`
    // a reduce/reduce conflict that the bracket contents decide.
    _generic_method_name: ($) => $.member_name,

    // Native rejects a bracketed type here, unlike in `generic_type_arguments`.
    generic_method_arguments: ($) =>
      seq('[', $.type_spec, repeat(seq(',', $.type_spec)), ']'),

    // `Dictionary[[string], [string]]`: an argument may be in brackets
    generic_type_arguments: ($) =>
      seq(
        choice($.type_spec, $.type_literal),
        repeat(seq(',', choice($.type_spec, $.type_literal))),
      ),

    // Attributes
    attribute_list: ($) => repeat1($.attribute),

    attribute: ($) =>
      choice($._attribute_with_arguments, $.type_literal),

    _attribute_with_arguments: ($) =>
      seq(
        '[',
        $.attribute_name,
        '(',
        optional($.attribute_arguments),
        ')',
        ']',
      ),

    attribute_name: ($) => $.type_spec,

    // Native accepts one empty argument before a named or bare-name first
    // argument; a leading comma before an expression is a unary comma.
    attribute_arguments: ($) =>
      choice(
        seq($.attribute_argument, repeat(seq(',', $.attribute_argument))),
        seq(
          ',',
          alias($._attribute_name_argument, $.attribute_argument),
          repeat(seq(',', $.attribute_argument)),
        ),
      ),

    attribute_argument: ($) =>
      choice($._attribute_expression, $._attribute_name_argument),

    _attribute_name_argument: ($) =>
      seq($.simple_name, optional(seq('=', $._attribute_expression))),

    // Attribute commas separate arguments, not array elements. Keep the normal
    // expression node names so existing attribute CSTs remain unchanged.
    // Unlike `_expression` this copy has no comma arrays and no `??` level,
    // and a type literal operand stays a value instead of starting a cast
    // (see _attribute_type_value).
    _attribute_expression: ($) =>
      choice(
        alias($._attribute_logical_expression, $.logical_expression),
        alias($._attribute_ternary_expression, $.ternary_expression),
      ),

    _attribute_ternary_expression: ($) =>
      prec.right(
        seq(
          field(
            'condition',
            alias($._attribute_logical_expression, $.logical_expression),
          ),
          '?',
          field('consequence', $._attribute_expression),
          ':',
          field('alternative', $._attribute_expression),
        ),
      ),

    _attribute_logical_expression: ($) =>
      prec.left(choice(
        alias($._attribute_bitwise_expression, $.bitwise_expression),
        seq(
          alias($._attribute_logical_expression, $.logical_expression),
          choice(reservedWord('-and'), reservedWord('-or'), reservedWord('-xor')),
          alias($._attribute_bitwise_expression, $.bitwise_expression),
        ),
      )),

    _attribute_bitwise_expression: ($) =>
      prec.left(choice(
        alias($._attribute_comparison_expression, $.comparison_expression),
        seq(
          alias($._attribute_bitwise_expression, $.bitwise_expression),
          choice(reservedWord('-band'), reservedWord('-bor'), reservedWord('-bxor')),
          alias($._attribute_comparison_expression, $.comparison_expression),
        ),
      )),

    _attribute_comparison_expression: ($) =>
      prec.left(choice(
        alias($._attribute_additive_expression, $.additive_expression),
        seq(
          alias($._attribute_comparison_expression, $.comparison_expression),
          $.comparison_operator,
          alias($._attribute_additive_expression, $.additive_expression),
        ),
      )),

    _attribute_additive_expression: ($) =>
      prec.left(choice(
        alias($._attribute_multiplicative_expression, $.multiplicative_expression),
        seq(
          alias($._attribute_additive_expression, $.additive_expression),
          choice('+', choice('-', alias($._unicode_minus, '-'))),
          alias($._attribute_multiplicative_expression, $.multiplicative_expression),
        ),
      )),

    _attribute_multiplicative_expression: ($) =>
      prec.left(choice(
        alias($._attribute_format_expression, $.format_expression),
        seq(
          alias($._attribute_multiplicative_expression, $.multiplicative_expression),
          choice('/', '\\', '%', '*'),
          alias($._attribute_format_expression, $.format_expression),
        ),
      )),

    _attribute_format_expression: ($) =>
      prec.left(choice(
        alias($._attribute_range_expression, $.range_expression),
        seq(
          alias($._attribute_format_expression, $.format_expression),
          $.format_operator,
          alias($._attribute_range_expression, $.range_expression),
        ),
      )),

    _attribute_range_expression: ($) =>
      prec.left(choice(
        alias($._attribute_array_literal_expression, $.array_literal_expression),
        seq(
          alias($._attribute_range_expression, $.range_expression),
          '..',
          alias($._attribute_array_literal_expression, $.array_literal_expression),
        ),
      )),

    _attribute_array_literal_expression: ($) =>
      choice(
        $.unary_expression,
        alias($._attribute_type_value, $.unary_expression),
      ),

    // Prefer a complete type value to a cast of a comma-prefixed array here.
    _attribute_type_value: ($) => prec(PREC.CAST + 1, $.type_literal),
  },
});

// Empty scope after the sigil: `$:name`, `$::` and `$::name` (`$:` alone is invalid).
function emptyScopeVariable() {
  const name = choice(VARIABLE_REFERENCE, '?');
  return seq(':', choice(name, seq(':', optional(name))));
}

// inspired from https://github.com/tree-sitter/tree-sitter/issues/261
/**
 * Creates a rule to match a case insensitive reserved keyword
 *
 * @param {string} word
 */
function reservedWord(word) {
  // return word // when debuging
  return alias(reserved(caseInsensitive(word)), word);
}

/**
 * Like reservedWord, but also any non-empty prefix of the name after the dash,
 * as a switch parameter such as `-c` or `-casesens` is.
 *
 * @param {string} word
 */
function prefixReservedWord(word) {
  const letters = [...word.slice(1)].map((l) => `[${l}${l.toUpperCase()}]`);
  const tail = letters.slice(1).reduceRight((rest, l) => `(?:${l}${rest})?`, '');
  return alias(reserved(`${DASH}${letters[0]}${tail}`), word);
}

/**
 * Create a reserved regex keyword
 *
 * @param {regex} regex
 */
function reserved(regex) {
  return prec(PREC.KEYWORD, new RegExp(regex));
}

/**
 * Return case insensitive regex for a word
 *
 * @param {string} word
 */
function caseInsensitive(word) {
  return word
    .split('')
    .map((letter, i) => (letter === '-' && i === 0 ? DASH : `[${letter}${letter.toUpperCase()}]`))
    .join('');
}

// Unary keyword operators. Native ends a dash word's letters at the first
// non-letter, so `-not$x` and `-not1` are the operator and `-notx` is a name.
/**
 * A word `-Name` (or with an en dash, em dash or horizontal bar) that is not a
 * unary keyword operator, as a regex: its leading run of ASCII letters is not
 * one of the unary keywords.
 */
function dashCommandName() {
  const unaryWords = ['not', 'bnot', 'split', 'csplit', 'isplit', 'join'];
  const letters = 'abcdefghijklmnopqrstuvwxyz';
  const both = (c) => `${c}${c.toUpperCase()}`;
  const rest = `${PARAMETER_CHAR}*`;
  // A parameter character that is not an ASCII letter ends the letter run.
  const nonLetter = PARAMETER_CHAR.replace('[^', '[^A-Za-z');
  const nonAscii = PARAMETER_LETTER.replace('[^\\P{L}', '[^\\P{L}\\x00-\\x7F');

  const walk = (words, root) => {
    const children = new Map();
    for (const w of words) {
      children.set(w[0], [...(children.get(w[0]) || []), w.slice(1)]);
    }
    const alternatives = [];
    const others = [...letters].filter((c) => !children.has(c)).map(both).join('');
    alternatives.push(`[${others}]${rest}`);
    for (const [c, suffixes] of children) {
      alternatives.push(suffixes.includes('') ?
        // The whole keyword needs a longer letter run to be a name.
        `[${both(c)}][A-Za-z]${rest}` :
        `[${both(c)}]${walk(suffixes, false)}`);
    }
    if (root) return `(?:${alternatives.join('|')})`;
    // A letter run that stops inside the keyword is a name.
    alternatives.push(`${nonLetter}${rest}`);
    return `(?:${alternatives.join('|')})?`;
  };

  return new RegExp(`${DASH}(?:${walk(unaryWords, true)}|${nonAscii}${rest})`, 'u');
}
