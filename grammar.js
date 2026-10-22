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

// Number suffixes are case-insensitive in PowerShell: 1KB, 1kb and 0X1F.
const NUMBER_MULTIPLIER = /[kKmMgGtTpP][bB]/;
const NUMBER_EXPONENT = /[eE][+-]?[0-9]+/;

// Characters that cannot appear in the first part of a command name.
const COMMAND_NAME_STOP = '\\{\\}\\(\\);,\\|\\&`"\'\\u2018-\\u201E\\s\\u00a0\\r\\n\\[\\]\\+\\-\\*\\/\\$@<\\!';
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
const TYPE_IDENTIFIER = VARIABLE_NAME;
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
  ],

  extras: ($) => [
    $.comment,
    /\s/,
    /`\n/,
    /`\r\n/,
    /`[ \t\v\f\r\u0085\u00a0\u1680\u2000-\u200a\u2028\u2029\u202f\u205f\u3000]/,
    /[\uFEFF\u2060\u200B\u00A0]/,
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
  ],

  rules: {
    program: ($) =>
      seq(
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
        seq(/[0-9]+/, optional(/[lLdD]/), optional(NUMBER_MULTIPLIER)),
      ),

    hexadecimal_integer_literal: ($) =>
      token(
        seq(
          /0[xX]/,
          /[0-9a-fA-F]+/,
          optional(/[lL]/),
          optional(NUMBER_MULTIPLIER),
        ),
      ),

    // Real Literals
    real_literal: ($) =>
      token(
        choice(
          seq(
            /[0-9]+\.[0-9]+/,
            optional(NUMBER_EXPONENT),
            optional(NUMBER_MULTIPLIER),
          ),
          seq(
            /\.[0-9]+/,
            optional(NUMBER_EXPONENT),
            optional(NUMBER_MULTIPLIER),
          ),
          seq(/[0-9]+/, NUMBER_EXPONENT, optional(NUMBER_MULTIPLIER)),
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

    expandable_string_literal: ($) =>
      seq(
        DOUBLE_QUOTE,
        repeat(
          choice(
            // Comment markers inside strings are text, not extra comments.
            token.immediate(prec(1, /[^\$"\u201C-\u201E`]+/)),
            $.variable,
            $.sub_expression,
            token.immediate(/\$(`.{1}|`\r?\n|[\s\\])/),
            token.immediate(/`.{1}|`\r?\n/),
            token.immediate(seq(DOUBLE_QUOTE, DOUBLE_QUOTE)),
            token.immediate('$'),
          ),
        ),
        repeat(token.immediate('$')),
        token.immediate(DOUBLE_QUOTE),
      ),

    expandable_here_string_literal: ($) =>
      seq(
        /@["\u201C-\u201E] *\r?\n/,
        choice(
          // An empty here-string closes immediately after its opening newline.
          token.immediate(prec(2, /["\u201C-\u201E]@/)),
          seq(
            repeat(
              choice(
                token.immediate(prec(1, /[^\$\r\n`]+/)),
                $.variable,
                $.sub_expression,
                // Leave the next line's escape or interpolation prefix intact.
                token.immediate(/\r?\n/),
                token.immediate('$'),
                token.immediate(/`.{1}|`\r?\n/),
              ),
            ),
            // Only the final newline belongs to the closing delimiter.
            token.immediate(prec(1, /\r?\n["\u201C-\u201E]@/)),
          ),
        ),
      ),

    verbatim_string_characters: ($) =>
      token(seq(SINGLE_QUOTE, repeat(choice(/[^'\u2018-\u201B]+/, seq(SINGLE_QUOTE, SINGLE_QUOTE))), SINGLE_QUOTE)),

    verbatim_here_string_characters: ($) =>
      token(
        seq(
          /@['\u2018-\u201B][^\S\r\n]*\r?\n/,
          // A content line cannot begin with a closing delimiter. In particular,
          // an empty or blank-only body must not consume a later here-string.
          repeat(seq(
            optional(choice(
              /[^'\u2018-\u201B\r\n][^\r\n]*/,
              seq(SINGLE_QUOTE, optional(/[^@\r\n][^\r\n]*/)),
            )),
            /\r?\n/,
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
      choice('=', '!=', '+=', '*=', '/=', '%=', '-=', '??='),

    file_redirection_operator: ($) =>
      choice(
        '>',
        '>>',
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
        '<',
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
        reservedWord('-csplit'),
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
        reservedWord('-isplit'),
        reservedWord('-join'),
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
        reservedWord('-split'),
      ),

    format_operator: ($) => reservedWord('-f'),

    // Variables
    variable: ($) =>
      choice(
        '$$',
        '$^',
        '$?',
        '$_',
        token(
          seq(
            '$',
            optional(
              seq(
                choice(
                  reservedWord('global:'),
                  reservedWord('local:'),
                  reservedWord('private:'),
                  reservedWord('script:'),
                  reservedWord('using:'),
                  reservedWord('workflow:'),
                  VARIABLE_NAME,
                ),
                ':',
              ),
            ),
            choice(VARIABLE_REFERENCE, '?'),
          ),
        ),
        token(
          seq(
            '@',
            optional(
              seq(
                choice(
                  reservedWord('global:'),
                  reservedWord('local:'),
                  reservedWord('private:'),
                  reservedWord('script:'),
                  reservedWord('using:'),
                  reservedWord('workflow:'),
                  VARIABLE_NAME,
                ),
                ':',
              ),
            ),
            choice(VARIABLE_REFERENCE, '?'),
          ),
        ),
        $.braced_variable,
      ),

    braced_variable: ($) => /\$\{[^}]+\}/,

    // Commands
    // A word cannot start like a redirection (`>`, `2>`, `*>`), so that
    // `tool arg 2>$null` ends the word before the redirection. Inside a word,
    // `>` is an ordinary character: `a=b>c` is one argument.
    generic_token: ($) =>
      choice(
        token(
          choice(
            /[^\(\)\$\"\'\u2018-\u201E\+\-\{\}@\|\[`\&:\s\u00a0>0-9*][^"'\u2018-\u201E\&\s\u00a0\(\)\}\|;,]*/,
            /[0-9*]([^"'\u2018-\u201E\&\s\u00a0\(\)\}\|;,>][^"'\u2018-\u201E\&\s\u00a0\(\)\}\|;,]*)?/,
            // Percentages are words in argument mode, not unary expressions.
            /-(?:[0-9]|\.[0-9])[^\&\s\u00a0\(\)\}\|;,]*%[^\&\s\u00a0\(\)\}\|;,]*/,
          ),
        ),
        seq(
          // After lexer extras, '+' must still start a word, not unary plus.
          choice(
            $._command_word_start,
            token(prec(1, /\+[^\s\u00a0"'\u2018-\u201E`$(){}|;,&]*/)),
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
    _command_token: ($) => token(/[^\(\)\{\}\s\u00a0;\&"'\u2018-\u201E][^\(\)\{\}\s\u00a0;\&]*/),

    // Parameters
    command_parameter: ($) =>
      choice(
        token(
          choice(
            // `-Name`, `-Name1`, `--long-flag`, `-A5`
            new RegExp(
              String.raw`-+(${PARAMETER_LETTER}|[_?\x60-])${PARAMETER_CHAR}*`,
              'u',
            ),
            // `--format=%H`, `--pretty=format:"%B"`: a native option with an attached value
            seq(
              new RegExp(String.raw`--?(${PARAMETER_LETTER}|_)${PARAMETER_CHAR}*=`, 'u'),
              repeat(choice(
                /[^\s\u00a0"'\u2018-\u201E`;|&(){}]/,
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

    script_parameter_default: ($) => seq('=', $._expression),

    script_block_body: ($) =>
      choice(
        field('named_block_list', $.named_block_list),
        field('statement_list', $.statement_list),
      ),

    named_block_list: ($) => repeat1($.named_block),

    named_block: ($) => seq($.block_name, $.statement_block),

    block_name: ($) =>
      choice(
        reservedWord('dynamicparam'),
        reservedWord('begin'),
        reservedWord('process'),
        reservedWord('end'),
      ),

    statement_block: ($) =>
      seq('{', field('statement_list', optional($.statement_list)), '}'),

    statement_list: ($) => repeat1($._statement),

    _statement: ($) =>
      prec.right(
        choice(
          $.if_statement,
          seq(optional($.label), $._labeled_statement),
          $.function_statement,
          $.class_statement,
          $.enum_statement,
          seq($.flow_control_statement, $._statement_terminator),
          $.trap_statement,
          $.try_statement,
          $.data_statement,
          $.inlinescript_statement,
          $.parallel_statement,
          $.sequence_statement,
          seq($.pipeline, $._statement_terminator),
          // `npm run dev &` (PowerShell 7): runs the pipeline as a background job
          seq($.pipeline, $.background_operator),
          $.empty_statement,
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
        reservedWord('-regex'),
        reservedWord('-wildcard'),
        reservedWord('-exact'),
        reservedWord('-casesensitive'),
        reservedWord('-parallel'),
      ),

    switch_condition: ($) =>
      choice(
        seq('(', $.pipeline, ')'),
        seq(reservedWord('-file'), $.switch_filename),
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
      choice($._command_token, $._primary_expression),

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

    foreach_parameter: ($) => choice(reservedWord('-parallel')),

    for_statement: ($) =>
      seq(
        reservedWord('for'),
        '(',
        optional(
          seq(
            optional(
              seq(
                field('for_initializer', $.for_initializer),
                $._statement_terminator,
              ),
            ),
            optional(
              seq(
                choice(';', token.immediate(/\r?\n/)),
                optional(
                  seq(
                    field('for_condition', $.for_condition),
                    $._statement_terminator,
                  ),
                ),
                optional(
                  seq(
                    choice(';', token.immediate(/\r?\n/)),
                    optional(
                      seq(
                        field('for_iterator', $.for_iterator),
                        $._statement_terminator,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        ')',
        $.statement_block,
      ),

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
          reservedWord('function'),
          reservedWord('filter'),
          reservedWord('workflow'),
        ),
        $.function_name,
        optional($.function_parameter_declaration),
        '{',
        optional($.script_block),
        '}',
      ),

    function_name: ($) => $._command_token,

    function_parameter_declaration: ($) =>
      seq('(', optional($.parameter_list), ')'),

    flow_control_statement: ($) =>
      choice(
        seq(reservedWord('break'), optional($.label_expression)),
        seq(reservedWord('continue'), optional($.label_expression)),
        seq(reservedWord('throw'), optional($.pipeline)),
        seq(reservedWord('return'), optional($.pipeline)),
        seq(reservedWord('exit'), optional($.pipeline)),
      ),

    label: ($) => token(seq(':', /[a-zA-Z_][a-zA-Z0-9_]*/)),

    label_expression: ($) => choice($.label, $.simple_name, $.unary_expression),

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

    catch_clauses: ($) => repeat1($.catch_clause),

    catch_clause: ($) =>
      seq(
        reservedWord('catch'),
        optional($.catch_type_list),
        $.statement_block,
      ),

    catch_type_list: ($) =>
      seq($.type_literal, repeat(seq(',', $.type_literal))),

    finally_clause: ($) => seq(reservedWord('finally'), $.statement_block),

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

    inlinescript_statement: ($) =>
      seq(reservedWord('inlinescript'), $.statement_block),

    parallel_statement: ($) => seq(reservedWord('parallel'), $.statement_block),

    sequence_statement: ($) => seq(reservedWord('sequence'), $.statement_block),

    pipeline: ($) =>
      choice(
        $.assignment_expression,
        seq(
          $.pipeline_chain,
          repeat(seq($.pipeline_chain_tail, $.pipeline_chain)),
        ),
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
        field('value', $._statement),
      ),

    _pipeline_tail: ($) => repeat1(seq('|', $.command)),

    command: ($) =>
      choice(
        seq(
          field('command_name', $.command_name),
          field('command_elements', optional($.command_elements)),
        ),
        seq(
          $.command_invokation_operator,
          // optional($.command_module),
          field('command_name', $.command_name_expr),
          field('command_elements', optional($.command_elements)),
        ),
      ),

    command_invokation_operator: ($) => choice('.', '&'),

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
        repeat(
          choice(
            token.immediate(/[^\{\}\(\);,\|\&`"'\u2018-\u201E\s\u00a0\r\n]+/),
            $._command_name_escape,
            seq(token.immediate(DOUBLE_QUOTE), $._expandable_string_literal_immediate),
            seq(token.immediate(SINGLE_QUOTE), $._string_literal_immediate),
            token.immediate(seq(DOUBLE_QUOTE, DOUBLE_QUOTE)),
            token.immediate(seq(SINGLE_QUOTE, SINGLE_QUOTE)),
          ),
        ),
      ),

    command_name: ($) => choice($._slash_command_name, $._ordinary_command_name),

    _ordinary_command_name: ($) =>
      seq(
        choice(
          // At a token boundary escaped whitespace is trivia, not a name.
          $._command_name_start_escape,
          new RegExp(`[^${COMMAND_NAME_STOP}0-9][^${COMMAND_NAME_STOP}]*`),
          // A name can start with digits (`7z`), but digits followed by `..`
          // start a range (`1..16`), not a command.
          new RegExp(
            `[0-9]+([^${COMMAND_NAME_STOP}0-9.]|\\.[^${COMMAND_NAME_STOP}.])` +
              `[^${COMMAND_NAME_STOP}]*`,
          ),
          // tree-sitter does not allow to control lexer
          // each start keyword into _statement rule must be present here
          // https://github.com/airbus-cert/tree-sitter-powershell/issues/24
          new RegExp(caseInsensitive('break-')),
          new RegExp(caseInsensitive('continue-')),
          new RegExp(caseInsensitive('throw-')),
          // Adjacent @ and $ continue literal command names, not return statements.
          new RegExp(caseInsensitive('return') + '[-@$]'),
          new RegExp(caseInsensitive('exit-')),
          new RegExp(caseInsensitive('try-')),
          new RegExp(caseInsensitive('trap-')),
          new RegExp(caseInsensitive('if-')),
          new RegExp(caseInsensitive('function-')),
          new RegExp(caseInsensitive('filter-')),
          new RegExp(caseInsensitive('workflow-')),
          new RegExp(caseInsensitive('class-')),
          new RegExp(caseInsensitive('enum-')),
          new RegExp(caseInsensitive('switch-')),
          new RegExp(caseInsensitive('for-')),
          new RegExp(caseInsensitive('foreach-')),
          new RegExp(caseInsensitive('while-')),
          new RegExp(caseInsensitive('parallel-')),
          new RegExp(caseInsensitive('using-')),
          new RegExp(caseInsensitive('begin-')),
          new RegExp(caseInsensitive('process-')),
          new RegExp(caseInsensitive('end-')),
          new RegExp(caseInsensitive('dynamicparam-')),
        ),
        repeat(
          choice(
            token.immediate(/[^\{\}\(\);,\|\&`"'\u2018-\u201E\s\u00a0\r\n]+/),
            $._command_name_escape,
            seq(token.immediate(DOUBLE_QUOTE), $._expandable_string_literal_immediate),
            seq(token.immediate(SINGLE_QUOTE), $._string_literal_immediate),
            token.immediate(seq(DOUBLE_QUOTE, DOUBLE_QUOTE)),
            token.immediate(seq(SINGLE_QUOTE, SINGLE_QUOTE)),
          ),
        ),
      ),

    path_command_name_token: ($) => /[0-9a-zA-Z_?\-\.\\\/]+/,

    // Use to parse command path
    path_command_name: ($) =>
      seq(
        choice($.path_command_name_token, $.variable),
        repeat(seq(
          $._path_command_name_continuation,
          choice(
            $.path_command_name_token,
            $.variable,
            seq(token.immediate(DOUBLE_QUOTE), $._expandable_string_literal_immediate),
            seq(token.immediate(SINGLE_QUOTE), $._string_literal_immediate),
            token.immediate(seq(DOUBLE_QUOTE, DOUBLE_QUOTE)),
            token.immediate(seq(SINGLE_QUOTE, SINGLE_QUOTE)),
            $._command_name_escape,
          ),
        )),
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
                alias(token(prec(1, /[\t\v\f\u00a0]+/)), $.command_argument_sep),
              )),
              $._command_parameter_argument,
            )),
          ),
          prec.dynamic(1, $._adjacent_expression_arguments),
          seq($._command_argument, optional($.argument_list)),
          seq(
            $.command_argument_sep,
            $.generic_token,
            alias(token.immediate(/[\t\v\f]+/), $.command_argument_sep),
            $._argument_after_quote,
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

    // Stop parsing is a token that end the parsing of command line
    stop_parsing: ($) => /--%[^\r\n]*/,

    // A colon is a separator only immediately after a command parameter.
    command_argument_sep: ($) => prec.right(/[ \u00a0]+/),

    _command_word: ($) => choice($.generic_token, $.colon_command_argument),

    _command_parameter_argument: ($) =>
      choice(
        seq(
          choice($._command_word, $.parameter_argument_word),
          repeat(seq(',', choice($._command_word, $.unary_expression))),
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
        $.array_literal_expression,
      ),

    // Dash-leading tokens are strings, not new parameters or unary expressions,
    // when a parameter colon has requested a value.
    parameter_argument_word: ($) => token.immediate(prec(1, new RegExp(
      String.raw`-+(?:${PARAMETER_LETTER}|[_?\x60-])${PARAMETER_CHAR}*:?|-[0-9.][^\s\u00a0"'\u2018-\u201E\x60$(){}|;,&]*|-`,
      'u',
    ))),

    // A colon starts a new command word after an expression, not a member suffix.
    // Only the immediate colon following a parameter is an attachment separator.
    colon_command_argument: ($) =>
      choice(
        // Label-like words remain literal: `:word$value` does not expand.
        alias(token(new RegExp(
          `:(?:${PARAMETER_LETTER}|_)[^\\s\\u00a0(){}|;&,]*`,
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
        token.immediate(prec(1, /[^\s\u00a0"'\u2018-\u201E`$();|&,{}]+/)),
        // CLI 0.22 misreads the union of \s and \S inside a character class.
        token.immediate(/`[^\r\n]|`[\r\n]/),
      ),

    // Adapt the grammar to have same behavior

    _command_argument: ($) =>
      prec.right(
        PREC.PARAM,
        choice(
          seq(
            $.command_argument_sep,
            optional(
              seq(
                $._command_word,
                // `Select-Object Id, Name`: an unquoted comma list is one array argument
                repeat(seq(',', choice($._command_word, $.unary_expression))),
              ),
            ),
          ),
          seq($.command_argument_sep, $.array_literal_expression),
          // `New-Object T "a", $b, word`: a comma list that starts with an
          // expression and has unquoted words. array_literal_expression wins
          // when both match.
          prec.dynamic(
            -1,
            seq(
              $.command_argument_sep,
              $.unary_expression,
              repeat1(seq(',', choice($._command_word, $.unary_expression))),
            ),
          ),
          seq(
            $.colon_command_argument,
            repeat(seq(',', choice($._command_word, $.unary_expression))),
          ),
          $.parenthesized_expression,
          $.script_block_expression,
        ),
      ),

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
        ),
      ),

    _completed_command_argument: ($) =>
      alias($._completed_argument_array, $.array_literal_expression),

    _completed_argument_array: ($) =>
      choice(
        seq(
          alias($._completed_argument_value, $.unary_expression),
          $._completed_expression_boundary,
        ),
        seq(
          alias($._completed_argument_member, $.unary_expression),
          $._completed_member_boundary,
        ),
      ),

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

    _completed_argument_member: ($) => $.member_access,

    _argument_after_quote: ($) =>
      choice(
        seq(
          $._command_word,
          repeat(seq(',', choice($._command_word, $.unary_expression))),
        ),
        $.array_literal_expression,
        seq($._completed_command_argument, $._argument_after_quote),
        seq(
          $.quoted_command_argument,
          $._quoted_argument_boundary,
          $._argument_after_quote,
        ),
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

    class_method_parameter: ($) => seq(optional($.type_literal), $.variable),

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
            choice('+', '-'),
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
        choice($._primary_expression, $.expression_with_unary_operator),
      ),

    expression_with_unary_operator: ($) =>
      choice(
        seq(',', $.unary_expression),
        seq(reservedWord('-not'), $.unary_expression),
        seq('!', $.unary_expression),
        seq(reservedWord('-bnot'), $.unary_expression),
        seq('+', $.unary_expression),
        seq('-', $.unary_expression),
        $.pre_increment_expression,
        $.pre_decrement_expression,
        $.cast_expression,
        $.attributed_expression,
        seq(reservedWord('-split'), $.unary_expression),
        seq(reservedWord('-join'), $.unary_expression),
      ),

    pre_increment_expression: ($) => seq('++', $.unary_expression),
    pre_decrement_expression: ($) => seq('--', $.unary_expression),

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
      seq('$(', field('statements', optional($.statement_list)), ')'),

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
      prec(PREC.UNARY, seq($._primary_expression, '--')),

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

    argument_expression_list: ($) =>
      prec.left(
        seq($.argument_expression, repeat(seq(',', $.argument_expression))),
      ),

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
            choice('+', '-'),
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

    type_literal: ($) => seq('[', $.type_spec, ']'),

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

    attribute_arguments: ($) =>
      seq($.attribute_argument, repeat(seq(',', $.attribute_argument))),

    attribute_argument: ($) =>
      choice(
        $._attribute_expression,
        seq($.simple_name, optional(seq('=', $._attribute_expression))),
      ),

    // Attribute commas separate arguments, not array elements. Keep the normal
    // expression node names so existing attribute CSTs remain unchanged.
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
          choice('+', '-'),
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
    .map((letter) => `[${letter}${letter.toUpperCase()}]`)
    .join('');
}
