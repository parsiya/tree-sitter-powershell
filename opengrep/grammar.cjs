const upstream = require('./upstream.cjs');

module.exports = grammar(upstream, {
  name: 'powershell',

  rules: {
    program: ($) => seq(optional($.param_block), optional($.statement_list)),

    variable: ($, previous) => choice($.semgrep_named_ellipsis, previous),

    semgrep_named_ellipsis: ($) => /\$\.\.\.[A-Z_][A-Z_0-9]*/,
  },
});
