// Native proof kit: compare the parser Opengrep uses with PowerShell's own parser
// on a list of cases, fact by fact, at exact byte offsets.
//
//   node ai-docs/tools/proof-kit.mjs CASES.json [--fork WORKTREE | --parser-dir DIR [--names TSV]]
//                                    [--out REPORT.json] [--known-pattern NAME] [--all]
//   node ai-docs/tools/proof-kit.mjs --source TEXT [--fork WORKTREE | --parser-dir DIR]
//   node ai-docs/tools/proof-kit.mjs --suites [DIR...] [--suite NAME[,NAME]] [--write-expectations]
//                                    [--fork ... | --parser-dir ...] [--out DIR]
//
// --source TEXT  one-off check of a snippet (quick classification while writing cases):
//                trailing-trivia on by default, every difference printed; the generated
//                cases file goes to local/results/proof-kit/adhoc/, never into a suite.
// --all          print every difference of a failing case, not just the first.
// --suite NAMES  restrict --suites to these suites, e.g. to record a new suite's
//                expectations without rewriting the others:
//                --suites --suite my-topic --write-expectations
//
// Suites (--suites): runs every SUITE.json in each DIR (default: ai-docs/cases and, when
// present, ai-docs/local/cases, reported separately) with --known-pattern trailing-trivia,
// and compares each with DIR/SUITE.expected.json: summary counts (informational) and, per
// case, its status and the sorted list (a multiset) of its remaining difference keys
// (unexpected differences and "stale known: ..." entries). The run fails (exit 1) on a
// difference not in the expectation, a status change that is not an improvement (fail ->
// known -> agree / invalid-rejected), a case without an expectation, an expected case that
// is gone, or a missing expectation file. A recorded difference that no longer occurs and
// a better status are reported as improvements (exit 0). Expectations are never updated
// automatically: --write-expectations rewrites every run suite's .expected.json from this
// run (a deliberate, reviewed step). Reports: local/results/proof-kit/suites-TIMESTAMP/.
//
// Paths come from config.mjs (optional ai-docs/local/config.json).
//
// Parser under test (always the simplified ABI 14 parser on the static tree-sitter
// 0.22.6 runtime from pkg-config, like corpus-probe and Opengrep's build):
//   default         this grammar repo's checked-in opengrep/ocaml/lib. Its grammar sources
//                   are regenerated (cached) for the node-name map; the fresh parser.c
//                   and scanner.c must be byte-identical to the checked-in ones.
//   --fork DIR      a parser worktree (fix branch): its ABI14 parser is built without
//                   Dune exactly as `validate.mjs quick` does (abi14-build.mjs).
//   --parser-dir D  prebuilt ABI14 sources, e.g. local/runs/NAME/compat-abi14/src from
//                   `validate.mjs quick --keep-scratch`; names from --names TSV or, in that
//                   layout, from D/grammar.json and D/../../compat-022/src/grammar.json.
// Builds are cached in local/proof-kit/parsers/ by the hash of every input.
// Tree-sitter nodes carry the unsimplified grammar's names (grammar-harness/abi14-names.mjs,
// ts-dump --tree), so the table below is stable across simplification.
// Native: PowerShell 7.6.7 Parser.ParseInput only (proof-kit-native.ps1), one process
// for all cases, local/native-home environment; the source is never evaluated.
//
// Output: REPORT.json (default local/results/proof-kit/CASES-TIMESTAMP.json, never overwritten)
// and a compact summary. Exit 0 = every case as expected; 1 = an unexpected difference,
// an expectation contradicted, a stale known entry, or a Native failure; 2 = usage,
// input or build error.
//
// CASES.json is an array of
//   { "name": unique string,
//     "source": text | "path": file (relative to CASES.json) | "path_bytes_base64": the same
//               as path, for a file name that is not UTF-8 (base64 of its bytes) |
//               "corpus_path": "BATCH/relative/path" under the corpus root (config.mjs); a
//               corpus case is skipped ("skipped: no corpus") when its batch folder is absent.
//               Give at most one file; with source too, the file's bytes must equal it,
//     "expect": "native" (default: Native decides validity) | "valid" | "invalid",
//     "facts":  families to compare (default all): validity, commands, elements, comments,
//               strings, typed, or typed:KIND for one typed row (e.g. typed:IfStatementAst),
//     "known":  [{ "difference": exact key printed by the kit, "reason": why it is expected }],
//     "known_patterns": [NAME, ...] (see Known patterns) }
// Other keys are ignored and listed in the report. A known entry only matches its exact
// key; it is reported under known differences, never applied to anything else, and one
// that matches nothing is stale (exit 1).
//
// Known patterns: named, narrowly checked classes of inherited differences, opt-in per
// case ("known_patterns") or for every case (--known-pattern NAME). Each accepted
// difference is listed under known differences with the pattern's reason and counted per
// pattern; a pattern declared on a case that matches nothing there is stale (exit 1).
//   trailing-trivia  a commands or typed `extent` difference with the same start where
//                    tree-sitter ends later and every extra byte is trivia: spaces, tabs,
//                    CR/LF, a backtick line continuation (` + newline), a # line comment
//                    or a <# #> block comment. Inherited grammar behaviour (e.g. the node
//                    before `|` or `# comment` includes the blank); anything else in the
//                    extra bytes (another statement, an escaped space) stays a difference.
//
// Bytes and encoding. Offsets are UTF-8 byte offsets of the file's bytes, which is what
// Opengrep's PowerShell frontend hands to tree-sitter: Parse_powershell_tree_sitter.parse
// -> Tree_sitter_powershell.Parse.file -> Tree_sitter_parsing.parse_source_file reads the
// file with Util_file.read_file (raw bytes, no decoding, no BOM removal) and
// octs_parser_parse_string passes them to ts_parser_parse_string. A UTF-8 BOM therefore
// reaches tree-sitter (the grammar's extras accept U+FEFF) and tree-sitter offsets count
// it. PowerShell's file reader drops the BOM, so the Native side decodes the bytes after
// it and adds 3 to every offset; a BOM case compares both parsers on the same original
// bytes. Native UTF-16 offsets become UTF-8 byte offsets of that text. Unsupported, never
// guessed (encoding work is deferred): bytes that are not strict UTF-8 (including UTF-16
// with a BOM), and NUL bytes, because the binding passes strlen(source) so tree-sitter
// would see only a prefix. Unsupported cases are reported, not compared; with
// "expect": "valid" or "invalid" they fail.
//
// Fact families (Native is the reference for every extent):
//   validity  Native syntax errors (TypeNotFound, ModuleNotFoundDuringParse and
//             ErrorLoadingAssembly depend on the environment and are only listed, as in
//             the grammar harness) versus ERROR/MISSING nodes (root has_error). Always
//             compared; for a Native-invalid case nothing else is compared, because
//             Native's partial AST is not a reference.
//   commands  every CommandAst versus every `command`, paired by start: exact extent,
//             and the invocation operator (& or .) versus command_invokation_operator.
//   elements  every CommandElements entry (redirections excluded): the name versus the
//             command_name field, the rest versus the units of command_elements (see
//             table). Elements of a command without a tree-sitter counterpart are missing;
//             the units of an extra `command` are extra.
//   comments  every Comment token (nested string tokens included) versus `comment`.
//   strings   every quoted StringConstantExpressionAst / ExpandableStringExpressionAst
//             (StringConstantType other than BareWord) versus the string node of its type.
//   typed     the rows of TYPED below, as multisets of exact extents.
// Every Native fact must match exactly; every unmatched tree-sitter node is a difference.
// Agreement counts are Native facts; known counts in the summary are differences.
//
// Difference keys (copy them into "known"; S:E are byte offsets, Kind a Native type,
// with /StringConstantType for strings, type a tree-sitter type or wrapper chain a>b>c):
//   validity native=valid ts=invalid | native=invalid ts=valid | native=valid ts=timeout |
//            expect=valid native=invalid | expect=invalid native=valid | expect=valid unsupported
//   commands missing S:E | extra S:E | extent S:E ts S:E | invocation S:E native & ts none
//   elements missing S:E Kind | extra S:E type | extent S:E Kind ts S:E | kind S:E Kind ts type |
//            items S:E native S:E,S:E ts S:E,S:E | extent S:E parameter ts S:E |
//            missing S:E Kind argument | missing/kind/extent S:E stop-parsing ...
//   comments missing S:E | extra S:E | extent S:E ts S:E
//   strings  missing S:E Type | extra S:E type | extent S:E Type ts S:E | kind S:E Type ts type
//   typed    missing Kind S:E | extra type S:E | extent Kind S:E ts S:E
// Case status: agree (Native-valid, no difference), invalid-rejected (both invalid), known
// (only known differences), unsupported, skipped (corpus absent), fail (unexpected
// difference, stale known entry, Native exception). Known entries on an unsupported case are stale.
//
// Native <-> tree-sitter mapping (tree-sitter side: unsimplified grammar names):
//   CommandAst                        command (extent includes command_invokation_operator)
//   InvocationOperator Ampersand/Dot  command_invokation_operator "&" / "."
//   CommandElements[0] (name)         the node in field command_name (command_name or
//                                     command_name_expr); kind per NAME_TYPES
//   other CommandElements             a unit of command_elements: its reported children,
//                                     skipping command_argument_sep (spaces and the colon
//                                     after a parameter), comment and redirection; kind per
//                                     ARGUMENT_TYPES, checked anywhere in the unit's chain of
//                                     single children with the same extent (wrappers such
//                                     as array_literal_expression > unary_expression)
//   ArrayLiteralAst (a,b)             one unit: an array_literal_expression node, or
//                                     adjacent nodes joined by "," tokens (hidden
//                                     _command_array_tail); item extents compared too
//   CommandParameterAst -P:value      two units: command_parameter at the Native start,
//                                     then the argument with exactly Native's argument extent
//                                     (the ":" is a command_argument_sep); Native's end must
//                                     be the argument's end; an array argument (-P:a,b) has
//                                     its item extents compared as for ArrayLiteralAst
//   "--%" + verbatim argument         one stop_parsing unit spanning both (opaque payload)
//   ParenExpressionAst argument       parenthesized_expression, or argument_list for an
//                                     inherited comma form like `cmd (1,2)` (prior proofs:
//                                     verify-command-parenthesis.mjs, verify-plus-command.mjs)
//   RedirectionAst                    redirection (typed family, not an element)
//   Comment token                     comment
//   SingleQuoted / DoubleQuoted       verbatim_string_characters / expandable_string_literal
//   ...HereString                     verbatim_here_string_characters / expandable_here_string_literal
//   quoted part of a bare word        none: `/opt:"a b"` or `-1'x'` is one Native BareWord; the
//                                     string node directly inside generic_token,
//                                     colon_command_argument, command_name or path_command_name
//                                     is not a strings fact (the elements family compares the word)
//   bare-word argument                generic_token, colon_command_argument, parameter_argument_word
//                                     (dash-leading value after `-P:`), parameter_dot_literal (the
//                                     `.` of `-P.$x`)
//   typed rows                        see TYPED; loop statements with a label (`:l foreach`)
//                                     include the preceding sibling `label` node, as
//                                     Native's extent includes the label
// An element kind missing from ARGUMENT_TYPES / NAME_TYPES is printed as a "kit limit"
// (its extent is still compared); extend the table rather than ignoring it.
import assert from 'node:assert/strict';
import { spawnSync, execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import {
  AI_DOCS, TOOLS, PARSER, ABI14_LIB, GENERATOR, ENV_SH, CORPUS, KIT, LOCAL, RESULTS, PWSH, PWSH_ARGS, PWSH_VERSION, CONFIG_FILE, nativeEnv, prepareLocal,
} from './config.mjs';
import { q, sh, buildAbi14, abi14NamesMap, tsDumpCommand, opengrepDir } from './abi14-build.mjs';

const FAMILIES = ['validity', 'commands', 'elements', 'comments', 'strings', 'typed'];
const EXPECT = ['native', 'valid', 'invalid'];
const CASE_KEYS = ['name', 'source', 'path', 'path_bytes_base64', 'corpus_path', 'expect', 'facts', 'known', 'known_patterns'];
// Spaces, tabs, CR/LF, backtick line continuations and comments; nothing else.
const TRIVIA = /^(?:[ \t\r\n]|`(?:\r\n|\r|\n)|#[^\r\n]*|<#[\s\S]*?#>)+$/;
const KNOWN_PATTERNS = {
  'trailing-trivia': {
    reason: 'inherited grammar: the tree-sitter node extends over trailing trivia that Native excludes',
    matches(difference, bytes) {
      if (!['commands', 'typed'].includes(difference.family)) return false;
      const m = difference.key.match(/ extent (?:\S+ )?(\d+):(\d+) ts (\d+):(\d+)$/);
      if (!m) return false;
      const [nativeStart, nativeEnd, tsStart, tsEnd] = m.slice(1).map(Number);
      return nativeStart === tsStart && tsEnd > nativeEnd && tsEnd <= bytes.length &&
        TRIVIA.test(bytes.subarray(nativeEnd, tsEnd).toString('latin1'));
    },
  },
};
// Every suite run (--suites) accepts this pattern; expectation files record it.
const SUITE_PATTERN = 'trailing-trivia';
const ENVIRONMENTAL = new Set(['TypeNotFound', 'ModuleNotFoundDuringParse', 'ErrorLoadingAssembly']);
const NATIVE_VERSION = PWSH_VERSION;
const WORK = KIT;

const STRING_TYPES = {
  SingleQuoted: 'verbatim_string_characters', DoubleQuoted: 'expandable_string_literal',
  SingleQuotedHereString: 'verbatim_here_string_characters', DoubleQuotedHereString: 'expandable_here_string_literal',
};
const STRING_NODES = new Set(Object.values(STRING_TYPES));
// Bare words; a quoted part inside one (`/opt:"a b"`) is part of a single Native BareWord.
const WORDS = new Set(['generic_token', 'colon_command_argument', 'command_name', 'path_command_name']);
const inWord = t => (t.parent?.type === 'string_literal' ? t.parent.parent : t.parent)?.type;
// Element kinds: Native kind (strings: kind/StringConstantType) -> accepted tree-sitter types.
const ARGUMENT_TYPES = {
  'StringConstantExpressionAst/BareWord': ['generic_token', 'colon_command_argument', 'parameter_argument_word', 'parameter_dot_literal'],
  'ExpandableStringExpressionAst/BareWord': ['generic_token'],
  ...Object.fromEntries(Object.entries(STRING_TYPES).map(([t, ts]) => [`StringConstantExpressionAst/${t}`, [ts]])),
  'ExpandableStringExpressionAst/DoubleQuoted': ['expandable_string_literal'],
  'ExpandableStringExpressionAst/DoubleQuotedHereString': ['expandable_here_string_literal'],
  ConstantExpressionAst: ['integer_literal', 'real_literal'],
  VariableExpressionAst: ['variable'],
  UsingExpressionAst: ['variable'],
  CommandParameterAst: ['command_parameter'],
  ParenExpressionAst: ['parenthesized_expression', 'argument_list'],
  SubExpressionAst: ['sub_expression'],
  ArrayExpressionAst: ['array_expression'],
  ScriptBlockExpressionAst: ['script_block_expression'],
  HashtableAst: ['hash_literal_expression'],
  MemberExpressionAst: ['member_access'],
  InvokeMemberExpressionAst: ['invokation_expression'],
  IndexExpressionAst: ['element_access'],
  TypeExpressionAst: ['type_literal'],
  ArrayLiteralAst: ['array_literal_expression'],
};
const NAME_TYPES = {
  ...ARGUMENT_TYPES,
  'StringConstantExpressionAst/BareWord': ['command_name', 'path_command_name'],
  'ExpandableStringExpressionAst/BareWord': ['command_name', 'path_command_name'],
};
const LOOPS = new Set(['foreach_statement', 'for_statement', 'while_statement', 'do_statement', 'switch_statement']);
// Typed rows: Native kinds -> tree-sitter types, compared as multisets of extents.
// Not selected, because the representations differ by design: ParamBlockAst (Native's
// extent starts at `param`, param_block includes the leading attributes), ArrayLiteralAst
// outside commands (comma lists nest differently), ConstantExpressionAst (command-mode
// `-1` is a Native bare word), and the many wrapper expressions.
const TYPED = [
  { kinds: ['AssignmentStatementAst'], types: ['assignment_expression'] },
  { kinds: ['IfStatementAst'], types: ['if_statement'] },
  { kinds: ['ForEachStatementAst'], types: ['foreach_statement'] },
  { kinds: ['ForStatementAst'], types: ['for_statement'] },
  { kinds: ['WhileStatementAst'], types: ['while_statement'] },
  { kinds: ['DoWhileStatementAst', 'DoUntilStatementAst'], types: ['do_statement'] },
  { kinds: ['SwitchStatementAst'], types: ['switch_statement'] },
  { kinds: ['TryStatementAst'], types: ['try_statement'] },
  { kinds: ['TrapStatementAst'], types: ['trap_statement'] },
  { kinds: ['DataStatementAst'], types: ['data_statement'] },
  // A class method's FunctionDefinitionAst is a class_method_definition (FunctionMemberAst).
  { kinds: ['FunctionDefinitionAst'], types: ['function_statement'], native: (n, parent) => parent?.kind !== 'FunctionMemberAst' },
  { kinds: ['TypeDefinitionAst'], types: ['class_statement', 'enum_statement'] },
  { kinds: ['HashtableAst'], types: ['hash_literal_expression'] },
  // `cmd (1,2)`: see the element table.
  { kinds: ['ParenExpressionAst'], types: ['parenthesized_expression', 'argument_list'],
    ts: (t, parent) => t.type !== 'argument_list' || parent?.type === 'command_elements' },
  { kinds: ['SubExpressionAst'], types: ['sub_expression'] },
  { kinds: ['ArrayExpressionAst'], types: ['array_expression'] },
  { kinds: ['ScriptBlockExpressionAst'], types: ['script_block_expression'] },
  { kinds: ['InvokeMemberExpressionAst'], types: ['invokation_expression'] },
  { kinds: ['MemberExpressionAst'], types: ['member_access'] },
  { kinds: ['IndexExpressionAst'], types: ['element_access'] },
  { kinds: ['TernaryExpressionAst'], types: ['ternary_expression'] },
  // A class property's name is PropertyMemberAst.Name, not a VariableExpressionAst.
  { kinds: ['VariableExpressionAst'], types: ['variable'], ts: (t, parent) => parent?.type !== 'class_property_definition' },
  { kinds: ['FileRedirectionAst', 'MergingRedirectionAst'], types: ['redirection'] },
];
const TYPED_KINDS = new Set(TYPED.flatMap(row => row.kinds));

const readJson = file => JSON.parse(fs.readFileSync(file, 'utf8'));
const sha256 = data => createHash('sha256').update(data).digest('hex');
const rel = file => path.relative(AI_DOCS, file);
const span = x => `${x.s}:${x.e}`;

class InputError extends Error {}

const FLAGS = ['suites', 'writeExpectations', 'all'];

function parseArgs(argv) {
  const opts = { positional: [] };
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg.startsWith('--')) {
      const key = arg.slice(2).replace(/-(\w)/g, (_, c) => c.toUpperCase());
      if (FLAGS.includes(key)) { opts[key] = true; continue; }
      if (i + 1 >= argv.length) throw new InputError(`${arg} needs a value`);
      opts[key] = argv[++i];
    } else opts.positional.push(arg);
  }
  for (const key of Object.keys(opts)) {
    if (!['positional', 'fork', 'parserDir', 'names', 'out', 'knownPattern', 'source', 'suite', ...FLAGS].includes(key)) throw new InputError(`unknown option --${key}`);
  }
  if (opts.knownPattern !== undefined && !KNOWN_PATTERNS[opts.knownPattern]) {
    throw new InputError(`unknown known pattern ${opts.knownPattern}; known: ${Object.keys(KNOWN_PATTERNS).join(', ')}`);
  }
  if (opts.writeExpectations && !opts.suites) throw new InputError('--write-expectations goes with --suites');
  if (opts.suite !== undefined && !opts.suites) throw new InputError('--suite goes with --suites');
  if (opts.source !== undefined) {
    if (opts.suites || opts.positional.length) throw new InputError('--source replaces CASES.json and --suites');
    opts.all = true;
    opts.knownPattern ??= SUITE_PATTERN;
  }
  if (opts.suites) {
    if (opts.knownPattern !== undefined && opts.knownPattern !== SUITE_PATTERN) {
      throw new InputError(`--suites always uses --known-pattern ${SUITE_PATTERN}`);
    }
    opts.knownPattern = SUITE_PATTERN;
  } else if (opts.source === undefined && opts.positional.length !== 1) {
    throw new InputError('usage: node ai-docs/tools/proof-kit.mjs CASES.json [--fork WORKTREE | --parser-dir DIR [--names TSV]] [--out REPORT.json] [--known-pattern NAME] [--all]\n' +
      '       node ai-docs/tools/proof-kit.mjs --source TEXT [--fork WORKTREE | --parser-dir DIR] [--known-pattern NAME]\n' +
      '       node ai-docs/tools/proof-kit.mjs --suites [DIR...] [--suite NAME[,NAME]] [--write-expectations] [--fork WORKTREE | --parser-dir DIR [--names TSV]] [--out DIR]');
  }
  if (opts.fork && opts.parserDir) throw new InputError('--fork and --parser-dir are exclusive');
  if (opts.names && !opts.parserDir) throw new InputError('--names goes with --parser-dir');
  return opts;
}

// ---------------------------------------------------------------- parser under test

function gitIdentity(dir) {
  try {
    const git = (...args) => execFileSync('git', ['-C', dir, ...args], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }).trim();
    // A plain folder inside another repository (e.g. a mutant under build/) must not borrow that repository's identity.
    const top = git('rev-parse', '--show-toplevel');
    if (fs.realpathSync(top) !== fs.realpathSync(dir)) return { path: dir, git: false, inside_repository: top };
    const status = git('status', '--porcelain');
    return { path: dir, head: git('rev-parse', '--short=9', 'HEAD'), branch: git('branch', '--show-current'), dirty: status !== '' };
  } catch {
    return { path: dir, git: false };
  }
}

function hashInputs(entries) {
  const hash = createHash('sha256');
  for (const [label, data] of entries) hash.update(`${label}\0${data.length}\0`).update(data);
  return hash.digest('hex').slice(0, 20);
}

const fileOrEmpty = file => fs.existsSync(file) ? fs.readFileSync(file) : Buffer.alloc(0);

function toolVersions() {
  const out = execFileSync('bash', ['-c', `${ENV_SH ? `source ${q(ENV_SH)}\n` : ''}tree-sitter --version\npkg-config --modversion tree-sitter`], { encoding: 'utf8' });
  const [cli, runtime] = out.trim().split('\n');
  assert.match(cli, /^tree-sitter 0\.22\.6\b/, `the build environment must provide tree-sitter CLI 0.22.6, got ${cli}`);
  assert.equal(runtime, '0.22.6', 'pkg-config tree-sitter must be the 0.22.6 runtime');
  return { cli, runtime };
}

// Build in a private folder and rename it into place, so concurrent kit runs share a cache entry safely.
async function cached(key, describe, build) {
  const dir = path.join(WORK, 'parsers', key);
  if (fs.existsSync(path.join(dir, 'ready.json'))) return { dir, cache: 'hit', ...readJson(path.join(dir, 'ready.json')) };
  const tmp = `${dir}.tmp-${process.pid}`;
  fs.rmSync(tmp, { recursive: true, force: true });
  fs.mkdirSync(tmp, { recursive: true });
  const fd = fs.openSync(path.join(tmp, 'build.log'), 'a');
  const run = (script, options) => sh(fd, script, options);
  const started = performance.now();
  try {
    const info = { ...describe, ...await build(tmp, run), build_s: +((performance.now() - started) / 1000).toFixed(1) };
    fs.writeFileSync(path.join(tmp, 'ready.json'), `${JSON.stringify(info, null, 2)}\n`);
    fs.closeSync(fd);
    try {
      fs.renameSync(tmp, dir);
    } catch (error) {
      if (!['ENOTEMPTY', 'EEXIST'].includes(error.code)) throw error;
      fs.rmSync(tmp, { recursive: true, force: true });
    }
  } catch (error) {
    fs.closeSync(fd);
    throw new InputError(`parser build failed (${error.message}); log: ${rel(path.join(tmp, 'build.log'))}`);
  }
  return { dir, cache: 'built', ...readJson(path.join(dir, 'ready.json')) };
}

// Paths in ready.json are relative to the cache entry, which is renamed after the build.
const inEntry = (entry, file) => path.join(entry.dir, file);

async function setupParser(opts) {
  const tools = toolVersions();
  const common = [['ts-dump.c', fileOrEmpty(path.join(TOOLS, 'grammar-harness/ts-dump.c'))],
    ['abi14-names.mjs', fileOrEmpty(path.join(TOOLS, 'grammar-harness/abi14-names.mjs'))],
    ['abi14-build.mjs', fileOrEmpty(path.join(TOOLS, 'abi14-build.mjs'))], ['tools', Buffer.from(JSON.stringify(tools))]];
  if (opts.parserDir) {
    const src = path.resolve(opts.parserDir);
    for (const file of ['parser.c', 'scanner.c']) {
      if (!fs.existsSync(path.join(src, file))) throw new InputError(`--parser-dir: no ${file} in ${src}`);
    }
    if (!/^#define LANGUAGE_VERSION 14$/m.test(fs.readFileSync(path.join(src, 'parser.c'), 'utf8'))) {
      throw new InputError(`--parser-dir: ${src}/parser.c is not an ABI 14 parser`);
    }
    const names = opts.names && path.resolve(opts.names);
    const grammars = [path.join(src, '../../compat-022/src/grammar.json'), path.join(src, 'grammar.json')];
    if (!names && !grammars.every(file => fs.existsSync(file))) {
      throw new InputError('--parser-dir: give --names TSV, or use a local/runs/NAME/compat-abi14/src folder');
    }
    const key = `dir-${hashInputs([...common, ['src', Buffer.from(src)],
      ...['parser.c', 'scanner.c', 'parameter_letters.h'].map(f => [f, fileOrEmpty(path.join(src, f))]),
      ...(names ? [['names', fs.readFileSync(names)]] : grammars.map(f => [f, fs.readFileSync(f)]))])}`;
    const entry = await cached(key, { mode: 'parser-dir', sources: src, tools }, async (dir, run) => {
      if (!names) await abi14NamesMap(run, grammars[0], grammars[1], path.join(dir, 'names.tsv'));
      else fs.copyFileSync(names, path.join(dir, 'names.tsv'));
      await run(tsDumpCommand(src, path.join(dir, 'ts-dump')));
      return { names_from: names ?? grammars };
    });
    return { ...entry, dump: inEntry(entry, 'ts-dump'), names: inEntry(entry, 'names.tsv'),
      parser_c_sha256: sha256(fs.readFileSync(path.join(src, 'parser.c'))) };
  }
  const checkedIn = !opts.fork;
  const fork = path.resolve(opts.fork ?? PARSER);
  if (!fs.existsSync(path.join(fork, 'grammar.js'))) throw new InputError(`not a parser worktree: ${fork}`);
  if (!GENERATOR) throw new InputError(`no Opengrep checkout (this repo is not a submodule); set opengrepRoot in ${CONFIG_FILE}`);
  if (!fs.existsSync(GENERATOR)) throw new InputError(`no ocaml-tree-sitter generator at ${GENERATOR}; build Opengrep once`);
  const key = `${checkedIn ? 'checked-in' : 'fork'}-${hashInputs([...common, ['fork', Buffer.from(fork)],
    ['grammar.js', fs.readFileSync(path.join(fork, 'grammar.js'))],
    ...['scanner.c', 'parameter_letters.h'].map(f => [f, fileOrEmpty(path.join(fork, 'src', f))]),
    ...['grammar.cjs', 'prepare-grammar.cjs'].map(f => [f, fs.readFileSync(path.join(opengrepDir(fork), f))]),
    ['generator', fs.readFileSync(GENERATOR)],
    ...(checkedIn ? ['parser.c', 'scanner.c'].map(f => [`checked-in ${f}`, fs.readFileSync(path.join(ABI14_LIB, f))]) : [])])}`;
  const entry = await cached(key, { mode: checkedIn ? 'checked-in' : 'fork', fork, tools }, async (dir, run) => {
    const built = await buildAbi14(run, fork, dir);
    await abi14NamesMap(run, built.unsimplified, built.simplified, path.join(dir, 'names.tsv'));
    let src = built.src;
    const matches = ['parser.c', 'scanner.c'].every(f => fs.readFileSync(path.join(src, f)).equals(fs.readFileSync(path.join(ABI14_LIB, f))));
    if (checkedIn) {
      if (!matches) {
        throw new Error('checked-in opengrep/ocaml/lib parser.c/scanner.c differ from a fresh generation of this repo\'s ' +
          `grammar sources; regenerate, or test the working tree with --fork ${fork}`);
      }
      src = ABI14_LIB;
    }
    await run(tsDumpCommand(src, path.join(dir, 'ts-dump')));
    // Keep the ABI14 sources (fork mode) and both grammar.json files (the names' evidence); drop rebuildable bulk.
    const bulk = ['compat-repo', 'ocaml-tree-sitter-gen.exe', 'compat-022/src/parser.c', ...(checkedIn ? ['compat-abi14/src/parser.c'] : [])];
    for (const name of bulk) fs.rmSync(path.join(dir, name), { recursive: true, force: true });
    return { sources: checkedIn ? src : path.relative(dir, src), matches_checked_in: matches };
  });
  const sources = path.isAbsolute(entry.sources) ? entry.sources : inEntry(entry, entry.sources);
  return { ...entry, sources, dump: inEntry(entry, 'ts-dump'), names: inEntry(entry, 'names.tsv'), fork_git: gitIdentity(fork),
    parser_c_sha256: sha256(fs.readFileSync(path.join(sources, 'parser.c'))) };
}

// ---------------------------------------------------------------- cases

function loadCases(file) {
  let cases;
  try {
    cases = readJson(file);
  } catch (error) {
    throw new InputError(`${file}: ${error.message}`);
  }
  if (!Array.isArray(cases) || !cases.length) throw new InputError(`${file}: expected a non-empty JSON array`);
  const base = path.dirname(file);
  const names = new Set();
  return cases.map((c, i) => {
    const where = `${file} case ${i}${c?.name ? ` (${c.name})` : ''}`;
    if (typeof c?.name !== 'string' || !c.name) throw new InputError(`${where}: name must be a non-empty string`);
    if (names.has(c.name)) throw new InputError(`${where}: duplicate name`);
    names.add(c.name);
    const expect = c.expect ?? 'native';
    if (!EXPECT.includes(expect)) throw new InputError(`${where}: expect must be one of ${EXPECT.join(', ')}`);
    let bytes;
    let origin = null;
    let skipped;
    const given = ['path', 'path_bytes_base64', 'corpus_path'].filter(key => c[key] !== undefined);
    if (given.length > 1) throw new InputError(`${where}: give only one of ${given.join(', ')}`);
    for (const key of given) if (typeof c[key] !== 'string' || !c[key]) throw new InputError(`${where}: ${key} must be a non-empty string`);
    if (c.path_bytes_base64 !== undefined) {
      const name = Buffer.from(c.path_bytes_base64, 'base64');
      // Resolved against the folder of CASES.json, as path is.
      origin = name[0] === 0x2f ? name : Buffer.concat([Buffer.from(`${base}/`), name]);
    } else if (c.corpus_path !== undefined) {
      const batch = c.corpus_path.split('/')[0];
      if (path.isAbsolute(c.corpus_path) || c.corpus_path.split('/').includes('..') || !batch) {
        throw new InputError(`${where}: corpus_path must be BATCH/relative/path`);
      }
      origin = path.join(CORPUS, c.corpus_path);
      if (!fs.existsSync(path.join(CORPUS, batch))) skipped = `no corpus (${batch} not in ${CORPUS})`;
    } else if (c.path !== undefined) origin = path.resolve(base, c.path);
    if (skipped) {
      // Not read: the case is reported as skipped.
    } else if (origin) {
      const shown = origin.toString();
      try {
        bytes = fs.readFileSync(origin);
      } catch (error) {
        throw new InputError(`${where}: cannot read ${shown} (${error.code ?? error.message})`);
      }
      if (c.source !== undefined && !bytes.equals(Buffer.from(c.source, 'utf8'))) {
        throw new InputError(`${where}: the bytes of ${shown} differ from its source`);
      }
    } else if (typeof c.source === 'string') {
      if (!c.source.isWellFormed()) throw new InputError(`${where}: source has a lone surrogate; use a path for such bytes`);
      bytes = Buffer.from(c.source, 'utf8');
    } else throw new InputError(`${where}: give source, path, path_bytes_base64 or corpus_path`);
    const facts = c.facts ?? FAMILIES;
    if (!Array.isArray(facts) || !facts.length) throw new InputError(`${where}: facts must be a non-empty array`);
    for (const fact of facts) {
      const [family, kind] = String(fact).split(':');
      if (!FAMILIES.includes(family) || (kind !== undefined && (family !== 'typed' || !TYPED_KINDS.has(kind)))) {
        throw new InputError(`${where}: unknown fact family ${fact}`);
      }
    }
    const known = c.known ?? [];
    if (!Array.isArray(known)) throw new InputError(`${where}: known must be an array`);
    for (const k of known) {
      if (typeof k?.difference !== 'string' || typeof k.reason !== 'string' || !k.reason.trim()) {
        throw new InputError(`${where}: each known entry needs a difference key and a non-empty reason`);
      }
    }
    if (new Set(known.map(k => k.difference)).size !== known.length) throw new InputError(`${where}: duplicate known entry`);
    const knownPatterns = c.known_patterns ?? [];
    if (!Array.isArray(knownPatterns) || knownPatterns.some(p => !KNOWN_PATTERNS[p]) || new Set(knownPatterns).size !== knownPatterns.length) {
      throw new InputError(`${where}: known_patterns must list distinct names from: ${Object.keys(KNOWN_PATTERNS).join(', ')}`);
    }
    return {
      name: c.name, expect, facts, known, knownPatterns, bytes, origin, skipped,
      ignored: Object.keys(c).filter(key => !CASE_KEYS.includes(key)),
    };
  });
}

function encodingProblem(bytes) {
  if (bytes.subarray(0, 2).equals(Buffer.from([0xff, 0xfe])) || bytes.subarray(0, 2).equals(Buffer.from([0xfe, 0xff]))) {
    return 'UTF-16 BOM (not UTF-8; encoding support is deferred)';
  }
  try {
    new TextDecoder('utf-8', { fatal: true }).decode(bytes);
  } catch {
    return 'not strict UTF-8 (encoding support is deferred)';
  }
  if (bytes.includes(0)) return 'NUL byte (Opengrep passes strlen(source) to tree-sitter, which would see only a prefix)';
  return null;
}

// ---------------------------------------------------------------- both parsers

function runNative(cases, dir) {
  const manifest = path.join(dir, `native-manifest-${process.pid}.json`);
  fs.writeFileSync(manifest, JSON.stringify(cases.map(c => ({ name: c.name, path: c.target }))));
  if (!fs.existsSync(PWSH)) throw new InputError(`missing ${PWSH}; run: node ai-docs/tools/setup.mjs`);
  const result = spawnSync(PWSH, [...PWSH_ARGS, '-File', path.join(TOOLS, 'proof-kit-native.ps1'),
    '-ManifestPath', manifest], { maxBuffer: 2e9, timeout: 600000, env: nativeEnv() });
  fs.rmSync(manifest, { force: true });
  if (result.status !== 0) {
    throw new InputError(`Native parser failed (${result.error?.message ?? `exit ${result.status}`}): ${result.stderr.toString().slice(0, 500)}`);
  }
  const lines = jsonLines(result.stdout);
  const { version } = lines.shift();
  if (version !== NATIVE_VERSION) throw new InputError(`expected PowerShell ${NATIVE_VERSION}, got ${version}`);
  if (lines.length !== cases.length) throw new InputError(`Native parser returned ${lines.length}/${cases.length} results`);
  return { version, results: lines };
}

function runTs(parser, cases) {
  const result = spawnSync(parser.dump, ['--tree'], {
    input: Buffer.concat(cases.map(c => Buffer.from(`${c.target}\0`))), maxBuffer: 2e9, timeout: 600000,
    env: { ...process.env, TS_DUMP_NAMES: parser.names },
  });
  if (result.status !== 0) {
    throw new InputError(`ts-dump failed (${result.error?.message ?? `exit ${result.status}`}): ${result.stderr.toString().slice(0, 500)}`);
  }
  const lines = jsonLines(result.stdout);
  if (lines.length !== cases.length) throw new InputError(`ts-dump returned ${lines.length}/${cases.length} results`);
  return lines;
}

// Parse JSON lines straight from a buffer: a whole corpus batch can exceed the maximum string length.
function jsonLines(buffer) {
  const lines = [];
  for (let start = 0; start < buffer.length;) {
    let end = buffer.indexOf(10, start);
    if (end < 0) end = buffer.length;
    if (end > start) {
      const text = buffer.toString('utf8', start, end).trim();
      if (text) lines.push(JSON.parse(text));
    }
    start = end + 1;
  }
  return lines;
}

// Both trees as node objects with parent links and ordered children.
function nativeTree(result) {
  const nodes = result.nodes.map(([kind, s, e, parent, extra], index) => ({ index, kind, s, e, parentIndex: parent, extra, children: [] }));
  for (const n of nodes) {
    n.parent = nodes[n.parentIndex] ?? null;
    n.parent?.children.push(n);
  }
  return nodes;
}

function tsTree(result) {
  const nodes = (result.n ?? []).map(([type, s, e, parent, flags, field], index) =>
    ({ index, type, s, e, parentIndex: parent, named: !!(flags & 1), error: !!(flags & 2), missing: !!(flags & 4), field, children: [] }));
  for (const n of nodes) {
    n.parent = nodes[n.parentIndex] ?? null;
    n.parent?.children.push(n);
  }
  return nodes;
}

// The node and its single children with the same extent (wrappers), outermost first.
function chain(node) {
  const out = [node];
  for (let n = node; n.children.length === 1 && n.children[0].s === node.s && n.children[0].e === node.e;) {
    n = n.children[0];
    out.push(n);
  }
  return out;
}

const kindKey = n => (n.kind === 'StringConstantExpressionAst' || n.kind === 'ExpandableStringExpressionAst') ? `${n.kind}/${n.extra}` : n.kind;

// ---------------------------------------------------------------- comparison

class Facts {
  constructor(text) {
    this.text = text;
    this.differences = [];
    this.counts = {};
    this.limits = [];
  }

  family(name) {
    return this.counts[name] ??= { native: 0, agree: 0 };
  }

  fact(family, ok) {
    const c = this.family(family);
    c.native++;
    if (ok) c.agree++;
  }

  differ(family, key, detail) {
    this.differences.push({ family, key: `${family} ${key}`, ...(detail ? { detail } : {}) });
  }

  snippet(s, e) {
    return s < 0 || e < s ? '' : JSON.stringify(this.text.subarray(s, Math.min(e, s + 60)).toString('utf8'));
  }
}

// Pair Native items with tree-sitter items by start (same end first); the rest are missing/extra.
function pairByStart(natives, tss) {
  const free = [...tss];
  const pairs = [];
  const missing = [];
  for (const n of natives) {
    let j = free.findIndex(t => t.s === n.s && t.e === n.e);
    if (j < 0) j = free.findIndex(t => t.s === n.s);
    if (j < 0) missing.push(n);
    else pairs.push([n, free.splice(j, 1)[0]]);
  }
  return { pairs, missing, extra: free };
}

function compareCommands(f, nNodes, tNodes, bytes) {
  const nCommands = nNodes.filter(n => n.kind === 'CommandAst');
  const tCommands = tNodes.filter(t => t.type === 'command');
  const { pairs, missing, extra } = pairByStart(nCommands, tCommands);
  for (const n of missing) f.differ('commands', `missing ${span(n)}`, f.snippet(n.s, n.e)), f.fact('commands', false);
  for (const t of extra) f.differ('commands', `extra ${span(t)}`, f.snippet(t.s, t.e));
  const operator = { Ampersand: '&', Dot: '.', Unknown: 'none' };
  for (const [n, t] of pairs) {
    let ok = true;
    if (n.e !== t.e) {
      f.differ('commands', `extent ${span(n)} ts ${span(t)}`, `${f.snippet(n.s, n.e)} vs ${f.snippet(t.s, t.e)}`);
      ok = false;
    }
    const invocation = t.children.find(c => c.type === 'command_invokation_operator');
    const tsOperator = invocation ? bytes.subarray(invocation.s, invocation.e).toString('utf8') : 'none';
    if ((operator[n.extra] ?? n.extra) !== tsOperator) {
      f.differ('commands', `invocation ${span(n)} native ${operator[n.extra] ?? n.extra} ts ${tsOperator}`);
      ok = false;
    }
    f.fact('commands', ok);
  }
  return { pairs, missing, extra };
}

// Units of command_elements: element nodes, comma groups, stop_parsing.
function tsUnits(elements) {
  const units = [];
  let join = false;
  for (const c of elements?.children ?? []) {
    if (c.type === 'command_argument_sep' || c.type === 'redirection' || c.type === 'comment') continue;
    if (c.type === ',') { join = units.length > 0; continue; }
    if (join) {
      const last = units.at(-1);
      last.e = c.e;
      last.items.push(c);
    } else units.push({ s: c.s, e: c.e, node: c, items: [c] });
    join = false;
  }
  return units;
}

function unitTypes(unit) {
  if (unit.items.length > 1) return [','];
  return chain(unit.node).map(n => n.type);
}

function unitItems(unit) {
  if (unit.items.length > 1) return unit.items;
  const array = chain(unit.node).find(n => n.type === 'array_literal_expression' && n.children.some(c => c.type === ','));
  return array ? array.children.filter(c => c.type !== ',') : null;
}

function checkKind(f, n, unit, table) {
  const accepted = table[kindKey(n)];
  const types = unitTypes(unit);
  if (!accepted) {
    f.limits.push(`elements: no kind mapping for ${kindKey(n)} at ${span(n)} (ts ${types.join('>')}); extent compared only`);
    return true;
  }
  const isArray = kindKey(n) === 'ArrayLiteralAst';
  if (types.some(t => accepted.includes(t)) || (isArray && types.includes(','))) return true;
  f.differ('elements', `kind ${span(n)} ${kindKey(n)} ts ${types.join('>')}`, f.snippet(n.s, n.e));
  return false;
}

const commandElements = command => command.children.filter(c => !c.kind.endsWith('RedirectionAst'));

// Item extents of an ArrayLiteralAst element (also when it is the argument of -Name:a,b).
function compareItems(f, n, unit) {
  const want = n.children.map(span).join(',');
  const items = unitItems(unit);
  const have = items ? items.map(span).join(',') : 'none';
  if (want === have) return true;
  f.differ('elements', `items ${span(n)} native ${want} ts ${have}`, f.snippet(n.s, n.e));
  return false;
}

function compareElements(f, { pairs, missing, extra }, bytes) {
  // Elements of unpaired commands are facts too, so an elements-only selection misses nothing.
  for (const command of missing) {
    for (const n of commandElements(command)) {
      f.differ('elements', `missing ${span(n)} ${kindKey(n)}`, f.snippet(n.s, n.e));
      f.fact('elements', false);
    }
  }
  for (const tCommand of extra) {
    const tName = tCommand.children.find(c => c.field === 'command_name');
    const units = tsUnits(tCommand.children.find(c => c.field === 'command_elements'));
    for (const unit of [...(tName ? [{ s: tName.s, e: tName.e, node: tName, items: [tName] }] : []), ...units]) {
      f.differ('elements', `extra ${span(unit)} ${unitTypes(unit).join('>')}`, f.snippet(unit.s, unit.e));
    }
  }
  for (const [command, tCommand] of pairs) {
    const elements = commandElements(command);
    if (!elements.length) continue;
    const [name, ...rest] = elements;
    const tName = tCommand.children.find(c => c.field === 'command_name');
    if (!tName) {
      f.differ('elements', `missing ${span(name)} ${kindKey(name)}`, f.snippet(name.s, name.e));
      f.fact('elements', false);
    } else {
      let ok = true;
      if (tName.s !== name.s || tName.e !== name.e) {
        f.differ('elements', `extent ${span(name)} ${kindKey(name)} ts ${span(tName)}`, f.snippet(name.s, name.e));
        ok = false;
      }
      f.fact('elements', checkKind(f, name, { s: tName.s, e: tName.e, node: tName, items: [tName] }, NAME_TYPES) && ok);
    }
    const units = tsUnits(tCommand.children.find(c => c.field === 'command_elements'));
    const free = new Set(units);
    const take = (s, e) => {
      let unit = units.find(u => free.has(u) && u.s === s && u.e === e) ?? units.find(u => free.has(u) && u.s === s);
      if (unit) free.delete(unit);
      return unit;
    };
    for (let i = 0; i < rest.length; i++) {
      const n = rest[i];
      if (n.kind === 'StringConstantExpressionAst' && n.extra === 'BareWord' && bytes.subarray(n.s, n.e).toString('latin1') === '--%') {
        // --% and its verbatim argument form one opaque stop_parsing unit.
        const end = rest.at(-1).e;
        const unit = take(n.s, end);
        let ok = !!unit;
        if (!unit) f.differ('elements', `missing ${n.s}:${end} stop-parsing`, f.snippet(n.s, end));
        else if (unit.node.type !== 'stop_parsing' || unit.items.length > 1) {
          f.differ('elements', `kind ${n.s}:${end} stop-parsing ts ${unitTypes(unit).join('>')}`);
          ok = false;
        } else if (unit.e !== end) {
          f.differ('elements', `extent ${n.s}:${end} stop-parsing ts ${span(unit)}`);
          ok = false;
        }
        for (let j = i; j < rest.length; j++) f.fact('elements', ok);
        break;
      }
      const argument = n.kind === 'CommandParameterAst' ? n.children[0] : null;
      const unit = take(n.s, argument ? null : n.e);
      if (!unit) {
        f.differ('elements', `missing ${span(n)} ${kindKey(n)}`, f.snippet(n.s, n.e));
        f.fact('elements', false);
        continue;
      }
      let ok = true;
      if (argument) {
        // -Name:value is a command_parameter unit and an argument unit with Native's argument extent.
        ok = checkKind(f, n, unit, ARGUMENT_TYPES);
        const value = take(argument.s, argument.e);
        if (unit.e > argument.s) {
          f.differ('elements', `extent ${span(n)} parameter ts ${span(unit)}`, f.snippet(n.s, n.e));
          ok = false;
        }
        if (!value) {
          f.differ('elements', `missing ${span(argument)} ${kindKey(argument)} argument`, f.snippet(argument.s, argument.e));
          ok = false;
        } else {
          if (value.e !== argument.e) {
            f.differ('elements', `extent ${span(argument)} ${kindKey(argument)} ts ${span(value)}`, f.snippet(argument.s, argument.e));
            ok = false;
          }
          ok = checkKind(f, argument, value, ARGUMENT_TYPES) && ok;
          if (argument.kind === 'ArrayLiteralAst' && value.e === argument.e) ok = compareItems(f, argument, value) && ok;
        }
        assert.equal(argument.e, n.e, 'Native parameter extent ends with its argument');
      } else {
        if (unit.e !== n.e) {
          f.differ('elements', `extent ${span(n)} ${kindKey(n)} ts ${span(unit)}`, f.snippet(n.s, n.e));
          ok = false;
        }
        ok = checkKind(f, n, unit, ARGUMENT_TYPES) && ok;
        if (n.kind === 'ArrayLiteralAst' && unit.e === n.e) ok = compareItems(f, n, unit) && ok;
      }
      f.fact('elements', ok);
    }
    for (const unit of free) f.differ('elements', `extra ${span(unit)} ${unitTypes(unit).join('>')}`, f.snippet(unit.s, unit.e));
  }
}

function compareComments(f, native, tNodes) {
  const comments = native.comments.map(([s, e]) => ({ s, e }));
  const { pairs, missing, extra } = pairByStart(comments, tNodes.filter(t => t.type === 'comment'));
  for (const n of missing) f.differ('comments', `missing ${span(n)}`, f.snippet(n.s, n.e)), f.fact('comments', false);
  for (const t of extra) f.differ('comments', `extra ${span(t)}`, f.snippet(t.s, t.e));
  for (const [n, t] of pairs) {
    if (n.e !== t.e) f.differ('comments', `extent ${span(n)} ts ${span(t)}`, f.snippet(n.s, n.e));
    f.fact('comments', n.e === t.e);
  }
}

function compareStrings(f, nNodes, tNodes) {
  const strings = nNodes.filter(n => (n.kind === 'StringConstantExpressionAst' || n.kind === 'ExpandableStringExpressionAst') &&
    n.extra !== 'BareWord');
  const { pairs, missing, extra } = pairByStart(strings, tNodes.filter(t => STRING_NODES.has(t.type) && !WORDS.has(inWord(t))));
  for (const n of missing) f.differ('strings', `missing ${span(n)} ${n.extra}`, f.snippet(n.s, n.e)), f.fact('strings', false);
  for (const t of extra) f.differ('strings', `extra ${span(t)} ${t.type}`, f.snippet(t.s, t.e));
  for (const [n, t] of pairs) {
    let ok = true;
    if (n.e !== t.e) {
      f.differ('strings', `extent ${span(n)} ${n.extra} ts ${span(t)}`, f.snippet(n.s, n.e));
      ok = false;
    }
    if (STRING_TYPES[n.extra] !== t.type) {
      f.differ('strings', `kind ${span(n)} ${n.extra} ts ${t.type}`, f.snippet(n.s, n.e));
      ok = false;
    }
    f.fact('strings', ok);
  }
}

function typedExtent(t) {
  if (!LOOPS.has(t.type) || !t.parent) return t;
  const siblings = t.parent.children;
  const before = siblings[siblings.indexOf(t) - 1];
  return before?.type === 'label' ? { ...t, s: before.s } : t;
}

function compareTyped(f, nNodes, tNodes, selected) {
  for (const row of TYPED) {
    if (!selected.has('typed') && !row.kinds.some(kind => selected.has(`typed:${kind}`))) continue;
    const natives = nNodes.filter(n => row.kinds.includes(n.kind) && (!row.native || row.native(n, n.parent)));
    const tss = tNodes.filter(t => row.types.includes(t.type) && (!row.ts || row.ts(t, t.parent))).map(typedExtent);
    const { pairs, missing, extra } = pairByStart(natives, tss);
    for (const n of missing) f.differ('typed', `missing ${n.kind} ${span(n)}`, f.snippet(n.s, n.e)), f.fact('typed', false);
    for (const t of extra) f.differ('typed', `extra ${t.type} ${span(t)}`, f.snippet(t.s, t.e));
    for (const [n, t] of pairs) {
      if (n.e !== t.e) f.differ('typed', `extent ${n.kind} ${span(n)} ts ${span(t)}`, f.snippet(n.s, n.e));
      f.fact('typed', n.e === t.e);
    }
  }
}

function compareCase(c, native, ts) {
  const f = new Facts(c.bytes);
  const selected = new Set(c.facts);
  const families = new Set(c.facts.map(fact => fact.split(':')[0]));
  const errors = native.err.map(([id, s, e, message]) => ({ id, s, e, message }));
  const syntax = errors.filter(e => !ENVIRONMENTAL.has(e.id));
  const nativeValid = syntax.length === 0;
  const tNodes = tsTree(ts);
  const tsState = ts.st === 'ok' ? 'valid' : ts.st === 'error' ? 'invalid' : ts.st;
  const errorNodes = tNodes.filter(t => t.error || t.missing).slice(0, 20).map(t => [t.error ? 'ERROR' : `MISSING ${t.type}`, t.s, t.e]);
  const outcome = {
    native: { valid: nativeValid, bom: native.bom, errors: syntax, environmental_errors: errors.filter(e => ENVIRONMENTAL.has(e.id)) },
    ts: { status: tsState, ms: ts.ms, error_nodes: errorNodes },
  };
  const nativeState = nativeValid ? 'valid' : 'invalid';
  const nativeErrors = syntax.map(e => `${e.id}@${e.s}`).join(' ');
  if (c.expect !== 'native' && c.expect !== nativeState) f.differ('validity', `expect=${c.expect} native=${nativeState}`, nativeErrors);
  if (nativeState !== tsState) {
    f.differ('validity', `native=${nativeState} ts=${tsState}`,
      nativeValid ? errorNodes.map(([what, s, e]) => `${what}@${s}:${e}`).join(' ') : nativeErrors);
  }
  f.fact('validity', nativeState === tsState && (c.expect === 'native' || c.expect === nativeState));
  if (nativeValid) {
    const nNodes = nativeTree(native);
    const commands = families.has('commands') || families.has('elements')
      ? compareCommands(f, nNodes, tNodes, c.bytes) : { pairs: [], missing: [], extra: [] };
    if (!families.has('commands')) {
      f.differences = f.differences.filter(d => d.family !== 'commands');
      delete f.counts.commands;
    }
    if (families.has('elements')) compareElements(f, commands, c.bytes);
    if (families.has('comments')) compareComments(f, native, tNodes);
    if (families.has('strings')) compareStrings(f, nNodes, tNodes);
    if (families.has('typed')) compareTyped(f, nNodes, tNodes, selected);
  }
  const position = d => Number(d.key.match(/ (\d+):\d+/)?.[1] ?? -1);
  f.differences.sort((a, b) => FAMILIES.indexOf(a.family) - FAMILIES.indexOf(b.family) || position(a) - position(b));
  return { f, outcome, nativeValid, tsState };
}

// ---------------------------------------------------------------- driver

function summarize(report, elapsed, all = false) {
  const s = report.summary;
  const lines = [
    `proof-kit ${report.cases_file}: ${s.result.toUpperCase()} in ${elapsed.toFixed(1)}s`,
    `parser: ${report.parser.description}; Native PowerShell ${report.native.version} Parser.ParseInput`,
    `cases ${s.cases}: ${s.valid_exact} valid exact agreements, ${s.invalid_rejections} invalid rejections, ` +
      `${s.with_known} agreeing with known differences, ${s.failed} failed, ${s.unsupported} unsupported` +
      `${s.skipped ? `, ${s.skipped} skipped (no corpus)` : ''}`,
    `facts agreed / Native facts: ${FAMILIES.map(name => `${name} ${s.families[name].agree}/${s.families[name].native}` +
      `${s.families[name].known ? ` (${s.families[name].known} known)` : ''}`).join(', ')}`,
    `known differences ${s.known_differences} in ${s.cases_with_known_differences} cases; stale known entries ${s.stale_known}` +
      `${Object.keys(s.known_patterns.accepted).length ? `; accepted by pattern: ${Object.entries(s.known_patterns.accepted)
        .map(([name, n]) => `${name} ${n}`).join(', ')}` : ''}`,
  ];
  for (const c of report.cases) {
    if (c.status === 'unsupported') lines.push(`UNSUPPORTED ${c.name}: ${c.unsupported}`);
    if (c.status === 'skipped') lines.push(`SKIPPED ${c.name}: ${c.skipped}`);
    if (c.status !== 'fail') continue;
    const first = c.unexpected[0];
    const more = c.unexpected.length - 1 + c.stale_known.length;
    lines.push(`MISMATCH ${c.name}: ${first ? `${first.key}${first.detail ? ` [${first.detail}]` : ''}` : `stale known: ${c.stale_known[0]}`}` +
      `${more > 0 && !all ? ` (+${more} more)` : ''}`);
    if (all) {
      for (const d of c.unexpected.slice(1)) lines.push(`  ${d.key}${d.detail ? ` [${d.detail}]` : ''}`);
      for (const key of first ? c.stale_known : c.stale_known.slice(1)) lines.push(`  stale known: ${key}`);
    }
  }
  for (const limit of s.kit_limits) lines.push(`kit limit: ${limit}`);
  lines.push(`report: ${rel(report.path)}`);
  return lines.join('\n');
}

// Default report names: timestamp plus process id, so back-to-back runs never collide.
const stampNow = () => `${new Date().toISOString().replace(/[-:]/g, '').replace(/\..*/, '')}-${process.pid}`;

async function main() {
  const started = performance.now();
  const opts = parseArgs(process.argv.slice(2));
  if (opts.suites) return runSuites(opts);
  if (opts.source !== undefined) {
    // A one-off case: written to local/, never into the committed suites.
    prepareLocal();
    const adhoc = path.join(RESULTS, 'proof-kit', 'adhoc');
    fs.mkdirSync(adhoc, { recursive: true });
    opts.positional = [path.join(adhoc, `source-${stampNow()}.json`)];
    fs.writeFileSync(opts.positional[0], JSON.stringify([{ name: 'source', source: opts.source }]));
  }
  const casesFile = path.resolve(opts.positional[0]);
  const cases = loadCases(casesFile);
  const out = path.resolve(opts.out ?? path.join(RESULTS, 'proof-kit', `${path.basename(casesFile, '.json')}-${stampNow()}.json`));
  if (fs.existsSync(out)) throw new InputError(`${out} exists; choose another --out`);
  prepareLocal();
  const parser = await setupParser(opts);
  const report = await runCases(casesFile, cases, parser, opts, out, started);
  console.log(summarize(report, (performance.now() - started) / 1000, opts.all));
  return report.summary.result === 'pass' ? 0 : 1;
}

// Runs one cases file with a prepared parser and writes its report to OUT.
async function runCases(casesFile, cases, parser, opts, out, started) {
  const inputs = path.join(WORK, 'inputs');
  fs.mkdirSync(inputs, { recursive: true });
  for (const c of cases.filter(c => !c.skipped)) {
    c.sha256 = sha256(c.bytes);
    c.unsupported = encodingProblem(c.bytes);
    if (Buffer.isBuffer(c.origin)) {
      // A non-UTF-8 file name reaches both parsers through a local alias (never a copy).
      c.target = path.join(inputs, `alias-${c.sha256}${path.extname(c.origin.toString('latin1')).toLowerCase()}`);
      try {
        fs.symlinkSync(c.origin, c.target);
      } catch (error) {
        if (error.code !== 'EEXIST') throw error;
        if (!fs.readlinkSync(c.target, { encoding: 'buffer' }).equals(c.origin)) {
          fs.rmSync(c.target);
          fs.symlinkSync(c.origin, c.target);
        }
      }
    } else if (c.origin) c.target = c.origin;
    else {
      c.target = path.join(inputs, `${c.sha256}.ps1`);
      // Write and rename, so a concurrent kit run never parses a partly written input.
      if (!fs.existsSync(c.target) || !fs.readFileSync(c.target).equals(c.bytes)) {
        const tmp = `${c.target}.${process.pid}.tmp`;
        fs.writeFileSync(tmp, c.bytes);
        fs.renameSync(tmp, c.target);
      }
    }
  }
  const supported = cases.filter(c => !c.skipped && !c.unsupported);
  const native = supported.length ? runNative(supported, inputs) : { version: NATIVE_VERSION, results: [] };
  const ts = supported.length ? runTs(parser, supported) : [];
  supported.forEach((c, i) => { c.native = native.results[i]; c.ts = ts[i]; });

  const families = Object.fromEntries(FAMILIES.map(name => [name, { native: 0, agree: 0, differences: 0, known: 0 }]));
  const patternCounts = {};
  const kitLimits = new Set();
  const results = cases.map(c => {
    const base = { name: c.name, path: c.origin?.toString() ?? null, sha256: c.sha256, bytes: c.bytes?.length, expect: c.expect, facts: c.facts,
      ignored_keys: c.ignored };
    if (c.skipped) return { ...base, status: 'skipped', skipped: c.skipped, unexpected: [], known: [], stale_known: [] };
    // Nothing is compared for these, so a known entry cannot match: it is stale.
    const uncompared = (status, unexpected, extra) => {
      const stale = [...c.known.map(k => k.difference), ...c.knownPatterns.map(name => `known pattern ${name}`)];
      return { ...base, status: unexpected.length || stale.length ? 'fail' : status, ...extra, unexpected, known: [], stale_known: stale };
    };
    if (c.unsupported) {
      return uncompared('unsupported', c.expect === 'native' ? []
        : [{ family: 'validity', key: `validity expect=${c.expect} unsupported`, detail: c.unsupported }], { unsupported: c.unsupported });
    }
    if (c.native.st !== 'ok') {
      return uncompared('fail', [{ family: 'validity', key: `validity native=${c.native.st}`, detail: c.native.msg }]);
    }
    const { f, outcome, nativeValid } = compareCase(c, c.native, c.ts);
    const knownKeys = new Map(c.known.map(k => [k.difference, k.reason]));
    const patterns = [...new Set([...(opts.knownPattern ? [opts.knownPattern] : []), ...c.knownPatterns])];
    const used = new Set();
    const usedPatterns = new Set();
    const unexpected = [];
    const known = [];
    for (const d of f.differences) {
      const pattern = knownKeys.has(d.key) ? null : patterns.find(name => KNOWN_PATTERNS[name].matches(d, c.bytes));
      if (knownKeys.has(d.key)) { known.push({ ...d, reason: knownKeys.get(d.key) }); used.add(d.key); }
      else if (pattern) {
        known.push({ ...d, pattern, reason: `known pattern ${pattern}: ${KNOWN_PATTERNS[pattern].reason}` });
        usedPatterns.add(pattern);
        patternCounts[pattern] = (patternCounts[pattern] ?? 0) + 1;
      } else unexpected.push(d);
      families[d.family].differences++;
      if (knownKeys.has(d.key) || pattern) families[d.family].known++;
    }
    for (const [name, count] of Object.entries(f.counts)) {
      families[name].native += count.native;
      families[name].agree += count.agree;
    }
    for (const limit of f.limits) kitLimits.add(limit.replace(/ at \d+:\d+.*/, ''));
    const stale = [...c.known.map(k => k.difference).filter(key => !used.has(key)),
      ...c.knownPatterns.filter(name => !usedPatterns.has(name)).map(name => `known pattern ${name}`)];
    const status = unexpected.length || stale.length ? 'fail' : known.length ? 'known' : nativeValid ? 'agree' : 'invalid-rejected';
    return { ...base, status, ...outcome, counts: f.counts, first_difference: f.differences[0]?.key ?? null,
      unexpected, known, stale_known: stale, kit_limits: f.limits };
  });
  const count = status => results.filter(r => r.status === status).length;
  const report = {
    tool: 'proof-kit.mjs', created_at: new Date().toISOString(), path: out,
    cases_file: path.relative(process.cwd(), casesFile) || casesFile, cases_sha256: sha256(fs.readFileSync(casesFile)),
    parser: {
      mode: parser.mode, sources: parser.sources, parser_c_sha256: parser.parser_c_sha256, names: parser.names,
      fork: parser.fork_git, matches_checked_in: parser.matches_checked_in, tools: parser.tools, cache: parser.cache, build_dir: rel(parser.dir),
      runtime: `tree-sitter ${parser.tools.runtime} (pkg-config, static libtree-sitter.a)`,
      description: parser.mode === 'parser-dir' ? `ABI14 sources ${parser.sources} on tree-sitter ${parser.tools.runtime}`
        : `${parser.mode === 'checked-in' ? `checked-in opengrep/ocaml/lib of ${parser.fork}` : `fork ${parser.fork}`} ` +
          `(${parser.fork_git.git === false ? 'not a git worktree' : parser.fork_git.head ?? '?'}` +
          `${parser.fork_git.branch ? ` ${parser.fork_git.branch}` : ''}${parser.fork_git.dirty ? ', dirty' : ''}` +
          `${parser.mode === 'checked-in' ? ', = fresh ABI14 generation' : ''}) on tree-sitter ${parser.tools.runtime}`,
    },
    native: { version: native.version, api: 'System.Management.Automation.Language.Parser.ParseInput', helper: 'proof-kit-native.ps1' },
    encoding_policy: 'UTF-8 byte offsets of the original file bytes, as Opengrep passes them to tree-sitter (BOM included); ' +
      'Native parses the text after a UTF-8 BOM and its offsets are shifted by 3; non-UTF-8 and NUL bytes are unsupported',
    summary: {
      result: results.some(r => r.status === 'fail') ? 'fail' : 'pass',
      cases: results.length, valid_exact: count('agree'), invalid_rejections: count('invalid-rejected'), with_known: count('known'),
      failed: count('fail'), unsupported: count('unsupported'), skipped: count('skipped'),
      known_differences: results.reduce((a, r) => a + r.known.length, 0),
      cases_with_known_differences: results.filter(r => r.known.length).length,
      known_patterns: { cli: opts.knownPattern ?? null, accepted: patternCounts },
      stale_known: results.reduce((a, r) => a + r.stale_known.length, 0),
      families, kit_limits: [...kitLimits], elapsed_s: +((performance.now() - started) / 1000).toFixed(2),
    },
    cases: results,
  };
  fs.mkdirSync(path.dirname(out), { recursive: true });
  fs.writeFileSync(out, `${JSON.stringify(report, null, 1)}\n`);
  return report;
}

// ---------------------------------------------------------------- suites

// agree and invalid-rejected are equally good; any other status change is not an improvement.
const STATUS_RANK = { agree: 0, 'invalid-rejected': 0, known: 1, fail: 2 };

// What an expectation file records of a suite report.
function expectation(suite, report) {
  const s = report.summary;
  const cases = {};
  for (const c of report.cases) {
    cases[c.name] = { status: c.status, differences: [...c.unexpected.map(d => d.key), ...c.stale_known.map(k => `stale known: ${k}`)].sort() };
  }
  return {
    suite, known_pattern: SUITE_PATTERN,
    summary: { cases: s.cases, agree: s.valid_exact, invalid_rejected: s.invalid_rejections, known: s.with_known, fail: s.failed,
      unsupported: s.unsupported, skipped: s.skipped, known_differences: s.known_differences },
    cases,
  };
}

// One case per line, so a reviewed update shows exactly which cases changed.
function formatExpectation(e) {
  const caseLines = Object.entries(e.cases).map(([name, c]) => `  ${JSON.stringify(name)}: ${JSON.stringify(c)}`);
  return `{\n "suite": ${JSON.stringify(e.suite)},\n "known_pattern": ${JSON.stringify(e.known_pattern)},\n` +
    ` "summary": ${JSON.stringify(e.summary)},\n "cases": {\n${caseLines.join(',\n')}\n }\n}\n`;
}

// Compares a suite's result with its expectation: new differences, worse statuses and
// unexpected/missing cases fail; disappeared differences and better statuses are improvements.
function compareExpectation(expected, actual) {
  const failures = [];
  const improvements = [];
  if (expected.known_pattern !== actual.known_pattern) failures.push(`known pattern ${expected.known_pattern} expected, run used ${actual.known_pattern}`);
  for (const [name, a] of Object.entries(actual.cases)) {
    const e = expected.cases[name];
    if (!e) { failures.push(`${name}: no expectation for this case`); continue; }
    if (a.status === 'skipped') continue;
    if (a.status !== e.status) {
      const better = a.status in STATUS_RANK && e.status in STATUS_RANK && STATUS_RANK[a.status] < STATUS_RANK[e.status];
      (better ? improvements : failures).push(`${name}: status ${e.status} -> ${a.status}`);
    }
    // Multisets: a key that occurs once more than expected is a new difference.
    const left = [...e.differences];
    for (const key of a.differences) {
      const i = left.indexOf(key);
      if (i < 0) failures.push(`${name}: new difference ${key}`);
      else left.splice(i, 1);
    }
    for (const key of left) improvements.push(`${name}: difference gone ${key}`);
  }
  for (const name of Object.keys(expected.cases)) if (!actual.cases[name]) failures.push(`${name}: expected case is missing from the suite`);
  return { failures, improvements };
}

async function runSuites(opts) {
  const started = performance.now();
  const dirs = opts.positional.length ? opts.positional.map(d => path.resolve(d))
    : [path.join(AI_DOCS, 'cases'), path.join(LOCAL, 'cases')].filter(d => fs.existsSync(d));
  const suites = [];
  for (const dir of dirs) {
    if (!fs.statSync(dir, { throwIfNoEntry: false })?.isDirectory()) throw new InputError(`not a suites folder: ${dir}`);
    for (const file of fs.readdirSync(dir).filter(f => f.endsWith('.json') && !f.endsWith('.expected.json')).sort()) {
      const casesFile = path.join(dir, file);
      suites.push({ dir, name: path.basename(file, '.json'), casesFile, cases: loadCases(casesFile) });
    }
  }
  if (opts.suite !== undefined) {
    const wanted = opts.suite.split(',');
    const missing = wanted.filter(name => !suites.some(s => s.name === name));
    if (missing.length) throw new InputError(`no such suite: ${missing.join(', ')}`);
    suites.splice(0, suites.length, ...suites.filter(s => wanted.includes(s.name)));
  }
  if (!suites.length) throw new InputError(`no suites in ${dirs.join(', ') || 'ai-docs/cases'}`);
  const outDir = path.resolve(opts.out ?? path.join(RESULTS, 'proof-kit', `suites-${stampNow()}`));
  if (fs.existsSync(outDir)) throw new InputError(`${outDir} exists; choose another --out`);
  prepareLocal();
  const parser = await setupParser(opts);
  for (const dir of dirs) fs.mkdirSync(path.join(outDir, `${dirs.indexOf(dir)}-${path.basename(path.dirname(dir))}`), { recursive: true });
  const lines = [];
  const results = [];
  let lastDir;
  for (const suite of suites) {
    if (suite.dir !== lastDir) { lines.push(`${rel(suite.dir) || suite.dir}:`); lastDir = suite.dir; }
    const report = await runCases(suite.casesFile, suite.cases, parser, opts, path.join(outDir, `${dirs.indexOf(suite.dir)}-${path.basename(path.dirname(suite.dir))}`, `${suite.name}.json`), performance.now());
    const actual = expectation(suite.name, report);
    const s = actual.summary;
    const counts = `${s.cases} cases: agree ${s.agree}, invalid-rejected ${s.invalid_rejected}, known ${s.known}, fail ${s.fail}` +
      `${s.unsupported ? `, unsupported ${s.unsupported}` : ''}${s.skipped ? `, skipped ${s.skipped} (no corpus)` : ''}`;
    const expectedFile = path.join(suite.dir, `${suite.name}.expected.json`);
    if (opts.writeExpectations) {
      fs.writeFileSync(expectedFile, formatExpectation(actual));
      lines.push(`  WROTE ${suite.name}: ${counts}`);
      results.push({ suite: suite.name, dir: suite.dir, result: 'written', summary: s });
      continue;
    }
    const { failures, improvements } = fs.existsSync(expectedFile)
      ? compareExpectation(readJson(expectedFile), actual)
      : { failures: [`no ${rel(expectedFile)}; review the suite, then record it with --write-expectations`], improvements: [] };
    const result = failures.length ? 'fail' : 'pass';
    results.push({ suite: suite.name, dir: suite.dir, result, summary: s, failures, improvements });
    lines.push(`  ${result.toUpperCase()} ${suite.name}: ${counts}` +
      `${failures.length ? `; ${failures.length} unexpected` : ''}${improvements.length ? `; ${improvements.length} improvements` : ''}`);
    for (const f of failures.slice(0, 10)) lines.push(`    UNEXPECTED ${f}`);
    if (failures.length > 10) lines.push(`    ... ${failures.length - 10} more`);
    for (const i of improvements.slice(0, 10)) lines.push(`    IMPROVED ${i}`);
    if (improvements.length > 10) lines.push(`    ... ${improvements.length - 10} more`);
  }
  const failed = results.filter(r => r.result === 'fail').length;
  const improved = results.filter(r => r.improvements?.length).length;
  const verdict = opts.writeExpectations ? `WROTE ${results.length} expectation files` :
    `${failed ? 'FAIL' : 'PASS'}: ${results.length - failed}/${results.length} suites match their expectations` +
    `${improved ? `; ${improved} with improvements (record them deliberately with --write-expectations)` : ''}`;
  const summaryFile = path.join(outDir, 'summary.json');
  fs.writeFileSync(summaryFile, `${JSON.stringify({ tool: 'proof-kit.mjs --suites', created_at: new Date().toISOString(),
    parser: parser.mode, known_pattern: SUITE_PATTERN, verdict, suites: results }, null, 1)}\n`);
  console.log([`proof-kit --suites: parser ${parser.mode}${opts.fork ? ` ${opts.fork}` : ''}; known pattern ${SUITE_PATTERN}; ` +
    `${((performance.now() - started) / 1000).toFixed(1)}s`, ...lines, verdict, `reports: ${rel(outDir)}`].join('\n'));
  return failed ? 1 : 0;
}

try {
  process.exitCode = await main();
} catch (error) {
  console.error(`proof-kit: ${error instanceof InputError || error instanceof assert.AssertionError ? error.message : error.stack}`);
  process.exitCode = 2;
}
