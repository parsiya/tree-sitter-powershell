import assert from 'node:assert/strict';
import path from 'node:path';
import test from 'node:test';
import { compactOutput, suiteDirectories } from './proof-kit.mjs';

test('short proof output is unchanged', () => {
  assert.equal(compactOutput(['PASS', 'report: result.json']), 'PASS\nreport: result.json');
});

test('large console output is bounded without losing verdict or report path', () => {
  const lines = ['proof-kit FAIL', ...Array(100).fill('detail '.repeat(100)), 'FAIL: 1 unexpected', 'reports: complete.json'];
  const output = compactOutput(lines);
  assert.ok(Buffer.byteLength(output) <= 6000);
  assert.match(output, /detail lines omitted/);
  assert.ok(output.endsWith('FAIL: 1 unexpected\nreports: complete.json'));
  assert.equal(compactOutput(lines, true), lines.join('\n'));
});

test('console limit counts UTF-8 bytes, including oversized individual lines', () => {
  const output = compactOutput(['FAIL', '\u03b1'.repeat(10000), 'FAIL: 1 unexpected', 'reports: complete.json']);
  assert.ok(Buffer.byteLength(output) <= 6000);
  assert.match(output, /FAIL: 1 unexpected/);
});

test('fork suites default to that worktree, not the parent checkout', () => {
  const fork = path.resolve('example-worktree');
  assert.equal(suiteDirectories({ positional: [], fork })[0], path.join(fork, 'ai-docs/cases'));
});

test('explicit suite directories override defaults', () => {
  assert.deepEqual(suiteDirectories({ positional: ['chosen-cases'], fork: 'ignored' }),
    [path.resolve('chosen-cases')]);
});
