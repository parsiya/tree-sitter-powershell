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

let map_pat_using (env : env) (tok : CST.pat_using) =
  (* pattern [uU][sS][iI][nN][gG] *) token env tok

let map_pat_base (env : env) (tok : CST.pat_base) =
  (* pattern [bB][aA][sS][eE] *) token env tok

let map_bang_command_name (env : env) (tok : CST.bang_command_name) =
  (* bang_command_name *) token env tok

let map_decimal_integer_literal (env : env) (tok : CST.decimal_integer_literal) =
  (* decimal_integer_literal *) token env tok

let map_imm_tok_pat_421479c_pat_421479c (env : env) (tok : CST.imm_tok_pat_421479c_pat_421479c) =
  (* imm_tok_pat_421479c_pat_421479c *) token env tok

let map_verbatim_here_string_characters (env : env) (tok : CST.verbatim_here_string_characters) =
  (* verbatim_here_string_characters *) token env tok

let map_label (env : env) (tok : CST.label) =
  (* label *) token env tok

let map_verbatim_string_characters (env : env) (tok : CST.verbatim_string_characters) =
  (* verbatim_string_characters *) token env tok

let map_pat_c37ec16 (env : env) (tok : CST.pat_c37ec16) =
  (* pattern [-\u2013-\u2015][iI][nN][eE] *) token env tok

let map_pat_fb1d2b1 (env : env) (tok : CST.pat_fb1d2b1) =
  (* pattern [-\u2013-\u2015][cC][iI][nN] *) token env tok

let map_keyword_single_quote_command_name (env : env) (tok : CST.keyword_single_quote_command_name) =
  (* keyword_single_quote_command_name *) token env tok

let map_pat_catch (env : env) (tok : CST.pat_catch) =
  (* pattern [cC][aA][tT][cC][hH] *) token env tok

let map_keyword_empty_quote_command_name (env : env) (tok : CST.keyword_empty_quote_command_name) =
  (* keyword_empty_quote_command_name *) token env tok

let map_tok_pat_77937c4 (env : env) (tok : CST.tok_pat_77937c4) =
  (* tok_pat_77937c4 *) token env tok

let map_pat_48c4f3f (env : env) (tok : CST.pat_48c4f3f) =
  (* pattern [-\u2013-\u2015][sS][hH][rR] *) token env tok

let map_pat_fina (env : env) (tok : CST.pat_fina) =
  (* pattern [fF][iI][nN][aA][lL][lL][yY] *) token env tok

let map_pat_asse (env : env) (tok : CST.pat_asse) =
  (* pattern [aA][sS][sS][eE][mM][bB][lL][yY] *) token env tok

let map_tok_prec_p1_pat_244ee43 (env : env) (tok : CST.tok_prec_p1_pat_244ee43) =
  (* tok_prec_p1_pat_244ee43 *) token env tok

let map_pat_0a8cd29 (env : env) (tok : CST.pat_0a8cd29) =
  (* pattern [-\u2013-\u2015][bB][aA][nN][dD] *) token env tok

let map_pat_43e36ae (env : env) (tok : CST.pat_43e36ae) =
  (* pattern "[-\\u2013-\\u2015](?:(?:[aAdDeEfFgGhHkKlLmMoOpPqQrRtTuUvVwWxXyYzZ][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[nN](?:[aAbBcCdDeEfFgGhHiIjJkKlLmMnNpPqQrRsStTuUvVwWxXyYzZ][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[oO](?:[aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsSuUvVwWxXyYzZ][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[tT][A-Za-z][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[^A-Za-z\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*\
  )?|[^A-Za-z\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*\
  )?|[bB](?:[aAbBcCdDeEfFgGhHiIjJkKlLmMoOpPqQrRsStTuUvVwWxXyYzZ][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[nN](?:[aAbBcCdDeEfFgGhHiIjJkKlLmMnNpPqQrRsStTuUvVwWxXyYzZ][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[oO](?:[aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsSuUvVwWxXyYzZ][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[tT][A-Za-z][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[^A-Za-z\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*\
  )?|[^A-Za-z\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*\
  )?|[^A-Za-z\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*\
  )?|[sS](?:[aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOqQrRsStTuUvVwWxXyYzZ][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[pP](?:[aAbBcCdDeEfFgGhHiIjJkKmMnNoOpPqQrRsStTuUvVwWxXyYzZ][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[lL](?:[aAbBcCdDeEfFgGhHjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[iI](?:[aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsSuUvVwWxXyYzZ][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[tT][A-Za-z][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[^A-Za-z\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*\
  )?|[^A-Za-z\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*\
  )?|[^A-Za-z\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*\
  )?|[^A-Za-z\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*\
  )?|[cC](?:[aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRtTuUvVwWxXyYzZ][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[sS](?:[aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOqQrRsStTuUvVwWxXyYzZ][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[pP](?:[aAbBcCdDeEfFgGhHiIjJkKmMnNoOpPqQrRsStTuUvVwWxXyYzZ][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[lL](?:[aAbBcCdDeEfFgGhHjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[iI](?:[aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsSuUvVwWxXyYzZ][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[tT][A-Za-z][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[^A-Za-z\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*\
  )?|[^A-Za-z\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*\
  )?|[^A-Za-z\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*\
  )?|[^A-Za-z\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*\
  )?|[^A-Za-z\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*\
  )?|[iI](?:[aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRtTuUvVwWxXyYzZ][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[sS](?:[aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOqQrRsStTuUvVwWxXyYzZ][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[pP](?:[aAbBcCdDeEfFgGhHiIjJkKmMnNoOpPqQrRsStTuUvVwWxXyYzZ][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[lL](?:[aAbBcCdDeEfFgGhHjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[iI](?:[aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsSuUvVwWxXyYzZ][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[tT][A-Za-z][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[^A-Za-z\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*\
  )?|[^A-Za-z\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*\
  )?|[^A-Za-z\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*\
  )?|[^A-Za-z\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*\
  )?|[^A-Za-z\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*\
  )?|[jJ](?:[aAbBcCdDeEfFgGhHiIjJkKlLmMnNpPqQrRsStTuUvVwWxXyYzZ][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[oO](?:[aAbBcCdDeEfFgGhHjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[iI](?:[aAbBcCdDeEfFgGhHiIjJkKlLmMoOpPqQrRsStTuUvVwWxXyYzZ][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[nN][A-Za-z][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*|[^A-Za-z\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*\
  )?|[^A-Za-z\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*\
  )?|[^A-Za-z\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000][^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*\
  )?)|([^\\P{L}\\x00-\\x7F\\u{10000}-\\u{10FFFF}]|[\\u1C89-\\u1C8A\\u3400-\\u4DBF\\u4E00-\\u9FFF\\uA7CB-\\uA7CD\\uA7DA-\\uA7DC\\uAC00-\\uD7A3])[^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*\
  )" *) token env tok

let map_pat_exit (env : env) (tok : CST.pat_exit) =
  (* pattern [eE][xX][iI][tT] *) token env tok

let map_pat_734c26b (env : env) (tok : CST.pat_734c26b) =
  (* pattern [-\u2013-\u2015][mM][aA][tT][cC][hH] *) token env tok

let map_pat_54780c6 (env : env) (tok : CST.pat_54780c6) =
  (* pattern [-\u2013-\u2015][oO][rR] *) token env tok

let map_pat_do (env : env) (tok : CST.pat_do) =
  (* pattern [dD][oO] *) token env tok

let map_pat_66302c1 (env : env) (tok : CST.pat_66302c1) =
  (* pattern [-\u2013-\u2015][cC][nN][oO][tT][lL][iI][kK][eE] *) token env tok

let map_pat_dc8ff84 (env : env) (tok : CST.pat_dc8ff84) =
  (* pattern [-\u2013-\u2015][iI][rR][eE][pP][lL][aA][cC][eE] *) token env tok

let map_pat_throw (env : env) (tok : CST.pat_throw) =
  (* pattern [tT][hH][rR][oO][wW] *) token env tok

let map_qualified_variable (env : env) (tok : CST.qualified_variable) =
  (* qualified_variable *) token env tok

let map_pat_d631060 (env : env) (tok : CST.pat_d631060) =
  (* pattern [-\u2013-\u2015][pP](?:[aA](?:[rR](?:[aA](?:[lL](?:[lL](?:[eE](?:[lL])?)?)?)?)?)?)? *) token env tok

let map_pat_0cd92c2 (env : env) (tok : CST.pat_0cd92c2) =
  (* pattern "[^'\\u2018-\\u201B]+" *) token env tok

let map_pat_4390b74 (env : env) (tok : CST.pat_4390b74) =
  (* pattern [-\u2013-\u2015][pP][aA][rR][aA][lL][lL][eE][lL] *) token env tok

let map_adjacent_paren_boundary (env : env) (tok : CST.adjacent_paren_boundary) =
  (* adjacent_paren_boundary *) token env tok

let map_imm_tok_pat_3d58547 (env : env) (tok : CST.imm_tok_pat_3d58547) =
  (* pattern "['\\u2018-\\u201B]" *) token env tok

let map_path_command_name_continuation (env : env) (tok : CST.path_command_name_continuation) =
  (* path_command_name_continuation *) token env tok

let map_pat_625cb41 (env : env) (tok : CST.pat_625cb41) =
  (* pattern [-\u2013-\u2015][nN][oO][tT][iI][nN] *) token env tok

let map_angle_command_name (env : env) (x : CST.angle_command_name) =
  (match x with
  | `LT tok -> R.Case ("LT",
      (* "<" *) token env tok
    )
  | `GT tok -> R.Case ("GT",
      (* ">" *) token env tok
    )
  | `GTGT tok -> R.Case ("GTGT",
      (* ">>" *) token env tok
    )
  )

let map_command_token (env : env) (tok : CST.command_token) =
  (* command_token *) token env tok

let map_pat_3039380 (env : env) (tok : CST.pat_3039380) =
  (* pattern [-\u2013-\u2015][iI][sS][pP][lL][iI][tT] *) token env tok

let map_pat_proc (env : env) (tok : CST.pat_proc) =
  (* pattern [pP][rR][oO][cC][eE][sS][sS] *) token env tok

let map_pat_else (env : env) (tok : CST.pat_else) =
  (* pattern [eE][lL][sS][eE] *) token env tok

let map_pat_0aea6ea (env : env) (tok : CST.pat_0aea6ea) =
  (* pattern [-\u2013-\u2015][wW](?:[iI](?:[lL](?:[dD](?:[cC](?:[aA](?:[rR](?:[dD])?)?)?)?)?)?)? *) token env tok

let map_pat_b026f1a (env : env) (tok : CST.pat_b026f1a) =
  (* pattern "[^\\$\"\\u201C-\\u201E`]+" *) token env tok

let map_pat_try (env : env) (tok : CST.pat_try) =
  (* pattern [tT][rR][yY] *) token env tok

let map_imm_tok_pat_d2fe81f (env : env) (tok : CST.imm_tok_pat_d2fe81f) =
  (* pattern `[^\r\n]|`\r|`\n *) token env tok

let map_keyword_dollar_command_name (env : env) (tok : CST.keyword_dollar_command_name) =
  (* keyword_dollar_command_name *) token env tok

let map_colon_word_continuation (env : env) (tok : CST.colon_word_continuation) =
  (* colon_word_continuation *) token env tok

let map_leading_bom (env : env) (tok : CST.leading_bom) =
  (* leading_bom *) token env tok

let map_pat_if (env : env) (tok : CST.pat_if) =
  (* pattern [iI][fF] *) token env tok

let map_qualified_variable_in_string (env : env) (tok : CST.qualified_variable_in_string) =
  (* qualified_variable_in_string *) token env tok

let map_pat_399c5a5 (env : env) (tok : CST.pat_399c5a5) =
  (* pattern [-\u2013-\u2015][cC][mM][aA][tT][cC][hH] *) token env tok

let map_foreach_prefixed_member_name (env : env) (tok : CST.foreach_prefixed_member_name) =
  (* foreach_prefixed_member_name *) token env tok

let map_tok_prec_p1_pat_ecd07ae (env : env) (tok : CST.tok_prec_p1_pat_ecd07ae) =
  (* tok_prec_p1_pat_ecd07ae *) token env tok

let map_pat_a930296 (env : env) (tok : CST.pat_a930296) =
  (* pattern [-\u2013-\u2015][lL][tT] *) token env tok

let map_pat_c1a5391 (env : env) (tok : CST.pat_c1a5391) =
  (* pattern [-\u2013-\u2015][cC][lL][iI][kK][eE] *) token env tok

let map_variable_before_literal_dot (env : env) (tok : CST.variable_before_literal_dot) =
  (* variable_before_literal_dot *) token env tok

let map_pat_cont (env : env) (tok : CST.pat_cont) =
  (* pattern [cC][oO][nN][tT][iI][nN][uU][eE] *) token env tok

let map_pat_edabe04 (env : env) (tok : CST.pat_edabe04) =
  (* pattern [-\u2013-\u2015][eE](?:[xX](?:[aA](?:[cC](?:[tT])?)?)?)? *) token env tok

let map_splatted_variable (env : env) (tok : CST.splatted_variable) =
  (* splatted_variable *) token env tok

let map_tok_pat_63ae94a_rep_plus_pat_63ae94a (env : env) (tok : CST.tok_pat_63ae94a_rep_plus_pat_63ae94a) =
  (* tok_pat_63ae94a_rep_plus_pat_63ae94a *) token env tok

let map_pat_1ee7012 (env : env) (tok : CST.pat_1ee7012) =
  (* pattern [-\u2013-\u2015][cC][cC][oO][nN][tT][aA][iI][nN][sS] *) token env tok

let map_pat_4648aec (env : env) (tok : CST.pat_4648aec) =
  (* pattern [-\u2013-\u2015][cC][sS][pP][lL][iI][tT] *) token env tok

let map_bare_dashes (env : env) (tok : CST.bare_dashes) =
  (* bare_dashes *) token env tok

let map_command_name_escape (env : env) (tok : CST.command_name_escape) =
  (* command_name_escape *) token env tok

let map_pat_module (env : env) (tok : CST.pat_module) =
  (* pattern [mM][oO][dD][uU][lL][eE] *) token env tok

let map_pat_975eb3a (env : env) (tok : CST.pat_975eb3a) =
  (* pattern [-\u2013-\u2015][aA][sS] *) token env tok

let map_pat_name (env : env) (tok : CST.pat_name) =
  (* pattern [nN][aA][mM][eE][sS][pP][aA][cC][eE] *) token env tok

let map_pat_in (env : env) (tok : CST.pat_in) =
  (* pattern [iI][nN] *) token env tok

let map_pat_d93d303 (env : env) (tok : CST.pat_d93d303) =
  (* pattern [-\u2013-\u2015][cC][nN][oO][tT][mM][aA][tT][cC][hH] *) token env tok

let map_string_subexpression_end (env : env) (tok : CST.string_subexpression_end) =
  (* string_subexpression_end *) token env tok

let map_tok_choice_pat_38c66fe (env : env) (tok : CST.tok_choice_pat_38c66fe) =
  (* tok_choice_pat_38c66fe *) token env tok

let map_parameter_dot_literal_boundary (env : env) (tok : CST.parameter_dot_literal_boundary) =
  (* parameter_dot_literal_boundary *) token env tok

let map_pat_e75a1ac (env : env) (tok : CST.pat_e75a1ac) =
  (* pattern [-\u2013-\u2015][iI][sS][nN][oO][tT] *) token env tok

let map_flow_control_colon_word (env : env) (tok : CST.flow_control_colon_word) =
  (* flow_control_colon_word *) token env tok

let map_pat_4f5d3ac (env : env) (tok : CST.pat_4f5d3ac) =
  (* pattern [-\u2013-\u2015][iI][nN][oO][tT][cC][oO][nN][tT][aA][iI][nN][sS] *) token env tok

let map_pat_c311815 (env : env) (tok : CST.pat_c311815) =
  (* pattern [-\u2013-\u2015][jJ][oO][iI][nN] *) token env tok

let map_pipeline_chain_tail (env : env) (x : CST.pipeline_chain_tail) =
  (match x with
  | `AMPAMP tok -> R.Case ("AMPAMP",
      (* "&&" *) token env tok
    )
  | `BARBAR tok -> R.Case ("BARBAR",
      (* "||" *) token env tok
    )
  )

let map_pat_6794e37 (env : env) (tok : CST.pat_6794e37) =
  (* pattern "\\.([^\\{\\}\\(\\);,\\|\\&`\"'\\u2018-\\u201E\\t-\\r \\u0085\\u00a0\\u1680\\u2000-\\u200a\\u2028\\u2029\\u202f\\u205f\\u3000\\[\\]\\+\\-\\*\\/\\$@<\\!0-9][^\\{\\}\\(\\);,\\|\\&`\"'\\u2018-\\u201E\\t-\\r \\u0085\\u00a0\\u1680\\u2000-\\u200a\\u2028\\u2029\\u202f\\u205f\\u3000\\[\\]\\+\\-\\*\\/\\$@<\\!]*\
  )?" *) token env tok

let map_pat_4485489 (env : env) (tok : CST.pat_4485489) =
  (* pattern "[^\\{\\}\\(\\);,\\|\\&`\"'\\u2018-\\u201E\\t-\\r \\u0085\\u00a0\\u1680\\u2000-\\u200a\\u2028\\u2029\\u202f\\u205f\\u3000\\[\\]\\+\\-\\*\\/\\$@<\\!\\u2013-\\u20150-9.>][^\\{\\}\\(\\);,\\|\\&`\"'\\u2018-\\u201E\\t-\\r \\u0085\\u00a0\\u1680\\u2000-\\u200a\\u2028\\u2029\\u202f\\u205f\\u3000\\[\\]\\+\\-\\*\\/\\$@<\\!]*" *) token env tok

let map_pat_481abbe (env : env) (tok : CST.pat_481abbe) =
  (* pattern [-\u2013-\u2015][cC][oO][nN][tT][aA][iI][nN][sS] *) token env tok

let map_pat_3f5725c (env : env) (tok : CST.pat_3f5725c) =
  (* pattern [-\u2013-\u2015][iI][lL][eE] *) token env tok

let map_path_command_name_token (env : env) (tok : CST.path_command_name_token) =
  (* pattern [0-9a-zA-Z_?\-\.\\\/][0-9a-zA-Z_?\-\.\\\/@]* *) token env tok

let map_pat_61eab51 (env : env) (tok : CST.pat_61eab51) =
  (* pattern [-\u2013-\u2015][iI][iI][nN] *) token env tok

let map_pat_d5a6271 (env : env) (tok : CST.pat_d5a6271) =
  (* pattern [-\u2013-\u2015][iI][nN][oO][tT][iI][nN] *) token env tok

let map_pat_ee35850 (env : env) (tok : CST.pat_ee35850) =
  (* pattern [-\u2013-\u2015][bB][nN][oO][tT] *) token env tok

let map_imm_tok_pat_e380114 (env : env) (tok : CST.imm_tok_pat_e380114) =
  (* pattern \r\n|\n|\r *) token env tok

let map_imm_tok_pat_b0e3134 (env : env) (tok : CST.imm_tok_pat_b0e3134) =
  (* pattern "\\$(`[^\"\\u201C-\\u201E]|`\\r?\\n|[\\s\\\\])" *) token env tok

let map_pat_bda16ab (env : env) (tok : CST.pat_bda16ab) =
  (* pattern \.{1,2}\/ *) token env tok

let map_pat_8a0ae06 (env : env) (tok : CST.pat_8a0ae06) =
  (* pattern `.{1}|`\r?\n *) token env tok

let map_command_name_subexpression (env : env) (tok : CST.command_name_subexpression) =
  (* command_name_subexpression *) token env tok

let map_tok_pat_e22930c (env : env) (tok : CST.tok_pat_e22930c) =
  (* tok_pat_e22930c *) token env tok

let map_pat_work (env : env) (tok : CST.pat_work) =
  (* pattern [wW][oO][rR][kK][fF][lL][oO][wW] *) token env tok

let map_quoted_argument_boundary (env : env) (tok : CST.quoted_argument_boundary) =
  (* quoted_argument_boundary *) token env tok

let map_pat_75780b9 (env : env) (tok : CST.pat_75780b9) =
  (* pattern \$`(.{1}|`\r?\n) *) token env tok

let map_tok_prec_p1_pat_hidden (env : env) (tok : CST.tok_prec_p1_pat_hidden) =
  (* tok_prec_p1_pat_hidden *) token env tok

let map_pat_2030147 (env : env) (tok : CST.pat_2030147) =
  (* pattern [-\u2013-\u2015][tT][hH][rR][oO][tT][tT][lL][eE][lL][iI][mM][iI][tT] *) token env tok

let map_braced_variable (env : env) (tok : CST.braced_variable) =
  (* pattern \$\{[^}]+\} *) token env tok

let map_pat_end (env : env) (tok : CST.pat_end) =
  (* pattern [eE][nN][dD] *) token env tok

let map_pat_for (env : env) (tok : CST.pat_for) =
  (* pattern [fF][oO][rR] *) token env tok

let map_trailing_dot_type_name (env : env) (tok : CST.trailing_dot_type_name) =
  (* trailing_dot_type_name *) token env tok

let map_variable_command_name_continuation (env : env) (tok : CST.variable_command_name_continuation) =
  (* variable_command_name_continuation *) token env tok

let map_pat_4e06ed5 (env : env) (tok : CST.pat_4e06ed5) =
  (* pattern [-\u2013-\u2015][lL][iI][kK][eE] *) token env tok

let map_function_context_end (env : env) (tok : CST.function_context_end) =
  (* function_context_end *) token env tok

let map_tok_prec_p1_pat_enum (env : env) (tok : CST.tok_prec_p1_pat_enum) =
  (* tok_prec_p1_pat_enum *) token env tok

let map_pat_0977ede (env : env) (tok : CST.pat_0977ede) =
  (* pattern [-\u2013-\u2015][cC](?:[aA](?:[sS](?:[eE](?:[sS](?:[eE](?:[nN](?:[sS](?:[iI](?:[tT](?:[iI](?:[vV](?:[eE])?)?)?)?)?)?)?)?)?)?)?)? *) token env tok

let map_pat_begin (env : env) (tok : CST.pat_begin) =
  (* pattern [bB][eE][gG][iI][nN] *) token env tok

let map_pat_6848da0 (env : env) (tok : CST.pat_6848da0) =
  (* pattern [-\u2013-\u2015][cC][nN][oO][tT][iI][nN] *) token env tok

let map_hexadecimal_integer_literal (env : env) (tok : CST.hexadecimal_integer_literal) =
  (* hexadecimal_integer_literal *) token env tok

let map_statement_terminator (env : env) (tok : CST.statement_terminator) =
  (* statement_terminator *) token env tok

let map_command_name_start_escape (env : env) (tok : CST.command_name_start_escape) =
  (* command_name_start_escape *) token env tok

let map_unicode_minus (env : env) (tok : CST.unicode_minus) =
  (* pattern [\u2013-\u2015] *) token env tok

let map_imm_tok_prec_p2_pat_8992db4 (env : env) (tok : CST.imm_tok_prec_p2_pat_8992db4) =
  (* pattern "[\"\\u201C-\\u201E]@" *) token env tok

let map_pat_01d6398 (env : env) (tok : CST.pat_01d6398) =
  (* pattern [-\u2013-\u2015][xX][oO][rR] *) token env tok

let map_pat_a78b04d (env : env) (tok : CST.pat_a78b04d) =
  (* pattern [-\u2013-\u2015][gG][eE] *) token env tok

let map_tok_prec_p1_pat_7de4c60 (env : env) (tok : CST.tok_prec_p1_pat_7de4c60) =
  (* tok_prec_p1_pat_7de4c60 *) token env tok

let map_pat_seq (env : env) (tok : CST.pat_seq) =
  (* pattern [sS][eE][qQ][uU][eE][nN][cC][eE] *) token env tok

let map_imm_tok_prec_p1_pat_b45f689 (env : env) (tok : CST.imm_tok_prec_p1_pat_b45f689) =
  (* pattern [^\$\r\n`]+ *) token env tok

let map_pat_func (env : env) (tok : CST.pat_func) =
  (* pattern [fF][uU][nN][cC][tT][iI][oO][nN] *) token env tok

let map_pat_3d58547 (env : env) (tok : CST.pat_3d58547) =
  (* pattern "['\\u2018-\\u201B]" *) token env tok

let map_script_block_argument_start (env : env) (tok : CST.script_block_argument_start) =
  (* script_block_argument_start *) token env tok

let map_pat_5973a47 (env : env) (tok : CST.pat_5973a47) =
  (* pattern [-\u2013-\u2015][lL][eE] *) token env tok

let map_command_word_start (env : env) (tok : CST.command_word_start) =
  (* command_word_start *) token env tok

let map_pat_e459adc (env : env) (tok : CST.pat_e459adc) =
  (* pattern [-\u2013-\u2015][iI][cC][oO][nN][tT][aA][iI][nN][sS] *) token env tok

let map_imm_tok_pat_f92c05a (env : env) (tok : CST.imm_tok_pat_f92c05a) =
  (* pattern \$(`.{1}|`\r?\n|[\s\\]) *) token env tok

let map_pat_a49b289 (env : env) (tok : CST.pat_a49b289) =
  (* pattern [-\u2013-\u2015][nN][oO][tT][mM][aA][tT][cC][hH] *) token env tok

let map_pat_1ef8891 (env : env) (tok : CST.pat_1ef8891) =
  (* pattern [-\u2013-\u2015][iI][gG][eE] *) token env tok

let map_pat_ad90d9b (env : env) (tok : CST.pat_ad90d9b) =
  (* pattern [-\u2013-\u2015][rR][eE][pP][lL][aA][cC][eE] *) token env tok

let map_using_separator (env : env) (tok : CST.using_separator) =
  (* using_separator *) token env tok

let map_pat_241719d (env : env) (tok : CST.pat_241719d) =
  (* pattern [-\u2013-\u2015][bB][oO][rR] *) token env tok

let map_pat_71f01fd (env : env) (tok : CST.pat_71f01fd) =
  (* pattern &[^&]* *) token env tok

let map_pat_2dff261 (env : env) (tok : CST.pat_2dff261) =
  (* pattern [-\u2013-\u2015][cC][rR][eE][pP][lL][aA][cC][eE] *) token env tok

let map_dollar_variable (env : env) (tok : CST.dollar_variable) =
  (* dollar_variable *) token env tok

let map_pat_d94f457 (env : env) (tok : CST.pat_d94f457) =
  (* pattern [-\u2013-\u2015][iI][lL][tT] *) token env tok

let map_quote_unit_open (env : env) (tok : CST.quote_unit_open) =
  (* quote_unit_open *) token env tok

let map_command_invokation_operator (env : env) (x : CST.command_invokation_operator) =
  (match x with
  | `DOT tok -> R.Case ("DOT",
      (* "." *) token env tok
    )
  | `AMP tok -> R.Case ("AMP",
      (* "&" *) token env tok
    )
  )

let map_foreach_member_name (env : env) (tok : CST.foreach_member_name) =
  (* pattern [fF][oO][rR][eE][aA][cC][hH] *) token env tok

let map_pat_brk (env : env) (tok : CST.pat_brk) =
  (* pattern [bB][rR][eE][aA][kK] *) token env tok

let map_tok_prec_p2_pat_f0eaee1 (env : env) (tok : CST.tok_prec_p2_pat_f0eaee1) =
  (* tok_prec_p2_pat_f0eaee1 *) token env tok

let map_pat_dyna (env : env) (tok : CST.pat_dyna) =
  (* pattern [dD][yY][nN][aA][mM][iI][cC][pP][aA][rR][aA][mM] *) token env tok

let map_assembly_qualifier (env : env) (tok : CST.assembly_qualifier) =
  (* assembly_qualifier *) token env tok

let map_numeric_command_name (env : env) (tok : CST.numeric_command_name) =
  (* numeric_command_name *) token env tok

let map_switch_clause_token (env : env) (tok : CST.switch_clause_token) =
  (* switch_clause_token *) token env tok

let map_tok_prec_p1_pat_8877d6b (env : env) (tok : CST.tok_prec_p1_pat_8877d6b) =
  (* tok_prec_p1_pat_8877d6b *) token env tok

let map_imm_tok_pat_8877d6b (env : env) (tok : CST.imm_tok_pat_8877d6b) =
  (* pattern [\t\v\f\u0085\u00a0\u1680\u2000-\u200a\u2028\u2029\u202f\u205f\u3000]+ *) token env tok

let map_pat_32b8d8b (env : env) (tok : CST.pat_32b8d8b) =
  (* pattern [-\u2013-\u2015][aA][nN][dD] *) token env tok

let map_imm_tok_prec_p1_pat_1c6d146 (env : env) (tok : CST.imm_tok_prec_p1_pat_1c6d146) =
  (* pattern "(\\r\\n|\\n|\\r)[\"\\u201C-\\u201E]@" *) token env tok

let map_unicode_decrement (env : env) (tok : CST.unicode_decrement) =
  (* pattern [\u2013-\u2015][\u2013-\u2015-]|-[\u2013-\u2015] *) token env tok

let map_imm_tok_pat_421479c (env : env) (tok : CST.imm_tok_pat_421479c) =
  (* pattern "[\"\\u201C-\\u201E]" *) token env tok

let map_pat_f1611b9 (env : env) (tok : CST.pat_f1611b9) =
  (* pattern [-\u2013-\u2015][iI][nN][oO][tT][mM][aA][tT][cC][hH] *) token env tok

let map_tok_pat_25523b4_rep_choice_pat_ec8942d (env : env) (tok : CST.tok_pat_25523b4_rep_choice_pat_ec8942d) =
  (* tok_pat_25523b4_rep_choice_pat_ec8942d *) token env tok

let map_pat_7007e18 (env : env) (tok : CST.pat_7007e18) =
  (* pattern [-\u2013-\u2015][nN][oO][tT][lL][iI][kK][eE] *) token env tok

let map_command_name_dollar (env : env) (tok : CST.command_name_dollar) =
  (* command_name_dollar *) token env tok

let map_keyword_double_quote_command_name (env : env) (tok : CST.keyword_double_quote_command_name) =
  (* keyword_double_quote_command_name *) token env tok

let map_pat_e780273 (env : env) (tok : CST.pat_e780273) =
  (* pattern [-\u2013-\u2015][cC][gG][eE] *) token env tok

let map_pat_dacd35e (env : env) (tok : CST.pat_dacd35e) =
  (* pattern [-\u2013-\u2015][nN][eE] *) token env tok

let map_pat_dbf96c7 (env : env) (tok : CST.pat_dbf96c7) =
  (* pattern [-\u2013-\u2015][cC][eE][qQ] *) token env tok

let map_invocation_argument_boundary (env : env) (tok : CST.invocation_argument_boundary) =
  (* invocation_argument_boundary *) token env tok

let map_type_identifier (env : env) (tok : CST.type_identifier) =
  (* type_identifier *) token env tok

let map_dash_colon_argument_boundary (env : env) (tok : CST.dash_colon_argument_boundary) =
  (* dash_colon_argument_boundary *) token env tok

let map_imm_tok_pat_3d58547_pat_3d58547 (env : env) (tok : CST.imm_tok_pat_3d58547_pat_3d58547) =
  (* imm_tok_pat_3d58547_pat_3d58547 *) token env tok

let map_pat_0152635 (env : env) (tok : CST.pat_0152635) =
  (* pattern [-\u2013-\u2015][cC][lL][tT] *) token env tok

let map_imm_tok_pat_5a0db4a (env : env) (tok : CST.imm_tok_pat_5a0db4a) =
  (* pattern `[^\r\n]|`[\r\n] *) token env tok

let map_pat_207e6aa (env : env) (tok : CST.pat_207e6aa) =
  (* pattern "@[\"\\u201C-\\u201E][ \\t\\v\\f\\u0085\\u00a0\\u1680\\u2000-\\u200a\\u2028\\u2029\\u202f\\u205f\\u3000]*(\\r\\n|\\n|\\r)" *) token env tok

let map_pat_trap (env : env) (tok : CST.pat_trap) =
  (* pattern [tT][rR][aA][pP] *) token env tok

let map_trailing_dot_real_literal (env : env) (tok : CST.trailing_dot_real_literal) =
  (* trailing_dot_real_literal *) token env tok

let map_tok_pat___ (env : env) (tok : CST.tok_pat___) =
  (* tok_pat___ *) token env tok

let map_pat_32e67b3 (env : env) (tok : CST.pat_32e67b3) =
  (* pattern [-\u2013-\u2015][iI][lL][iI][kK][eE] *) token env tok

let map_inlinescript_name (env : env) (tok : CST.inlinescript_name) =
  (* inlinescript_name *) token env tok

let map_pat_ccd4326 (env : env) (tok : CST.pat_ccd4326) =
  (* pattern [-\u2013-\u2015][cC][gG][tT] *) token env tok

let map_pat_721400f (env : env) (tok : CST.pat_721400f) =
  (* pattern [-\u2013-\u2015][fF] *) token env tok

let map_imm_tok_pat_11f42bb (env : env) (tok : CST.imm_tok_pat_11f42bb) =
  (* pattern "[^\\{\\}\\(\\);,\\|\\&\\x60\"'\\u2018-\\u201E\\t-\\r \\u0085\\u00a0\\u1680\\u2000-\\u200a\\u2028\\u2029\\u202f\\u205f\\u3000\\$]+" *) token env tok

let map_pat_d72a25c (env : env) (tok : CST.pat_d72a25c) =
  (* pattern [^\|\r\n]+ *) token env tok

let map_expandable_string_ahead (env : env) (tok : CST.expandable_string_ahead) =
  (* expandable_string_ahead *) token env tok

let map_pat_5efd524 (env : env) (tok : CST.pat_5efd524) =
  (* pattern [-\u2013-\u2015][iI][nN][oO][tT][lL][iI][kK][eE] *) token env tok

let map_pat_elseif (env : env) (tok : CST.pat_elseif) =
  (* pattern [eE][lL][sS][eE][iI][fF] *) token env tok

let map_pat_data (env : env) (tok : CST.pat_data) =
  (* pattern [dD][aA][tT][aA] *) token env tok

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

let map_pat_filter (env : env) (tok : CST.pat_filter) =
  (* pattern [fF][iI][lL][tT][eE][rR] *) token env tok

let map_dimension (env : env) (xs : CST.dimension) =
  R.List (List.map (token env (* "," *)) xs)

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

let map_pat_4a7d117 (env : env) (tok : CST.pat_4a7d117) =
  (* pattern [-\u2013-\u2015][iI][eE][qQ] *) token env tok

let map_quote_unit_escape (env : env) (tok : CST.quote_unit_escape) =
  (* quote_unit_escape *) token env tok

let map_imm_tok_prec_p1_pat_4bee114 (env : env) (tok : CST.imm_tok_prec_p1_pat_4bee114) =
  (* pattern "[^\\t-\\r \\u0085\\u00a0\\u1680\\u2000-\\u200a\\u2028\\u2029\\u202f\\u205f\\u3000\"'\\u2018-\\u201E\\x60$();|&,{}]+" *) token env tok

let map_pat_ebd9644 (env : env) (tok : CST.pat_ebd9644) =
  (* pattern [-\u2013-\u2015][cC][nN][oO][tT][cC][oO][nN][tT][aA][iI][nN][sS] *) token env tok

let map_function_context_workflow (env : env) (tok : CST.function_context_workflow) =
  (* function_context_workflow *) token env tok

let map_enum_base_colon_ahead (env : env) (tok : CST.enum_base_colon_ahead) =
  (* enum_base_colon_ahead *) token env tok

let map_pat_31ad92b (env : env) (tok : CST.pat_31ad92b) =
  (* pattern [-\u2013-\u2015][bB][xX][oO][rR] *) token env tok

let map_pat_d159322 (env : env) (tok : CST.pat_d159322) =
  (* pattern [-\u2013-\u2015][fF](?:[iI](?:[lL](?:[eE])?)?)? *) token env tok

let map_pat_711b49c (env : env) (tok : CST.pat_711b49c) =
  (* pattern [-\u2013-\u2015][cC][nN][eE] *) token env tok

let map_pat_d66cbf4 (env : env) (tok : CST.pat_d66cbf4) =
  (* pattern [-\u2013-\u2015][sS][hH][lL] *) token env tok

let map_pat_fore (env : env) (tok : CST.pat_fore) =
  (* pattern [fF][oO][rR][eE][aA][cC][hH] *) token env tok

let map_pat_5a0fe87 (env : env) (tok : CST.pat_5a0fe87) =
  (* pattern [-\u2013-\u2015][sS][pP][lL][iI][tT] *) token env tok

let map_pat_5992099 (env : env) (tok : CST.pat_5992099) =
  (* pattern [-\u2013-\u2015][gG][tT] *) token env tok

let map_pat_547618a (env : env) (tok : CST.pat_547618a) =
  (* pattern [-\u2013-\u2015][sS][uU][pP][pP][oO][rR][tT][eE][dD][cC][oO][mM][mM][aA][nN][dD] *) token env tok

let map_command_word_part (env : env) (tok : CST.command_word_part) =
  (* command_word_part *) token env tok

let map_for_newline (env : env) (tok : CST.for_newline) =
  (* pattern \r\n|\r|\n *) token env tok

let map_pat_61fd33e (env : env) (tok : CST.pat_61fd33e) =
  (* pattern [-\u2013-\u2015][nN][oO][tT] *) token env tok

let map_parameter_argument_start (env : env) (tok : CST.parameter_argument_start) =
  (* parameter_argument_start *) token env tok

let map_pat_3fbe826 (env : env) (tok : CST.pat_3fbe826) =
  (* pattern [-\u2013-\u2015][iI][nN] *) token env tok

let map_simple_name (env : env) (tok : CST.simple_name) =
  (* simple_name *) token env tok

let map_tok_prec_p1_pat_class (env : env) (tok : CST.tok_prec_p1_pat_class) =
  (* tok_prec_p1_pat_class *) token env tok

let map_file_redirection_operator (env : env) (x : CST.file_redirection_operator) =
  (match x with
  | `GT tok -> R.Case ("GT",
      (* ">" *) token env tok
    )
  | `GTGT tok -> R.Case ("GTGT",
      (* ">>" *) token env tok
    )
  | `X_1GT tok -> R.Case ("X_1GT",
      (* "1>" *) token env tok
    )
  | `X_1GTGT tok -> R.Case ("X_1GTGT",
      (* "1>>" *) token env tok
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
  )

let map_pat_7c15b39 (env : env) (tok : CST.pat_7c15b39) =
  (* pattern [-\u2013-\u2015][rR](?:[eE](?:[gG](?:[eE](?:[xX])?)?)?)? *) token env tok

let map_imm_tok_dot (env : env) (tok : CST.imm_tok_dot) =
  (* "." *) token env tok

let map_parameter_argument_separator (env : env) (tok : CST.parameter_argument_separator) =
  (* parameter_argument_separator *) token env tok

let map_pat_ad1fb95 (env : env) (tok : CST.pat_ad1fb95) =
  (* pattern "--%(?:(?:[^|&\"\\r\\n]|&[^&|\\r\\n]|\"[^\"\\r\\n]*\")+(?:\"[^\"\\r\\n]*\
  )?|\"[^\"\\r\\n]*\
  )" *) token env tok

let map_semgrep_named_ellipsis (env : env) (tok : CST.semgrep_named_ellipsis) =
  (* pattern \$\.\.\.[A-Z_][A-Z_0-9]* *) token env tok

let map_imm_tok_lpar (env : env) (tok : CST.imm_tok_lpar) =
  (* "(" *) token env tok

let map_pat_0bfef4d (env : env) (tok : CST.pat_0bfef4d) =
  (* pattern "\\*[^\\{\\}\\(\\);,\\|\\&`\"'\\u2018-\\u201E\\t-\\r \\u0085\\u00a0\\u1680\\u2000-\\u200a\\u2028\\u2029\\u202f\\u205f\\u3000\\[\\]\\+\\-\\*\\/\\$@<\\!]*" *) token env tok

let map_dashdash_parameter (env : env) (tok : CST.dashdash_parameter) =
  (* dashdash_parameter *) token env tok

let map_pat_421479c (env : env) (tok : CST.pat_421479c) =
  (* pattern "[\"\\u201C-\\u201E]" *) token env tok

let map_pat_4bb388b (env : env) (tok : CST.pat_4bb388b) =
  (* pattern [-\u2013-\u2015][eE][qQ] *) token env tok

let map_pat_switch (env : env) (tok : CST.pat_switch) =
  (* pattern [sS][wW][iI][tT][cC][hH] *) token env tok

let map_pat_9fae069 (env : env) (tok : CST.pat_9fae069) =
  (* pattern [-\u2013-\u2015][cC][lL][eE] *) token env tok

let map_unicode_minus_assign (env : env) (tok : CST.unicode_minus_assign) =
  (* pattern [\u2013-\u2015]= *) token env tok

let map_else_clause_ahead (env : env) (tok : CST.else_clause_ahead) =
  (* else_clause_ahead *) token env tok

let map_pat_while (env : env) (tok : CST.pat_while) =
  (* pattern [wW][hH][iI][lL][eE] *) token env tok

let map_pat_clean (env : env) (tok : CST.pat_clean) =
  (* pattern [cC][lL][eE][aA][nN] *) token env tok

let map_pat_f693f8b (env : env) (tok : CST.pat_f693f8b) =
  (* pattern [-\u2013-\u2015][iI][gG][tT] *) token env tok

let map_imm_tok_dollar (env : env) (tok : CST.imm_tok_dollar) =
  (* "$" *) token env tok

let map_imm_tok_prec_p1_pat_b026f1a (env : env) (tok : CST.imm_tok_prec_p1_pat_b026f1a) =
  (* pattern "[^\\$\"\\u201C-\\u201E`]+" *) token env tok

let map_tok_prec_p1_pat_static (env : env) (tok : CST.tok_prec_p1_pat_static) =
  (* tok_prec_p1_pat_static *) token env tok

let map_pat_6b4bb94 (env : env) (tok : CST.pat_6b4bb94) =
  (* pattern [-\u2013-\u2015][iI][sS] *) token env tok

let map_pat_param (env : env) (tok : CST.pat_param) =
  (* pattern [pP][aA][rR][aA][mM] *) token env tok

let map_keyword_dash_command_name (env : env) (tok : CST.keyword_dash_command_name) =
  (* keyword_dash_command_name *) token env tok

let map_parameter_argument_word (env : env) (tok : CST.parameter_argument_word) =
  (* pattern "-+(?:([^\\P{L}\\u{10000}-\\u{10FFFF}]|[\\u1C89-\\u1C8A\\u3400-\\u4DBF\\u4E00-\\u9FFF\\uA7CB-\\uA7CD\\uA7DA-\\uA7DC\\uAC00-\\uD7A3])|[_?\\x60-])[^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*:?|-[0-9.][^\\t-\\r \\u0085\\u00a0\\u1680\\u2000-\\u200a\\u2028\\u2029\\u202f\\u205f\\u3000\"'\\u2018-\\u201E\\x60$(){}|;,&]*|-" *) token env tok

let map_command_word_expression (env : env) (tok : CST.command_word_expression) =
  (* command_word_expression *) token env tok

let map_string_subexpression_start (env : env) (tok : CST.string_subexpression_start) =
  (* string_subexpression_start *) token env tok

let map_quote_unit_close (env : env) (tok : CST.quote_unit_close) =
  (* quote_unit_close *) token env tok

let map_tok_prec_p2_pat_a0b6b0e (env : env) (tok : CST.tok_prec_p2_pat_a0b6b0e) =
  (* tok_prec_p2_pat_a0b6b0e *) token env tok

let map_pat_4f029d2 (env : env) (tok : CST.pat_4f029d2) =
  (* pattern "\"[^\"]*\"" *) token env tok

let map_pat_d7653bb (env : env) (tok : CST.pat_d7653bb) =
  (* pattern [-\u2013-\u2015][nN][oO][tT][cC][oO][nN][tT][aA][iI][nN][sS] *) token env tok

let map_pat_ret (env : env) (tok : CST.pat_ret) =
  (* pattern [rR][eE][tT][uU][rR][nN] *) token env tok

let map_parameter_dot_boundary (env : env) (tok : CST.parameter_dot_boundary) =
  (* parameter_dot_boundary *) token env tok

let map_completed_expression_boundary (env : env) (tok : CST.completed_expression_boundary) =
  (* completed_expression_boundary *) token env tok

let map_real_literal_token (env : env) (tok : CST.real_literal_token) =
  (* real_literal_token *) token env tok

let map_try_clause_ahead (env : env) (tok : CST.try_clause_ahead) =
  (* try_clause_ahead *) token env tok

let map_pat_para (env : env) (tok : CST.pat_para) =
  (* pattern [pP][aA][rR][aA][lL][lL][eE][lL] *) token env tok

let map_dash_colon_command_name (env : env) (tok : CST.dash_colon_command_name) =
  (* dash_colon_command_name *) token env tok

let map_pat_ac770bb (env : env) (tok : CST.pat_ac770bb) =
  (* pattern [-\u2013-\u2015][iI][mM][aA][tT][cC][hH] *) token env tok

let map_function_context_plain (env : env) (tok : CST.function_context_plain) =
  (* function_context_plain *) token env tok

let map_imm_tok_pat_8a0ae06 (env : env) (tok : CST.imm_tok_pat_8a0ae06) =
  (* pattern `.{1}|`\r?\n *) token env tok

let map_pat_until (env : env) (tok : CST.pat_until) =
  (* pattern [uU][nN][tT][iI][lL] *) token env tok

let map_command_array_item_start (env : env) (tok : CST.command_array_item_start) =
  (* command_array_item_start *) token env tok

let map_completed_member_boundary (env : env) (tok : CST.completed_member_boundary) =
  (* completed_member_boundary *) token env tok

let map_imm_tok_pat_d8b1f43 (env : env) (tok : CST.imm_tok_pat_d8b1f43) =
  (* pattern "`[^\"\\u201C-\\u201E]|`\\r?\\n" *) token env tok

let map_angle_argument_boundary (env : env) (tok : CST.angle_argument_boundary) =
  (* angle_argument_boundary *) token env tok

let map_command_argument_sep (env : env) (x : CST.command_argument_sep) =
  map_tok_prec_p1_pat_244ee43 env x

let map_dash_command_name (env : env) (x : CST.dash_command_name) =
  map_pat_43e36ae env x

let map_isplit_operator (env : env) (x : CST.isplit_operator) =
  map_pat_3039380 env x

let map_csplit_operator (env : env) (x : CST.csplit_operator) =
  map_pat_4648aec env x

let map_join_operator (env : env) (x : CST.join_operator) =
  map_pat_c311815 env x

let map_bnot_operator (env : env) (x : CST.bnot_operator) =
  map_pat_ee35850 env x

let map_single_command_parameter (env : env) (x : CST.single_command_parameter) =
  (match x with
  | `Tok_pat_e22930c x -> R.Case ("Tok_pat_e22930c",
      map_tok_pat_e22930c env x
    )
  | `Tok_prec_p1_pat_ecd07ae x -> R.Case ("Tok_prec_p1_pat_ecd07ae",
      map_tok_prec_p1_pat_ecd07ae env x
    )
  )

let map_workflow_keyword (env : env) (x : CST.workflow_keyword) =
  map_pat_work env x

let map_integer_literal (env : env) (x : CST.integer_literal) =
  (match x with
  | `Deci_int_lit tok -> R.Case ("Deci_int_lit",
      (* decimal_integer_literal *) token env tok
    )
  | `Hexa_int_lit tok -> R.Case ("Hexa_int_lit",
      (* hexadecimal_integer_literal *) token env tok
    )
  )

let map_anon_choice_DASH_75a790b (env : env) (x : CST.anon_choice_DASH_75a790b) =
  (match x with
  | `DASH tok -> R.Case ("DASH",
      (* "-" *) token env tok
    )
  | `Unic_minus tok -> R.Case ("Unic_minus",
      (* pattern [\u2013-\u2015] *) token env tok
    )
  )

let map_function_keyword (env : env) (x : CST.function_keyword) =
  map_pat_func env x

let map_string_literal_immediate (env : env) ((v1, v2) : CST.string_literal_immediate) =
  let v1 = map_pat_0cd92c2 env v1 in
  let v2 = map_pat_3d58547 env v2 in
  R.Tuple [v1; v2]

let map_anon_choice_pat_brk_17ec5e1 (env : env) (x : CST.anon_choice_pat_brk_17ec5e1) =
  (match x with
  | `Pat_brk x -> R.Case ("Pat_brk",
      map_pat_brk env x
    )
  | `Pat_cont x -> R.Case ("Pat_cont",
      map_pat_cont env x
    )
  )

let map_anon_choice_pat_32b8d8b_b35500c (env : env) (x : CST.anon_choice_pat_32b8d8b_b35500c) =
  (match x with
  | `Pat_32b8d8b x -> R.Case ("Pat_32b8d8b",
      map_pat_32b8d8b env x
    )
  | `Pat_54780c6 x -> R.Case ("Pat_54780c6",
      map_pat_54780c6 env x
    )
  | `Pat_01d6398 x -> R.Case ("Pat_01d6398",
      map_pat_01d6398 env x
    )
  )

let map_anon_choice_DASHDASH_a0c9c93 (env : env) (x : CST.anon_choice_DASHDASH_a0c9c93) =
  (match x with
  | `DASHDASH tok -> R.Case ("DASHDASH",
      (* "--" *) token env tok
    )
  | `Unic_decr tok -> R.Case ("Unic_decr",
      (* pattern [\u2013-\u2015][\u2013-\u2015-]|-[\u2013-\u2015] *) token env tok
    )
  )

let rec map_type_name (env : env) (x : CST.type_name) =
  (match x with
  | `Type_id tok -> R.Case ("Type_id",
      (* type_identifier *) token env tok
    )
  | `Type_name_DOT_tok_pat_63ae94a_rep_plus_pat_63ae94a (v1, v2, v3) -> R.Case ("Type_name_DOT_tok_pat_63ae94a_rep_plus_pat_63ae94a",
      let v1 = map_type_name env v1 in
      let v2 = (* "." *) token env v2 in
      let v3 = map_tok_pat_63ae94a_rep_plus_pat_63ae94a env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

let map_anon_choice_LBRACK_c253fc2 (env : env) (x : CST.anon_choice_LBRACK_c253fc2) =
  (match x with
  | `LBRACK tok -> R.Case ("LBRACK",
      (* "[" *) token env tok
    )
  | `Null_cond_elem_op tok -> R.Case ("Null_cond_elem_op",
      (* "?[" *) token env tok
    )
  )

let map_format_operator (env : env) (x : CST.format_operator) =
  map_pat_721400f env x

let map_filter_keyword (env : env) (x : CST.filter_keyword) =
  map_pat_filter env x

let map_colon_word_text (env : env) (x : CST.colon_word_text) =
  (match x with
  | `Imm_tok_prec_p1_pat_4bee114 x -> R.Case ("Imm_tok_prec_p1_pat_4bee114",
      map_imm_tok_prec_p1_pat_4bee114 env x
    )
  | `Imm_tok_pat_5a0db4a x -> R.Case ("Imm_tok_pat_5a0db4a",
      map_imm_tok_pat_5a0db4a env x
    )
  )

let map_anon_choice_pat_0a8cd29_7c5cd31 (env : env) (x : CST.anon_choice_pat_0a8cd29_7c5cd31) =
  (match x with
  | `Pat_0a8cd29 x -> R.Case ("Pat_0a8cd29",
      map_pat_0a8cd29 env x
    )
  | `Pat_241719d x -> R.Case ("Pat_241719d",
      map_pat_241719d env x
    )
  | `Pat_31ad92b x -> R.Case ("Pat_31ad92b",
      map_pat_31ad92b env x
    )
  )

let map_split_operator (env : env) (x : CST.split_operator) =
  map_pat_5a0fe87 env x

let map_anon_choice_SEMI_ef77367 (env : env) (x : CST.anon_choice_SEMI_ef77367) =
  (match x with
  | `SEMI tok -> R.Case ("SEMI",
      (* ";" *) token env tok
    )
  | `For_nl tok -> R.Case ("For_nl",
      (* pattern \r\n|\r|\n *) token env tok
    )
  )

let map_not_operator (env : env) (x : CST.not_operator) =
  map_pat_61fd33e env x

let map_switch_parameter (env : env) (x : CST.switch_parameter) =
  (match x with
  | `Pat_7c15b39 x -> R.Case ("Pat_7c15b39",
      map_pat_7c15b39 env x
    )
  | `Pat_0aea6ea x -> R.Case ("Pat_0aea6ea",
      map_pat_0aea6ea env x
    )
  | `Pat_edabe04 x -> R.Case ("Pat_edabe04",
      map_pat_edabe04 env x
    )
  | `Pat_0977ede x -> R.Case ("Pat_0977ede",
      map_pat_0977ede env x
    )
  | `Pat_d631060 x -> R.Case ("Pat_d631060",
      map_pat_d631060 env x
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

let map_stop_parsing (env : env) (x : CST.stop_parsing) =
  (match x with
  | `DASHDASHPERC tok -> R.Case ("DASHDASHPERC",
      (* "--%" *) token env tok
    )
  | `Pat_ad1fb95 x -> R.Case ("Pat_ad1fb95",
      map_pat_ad1fb95 env x
    )
  )

let map_variable (env : env) (x : CST.variable) =
  (match x with
  | `Semg_named_ellips tok -> R.Case ("Semg_named_ellips",
      (* pattern \$\.\.\.[A-Z_][A-Z_0-9]* *) token env tok
    )
  | `Choice_qual_var x -> R.Case ("Choice_qual_var",
      (match x with
      | `Qual_var tok -> R.Case ("Qual_var",
          (* qualified_variable *) token env tok
        )
      | `DOLLARDOLLAR tok -> R.Case ("DOLLARDOLLAR",
          (* "$$" *) token env tok
        )
      | `ATDOLLAR tok -> R.Case ("ATDOLLAR",
          (* "@$" *) token env tok
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
      | `Dollar_var tok -> R.Case ("Dollar_var",
          (* dollar_variable *) token env tok
        )
      | `Spla_var tok -> R.Case ("Spla_var",
          (* splatted_variable *) token env tok
        )
      | `Braced_var tok -> R.Case ("Braced_var",
          (* pattern \$\{[^}]+\} *) token env tok
        )
      )
    )
  )

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
  | `Choice_DASHEQ x -> R.Case ("Choice_DASHEQ",
      (match x with
      | `DASHEQ tok -> R.Case ("DASHEQ",
          (* "-=" *) token env tok
        )
      | `Unic_minus_assign tok -> R.Case ("Unic_minus_assign",
          (* pattern [\u2013-\u2015]= *) token env tok
        )
      )
    )
  | `QMARKQMARKEQ tok -> R.Case ("QMARKQMARKEQ",
      (* "??=" *) token env tok
    )
  )

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
  | `Pat_clean x -> R.Case ("Pat_clean",
      map_pat_clean env x
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

let map_real_literal (env : env) (x : CST.real_literal) =
  (match x with
  | `Trai_dot_real_lit tok -> R.Case ("Trai_dot_real_lit",
      (* trailing_dot_real_literal *) token env tok
    )
  | `Real_lit_tok tok -> R.Case ("Real_lit_tok",
      (* real_literal_token *) token env tok
    )
  )

let map_command_parameter (env : env) (x : CST.command_parameter) =
  (match x with
  | `Single_cmd_param x -> R.Case ("Single_cmd_param",
      map_single_command_parameter env x
    )
  | `Dash_param tok -> R.Case ("Dash_param",
      (* dashdash_parameter *) token env tok
    )
  | `Tok_pat___ x -> R.Case ("Tok_pat___",
      map_tok_pat___ env x
    )
  | `Tok_pat_25523b4_rep_choice_pat_ec8942d x -> R.Case ("Tok_pat_25523b4_rep_choice_pat_ec8942d",
      map_tok_pat_25523b4_rep_choice_pat_ec8942d env x
    )
  | `Bare_dashes tok -> R.Case ("Bare_dashes",
      (* bare_dashes *) token env tok
    )
  )

let map_anon_choice_PLUS_5f1a605 (env : env) (x : CST.anon_choice_PLUS_5f1a605) =
  (match x with
  | `PLUS tok -> R.Case ("PLUS",
      (* "+" *) token env tok
    )
  | `Choice_DASH x -> R.Case ("Choice_DASH",
      map_anon_choice_DASH_75a790b env x
    )
  )

let map_type_name_ (env : env) (x : CST.type_name_) =
  (match x with
  | `Type_name x -> R.Case ("Type_name",
      map_type_name env x
    )
  | `Trai_dot_type_name tok -> R.Case ("Trai_dot_type_name",
      (* trailing_dot_type_name *) token env tok
    )
  )

let map_comparison_operator (env : env) (x : CST.comparison_operator) =
  (match x with
  | `Pat_975eb3a x -> R.Case ("Pat_975eb3a",
      map_pat_975eb3a env x
    )
  | `Pat_1ee7012 x -> R.Case ("Pat_1ee7012",
      map_pat_1ee7012 env x
    )
  | `Pat_dbf96c7 x -> R.Case ("Pat_dbf96c7",
      map_pat_dbf96c7 env x
    )
  | `Pat_e780273 x -> R.Case ("Pat_e780273",
      map_pat_e780273 env x
    )
  | `Pat_ccd4326 x -> R.Case ("Pat_ccd4326",
      map_pat_ccd4326 env x
    )
  | `Pat_fb1d2b1 x -> R.Case ("Pat_fb1d2b1",
      map_pat_fb1d2b1 env x
    )
  | `Pat_9fae069 x -> R.Case ("Pat_9fae069",
      map_pat_9fae069 env x
    )
  | `Pat_c1a5391 x -> R.Case ("Pat_c1a5391",
      map_pat_c1a5391 env x
    )
  | `Pat_0152635 x -> R.Case ("Pat_0152635",
      map_pat_0152635 env x
    )
  | `Pat_399c5a5 x -> R.Case ("Pat_399c5a5",
      map_pat_399c5a5 env x
    )
  | `Pat_711b49c x -> R.Case ("Pat_711b49c",
      map_pat_711b49c env x
    )
  | `Pat_ebd9644 x -> R.Case ("Pat_ebd9644",
      map_pat_ebd9644 env x
    )
  | `Pat_6848da0 x -> R.Case ("Pat_6848da0",
      map_pat_6848da0 env x
    )
  | `Pat_66302c1 x -> R.Case ("Pat_66302c1",
      map_pat_66302c1 env x
    )
  | `Pat_d93d303 x -> R.Case ("Pat_d93d303",
      map_pat_d93d303 env x
    )
  | `Pat_481abbe x -> R.Case ("Pat_481abbe",
      map_pat_481abbe env x
    )
  | `Pat_2dff261 x -> R.Case ("Pat_2dff261",
      map_pat_2dff261 env x
    )
  | `Csplit_op x -> R.Case ("Csplit_op",
      map_csplit_operator env x
    )
  | `Pat_4bb388b x -> R.Case ("Pat_4bb388b",
      map_pat_4bb388b env x
    )
  | `Pat_a78b04d x -> R.Case ("Pat_a78b04d",
      map_pat_a78b04d env x
    )
  | `Pat_5992099 x -> R.Case ("Pat_5992099",
      map_pat_5992099 env x
    )
  | `Pat_e459adc x -> R.Case ("Pat_e459adc",
      map_pat_e459adc env x
    )
  | `Pat_4a7d117 x -> R.Case ("Pat_4a7d117",
      map_pat_4a7d117 env x
    )
  | `Pat_1ef8891 x -> R.Case ("Pat_1ef8891",
      map_pat_1ef8891 env x
    )
  | `Pat_f693f8b x -> R.Case ("Pat_f693f8b",
      map_pat_f693f8b env x
    )
  | `Pat_61eab51 x -> R.Case ("Pat_61eab51",
      map_pat_61eab51 env x
    )
  | `Pat_3f5725c x -> R.Case ("Pat_3f5725c",
      map_pat_3f5725c env x
    )
  | `Pat_32e67b3 x -> R.Case ("Pat_32e67b3",
      map_pat_32e67b3 env x
    )
  | `Pat_d94f457 x -> R.Case ("Pat_d94f457",
      map_pat_d94f457 env x
    )
  | `Pat_ac770bb x -> R.Case ("Pat_ac770bb",
      map_pat_ac770bb env x
    )
  | `Pat_3fbe826 x -> R.Case ("Pat_3fbe826",
      map_pat_3fbe826 env x
    )
  | `Pat_c37ec16 x -> R.Case ("Pat_c37ec16",
      map_pat_c37ec16 env x
    )
  | `Pat_4f5d3ac x -> R.Case ("Pat_4f5d3ac",
      map_pat_4f5d3ac env x
    )
  | `Pat_d5a6271 x -> R.Case ("Pat_d5a6271",
      map_pat_d5a6271 env x
    )
  | `Pat_5efd524 x -> R.Case ("Pat_5efd524",
      map_pat_5efd524 env x
    )
  | `Pat_f1611b9 x -> R.Case ("Pat_f1611b9",
      map_pat_f1611b9 env x
    )
  | `Pat_dc8ff84 x -> R.Case ("Pat_dc8ff84",
      map_pat_dc8ff84 env x
    )
  | `Pat_6b4bb94 x -> R.Case ("Pat_6b4bb94",
      map_pat_6b4bb94 env x
    )
  | `Pat_e75a1ac x -> R.Case ("Pat_e75a1ac",
      map_pat_e75a1ac env x
    )
  | `Isplit_op x -> R.Case ("Isplit_op",
      map_isplit_operator env x
    )
  | `Join_op x -> R.Case ("Join_op",
      map_join_operator env x
    )
  | `Pat_5973a47 x -> R.Case ("Pat_5973a47",
      map_pat_5973a47 env x
    )
  | `Pat_4e06ed5 x -> R.Case ("Pat_4e06ed5",
      map_pat_4e06ed5 env x
    )
  | `Pat_a930296 x -> R.Case ("Pat_a930296",
      map_pat_a930296 env x
    )
  | `Pat_734c26b x -> R.Case ("Pat_734c26b",
      map_pat_734c26b env x
    )
  | `Pat_dacd35e x -> R.Case ("Pat_dacd35e",
      map_pat_dacd35e env x
    )
  | `Pat_d7653bb x -> R.Case ("Pat_d7653bb",
      map_pat_d7653bb env x
    )
  | `Pat_625cb41 x -> R.Case ("Pat_625cb41",
      map_pat_625cb41 env x
    )
  | `Pat_7007e18 x -> R.Case ("Pat_7007e18",
      map_pat_7007e18 env x
    )
  | `Pat_a49b289 x -> R.Case ("Pat_a49b289",
      map_pat_a49b289 env x
    )
  | `Pat_ad90d9b x -> R.Case ("Pat_ad90d9b",
      map_pat_ad90d9b env x
    )
  | `Pat_d66cbf4 x -> R.Case ("Pat_d66cbf4",
      map_pat_d66cbf4 env x
    )
  | `Pat_48c4f3f x -> R.Case ("Pat_48c4f3f",
      map_pat_48c4f3f env x
    )
  | `Split_op x -> R.Case ("Split_op",
      map_split_operator env x
    )
  )

let map_switch_parameters (env : env) (xs : CST.switch_parameters) =
  R.List (List.map (map_switch_parameter env) xs)

let map_verbatim_command_argument (env : env) ((v1, v2) : CST.verbatim_command_argument) =
  let v1 = (* "--%" *) token env v1 in
  let v2 = map_verbatim_command_argument_chars env v2 in
  R.Tuple [v1; v2]

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

and map_type_literal (env : env) ((v1, v2, v3, v4) : CST.type_literal) =
  let v1 = (* "[" *) token env v1 in
  let v2 = map_attribute_name env v2 in
  let v3 =
    (match v3 with
    | Some tok -> R.Option (Some (
        (* assembly_qualifier *) token env tok
      ))
    | None -> R.Option None)
  in
  let v4 = (* "]" *) token env v4 in
  R.Tuple [v1; v2; v3; v4]

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

let map_generic_method_arguments (env : env) ((v1, v2, v3, v4) : CST.generic_method_arguments) =
  let v1 = (* "[" *) token env v1 in
  let v2 = map_attribute_name env v2 in
  let v3 =
    R.List (List.map (fun (v1, v2) ->
      let v1 = (* "," *) token env v1 in
      let v2 = map_attribute_name env v2 in
      R.Tuple [v1; v2]
    ) v3)
  in
  let v4 = (* "]" *) token env v4 in
  R.Tuple [v1; v2; v3; v4]

let rec map_additive_argument_expression (env : env) (x : CST.additive_argument_expression) =
  (match x with
  | `Mult_arg_exp x -> R.Case ("Mult_arg_exp",
      map_multiplicative_argument_expression env x
    )
  | `Addi_arg_exp_choice_PLUS_mult_arg_exp (v1, v2, v3) -> R.Case ("Addi_arg_exp_choice_PLUS_mult_arg_exp",
      let v1 = map_additive_argument_expression env v1 in
      let v2 = map_anon_choice_PLUS_5f1a605 env v2 in
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
      let v2 = map_anon_choice_PLUS_5f1a605 env v2 in
      let v3 = map_multiplicative_expression env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_adjacent_dash_colon_arguments (env : env) ((v1, v2, v3) : CST.adjacent_dash_colon_arguments) =
  let v1 = (* dash_colon_argument_boundary *) token env v1 in
  let v2 = map_argument_after_quote env v2 in
  let v3 = R.List (List.map (map_command_element env) v3) in
  R.Tuple [v1; v2; v3]

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
            map_inlinescript_block_argument env x
          )
        )
      in
      let v2 = (* completed_expression_boundary *) token env v2 in
      let v3 = map_argument_after_quote env v3 in
      R.Tuple [v1; v2; v3]
    )
  | `Paren_member_array_opt_comp_member_boun_arg_after_quote x -> R.Case ("Paren_member_array_opt_comp_member_boun_arg_after_quote",
      map_anon_paren_member_array_opt_comp_member_boun_arg_after_quote_8309ac2 env x
    )
  | `Paren_call_array_opt_comp_exp_boun_arg_after_quote x -> R.Case ("Paren_call_array_opt_comp_exp_boun_arg_after_quote",
      map_anon_paren_call_array_opt_comp_exp_boun_arg_after_quote_1c273aa env x
    )
  )

and map_adjacent_invocation_arguments (env : env) ((v1, v2, v3) : CST.adjacent_invocation_arguments) =
  let v1 = (* invocation_argument_boundary *) token env v1 in
  let v2 = map_argument_after_quote env v2 in
  let v3 = R.List (List.map (map_command_element env) v3) in
  R.Tuple [v1; v2; v3]

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

and map_anon_choice_class_defa_addi_7e4e529 (env : env) (x : CST.anon_choice_class_defa_addi_7e4e529) =
  (match x with
  | `Class_defa_addi x -> R.Case ("Class_defa_addi",
      map_class_default_additive env x
    )
  | `Class_defa_null_coal x -> R.Case ("Class_defa_null_coal",
      map_class_default_null_coalescing env x
    )
  )

and map_anon_choice_cmd_elemes_6862edb (env : env) (x : CST.anon_choice_cmd_elemes_6862edb) =
  (match x with
  | `Cmd_elemes x -> R.Case ("Cmd_elemes",
      map_command_elements env x
    )
  | `Adja_angle_args (v1, v2, v3) -> R.Case ("Adja_angle_args",
      let v1 = (* angle_argument_boundary *) token env v1 in
      let v2 =
        (match v2 with
        | `Arg_after_quote x -> R.Case ("Arg_after_quote",
            map_argument_after_quote env x
          )
        | `Cmd_param x -> R.Case ("Cmd_param",
            map_command_parameter env x
          )
        )
      in
      let v3 = R.List (List.map (map_command_element env) v3) in
      R.Tuple [v1; v2; v3]
    )
  )

and map_anon_choice_inli_blk_value_974df10 (env : env) (x : CST.anon_choice_inli_blk_value_974df10) =
  (match x with
  | `Script_blk_exp x -> R.Case ("Script_blk_exp",
      map_inlinescript_block_argument env x
    )
  | `Arg_list x -> R.Case ("Arg_list",
      map_argument_list env x
    )
  )

and map_anon_paren_call_array_opt_comp_exp_boun_arg_after_quote_1c273aa (env : env) ((v1, v2) : CST.anon_paren_call_array_opt_comp_exp_boun_arg_after_quote_1c273aa) =
  let v1 = map_paren_call_array env v1 in
  let v2 =
    (match v2 with
    | Some (v1, v2) -> R.Option (Some (
        let v1 = (* completed_expression_boundary *) token env v1 in
        let v2 = map_argument_after_quote env v2 in
        R.Tuple [v1; v2]
      ))
    | None -> R.Option None)
  in
  R.Tuple [v1; v2]

and map_anon_paren_member_array_opt_comp_member_boun_arg_after_quote_8309ac2 (env : env) ((v1, v2) : CST.anon_paren_member_array_opt_comp_member_boun_arg_after_quote_8309ac2) =
  let v1 = map_paren_member_array env v1 in
  let v2 =
    (match v2 with
    | Some (v1, v2) -> R.Option (Some (
        let v1 = (* completed_member_boundary *) token env v1 in
        let v2 = map_argument_after_quote env v2 in
        R.Tuple [v1; v2]
      ))
    | None -> R.Option None)
  in
  R.Tuple [v1; v2]

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

and map_assigned_statement (env : env) (x : CST.assigned_statement) =
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
  | `Func_stmt (v1, v2, v3, v4, v5, v6, v7) -> R.Case ("Func_stmt",
      let v1 =
        (match v1 with
        | `Choice_func_kw_func_cont_plain (v1, v2) -> R.Case ("Choice_func_kw_func_cont_plain",
            let v1 =
              (match v1 with
              | `Func_kw x -> R.Case ("Func_kw",
                  map_function_keyword env x
                )
              | `Filter_kw x -> R.Case ("Filter_kw",
                  map_filter_keyword env x
                )
              )
            in
            let v2 = (* function_context_plain *) token env v2 in
            R.Tuple [v1; v2]
          )
        | `Work_kw_func_cont_work (v1, v2) -> R.Case ("Work_kw_func_cont_work",
            let v1 = map_workflow_keyword env v1 in
            let v2 = (* function_context_workflow *) token env v2 in
            R.Tuple [v1; v2]
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
      let v7 = (* function_context_end *) token env v7 in
      R.Tuple [v1; v2; v3; v4; v5; v6; v7]
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
  | `Enum_stmt (v1, v2, v3, v4, v5, v6, v7) -> R.Case ("Enum_stmt",
      let v1 =
        (match v1 with
        | Some x -> R.Option (Some (
            map_attribute_list env x
          ))
        | None -> R.Option None)
      in
      let v2 = map_tok_prec_p1_pat_enum env v2 in
      let v3 = (* simple_name *) token env v3 in
      let v4 =
        (match v4 with
        | Some (v1, v2, v3) -> R.Option (Some (
            let v1 = (* enum_base_colon_ahead *) token env v1 in
            let v2 = (* ":" *) token env v2 in
            let v3 = map_attribute_name env v3 in
            R.Tuple [v1; v2; v3]
          ))
        | None -> R.Option None)
      in
      let v5 = (* "{" *) token env v5 in
      let v6 =
        R.List (List.map (fun (v1, v2, v3) ->
          let v1 = map_enum_member env v1 in
          let v2 = (* statement_terminator *) token env v2 in
          let v3 = R.List (List.map (token env (* ";" *)) v3) in
          R.Tuple [v1; v2; v3]
        ) v6)
      in
      let v7 = (* "}" *) token env v7 in
      R.Tuple [v1; v2; v3; v4; v5; v6; v7]
    )
  | `Flow_cont_stmt_stmt_term (v1, v2) -> R.Case ("Flow_cont_stmt_stmt_term",
      let v1 = map_flow_control_statement env v1 in
      let v2 = (* statement_terminator *) token env v2 in
      R.Tuple [v1; v2]
    )
  | `Colon_flow_cont (v1, v2) -> R.Case ("Colon_flow_cont",
      let v1 = map_anon_choice_pat_brk_17ec5e1 env v1 in
      let v2 = (* flow_control_colon_word *) token env v2 in
      R.Tuple [v1; v2]
    )
  | `Labe_flow_cont (v1, v2) -> R.Case ("Labe_flow_cont",
      let v1 = map_anon_choice_pat_brk_17ec5e1 env v1 in
      let v2 = map_label_expression env v2 in
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
  | `Pipe_chains_stmt_term (v1, v2) -> R.Case ("Pipe_chains_stmt_term",
      let v1 = map_pipeline_chains env v1 in
      let v2 = (* statement_terminator *) token env v2 in
      R.Tuple [v1; v2]
    )
  | `Pipe_chains_back_op (v1, v2) -> R.Case ("Pipe_chains_back_op",
      let v1 = map_pipeline_chains env v1 in
      let v2 = (* "&" *) token env v2 in
      R.Tuple [v1; v2]
    )
  | `Assign_pipe x -> R.Case ("Assign_pipe",
      map_assignment_pipeline env x
    )
  )

and map_assignment_expression (env : env) ((v1, v2, v3) : CST.assignment_expression) =
  let v1 = map_left_assignment_expression env v1 in
  let v2 = map_assignement_operator env v2 in
  let v3 = map_assigned_statement env v3 in
  R.Tuple [v1; v2; v3]

and map_assignment_pipeline (env : env) (x : CST.assignment_pipeline) =
  map_assignment_expression env x

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
      let v2 = map_anon_choice_PLUS_5f1a605 env v2 in
      let v3 = map_attribute_multiplicative_expression env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_attribute_argument (env : env) (x : CST.attribute_argument) =
  (match x with
  | `Attr_exp x -> R.Case ("Attr_exp",
      map_attribute_expression env x
    )
  | `Attr_name_arg x -> R.Case ("Attr_name_arg",
      map_attribute_name_argument env x
    )
  )

and map_attribute_arguments (env : env) (x : CST.attribute_arguments) =
  (match x with
  | `Attr_arg_rep_COMMA_attr_arg (v1, v2) -> R.Case ("Attr_arg_rep_COMMA_attr_arg",
      let v1 = map_attribute_argument env v1 in
      let v2 =
        R.List (List.map (fun (v1, v2) ->
          let v1 = (* "," *) token env v1 in
          let v2 = map_attribute_argument env v2 in
          R.Tuple [v1; v2]
        ) v2)
      in
      R.Tuple [v1; v2]
    )
  | `COMMA_attr_name_arg_rep_COMMA_attr_arg (v1, v2, v3) -> R.Case ("COMMA_attr_name_arg_rep_COMMA_attr_arg",
      let v1 = (* "," *) token env v1 in
      let v2 = map_attribute_name_argument env v2 in
      let v3 =
        R.List (List.map (fun (v1, v2) ->
          let v1 = (* "," *) token env v1 in
          let v2 = map_attribute_argument env v2 in
          R.Tuple [v1; v2]
        ) v3)
      in
      R.Tuple [v1; v2; v3]
    )
  )

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
  | `Attr_bitw_exp_choice_pat_0a8cd29_attr_comp_exp (v1, v2, v3) -> R.Case ("Attr_bitw_exp_choice_pat_0a8cd29_attr_comp_exp",
      let v1 = map_attribute_bitwise_expression env v1 in
      let v2 = map_anon_choice_pat_0a8cd29_7c5cd31 env v2 in
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
  | `Attr_logi_exp_choice_pat_32b8d8b_attr_bitw_exp (v1, v2, v3) -> R.Case ("Attr_logi_exp_choice_pat_32b8d8b_attr_bitw_exp",
      let v1 = map_attribute_logical_expression env v1 in
      let v2 = map_anon_choice_pat_32b8d8b_b35500c env v2 in
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

and map_attribute_name_argument (env : env) ((v1, v2) : CST.attribute_name_argument) =
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
  | `Bitw_arg_exp_choice_pat_0a8cd29_comp_arg_exp (v1, v2, v3) -> R.Case ("Bitw_arg_exp_choice_pat_0a8cd29_comp_arg_exp",
      let v1 = map_bitwise_argument_expression env v1 in
      let v2 = map_anon_choice_pat_0a8cd29_7c5cd31 env v2 in
      let v3 = map_comparison_argument_expression env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_bitwise_expression (env : env) (x : CST.bitwise_expression) =
  (match x with
  | `Comp_exp x -> R.Case ("Comp_exp",
      map_comparison_expression env x
    )
  | `Bitw_exp_choice_pat_0a8cd29_comp_exp (v1, v2, v3) -> R.Case ("Bitw_exp_choice_pat_0a8cd29_comp_exp",
      let v1 = map_bitwise_expression env v1 in
      let v2 = map_anon_choice_pat_0a8cd29_7c5cd31 env v2 in
      let v3 = map_comparison_expression env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_catch_clause (env : env) ((v1, v2, v3, v4) : CST.catch_clause) =
  let v1 =
    (match v1 with
    | Some tok -> R.Option (Some (
        (* try_clause_ahead *) token env tok
      ))
    | None -> R.Option None)
  in
  let v2 = map_pat_catch env v2 in
  let v3 =
    (match v3 with
    | Some x -> R.Option (Some (
        map_catch_type_list env x
      ))
    | None -> R.Option None)
  in
  let v4 = map_statement_block env v4 in
  R.Tuple [v1; v2; v3; v4]

and map_catch_clauses (env : env) (xs : CST.catch_clauses) =
  R.List (List.map (map_catch_clause env) xs)

and map_class_base_constructor_call (env : env) ((v1, v2, v3) : CST.class_base_constructor_call) =
  let v1 = (* ":" *) token env v1 in
  let v2 = map_pat_base env v2 in
  let v3 = map_argument_list env v3 in
  R.Tuple [v1; v2; v3]

and map_class_default_additive (env : env) (x : CST.class_default_additive) =
  (match x with
  | `Class_defa_mult x -> R.Case ("Class_defa_mult",
      map_class_default_multiplicative env x
    )
  | `Class_defa_addi_choice_PLUS_class_defa_mult (v1, v2, v3) -> R.Case ("Class_defa_addi_choice_PLUS_class_defa_mult",
      let v1 = map_class_default_additive env v1 in
      let v2 = map_anon_choice_PLUS_5f1a605 env v2 in
      let v3 = map_class_default_multiplicative env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_class_default_array (env : env) (x : CST.class_default_array) =
  (match x with
  | `Cmd_un_exp x -> R.Case ("Cmd_un_exp",
      map_command_unary_expression env x
    )
  | `Attr_type_value x -> R.Case ("Attr_type_value",
      map_attribute_type_value env x
    )
  | `Gene_prim_exp x -> R.Case ("Gene_prim_exp",
      map_generic_primary_expression env x
    )
  )

and map_class_default_bitwise (env : env) (x : CST.class_default_bitwise) =
  (match x with
  | `Class_defa_comp x -> R.Case ("Class_defa_comp",
      map_class_default_comparison env x
    )
  | `Class_defa_bitw_choice_pat_0a8cd29_class_defa_comp (v1, v2, v3) -> R.Case ("Class_defa_bitw_choice_pat_0a8cd29_class_defa_comp",
      let v1 = map_class_default_bitwise env v1 in
      let v2 = map_anon_choice_pat_0a8cd29_7c5cd31 env v2 in
      let v3 = map_class_default_comparison env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_class_default_comparison (env : env) (x : CST.class_default_comparison) =
  (match x with
  | `Class_defa_addi x -> R.Case ("Class_defa_addi",
      map_class_default_additive env x
    )
  | `Class_defa_null_coal x -> R.Case ("Class_defa_null_coal",
      map_class_default_null_coalescing env x
    )
  | `Class_defa_comp_comp_op_choice_class_defa_addi (v1, v2, v3) -> R.Case ("Class_defa_comp_comp_op_choice_class_defa_addi",
      let v1 = map_class_default_comparison env v1 in
      let v2 = map_comparison_operator env v2 in
      let v3 = map_anon_choice_class_defa_addi_7e4e529 env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_class_default_format (env : env) (x : CST.class_default_format) =
  (match x with
  | `Class_defa_range x -> R.Case ("Class_defa_range",
      map_class_default_range env x
    )
  | `Class_defa_format_format_op_class_defa_range (v1, v2, v3) -> R.Case ("Class_defa_format_format_op_class_defa_range",
      let v1 = map_class_default_format env v1 in
      let v2 = map_format_operator env v2 in
      let v3 = map_class_default_range env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_class_default_logical (env : env) (x : CST.class_default_logical) =
  (match x with
  | `Class_defa_bitw x -> R.Case ("Class_defa_bitw",
      map_class_default_bitwise env x
    )
  | `Class_defa_logi_choice_pat_32b8d8b_class_defa_bitw (v1, v2, v3) -> R.Case ("Class_defa_logi_choice_pat_32b8d8b_class_defa_bitw",
      let v1 = map_class_default_logical env v1 in
      let v2 = map_anon_choice_pat_32b8d8b_b35500c env v2 in
      let v3 = map_class_default_bitwise env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_class_default_multiplicative (env : env) (x : CST.class_default_multiplicative) =
  (match x with
  | `Class_defa_format x -> R.Case ("Class_defa_format",
      map_class_default_format env x
    )
  | `Class_defa_mult_choice_SLASH_class_defa_format (v1, v2, v3) -> R.Case ("Class_defa_mult_choice_SLASH_class_defa_format",
      let v1 = map_class_default_multiplicative env v1 in
      let v2 = map_anon_choice_SLASH_4ca1f7c env v2 in
      let v3 = map_class_default_format env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_class_default_null_coalescing (env : env) ((v1, v2, v3) : CST.class_default_null_coalescing) =
  let v1 = map_anon_choice_class_defa_addi_7e4e529 env v1 in
  let v2 = (* "??" *) token env v2 in
  let v3 = map_class_default_additive env v3 in
  R.Tuple [v1; v2; v3]

and map_class_default_range (env : env) (x : CST.class_default_range) =
  (match x with
  | `Class_defa_array x -> R.Case ("Class_defa_array",
      map_class_default_array env x
    )
  | `Class_defa_range_DOTDOT_class_defa_array (v1, v2, v3) -> R.Case ("Class_defa_range_DOTDOT_class_defa_array",
      let v1 = map_class_default_range env v1 in
      let v2 = (* ".." *) token env v2 in
      let v3 = map_class_default_array env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

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

and map_class_method_parameter (env : env) ((v1, v2, v3) : CST.class_method_parameter) =
  let v1 =
    (match v1 with
    | Some x -> R.Option (Some (
        map_attribute_type_value env x
      ))
    | None -> R.Option None)
  in
  let v2 = map_variable env v2 in
  let v3 =
    (match v3 with
    | Some x -> R.Option (Some (
        map_class_method_parameter_default env x
      ))
    | None -> R.Option None)
  in
  R.Tuple [v1; v2; v3]

and map_class_method_parameter_default (env : env) ((v1, v2) : CST.class_method_parameter_default) =
  let v1 = (* "=" *) token env v1 in
  let v2 = map_class_parameter_default_expression env v2 in
  R.Tuple [v1; v2]

and map_class_method_parameter_list (env : env) ((v1, v2) : CST.class_method_parameter_list) =
  let v1 = map_class_method_parameter env v1 in
  let v2 =
    R.List (List.map (fun (v1, v2) ->
      let v1 = (* "," *) token env v1 in
      let v2 = map_class_method_parameter env v2 in
      R.Tuple [v1; v2]
    ) v2)
  in
  R.Tuple [v1; v2]

and map_class_parameter_default_expression (env : env) (x : CST.class_parameter_default_expression) =
  (match x with
  | `Class_defa_logi x -> R.Case ("Class_defa_logi",
      map_class_default_logical env x
    )
  | `Class_defa_tern (v1, v2, v3, v4, v5) -> R.Case ("Class_defa_tern",
      let v1 = map_class_default_logical env v1 in
      let v2 = (* "?" *) token env v2 in
      let v3 = map_class_parameter_default_expression env v3 in
      let v4 = (* ":" *) token env v4 in
      let v5 = map_class_parameter_default_expression env v5 in
      R.Tuple [v1; v2; v3; v4; v5]
    )
  )

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
    | Some (v1, v2) -> R.Option (Some (
        let v1 = (* "=" *) token env v1 in
        let v2 = map_left_assignment_expression env v2 in
        R.Tuple [v1; v2]
      ))
    | None -> R.Option None)
  in
  R.Tuple [v1; v2; v3; v4]

and map_colon_command_argument (env : env) (x : CST.colon_command_argument) =
  (match x with
  | `Tok_pat_77937c4 x -> R.Case ("Tok_pat_77937c4",
      map_tok_pat_77937c4 env x
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
  | `Angle_cmd_name_opt_choice_cmd_elemes (v1, v2) -> R.Case ("Angle_cmd_name_opt_choice_cmd_elemes",
      let v1 = map_angle_command_name env v1 in
      let v2 =
        (match v2 with
        | Some x -> R.Option (Some (
            map_anon_choice_cmd_elemes_6862edb env x
          ))
        | None -> R.Option None)
      in
      R.Tuple [v1; v2]
    )
  | `Dash_colon_cmd_name_opt_choice_cmd_elemes (v1, v2) -> R.Case ("Dash_colon_cmd_name_opt_choice_cmd_elemes",
      let v1 = (* dash_colon_command_name *) token env v1 in
      let v2 =
        (match v2 with
        | Some x -> R.Option (Some (
            (match x with
            | `Cmd_elemes x -> R.Case ("Cmd_elemes",
                map_command_elements env x
              )
            | `Adja_dash_colon_args x -> R.Case ("Adja_dash_colon_args",
                map_adjacent_dash_colon_arguments env x
              )
            )
          ))
        | None -> R.Option None)
      in
      R.Tuple [v1; v2]
    )
  | `Cmd_invo_op_angle_cmd_name_opt_choice_cmd_elemes (v1, v2, v3) -> R.Case ("Cmd_invo_op_angle_cmd_name_opt_choice_cmd_elemes",
      let v1 = map_command_invokation_operator env v1 in
      let v2 = map_angle_command_name env v2 in
      let v3 =
        (match v3 with
        | Some x -> R.Option (Some (
            map_anon_choice_cmd_elemes_6862edb env x
          ))
        | None -> R.Option None)
      in
      R.Tuple [v1; v2; v3]
    )
  | `Cmd_invo_op_cmd_name_expr_opt_choice_cmd_elemes (v1, v2, v3) -> R.Case ("Cmd_invo_op_cmd_name_expr_opt_choice_cmd_elemes",
      let v1 = map_command_invokation_operator env v1 in
      let v2 = map_data_command env v2 in
      let v3 =
        (match v3 with
        | Some x -> R.Option (Some (
            (match x with
            | `Cmd_elemes x -> R.Case ("Cmd_elemes",
                map_command_elements env x
              )
            | `Adja_invo_args x -> R.Case ("Adja_invo_args",
                map_adjacent_invocation_arguments env x
              )
            )
          ))
        | None -> R.Option None)
      in
      R.Tuple [v1; v2; v3]
    )
  | `Inli_name_inli_elemes (v1, v2) -> R.Case ("Inli_name_inli_elemes",
      let v1 = (* inlinescript_name *) token env v1 in
      let v2 = map_inlinescript_elements env v2 in
      R.Tuple [v1; v2]
    )
  )

and map_command_argument (env : env) (x : CST.command_argument) =
  (match x with
  | `Cmd_arg_sep_choice_cmd_word_choice_arg_list_opt_choice_comp_exp_boun_arg_after_quote (v1, v2, v3) -> R.Case ("Cmd_arg_sep_choice_cmd_word_choice_arg_list_opt_choice_comp_exp_boun_arg_after_quote",
      let v1 = map_command_argument_sep env v1 in
      let v2 =
        (match v2 with
        | `Cmd_word x -> R.Case ("Cmd_word",
            map_command_word env x
          )
        | `Cmd_pipe_prefix_array_adja_paren_boun (v1, v2) -> R.Case ("Cmd_pipe_prefix_array_adja_paren_boun",
            let v1 = map_command_pipeline_prefix_array env v1 in
            let v2 = (* adjacent_paren_boundary *) token env v2 in
            R.Tuple [v1; v2]
          )
        )
      in
      let v3 =
        (match v3 with
        | `Arg_list_opt_choice_comp_exp_boun_arg_after_quote (v1, v2) -> R.Case ("Arg_list_opt_choice_comp_exp_boun_arg_after_quote",
            let v1 = map_argument_list env v1 in
            let v2 =
              (match v2 with
              | Some x -> R.Option (Some (
                  (match x with
                  | `Comp_exp_boun_arg_after_quote (v1, v2) -> R.Case ("Comp_exp_boun_arg_after_quote",
                      let v1 = (* completed_expression_boundary *) token env v1 in
                      let v2 = map_argument_after_quote env v2 in
                      R.Tuple [v1; v2]
                    )
                  | `Rep1_cmd_array_tail xs -> R.Case ("Rep1_cmd_array_tail",
                      R.List (List.map (map_command_array_tail env) xs)
                    )
                  )
                ))
              | None -> R.Option None)
            in
            R.Tuple [v1; v2]
          )
        | `Paren_exp x -> R.Case ("Paren_exp",
            map_parenthesized_expression env x
          )
        | `Paren_member_array_opt_comp_member_boun_arg_after_quote x -> R.Case ("Paren_member_array_opt_comp_member_boun_arg_after_quote",
            map_anon_paren_member_array_opt_comp_member_boun_arg_after_quote_8309ac2 env x
          )
        | `Paren_call_array_opt_comp_exp_boun_arg_after_quote x -> R.Case ("Paren_call_array_opt_comp_exp_boun_arg_after_quote",
            map_anon_paren_call_array_opt_comp_exp_boun_arg_after_quote_1c273aa env x
          )
        )
      in
      R.Tuple [v1; v2; v3]
    )
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
      map_inlinescript_block_argument env x
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
  | `Cmd_word_arg_list (v1, v2) -> R.Case ("Cmd_word_arg_list",
      let v1 = map_command_word env v1 in
      let v2 = map_argument_list env v2 in
      R.Tuple [v1; v2]
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
                | `Tok_prec_p1_pat_8877d6b x -> R.Case ("Tok_prec_p1_pat_8877d6b",
                    map_tok_prec_p1_pat_8877d6b env x
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
      let v1 = map_single_command_parameter env v1 in
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
  | `Dash_param_rep1_cmd_array_tail (v1, v2) -> R.Case ("Dash_param_rep1_cmd_array_tail",
      let v1 = (* dashdash_parameter *) token env v1 in
      let v2 =
        R.List (List.map (map_command_array_tail env) v2)
      in
      R.Tuple [v1; v2]
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
  | `Cmd_arg_sep_gene_tok_imm_tok_pat_8877d6b_opt_arg_after_quote (v1, v2, v3, v4) -> R.Case ("Cmd_arg_sep_gene_tok_imm_tok_pat_8877d6b_opt_arg_after_quote",
      let v1 = map_command_argument_sep env v1 in
      let v2 = map_generic_token env v2 in
      let v3 = map_imm_tok_pat_8877d6b env v3 in
      let v4 =
        (match v4 with
        | Some x -> R.Option (Some (
            map_argument_after_quote env x
          ))
        | None -> R.Option None)
      in
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
  | `Stop_pars x -> R.Case ("Stop_pars",
      map_stop_parsing env x
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
      let v2 = R.List (List.map (map_command_name_part env) v2) in
      R.Tuple [v1; v2]
    )
  | `Ordi_cmd_name (v1, v2, v3) -> R.Case ("Ordi_cmd_name",
      let v1 =
        (match v1 with
        | Some tok -> R.Option (Some (
            (* bang_command_name *) token env tok
          ))
        | None -> R.Option None)
      in
      let v2 =
        (match v2 with
        | `Cmd_name_start_esc tok -> R.Case ("Cmd_name_start_esc",
            (* command_name_start_escape *) token env tok
          )
        | `Cmd_name_dollar tok -> R.Case ("Cmd_name_dollar",
            (* command_name_dollar *) token env tok
          )
        | `Pat_4485489 x -> R.Case ("Pat_4485489",
            map_pat_4485489 env x
          )
        | `Pat_0bfef4d x -> R.Case ("Pat_0bfef4d",
            map_pat_0bfef4d env x
          )
        | `Pat_6794e37 x -> R.Case ("Pat_6794e37",
            map_pat_6794e37 env x
          )
        | `Nume_cmd_name tok -> R.Case ("Nume_cmd_name",
            (* numeric_command_name *) token env tok
          )
        | `Kw_dash_cmd_name tok -> R.Case ("Kw_dash_cmd_name",
            (* keyword_dash_command_name *) token env tok
          )
        | `Kw_single_quote_cmd_name_str_lit_imme (v1, v2) -> R.Case ("Kw_single_quote_cmd_name_str_lit_imme",
            let v1 =
              (* keyword_single_quote_command_name *) token env v1
            in
            let v2 = map_string_literal_immediate env v2 in
            R.Tuple [v1; v2]
          )
        | `Kw_double_quote_cmd_name_expa_str_lit_imme (v1, v2) -> R.Case ("Kw_double_quote_cmd_name_expa_str_lit_imme",
            let v1 =
              (* keyword_double_quote_command_name *) token env v1
            in
            let v2 = map_expandable_string_literal_immediate env v2 in
            R.Tuple [v1; v2]
          )
        | `Kw_empty_quote_cmd_name tok -> R.Case ("Kw_empty_quote_cmd_name",
            (* keyword_empty_quote_command_name *) token env tok
          )
        | `Dash_cmd_name x -> R.Case ("Dash_cmd_name",
            map_dash_command_name env x
          )
        | `Kw_dollar_cmd_name_opt_cmd_name_sube (v1, v2) -> R.Case ("Kw_dollar_cmd_name_opt_cmd_name_sube",
            let v1 = (* keyword_dollar_command_name *) token env v1 in
            let v2 =
              (match v2 with
              | Some tok -> R.Option (Some (
                  (* command_name_subexpression *) token env tok
                ))
              | None -> R.Option None)
            in
            R.Tuple [v1; v2]
          )
        | `Tok_prec_p2_pat_f0eaee1 x -> R.Case ("Tok_prec_p2_pat_f0eaee1",
            map_tok_prec_p2_pat_f0eaee1 env x
          )
        | `Tok_prec_p2_pat_a0b6b0e x -> R.Case ("Tok_prec_p2_pat_a0b6b0e",
            map_tok_prec_p2_pat_a0b6b0e env x
          )
        )
      in
      let v3 = R.List (List.map (map_command_name_part env) v3) in
      R.Tuple [v1; v2; v3]
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
            (* pattern [0-9a-zA-Z_?\-\.\\\/][0-9a-zA-Z_?\-\.\\\/@]* *) token env tok
          )
        | `Var_var_cmd_name_cont_path_cmd_name_part (v1, v2, v3) -> R.Case ("Var_var_cmd_name_cont_path_cmd_name_part",
            let v1 = map_variable env v1 in
            let v2 =
              (* variable_command_name_continuation *) token env v2
            in
            let v3 = map_path_command_name_part env v3 in
            R.Tuple [v1; v2; v3]
          )
        )
      in
      let v2 =
        R.List (List.map (fun (v1, v2) ->
          let v1 =
            (* path_command_name_continuation *) token env v1
          in
          let v2 = map_path_command_name_part env v2 in
          R.Tuple [v1; v2]
        ) v2)
      in
      R.Tuple [v1; v2]
    )
  | `Prim_exp x -> R.Case ("Prim_exp",
      map_primary_expression env x
    )
  )

and map_command_name_part (env : env) (x : CST.command_name_part) =
  (match x with
  | `Imm_tok_pat_11f42bb x -> R.Case ("Imm_tok_pat_11f42bb",
      map_imm_tok_pat_11f42bb env x
    )
  | `Imm_tok_dollar_opt_cmd_name_sube (v1, v2) -> R.Case ("Imm_tok_dollar_opt_cmd_name_sube",
      let v1 = map_imm_tok_dollar env v1 in
      let v2 =
        (match v2 with
        | Some tok -> R.Option (Some (
            (* command_name_subexpression *) token env tok
          ))
        | None -> R.Option None)
      in
      R.Tuple [v1; v2]
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

and map_command_parameter_argument (env : env) (x : CST.command_parameter_argument) =
  (match x with
  | `Choice_cmd_word_rep_cmd_array_tail (v1, v2) -> R.Case ("Choice_cmd_word_rep_cmd_array_tail",
      let v1 =
        (match v1 with
        | `Cmd_word x -> R.Case ("Cmd_word",
            map_command_word env x
          )
        | `Param_arg_word tok -> R.Case ("Param_arg_word",
            (* pattern "-+(?:([^\\P{L}\\u{10000}-\\u{10FFFF}]|[\\u1C89-\\u1C8A\\u3400-\\u4DBF\\u4E00-\\u9FFF\\uA7CB-\\uA7CD\\uA7DA-\\uA7DC\\uAC00-\\uD7A3])|[_?\\x60-])[^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*:?|-[0-9.][^\\t-\\r \\u0085\\u00a0\\u1680\\u2000-\\u200a\\u2028\\u2029\\u202f\\u205f\\u3000\"'\\u2018-\\u201E\\x60$(){}|;,&]*|-" *) token env tok
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
        (* pattern "-+(?:([^\\P{L}\\u{10000}-\\u{10FFFF}]|[\\u1C89-\\u1C8A\\u3400-\\u4DBF\\u4E00-\\u9FFF\\uA7CB-\\uA7CD\\uA7DA-\\uA7DC\\uAC00-\\uD7A3])|[_?\\x60-])[^\\x00\\t-\\r \"'&(),.:;\\[{}|\\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2018-\\u201E\\u2028\\u2029\\u202F\\u205F\\u3000]*:?|-[0-9.][^\\t-\\r \\u0085\\u00a0\\u1680\\u2000-\\u200a\\u2028\\u2029\\u202f\\u205f\\u3000\"'\\u2018-\\u201E\\x60$(){}|;,&]*|-" *) token env v1
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

and map_command_pipeline_prefix_array (env : env) ((v1, v2) : CST.command_pipeline_prefix_array) =
  let v1 = map_command_pipeline_prefix_expression env v1 in
  let v2 =
    R.List (List.map (fun (v1, v2) ->
      let v1 = (* "," *) token env v1 in
      let v2 = map_command_pipeline_prefix_expression env v2 in
      R.Tuple [v1; v2]
    ) v2)
  in
  R.Tuple [v1; v2]

and map_command_pipeline_prefix_expression (env : env) (x : CST.command_pipeline_prefix_expression) =
  (match x with
  | `Value x -> R.Case ("Value",
      map_value env x
    )
  | `Elem_access x -> R.Case ("Elem_access",
      map_element_access env x
    )
  | `Invo_exp x -> R.Case ("Invo_exp",
      map_invokation_expression env x
    )
  | `Post_incr_exp x -> R.Case ("Post_incr_exp",
      map_post_increment_expression env x
    )
  | `Post_decr_exp x -> R.Case ("Post_decr_exp",
      map_post_decrement_expression env x
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
  | `Not_op_un_exp (v1, v2) -> R.Case ("Not_op_un_exp",
      let v1 = map_not_operator env v1 in
      let v2 = map_unary_expression env v2 in
      R.Tuple [v1; v2]
    )
  | `BANG_un_exp (v1, v2) -> R.Case ("BANG_un_exp",
      let v1 = (* "!" *) token env v1 in
      let v2 = map_unary_expression env v2 in
      R.Tuple [v1; v2]
    )
  | `Bnot_op_un_exp (v1, v2) -> R.Case ("Bnot_op_un_exp",
      let v1 = map_bnot_operator env v1 in
      let v2 = map_unary_expression env v2 in
      R.Tuple [v1; v2]
    )
  | `PLUS_un_exp (v1, v2) -> R.Case ("PLUS_un_exp",
      let v1 = (* "+" *) token env v1 in
      let v2 = map_unary_expression env v2 in
      R.Tuple [v1; v2]
    )
  | `Choice_DASH_un_exp (v1, v2) -> R.Case ("Choice_DASH_un_exp",
      let v1 = map_anon_choice_DASH_75a790b env v1 in
      let v2 = map_unary_expression env v2 in
      R.Tuple [v1; v2]
    )
  | `Pre_incr_exp (v1, v2) -> R.Case ("Pre_incr_exp",
      let v1 = (* "++" *) token env v1 in
      let v2 = map_unary_expression env v2 in
      R.Tuple [v1; v2]
    )
  | `Pre_decr_exp (v1, v2) -> R.Case ("Pre_decr_exp",
      let v1 = map_anon_choice_DASHDASH_a0c9c93 env v1 in
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
  | `Split_op_un_exp (v1, v2) -> R.Case ("Split_op_un_exp",
      let v1 = map_split_operator env v1 in
      let v2 = map_unary_expression env v2 in
      R.Tuple [v1; v2]
    )
  | `Csplit_op_un_exp (v1, v2) -> R.Case ("Csplit_op_un_exp",
      let v1 = map_csplit_operator env v1 in
      let v2 = map_unary_expression env v2 in
      R.Tuple [v1; v2]
    )
  | `Isplit_op_un_exp (v1, v2) -> R.Case ("Isplit_op_un_exp",
      let v1 = map_isplit_operator env v1 in
      let v2 = map_unary_expression env v2 in
      R.Tuple [v1; v2]
    )
  | `Join_op_un_exp (v1, v2) -> R.Case ("Join_op_un_exp",
      let v1 = map_join_operator env v1 in
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
  | `Rep1_choice_cmd_un_exp_COMMA_cmd_array_item_start_quoted_array_value_quoted_arg_boun (v1, v2, v3) -> R.Case ("Rep1_choice_cmd_un_exp_COMMA_cmd_array_item_start_quoted_array_value_quoted_arg_boun",
      let v1 =
        R.List (List.map (fun (v1, v2, v3) ->
          let v1 =
            (match v1 with
            | `Cmd_un_exp x -> R.Case ("Cmd_un_exp",
                map_command_unary_expression env x
              )
            | `Cmd_word x -> R.Case ("Cmd_word",
                map_command_word env x
              )
            )
          in
          let v2 = (* "," *) token env v2 in
          let v3 = (* command_array_item_start *) token env v3 in
          R.Tuple [v1; v2; v3]
        ) v1)
      in
      let v2 = map_quoted_array_value env v2 in
      let v3 = (* quoted_argument_boundary *) token env v3 in
      R.Tuple [v1; v2; v3]
    )
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
  (match x with
  | `Member_access x -> R.Case ("Member_access",
      map_member_access env x
    )
  | `Var_before_lit_dot tok -> R.Case ("Var_before_lit_dot",
      (* variable_before_literal_dot *) token env tok
    )
  )

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
      map_inlinescript_block_argument env x
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
  let v1 = map_pat_547618a env v1 in
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
  let v2 = map_anon_choice_LBRACK_c253fc2 env v2 in
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

and map_expandable_string_literal (env : env) (x : CST.expandable_string_literal) =
  (match x with
  | `Pat_421479c_rep_choice_imm_tok_prec_p1_pat_b026f1a_rep_imm_tok_dollar_imm_tok_pat_421479c (v1, v2, v3, v4) -> R.Case ("Pat_421479c_rep_choice_imm_tok_prec_p1_pat_b026f1a_rep_imm_tok_dollar_imm_tok_pat_421479c",
      let v1 = map_pat_421479c env v1 in
      let v2 =
        R.List (List.map (fun x ->
          (match x with
          | `Imm_tok_prec_p1_pat_b026f1a x -> R.Case ("Imm_tok_prec_p1_pat_b026f1a",
              map_imm_tok_prec_p1_pat_b026f1a env x
            )
          | `Qual_var_in_str tok -> R.Case ("Qual_var_in_str",
              (* qualified_variable_in_string *) token env tok
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
          | `Expa_str_ahead tok -> R.Case ("Expa_str_ahead",
              (* expandable_string_ahead *) token env tok
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
  | `Quote_unit_open_rep_choice_imm_tok_prec_p1_pat_b026f1a_quote_unit_close (v1, v2, v3) -> R.Case ("Quote_unit_open_rep_choice_imm_tok_prec_p1_pat_b026f1a_quote_unit_close",
      let v1 = (* quote_unit_open *) token env v1 in
      let v2 =
        R.List (List.map (fun x ->
          (match x with
          | `Imm_tok_prec_p1_pat_b026f1a x -> R.Case ("Imm_tok_prec_p1_pat_b026f1a",
              map_imm_tok_prec_p1_pat_b026f1a env x
            )
          | `Qual_var_in_str tok -> R.Case ("Qual_var_in_str",
              (* qualified_variable_in_string *) token env tok
            )
          | `Var x -> R.Case ("Var",
              map_variable env x
            )
          | `Sub_exp x -> R.Case ("Sub_exp",
              map_sub_expression env x
            )
          | `Imm_tok_pat_b0e3134 x -> R.Case ("Imm_tok_pat_b0e3134",
              map_imm_tok_pat_b0e3134 env x
            )
          | `Imm_tok_pat_d8b1f43 x -> R.Case ("Imm_tok_pat_d8b1f43",
              map_imm_tok_pat_d8b1f43 env x
            )
          | `Quote_unit_esc tok -> R.Case ("Quote_unit_esc",
              (* quote_unit_escape *) token env tok
            )
          | `Imm_tok_dollar x -> R.Case ("Imm_tok_dollar",
              map_imm_tok_dollar env x
            )
          | `Expa_str_ahead tok -> R.Case ("Expa_str_ahead",
              (* expandable_string_ahead *) token env tok
            )
          )
        ) v2)
      in
      let v3 = (* quote_unit_close *) token env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

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

and map_finally_clause (env : env) ((v1, v2, v3) : CST.finally_clause) =
  let v1 =
    (match v1 with
    | Some tok -> R.Option (Some (
        (* try_clause_ahead *) token env tok
      ))
    | None -> R.Option None)
  in
  let v2 = map_pat_fina env v2 in
  let v3 = map_statement_block env v3 in
  R.Tuple [v1; v2; v3]

and map_flow_control_statement (env : env) (x : CST.flow_control_statement) =
  (match x with
  | `Pat_brk x -> R.Case ("Pat_brk",
      map_pat_brk env x
    )
  | `Pat_cont x -> R.Case ("Pat_cont",
      map_pat_cont env x
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

and map_for_after_separator (env : env) (x : CST.for_after_separator) =
  (match x with
  | `For_cond_stmt_term_opt_choice_SEMI_opt_for_iter_clause (v1, v2, v3) -> R.Case ("For_cond_stmt_term_opt_choice_SEMI_opt_for_iter_clause",
      let v1 = map_for_condition env v1 in
      let v2 = (* statement_terminator *) token env v2 in
      let v3 =
        (match v3 with
        | Some (v1, v2) -> R.Option (Some (
            let v1 = map_anon_choice_SEMI_ef77367 env v1 in
            let v2 =
              (match v2 with
              | Some x -> R.Option (Some (
                  map_for_iterator_clause env x
                ))
              | None -> R.Option None)
            in
            R.Tuple [v1; v2]
          ))
        | None -> R.Option None)
      in
      R.Tuple [v1; v2; v3]
    )
  | `SEMI_opt_for_iter_clause (v1, v2) -> R.Case ("SEMI_opt_for_iter_clause",
      let v1 = (* ";" *) token env v1 in
      let v2 =
        (match v2 with
        | Some x -> R.Option (Some (
            map_for_iterator_clause env x
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

and map_for_iterator_clause (env : env) ((v1, v2) : CST.for_iterator_clause) =
  let v1 = map_for_iterator env v1 in
  let v2 = (* statement_terminator *) token env v2 in
  R.Tuple [v1; v2]

and map_foreach_parameter (env : env) ((v1, v2, v3) : CST.foreach_parameter) =
  let v1 =
    R.List (List.map (map_foreach_throttle_limit env) v1)
  in
  let v2 = map_pat_4390b74 env v2 in
  let v3 =
    R.List (List.map (fun x ->
      (match x with
      | `Pat_4390b74 x -> R.Case ("Pat_4390b74",
          map_pat_4390b74 env x
        )
      | `Fore_thro_limit x -> R.Case ("Fore_thro_limit",
          map_foreach_throttle_limit env x
        )
      )
    ) v3)
  in
  R.Tuple [v1; v2; v3]

and map_foreach_throttle_limit (env : env) ((v1, v2) : CST.foreach_throttle_limit) =
  let v1 = map_pat_2030147 env v1 in
  let v2 = map_switch_filename env v2 in
  R.Tuple [v1; v2]

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

and map_generic_call_arguments (env : env) ((v1, v2, v3) : CST.generic_call_arguments) =
  let v1 = map_imm_tok_lpar env v1 in
  let v2 =
    (match v2 with
    | Some x -> R.Option (Some (
        map_argument_expression_list env x
      ))
    | None -> R.Option None)
  in
  let v3 = (* ")" *) token env v3 in
  R.Tuple [v1; v2; v3]

and map_generic_invokation (env : env) (x : CST.generic_invokation) =
  (match x with
  | `Prim_exp_member_access_op_gene_meth_name_gene_meth_args_gene_call_args (v1, v2, v3, v4, v5) -> R.Case ("Prim_exp_member_access_op_gene_meth_name_gene_meth_args_gene_call_args",
      let v1 = map_primary_expression env v1 in
      let v2 = map_member_access_operator env v2 in
      let v3 = map_generic_method_name env v3 in
      let v4 = map_generic_method_arguments env v4 in
      let v5 = map_generic_call_arguments env v5 in
      R.Tuple [v1; v2; v3; v4; v5]
    )
  | `Prim_exp_COLONCOLON_gene_meth_name_gene_meth_args_gene_call_args (v1, v2, v3, v4, v5) -> R.Case ("Prim_exp_COLONCOLON_gene_meth_name_gene_meth_args_gene_call_args",
      let v1 = map_primary_expression env v1 in
      let v2 = (* "::" *) token env v2 in
      let v3 = map_generic_method_name env v3 in
      let v4 = map_generic_method_arguments env v4 in
      let v5 = map_generic_call_arguments env v5 in
      R.Tuple [v1; v2; v3; v4; v5]
    )
  | `Gene_prim_exp_member_access_op_gene_meth_name_gene_meth_args_gene_call_args (v1, v2, v3, v4, v5) -> R.Case ("Gene_prim_exp_member_access_op_gene_meth_name_gene_meth_args_gene_call_args",
      let v1 = map_generic_primary_expression env v1 in
      let v2 = map_member_access_operator env v2 in
      let v3 = map_generic_method_name env v3 in
      let v4 = map_generic_method_arguments env v4 in
      let v5 = map_generic_call_arguments env v5 in
      R.Tuple [v1; v2; v3; v4; v5]
    )
  | `Gene_prim_exp_COLONCOLON_gene_meth_name_gene_meth_args_gene_call_args (v1, v2, v3, v4, v5) -> R.Case ("Gene_prim_exp_COLONCOLON_gene_meth_name_gene_meth_args_gene_call_args",
      let v1 = map_generic_primary_expression env v1 in
      let v2 = (* "::" *) token env v2 in
      let v3 = map_generic_method_name env v3 in
      let v4 = map_generic_method_arguments env v4 in
      let v5 = map_generic_call_arguments env v5 in
      R.Tuple [v1; v2; v3; v4; v5]
    )
  )

and map_generic_member_access (env : env) (x : CST.generic_member_access) =
  (match x with
  | `Gene_prim_exp_member_access_op_member_name (v1, v2, v3) -> R.Case ("Gene_prim_exp_member_access_op_member_name",
      let v1 = map_generic_primary_expression env v1 in
      let v2 = map_member_access_operator env v2 in
      let v3 = map_generic_method_name env v3 in
      R.Tuple [v1; v2; v3]
    )
  | `Gene_prim_exp_COLONCOLON_member_name (v1, v2, v3) -> R.Case ("Gene_prim_exp_COLONCOLON_member_name",
      let v1 = map_generic_primary_expression env v1 in
      let v2 = (* "::" *) token env v2 in
      let v3 = map_generic_method_name env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_generic_method_name (env : env) (x : CST.generic_method_name) =
  map_member_name env x

and map_generic_primary_expression (env : env) (x : CST.generic_primary_expression) =
  (match x with
  | `Gene_invo x -> R.Case ("Gene_invo",
      map_generic_invokation env x
    )
  | `Gene_member_access x -> R.Case ("Gene_member_access",
      map_generic_member_access env x
    )
  | `Gene_elem_access (v1, v2, v3, v4) -> R.Case ("Gene_elem_access",
      let v1 = map_generic_primary_expression env v1 in
      let v2 = map_anon_choice_LBRACK_c253fc2 env v2 in
      let v3 = map_left_assignment_expression env v3 in
      let v4 = (* "]" *) token env v4 in
      R.Tuple [v1; v2; v3; v4]
    )
  | `Gene_result_call x -> R.Case ("Gene_result_call",
      map_generic_result_call env x
    )
  | `Gene_post_incr (v1, v2) -> R.Case ("Gene_post_incr",
      let v1 = map_generic_primary_expression env v1 in
      let v2 = (* "++" *) token env v2 in
      R.Tuple [v1; v2]
    )
  | `Gene_post_decr (v1, v2) -> R.Case ("Gene_post_decr",
      let v1 = map_generic_primary_expression env v1 in
      let v2 = map_anon_choice_DASHDASH_a0c9c93 env v2 in
      R.Tuple [v1; v2]
    )
  )

and map_generic_result_call (env : env) (x : CST.generic_result_call) =
  (match x with
  | `Gene_prim_exp_member_access_op_member_name_arg_list (v1, v2, v3, v4) -> R.Case ("Gene_prim_exp_member_access_op_member_name_arg_list",
      let v1 = map_generic_primary_expression env v1 in
      let v2 = map_member_access_operator env v2 in
      let v3 = map_generic_method_name env v3 in
      let v4 = map_argument_list env v4 in
      R.Tuple [v1; v2; v3; v4]
    )
  | `Gene_prim_exp_COLONCOLON_member_name_arg_list (v1, v2, v3, v4) -> R.Case ("Gene_prim_exp_COLONCOLON_member_name_arg_list",
      let v1 = map_generic_primary_expression env v1 in
      let v2 = (* "::" *) token env v2 in
      let v3 = map_generic_method_name env v3 in
      let v4 = map_argument_list env v4 in
      R.Tuple [v1; v2; v3; v4]
    )
  | `Gene_prim_exp_member_access_op_member_name_script_blk_arg_start_script_blk_exp (v1, v2, v3, v4, v5) -> R.Case ("Gene_prim_exp_member_access_op_member_name_script_blk_arg_start_script_blk_exp",
      let v1 = map_generic_primary_expression env v1 in
      let v2 = map_member_access_operator env v2 in
      let v3 = map_generic_method_name env v3 in
      let v4 = (* script_block_argument_start *) token env v4 in
      let v5 = map_inlinescript_block_argument env v5 in
      R.Tuple [v1; v2; v3; v4; v5]
    )
  | `Gene_prim_exp_COLONCOLON_member_name_script_blk_arg_start_script_blk_exp (v1, v2, v3, v4, v5) -> R.Case ("Gene_prim_exp_COLONCOLON_member_name_script_blk_arg_start_script_blk_exp",
      let v1 = map_generic_primary_expression env v1 in
      let v2 = (* "::" *) token env v2 in
      let v3 = map_generic_method_name env v3 in
      let v4 = (* script_block_argument_start *) token env v4 in
      let v5 = map_inlinescript_block_argument env v5 in
      R.Tuple [v1; v2; v3; v4; v5]
    )
  | `Gene_fore_call (v1, v2, v3, v4) -> R.Case ("Gene_fore_call",
      let v1 = map_generic_primary_expression env v1 in
      let v2 = map_member_access_operator env v2 in
      let v3 =
        (* pattern [fF][oO][rR][eE][aA][cC][hH] *) token env v3
      in
      let v4 = map_anon_choice_inli_blk_value_974df10 env v4 in
      R.Tuple [v1; v2; v3; v4]
    )
  )

and map_generic_token (env : env) (x : CST.generic_token) =
  (match x with
  | `Tok_choice_pat_38c66fe x -> R.Case ("Tok_choice_pat_38c66fe",
      map_tok_choice_pat_38c66fe env x
    )
  | `Choice_cmd_word_start_rep_choice_cmd_word_part (v1, v2) -> R.Case ("Choice_cmd_word_start_rep_choice_cmd_word_part",
      let v1 =
        (match v1 with
        | `Cmd_word_start tok -> R.Case ("Cmd_word_start",
            (* command_word_start *) token env tok
          )
        | `Tok_prec_p1_pat_7de4c60 x -> R.Case ("Tok_prec_p1_pat_7de4c60",
            map_tok_prec_p1_pat_7de4c60 env x
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

and map_inlinescript_block_argument (env : env) (x : CST.inlinescript_block_argument) =
  map_inlinescript_block_value env x

and map_inlinescript_block_value (env : env) (x : CST.inlinescript_block_value) =
  map_script_block_expression env x

and map_inlinescript_elements (env : env) ((v1, v2, v3) : CST.inlinescript_elements) =
  let v1 =
    (match v1 with
    | Some x -> R.Option (Some (
        map_command_argument_sep env x
      ))
    | None -> R.Option None)
  in
  let v2 = map_inlinescript_block_argument env v2 in
  let v3 = R.List (List.map (map_command_element env) v3) in
  R.Tuple [v1; v2; v3]

and map_invokation_expression (env : env) (x : CST.invokation_expression) =
  (match x with
  | `Prim_exp_member_access_op_member_name_arg_list (v1, v2, v3, v4) -> R.Case ("Prim_exp_member_access_op_member_name_arg_list",
      let v1 = map_primary_expression env v1 in
      let v2 = map_member_access_operator env v2 in
      let v3 = map_generic_method_name env v3 in
      let v4 = map_argument_list env v4 in
      R.Tuple [v1; v2; v3; v4]
    )
  | `Prim_exp_COLONCOLON_member_name_arg_list (v1, v2, v3, v4) -> R.Case ("Prim_exp_COLONCOLON_member_name_arg_list",
      let v1 = map_primary_expression env v1 in
      let v2 = (* "::" *) token env v2 in
      let v3 = map_generic_method_name env v3 in
      let v4 = map_argument_list env v4 in
      R.Tuple [v1; v2; v3; v4]
    )
  | `Prim_exp_member_access_op_member_name_script_blk_arg_start_script_blk_exp (v1, v2, v3, v4, v5) -> R.Case ("Prim_exp_member_access_op_member_name_script_blk_arg_start_script_blk_exp",
      let v1 = map_primary_expression env v1 in
      let v2 = map_member_access_operator env v2 in
      let v3 = map_generic_method_name env v3 in
      let v4 = (* script_block_argument_start *) token env v4 in
      let v5 = map_inlinescript_block_argument env v5 in
      R.Tuple [v1; v2; v3; v4; v5]
    )
  | `Prim_exp_COLONCOLON_member_name_script_blk_arg_start_script_blk_exp (v1, v2, v3, v4, v5) -> R.Case ("Prim_exp_COLONCOLON_member_name_script_blk_arg_start_script_blk_exp",
      let v1 = map_primary_expression env v1 in
      let v2 = (* "::" *) token env v2 in
      let v3 = map_generic_method_name env v3 in
      let v4 = (* script_block_argument_start *) token env v4 in
      let v5 = map_inlinescript_block_argument env v5 in
      R.Tuple [v1; v2; v3; v4; v5]
    )
  | `Invo_fore_exp (v1, v2, v3, v4) -> R.Case ("Invo_fore_exp",
      let v1 = map_primary_expression env v1 in
      let v2 = map_member_access_operator env v2 in
      let v3 =
        (* pattern [fF][oO][rR][eE][aA][cC][hH] *) token env v3
      in
      let v4 = map_anon_choice_inli_blk_value_974df10 env v4 in
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
        | Some x -> R.Option (Some (
            (match x with
            | `For_init_stmt_term_opt_choice_SEMI_opt_for_after_sepa (v1, v2, v3) -> R.Case ("For_init_stmt_term_opt_choice_SEMI_opt_for_after_sepa",
                let v1 = map_for_initializer env v1 in
                let v2 = (* statement_terminator *) token env v2 in
                let v3 =
                  (match v3 with
                  | Some (v1, v2) -> R.Option (Some (
                      let v1 = map_anon_choice_SEMI_ef77367 env v1 in
                      let v2 =
                        (match v2 with
                        | Some x -> R.Option (Some (
                            map_for_after_separator env x
                          ))
                        | None -> R.Option None)
                      in
                      R.Tuple [v1; v2]
                    ))
                  | None -> R.Option None)
                in
                R.Tuple [v1; v2; v3]
              )
            | `SEMI_opt_for_after_sepa (v1, v2) -> R.Case ("SEMI_opt_for_after_sepa",
                let v1 = (* ";" *) token env v1 in
                let v2 =
                  (match v2 with
                  | Some x -> R.Option (Some (
                      map_for_after_separator env x
                    ))
                  | None -> R.Option None)
                in
                R.Tuple [v1; v2]
              )
            )
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
  | `Real_lit x -> R.Case ("Real_lit",
      map_real_literal env x
    )
  )

and map_logical_argument_expression (env : env) (x : CST.logical_argument_expression) =
  (match x with
  | `Bitw_arg_exp x -> R.Case ("Bitw_arg_exp",
      map_bitwise_argument_expression env x
    )
  | `Logi_arg_exp_choice_pat_32b8d8b_bitw_arg_exp (v1, v2, v3) -> R.Case ("Logi_arg_exp_choice_pat_32b8d8b_bitw_arg_exp",
      let v1 = map_logical_argument_expression env v1 in
      let v2 = map_anon_choice_pat_32b8d8b_b35500c env v2 in
      let v3 = map_bitwise_argument_expression env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_logical_expression (env : env) (x : CST.logical_expression) =
  (match x with
  | `Bitw_exp x -> R.Case ("Bitw_exp",
      map_bitwise_expression env x
    )
  | `Logi_exp_choice_pat_32b8d8b_bitw_exp (v1, v2, v3) -> R.Case ("Logi_exp_choice_pat_32b8d8b_bitw_exp",
      let v1 = map_logical_expression env v1 in
      let v2 = map_anon_choice_pat_32b8d8b_b35500c env v2 in
      let v3 = map_bitwise_expression env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_member_access (env : env) (x : CST.member_access) =
  (match x with
  | `Prim_exp_member_access_op_member_name (v1, v2, v3) -> R.Case ("Prim_exp_member_access_op_member_name",
      let v1 = map_primary_expression env v1 in
      let v2 = map_member_access_operator env v2 in
      let v3 = map_generic_method_name env v3 in
      R.Tuple [v1; v2; v3]
    )
  | `Prim_exp_COLONCOLON_member_name (v1, v2, v3) -> R.Case ("Prim_exp_COLONCOLON_member_name",
      let v1 = map_primary_expression env v1 in
      let v2 = (* "::" *) token env v2 in
      let v3 = map_generic_method_name env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_member_name (env : env) (x : CST.member_name) =
  (match x with
  | `Fore_member_name tok -> R.Case ("Fore_member_name",
      (* pattern [fF][oO][rR][eE][aA][cC][hH] *) token env tok
    )
  | `Fore_pref_member_name tok -> R.Case ("Fore_pref_member_name",
      (* foreach_prefixed_member_name *) token env tok
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

and map_named_block (env : env) ((v1, v2, v3) : CST.named_block) =
  let v1 = map_block_name env v1 in
  let v2 = map_statement_block env v2 in
  let v3 = R.List (List.map (token env (* ";" *)) v3) in
  R.Tuple [v1; v2; v3]

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

and map_paren_call_array (env : env) ((v1, v2) : CST.paren_call_array) =
  let v1 = map_paren_call_value env v1 in
  let v2 =
    R.List (List.map (map_paren_postfix_array_item env) v2)
  in
  R.Tuple [v1; v2]

and map_paren_call_value (env : env) (x : CST.paren_call_value) =
  (match x with
  | `Paren_elem_access (v1, v2, v3, v4) -> R.Case ("Paren_elem_access",
      let v1 = map_paren_chain env v1 in
      let v2 = map_anon_choice_LBRACK_c253fc2 env v2 in
      let v3 = map_left_assignment_expression env v3 in
      let v4 = (* "]" *) token env v4 in
      R.Tuple [v1; v2; v3; v4]
    )
  | `Paren_invo x -> R.Case ("Paren_invo",
      map_paren_invokation env x
    )
  )

and map_paren_chain (env : env) (x : CST.paren_chain) =
  (match x with
  | `Paren_exp x -> R.Case ("Paren_exp",
      map_parenthesized_expression env x
    )
  | `Paren_member_value x -> R.Case ("Paren_member_value",
      map_paren_member_value env x
    )
  | `Paren_call_value x -> R.Case ("Paren_call_value",
      map_paren_call_value env x
    )
  )

and map_paren_invokation (env : env) (x : CST.paren_invokation) =
  (match x with
  | `Paren_chain_member_access_op_member_name_arg_list (v1, v2, v3, v4) -> R.Case ("Paren_chain_member_access_op_member_name_arg_list",
      let v1 = map_paren_chain env v1 in
      let v2 = map_member_access_operator env v2 in
      let v3 = map_generic_method_name env v3 in
      let v4 = map_argument_list env v4 in
      R.Tuple [v1; v2; v3; v4]
    )
  | `Paren_chain_COLONCOLON_member_name_arg_list (v1, v2, v3, v4) -> R.Case ("Paren_chain_COLONCOLON_member_name_arg_list",
      let v1 = map_paren_chain env v1 in
      let v2 = (* "::" *) token env v2 in
      let v3 = map_generic_method_name env v3 in
      let v4 = map_argument_list env v4 in
      R.Tuple [v1; v2; v3; v4]
    )
  )

and map_paren_member_access (env : env) (x : CST.paren_member_access) =
  (match x with
  | `Paren_chain_member_access_op_member_name (v1, v2, v3) -> R.Case ("Paren_chain_member_access_op_member_name",
      let v1 = map_paren_chain env v1 in
      let v2 = map_member_access_operator env v2 in
      let v3 = map_generic_method_name env v3 in
      R.Tuple [v1; v2; v3]
    )
  | `Paren_chain_COLONCOLON_member_name (v1, v2, v3) -> R.Case ("Paren_chain_COLONCOLON_member_name",
      let v1 = map_paren_chain env v1 in
      let v2 = (* "::" *) token env v2 in
      let v3 = map_generic_method_name env v3 in
      R.Tuple [v1; v2; v3]
    )
  )

and map_paren_member_array (env : env) ((v1, v2) : CST.paren_member_array) =
  let v1 = map_paren_member_value env v1 in
  let v2 =
    R.List (List.map (map_paren_postfix_array_item env) v2)
  in
  R.Tuple [v1; v2]

and map_paren_member_value (env : env) (x : CST.paren_member_value) =
  map_paren_member_access env x

and map_paren_postfix_array_item (env : env) ((v1, v2, v3) : CST.paren_postfix_array_item) =
  let v1 = (* "," *) token env v1 in
  let v2 = (* command_array_item_start *) token env v2 in
  let v3 =
    (match v3 with
    | `Cmd_un_exp x -> R.Case ("Cmd_un_exp",
        map_command_unary_expression env x
      )
    | `Cmd_array_word x -> R.Case ("Cmd_array_word",
        map_command_array_word env x
      )
    )
  in
  R.Tuple [v1; v2; v3]

and map_parenthesized_expression (env : env) ((v1, v2, v3) : CST.parenthesized_expression) =
  let v1 = (* "(" *) token env v1 in
  let v2 = map_while_condition env v2 in
  let v3 = (* ")" *) token env v3 in
  R.Tuple [v1; v2; v3]

and map_path_command_name_part (env : env) (x : CST.path_command_name_part) =
  (match x with
  | `Path_cmd_name_tok tok -> R.Case ("Path_cmd_name_tok",
      (* pattern [0-9a-zA-Z_?\-\.\\\/][0-9a-zA-Z_?\-\.\\\/@]* *) token env tok
    )
  | `Var x -> R.Case ("Var",
      map_variable env x
    )
  | `Sub_exp x -> R.Case ("Sub_exp",
      map_sub_expression env x
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

and map_pipeline (env : env) (x : CST.pipeline) =
  (match x with
  | `Assign_pipe x -> R.Case ("Assign_pipe",
      map_assignment_pipeline env x
    )
  | `Pipe_chains x -> R.Case ("Pipe_chains",
      map_pipeline_chains env x
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

and map_pipeline_chains (env : env) ((v1, v2) : CST.pipeline_chains) =
  let v1 = map_pipeline_chain env v1 in
  let v2 =
    R.List (List.map (fun (v1, v2) ->
      let v1 = map_pipeline_chain_tail env v1 in
      let v2 = map_pipeline_chain env v2 in
      R.Tuple [v1; v2]
    ) v2)
  in
  R.Tuple [v1; v2]

and map_pipeline_tail (env : env) (xs : CST.pipeline_tail) =
  R.List (List.map (fun (v1, v2) ->
    let v1 = (* "|" *) token env v1 in
    let v2 = map_command env v2 in
    R.Tuple [v1; v2]
  ) xs)

and map_post_decrement_expression (env : env) ((v1, v2) : CST.post_decrement_expression) =
  let v1 = map_primary_expression env v1 in
  let v2 = map_anon_choice_DASHDASH_a0c9c93 env v2 in
  R.Tuple [v1; v2]

and map_post_increment_expression (env : env) ((v1, v2) : CST.post_increment_expression) =
  let v1 = map_primary_expression env v1 in
  let v2 = (* "++" *) token env v2 in
  R.Tuple [v1; v2]

and map_primary_expression (env : env) (x : CST.primary_expression) =
  (match x with
  | `Value x -> R.Case ("Value",
      map_value env x
    )
  | `Member_access x -> R.Case ("Member_access",
      map_member_access env x
    )
  | `Elem_access x -> R.Case ("Elem_access",
      map_element_access env x
    )
  | `Invo_exp x -> R.Case ("Invo_exp",
      map_invokation_expression env x
    )
  | `Post_incr_exp x -> R.Case ("Post_incr_exp",
      map_post_increment_expression env x
    )
  | `Post_decr_exp x -> R.Case ("Post_decr_exp",
      map_post_decrement_expression env x
    )
  )

and map_quoted_array_value (env : env) (x : CST.quoted_array_value) =
  map_string_literal env x

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
  let v2 = map_class_parameter_default_expression env v2 in
  R.Tuple [v1; v2]

and map_statement (env : env) (x : CST.statement) =
  (match x with
  | `Assi_stmt x -> R.Case ("Assi_stmt",
      map_assigned_statement env x
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
  | `Expa_str_lit x -> R.Case ("Expa_str_lit",
      map_expandable_string_literal env x
    )
  | `Verb_str_charas tok -> R.Case ("Verb_str_charas",
      (* verbatim_string_characters *) token env tok
    )
  | `Expa_here_str_lit (v1, v2) -> R.Case ("Expa_here_str_lit",
      let v1 = map_pat_207e6aa env v1 in
      let v2 =
        (match v2 with
        | `Imm_tok_prec_p2_pat_8992db4 x -> R.Case ("Imm_tok_prec_p2_pat_8992db4",
            map_imm_tok_prec_p2_pat_8992db4 env x
          )
        | `Rep_choice_imm_tok_prec_p1_pat_b45f689_imm_tok_prec_p1_pat_1c6d146 (v1, v2) -> R.Case ("Rep_choice_imm_tok_prec_p1_pat_b45f689_imm_tok_prec_p1_pat_1c6d146",
            let v1 =
              R.List (List.map (fun x ->
                (match x with
                | `Imm_tok_prec_p1_pat_b45f689 x -> R.Case ("Imm_tok_prec_p1_pat_b45f689",
                    map_imm_tok_prec_p1_pat_b45f689 env x
                  )
                | `Qual_var_in_str tok -> R.Case ("Qual_var_in_str",
                    (* qualified_variable_in_string *) token env tok
                  )
                | `Var x -> R.Case ("Var",
                    map_variable env x
                  )
                | `Sub_exp x -> R.Case ("Sub_exp",
                    map_sub_expression env x
                  )
                | `Imm_tok_pat_e380114 x -> R.Case ("Imm_tok_pat_e380114",
                    map_imm_tok_pat_e380114 env x
                  )
                | `Imm_tok_dollar x -> R.Case ("Imm_tok_dollar",
                    map_imm_tok_dollar env x
                  )
                | `Imm_tok_pat_d2fe81f x -> R.Case ("Imm_tok_pat_d2fe81f",
                    map_imm_tok_pat_d2fe81f env x
                  )
                )
              ) v1)
            in
            let v2 = map_imm_tok_prec_p1_pat_1c6d146 env v2 in
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

and map_sub_expression (env : env) (x : CST.sub_expression) =
  (match x with
  | `DOLLARLPAR_opt_stmt_list_RPAR (v1, v2, v3) -> R.Case ("DOLLARLPAR_opt_stmt_list_RPAR",
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
    )
  | `Str_sube_start_opt_stmt_list_RPAR_str_sube_end (v1, v2, v3, v4) -> R.Case ("Str_sube_start_opt_stmt_list_RPAR_str_sube_end",
      let v1 = (* string_subexpression_start *) token env v1 in
      let v2 =
        (match v2 with
        | Some x -> R.Option (Some (
            map_statement_list env x
          ))
        | None -> R.Option None)
      in
      let v3 = (* ")" *) token env v3 in
      let v4 = (* string_subexpression_end *) token env v4 in
      R.Tuple [v1; v2; v3; v4]
    )
  )

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
  | `Switch_clause_tok tok -> R.Case ("Switch_clause_tok",
      (* switch_clause_token *) token env tok
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
  | `Pat_d159322_switch_file (v1, v2) -> R.Case ("Pat_d159322_switch_file",
      let v1 = map_pat_d159322 env v1 in
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
  | `Gene_prim_exp x -> R.Case ("Gene_prim_exp",
      map_generic_primary_expression env x
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
      map_inlinescript_block_argument env x
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

let map_program (env : env) ((v1, v2, v3, v4) : CST.program) =
  let v1 =
    (match v1 with
    | Some tok -> R.Option (Some (
        (* leading_bom *) token env tok
      ))
    | None -> R.Option None)
  in
  let v2 =
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
    ) v2)
  in
  let v3 =
    (match v3 with
    | Some x -> R.Option (Some (
        map_param_block env x
      ))
    | None -> R.Option None)
  in
  let v4 =
    (match v4 with
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
  R.Tuple [v1; v2; v3; v4]

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
