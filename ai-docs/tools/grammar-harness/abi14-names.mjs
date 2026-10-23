// Derive how each node of the simplified ABI14 parser (the one Opengrep uses)
// appears in the unsimplified grammar's tree, so ts-dump can report ABI14
// trees with root node names (TS_DUMP_NAMES=FILE).
//
// usage: node abi14-names.mjs UNSIMPLIFIED_GRAMMAR_JSON SIMPLIFIED_GRAMMAR_JSON OUTPUT_TSV
//
// ocaml-tree-sitter `simplify` changes names, not parsing:
//   - hidden rules `_x` become visible `x` (`x_` if `x` is taken; lowercased);
//   - aliases are removed: the node keeps the aliased rule's own name;
//   - patterns and token() inside rules get named aliases (pat_*, tok_*, ...)
//     so that they appear in the tree; the root parser hides them;
//   - extras used inside rules are aliased as `x_explicit`.
// Both grammar.json files are walked in parallel; any other difference throws,
// so a structural change in simplify cannot be mapped silently.
//
// Output lines: PARENT \t CHILD \t RESULT, with PARENT `*` for the default.
//   CHILD  ABI14 node type; a leading " marks an anonymous node.
//   RESULT `-` hidden in the root tree (report its children instead),
//          `=NAME` named node NAME, `"TEXT` anonymous node TEXT.
// Every ABI14 symbol has a `*` line; context lines exist only where an alias in
// that parent rule overrides the default.
import assert from 'node:assert/strict';
import fs from 'node:fs';

const [unsimplifiedFile, simplifiedFile, output] = process.argv.slice(2);
assert.ok(output, 'usage: node abi14-names.mjs UNSIMPLIFIED_GRAMMAR_JSON SIMPLIFIED_GRAMMAR_JSON OUTPUT_TSV');
const U = JSON.parse(fs.readFileSync(unsimplifiedFile, 'utf8'));
const S = JSON.parse(fs.readFileSync(simplifiedFile, 'utf8'));
const HIDDEN = '-';
const named = name => `=${name}`;
const anonymous = text => `"${text}`;
const visibility = name => name.startsWith('_') ? HIDDEN : named(name);

// simplify translates rules first, in order, then appends its own rules.
const translate = new Map();
const uRules = Object.keys(U.rules);
const sRules = Object.keys(S.rules);
uRules.forEach((name, i) => translate.set(name, sRules[i]));
assert.equal(U.externals.length, S.externals.length, 'externals differ in length');
U.externals.forEach((external, i) => {
  if (external.type === 'SYMBOL') translate.set(external.name, S.externals[i].name);
});
for (const [from, to] of translate) {
  const preferred = from.replace(/^_+/, '').toLowerCase() || 'x';
  assert.ok(to === preferred || (to?.startsWith(preferred) && /^_+$/.test(to.slice(preferred.length))),
    `unexpected simplified name for ${from}: ${to}`);
}
const extras = new Set(U.extras.filter(x => x.type === 'SYMBOL').map(x => x.name));

const defaults = new Map();
const contexts = new Map();
const setDefault = (child, result) => {
  assert.ok(!defaults.has(child) || defaults.get(child) === result, `conflicting default for ${child}`);
  defaults.set(child, result);
};
const ambiguous = [];
function record(parent, child, result) {
  const key = `${parent}\t${child}`;
  const previous = contexts.get(key);
  if (previous !== undefined && previous !== result) ambiguous.push(`${key}: ${previous} / ${result}`);
  contexts.set(key, result);
}

function tokenDefault(rule) {
  // token('x') keeps the literal's anonymous node; other tokens are hidden.
  let content = rule.content;
  while (content?.type?.startsWith('PREC')) content = content.content;
  return rule.type !== 'PATTERN' && content?.type === 'STRING' ? anonymous(content.value) : HIDDEN;
}

function walk(u, s, parent, alias, top = false) {
  const where = `${parent}: ${JSON.stringify(u).slice(0, 120)}`;
  switch (u.type) {
    case 'ALIAS':
      assert.ok(alias === undefined, `nested alias in ${where}`);
      return walk(u.content, s, parent, u.named ? named(u.value) : anonymous(u.value));
    case 'SYMBOL': {
      const expected = translate.get(u.name);
      assert.ok(expected, `unknown symbol in ${where}`);
      let child = expected;
      if (extras.has(u.name)) {
        assert.ok(s.type === 'ALIAS' && s.named && s.content.type === 'SYMBOL' && s.content.name === expected,
          `extra not aliased as expected in ${where}`);
        child = s.value;
        setDefault(child, visibility(u.name));
      } else {
        assert.ok(s.type === 'SYMBOL' && s.name === expected, `symbol mismatch in ${where}`);
      }
      record(parent, child, alias ?? visibility(u.name));
      return;
    }
    case 'PATTERN':
    case 'TOKEN':
    case 'IMMEDIATE_TOKEN':
      if (top) {
        assert.ok(alias === undefined && s.type === u.type, `top-level token changed in ${where}`);
        return;
      }
      assert.ok(s.type === 'ALIAS' && s.named && s.content.type === u.type, `token not named as expected in ${where}`);
      setDefault(s.value, tokenDefault(u));
      record(parent, s.value, alias ?? tokenDefault(u));
      return;
    case 'STRING':
      assert.ok(s.type === 'STRING' && s.value === u.value, `string mismatch in ${where}`);
      record(parent, `"${u.value}`, alias ?? anonymous(u.value));
      return;
    case 'BLANK':
      assert.equal(s.type, 'BLANK', `blank mismatch in ${where}`);
      return;
    case 'SEQ':
    case 'CHOICE':
      // An alias of a composite would name a node that simplify cannot keep.
      assert.ok(alias === undefined, `alias of ${u.type} in ${where}`);
      assert.ok(s.type === u.type && s.members.length === u.members.length, `${u.type} mismatch in ${where}`);
      u.members.forEach((member, i) => walk(member, s.members[i], parent, undefined));
      return;
    case 'REPEAT':
    case 'REPEAT1':
      assert.ok(alias === undefined, `alias of ${u.type} in ${where}`);
      assert.equal(s.type, u.type, `${u.type} mismatch in ${where}`);
      return walk(u.content, s.content, parent, undefined);
    case 'PREC':
    case 'PREC_LEFT':
    case 'PREC_RIGHT':
    case 'PREC_DYNAMIC':
      assert.ok(s.type === u.type && JSON.stringify(s.value) === JSON.stringify(u.value), `precedence mismatch in ${where}`);
      return walk(u.content, s.content, parent, alias);
    case 'FIELD':
      assert.ok(s.type === 'FIELD' && s.name === u.name, `field mismatch in ${where}`);
      return walk(u.content, s.content, parent, alias);
    default:
      throw new Error(`unsupported rule type in ${where}`);
  }
}

for (const name of [...uRules, ...U.externals.filter(x => x.type === 'SYMBOL').map(x => x.name)]) {
  setDefault(translate.get(name), visibility(name));
}
for (const name of uRules) walk(U.rules[name], S.rules[translate.get(name)], translate.get(name), undefined, true);
assert.deepEqual(ambiguous, [], 'an ABI14 node has two root names in the same parent rule');

const lines = [...defaults].map(([child, result]) => `*\t${child}\t${result}`);
for (const [key, result] of contexts) {
  const child = key.split('\t')[1];
  if (result !== (child.startsWith('"') ? child : defaults.get(child))) lines.push(`${key}\t${result}`);
}
fs.writeFileSync(output, `${lines.sort().join('\n')}\n`);
console.log(`${defaults.size} ABI14 symbols, ${[...defaults.values()].filter(r => r === HIDDEN).length} hidden in the root tree, ` +
  `${lines.length - defaults.size} alias contexts`);
