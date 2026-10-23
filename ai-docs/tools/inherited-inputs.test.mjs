import assert from 'node:assert/strict';
import test from 'node:test';
import { compareInheritedInputs } from './inherited-inputs.mjs';

const fixture = (name, source, tree = '(program (path_command_name))') =>
  `===\n${name}\n===\n\n${source}\n\n---\n\n${tree}\n`;
const original = fixture('member command', '. $item.Path');

test('allows correcting an inherited expected tree without changing its input', () => {
  const corrected = fixture('member command', '. $item.Path', '(program (member_access))');
  assert.deepEqual(compareInheritedInputs(original, corrected), { total: 1, changed: [] });
});

test('allows correcting a mistaken expected error', () => {
  const before = fixture('valid command', 'Write-Output ok', '(ERROR)');
  const after = fixture('valid command', 'Write-Output ok', '(program (command))');
  assert.deepEqual(compareInheritedInputs(before, after), { total: 1, changed: [] });
});

test('allows adding cases and reordering preserved cases', () => {
  const extra = fixture('neighbour', '& $item.Path');
  assert.deepEqual(compareInheritedInputs(original, extra + original), { total: 1, changed: [] });
  assert.deepEqual(compareInheritedInputs(original + extra, extra + original), { total: 2, changed: [] });
});

test('rejects modifying the original source', () => {
  const changed = fixture('member command', '. "$item.Path"');
  assert.deepEqual(compareInheritedInputs(original, changed).changed, ['member command']);
});

test('rejects deleting or renaming an inherited case', () => {
  assert.deepEqual(compareInheritedInputs(original, '').changed, ['member command']);
  assert.deepEqual(compareInheritedInputs(original, fixture('renamed', '. $item.Path')).changed,
    ['member command']);
});

test('rejects replacing a case with a skipped test', () => {
  const skipped = original.replace('member command\n', 'member command\n:skip\n');
  assert.deepEqual(compareInheritedInputs(original, skipped).changed, ['member command']);
});

test('preserves duplicate case coverage', () => {
  assert.deepEqual(compareInheritedInputs(original + original, original),
    { total: 2, changed: ['member command'] });
});

test('preserves original source whitespace and line endings', () => {
  assert.deepEqual(compareInheritedInputs(original, original.replace('. $item.Path', '. $item.Path ')).changed,
    ['member command']);
  const crlf = original.replaceAll('\n', '\r\n');
  const corrected = crlf.replace('(path_command_name)', '(member_access)');
  assert.deepEqual(compareInheritedInputs(crlf, corrected), { total: 1, changed: [] });
  assert.deepEqual(compareInheritedInputs(original, crlf).changed, ['member command']);
});

test('reports malformed fixtures explicitly', () => {
  assert.throws(() => compareInheritedInputs(original, original.replace('---', 'not a separator')),
    /lacks an expected-tree separator/);
  assert.throws(() => compareInheritedInputs('not a fixture', original), /no inherited corpus cases/);
});
