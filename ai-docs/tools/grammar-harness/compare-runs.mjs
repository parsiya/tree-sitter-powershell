// Compare two harness result folders file by file.
// usage: node compare-runs.mjs BEFORE AFTER [GROUP_SUBSTRING]
// Exits 1 if any file got worse: agree -> not agree, or more problems than
// before in the same category.
import fs from 'node:fs';

const [beforeDir, afterDir, focus] = process.argv.slice(2);
const load = dir => new Map(fs.readFileSync(`${dir}/files.jsonl`, 'utf8').trim().split('\n')
  .map(JSON.parse).map(r => [r.sha256, r]));
const before = load(beforeDir);
const after = load(afterDir);
const rank = { agree: 0, disagree: 1, rejected: 2 };
const moves = {};
const worse = [];
const changed = [];
for (const [sha, b] of before) {
  const a = after.get(sha);
  if (!a) continue;
  if (b.category !== a.category) {
    const key = `${b.category} -> ${a.category}`;
    moves[key] = (moves[key] ?? 0) + b.copies;
  }
  const keys = r => r.problems.map(p => `${p.kind}: ${p.detail}@${p.offset}`);
  const beforeKeys = new Set(keys(b));
  const added = keys(a).filter(k => !beforeKeys.has(k));
  const gotWorse = (rank[a.category] ?? 9) > (rank[b.category] ?? 9) ||
    (a.category === b.category && a.category === 'disagree' && added.length > 0);
  if (gotWorse) worse.push({ path: b.path, before: b.category, after: a.category, added: added.slice(0, 3) });
  else if (a.category === b.category && a.category === 'rejected' &&
    JSON.stringify(a.problems) !== JSON.stringify(b.problems)) {
    changed.push({ path: b.path, before: b.problems[0], after: a.problems[0] });
  }
}
const summary = file => JSON.parse(fs.readFileSync(`${file}/summary.json`, 'utf8'));
const groupFiles = (s, text) => s.groups.filter(g => g.key.includes(text)).reduce((n, g) => n + g.files, 0);
console.log('before', JSON.stringify(summary(beforeDir).categories));
console.log('after ', JSON.stringify(summary(afterDir).categories));
console.log('moves ', JSON.stringify(moves));
if (focus) console.log(`group "${focus}": ${groupFiles(summary(beforeDir), focus)} -> ${groupFiles(summary(afterDir), focus)} files`);
console.log(`rejected files whose first error moved: ${changed.length}`);
for (const c of changed.slice(0, 10)) console.log('  ', c.path, c.before.offset, '->', c.after.offset, c.after.detail);
console.log(`worse: ${worse.length}`);
for (const w of worse.slice(0, 20)) console.log('  ', JSON.stringify(w));
process.exit(worse.length ? 1 : 0);
