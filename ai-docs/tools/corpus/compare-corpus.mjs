import assert from 'node:assert/strict';
import * as fs from 'node:fs/promises';
import path from 'node:path';

// usage: node compare-corpus.mjs [--allow-grammar-changes] BEFORE_DIRECTORY AFTER_DIRECTORY
// Compares two corpus-baseline.mjs result folders of the same batch; writes AFTER/comparison.json.
// --allow-grammar-changes: for a grammar update, count grammar result changes
// instead of failing on them. Regressions of clean files still fail.
const args = process.argv.slice(2);
const allowGrammarChanges = args.includes('--allow-grammar-changes');
const [beforeArg, afterArg] = args.filter(arg => !arg.startsWith('--'));
assert.ok(beforeArg && afterArg,
  'usage: node compare-corpus.mjs [--allow-grammar-changes] BEFORE_DIRECTORY AFTER_DIRECTORY');
const beforeDirectory = path.resolve(beforeArg);
const afterDirectory = path.resolve(afterArg);
const load = async directory => (await fs.readFile(path.join(directory, 'files.jsonl'), 'utf8'))
  .trim().split('\n').map(JSON.parse);
const [before, after] = await Promise.all([load(beforeDirectory), load(afterDirectory)]);
assert.equal(before.length, after.length, 'Selected file counts changed');
const key = file => file.path_bytes_base64 ?? file.path;
const byPath = new Map(after.map(file => [key(file), file]));
assert.equal(byPath.size, after.length, 'Duplicate original paths');
const transitions = {};
const blockers = {};
const regressions = [];
const grammarTransitions = {};
let grammarUnchanged = true;
for (const old of before) {
  const file = byPath.get(key(old));
  assert.ok(file, `Missing file: ${old.path}`);
  for (const field of ['sha256', 'bytes', 'encoding']) assert.equal(file[field], old[field]);
  const grammarChanged = ['status', 'errors', 'missing'].some(field => file.grammar[field] !== old.grammar[field]) ||
    JSON.stringify(file.grammar.samples) !== JSON.stringify(old.grammar.samples);
  if (grammarChanged) {
    assert.ok(allowGrammarChanges, `Grammar changed: ${old.path}`);
    grammarUnchanged = false;
    const transition = `${old.grammar.status} -> ${file.grammar.status}`;
    grammarTransitions[transition] = (grammarTransitions[transition] ?? 0) + 1;
  }
  const transition = `${old.category} -> ${file.category}`;
  transitions[transition] = (transitions[transition] ?? 0) + 1;
  if (old.category === 'ok' && file.category !== 'ok') regressions.push(file.path);
  if (file.category === 'unsupported_conversion') {
    const prefix = 'Unsupported PowerShell syntax: ';
    const start = file.exception.indexOf(prefix);
    const end = file.exception.indexOf(`, ${file.stats.name}:`, start);
    assert.ok(start >= 0 && end > start, `Unrecognized diagnostic: ${file.exception}`);
    const label = file.exception.slice(start + prefix.length, end);
    blockers[label] = (blockers[label] ?? 0) + 1;
  }
}
const report = {
  before: beforeDirectory, after: afterDirectory, compared_files: before.length,
  grammar_unchanged: grammarUnchanged, grammar_transitions: grammarTransitions, transitions, regressions,
  grammar_accepted_blockers: Object.fromEntries(Object.entries(blockers).sort((a, b) => b[1] - a[1])),
};
const output = path.join(afterDirectory, 'comparison.json');
await fs.writeFile(output, `${JSON.stringify(report, null, 2)}\n`);
console.log(JSON.stringify(report, null, 2));
assert.equal(regressions.length, 0, 'Previously successful inputs regressed');
