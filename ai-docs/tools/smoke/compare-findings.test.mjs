import assert from 'node:assert/strict';
import test from 'node:test';
import { compareFindingSets } from '../validate.mjs';

const oldKey = 'rule\tsample.ps1\t10\t40', newKey = 'rule\tsample.ps1\t10\t20';
const sha256 = 'a'.repeat(64);
const review = { before: oldKey, after: newKey, source_sha256: sha256,
  reason: 'User-approved correction; Native confirms command extent 10:20.' };
const before = { findings: [oldKey], error_files: [] };
const now = { findings: [newKey], error_files: [] };
const sourceHashes = new Map([['sample.ps1', sha256]]);

test('an unreviewed extent change remains a removed and added finding', () => {
  const result = compareFindingSets(before, now);
  assert.deepEqual(result.removed, [oldKey]);
  assert.deepEqual(result.added, [newKey]);
  assert.deepEqual(result.reviewed_replacements, []);
});

test('only an exact approved replacement with unchanged source is accepted', () => {
  const result = compareFindingSets(before, now, [review], sourceHashes);
  assert.deepEqual(result.removed, []);
  assert.deepEqual(result.added, []);
  assert.deepEqual(result.reviewed_replacements, [review]);
});

test('other missing findings and new scan errors are still reported', () => {
  const other = 'other\tsample.ps1\t50\t60';
  const result = compareFindingSets(
    { ...before, findings: [...before.findings, other] },
    { ...now, error_files: ['sample.ps1'] }, [review], sourceHashes);
  assert.deepEqual(result.removed, [other]);
  assert.deepEqual(result.new_error_paths, ['sample.ps1']);
});

test('changed or missing source hashes reject the approval', () => {
  for (const hashes of [new Map(), new Map([['sample.ps1', 'b'.repeat(64)]])]) {
    assert.throws(() => compareFindingSets(before, now, [review], hashes), /original bytes/);
  }
});

test('rule, path and start cannot change under an extent review', () => {
  for (const after of ['other\tsample.ps1\t10\t20', 'rule\tother.ps1\t10\t20', 'rule\tsample.ps1\t11\t20']) {
    assert.throws(() => compareFindingSets(before, now, [{ ...review, after }], sourceHashes),
      /cannot change the rule, path or start/);
  }
});

test('a missing or unexpected replacement remains a failure', () => {
  for (const findings of [[], [oldKey], ['rule\tsample.ps1\t10\t21']]) {
    assert.throws(() => compareFindingSets(before, { ...now, findings }, [review], sourceHashes),
      /exact current finding/);
  }
});

test('an approval cannot be reused against a different baseline', () => {
  assert.throws(() => compareFindingSets(now, now, [review], sourceHashes), /exact baseline expectation/);
});

test('duplicate approvals and reviews without evidence are rejected', () => {
  assert.throws(() => compareFindingSets(before, now, [review, review], sourceHashes), /duplicate/);
  assert.throws(() => compareFindingSets(before, now, [{ ...review, reason: '' }], sourceHashes), /evidence/);
});
