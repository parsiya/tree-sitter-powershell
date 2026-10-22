(**
   Boilerplate to be used as a template when mapping the powershell CST
   to another type of tree.
*)

module R = Tree_sitter_run.Raw_tree

(* Disable warnings against unused variables *)
[@@@warning "-26-27"]

(* Disable warning against unused 'rec' *)
[@@@warning "-39"]

type env = unit

let token (env : env) (tok : Tree_sitter_run.Token.t) =
  R.Token tok

let blank (env : env) () =
  R.Tuple []

let map_tok_pat_f2b7187 (env : env) (tok : CST.tok_pat_f2b7187) =
  (* tok_pat_f2b7187 *) token env tok

let map_pat_filter_ (env : env) (tok : CST.pat_filter_) =
  (* pattern [fF][iI][lL][tT][eE][rR][--] *) token env tok

let map_imm_tok_pat_421479c (env : env) (tok : CST.imm_tok_pat_421479c) =
  (* pattern "[\"\\u201C-\\u201E]" *) token env tok

let map_pat_6a8c7a7 (env : env) (tok : CST.pat_6a8c7a7) =
  (* pattern [ \u00a0]+ *) token env tok

let map_pat__cnotcs (env : env) (tok : CST.pat__cnotcs) =
  (* pattern [--][cC][nN][oO][tT][cC][oO][nN][tT][aA][iI][nN][sS] *) token env tok

let map_pat_func (env : env) (tok : CST.pat_func) =
  (* pattern [fF][uU][nN][cC][tT][iI][oO][nN] *) token env tok

let map_path_command_name_token (env : env) (tok : CST.path_command_name_token) =
  (* pattern [0-9a-zA-Z_?\-\.\\\/]+ *) token env tok

let map_pat__cnot_ (env : env) (tok : CST.pat__cnot_) =
  (* pattern [--][cC][nN][oO][tT][mM][aA][tT][cC][hH] *) token env tok

let map_pat_func_ (env : env) (tok : CST.pat_func_) =
  (* pattern [fF][uU][nN][cC][tT][iI][oO][nN][--] *) token env tok

let map_pat__cnot (env : env) (tok : CST.pat__cnot) =
  (* pattern [--][cC][nN][oO][tT][lL][iI][kK][eE] *) token env tok

let map_pat__or (env : env) (tok : CST.pat__or) =
  (* pattern [--][oO][rR] *) token env tok

let map_pat_exit_ (env : env) (tok : CST.pat_exit_) =
  (* pattern [eE][xX][iI][tT][--] *) token env tok

let map_pat__ilike (env : env) (tok : CST.pat__ilike) =
  (* pattern [--][iI][lL][iI][kK][eE] *) token env tok

let map_pat__notcos (env : env) (tok : CST.pat__notcos) =
  (* pattern [--][nN][oO][tT][cC][oO][nN][tT][aA][iI][nN][sS] *) token env tok

let map_pat_work (env : env) (tok : CST.pat_work) =
  (* pattern [wW][oO][rR][kK][fF][lL][oO][wW] *) token env tok

let map_pat_cont_ (env : env) (tok : CST.pat_cont_) =
  (* pattern [cC][oO][nN][tT][iI][nN][uU][eE][--] *) token env tok

let map_pat__supp (env : env) (tok : CST.pat__supp) =
  (* pattern [--][sS][uU][pP][pP][oO][rR][tT][eE][dD][cC][oO][mM][mM][aA][nN][dD] *) token env tok

let map_pat_throw (env : env) (tok : CST.pat_throw) =
  (* pattern [tT][hH][rR][oO][wW] *) token env tok

let map_pat_begin_ (env : env) (tok : CST.pat_begin_) =
  (* pattern [bB][eE][gG][iI][nN][--] *) token env tok

let map_pat_switch_ (env : env) (tok : CST.pat_switch_) =
  (* pattern [sS][wW][iI][tT][cC][hH][--] *) token env tok

let map_tok_choice_pat_1bbb0cf (env : env) (tok : CST.tok_choice_pat_1bbb0cf) =
  (* tok_choice_pat_1bbb0cf *) token env tok

let map_trailing_dot_type_name (env : env) (tok : CST.trailing_dot_type_name) =
  (* trailing_dot_type_name *) token env tok

let map_pat_name (env : env) (tok : CST.pat_name) =
  (* pattern [nN][aA][mM][eE][sS][pP][aA][cC][eE] *) token env tok

let map_imm_tok_pat_7fb0419 (env : env) (tok : CST.imm_tok_pat_7fb0419) =
  (* pattern [\t\v\f]+ *) token env tok

let map_pat__in (env : env) (tok : CST.pat__in) =
  (* pattern [--][iI][nN] *) token env tok

let map_pat__not (env : env) (tok : CST.pat__not) =
  (* pattern [--][nN][oO][tT] *) token env tok

let map_anon_choice_PLUS_da42005 (env : env) (x : CST.anon_choice_PLUS_da42005) =
  (match x with
  | `PLUS tok -> R.Case ("PLUS",
      (* "+" *) token env tok
    )
  | `DASH tok -> R.Case ("DASH",
      (* "-" *) token env tok
    )
  )

let map_pat_421479c (env : env) (tok : CST.pat_421479c) =
  (* pattern "[\"\\u201C-\\u201E]" *) token env tok

let map_tok_prec_p1_pat_enum (env : env) (tok : CST.tok_prec_p1_pat_enum) =
  (* tok_prec_p1_pat_enum *) token env tok

let map_pat_begin (env : env) (tok : CST.pat_begin) =
  (* pattern [bB][eE][gG][iI][nN] *) token env tok

let map_anon_choice_SLASH_4ca1f7c (env : env) (x : CST.anon_choice_SLASH_4ca1f7c) =
  (match x with
  | `SLASH tok -> R.Case ("SLASH",
      (* "/" *) token env tok
    )
  | `BSLASH tok -> R.Case ("BSLASH",
      (* "\\" *) token env tok
    )
  | `PERC tok -> R.Case ("PERC",
      (* "%" *) token env tok
    )
  | `STAR tok -> R.Case ("STAR",
      (* "*" *) token env tok
    )
  )

let map_command_invokation_operator (env : env) (x : CST.command_invokation_operator) =
  (match x with
  | `DOT tok -> R.Case ("DOT",
      (* "." *) token env tok
    )
  | `AMP tok -> R.Case ("AMP",
      (* "&" *) token env tok
    )
  )

let map_else_clause_ahead (env : env) (tok : CST.else_clause_ahead) =
  (* else_clause_ahead *) token env tok

let map_pat__is (env : env) (tok : CST.pat__is) =
  (* pattern [--][iI][sS] *) token env tok

let map_pat_using_ (env : env) (tok : CST.pat_using_) =
  (* pattern [uU][sS][iI][nN][gG][--] *) token env tok

let map_pat__ilt (env : env) (tok : CST.pat__ilt) =
  (* pattern [--][iI][lL][tT] *) token env tok

let map_pat_filter (env : env) (tok : CST.pat_filter) =
  (* pattern [fF][iI][lL][tT][eE][rR] *) token env tok

let map_tok_dollar_choice_choice_prec_p1_pat_0705c16_colon_choice_pat_b2ccb50 (env : env) (tok : CST.tok_dollar_choice_choice_prec_p1_pat_0705c16_colon_choice_pat_b2ccb50) =
  (* tok_dollar_choice_choice_prec_p1_pat_0705c16_colon_choice_pat_b2ccb50 *) token env tok

let map_pat__and (env : env) (tok : CST.pat__and) =
  (* pattern [--][aA][nN][dD] *) token env tok

let map_pat__cmatch (env : env) (tok : CST.pat__cmatch) =
  (* pattern [--][cC][mM][aA][tT][cC][hH] *) token env tok

let map_command_word_expression (env : env) (tok : CST.command_word_expression) =
  (* command_word_expression *) token env tok

let map_pat__cnotin (env : env) (tok : CST.pat__cnotin) =
  (* pattern [--][cC][nN][oO][tT][iI][nN] *) token env tok

let map_semgrep_named_ellipsis (env : env) (tok : CST.semgrep_named_ellipsis) =
  (* pattern \$\.\.\.[A-Z_][A-Z_0-9]* *) token env tok

let map_type_identifier (env : env) (tok : CST.type_identifier) =
  (* type_identifier *) token env tok

let map_pat__le (env : env) (tok : CST.pat__le) =
  (* pattern [--][lL][eE] *) token env tok

let map_pat_end (env : env) (tok : CST.pat_end) =
  (* pattern [eE][nN][dD] *) token env tok

let map_pat_fore (env : env) (tok : CST.pat_fore) =
  (* pattern [fF][oO][rR][eE][aA][cC][hH] *) token env tok

let map_pat_in (env : env) (tok : CST.pat_in) =
  (* pattern [iI][nN] *) token env tok

let map_pat_until (env : env) (tok : CST.pat_until) =
  (* pattern [uU][nN][tT][iI][lL] *) token env tok

let map_pat__ine (env : env) (tok : CST.pat__ine) =
  (* pattern [--][iI][nN][eE] *) token env tok

let map_pat__notl (env : env) (tok : CST.pat__notl) =
  (* pattern [--][nN][oO][tT][lL][iI][kK][eE] *) token env tok

let map_completed_member_boundary (env : env) (tok : CST.completed_member_boundary) =
  (* completed_member_boundary *) token env tok

let map_single_command_parameter (env : env) (tok : CST.single_command_parameter) =
  (* single_command_parameter *) token env tok

let map_colon_word_continuation (env : env) (tok : CST.colon_word_continuation) =
  (* colon_word_continuation *) token env tok

let map_pat_dyna (env : env) (tok : CST.pat_dyna) =
  (* pattern [dD][yY][nN][aA][mM][iI][cC][pP][aA][rR][aA][mM] *) token env tok

let map_simple_name (env : env) (tok : CST.simple_name) =
  (* simple_name *) token env tok

let map_pat_proc (env : env) (tok : CST.pat_proc) =
  (* pattern [pP][rR][oO][cC][eE][sS][sS] *) token env tok

let map_pat__ige (env : env) (tok : CST.pat__ige) =
  (* pattern [--][iI][gG][eE] *) token env tok

let map_pat_trap_ (env : env) (tok : CST.pat_trap_) =
  (* pattern [tT][rR][aA][pP][--] *) token env tok

let map_imm_tok_prec_p1_pat_b45f689 (env : env) (tok : CST.imm_tok_prec_p1_pat_b45f689) =
  (* pattern [^\$\r\n`]+ *) token env tok

let map_pat__shr (env : env) (tok : CST.pat__shr) =
  (* pattern [--][sS][hH][rR] *) token env tok

let map_pat_fore_ (env : env) (tok : CST.pat_fore_) =
  (* pattern [fF][oO][rR][eE][aA][cC][hH][--] *) token env tok

let map_tok_prec_p1_pat_hidden (env : env) (tok : CST.tok_prec_p1_pat_hidden) =
  (* tok_prec_p1_pat_hidden *) token env tok

let map_pat_brk (env : env) (tok : CST.pat_brk) =
  (* pattern [bB][rR][eE][aA][kK] *) token env tok

let map_pat__notin (env : env) (tok : CST.pat__notin) =
  (* pattern [--][nN][oO][tT][iI][nN] *) token env tok

let map_pat__notm (env : env) (tok : CST.pat__notm) =
  (* pattern [--][nN][oO][tT][mM][aA][tT][cC][hH] *) token env tok

let map_pat__lt (env : env) (tok : CST.pat__lt) =
  (* pattern [--][lL][tT] *) token env tok

let map_command_word_part (env : env) (tok : CST.command_word_part) =
  (* command_word_part *) token env tok

let map_tok_prec_p1_pat_fb4042a (env : env) (tok : CST.tok_prec_p1_pat_fb4042a) =
  (* tok_prec_p1_pat_fb4042a *) token env tok

let map_pat_base (env : env) (tok : CST.pat_base) =
  (* pattern [bB][aA][sS][eE] *) token env tok

let map_pat_module (env : env) (tok : CST.pat_module) =
  (* pattern [mM][oO][dD][uU][lL][eE] *) token env tok

let map_pat_using (env : env) (tok : CST.pat_using) =
  (* pattern [uU][sS][iI][nN][gG] *) token env tok

let map_pat__band (env : env) (tok : CST.pat__band) =
  (* pattern [--][bB][aA][nN][dD] *) token env tok

let map_pat_8a0ae06 (env : env) (tok : CST.pat_8a0ae06) =
  (* pattern `.{1}|`\r?\n *) token env tok

let map_pat_fina (env : env) (tok : CST.pat_fina) =
  (* pattern [fF][iI][nN][aA][lL][lL][yY] *) token env tok

let map_pat_do (env : env) (tok : CST.pat_do) =
  (* pattern [dD][oO] *) token env tok

let map_decimal_integer_literal (env : env) (tok : CST.decimal_integer_literal) =
  (* decimal_integer_literal *) token env tok

let map_tok_prec_p1_pat_d01e7ed (env : env) (tok : CST.tok_prec_p1_pat_d01e7ed) =
  (* tok_prec_p1_pat_d01e7ed *) token env tok

let map_pat_d72a25c (env : env) (tok : CST.pat_d72a25c) =
  (* pattern [^\|\r\n]+ *) token env tok

let map_pat__inot_ (env : env) (tok : CST.pat__inot_) =
  (* pattern [--][iI][nN][oO][tT][mM][aA][tT][cC][hH] *) token env tok

let map_command_name_escape (env : env) (tok : CST.command_name_escape) =
  (* command_name_escape *) token env tok

let map_pat_while_ (env : env) (tok : CST.pat_while_) =
  (* pattern [wW][hH][iI][lL][eE][--] *) token env tok

let map_quoted_argument_boundary (env : env) (tok : CST.quoted_argument_boundary) =
  (* quoted_argument_boundary *) token env tok

let map_command_word_start (env : env) (tok : CST.command_word_start) =
  (* command_word_start *) token env tok

let map_pat__repl (env : env) (tok : CST.pat__repl) =
  (* pattern [--][rR][eE][pP][lL][aA][cC][eE] *) token env tok

let map_pat__ile (env : env) (tok : CST.pat__ile) =
  (* pattern [--][iI][lL][eE] *) token env tok

let map_pat_for (env : env) (tok : CST.pat_for) =
  (* pattern [fF][oO][rR] *) token env tok

let map_pat_brk_ (env : env) (tok : CST.pat_brk_) =
  (* pattern [bB][rR][eE][aA][kK][--] *) token env tok

let map_parameter_dot_boundary (env : env) (tok : CST.parameter_dot_boundary) =
  (* parameter_dot_boundary *) token env tok

let map_label (env : env) (tok : CST.label) =
  (* label *) token env tok

let map_pat__ceq (env : env) (tok : CST.pat__ceq) =
  (* pattern [--][cC][eE][qQ] *) token env tok

let map_pat__iin (env : env) (tok : CST.pat__iin) =
  (* pattern [--][iI][iI][nN] *) token env tok

let map_pat_elseif (env : env) (tok : CST.pat_elseif) =
  (* pattern [eE][lL][sS][eE][iI][fF] *) token env tok

let map_pat__cconts (env : env) (tok : CST.pat__cconts) =
  (* pattern [--][cC][cC][oO][nN][tT][aA][iI][nN][sS] *) token env tok

let map_bare_dashes (env : env) (tok : CST.bare_dashes) =
  (* bare_dashes *) token env tok

let map_script_block_argument_start (env : env) (tok : CST.script_block_argument_start) =
  (* script_block_argument_start *) token env tok

let map_pat__like (env : env) (tok : CST.pat__like) =
  (* pattern [--][lL][iI][kK][eE] *) token env tok

let map_pat__wild (env : env) (tok : CST.pat__wild) =
  (* pattern [--][wW][iI][lL][dD][cC][aA][rR][dD] *) token env tok

let map_file_redirection_operator (env : env) (x : CST.file_redirection_operator) =
  (match x with
  | `GT tok -> R.Case ("GT",
      (* ">" *) token env tok
    )
  | `GTGT tok -> R.Case ("GTGT",
      (* ">>" *) token env tok
    )
  | `X_2GT tok -> R.Case ("X_2GT",
      (* "2>" *) token env tok
    )
  | `X_2GTGT tok -> R.Case ("X_2GTGT",
      (* "2>>" *) token env tok
    )
  | `X_3GT tok -> R.Case ("X_3GT",
      (* "3>" *) token env tok
    )
  | `X_3GTGT tok -> R.Case ("X_3GTGT",
      (* "3>>" *) token env tok
    )
  | `X_4GT tok -> R.Case ("X_4GT",
      (* "4>" *) token env tok
    )
  | `X_4GTGT tok -> R.Case ("X_4GTGT",
      (* "4>>" *) token env tok
    )
  | `X_5GT tok -> R.Case ("X_5GT",
      (* "5>" *) token env tok
    )
  | `X_5GTGT tok -> R.Case ("X_5GTGT",
      (* "5>>" *) token env tok
    )
  | `X_6GT tok -> R.Case ("X_6GT",
      (* "6>" *) token env tok
    )
  | `X_6GTGT tok -> R.Case ("X_6GTGT",
      (* "6>>" *) token env tok
    )
  | `STARGT tok -> R.Case ("STARGT",
      (* "*>" *) token env tok
    )
  | `STARGTGT tok -> R.Case ("STARGTGT",
      (* "*>>" *) token env tok
    )
  | `LT tok -> R.Case ("LT",
      (* "<" *) token env tok
    )
  )

let map_pat_trap (env : env) (tok : CST.pat_trap) =
  (* pattern [tT][rR][aA][pP] *) token env tok

let map_assignement_operator (env : env) (x : CST.assignement_operator) =
  (match x with
  | `EQ tok -> R.Case ("EQ",
      (* "=" *) token env tok
    )
  | `BANGEQ tok -> R.Case ("BANGEQ",
      (* "!=" *) token env tok
    )
  | `PLUSEQ tok -> R.Case ("PLUSEQ",
      (* "+=" *) token env tok
    )
  | `STAREQ tok -> R.Case ("STAREQ",
      (* "*=" *) token env tok
    )
  | `SLASHEQ tok -> R.Case ("SLASHEQ",
      (* "/=" *) token env tok
    )
  | `PERCEQ tok -> R.Case ("PERCEQ",
      (* "%=" *) token env tok
    )
  | `DASHEQ tok -> R.Case ("DASHEQ",
      (* "-=" *) token env tok
    )
  | `QMARKQMARKEQ tok -> R.Case ("QMARKQMARKEQ",
      (* "??=" *) token env tok
    )
  )

let map_pat__bnot (env : env) (tok : CST.pat__bnot) =
  (* pattern [--][bB][nN][oO][tT] *) token env tok

let map_pat_else (env : env) (tok : CST.pat_else) =
  (* pattern [eE][lL][sS][eE] *) token env tok

let map_pat__inot (env : env) (tok : CST.pat__inot) =
  (* pattern [--][iI][nN][oO][tT][lL][iI][kK][eE] *) token env tok

let map_pat_exit (env : env) (tok : CST.pat_exit) =
  (* pattern [eE][xX][iI][tT] *) token env tok

let map_command_array_item_start (env : env) (tok : CST.command_array_item_start) =
  (* command_array_item_start *) token env tok

let map_pat__inotin (env : env) (tok : CST.pat__inotin) =
  (* pattern [--][iI][nN][oO][tT][iI][nN] *) token env tok

let map_pat__csplit (env : env) (tok : CST.pat__csplit) =
  (* pattern [--][cC][sS][pP][lL][iI][tT] *) token env tok

let map_pat_class_ (env : env) (tok : CST.pat_class_) =
  (* pattern [cC][lL][aA][sS][sS][--] *) token env tok

let map_pat__irep (env : env) (tok : CST.pat__irep) =
  (* pattern [--][iI][rR][eE][pP][lL][aA][cC][eE] *) token env tok

let map_command_token (env : env) (tok : CST.command_token) =
  (* command_token *) token env tok

let map_imm_tok_pat_3d58547_pat_3d58547 (env : env) (tok : CST.imm_tok_pat_3d58547_pat_3d58547) =
  (* imm_tok_pat_3d58547_pat_3d58547 *) token env tok

let map_imm_tok_pat_509ec78 (env : env) (tok : CST.imm_tok_pat_509ec78) =
  (* pattern \r?\n *) token env tok

let map_pat_proc_ (env : env) (tok : CST.pat_proc_) =
  (* pattern [pP][rR][oO][cC][eE][sS][sS][--] *) token env tok

let map_using_separator (env : env) (tok : CST.using_separator) =
  (* using_separator *) token env tok

let map_imm_tok_prec_p2_pat_8992db4 (env : env) (tok : CST.imm_tok_prec_p2_pat_8992db4) =
  (* pattern "[\"\\u201C-\\u201E]@" *) token env tok

let map_pat_for_ (env : env) (tok : CST.pat_for_) =
  (* pattern [fF][oO][rR][--] *) token env tok

let map_pat__contas (env : env) (tok : CST.pat__contas) =
  (* pattern [--][cC][oO][nN][tT][aA][iI][nN][sS] *) token env tok

let map_pat_throw_ (env : env) (tok : CST.pat_throw_) =
  (* pattern [tT][hH][rR][oO][wW][--] *) token env tok

let map_pat__f (env : env) (tok : CST.pat__f) =
  (* pattern [--][fF] *) token env tok

let map_pat_75780b9 (env : env) (tok : CST.pat_75780b9) =
  (* pattern \$`(.{1}|`\r?\n) *) token env tok

let map_pat__isplit (env : env) (tok : CST.pat__isplit) =
  (* pattern [--][iI][sS][pP][lL][iI][tT] *) token env tok

let map_pat__bor (env : env) (tok : CST.pat__bor) =
  (* pattern [--][bB][oO][rR] *) token env tok

let map_imm_tok_pat_99bafa0 (env : env) (tok : CST.imm_tok_pat_99bafa0) =
  (* pattern "[^\\{\\}\\(\\);,\\|\\&`\"'\\u2018-\\u201E\\s\\u00a0\\r\\n]+" *) token env tok

let map_pat_4f029d2 (env : env) (tok : CST.pat_4f029d2) =
  (* pattern "\"[^\"]*\"" *) token env tok

let map_pat_work_ (env : env) (tok : CST.pat_work_) =
  (* pattern [wW][oO][rR][kK][fF][lL][oO][wW][--] *) token env tok

let map_pat_catch (env : env) (tok : CST.pat_catch) =
  (* pattern [cC][aA][tT][cC][hH] *) token env tok

let map_completed_expression_boundary (env : env) (tok : CST.completed_expression_boundary) =
  (* completed_expression_boundary *) token env tok

let map_braced_variable (env : env) (tok : CST.braced_variable) =
  (* pattern \$\{[^}]+\} *) token env tok

let map_pat__cne (env : env) (tok : CST.pat__cne) =
  (* pattern [--][cC][nN][eE] *) token env tok

let map_pat_try (env : env) (tok : CST.pat_try) =
  (* pattern [tT][rR][yY] *) token env tok

let map_parameter_argument_separator (env : env) (tok : CST.parameter_argument_separator) =
  (* parameter_argument_separator *) token env tok

let map_pat_ret (env : env) (tok : CST.pat_ret) =
  (* pattern [rR][eE][tT][uU][rR][nN] *) token env tok

let map_pat_switch (env : env) (tok : CST.pat_switch) =
  (* pattern [sS][wW][iI][tT][cC][hH] *) token env tok

let map_pat__cin (env : env) (tok : CST.pat__cin) =
  (* pattern [--][cC][iI][nN] *) token env tok

let map_hexadecimal_integer_literal (env : env) (tok : CST.hexadecimal_integer_literal) =
  (* hexadecimal_integer_literal *) token env tok

let map_pat_4b2636b (env : env) (tok : CST.pat_4b2636b) =
  (* pattern "[^\\{\\}\\(\\);,\\|\\&`\"'\\u2018-\\u201E\\s\\u00a0\\r\\n\\[\\]\\+\\-\\*\\/\\$@<\\!0-9][^\\{\\}\\(\\);,\\|\\&`\"'\\u2018-\\u201E\\s\\u00a0\\r\\n\\[\\]\\+\\-\\*\\/\\$@<\\!]*" *) token env tok

let map_pat__igt (env : env) (tok : CST.pat__igt) =
  (* pattern [--][iI][gG][tT] *) token env tok

let map_pat_71f01fd (env : env) (tok : CST.pat_71f01fd) =
  (* pattern &[^&]* *) token env tok

let map_pat__inotcs (env : env) (tok : CST.pat__inotcs) =
  (* pattern [--][iI][nN][oO][tT][cC][oO][nN][tT][aA][iI][nN][sS] *) token env tok

let map_tok_choice_pat_cfc8cac (env : env) (tok : CST.tok_choice_pat_cfc8cac) =
  (* tok_choice_pat_cfc8cac *) token env tok

let map_command_name_start_escape (env : env) (tok : CST.command_name_start_escape) =
  (* command_name_start_escape *) token env tok

let map_parameter_argument_start (env : env) (tok : CST.parameter_argument_start) =
  (* parameter_argument_start *) token env tok

let map_pat__join (env : env) (tok : CST.pat__join) =
  (* pattern [--][jJ][oO][iI][nN] *) token env tok

let map_pat__cge (env : env) (tok : CST.pat__cge) =
  (* pattern [--][cC][gG][eE] *) token env tok

let map_pat__eq (env : env) (tok : CST.pat__eq) =
  (* pattern [--][eE][qQ] *) token env tok

let map_pat_if (env : env) (tok : CST.pat_if) =
  (* pattern [iI][fF] *) token env tok

let map_pat_cont (env : env) (tok : CST.pat_cont) =
  (* pattern [cC][oO][nN][tT][iI][nN][uU][eE] *) token env tok

let map_pat_3d58547 (env : env) (tok : CST.pat_3d58547) =
  (* pattern "['\\u2018-\\u201B]" *) token env tok

let map_pat_para_ (env : env) (tok : CST.pat_para_) =
  (* pattern [pP][aA][rR][aA][lL][lL][eE][lL][--] *) token env tok

let map_tok_prec_p1_pat_static (env : env) (tok : CST.tok_prec_p1_pat_static) =
  (* tok_prec_p1_pat_static *) token env tok

let map_imm_tok_pat_f92c05a (env : env) (tok : CST.imm_tok_pat_f92c05a) =
  (* pattern \$(`.{1}|`\r?\n|[\s\\]) *) token env tok

let map_pat_b026f1a (env : env) (tok : CST.pat_b026f1a) =
  (* pattern "[^\\$\"\\u201C-\\u201E`]+" *) token env tok

let map_pat__clike (env : env) (tok : CST.pat__clike) =
  (* pattern [--][cC][lL][iI][kK][eE] *) token env tok

let map_pat_while (env : env) (tok : CST.pat_while) =
  (* pattern [wW][hH][iI][lL][eE] *) token env tok

let map_pat_seq (env : env) (tok : CST.pat_seq) =
  (* pattern [sS][eE][qQ][uU][eE][nN][cC][eE] *) token env tok

let map_pipeline_chain_tail (env : env) (x : CST.pipeline_chain_tail) =
  (match x with
  | `AMPAMP tok -> R.Case ("AMPAMP",
      (* "&&" *) token env tok
    )
  | `BARBAR tok -> R.Case ("BARBAR",
      (* "||" *) token env tok
    )
  )

let map_imm_tok_pat_421479c_pat_421479c (env : env) (tok : CST.imm_tok_pat_421479c_pat_421479c) =
  (* imm_tok_pat_421479c_pat_421479c *) token env tok

let map_pat__crep (env : env) (tok : CST.pat__crep) =
  (* pattern [--][cC][rR][eE][pP][lL][aA][cC][eE] *) token env tok

let map_pat__para (env : env) (tok : CST.pat__para) =
  (* pattern [--][pP][aA][rR][aA][lL][lL][eE][lL] *) token env tok

let map_pat__bxor (env : env) (tok : CST.pat__bxor) =
  (* pattern [--][bB][xX][oO][rR] *) token env tok

let map_foreach_member_name (env : env) (tok : CST.foreach_member_name) =
  (* pattern [fF][oO][rR][eE][aA][cC][hH] *) token env tok

let map_pat_try_ (env : env) (tok : CST.pat_try_) =
  (* pattern [tT][rR][yY][--] *) token env tok

let map_imm_tok_pat_8a0ae06 (env : env) (tok : CST.imm_tok_pat_8a0ae06) =
  (* pattern `.{1}|`\r?\n *) token env tok

let map_pat__isnot (env : env) (tok : CST.pat__isnot) =
  (* pattern [--][iI][sS][nN][oO][tT] *) token env tok

let map_pat__exact (env : env) (tok : CST.pat__exact) =
  (* pattern [--][eE][xX][aA][cC][tT] *) token env tok

let map_pat_inli (env : env) (tok : CST.pat_inli) =
  (* pattern [iI][nN][lL][iI][nN][eE][sS][cC][rR][iI][pP][tT] *) token env tok

let map_imm_tok_prec_p1_pat_b026f1a (env : env) (tok : CST.imm_tok_prec_p1_pat_b026f1a) =
  (* pattern "[^\\$\"\\u201C-\\u201E`]+" *) token env tok

let map_pat_cc660f0 (env : env) (tok : CST.pat_cc660f0) =
  (* pattern [rR][eE][tT][uU][rR][nN][-@$] *) token env tok

let map_pat_para (env : env) (tok : CST.pat_para) =
  (* pattern [pP][aA][rR][aA][lL][lL][eE][lL] *) token env tok

let map_real_literal (env : env) (tok : CST.real_literal) =
  (* real_literal *) token env tok

let map_pat_asse (env : env) (tok : CST.pat_asse) =
  (* pattern [aA][sS][sS][eE][mM][bB][lL][yY] *) token env tok

let map_pat__ieq (env : env) (tok : CST.pat__ieq) =
  (* pattern [--][iI][eE][qQ] *) token env tok

let map_pat__xor (env : env) (tok : CST.pat__xor) =
  (* pattern [--][xX][oO][rR] *) token env tok

let map_pat__split (env : env) (tok : CST.pat__split) =
  (* pattern [--][sS][pP][lL][iI][tT] *) token env tok

let map_imm_tok_prec_p1_pat_dc9636f (env : env) (tok : CST.imm_tok_prec_p1_pat_dc9636f) =
  (* pattern "[^\\s\\u00a0\"'\\u2018-\\u201E`$();|&,{}]+" *) token env tok

let map_pat_bda16ab (env : env) (tok : CST.pat_bda16ab) =
  (* pattern \.{1,2}\/ *) token env tok

let map_pat__ge (env : env) (tok : CST.pat__ge) =
  (* pattern [--][gG][eE] *) token env tok

let map_pat__match (env : env) (tok : CST.pat__match) =
  (* pattern [--][mM][aA][tT][cC][hH] *) token env tok

let map_verbatim_string_characters (env : env) (tok : CST.verbatim_string_characters) =
  (* verbatim_string_characters *) token env tok

let map_imm_tok_prec_p1_pat_0f46d6a (env : env) (tok : CST.imm_tok_prec_p1_pat_0f46d6a) =
  (* pattern "\\r?\\n[\"\\u201C-\\u201E]@" *) token env tok

let map_pat_data (env : env) (tok : CST.pat_data) =
  (* pattern [dD][aA][tT][aA] *) token env tok

let map_parameter_dot_literal_boundary (env : env) (tok : CST.parameter_dot_literal_boundary) =
  (* parameter_dot_literal_boundary *) token env tok

let map_pat__file (env : env) (tok : CST.pat__file) =
  (* pattern [--][fF][iI][lL][eE] *) token env tok

let map_pat_enum_ (env : env) (tok : CST.pat_enum_) =
  (* pattern [eE][nN][uU][mM][--] *) token env tok

let map_verbatim_here_string_characters (env : env) (tok : CST.verbatim_here_string_characters) =
  (* verbatim_here_string_characters *) token env tok

let map_pat_0cd92c2 (env : env) (tok : CST.pat_0cd92c2) =
  (* pattern "[^'\\u2018-\\u201B]+" *) token env tok

let map_pat__imatch (env : env) (tok : CST.pat__imatch) =
  (* pattern [--][iI][mM][aA][tT][cC][hH] *) token env tok

let map_imm_tok_pat_3d58547 (env : env) (tok : CST.imm_tok_pat_3d58547) =
  (* pattern "['\\u2018-\\u201B]" *) token env tok

let map_pat__ne (env : env) (tok : CST.pat__ne) =
  (* pattern [--][nN][eE] *) token env tok

let map_pat__regex (env : env) (tok : CST.pat__regex) =
  (* pattern [--][rR][eE][gG][eE][xX] *) token env tok

let map_parameter_argument_word (env : env) (tok : CST.parameter_argument_word) =
  (* pattern "-+(?:([^\\P{L}\\u{10000}-\\u{10FFFF}]|[\\u1C89-\\u1C8A\\u3400-\\u4DBF\\u4E00-\\u9FFF\\uA7CB-\\uA7CD\\uA7DA-\\uA7DC\\uAC00-\\uD7A3])|[_?\\x60-])[^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*:?|-[0-9.][^\\s\\u00a0\"'\\u2018-\\u201E\\x60$(){}|;,&]*|-" *) token env tok

let map_tok_at_choice_choice_prec_p1_pat_0705c16_colon_choice_pat_b2ccb50 (env : env) (tok : CST.tok_at_choice_choice_prec_p1_pat_0705c16_colon_choice_pat_b2ccb50) =
  (* tok_at_choice_choice_prec_p1_pat_0705c16_colon_choice_pat_b2ccb50 *) token env tok

let map_pat_dyna_ (env : env) (tok : CST.pat_dyna_) =
  (* pattern [dD][yY][nN][aA][mM][iI][cC][pP][aA][rR][aA][mM][--] *) token env tok

let map_imm_tok_pat_5a0db4a (env : env) (tok : CST.imm_tok_pat_5a0db4a) =
  (* pattern `[^\r\n]|`[\r\n] *) token env tok

let map_tok_prec_p1_pat_class (env : env) (tok : CST.tok_prec_p1_pat_class) =
  (* tok_prec_p1_pat_class *) token env tok

let map_pat_if_ (env : env) (tok : CST.pat_if_) =
  (* pattern [iI][fF][--] *) token env tok

let map_path_command_name_continuation (env : env) (tok : CST.path_command_name_continuation) =
  (* path_command_name_continuation *) token env tok

let map_imm_tok_dot (env : env) (tok : CST.imm_tok_dot) =
  (* "." *) token env tok

let map_pat__case (env : env) (tok : CST.pat__case) =
  (* pattern [--][cC][aA][sS][eE][sS][eE][nN][sS][iI][tT][iI][vV][eE] *) token env tok

let map_pat__cle (env : env) (tok : CST.pat__cle) =
  (* pattern [--][cC][lL][eE] *) token env tok

let map_pat_c7917d5 (env : env) (tok : CST.pat_c7917d5) =
  (* pattern "[0-9]+([^\\{\\}\\(\\);,\\|\\&`\"'\\u2018-\\u201E\\s\\u00a0\\r\\n\\[\\]\\+\\-\\*\\/\\$@<\\!0-9.]|\\.[^\\{\\}\\(\\);,\\|\\&`\"'\\u2018-\\u201E\\s\\u00a0\\r\\n\\[\\]\\+\\-\\*\\/\\$@<\\!.])[^\\{\\}\\(\\);,\\|\\&`\"'\\u2018-\\u201E\\s\\u00a0\\r\\n\\[\\]\\+\\-\\*\\/\\$@<\\!]*" *) token env tok

let map_stop_parsing (env : env) (tok : CST.stop_parsing) =
  (* pattern --%[^\r\n]* *) token env tok

let map_pat__clt (env : env) (tok : CST.pat__clt) =
  (* pattern [--][cC][lL][tT] *) token env tok

let map_pat__gt (env : env) (tok : CST.pat__gt) =
  (* pattern [--][gG][tT] *) token env tok

let map_pat__cgt (env : env) (tok : CST.pat__cgt) =
  (* pattern [--][cC][gG][tT] *) token env tok

let map_pat__shl (env : env) (tok : CST.pat__shl) =
  (* pattern [--][sS][hH][lL] *) token env tok

let map_pat_param (env : env) (tok : CST.pat_param) =
  (* pattern [pP][aA][rR][aA][mM] *) token env tok

let map_pat__iconts (env : env) (tok : CST.pat__iconts) =
  (* pattern [--][iI][cC][oO][nN][tT][aA][iI][nN][sS] *) token env tok

let map_statement_terminator (env : env) (tok : CST.statement_terminator) =
  (* statement_terminator *) token env tok

let map_imm_tok_dollar (env : env) (tok : CST.imm_tok_dollar) =
  (* "$" *) token env tok

let map_pat_end_ (env : env) (tok : CST.pat_end_) =
  (* pattern [eE][nN][dD][--] *) token env tok

let map_merging_redirection_operator (env : env) (x : CST.merging_redirection_operator) =
  (match x with
  | `STARGTAMP1 tok -> R.Case ("STARGTAMP1",
      (* "*>&1" *) token env tok
    )
  | `X_2GTAMP1 tok -> R.Case ("X_2GTAMP1",
      (* "2>&1" *) token env tok
    )
  | `X_3GTAMP1 tok -> R.Case ("X_3GTAMP1",
      (* "3>&1" *) token env tok
    )
  | `X_4GTAMP1 tok -> R.Case ("X_4GTAMP1",
      (* "4>&1" *) token env tok
    )
  | `X_5GTAMP1 tok -> R.Case ("X_5GTAMP1",
      (* "5>&1" *) token env tok
    )
  | `X_6GTAMP1 tok -> R.Case ("X_6GTAMP1",
      (* "6>&1" *) token env tok
    )
  | `STARGTAMP2 tok -> R.Case ("STARGTAMP2",
      (* "*>&2" *) token env tok
    )
  | `X_1GTAMP2 tok -> R.Case ("X_1GTAMP2",
      (* "1>&2" *) token env tok
    )
  | `X_3GTAMP2 tok -> R.Case ("X_3GTAMP2",
      (* "3>&2" *) token env tok
    )
  | `X_4GTAMP2 tok -> R.Case ("X_4GTAMP2",
      (* "4>&2" *) token env tok
    )
  | `X_5GTAMP2 tok -> R.Case ("X_5GTAMP2",
      (* "5>&2" *) token env tok
    )
  | `X_6GTAMP2 tok -> R.Case ("X_6GTAMP2",
      (* "6>&2" *) token env tok
    )
  )

let map_pat_8357948 (env : env) (tok : CST.pat_8357948) =
  (* pattern "@[\"\\u201C-\\u201E] *\\r?\\n" *) token env tok

let map_dimension (env : env) (xs : CST.dimension) =
  R.List (List.map (token env (* "," *)) xs)

let map_tok_pat_7059588_rep_plus_pat_7059588 (env : env) (tok : CST.tok_pat_7059588_rep_plus_pat_7059588) =
  (* tok_pat_7059588_rep_plus_pat_7059588 *) token env tok

let map_pat__as (env : env) (tok : CST.pat__as) =
  (* pattern [--][aA][sS] *) token env tok

let map_command_argument_sep (env : env) (x : CST.command_argument_sep) =
  map_pat_6a8c7a7 env x

let map_block_name (env : env) (x : CST.block_name) =
  (match x with
  | `Pat_dyna x -> R.Case ("Pat_dyna",
      map_pat_dyna env x
    )
  | `Pat_begin x -> R.Case ("Pat_begin",
      map_pat_begin env x
    )
  | `Pat_proc x -> R.Case ("Pat_proc",
      map_pat_proc env x
    )
  | `Pat_end x -> R.Case ("Pat_end",
      map_pat_end env x
    )
  )

let map_anon_choice_SEMI_fddb21e (env : env) (x : CST.anon_choice_SEMI_fddb21e) =
  (match x with
  | `SEMI tok -> R.Case ("SEMI",
      (* ";" *) token env tok
    )
  | `Imm_tok_pat_509ec78 x -> R.Case ("Imm_tok_pat_509ec78",
      map_imm_tok_pat_509ec78 env x
    )
  )

let map_format_operator (env : env) (x : CST.format_operator) =
  map_pat__f env x

let map_integer_literal (env : env) (x : CST.integer_literal) =
  (match x with
  | `Deci_int_lit tok -> R.Case ("Deci_int_lit",
      (* decimal_integer_literal *) token env tok
    )
  | `Hexa_int_lit tok -> R.Case ("Hexa_int_lit",
      (* hexadecimal_integer_literal *) token env tok
    )
  )

let map_verbatim_command_argument_chars (env : env) (xs : CST.verbatim_command_argument_chars) =
  R.List (List.map (fun x ->
    (match x with
    | `Pat_4f029d2 x -> R.Case ("Pat_4f029d2",
        map_pat_4f029d2 env x
      )
    | `Pat_71f01fd x -> R.Case ("Pat_71f01fd",
        map_pat_71f01fd env x
      )
    | `Pat_d72a25c x -> R.Case ("Pat_d72a25c",
        map_pat_d72a25c env x
      )
    )
  ) xs)

let map_command_parameter (env : env) (x : CST.command_parameter) =
  (match x with
  | `Single_cmd_param tok -> R.Case ("Single_cmd_param",
      (* single_command_parameter *) token env tok
    )
  | `Tok_choice_pat_cfc8cac x -> R.Case ("Tok_choice_pat_cfc8cac",
      map_tok_choice_pat_cfc8cac env x
    )
  | `Bare_dashes tok -> R.Case ("Bare_dashes",
      (* bare_dashes *) token env tok
    )
  )

let map_class_attribute (env : env) (x : CST.class_attribute) =
  (match x with
  | `Tok_prec_p1_pat_hidden x -> R.Case ("Tok_prec_p1_pat_hidden",
      map_tok_prec_p1_pat_hidden env x
    )
  | `Tok_prec_p1_pat_static x -> R.Case ("Tok_prec_p1_pat_static",
      map_tok_prec_p1_pat_static env x
    )
  )

let map_foreach_parameter (env : env) (x : CST.foreach_parameter) =
  (match x with
  | `Pat__para x -> R.Case ("Pat__para",
      map_pat__para env x
    )
  )

let map_anon_choice_pat__band_7750572 (env : env) (x : CST.anon_choice_pat__band_7750572) =
  (match x with
  | `Pat__band x -> R.Case ("Pat__band",
      map_pat__band env x
    )
  | `Pat__bor x -> R.Case ("Pat__bor",
      map_pat__bor env x
    )
  | `Pat__bxor x -> R.Case ("Pat__bxor",
      map_pat__bxor env x
    )
  )

let map_anon_choice_pat__and_bad5cfe (env : env) (x : CST.anon_choice_pat__and_bad5cfe) =
  (match x with
  | `Pat__and x -> R.Case ("Pat__and",
      map_pat__and env x
    )
  | `Pat__or x -> R.Case ("Pat__or",
      map_pat__or env x
    )
  | `Pat__xor x -> R.Case ("Pat__xor",
      map_pat__xor env x
    )
  )

let map_string_literal_immediate (env : env) ((v1, v2) : CST.string_literal_immediate) =
  let v1 = map_pat_0cd92c2 env v1 in
  let v2 = map_pat_3d58547 env v2 in
  R.Tuple [v1; v2]

let map_variable (env : env) (x : CST.variable) =
  (match x with
  | `Semg_named_ellips tok -> R.Case ("Semg_named_ellips",
      (* pattern \$\.\.\.[A-Z_][A-Z_0-9]* *) token env tok
    )
  | `Choice_DOLLARDOLLAR x -> R.Case ("Choice_DOLLARDOLLAR",
      (match x with
      | `DOLLARDOLLAR tok -> R.Case ("DOLLARDOLLAR",
          (* "$$" *) token env tok
        )
      | `DOLLARHAT tok -> R.Case ("DOLLARHAT",
          (* "$^" *) token env tok
        )
      | `DOLLARQMARK tok -> R.Case ("DOLLARQMARK",
          (* "$?" *) token env tok
        )
      | `DOLLAR_ tok -> R.Case ("DOLLAR_",
          (* "$_" *) token env tok
        )
      | `Tok_dollar_choice_choice_prec_p1_pat_0705c16_colon_choice_pat_b2ccb50 x -> R.Case ("Tok_dollar_choice_choice_prec_p1_pat_0705c16_colon_choice_pat_b2ccb50",
          map_tok_dollar_choice_choice_prec_p1_pat_0705c16_colon_choice_pat_b2ccb50 env x
        )
      | `Tok_at_choice_choice_prec_p1_pat_0705c16_colon_choice_pat_b2ccb50 x -> R.Case ("Tok_at_choice_choice_prec_p1_pat_0705c16_colon_choice_pat_b2ccb50",
          map_tok_at_choice_choice_prec_p1_pat_0705c16_colon_choice_pat_b2ccb50 env x
        )
      | `Braced_var tok -> R.Case ("Braced_var",
          (* pattern \$\{[^}]+\} *) token env tok
        )
      )
    )
  )

let map_colon_word_text (env : env) (x : CST.colon_word_text) =
  (match x with
  | `Imm_tok_prec_p1_pat_dc9636f x -> R.Case ("Imm_tok_prec_p1_pat_dc9636f",
      map_imm_tok_prec_p1_pat_dc9636f env x
    )
  | `Imm_tok_pat_5a0db4a x -> R.Case ("Imm_tok_pat_5a0db4a",
      map_imm_tok_pat_5a0db4a env x
    )
  )

let map_member_access_operator (env : env) (x : CST.member_access_operator) =
  (match x with
  | `Imm_tok_dot x -> R.Case ("Imm_tok_dot",
      map_imm_tok_dot env x
    )
  | `Null_cond_member_op tok -> R.Case ("Null_cond_member_op",
      (* "?." *) token env tok
    )
  )

let map_switch_parameter (env : env) (x : CST.switch_parameter) =
  (match x with
  | `Pat__regex x -> R.Case ("Pat__regex",
      map_pat__regex env x
    )
  | `Pat__wild x -> R.Case ("Pat__wild",
      map_pat__wild env x
    )
  | `Pat__exact x -> R.Case ("Pat__exact",
      map_pat__exact env x
    )
  | `Pat__case x -> R.Case ("Pat__case",
      map_pat__case env x
    )
  | `Pat__para x -> R.Case ("Pat__para",
      map_pat__para env x
    )
  )

let rec map_type_name (env : env) (x : CST.type_name) =
  (match x with
  | `Type_id tok -> R.Case ("Type_id",
      (* type_identifier *) token env tok
    )
  | `Type_name_DOT_tok_pat_7059588_rep_plus_pat_7059588 (v1, v2, v3) -> R.Case ("Type_name_DOT_tok_pat_7059588_rep_plus_pat_7059588",
      let v1 = map_type_name env v1 in
      let v2 = (* "." *) token env v2 in
      let v3 = map_tok_pat_7059588_rep_plus_pat_7059588 env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

let map_comparison_operator (env : env) (x : CST.comparison_operator) =
  (match x with
  | `Pat__as x -> R.Case ("Pat__as",
      map_pat__as env x
    )
  | `Pat__cconts x -> R.Case ("Pat__cconts",
      map_pat__cconts env x
    )
  | `Pat__ceq x -> R.Case ("Pat__ceq",
      map_pat__ceq env x
    )
  | `Pat__cge x -> R.Case ("Pat__cge",
      map_pat__cge env x
    )
  | `Pat__cgt x -> R.Case ("Pat__cgt",
      map_pat__cgt env x
    )
  | `Pat__cin x -> R.Case ("Pat__cin",
      map_pat__cin env x
    )
  | `Pat__cle x -> R.Case ("Pat__cle",
      map_pat__cle env x
    )
  | `Pat__clike x -> R.Case ("Pat__clike",
      map_pat__clike env x
    )
  | `Pat__clt x -> R.Case ("Pat__clt",
      map_pat__clt env x
    )
  | `Pat__cmatch x -> R.Case ("Pat__cmatch",
      map_pat__cmatch env x
    )
  | `Pat__cne x -> R.Case ("Pat__cne",
      map_pat__cne env x
    )
  | `Pat__cnotcs x -> R.Case ("Pat__cnotcs",
      map_pat__cnotcs env x
    )
  | `Pat__cnotin x -> R.Case ("Pat__cnotin",
      map_pat__cnotin env x
    )
  | `Pat__cnot x -> R.Case ("Pat__cnot",
      map_pat__cnot env x
    )
  | `Pat__cnot_ x -> R.Case ("Pat__cnot_",
      map_pat__cnot_ env x
    )
  | `Pat__contas x -> R.Case ("Pat__contas",
      map_pat__contas env x
    )
  | `Pat__crep x -> R.Case ("Pat__crep",
      map_pat__crep env x
    )
  | `Pat__csplit x -> R.Case ("Pat__csplit",
      map_pat__csplit env x
    )
  | `Pat__eq x -> R.Case ("Pat__eq",
      map_pat__eq env x
    )
  | `Pat__ge x -> R.Case ("Pat__ge",
      map_pat__ge env x
    )
  | `Pat__gt x -> R.Case ("Pat__gt",
      map_pat__gt env x
    )
  | `Pat__iconts x -> R.Case ("Pat__iconts",
      map_pat__iconts env x
    )
  | `Pat__ieq x -> R.Case ("Pat__ieq",
      map_pat__ieq env x
    )
  | `Pat__ige x -> R.Case ("Pat__ige",
      map_pat__ige env x
    )
  | `Pat__igt x -> R.Case ("Pat__igt",
      map_pat__igt env x
    )
  | `Pat__iin x -> R.Case ("Pat__iin",
      map_pat__iin env x
    )
  | `Pat__ile x -> R.Case ("Pat__ile",
      map_pat__ile env x
    )
  | `Pat__ilike x -> R.Case ("Pat__ilike",
      map_pat__ilike env x
    )
  | `Pat__ilt x -> R.Case ("Pat__ilt",
      map_pat__ilt env x
    )
  | `Pat__imatch x -> R.Case ("Pat__imatch",
      map_pat__imatch env x
    )
  | `Pat__in x -> R.Case ("Pat__in",
      map_pat__in env x
    )
  | `Pat__ine x -> R.Case ("Pat__ine",
      map_pat__ine env x
    )
  | `Pat__inotcs x -> R.Case ("Pat__inotcs",
      map_pat__inotcs env x
    )
  | `Pat__inotin x -> R.Case ("Pat__inotin",
      map_pat__inotin env x
    )
  | `Pat__inot x -> R.Case ("Pat__inot",
      map_pat__inot env x
    )
  | `Pat__inot_ x -> R.Case ("Pat__inot_",
      map_pat__inot_ env x
    )
  | `Pat__irep x -> R.Case ("Pat__irep",
      map_pat__irep env x
    )
  | `Pat__is x -> R.Case ("Pat__is",
      map_pat__is env x
    )
  | `Pat__isnot x -> R.Case ("Pat__isnot",
      map_pat__isnot env x
    )
  | `Pat__isplit x -> R.Case ("Pat__isplit",
      map_pat__isplit env x
    )
  | `Pat__join x -> R.Case ("Pat__join",
      map_pat__join env x
    )
  | `Pat__le x -> R.Case ("Pat__le",
      map_pat__le env x
    )
  | `Pat__like x -> R.Case ("Pat__like",
      map_pat__like env x
    )
  | `Pat__lt x -> R.Case ("Pat__lt",
      map_pat__lt env x
    )
  | `Pat__match x -> R.Case ("Pat__match",
      map_pat__match env x
    )
  | `Pat__ne x -> R.Case ("Pat__ne",
      map_pat__ne env x
    )
  | `Pat__notcos x -> R.Case ("Pat__notcos",
      map_pat__notcos env x
    )
  | `Pat__notin x -> R.Case ("Pat__notin",
      map_pat__notin env x
    )
  | `Pat__notl x -> R.Case ("Pat__notl",
      map_pat__notl env x
    )
  | `Pat__notm x -> R.Case ("Pat__notm",
      map_pat__notm env x
    )
  | `Pat__repl x -> R.Case ("Pat__repl",
      map_pat__repl env x
    )
  | `Pat__shl x -> R.Case ("Pat__shl",
      map_pat__shl env x
    )
  | `Pat__shr x -> R.Case ("Pat__shr",
      map_pat__shr env x
    )
  | `Pat__split x -> R.Case ("Pat__split",
      map_pat__split env x
    )
  )

let map_verbatim_command_argument (env : env) ((v1, v2) : CST.verbatim_command_argument) =
  let v1 = (* "--%" *) token env v1 in
  let v2 = map_verbatim_command_argument_chars env v2 in
  R.Tuple [v1; v2]

let map_switch_parameters (env : env) (xs : CST.switch_parameters) =
  R.List (List.map (map_switch_parameter env) xs)

let map_type_name_ (env : env) (x : CST.type_name_) =
  (match x with
  | `Type_name x -> R.Case ("Type_name",
      map_type_name env x
    )
  | `Trai_dot_type_name tok -> R.Case ("Trai_dot_type_name",
      (* trailing_dot_type_name *) token env tok
    )
  )

let map_generic_type_name (env : env) ((v1, v2) : CST.generic_type_name) =
  let v1 = map_type_name_ env v1 in
  let v2 = (* "[" *) token env v2 in
  R.Tuple [v1; v2]

let rec map_anon_choice_attr_name_c4266a2 (env : env) (x : CST.anon_choice_attr_name_c4266a2) =
  (match x with
  | `Type_spec x -> R.Case ("Type_spec",
      map_attribute_name env x
    )
  | `Type_lit x -> R.Case ("Type_lit",
      map_attribute_type_value env x
    )
  )

and map_array_type_name (env : env) ((v1, v2) : CST.array_type_name) =
  let v1 =
    (match v1 with
    | `Type_name_ x -> R.Case ("Type_name_",
        map_type_name_ env x
      )
    | `Array_type_spec x -> R.Case ("Array_type_spec",
        map_array_type_spec env x
      )
    | `Gene_type_spec x -> R.Case ("Gene_type_spec",
        map_generic_type_spec env x
      )
    )
  in
  let v2 = (* "[" *) token env v2 in
  R.Tuple [v1; v2]

and map_array_type_spec (env : env) ((v1, v2, v3) : CST.array_type_spec) =
  let v1 = map_array_type_name env v1 in
  let v2 =
    (match v2 with
    | Some x -> R.Option (Some (
        map_dimension env x
      ))
    | None -> R.Option None)
  in
  let v3 = (* "]" *) token env v3 in
  R.Tuple [v1; v2; v3]

and map_attribute_name (env : env) (x : CST.attribute_name) =
  map_type_spec env x

and map_attribute_type_value (env : env) (x : CST.attribute_type_value) =
  map_type_literal env x

and map_generic_type_arguments (env : env) ((v1, v2) : CST.generic_type_arguments) =
  let v1 = map_anon_choice_attr_name_c4266a2 env v1 in
  let v2 =
    R.List (List.map (fun (v1, v2) ->
      let v1 = (* "," *) token env v1 in
      let v2 = map_anon_choice_attr_name_c4266a2 env v2 in
      R.Tuple [v1; v2]
    ) v2)
  in
  R.Tuple [v1; v2]

and map_generic_type_spec (env : env) ((v1, v2, v3) : CST.generic_type_spec) =
  let v1 = map_generic_type_name env v1 in
  let v2 = map_generic_type_arguments env v2 in
  let v3 = (* "]" *) token env v3 in
  R.Tuple [v1; v2; v3]

and map_type_literal (env : env) ((v1, v2, v3) : CST.type_literal) =
  let v1 = (* "[" *) token env v1 in
  let v2 = map_attribute_name env v2 in
  let v3 = (* "]" *) token env v3 in
  R.Tuple [v1; v2; v3]

and map_type_spec (env : env) (x : CST.type_spec) =
  (match x with
  | `Array_type_spec x -> R.Case ("Array_type_spec",
      map_array_type_spec env x
    )
  | `Gene_type_spec x -> R.Case ("Gene_type_spec",
      map_generic_type_spec env x
    )
  | `Type_name_ x -> R.Case ("Type_name_",
      map_type_name_ env x
    )
  )

let map_class_method_parameter (env : env) ((v1, v2) : CST.class_method_parameter) =
  let v1 =
    (match v1 with
    | Some x -> R.Option (Some (
        map_attribute_type_value env x
      ))
    | None -> R.Option None)
  in
  let v2 = map_variable env v2 in
  R.Tuple [v1; v2]

let map_catch_type_list (env : env) ((v1, v2) : CST.catch_type_list) =
  let v1 = map_attribute_type_value env v1 in
  let v2 =
    R.List (List.map (fun (v1, v2) ->
      let v1 = (* "," *) token env v1 in
      let v2 = map_attribute_type_value env v2 in
      R.Tuple [v1; v2]
    ) v2)
  in
  R.Tuple [v1; v2]

let map_class_method_parameter_list (env : env) ((v1, v2) : CST.class_method_parameter_list) =
  let v1 = map_class_method_parameter env v1 in
  let v2 =
    R.List (List.map (fun (v1, v2) ->
      let v1 = (* "," *) token env v1 in
      let v2 = map_class_method_parameter env v2 in
      R.Tuple [v1; v2]
    ) v2)
  in
  R.Tuple [v1; v2]

let rec map_additive_argument_expression (env : env) (x : CST.additive_argument_expression) =
  (match x with
  | `Mult_arg_exp x -> R.Case ("Mult_arg_exp",
      map_multiplicative_argument_expression env x
    )
  | `Addi_arg_exp_choice_PLUS_mult_arg_exp (v1, v2, v3) -> R.Case ("Addi_arg_exp_choice_PLUS_mult_arg_exp",
      let v1 = map_additive_argument_expression env v1 in
      let v2 = map_anon_choice_PLUS_da42005 env v2 in
      let v3 = map_multiplicative_argument_expression env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_additive_expression (env : env) (x : CST.additive_expression) =
  (match x with
  | `Mult_exp x -> R.Case ("Mult_exp",
      map_multiplicative_expression env x
    )
  | `Addi_exp_choice_PLUS_mult_exp (v1, v2, v3) -> R.Case ("Addi_exp_choice_PLUS_mult_exp",
      let v1 = map_additive_expression env v1 in
      let v2 = map_anon_choice_PLUS_da42005 env v2 in
      let v3 = map_multiplicative_expression env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_adjacent_expression_arguments (env : env) (x : CST.adjacent_expression_arguments) =
  (match x with
  | `Cmd_arg_sep_comp_cmd_arg_arg_after_quote (v1, v2, v3) -> R.Case ("Cmd_arg_sep_comp_cmd_arg_arg_after_quote",
      let v1 = map_command_argument_sep env v1 in
      let v2 = map_completed_command_argument env v2 in
      let v3 = map_argument_after_quote env v3 in
      R.Tuple [v1; v2; v3]
    )
  | `Choice_paren_exp_comp_exp_boun_arg_after_quote (v1, v2, v3) -> R.Case ("Choice_paren_exp_comp_exp_boun_arg_after_quote",
      let v1 =
        (match v1 with
        | `Paren_exp x -> R.Case ("Paren_exp",
            map_parenthesized_expression env x
          )
        | `Script_blk_exp x -> R.Case ("Script_blk_exp",
            map_script_block_expression env x
          )
        )
      in
      let v2 = (* completed_expression_boundary *) token env v2 in
      let v3 = map_argument_after_quote env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_anon_choice_addi_arg_exp_5481787 (env : env) (x : CST.anon_choice_addi_arg_exp_5481787) =
  (match x with
  | `Addi_arg_exp x -> R.Case ("Addi_arg_exp",
      map_additive_argument_expression env x
    )
  | `Null_coal_arg_exp x -> R.Case ("Null_coal_arg_exp",
      map_null_coalescing_argument_expression env x
    )
  )

and map_anon_choice_addi_exp_4da1943 (env : env) (x : CST.anon_choice_addi_exp_4da1943) =
  (match x with
  | `Addi_exp x -> R.Case ("Addi_exp",
      map_additive_expression env x
    )
  | `Null_coal_exp x -> R.Case ("Null_coal_exp",
      map_null_coalescing_expression env x
    )
  )

and map_anon_choice_attr_dfec0a4 (env : env) (x : CST.anon_choice_attr_dfec0a4) =
  (match x with
  | `Attr x -> R.Case ("Attr",
      map_attribute env x
    )
  | `Class_attr x -> R.Case ("Class_attr",
      map_class_attribute env x
    )
  )

and map_anon_choice_imm_tok_pat_99bafa0_eb5bcb2 (env : env) (x : CST.anon_choice_imm_tok_pat_99bafa0_eb5bcb2) =
  (match x with
  | `Imm_tok_pat_99bafa0 x -> R.Case ("Imm_tok_pat_99bafa0",
      map_imm_tok_pat_99bafa0 env x
    )
  | `Cmd_name_esc tok -> R.Case ("Cmd_name_esc",
      (* command_name_escape *) token env tok
    )
  | `Imm_tok_pat_421479c_expa_str_lit_imme (v1, v2) -> R.Case ("Imm_tok_pat_421479c_expa_str_lit_imme",
      let v1 = map_imm_tok_pat_421479c env v1 in
      let v2 = map_expandable_string_literal_immediate env v2 in
      R.Tuple [v1; v2]
    )
  | `Imm_tok_pat_3d58547_str_lit_imme (v1, v2) -> R.Case ("Imm_tok_pat_3d58547_str_lit_imme",
      let v1 = map_imm_tok_pat_3d58547 env v1 in
      let v2 = map_string_literal_immediate env v2 in
      R.Tuple [v1; v2]
    )
  | `Imm_tok_pat_421479c_pat_421479c x -> R.Case ("Imm_tok_pat_421479c_pat_421479c",
      map_imm_tok_pat_421479c_pat_421479c env x
    )
  | `Imm_tok_pat_3d58547_pat_3d58547 x -> R.Case ("Imm_tok_pat_3d58547_pat_3d58547",
      map_imm_tok_pat_3d58547_pat_3d58547 env x
    )
  )

and map_argument_after_quote (env : env) (x : CST.argument_after_quote) =
  (match x with
  | `Cmd_word_rep_cmd_array_tail (v1, v2) -> R.Case ("Cmd_word_rep_cmd_array_tail",
      let v1 = map_command_word env v1 in
      let v2 =
        R.List (List.map (map_command_array_tail env) v2)
      in
      R.Tuple [v1; v2]
    )
  | `Cmd_exp_array x -> R.Case ("Cmd_exp_array",
      map_command_expression_array env x
    )
  | `Cmd_mixed_array x -> R.Case ("Cmd_mixed_array",
      map_command_mixed_array env x
    )
  | `Comp_cmd_arg_arg_after_quote (v1, v2) -> R.Case ("Comp_cmd_arg_arg_after_quote",
      let v1 = map_completed_command_argument env v1 in
      let v2 = map_argument_after_quote env v2 in
      R.Tuple [v1; v2]
    )
  | `Quoted_cmd_arg_quoted_arg_boun_arg_after_quote (v1, v2, v3) -> R.Case ("Quoted_cmd_arg_quoted_arg_boun_arg_after_quote",
      let v1 = map_quoted_command_argument env v1 in
      let v2 = (* quoted_argument_boundary *) token env v2 in
      let v3 = map_argument_after_quote env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_argument_expression (env : env) (x : CST.argument_expression) =
  (match x with
  | `Logi_arg_exp x -> R.Case ("Logi_arg_exp",
      map_logical_argument_expression env x
    )
  | `Tern_arg_exp (v1, v2, v3, v4, v5) -> R.Case ("Tern_arg_exp",
      let v1 = map_logical_argument_expression env v1 in
      let v2 = (* "?" *) token env v2 in
      let v3 = map_argument_expression env v3 in
      let v4 = (* ":" *) token env v4 in
      let v5 = map_argument_expression env v5 in
      R.Tuple [v1; v2; v3; v4; v5]
    )
  )

and map_argument_expression_list (env : env) ((v1, v2) : CST.argument_expression_list) =
  let v1 = map_argument_expression env v1 in
  let v2 =
    R.List (List.map (fun (v1, v2) ->
      let v1 = (* "," *) token env v1 in
      let v2 = map_argument_expression env v2 in
      R.Tuple [v1; v2]
    ) v2)
  in
  R.Tuple [v1; v2]

and map_argument_list (env : env) ((v1, v2, v3) : CST.argument_list) =
  let v1 = (* "(" *) token env v1 in
  let v2 =
    (match v2 with
    | Some x -> R.Option (Some (
        map_argument_expression_list env x
      ))
    | None -> R.Option None)
  in
  let v3 = (* ")" *) token env v3 in
  R.Tuple [v1; v2; v3]

and map_array_expression (env : env) ((v1, v2, v3) : CST.array_expression) =
  let v1 = (* "@(" *) token env v1 in
  let v2 =
    (match v2 with
    | Some x -> R.Option (Some (
        map_statement_list env x
      ))
    | None -> R.Option None)
  in
  let v3 = (* ")" *) token env v3 in
  R.Tuple [v1; v2; v3]

and map_array_literal_expression (env : env) ((v1, v2) : CST.array_literal_expression) =
  let v1 = map_unary_expression env v1 in
  let v2 =
    R.List (List.map (fun (v1, v2) ->
      let v1 = (* "," *) token env v1 in
      let v2 = map_unary_expression env v2 in
      R.Tuple [v1; v2]
    ) v2)
  in
  R.Tuple [v1; v2]

and map_attribute (env : env) (x : CST.attribute) =
  (match x with
  | `Attr_with_args x -> R.Case ("Attr_with_args",
      map_attribute_with_arguments env x
    )
  | `Type_lit x -> R.Case ("Type_lit",
      map_attribute_type_value env x
    )
  )

and map_attribute_additive_expression (env : env) (x : CST.attribute_additive_expression) =
  (match x with
  | `Attr_mult_exp x -> R.Case ("Attr_mult_exp",
      map_attribute_multiplicative_expression env x
    )
  | `Attr_addi_exp_choice_PLUS_attr_mult_exp (v1, v2, v3) -> R.Case ("Attr_addi_exp_choice_PLUS_attr_mult_exp",
      let v1 = map_attribute_additive_expression env v1 in
      let v2 = map_anon_choice_PLUS_da42005 env v2 in
      let v3 = map_attribute_multiplicative_expression env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_attribute_argument (env : env) (x : CST.attribute_argument) =
  (match x with
  | `Attr_exp x -> R.Case ("Attr_exp",
      map_attribute_expression env x
    )
  | `Simple_name_opt_EQ_attr_exp (v1, v2) -> R.Case ("Simple_name_opt_EQ_attr_exp",
      let v1 = (* simple_name *) token env v1 in
      let v2 =
        (match v2 with
        | Some (v1, v2) -> R.Option (Some (
            let v1 = (* "=" *) token env v1 in
            let v2 = map_attribute_expression env v2 in
            R.Tuple [v1; v2]
          ))
        | None -> R.Option None)
      in
      R.Tuple [v1; v2]
    )
  )

and map_attribute_arguments (env : env) ((v1, v2) : CST.attribute_arguments) =
  let v1 = map_attribute_argument env v1 in
  let v2 =
    R.List (List.map (fun (v1, v2) ->
      let v1 = (* "," *) token env v1 in
      let v2 = map_attribute_argument env v2 in
      R.Tuple [v1; v2]
    ) v2)
  in
  R.Tuple [v1; v2]

and map_attribute_array_literal_expression (env : env) (x : CST.attribute_array_literal_expression) =
  (match x with
  | `Un_exp x -> R.Case ("Un_exp",
      map_unary_expression env x
    )
  | `Attr_type_value x -> R.Case ("Attr_type_value",
      map_attribute_type_value env x
    )
  )

and map_attribute_bitwise_expression (env : env) (x : CST.attribute_bitwise_expression) =
  (match x with
  | `Attr_comp_exp x -> R.Case ("Attr_comp_exp",
      map_attribute_comparison_expression env x
    )
  | `Attr_bitw_exp_choice_pat__band_attr_comp_exp (v1, v2, v3) -> R.Case ("Attr_bitw_exp_choice_pat__band_attr_comp_exp",
      let v1 = map_attribute_bitwise_expression env v1 in
      let v2 = map_anon_choice_pat__band_7750572 env v2 in
      let v3 = map_attribute_comparison_expression env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_attribute_comparison_expression (env : env) (x : CST.attribute_comparison_expression) =
  (match x with
  | `Attr_addi_exp x -> R.Case ("Attr_addi_exp",
      map_attribute_additive_expression env x
    )
  | `Attr_comp_exp_comp_op_attr_addi_exp (v1, v2, v3) -> R.Case ("Attr_comp_exp_comp_op_attr_addi_exp",
      let v1 = map_attribute_comparison_expression env v1 in
      let v2 = map_comparison_operator env v2 in
      let v3 = map_attribute_additive_expression env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_attribute_expression (env : env) (x : CST.attribute_expression) =
  (match x with
  | `Attr_logi_exp x -> R.Case ("Attr_logi_exp",
      map_attribute_logical_expression env x
    )
  | `Attr_tern_exp (v1, v2, v3, v4, v5) -> R.Case ("Attr_tern_exp",
      let v1 = map_attribute_logical_expression env v1 in
      let v2 = (* "?" *) token env v2 in
      let v3 = map_attribute_expression env v3 in
      let v4 = (* ":" *) token env v4 in
      let v5 = map_attribute_expression env v5 in
      R.Tuple [v1; v2; v3; v4; v5]
    )
  )

and map_attribute_format_expression (env : env) (x : CST.attribute_format_expression) =
  (match x with
  | `Attr_range_exp x -> R.Case ("Attr_range_exp",
      map_attribute_range_expression env x
    )
  | `Attr_format_exp_format_op_attr_range_exp (v1, v2, v3) -> R.Case ("Attr_format_exp_format_op_attr_range_exp",
      let v1 = map_attribute_format_expression env v1 in
      let v2 = map_format_operator env v2 in
      let v3 = map_attribute_range_expression env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_attribute_list (env : env) (xs : CST.attribute_list) =
  R.List (List.map (map_attribute env) xs)

and map_attribute_logical_expression (env : env) (x : CST.attribute_logical_expression) =
  (match x with
  | `Attr_bitw_exp x -> R.Case ("Attr_bitw_exp",
      map_attribute_bitwise_expression env x
    )
  | `Attr_logi_exp_choice_pat__and_attr_bitw_exp (v1, v2, v3) -> R.Case ("Attr_logi_exp_choice_pat__and_attr_bitw_exp",
      let v1 = map_attribute_logical_expression env v1 in
      let v2 = map_anon_choice_pat__and_bad5cfe env v2 in
      let v3 = map_attribute_bitwise_expression env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_attribute_multiplicative_expression (env : env) (x : CST.attribute_multiplicative_expression) =
  (match x with
  | `Attr_format_exp x -> R.Case ("Attr_format_exp",
      map_attribute_format_expression env x
    )
  | `Attr_mult_exp_choice_SLASH_attr_format_exp (v1, v2, v3) -> R.Case ("Attr_mult_exp_choice_SLASH_attr_format_exp",
      let v1 = map_attribute_multiplicative_expression env v1 in
      let v2 = map_anon_choice_SLASH_4ca1f7c env v2 in
      let v3 = map_attribute_format_expression env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_attribute_range_expression (env : env) (x : CST.attribute_range_expression) =
  (match x with
  | `Attr_array_lit_exp x -> R.Case ("Attr_array_lit_exp",
      map_attribute_array_literal_expression env x
    )
  | `Attr_range_exp_DOTDOT_attr_array_lit_exp (v1, v2, v3) -> R.Case ("Attr_range_exp_DOTDOT_attr_array_lit_exp",
      let v1 = map_attribute_range_expression env v1 in
      let v2 = (* ".." *) token env v2 in
      let v3 = map_attribute_array_literal_expression env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_attribute_with_arguments (env : env) ((v1, v2, v3, v4, v5, v6) : CST.attribute_with_arguments) =
  let v1 = (* "[" *) token env v1 in
  let v2 = map_attribute_name env v2 in
  let v3 = (* "(" *) token env v3 in
  let v4 =
    (match v4 with
    | Some x -> R.Option (Some (
        map_attribute_arguments env x
      ))
    | None -> R.Option None)
  in
  let v5 = (* ")" *) token env v5 in
  let v6 = (* "]" *) token env v6 in
  R.Tuple [v1; v2; v3; v4; v5; v6]

and map_bitwise_argument_expression (env : env) (x : CST.bitwise_argument_expression) =
  (match x with
  | `Comp_arg_exp x -> R.Case ("Comp_arg_exp",
      map_comparison_argument_expression env x
    )
  | `Bitw_arg_exp_choice_pat__band_comp_arg_exp (v1, v2, v3) -> R.Case ("Bitw_arg_exp_choice_pat__band_comp_arg_exp",
      let v1 = map_bitwise_argument_expression env v1 in
      let v2 = map_anon_choice_pat__band_7750572 env v2 in
      let v3 = map_comparison_argument_expression env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_bitwise_expression (env : env) (x : CST.bitwise_expression) =
  (match x with
  | `Comp_exp x -> R.Case ("Comp_exp",
      map_comparison_expression env x
    )
  | `Bitw_exp_choice_pat__band_comp_exp (v1, v2, v3) -> R.Case ("Bitw_exp_choice_pat__band_comp_exp",
      let v1 = map_bitwise_expression env v1 in
      let v2 = map_anon_choice_pat__band_7750572 env v2 in
      let v3 = map_comparison_expression env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_catch_clause (env : env) ((v1, v2, v3) : CST.catch_clause) =
  let v1 = map_pat_catch env v1 in
  let v2 =
    (match v2 with
    | Some x -> R.Option (Some (
        map_catch_type_list env x
      ))
    | None -> R.Option None)
  in
  let v3 = map_statement_block env v3 in
  R.Tuple [v1; v2; v3]

and map_catch_clauses (env : env) (xs : CST.catch_clauses) =
  R.List (List.map (map_catch_clause env) xs)

and map_class_base_constructor_call (env : env) ((v1, v2, v3) : CST.class_base_constructor_call) =
  let v1 = (* ":" *) token env v1 in
  let v2 = map_pat_base env v2 in
  let v3 = map_argument_list env v3 in
  R.Tuple [v1; v2; v3]

and map_class_method_definition (env : env) ((v1, v2, v3, v4, v5, v6, v7, v8, v9, v10) : CST.class_method_definition) =
  let v1 =
    R.List (List.map (map_anon_choice_attr_dfec0a4 env) v1)
  in
  let v2 =
    (match v2 with
    | Some x -> R.Option (Some (
        map_attribute_type_value env x
      ))
    | None -> R.Option None)
  in
  let v3 = (* simple_name *) token env v3 in
  let v4 = (* "(" *) token env v4 in
  let v5 =
    (match v5 with
    | Some x -> R.Option (Some (
        map_class_method_parameter_list env x
      ))
    | None -> R.Option None)
  in
  let v6 = (* ")" *) token env v6 in
  let v7 =
    (match v7 with
    | Some x -> R.Option (Some (
        map_class_base_constructor_call env x
      ))
    | None -> R.Option None)
  in
  let v8 = (* "{" *) token env v8 in
  let v9 =
    (match v9 with
    | Some x -> R.Option (Some (
        map_script_block env x
      ))
    | None -> R.Option None)
  in
  let v10 = (* "}" *) token env v10 in
  R.Tuple [v1; v2; v3; v4; v5; v6; v7; v8; v9; v10]

and map_class_property_definition (env : env) ((v1, v2, v3, v4) : CST.class_property_definition) =
  let v1 =
    R.List (List.map (map_anon_choice_attr_dfec0a4 env) v1)
  in
  let v2 =
    (match v2 with
    | Some x -> R.Option (Some (
        map_attribute_type_value env x
      ))
    | None -> R.Option None)
  in
  let v3 = map_variable env v3 in
  let v4 =
    (match v4 with
    | Some x -> R.Option (Some (
        map_script_parameter_default env x
      ))
    | None -> R.Option None)
  in
  R.Tuple [v1; v2; v3; v4]

and map_colon_command_argument (env : env) (x : CST.colon_command_argument) =
  (match x with
  | `Tok_pat_f2b7187 x -> R.Case ("Tok_pat_f2b7187",
      map_tok_pat_f2b7187 env x
    )
  | `COLON_rep_choice_colon_word_text (v1, v2) -> R.Case ("COLON_rep_choice_colon_word_text",
      let v1 = (* ":" *) token env v1 in
      let v2 =
        R.List (List.map (fun x ->
          (match x with
          | `Colon_word_text x -> R.Case ("Colon_word_text",
              map_colon_word_text env x
            )
          | `Colon_word_cont_choice_var (v1, v2) -> R.Case ("Colon_word_cont_choice_var",
              let v1 = (* colon_word_continuation *) token env v1 in
              let v2 =
                (match v2 with
                | `Var x -> R.Case ("Var",
                    map_variable env x
                  )
                | `Str_lit x -> R.Case ("Str_lit",
                    map_quoted_command_argument env x
                  )
                | `Sub_exp x -> R.Case ("Sub_exp",
                    map_sub_expression env x
                  )
                | `Imm_tok_dollar x -> R.Case ("Imm_tok_dollar",
                    map_imm_tok_dollar env x
                  )
                )
              in
              R.Tuple [v1; v2]
            )
          )
        ) v2)
      in
      R.Tuple [v1; v2]
    )
  )

and map_command (env : env) (x : CST.command) =
  (match x with
  | `Cmd_name_opt_cmd_elemes (v1, v2) -> R.Case ("Cmd_name_opt_cmd_elemes",
      let v1 = map_command_name env v1 in
      let v2 =
        (match v2 with
        | Some x -> R.Option (Some (
            map_command_elements env x
          ))
        | None -> R.Option None)
      in
      R.Tuple [v1; v2]
    )
  | `Cmd_invo_op_cmd_name_expr_opt_cmd_elemes (v1, v2, v3) -> R.Case ("Cmd_invo_op_cmd_name_expr_opt_cmd_elemes",
      let v1 = map_command_invokation_operator env v1 in
      let v2 = map_data_command env v2 in
      let v3 =
        (match v3 with
        | Some x -> R.Option (Some (
            map_command_elements env x
          ))
        | None -> R.Option None)
      in
      R.Tuple [v1; v2; v3]
    )
  )

and map_command_argument (env : env) (x : CST.command_argument) =
  (match x with
  | `Cmd_arg_sep_opt_cmd_word_rep_cmd_array_tail (v1, v2) -> R.Case ("Cmd_arg_sep_opt_cmd_word_rep_cmd_array_tail",
      let v1 = map_command_argument_sep env v1 in
      let v2 =
        (match v2 with
        | Some (v1, v2) -> R.Option (Some (
            let v1 = map_command_word env v1 in
            let v2 =
              R.List (List.map (map_command_array_tail env) v2)
            in
            R.Tuple [v1; v2]
          ))
        | None -> R.Option None)
      in
      R.Tuple [v1; v2]
    )
  | `Cmd_arg_sep_cmd_exp_array (v1, v2) -> R.Case ("Cmd_arg_sep_cmd_exp_array",
      let v1 = map_command_argument_sep env v1 in
      let v2 = map_command_expression_array env v2 in
      R.Tuple [v1; v2]
    )
  | `Cmd_arg_sep_cmd_mixed_array (v1, v2) -> R.Case ("Cmd_arg_sep_cmd_mixed_array",
      let v1 = map_command_argument_sep env v1 in
      let v2 = map_command_mixed_array env v2 in
      R.Tuple [v1; v2]
    )
  | `Colon_cmd_arg_rep_cmd_array_tail (v1, v2) -> R.Case ("Colon_cmd_arg_rep_cmd_array_tail",
      let v1 = map_colon_command_argument env v1 in
      let v2 =
        R.List (List.map (map_command_array_tail env) v2)
      in
      R.Tuple [v1; v2]
    )
  | `Paren_exp x -> R.Case ("Paren_exp",
      map_parenthesized_expression env x
    )
  | `Script_blk_exp x -> R.Case ("Script_blk_exp",
      map_script_block_expression env x
    )
  )

and map_command_array_tail (env : env) ((v1, v2, v3) : CST.command_array_tail) =
  let v1 = (* "," *) token env v1 in
  let v2 = (* command_array_item_start *) token env v2 in
  let v3 =
    (match v3 with
    | `Cmd_array_word x -> R.Case ("Cmd_array_word",
        map_command_array_word env x
      )
    | `Cmd_un_exp x -> R.Case ("Cmd_un_exp",
        map_command_unary_expression env x
      )
    )
  in
  R.Tuple [v1; v2; v3]

and map_command_array_word (env : env) (x : CST.command_array_word) =
  (match x with
  | `Cmd_word x -> R.Case ("Cmd_word",
      map_command_word env x
    )
  | `Cmd_param x -> R.Case ("Cmd_param",
      map_command_parameter env x
    )
  )

and map_command_element (env : env) (x : CST.command_element) =
  (match x with
  | `Cmd_param_opt_param_arg_sepa_param_arg_start_rep_choice_cmd_arg_sep_cmd_param_arg (v1, v2) -> R.Case ("Cmd_param_opt_param_arg_sepa_param_arg_start_rep_choice_cmd_arg_sep_cmd_param_arg",
      let v1 = map_command_parameter env v1 in
      let v2 =
        (match v2 with
        | Some (v1, v2, v3, v4) -> R.Option (Some (
            let v1 = (* parameter_argument_separator *) token env v1 in
            let v2 = (* parameter_argument_start *) token env v2 in
            let v3 =
              R.List (List.map (fun x ->
                (match x with
                | `Cmd_arg_sep x -> R.Case ("Cmd_arg_sep",
                    map_command_argument_sep env x
                  )
                | `Tok_prec_p1_pat_fb4042a x -> R.Case ("Tok_prec_p1_pat_fb4042a",
                    map_tok_prec_p1_pat_fb4042a env x
                  )
                )
              ) v3)
            in
            let v4 = map_command_parameter_argument env v4 in
            R.Tuple [v1; v2; v3; v4]
          ))
        | None -> R.Option None)
      in
      R.Tuple [v1; v2]
    )
  | `Single_cmd_param_choice_param_dot_boun_arg_after_quote (v1, v2) -> R.Case ("Single_cmd_param_choice_param_dot_boun_arg_after_quote",
      let v1 = (* single_command_parameter *) token env v1 in
      let v2 =
        (match v2 with
        | `Param_dot_boun_arg_after_quote (v1, v2) -> R.Case ("Param_dot_boun_arg_after_quote",
            let v1 = (* parameter_dot_boundary *) token env v1 in
            let v2 = map_argument_after_quote env v2 in
            R.Tuple [v1; v2]
          )
        | `Param_dot_lit_boun_param_dot_lit_arg_after_quote (v1, v2, v3) -> R.Case ("Param_dot_lit_boun_param_dot_lit_arg_after_quote",
            let v1 =
              (* parameter_dot_literal_boundary *) token env v1
            in
            let v2 = (* "." *) token env v2 in
            let v3 = map_argument_after_quote env v3 in
            R.Tuple [v1; v2; v3]
          )
        )
      in
      R.Tuple [v1; v2]
    )
  | `Adja_exp_args x -> R.Case ("Adja_exp_args",
      map_adjacent_expression_arguments env x
    )
  | `Cmd_arg_opt_arg_list (v1, v2) -> R.Case ("Cmd_arg_opt_arg_list",
      let v1 = map_command_argument env v1 in
      let v2 =
        (match v2 with
        | Some x -> R.Option (Some (
            map_argument_list env x
          ))
        | None -> R.Option None)
      in
      R.Tuple [v1; v2]
    )
  | `Cmd_arg_sep_gene_tok_imm_tok_pat_7fb0419_arg_after_quote (v1, v2, v3, v4) -> R.Case ("Cmd_arg_sep_gene_tok_imm_tok_pat_7fb0419_arg_after_quote",
      let v1 = map_command_argument_sep env v1 in
      let v2 = map_generic_token env v2 in
      let v3 = map_imm_tok_pat_7fb0419 env v3 in
      let v4 = map_argument_after_quote env v4 in
      R.Tuple [v1; v2; v3; v4]
    )
  | `Cmd_arg_sep_quoted_cmd_arg_quoted_arg_boun_arg_after_quote (v1, v2, v3, v4) -> R.Case ("Cmd_arg_sep_quoted_cmd_arg_quoted_arg_boun_arg_after_quote",
      let v1 = map_command_argument_sep env v1 in
      let v2 = map_quoted_command_argument env v2 in
      let v3 = (* quoted_argument_boundary *) token env v3 in
      let v4 = map_argument_after_quote env v4 in
      R.Tuple [v1; v2; v3; v4]
    )
  | `Redi x -> R.Case ("Redi",
      map_redirection env x
    )
  | `Stop_pars tok -> R.Case ("Stop_pars",
      (* pattern --%[^\r\n]* *) token env tok
    )
  )

and map_command_elements (env : env) (xs : CST.command_elements) =
  R.List (List.map (map_command_element env) xs)

and map_command_expression_array (env : env) ((v1, v2) : CST.command_expression_array) =
  let v1 = map_command_unary_expression env v1 in
  let v2 =
    R.List (List.map (fun (v1, v2, v3) ->
      let v1 = (* "," *) token env v1 in
      let v2 = (* command_array_item_start *) token env v2 in
      let v3 = map_command_unary_expression env v3 in
      R.Tuple [v1; v2; v3]
    ) v2)
  in
  R.Tuple [v1; v2]

and map_command_mixed_array (env : env) ((v1, v2, v3, v4, v5, v6) : CST.command_mixed_array) =
  let v1 = map_command_unary_expression env v1 in
  let v2 =
    R.List (List.map (fun (v1, v2, v3) ->
      let v1 = (* "," *) token env v1 in
      let v2 = (* command_array_item_start *) token env v2 in
      let v3 = map_command_unary_expression env v3 in
      R.Tuple [v1; v2; v3]
    ) v2)
  in
  let v3 = (* "," *) token env v3 in
  let v4 = (* command_array_item_start *) token env v4 in
  let v5 = map_command_array_word env v5 in
  let v6 =
    R.List (List.map (map_command_array_tail env) v6)
  in
  R.Tuple [v1; v2; v3; v4; v5; v6]

and map_command_name (env : env) (x : CST.command_name) =
  (match x with
  | `Slash_cmd_name (v1, v2) -> R.Case ("Slash_cmd_name",
      let v1 =
        (match v1 with
        | `SLASH tok -> R.Case ("SLASH",
            (* "/" *) token env tok
          )
        | `Pat_bda16ab x -> R.Case ("Pat_bda16ab",
            map_pat_bda16ab env x
          )
        )
      in
      let v2 =
        R.List (List.map (map_anon_choice_imm_tok_pat_99bafa0_eb5bcb2 env) v2)
      in
      R.Tuple [v1; v2]
    )
  | `Ordi_cmd_name (v1, v2) -> R.Case ("Ordi_cmd_name",
      let v1 =
        (match v1 with
        | `Cmd_name_start_esc tok -> R.Case ("Cmd_name_start_esc",
            (* command_name_start_escape *) token env tok
          )
        | `Pat_4b2636b x -> R.Case ("Pat_4b2636b",
            map_pat_4b2636b env x
          )
        | `Pat_c7917d5 x -> R.Case ("Pat_c7917d5",
            map_pat_c7917d5 env x
          )
        | `Pat_brk_ x -> R.Case ("Pat_brk_",
            map_pat_brk_ env x
          )
        | `Pat_cont_ x -> R.Case ("Pat_cont_",
            map_pat_cont_ env x
          )
        | `Pat_throw_ x -> R.Case ("Pat_throw_",
            map_pat_throw_ env x
          )
        | `Pat_cc660f0 x -> R.Case ("Pat_cc660f0",
            map_pat_cc660f0 env x
          )
        | `Pat_exit_ x -> R.Case ("Pat_exit_",
            map_pat_exit_ env x
          )
        | `Pat_try_ x -> R.Case ("Pat_try_",
            map_pat_try_ env x
          )
        | `Pat_trap_ x -> R.Case ("Pat_trap_",
            map_pat_trap_ env x
          )
        | `Pat_if_ x -> R.Case ("Pat_if_",
            map_pat_if_ env x
          )
        | `Pat_func_ x -> R.Case ("Pat_func_",
            map_pat_func_ env x
          )
        | `Pat_filter_ x -> R.Case ("Pat_filter_",
            map_pat_filter_ env x
          )
        | `Pat_work_ x -> R.Case ("Pat_work_",
            map_pat_work_ env x
          )
        | `Pat_class_ x -> R.Case ("Pat_class_",
            map_pat_class_ env x
          )
        | `Pat_enum_ x -> R.Case ("Pat_enum_",
            map_pat_enum_ env x
          )
        | `Pat_switch_ x -> R.Case ("Pat_switch_",
            map_pat_switch_ env x
          )
        | `Pat_for_ x -> R.Case ("Pat_for_",
            map_pat_for_ env x
          )
        | `Pat_fore_ x -> R.Case ("Pat_fore_",
            map_pat_fore_ env x
          )
        | `Pat_while_ x -> R.Case ("Pat_while_",
            map_pat_while_ env x
          )
        | `Pat_para_ x -> R.Case ("Pat_para_",
            map_pat_para_ env x
          )
        | `Pat_using_ x -> R.Case ("Pat_using_",
            map_pat_using_ env x
          )
        | `Pat_begin_ x -> R.Case ("Pat_begin_",
            map_pat_begin_ env x
          )
        | `Pat_proc_ x -> R.Case ("Pat_proc_",
            map_pat_proc_ env x
          )
        | `Pat_end_ x -> R.Case ("Pat_end_",
            map_pat_end_ env x
          )
        | `Pat_dyna_ x -> R.Case ("Pat_dyna_",
            map_pat_dyna_ env x
          )
        )
      in
      let v2 =
        R.List (List.map (map_anon_choice_imm_tok_pat_99bafa0_eb5bcb2 env) v2)
      in
      R.Tuple [v1; v2]
    )
  )

and map_command_name_expr (env : env) (x : CST.command_name_expr) =
  (match x with
  | `Cmd_name x -> R.Case ("Cmd_name",
      map_command_name env x
    )
  | `Path_cmd_name (v1, v2) -> R.Case ("Path_cmd_name",
      let v1 =
        (match v1 with
        | `Path_cmd_name_tok tok -> R.Case ("Path_cmd_name_tok",
            (* pattern [0-9a-zA-Z_?\-\.\\\/]+ *) token env tok
          )
        | `Var x -> R.Case ("Var",
            map_variable env x
          )
        )
      in
      let v2 =
        R.List (List.map (fun (v1, v2) ->
          let v1 =
            (* path_command_name_continuation *) token env v1
          in
          let v2 =
            (match v2 with
            | `Path_cmd_name_tok tok -> R.Case ("Path_cmd_name_tok",
                (* pattern [0-9a-zA-Z_?\-\.\\\/]+ *) token env tok
              )
            | `Var x -> R.Case ("Var",
                map_variable env x
              )
            | `Imm_tok_pat_421479c_expa_str_lit_imme (v1, v2) -> R.Case ("Imm_tok_pat_421479c_expa_str_lit_imme",
                let v1 = map_imm_tok_pat_421479c env v1 in
                let v2 = map_expandable_string_literal_immediate env v2 in
                R.Tuple [v1; v2]
              )
            | `Imm_tok_pat_3d58547_str_lit_imme (v1, v2) -> R.Case ("Imm_tok_pat_3d58547_str_lit_imme",
                let v1 = map_imm_tok_pat_3d58547 env v1 in
                let v2 = map_string_literal_immediate env v2 in
                R.Tuple [v1; v2]
              )
            | `Imm_tok_pat_421479c_pat_421479c x -> R.Case ("Imm_tok_pat_421479c_pat_421479c",
                map_imm_tok_pat_421479c_pat_421479c env x
              )
            | `Imm_tok_pat_3d58547_pat_3d58547 x -> R.Case ("Imm_tok_pat_3d58547_pat_3d58547",
                map_imm_tok_pat_3d58547_pat_3d58547 env x
              )
            | `Cmd_name_esc tok -> R.Case ("Cmd_name_esc",
                (* command_name_escape *) token env tok
              )
            )
          in
          R.Tuple [v1; v2]
        ) v2)
      in
      R.Tuple [v1; v2]
    )
  | `Prim_exp x -> R.Case ("Prim_exp",
      map_primary_expression env x
    )
  )

and map_command_parameter_argument (env : env) (x : CST.command_parameter_argument) =
  (match x with
  | `Choice_cmd_word_rep_cmd_array_tail (v1, v2) -> R.Case ("Choice_cmd_word_rep_cmd_array_tail",
      let v1 =
        (match v1 with
        | `Cmd_word x -> R.Case ("Cmd_word",
            map_command_word env x
          )
        | `Param_arg_word tok -> R.Case ("Param_arg_word",
            (* pattern "-+(?:([^\\P{L}\\u{10000}-\\u{10FFFF}]|[\\u1C89-\\u1C8A\\u3400-\\u4DBF\\u4E00-\\u9FFF\\uA7CB-\\uA7CD\\uA7DA-\\uA7DC\\uAC00-\\uD7A3])|[_?\\x60-])[^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*:?|-[0-9.][^\\s\\u00a0\"'\\u2018-\\u201E\\x60$(){}|;,&]*|-" *) token env tok
          )
        )
      in
      let v2 =
        R.List (List.map (map_command_array_tail env) v2)
      in
      R.Tuple [v1; v2]
    )
  | `Param_arg_word_quoted_arg_boun_arg_after_quote (v1, v2, v3) -> R.Case ("Param_arg_word_quoted_arg_boun_arg_after_quote",
      let v1 =
        (* pattern "-+(?:([^\\P{L}\\u{10000}-\\u{10FFFF}]|[\\u1C89-\\u1C8A\\u3400-\\u4DBF\\u4E00-\\u9FFF\\uA7CB-\\uA7CD\\uA7DA-\\uA7DC\\uAC00-\\uD7A3])|[_?\\x60-])[^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*:?|-[0-9.][^\\s\\u00a0\"'\\u2018-\\u201E\\x60$(){}|;,&]*|-" *) token env v1
      in
      let v2 = (* quoted_argument_boundary *) token env v2 in
      let v3 = map_argument_after_quote env v3 in
      R.Tuple [v1; v2; v3]
    )
  | `Quoted_cmd_arg_quoted_arg_boun_arg_after_quote (v1, v2, v3) -> R.Case ("Quoted_cmd_arg_quoted_arg_boun_arg_after_quote",
      let v1 = map_quoted_command_argument env v1 in
      let v2 = (* quoted_argument_boundary *) token env v2 in
      let v3 = map_argument_after_quote env v3 in
      R.Tuple [v1; v2; v3]
    )
  | `Comp_cmd_arg_arg_after_quote (v1, v2) -> R.Case ("Comp_cmd_arg_arg_after_quote",
      let v1 = map_completed_command_argument env v1 in
      let v2 = map_argument_after_quote env v2 in
      R.Tuple [v1; v2]
    )
  | `Cmd_exp_array x -> R.Case ("Cmd_exp_array",
      map_command_expression_array env x
    )
  | `Cmd_mixed_array x -> R.Case ("Cmd_mixed_array",
      map_command_mixed_array env x
    )
  )

and map_command_unary_expression (env : env) (x : CST.command_unary_expression) =
  (match x with
  | `Prim_exp x -> R.Case ("Prim_exp",
      map_primary_expression env x
    )
  | `Cmd_un_op x -> R.Case ("Cmd_un_op",
      map_command_unary_operator env x
    )
  )

and map_command_unary_operator (env : env) (x : CST.command_unary_operator) =
  (match x with
  | `Pat__not_un_exp (v1, v2) -> R.Case ("Pat__not_un_exp",
      let v1 = map_pat__not env v1 in
      let v2 = map_unary_expression env v2 in
      R.Tuple [v1; v2]
    )
  | `BANG_un_exp (v1, v2) -> R.Case ("BANG_un_exp",
      let v1 = (* "!" *) token env v1 in
      let v2 = map_unary_expression env v2 in
      R.Tuple [v1; v2]
    )
  | `Pat__bnot_un_exp (v1, v2) -> R.Case ("Pat__bnot_un_exp",
      let v1 = map_pat__bnot env v1 in
      let v2 = map_unary_expression env v2 in
      R.Tuple [v1; v2]
    )
  | `PLUS_un_exp (v1, v2) -> R.Case ("PLUS_un_exp",
      let v1 = (* "+" *) token env v1 in
      let v2 = map_unary_expression env v2 in
      R.Tuple [v1; v2]
    )
  | `DASH_un_exp (v1, v2) -> R.Case ("DASH_un_exp",
      let v1 = (* "-" *) token env v1 in
      let v2 = map_unary_expression env v2 in
      R.Tuple [v1; v2]
    )
  | `Pre_incr_exp (v1, v2) -> R.Case ("Pre_incr_exp",
      let v1 = (* "++" *) token env v1 in
      let v2 = map_unary_expression env v2 in
      R.Tuple [v1; v2]
    )
  | `Pre_decr_exp (v1, v2) -> R.Case ("Pre_decr_exp",
      let v1 = (* "--" *) token env v1 in
      let v2 = map_unary_expression env v2 in
      R.Tuple [v1; v2]
    )
  | `Cast_exp (v1, v2) -> R.Case ("Cast_exp",
      let v1 = map_attribute_type_value env v1 in
      let v2 = map_unary_expression env v2 in
      R.Tuple [v1; v2]
    )
  | `Attr_exp (v1, v2) -> R.Case ("Attr_exp",
      let v1 = map_attribute_with_arguments env v1 in
      let v2 = map_unary_expression env v2 in
      R.Tuple [v1; v2]
    )
  | `Pat__split_un_exp (v1, v2) -> R.Case ("Pat__split_un_exp",
      let v1 = map_pat__split env v1 in
      let v2 = map_unary_expression env v2 in
      R.Tuple [v1; v2]
    )
  | `Pat__join_un_exp (v1, v2) -> R.Case ("Pat__join_un_exp",
      let v1 = map_pat__join env v1 in
      let v2 = map_unary_expression env v2 in
      R.Tuple [v1; v2]
    )
  )

and map_command_word (env : env) (x : CST.command_word) =
  (match x with
  | `Gene_tok x -> R.Case ("Gene_tok",
      map_generic_token env x
    )
  | `Colon_cmd_arg x -> R.Case ("Colon_cmd_arg",
      map_colon_command_argument env x
    )
  )

and map_comparison_argument_expression (env : env) (x : CST.comparison_argument_expression) =
  (match x with
  | `Addi_arg_exp x -> R.Case ("Addi_arg_exp",
      map_additive_argument_expression env x
    )
  | `Null_coal_arg_exp x -> R.Case ("Null_coal_arg_exp",
      map_null_coalescing_argument_expression env x
    )
  | `Comp_arg_exp_comp_op_choice_addi_arg_exp (v1, v2, v3) -> R.Case ("Comp_arg_exp_comp_op_choice_addi_arg_exp",
      let v1 = map_comparison_argument_expression env v1 in
      let v2 = map_comparison_operator env v2 in
      let v3 = map_anon_choice_addi_arg_exp_5481787 env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_comparison_expression (env : env) (x : CST.comparison_expression) =
  (match x with
  | `Addi_exp x -> R.Case ("Addi_exp",
      map_additive_expression env x
    )
  | `Null_coal_exp x -> R.Case ("Null_coal_exp",
      map_null_coalescing_expression env x
    )
  | `Comp_exp_comp_op_choice_addi_exp (v1, v2, v3) -> R.Case ("Comp_exp_comp_op_choice_addi_exp",
      let v1 = map_comparison_expression env v1 in
      let v2 = map_comparison_operator env v2 in
      let v3 = map_anon_choice_addi_exp_4da1943 env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_completed_argument_array (env : env) (x : CST.completed_argument_array) =
  (match x with
  | `Comp_arg_value_comp_exp_boun (v1, v2) -> R.Case ("Comp_arg_value_comp_exp_boun",
      let v1 = map_completed_argument_value env v1 in
      let v2 = (* completed_expression_boundary *) token env v2 in
      R.Tuple [v1; v2]
    )
  | `Comp_arg_member_comp_member_boun (v1, v2) -> R.Case ("Comp_arg_member_comp_member_boun",
      let v1 = map_completed_argument_member env v1 in
      let v2 = (* completed_member_boundary *) token env v2 in
      R.Tuple [v1; v2]
    )
  )

and map_completed_argument_member (env : env) (x : CST.completed_argument_member) =
  map_member_access env x

and map_completed_argument_value (env : env) (x : CST.completed_argument_value) =
  (match x with
  | `Paren_exp x -> R.Case ("Paren_exp",
      map_parenthesized_expression env x
    )
  | `Sub_exp x -> R.Case ("Sub_exp",
      map_sub_expression env x
    )
  | `Array_exp x -> R.Case ("Array_exp",
      map_array_expression env x
    )
  | `Script_blk_exp x -> R.Case ("Script_blk_exp",
      map_script_block_expression env x
    )
  | `Hash_lit_exp x -> R.Case ("Hash_lit_exp",
      map_hash_literal_expression env x
    )
  | `Elem_access x -> R.Case ("Elem_access",
      map_element_access env x
    )
  | `Invo_exp x -> R.Case ("Invo_exp",
      map_invokation_expression env x
    )
  )

and map_completed_command_argument (env : env) (x : CST.completed_command_argument) =
  map_completed_argument_array env x

and map_data_command (env : env) (x : CST.data_command) =
  map_command_name_expr env x

and map_data_commands_allowed (env : env) ((v1, v2) : CST.data_commands_allowed) =
  let v1 = map_pat__supp env v1 in
  let v2 = map_data_commands_list env v2 in
  R.Tuple [v1; v2]

and map_data_commands_list (env : env) ((v1, v2) : CST.data_commands_list) =
  let v1 = map_data_command env v1 in
  let v2 =
    R.List (List.map (fun (v1, v2) ->
      let v1 = (* "," *) token env v1 in
      let v2 = map_data_command env v2 in
      R.Tuple [v1; v2]
    ) v2)
  in
  R.Tuple [v1; v2]

and map_element_access (env : env) ((v1, v2, v3, v4) : CST.element_access) =
  let v1 = map_primary_expression env v1 in
  let v2 =
    (match v2 with
    | `LBRACK tok -> R.Case ("LBRACK",
        (* "[" *) token env tok
      )
    | `Null_cond_elem_op tok -> R.Case ("Null_cond_elem_op",
        (* "?[" *) token env tok
      )
    )
  in
  let v3 = map_left_assignment_expression env v3 in
  let v4 = (* "]" *) token env v4 in
  R.Tuple [v1; v2; v3; v4]

and map_else_clause (env : env) ((v1, v2, v3) : CST.else_clause) =
  let v1 =
    (match v1 with
    | Some tok -> R.Option (Some (
        (* else_clause_ahead *) token env tok
      ))
    | None -> R.Option None)
  in
  let v2 = map_pat_else env v2 in
  let v3 = map_statement_block env v3 in
  R.Tuple [v1; v2; v3]

and map_elseif_clause (env : env) ((v1, v2, v3, v4, v5, v6) : CST.elseif_clause) =
  let v1 =
    (match v1 with
    | Some tok -> R.Option (Some (
        (* else_clause_ahead *) token env tok
      ))
    | None -> R.Option None)
  in
  let v2 = map_pat_elseif env v2 in
  let v3 = (* "(" *) token env v3 in
  let v4 = map_while_condition env v4 in
  let v5 = (* ")" *) token env v5 in
  let v6 = map_statement_block env v6 in
  R.Tuple [v1; v2; v3; v4; v5; v6]

and map_elseif_clauses (env : env) (xs : CST.elseif_clauses) =
  R.List (List.map (map_elseif_clause env) xs)

and map_enum_member (env : env) ((v1, v2) : CST.enum_member) =
  let v1 = (* simple_name *) token env v1 in
  let v2 =
    (match v2 with
    | Some (v1, v2) -> R.Option (Some (
        let v1 = (* "=" *) token env v1 in
        let v2 =
          (match v2 with
          | `Int_lit x -> R.Case ("Int_lit",
              map_integer_literal env x
            )
          | `Exp x -> R.Case ("Exp",
              map_left_assignment_expression env x
            )
          )
        in
        R.Tuple [v1; v2]
      ))
    | None -> R.Option None)
  in
  R.Tuple [v1; v2]

and map_expandable_string_literal_immediate (env : env) ((v1, v2, v3) : CST.expandable_string_literal_immediate) =
  let v1 =
    R.List (List.map (fun x ->
      (match x with
      | `Pat_b026f1a x -> R.Case ("Pat_b026f1a",
          map_pat_b026f1a env x
        )
      | `Var x -> R.Case ("Var",
          map_variable env x
        )
      | `Pat_75780b9 x -> R.Case ("Pat_75780b9",
          map_pat_75780b9 env x
        )
      | `Pat_8a0ae06 x -> R.Case ("Pat_8a0ae06",
          map_pat_8a0ae06 env x
        )
      | `Pat_421479c_pat_421479c (v1, v2) -> R.Case ("Pat_421479c_pat_421479c",
          let v1 = map_pat_421479c env v1 in
          let v2 = map_pat_421479c env v2 in
          R.Tuple [v1; v2]
        )
      | `Sub_exp x -> R.Case ("Sub_exp",
          map_sub_expression env x
        )
      )
    ) v1)
  in
  let v2 = R.List (List.map (token env (* "$" *)) v2) in
  let v3 = map_pat_421479c env v3 in
  R.Tuple [v1; v2; v3]

and map_expression (env : env) (x : CST.expression) =
  (match x with
  | `Logi_exp x -> R.Case ("Logi_exp",
      map_logical_expression env x
    )
  | `Tern_exp (v1, v2, v3, v4, v5) -> R.Case ("Tern_exp",
      let v1 = map_logical_expression env v1 in
      let v2 = (* "?" *) token env v2 in
      let v3 = map_left_assignment_expression env v3 in
      let v4 = (* ":" *) token env v4 in
      let v5 = map_left_assignment_expression env v5 in
      R.Tuple [v1; v2; v3; v4; v5]
    )
  )

and map_expression_with_unary_operator (env : env) (x : CST.expression_with_unary_operator) =
  (match x with
  | `COMMA_un_exp (v1, v2) -> R.Case ("COMMA_un_exp",
      let v1 = (* "," *) token env v1 in
      let v2 = map_unary_expression env v2 in
      R.Tuple [v1; v2]
    )
  | `Cmd_un_op x -> R.Case ("Cmd_un_op",
      map_command_unary_operator env x
    )
  )

and map_finally_clause (env : env) ((v1, v2) : CST.finally_clause) =
  let v1 = map_pat_fina env v1 in
  let v2 = map_statement_block env v2 in
  R.Tuple [v1; v2]

and map_flow_control_statement (env : env) (x : CST.flow_control_statement) =
  (match x with
  | `Pat_brk_opt_label_exp (v1, v2) -> R.Case ("Pat_brk_opt_label_exp",
      let v1 = map_pat_brk env v1 in
      let v2 =
        (match v2 with
        | Some x -> R.Option (Some (
            map_label_expression env x
          ))
        | None -> R.Option None)
      in
      R.Tuple [v1; v2]
    )
  | `Pat_cont_opt_label_exp (v1, v2) -> R.Case ("Pat_cont_opt_label_exp",
      let v1 = map_pat_cont env v1 in
      let v2 =
        (match v2 with
        | Some x -> R.Option (Some (
            map_label_expression env x
          ))
        | None -> R.Option None)
      in
      R.Tuple [v1; v2]
    )
  | `Pat_throw_opt_pipe (v1, v2) -> R.Case ("Pat_throw_opt_pipe",
      let v1 = map_pat_throw env v1 in
      let v2 =
        (match v2 with
        | Some x -> R.Option (Some (
            map_while_condition env x
          ))
        | None -> R.Option None)
      in
      R.Tuple [v1; v2]
    )
  | `Pat_ret_opt_pipe (v1, v2) -> R.Case ("Pat_ret_opt_pipe",
      let v1 = map_pat_ret env v1 in
      let v2 =
        (match v2 with
        | Some x -> R.Option (Some (
            map_while_condition env x
          ))
        | None -> R.Option None)
      in
      R.Tuple [v1; v2]
    )
  | `Pat_exit_opt_pipe (v1, v2) -> R.Case ("Pat_exit_opt_pipe",
      let v1 = map_pat_exit env v1 in
      let v2 =
        (match v2 with
        | Some x -> R.Option (Some (
            map_while_condition env x
          ))
        | None -> R.Option None)
      in
      R.Tuple [v1; v2]
    )
  )

and map_for_condition (env : env) (x : CST.for_condition) =
  map_pipeline env x

and map_for_initializer (env : env) (x : CST.for_initializer) =
  map_pipeline env x

and map_for_iterator (env : env) (x : CST.for_iterator) =
  map_pipeline env x

and map_format_argument_expression (env : env) (x : CST.format_argument_expression) =
  (match x with
  | `Range_arg_exp x -> R.Case ("Range_arg_exp",
      map_range_argument_expression env x
    )
  | `Format_arg_exp_format_op_range_arg_exp (v1, v2, v3) -> R.Case ("Format_arg_exp_format_op_range_arg_exp",
      let v1 = map_format_argument_expression env v1 in
      let v2 = map_format_operator env v2 in
      let v3 = map_range_argument_expression env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_format_expression (env : env) (x : CST.format_expression) =
  (match x with
  | `Range_exp x -> R.Case ("Range_exp",
      map_range_expression env x
    )
  | `Format_exp_format_op_range_exp (v1, v2, v3) -> R.Case ("Format_exp_format_op_range_exp",
      let v1 = map_format_expression env v1 in
      let v2 = map_format_operator env v2 in
      let v3 = map_range_expression env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_function_parameter_declaration (env : env) ((v1, v2, v3) : CST.function_parameter_declaration) =
  let v1 = (* "(" *) token env v1 in
  let v2 =
    (match v2 with
    | Some x -> R.Option (Some (
        map_parameter_list env x
      ))
    | None -> R.Option None)
  in
  let v3 = (* ")" *) token env v3 in
  R.Tuple [v1; v2; v3]

and map_generic_token (env : env) (x : CST.generic_token) =
  (match x with
  | `Tok_choice_pat_1bbb0cf x -> R.Case ("Tok_choice_pat_1bbb0cf",
      map_tok_choice_pat_1bbb0cf env x
    )
  | `Choice_cmd_word_start_rep_choice_cmd_word_part (v1, v2) -> R.Case ("Choice_cmd_word_start_rep_choice_cmd_word_part",
      let v1 =
        (match v1 with
        | `Cmd_word_start tok -> R.Case ("Cmd_word_start",
            (* command_word_start *) token env tok
          )
        | `Tok_prec_p1_pat_d01e7ed x -> R.Case ("Tok_prec_p1_pat_d01e7ed",
            map_tok_prec_p1_pat_d01e7ed env x
          )
        )
      in
      let v2 =
        R.List (List.map (fun x ->
          (match x with
          | `Cmd_word_part tok -> R.Case ("Cmd_word_part",
              (* command_word_part *) token env tok
            )
          | `Cmd_word_exp_choice_str_lit (v1, v2) -> R.Case ("Cmd_word_exp_choice_str_lit",
              let v1 = (* command_word_expression *) token env v1 in
              let v2 =
                (match v2 with
                | `Str_lit x -> R.Case ("Str_lit",
                    map_quoted_command_argument env x
                  )
                | `Sub_exp x -> R.Case ("Sub_exp",
                    map_sub_expression env x
                  )
                )
              in
              R.Tuple [v1; v2]
            )
          )
        ) v2)
      in
      R.Tuple [v1; v2]
    )
  )

and map_hash_entry (env : env) ((v1, v2, v3, v4, v5) : CST.hash_entry) =
  let v1 = map_key_expression env v1 in
  let v2 = (* "=" *) token env v2 in
  let v3 = map_statement env v3 in
  let v4 = (* statement_terminator *) token env v4 in
  let v5 = R.List (List.map (token env (* ";" *)) v5) in
  R.Tuple [v1; v2; v3; v4; v5]

and map_hash_literal_body (env : env) (xs : CST.hash_literal_body) =
  R.List (List.map (map_hash_entry env) xs)

and map_hash_literal_expression (env : env) ((v1, v2, v3) : CST.hash_literal_expression) =
  let v1 = (* "@{" *) token env v1 in
  let v2 =
    (match v2 with
    | Some x -> R.Option (Some (
        map_hash_literal_body env x
      ))
    | None -> R.Option None)
  in
  let v3 = (* "}" *) token env v3 in
  R.Tuple [v1; v2; v3]

and map_invokation_expression (env : env) (x : CST.invokation_expression) =
  (match x with
  | `Prim_exp_member_access_op_member_name_arg_list (v1, v2, v3, v4) -> R.Case ("Prim_exp_member_access_op_member_name_arg_list",
      let v1 = map_primary_expression env v1 in
      let v2 = map_member_access_operator env v2 in
      let v3 = map_member_name env v3 in
      let v4 = map_argument_list env v4 in
      R.Tuple [v1; v2; v3; v4]
    )
  | `Prim_exp_COLONCOLON_member_name_arg_list (v1, v2, v3, v4) -> R.Case ("Prim_exp_COLONCOLON_member_name_arg_list",
      let v1 = map_primary_expression env v1 in
      let v2 = (* "::" *) token env v2 in
      let v3 = map_member_name env v3 in
      let v4 = map_argument_list env v4 in
      R.Tuple [v1; v2; v3; v4]
    )
  | `Prim_exp_member_access_op_member_name_script_blk_arg_start_script_blk_exp (v1, v2, v3, v4, v5) -> R.Case ("Prim_exp_member_access_op_member_name_script_blk_arg_start_script_blk_exp",
      let v1 = map_primary_expression env v1 in
      let v2 = map_member_access_operator env v2 in
      let v3 = map_member_name env v3 in
      let v4 = (* script_block_argument_start *) token env v4 in
      let v5 = map_script_block_expression env v5 in
      R.Tuple [v1; v2; v3; v4; v5]
    )
  | `Prim_exp_COLONCOLON_member_name_script_blk_arg_start_script_blk_exp (v1, v2, v3, v4, v5) -> R.Case ("Prim_exp_COLONCOLON_member_name_script_blk_arg_start_script_blk_exp",
      let v1 = map_primary_expression env v1 in
      let v2 = (* "::" *) token env v2 in
      let v3 = map_member_name env v3 in
      let v4 = (* script_block_argument_start *) token env v4 in
      let v5 = map_script_block_expression env v5 in
      R.Tuple [v1; v2; v3; v4; v5]
    )
  | `Invo_fore_exp (v1, v2, v3, v4) -> R.Case ("Invo_fore_exp",
      let v1 = map_primary_expression env v1 in
      let v2 = map_member_access_operator env v2 in
      let v3 =
        (* pattern [fF][oO][rR][eE][aA][cC][hH] *) token env v3
      in
      let v4 =
        (match v4 with
        | `Script_blk_exp x -> R.Case ("Script_blk_exp",
            map_script_block_expression env x
          )
        | `Arg_list x -> R.Case ("Arg_list",
            map_argument_list env x
          )
        )
      in
      R.Tuple [v1; v2; v3; v4]
    )
  )

and map_key_expression (env : env) (x : CST.key_expression) =
  (match x with
  | `Simple_name tok -> R.Case ("Simple_name",
      (* simple_name *) token env tok
    )
  | `Un_exp x -> R.Case ("Un_exp",
      map_unary_expression env x
    )
  )

and map_label_expression (env : env) (x : CST.label_expression) =
  (match x with
  | `Label tok -> R.Case ("Label",
      (* label *) token env tok
    )
  | `Simple_name tok -> R.Case ("Simple_name",
      (* simple_name *) token env tok
    )
  | `Un_exp x -> R.Case ("Un_exp",
      map_unary_expression env x
    )
  )

and map_labeled_statement (env : env) (x : CST.labeled_statement) =
  (match x with
  | `Switch_stmt (v1, v2, v3, v4) -> R.Case ("Switch_stmt",
      let v1 = map_pat_switch env v1 in
      let v2 =
        (match v2 with
        | Some x -> R.Option (Some (
            map_switch_parameters env x
          ))
        | None -> R.Option None)
      in
      let v3 = map_switch_condition env v3 in
      let v4 = map_switch_body env v4 in
      R.Tuple [v1; v2; v3; v4]
    )
  | `Fore_stmt (v1, v2, v3, v4, v5, v6, v7, v8) -> R.Case ("Fore_stmt",
      let v1 = map_pat_fore env v1 in
      let v2 =
        (match v2 with
        | Some x -> R.Option (Some (
            map_foreach_parameter env x
          ))
        | None -> R.Option None)
      in
      let v3 = (* "(" *) token env v3 in
      let v4 = map_variable env v4 in
      let v5 = map_pat_in env v5 in
      let v6 = map_while_condition env v6 in
      let v7 = (* ")" *) token env v7 in
      let v8 = map_statement_block env v8 in
      R.Tuple [v1; v2; v3; v4; v5; v6; v7; v8]
    )
  | `For_stmt (v1, v2, v3, v4, v5) -> R.Case ("For_stmt",
      let v1 = map_pat_for env v1 in
      let v2 = (* "(" *) token env v2 in
      let v3 =
        (match v3 with
        | Some (v1, v2) -> R.Option (Some (
            let v1 =
              (match v1 with
              | Some (v1, v2) -> R.Option (Some (
                  let v1 = map_for_initializer env v1 in
                  let v2 = (* statement_terminator *) token env v2 in
                  R.Tuple [v1; v2]
                ))
              | None -> R.Option None)
            in
            let v2 =
              (match v2 with
              | Some (v1, v2, v3) -> R.Option (Some (
                  let v1 = map_anon_choice_SEMI_fddb21e env v1 in
                  let v2 =
                    (match v2 with
                    | Some (v1, v2) -> R.Option (Some (
                        let v1 = map_for_condition env v1 in
                        let v2 = (* statement_terminator *) token env v2 in
                        R.Tuple [v1; v2]
                      ))
                    | None -> R.Option None)
                  in
                  let v3 =
                    (match v3 with
                    | Some (v1, v2) -> R.Option (Some (
                        let v1 = map_anon_choice_SEMI_fddb21e env v1 in
                        let v2 =
                          (match v2 with
                          | Some (v1, v2) -> R.Option (Some (
                              let v1 = map_for_iterator env v1 in
                              let v2 = (* statement_terminator *) token env v2 in
                              R.Tuple [v1; v2]
                            ))
                          | None -> R.Option None)
                        in
                        R.Tuple [v1; v2]
                      ))
                    | None -> R.Option None)
                  in
                  R.Tuple [v1; v2; v3]
                ))
              | None -> R.Option None)
            in
            R.Tuple [v1; v2]
          ))
        | None -> R.Option None)
      in
      let v4 = (* ")" *) token env v4 in
      let v5 = map_statement_block env v5 in
      R.Tuple [v1; v2; v3; v4; v5]
    )
  | `While_stmt (v1, v2, v3, v4, v5) -> R.Case ("While_stmt",
      let v1 = map_pat_while env v1 in
      let v2 = (* "(" *) token env v2 in
      let v3 = map_while_condition env v3 in
      let v4 = (* ")" *) token env v4 in
      let v5 = map_statement_block env v5 in
      R.Tuple [v1; v2; v3; v4; v5]
    )
  | `Do_stmt (v1, v2, v3, v4, v5, v6) -> R.Case ("Do_stmt",
      let v1 = map_pat_do env v1 in
      let v2 = map_statement_block env v2 in
      let v3 =
        (match v3 with
        | `Pat_while x -> R.Case ("Pat_while",
            map_pat_while env x
          )
        | `Pat_until x -> R.Case ("Pat_until",
            map_pat_until env x
          )
        )
      in
      let v4 = (* "(" *) token env v4 in
      let v5 = map_while_condition env v5 in
      let v6 = (* ")" *) token env v6 in
      R.Tuple [v1; v2; v3; v4; v5; v6]
    )
  )

and map_left_assignment_expression (env : env) (x : CST.left_assignment_expression) =
  map_expression env x

and map_literal (env : env) (x : CST.literal) =
  (match x with
  | `Int_lit x -> R.Case ("Int_lit",
      map_integer_literal env x
    )
  | `Str_lit x -> R.Case ("Str_lit",
      map_quoted_command_argument env x
    )
  | `Real_lit tok -> R.Case ("Real_lit",
      (* real_literal *) token env tok
    )
  )

and map_logical_argument_expression (env : env) (x : CST.logical_argument_expression) =
  (match x with
  | `Bitw_arg_exp x -> R.Case ("Bitw_arg_exp",
      map_bitwise_argument_expression env x
    )
  | `Logi_arg_exp_choice_pat__and_bitw_arg_exp (v1, v2, v3) -> R.Case ("Logi_arg_exp_choice_pat__and_bitw_arg_exp",
      let v1 = map_logical_argument_expression env v1 in
      let v2 = map_anon_choice_pat__and_bad5cfe env v2 in
      let v3 = map_bitwise_argument_expression env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_logical_expression (env : env) (x : CST.logical_expression) =
  (match x with
  | `Bitw_exp x -> R.Case ("Bitw_exp",
      map_bitwise_expression env x
    )
  | `Logi_exp_choice_pat__and_bitw_exp (v1, v2, v3) -> R.Case ("Logi_exp_choice_pat__and_bitw_exp",
      let v1 = map_logical_expression env v1 in
      let v2 = map_anon_choice_pat__and_bad5cfe env v2 in
      let v3 = map_bitwise_expression env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_member_access (env : env) (x : CST.member_access) =
  (match x with
  | `Prim_exp_member_access_op_member_name (v1, v2, v3) -> R.Case ("Prim_exp_member_access_op_member_name",
      let v1 = map_primary_expression env v1 in
      let v2 = map_member_access_operator env v2 in
      let v3 = map_member_name env v3 in
      R.Tuple [v1; v2; v3]
    )
  | `Prim_exp_COLONCOLON_member_name (v1, v2, v3) -> R.Case ("Prim_exp_COLONCOLON_member_name",
      let v1 = map_primary_expression env v1 in
      let v2 = (* "::" *) token env v2 in
      let v3 = map_member_name env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_member_name (env : env) (x : CST.member_name) =
  (match x with
  | `Fore_member_name tok -> R.Case ("Fore_member_name",
      (* pattern [fF][oO][rR][eE][aA][cC][hH] *) token env tok
    )
  | `Simple_name tok -> R.Case ("Simple_name",
      (* simple_name *) token env tok
    )
  | `Str_lit x -> R.Case ("Str_lit",
      map_quoted_command_argument env x
    )
  | `Exp_with_un_op x -> R.Case ("Exp_with_un_op",
      map_expression_with_unary_operator env x
    )
  | `Value x -> R.Case ("Value",
      map_value env x
    )
  )

and map_multiplicative_argument_expression (env : env) (x : CST.multiplicative_argument_expression) =
  (match x with
  | `Format_arg_exp x -> R.Case ("Format_arg_exp",
      map_format_argument_expression env x
    )
  | `Mult_arg_exp_choice_SLASH_format_arg_exp (v1, v2, v3) -> R.Case ("Mult_arg_exp_choice_SLASH_format_arg_exp",
      let v1 = map_multiplicative_argument_expression env v1 in
      let v2 = map_anon_choice_SLASH_4ca1f7c env v2 in
      let v3 = map_format_argument_expression env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_multiplicative_expression (env : env) (x : CST.multiplicative_expression) =
  (match x with
  | `Format_exp x -> R.Case ("Format_exp",
      map_format_expression env x
    )
  | `Mult_exp_choice_SLASH_format_exp (v1, v2, v3) -> R.Case ("Mult_exp_choice_SLASH_format_exp",
      let v1 = map_multiplicative_expression env v1 in
      let v2 = map_anon_choice_SLASH_4ca1f7c env v2 in
      let v3 = map_format_expression env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_named_block (env : env) ((v1, v2) : CST.named_block) =
  let v1 = map_block_name env v1 in
  let v2 = map_statement_block env v2 in
  R.Tuple [v1; v2]

and map_named_block_list (env : env) (xs : CST.named_block_list) =
  R.List (List.map (map_named_block env) xs)

and map_null_coalescing_argument_expression (env : env) ((v1, v2, v3) : CST.null_coalescing_argument_expression) =
  let v1 = map_anon_choice_addi_arg_exp_5481787 env v1 in
  let v2 = (* "??" *) token env v2 in
  let v3 = map_additive_argument_expression env v3 in
  R.Tuple [v1; v2; v3]

and map_null_coalescing_expression (env : env) ((v1, v2, v3) : CST.null_coalescing_expression) =
  let v1 = map_anon_choice_addi_exp_4da1943 env v1 in
  let v2 = (* "??" *) token env v2 in
  let v3 = map_additive_expression env v3 in
  R.Tuple [v1; v2; v3]

and map_param_block (env : env) ((v1, v2, v3, v4, v5) : CST.param_block) =
  let v1 =
    (match v1 with
    | Some x -> R.Option (Some (
        map_attribute_list env x
      ))
    | None -> R.Option None)
  in
  let v2 = map_pat_param env v2 in
  let v3 = (* "(" *) token env v3 in
  let v4 =
    (match v4 with
    | Some x -> R.Option (Some (
        map_parameter_list env x
      ))
    | None -> R.Option None)
  in
  let v5 = (* ")" *) token env v5 in
  R.Tuple [v1; v2; v3; v4; v5]

and map_parameter_list (env : env) ((v1, v2) : CST.parameter_list) =
  let v1 = map_script_parameter env v1 in
  let v2 =
    R.List (List.map (fun (v1, v2) ->
      let v1 = (* "," *) token env v1 in
      let v2 = map_script_parameter env v2 in
      R.Tuple [v1; v2]
    ) v2)
  in
  R.Tuple [v1; v2]

and map_parenthesized_expression (env : env) ((v1, v2, v3) : CST.parenthesized_expression) =
  let v1 = (* "(" *) token env v1 in
  let v2 = map_while_condition env v2 in
  let v3 = (* ")" *) token env v3 in
  R.Tuple [v1; v2; v3]

and map_pipeline (env : env) (x : CST.pipeline) =
  (match x with
  | `Assign_exp (v1, v2, v3) -> R.Case ("Assign_exp",
      let v1 = map_left_assignment_expression env v1 in
      let v2 = map_assignement_operator env v2 in
      let v3 = map_statement env v3 in
      R.Tuple [v1; v2; v3]
    )
  | `Pipe_chain_rep_pipe_chain_tail_pipe_chain (v1, v2) -> R.Case ("Pipe_chain_rep_pipe_chain_tail_pipe_chain",
      let v1 = map_pipeline_chain env v1 in
      let v2 =
        R.List (List.map (fun (v1, v2) ->
          let v1 = map_pipeline_chain_tail env v1 in
          let v2 = map_pipeline_chain env v2 in
          R.Tuple [v1; v2]
        ) v2)
      in
      R.Tuple [v1; v2]
    )
  )

and map_pipeline_chain (env : env) (x : CST.pipeline_chain) =
  (match x with
  | `Exp_opt_redirs_opt_pipe_tail (v1, v2, v3) -> R.Case ("Exp_opt_redirs_opt_pipe_tail",
      let v1 = map_left_assignment_expression env v1 in
      let v2 =
        (match v2 with
        | Some x -> R.Option (Some (
            map_redirections env x
          ))
        | None -> R.Option None)
      in
      let v3 =
        (match v3 with
        | Some x -> R.Option (Some (
            map_pipeline_tail env x
          ))
        | None -> R.Option None)
      in
      R.Tuple [v1; v2; v3]
    )
  | `Cmd_opt_verb_cmd_arg_opt_pipe_tail (v1, v2, v3) -> R.Case ("Cmd_opt_verb_cmd_arg_opt_pipe_tail",
      let v1 = map_command env v1 in
      let v2 =
        (match v2 with
        | Some x -> R.Option (Some (
            map_verbatim_command_argument env x
          ))
        | None -> R.Option None)
      in
      let v3 =
        (match v3 with
        | Some x -> R.Option (Some (
            map_pipeline_tail env x
          ))
        | None -> R.Option None)
      in
      R.Tuple [v1; v2; v3]
    )
  )

and map_pipeline_tail (env : env) (xs : CST.pipeline_tail) =
  R.List (List.map (fun (v1, v2) ->
    let v1 = (* "|" *) token env v1 in
    let v2 = map_command env v2 in
    R.Tuple [v1; v2]
  ) xs)

and map_primary_expression (env : env) (x : CST.primary_expression) =
  (match x with
  | `Value x -> R.Case ("Value",
      map_value env x
    )
  | `Member_access x -> R.Case ("Member_access",
      map_completed_argument_member env x
    )
  | `Elem_access x -> R.Case ("Elem_access",
      map_element_access env x
    )
  | `Invo_exp x -> R.Case ("Invo_exp",
      map_invokation_expression env x
    )
  | `Post_incr_exp (v1, v2) -> R.Case ("Post_incr_exp",
      let v1 = map_primary_expression env v1 in
      let v2 = (* "++" *) token env v2 in
      R.Tuple [v1; v2]
    )
  | `Post_decr_exp (v1, v2) -> R.Case ("Post_decr_exp",
      let v1 = map_primary_expression env v1 in
      let v2 = (* "--" *) token env v2 in
      R.Tuple [v1; v2]
    )
  )

and map_quoted_command_argument (env : env) (x : CST.quoted_command_argument) =
  map_string_literal env x

and map_range_argument_expression (env : env) (x : CST.range_argument_expression) =
  (match x with
  | `Un_exp x -> R.Case ("Un_exp",
      map_unary_expression env x
    )
  | `Range_arg_exp_DOTDOT_un_exp (v1, v2, v3) -> R.Case ("Range_arg_exp_DOTDOT_un_exp",
      let v1 = map_range_argument_expression env v1 in
      let v2 = (* ".." *) token env v2 in
      let v3 = map_unary_expression env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_range_expression (env : env) (x : CST.range_expression) =
  (match x with
  | `Array_lit_exp x -> R.Case ("Array_lit_exp",
      map_array_literal_expression env x
    )
  | `Range_exp_DOTDOT_array_lit_exp (v1, v2, v3) -> R.Case ("Range_exp_DOTDOT_array_lit_exp",
      let v1 = map_range_expression env v1 in
      let v2 = (* ".." *) token env v2 in
      let v3 = map_array_literal_expression env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_redirected_file_name (env : env) (x : CST.redirected_file_name) =
  (match x with
  | `Cmd_arg x -> R.Case ("Cmd_arg",
      map_command_argument env x
    )
  | `Prim_exp x -> R.Case ("Prim_exp",
      map_primary_expression env x
    )
  | `Gene_tok x -> R.Case ("Gene_tok",
      map_generic_token env x
    )
  )

and map_redirection (env : env) (x : CST.redirection) =
  (match x with
  | `Merg_redi_op x -> R.Case ("Merg_redi_op",
      map_merging_redirection_operator env x
    )
  | `File_redi_op_redi_file_name (v1, v2) -> R.Case ("File_redi_op_redi_file_name",
      let v1 = map_file_redirection_operator env v1 in
      let v2 = map_redirected_file_name env v2 in
      R.Tuple [v1; v2]
    )
  )

and map_redirections (env : env) (xs : CST.redirections) =
  R.List (List.map (map_redirection env) xs)

and map_script_block (env : env) (x : CST.script_block) =
  (match x with
  | `Script_blk_body x -> R.Case ("Script_blk_body",
      map_script_block_body env x
    )
  | `Param_blk_rep_SEMI_opt_script_blk_body (v1, v2, v3) -> R.Case ("Param_blk_rep_SEMI_opt_script_blk_body",
      let v1 = map_param_block env v1 in
      let v2 = R.List (List.map (token env (* ";" *)) v2) in
      let v3 =
        (match v3 with
        | Some x -> R.Option (Some (
            map_script_block_body env x
          ))
        | None -> R.Option None)
      in
      R.Tuple [v1; v2; v3]
    )
  )

and map_script_block_body (env : env) (x : CST.script_block_body) =
  (match x with
  | `Named_blk_list x -> R.Case ("Named_blk_list",
      map_named_block_list env x
    )
  | `Stmt_list x -> R.Case ("Stmt_list",
      map_statement_list env x
    )
  )

and map_script_block_expression (env : env) ((v1, v2, v3, v4) : CST.script_block_expression) =
  let v1 = (* "{" *) token env v1 in
  let v2 =
    (match v2 with
    | Some x -> R.Option (Some (
        map_param_block env x
      ))
    | None -> R.Option None)
  in
  let v3 =
    (match v3 with
    | Some x -> R.Option (Some (
        map_script_block env x
      ))
    | None -> R.Option None)
  in
  let v4 = (* "}" *) token env v4 in
  R.Tuple [v1; v2; v3; v4]

and map_script_parameter (env : env) ((v1, v2, v3) : CST.script_parameter) =
  let v1 =
    (match v1 with
    | Some x -> R.Option (Some (
        map_attribute_list env x
      ))
    | None -> R.Option None)
  in
  let v2 = map_variable env v2 in
  let v3 =
    (match v3 with
    | Some x -> R.Option (Some (
        map_script_parameter_default env x
      ))
    | None -> R.Option None)
  in
  R.Tuple [v1; v2; v3]

and map_script_parameter_default (env : env) ((v1, v2) : CST.script_parameter_default) =
  let v1 = (* "=" *) token env v1 in
  let v2 = map_left_assignment_expression env v2 in
  R.Tuple [v1; v2]

and map_statement (env : env) (x : CST.statement) =
  (match x with
  | `If_stmt (v1, v2, v3, v4, v5, v6, v7) -> R.Case ("If_stmt",
      let v1 = map_pat_if env v1 in
      let v2 = (* "(" *) token env v2 in
      let v3 = map_while_condition env v3 in
      let v4 = (* ")" *) token env v4 in
      let v5 = map_statement_block env v5 in
      let v6 =
        (match v6 with
        | Some x -> R.Option (Some (
            map_elseif_clauses env x
          ))
        | None -> R.Option None)
      in
      let v7 =
        (match v7 with
        | Some x -> R.Option (Some (
            map_else_clause env x
          ))
        | None -> R.Option None)
      in
      R.Tuple [v1; v2; v3; v4; v5; v6; v7]
    )
  | `Opt_label_labe_stmt (v1, v2) -> R.Case ("Opt_label_labe_stmt",
      let v1 =
        (match v1 with
        | Some tok -> R.Option (Some (
            (* label *) token env tok
          ))
        | None -> R.Option None)
      in
      let v2 = map_labeled_statement env v2 in
      R.Tuple [v1; v2]
    )
  | `Func_stmt (v1, v2, v3, v4, v5, v6) -> R.Case ("Func_stmt",
      let v1 =
        (match v1 with
        | `Pat_func x -> R.Case ("Pat_func",
            map_pat_func env x
          )
        | `Pat_filter x -> R.Case ("Pat_filter",
            map_pat_filter env x
          )
        | `Pat_work x -> R.Case ("Pat_work",
            map_pat_work env x
          )
        )
      in
      let v2 = (* command_token *) token env v2 in
      let v3 =
        (match v3 with
        | Some x -> R.Option (Some (
            map_function_parameter_declaration env x
          ))
        | None -> R.Option None)
      in
      let v4 = (* "{" *) token env v4 in
      let v5 =
        (match v5 with
        | Some x -> R.Option (Some (
            map_script_block env x
          ))
        | None -> R.Option None)
      in
      let v6 = (* "}" *) token env v6 in
      R.Tuple [v1; v2; v3; v4; v5; v6]
    )
  | `Class_stmt (v1, v2, v3, v4, v5, v6, v7) -> R.Case ("Class_stmt",
      let v1 =
        (match v1 with
        | Some x -> R.Option (Some (
            map_attribute_list env x
          ))
        | None -> R.Option None)
      in
      let v2 = map_tok_prec_p1_pat_class env v2 in
      let v3 = (* simple_name *) token env v3 in
      let v4 =
        (match v4 with
        | Some (v1, v2, v3) -> R.Option (Some (
            let v1 = (* ":" *) token env v1 in
            let v2 = map_attribute_name env v2 in
            let v3 =
              R.List (List.map (fun (v1, v2) ->
                let v1 = (* "," *) token env v1 in
                let v2 = map_attribute_name env v2 in
                R.Tuple [v1; v2]
              ) v3)
            in
            R.Tuple [v1; v2; v3]
          ))
        | None -> R.Option None)
      in
      let v5 = (* "{" *) token env v5 in
      let v6 =
        R.List (List.map (fun x ->
          (match x with
          | `Class_prop_defi_stmt_term_rep_SEMI (v1, v2, v3) -> R.Case ("Class_prop_defi_stmt_term_rep_SEMI",
              let v1 = map_class_property_definition env v1 in
              let v2 = (* statement_terminator *) token env v2 in
              let v3 = R.List (List.map (token env (* ";" *)) v3) in
              R.Tuple [v1; v2; v3]
            )
          | `Class_meth_defi x -> R.Case ("Class_meth_defi",
              map_class_method_definition env x
            )
          )
        ) v6)
      in
      let v7 = (* "}" *) token env v7 in
      R.Tuple [v1; v2; v3; v4; v5; v6; v7]
    )
  | `Enum_stmt (v1, v2, v3, v4, v5, v6) -> R.Case ("Enum_stmt",
      let v1 =
        (match v1 with
        | Some x -> R.Option (Some (
            map_attribute_list env x
          ))
        | None -> R.Option None)
      in
      let v2 = map_tok_prec_p1_pat_enum env v2 in
      let v3 = (* simple_name *) token env v3 in
      let v4 = (* "{" *) token env v4 in
      let v5 =
        R.List (List.map (fun (v1, v2, v3) ->
          let v1 = map_enum_member env v1 in
          let v2 = (* statement_terminator *) token env v2 in
          let v3 = R.List (List.map (token env (* ";" *)) v3) in
          R.Tuple [v1; v2; v3]
        ) v5)
      in
      let v6 = (* "}" *) token env v6 in
      R.Tuple [v1; v2; v3; v4; v5; v6]
    )
  | `Flow_cont_stmt_stmt_term (v1, v2) -> R.Case ("Flow_cont_stmt_stmt_term",
      let v1 = map_flow_control_statement env v1 in
      let v2 = (* statement_terminator *) token env v2 in
      R.Tuple [v1; v2]
    )
  | `Trap_stmt (v1, v2, v3) -> R.Case ("Trap_stmt",
      let v1 = map_pat_trap env v1 in
      let v2 =
        (match v2 with
        | Some x -> R.Option (Some (
            map_attribute_type_value env x
          ))
        | None -> R.Option None)
      in
      let v3 = map_statement_block env v3 in
      R.Tuple [v1; v2; v3]
    )
  | `Try_stmt (v1, v2, v3) -> R.Case ("Try_stmt",
      let v1 = map_pat_try env v1 in
      let v2 = map_statement_block env v2 in
      let v3 =
        (match v3 with
        | `Catch_clauses_opt_fina_clause (v1, v2) -> R.Case ("Catch_clauses_opt_fina_clause",
            let v1 = map_catch_clauses env v1 in
            let v2 =
              (match v2 with
              | Some x -> R.Option (Some (
                  map_finally_clause env x
                ))
              | None -> R.Option None)
            in
            R.Tuple [v1; v2]
          )
        | `Opt_fina_clause opt -> R.Case ("Opt_fina_clause",
            (match opt with
            | Some x -> R.Option (Some (
                map_finally_clause env x
              ))
            | None -> R.Option None)
          )
        )
      in
      R.Tuple [v1; v2; v3]
    )
  | `Data_stmt (v1, v2, v3, v4) -> R.Case ("Data_stmt",
      let v1 = map_pat_data env v1 in
      let v2 =
        (match v2 with
        | Some tok -> R.Option (Some (
            (* simple_name *) token env tok
          ))
        | None -> R.Option None)
      in
      let v3 =
        (match v3 with
        | Some x -> R.Option (Some (
            map_data_commands_allowed env x
          ))
        | None -> R.Option None)
      in
      let v4 = map_statement_block env v4 in
      R.Tuple [v1; v2; v3; v4]
    )
  | `Inli_stmt (v1, v2) -> R.Case ("Inli_stmt",
      let v1 = map_pat_inli env v1 in
      let v2 = map_statement_block env v2 in
      R.Tuple [v1; v2]
    )
  | `Para_stmt (v1, v2) -> R.Case ("Para_stmt",
      let v1 = map_pat_para env v1 in
      let v2 = map_statement_block env v2 in
      R.Tuple [v1; v2]
    )
  | `Seq_stmt (v1, v2) -> R.Case ("Seq_stmt",
      let v1 = map_pat_seq env v1 in
      let v2 = map_statement_block env v2 in
      R.Tuple [v1; v2]
    )
  | `Pipe_stmt_term (v1, v2) -> R.Case ("Pipe_stmt_term",
      let v1 = map_while_condition env v1 in
      let v2 = (* statement_terminator *) token env v2 in
      R.Tuple [v1; v2]
    )
  | `Pipe_back_op (v1, v2) -> R.Case ("Pipe_back_op",
      let v1 = map_while_condition env v1 in
      let v2 = (* "&" *) token env v2 in
      R.Tuple [v1; v2]
    )
  | `Empty_stmt tok -> R.Case ("Empty_stmt",
      (* ";" *) token env tok
    )
  )

and map_statement_block (env : env) ((v1, v2, v3) : CST.statement_block) =
  let v1 = (* "{" *) token env v1 in
  let v2 =
    (match v2 with
    | Some x -> R.Option (Some (
        map_statement_list env x
      ))
    | None -> R.Option None)
  in
  let v3 = (* "}" *) token env v3 in
  R.Tuple [v1; v2; v3]

and map_statement_list (env : env) (xs : CST.statement_list) =
  R.List (List.map (map_statement env) xs)

and map_string_literal (env : env) (x : CST.string_literal) =
  (match x with
  | `Expa_str_lit (v1, v2, v3, v4) -> R.Case ("Expa_str_lit",
      let v1 = map_pat_421479c env v1 in
      let v2 =
        R.List (List.map (fun x ->
          (match x with
          | `Imm_tok_prec_p1_pat_b026f1a x -> R.Case ("Imm_tok_prec_p1_pat_b026f1a",
              map_imm_tok_prec_p1_pat_b026f1a env x
            )
          | `Var x -> R.Case ("Var",
              map_variable env x
            )
          | `Sub_exp x -> R.Case ("Sub_exp",
              map_sub_expression env x
            )
          | `Imm_tok_pat_f92c05a x -> R.Case ("Imm_tok_pat_f92c05a",
              map_imm_tok_pat_f92c05a env x
            )
          | `Imm_tok_pat_8a0ae06 x -> R.Case ("Imm_tok_pat_8a0ae06",
              map_imm_tok_pat_8a0ae06 env x
            )
          | `Imm_tok_pat_421479c_pat_421479c x -> R.Case ("Imm_tok_pat_421479c_pat_421479c",
              map_imm_tok_pat_421479c_pat_421479c env x
            )
          | `Imm_tok_dollar x -> R.Case ("Imm_tok_dollar",
              map_imm_tok_dollar env x
            )
          )
        ) v2)
      in
      let v3 =
        R.List (List.map (fun x ->
          map_imm_tok_dollar env x
        ) v3)
      in
      let v4 = map_imm_tok_pat_421479c env v4 in
      R.Tuple [v1; v2; v3; v4]
    )
  | `Verb_str_charas tok -> R.Case ("Verb_str_charas",
      (* verbatim_string_characters *) token env tok
    )
  | `Expa_here_str_lit (v1, v2) -> R.Case ("Expa_here_str_lit",
      let v1 = map_pat_8357948 env v1 in
      let v2 =
        (match v2 with
        | `Imm_tok_prec_p2_pat_8992db4 x -> R.Case ("Imm_tok_prec_p2_pat_8992db4",
            map_imm_tok_prec_p2_pat_8992db4 env x
          )
        | `Rep_choice_imm_tok_prec_p1_pat_b45f689_imm_tok_prec_p1_pat_0f46d6a (v1, v2) -> R.Case ("Rep_choice_imm_tok_prec_p1_pat_b45f689_imm_tok_prec_p1_pat_0f46d6a",
            let v1 =
              R.List (List.map (fun x ->
                (match x with
                | `Imm_tok_prec_p1_pat_b45f689 x -> R.Case ("Imm_tok_prec_p1_pat_b45f689",
                    map_imm_tok_prec_p1_pat_b45f689 env x
                  )
                | `Var x -> R.Case ("Var",
                    map_variable env x
                  )
                | `Sub_exp x -> R.Case ("Sub_exp",
                    map_sub_expression env x
                  )
                | `Imm_tok_pat_509ec78 x -> R.Case ("Imm_tok_pat_509ec78",
                    map_imm_tok_pat_509ec78 env x
                  )
                | `Imm_tok_dollar x -> R.Case ("Imm_tok_dollar",
                    map_imm_tok_dollar env x
                  )
                | `Imm_tok_pat_8a0ae06 x -> R.Case ("Imm_tok_pat_8a0ae06",
                    map_imm_tok_pat_8a0ae06 env x
                  )
                )
              ) v1)
            in
            let v2 = map_imm_tok_prec_p1_pat_0f46d6a env v2 in
            R.Tuple [v1; v2]
          )
        )
      in
      R.Tuple [v1; v2]
    )
  | `Verb_here_str_charas tok -> R.Case ("Verb_here_str_charas",
      (* verbatim_here_string_characters *) token env tok
    )
  )

and map_sub_expression (env : env) ((v1, v2, v3) : CST.sub_expression) =
  let v1 = (* "$(" *) token env v1 in
  let v2 =
    (match v2 with
    | Some x -> R.Option (Some (
        map_statement_list env x
      ))
    | None -> R.Option None)
  in
  let v3 = (* ")" *) token env v3 in
  R.Tuple [v1; v2; v3]

and map_switch_body (env : env) ((v1, v2, v3) : CST.switch_body) =
  let v1 = (* "{" *) token env v1 in
  let v2 =
    (match v2 with
    | Some x -> R.Option (Some (
        map_switch_clauses env x
      ))
    | None -> R.Option None)
  in
  let v3 = (* "}" *) token env v3 in
  R.Tuple [v1; v2; v3]

and map_switch_clause (env : env) ((v1, v2, v3, v4) : CST.switch_clause) =
  let v1 = map_switch_clause_condition env v1 in
  let v2 = map_statement_block env v2 in
  let v3 =
    (match v3 with
    | Some tok -> R.Option (Some (
        (* statement_terminator *) token env tok
      ))
    | None -> R.Option None)
  in
  let v4 = R.List (List.map (token env (* ";" *)) v4) in
  R.Tuple [v1; v2; v3; v4]

and map_switch_clause_condition (env : env) (x : CST.switch_clause_condition) =
  (match x with
  | `Cmd_tok tok -> R.Case ("Cmd_tok",
      (* command_token *) token env tok
    )
  | `Prim_exp x -> R.Case ("Prim_exp",
      map_primary_expression env x
    )
  )

and map_switch_clauses (env : env) (xs : CST.switch_clauses) =
  R.List (List.map (map_switch_clause env) xs)

and map_switch_condition (env : env) (x : CST.switch_condition) =
  (match x with
  | `LPAR_pipe_RPAR x -> R.Case ("LPAR_pipe_RPAR",
      map_parenthesized_expression env x
    )
  | `Pat__file_switch_file (v1, v2) -> R.Case ("Pat__file_switch_file",
      let v1 = map_pat__file env v1 in
      let v2 = map_switch_filename env v2 in
      R.Tuple [v1; v2]
    )
  )

and map_switch_filename (env : env) (x : CST.switch_filename) =
  (match x with
  | `Cmd_tok tok -> R.Case ("Cmd_tok",
      (* command_token *) token env tok
    )
  | `Prim_exp x -> R.Case ("Prim_exp",
      map_primary_expression env x
    )
  )

and map_unary_expression (env : env) (x : CST.unary_expression) =
  (match x with
  | `Prim_exp x -> R.Case ("Prim_exp",
      map_primary_expression env x
    )
  | `Exp_with_un_op x -> R.Case ("Exp_with_un_op",
      map_expression_with_unary_operator env x
    )
  )

and map_value (env : env) (x : CST.value) =
  (match x with
  | `Paren_exp x -> R.Case ("Paren_exp",
      map_parenthesized_expression env x
    )
  | `Sub_exp x -> R.Case ("Sub_exp",
      map_sub_expression env x
    )
  | `Array_exp x -> R.Case ("Array_exp",
      map_array_expression env x
    )
  | `Script_blk_exp x -> R.Case ("Script_blk_exp",
      map_script_block_expression env x
    )
  | `Hash_lit_exp x -> R.Case ("Hash_lit_exp",
      map_hash_literal_expression env x
    )
  | `Lit x -> R.Case ("Lit",
      map_literal env x
    )
  | `Type_lit x -> R.Case ("Type_lit",
      map_attribute_type_value env x
    )
  | `Var x -> R.Case ("Var",
      map_variable env x
    )
  )

and map_while_condition (env : env) (x : CST.while_condition) =
  map_pipeline env x

let map_using_statement (env : env) ((v1, v2) : CST.using_statement) =
  let v1 = map_pat_using env v1 in
  let v2 =
    (match v2 with
    | `Pat_name_choice_type_name (v1, v2) -> R.Case ("Pat_name_choice_type_name",
        let v1 = map_pat_name env v1 in
        let v2 =
          (match v2 with
          | `Type_name x -> R.Case ("Type_name",
              map_type_name env x
            )
          | `Str_lit x -> R.Case ("Str_lit",
              map_quoted_command_argument env x
            )
          )
        in
        R.Tuple [v1; v2]
      )
    | `Pat_module_choice_str_lit (v1, v2) -> R.Case ("Pat_module_choice_str_lit",
        let v1 = map_pat_module env v1 in
        let v2 =
          (match v2 with
          | `Str_lit x -> R.Case ("Str_lit",
              map_quoted_command_argument env x
            )
          | `Hash_lit_exp x -> R.Case ("Hash_lit_exp",
              map_hash_literal_expression env x
            )
          | `Cmd_word x -> R.Case ("Cmd_word",
              map_command_word env x
            )
          )
        in
        R.Tuple [v1; v2]
      )
    | `Pat_asse_choice_str_lit (v1, v2) -> R.Case ("Pat_asse_choice_str_lit",
        let v1 = map_pat_asse env v1 in
        let v2 =
          (match v2 with
          | `Str_lit x -> R.Case ("Str_lit",
              map_quoted_command_argument env x
            )
          | `Cmd_word x -> R.Case ("Cmd_word",
              map_command_word env x
            )
          )
        in
        R.Tuple [v1; v2]
      )
    )
  in
  R.Tuple [v1; v2]

let map_program (env : env) ((v1, v2, v3) : CST.program) =
  let v1 =
    R.List (List.map (fun (v1, v2, v3) ->
      let v1 = map_using_statement env v1 in
      let v2 = (* statement_terminator *) token env v2 in
      let v3 =
        (match v3 with
        | Some tok -> R.Option (Some (
            (* using_separator *) token env tok
          ))
        | None -> R.Option None)
      in
      R.Tuple [v1; v2; v3]
    ) v1)
  in
  let v2 =
    (match v2 with
    | Some x -> R.Option (Some (
        map_param_block env x
      ))
    | None -> R.Option None)
  in
  let v3 =
    (match v3 with
    | Some x -> R.Option (Some (
        (match x with
        | `Stmt_list x -> R.Case ("Stmt_list",
            map_statement_list env x
          )
        | `Named_blk_list x -> R.Case ("Named_blk_list",
            map_named_block_list env x
          )
        )
      ))
    | None -> R.Option None)
  in
  R.Tuple [v1; v2; v3]

let map_spaces_before_comma (env : env) (tok : CST.spaces_before_comma) =
  (* spaces_before_comma *) token env tok

let map_comment (env : env) (tok : CST.comment) =
  (* comment *) token env tok

let dump_tree root =
  map_program () root
  |> Tree_sitter_run.Raw_tree.to_channel stdout

let map_extra (env : env) (x : CST.extra) =
  match x with
  | `Comment (_loc, x) -> ("comment", "comment", map_comment env x)
  | `Spaces_before_comma (_loc, x) -> ("spaces_before_comma", "spaces_before_comma", map_spaces_before_comma env x)

let dump_extras (extras : CST.extras) =
  List.iter (fun extra ->
    let ts_rule_name, ocaml_type_name, raw_tree = map_extra () extra in
    let details =
      if ocaml_type_name <> ts_rule_name then
        Printf.sprintf " (OCaml type '%s')" ocaml_type_name
      else
        ""
    in
    Printf.printf "%s%s:\n" ts_rule_name details;
    Tree_sitter_run.Raw_tree.to_channel stdout raw_tree
  ) extras
