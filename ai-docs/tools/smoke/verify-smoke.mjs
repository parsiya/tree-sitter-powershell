// Verify one CLI smoke scan of a corpus batch (validate.mjs full, stage smoke).
//
// usage: node verify-smoke.mjs OUTPUT BATCH_DIRECTORY CORPUS_FILES_JSONL RULES_YAML
//
// OUTPUT holds targets.nul (NUL-separated original file names), results.json and
// exit-code.txt of `opengrep scan --json`. Checks:
//   - exit code 0, no skipped rules, every target scanned;
//   - every finding comes from a rule of RULES_YAML and its bytes start with the command
//     its pattern starts with; start/end and every capture's start/end are valid byte
//     offsets of the original bytes whose line/col agree; captures lie inside the finding;
//     the file's SHA-256 equals the corpus inventory's;
//   - every file with a scan error is an encoding_review or grammar_error file of
//     CORPUS_FILES_JSONL (this run's corpus layer).
// Writes OUTPUT/summary.json and OUTPUT/keys.json (finding keys "rule<TAB>path<TAB>start<TAB>end"
// and error files, with paths relative to the batch), which validate.mjs compares with the baseline.
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';

const [output, batchArg, inventoryFile, rulesFile] = process.argv.slice(2);
assert.ok(output && batchArg && inventoryFile && rulesFile,
  'usage: node verify-smoke.mjs OUTPUT BATCH_DIRECTORY CORPUS_FILES_JSONL RULES_YAML');
const batch = path.resolve(batchArg);
const ERROR_CATEGORIES = ['encoding_review', 'grammar_error'];

const ruleText = fs.readFileSync(rulesFile, 'utf8');
const ids = [...ruleText.matchAll(/^\s*- id: (\S+)\s*$/gm)].map(m => m[1]);
const patterns = [...ruleText.matchAll(/^\s*pattern: (\S+)/gm)].map(m => m[1].toLowerCase());
assert.ok(ids.length && ids.length === patterns.length, `${rulesFile}: expected one "pattern: COMMAND ..." per rule`);
const commands = new Map(ids.map((id, i) => [id, patterns[i]]));

const inventory = new Map(fs.readFileSync(inventoryFile, 'utf8').trim().split('\n').map(line => {
  const row = JSON.parse(line);
  return [row.path, row];
}));
const targetBytes = fs.readFileSync(path.join(output, 'targets.nul'));
const targets = new Map();
let start = 0;
for (let i = 0; i < targetBytes.length; i++) {
  if (targetBytes[i] !== 0) continue;
  const raw = targetBytes.subarray(start, i);
  const decoded = raw.toString('utf8');
  assert.ok(!targets.has(decoded), `ambiguous decoded filename: ${decoded}`);
  targets.set(decoded, raw);
  start = i + 1;
}
assert.equal(start, targetBytes.length, 'targets.nul must end with NUL');
assert.equal(targets.size, inventory.size, 'targets must be every readable PowerShell file of the batch');

const report = JSON.parse(fs.readFileSync(path.join(output, 'results.json'), 'utf8'));
assert.equal(fs.readFileSync(path.join(output, 'exit-code.txt'), 'utf8').trim(), '0');
assert.deepEqual(report.skipped_rules, []);
assert.deepEqual(new Set(report.paths.scanned), new Set(targets.keys()), 'scanned paths differ from the targets');

const relative = file => path.relative(batch, file);
const row = file => {
  const found = inventory.get(relative(file));
  assert.ok(found, `not in the corpus inventory: ${file}`);
  return found;
};

const errorFiles = new Map();
for (const error of report.errors) {
  assert.ok(typeof error.path === 'string', `scan error without a file: ${JSON.stringify(error).slice(0, 300)}`);
  const prior = row(error.path);
  assert.ok(ERROR_CATEGORIES.includes(prior.category),
    `scan error in a file the corpus layer classifies as ${prior.category}: ${error.path}`);
  const type = typeof error.type === 'string' ? error.type : error.type[0];
  errorFiles.set(relative(error.path), { path: relative(error.path), type, category: prior.category, encoding: prior.encoding });
}

const contents = new Map();
function content(file) {
  if (contents.has(file)) return contents.get(file);
  const raw = targets.get(file);
  assert.ok(raw, `finding outside the targets: ${file}`);
  const bytes = fs.readFileSync(raw);
  const prior = row(file);
  assert.equal(createHash('sha256').update(bytes).digest('hex'), prior.sha256, `corpus content changed: ${file}`);
  const lines = [0];
  for (let i = 0; i < bytes.length; i++) if (bytes[i] === 10) lines.push(i + 1);
  const result = { bytes, lines, encoding: prior.encoding };
  contents.set(file, result);
  return result;
}
function checkPosition(position, source, label) {
  assert.ok(Number.isInteger(position.offset), label);
  assert.ok(position.offset >= 0 && position.offset <= source.bytes.length, label);
  assert.ok(position.line >= 1 && position.line <= source.lines.length, label);
  assert.equal(source.lines[position.line - 1] + position.col - 1, position.offset, label);
}

const keys = [];
const byRule = {};
const byEncoding = {};
let captures = 0;
for (const finding of report.results) {
  // Opengrep prefixes rule ids with the config file's location.
  const id = finding.check_id.split('.').at(-1);
  const command = commands.get(id);
  assert.ok(command, `finding from an unknown rule: ${finding.check_id}`);
  const source = content(finding.path);
  const where = `${finding.path}:${finding.start.offset}`;
  checkPosition(finding.start, source, `finding start ${where}`);
  checkPosition(finding.end, source, `finding end ${where}`);
  assert.ok(finding.end.offset > finding.start.offset, where);
  const text = source.bytes.subarray(finding.start.offset, finding.end.offset).toString('utf8');
  assert.equal(text.match(/^[^\s(]+/u)?.[0].replace(/[`'"]/g, '').toLowerCase(), command, where);
  for (const value of Object.values(finding.extra.metavars)) {
    checkPosition(value.start, source, `capture start ${where}`);
    checkPosition(value.end, source, `capture end ${where}`);
    assert.ok(value.start.offset >= finding.start.offset, where);
    assert.ok(value.end.offset >= value.start.offset, where);
    assert.ok(value.end.offset <= finding.end.offset, where);
    captures++;
  }
  byRule[id] = (byRule[id] ?? 0) + 1;
  byEncoding[source.encoding] = (byEncoding[source.encoding] ?? 0) + 1;
  keys.push(`${id}\t${relative(finding.path)}\t${finding.start.offset}\t${finding.end.offset}`);
}
assert.ok(report.results.length > 0, 'the scan must match real source');

const summary = {
  batch, rules: [...commands.keys()], targets: targets.size, findings: report.results.length,
  findings_by_rule: byRule, findings_by_encoding: byEncoding, matching_files: contents.size,
  validated_finding_byte_ranges: report.results.length, validated_capture_byte_ranges: captures,
  error_files: [...errorFiles.values()],
  caveats: [
    'Pattern scanning can prefilter irrelevant files; this is not a parse-all certification.',
    'Partial parsing can miss findings in affected files.',
    'Metavariable abstract_content is normalized, not original source; byte ranges were checked independently.',
    'Corpus source was read only, never executed, copied or chmodded.',
  ],
};
fs.writeFileSync(path.join(output, 'summary.json'), `${JSON.stringify(summary, null, 2)}\n`);
fs.writeFileSync(path.join(output, 'keys.json'),
  `${JSON.stringify({ findings: keys.sort(), error_files: [...errorFiles.keys()].sort() }, null, 1)}\n`);
console.log(JSON.stringify({ ...summary, caveats: undefined }, null, 2));
