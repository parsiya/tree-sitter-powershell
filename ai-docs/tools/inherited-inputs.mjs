import assert from 'node:assert/strict';

function corpusInputs(text) {
  const lines = text.split('\n');
  const isDelimiter = line => /^={3,}\S*\r?$/.test(line);
  const starts = [];
  for (let i = 0; i + 2 < lines.length; i++) {
    if (isDelimiter(lines[i]) && isDelimiter(lines[i + 2])) {
      starts.push(i);
      i += 2;
    }
  }
  return starts.map((start, n) => {
    const block = lines.slice(start, starts[n + 1] ?? lines.length).join('\n');
    const separator = /^---+\r?$/m.exec(block);
    assert.ok(separator, `corpus case lacks an expected-tree separator: ${lines[start + 1]}`);
    // Keep the header and original source bytes, but allow corrected expected trees.
    return block.slice(0, separator.index);
  });
}

export function compareInheritedInputs(original, current) {
  const before = corpusInputs(original);
  assert.ok(before.length, 'no inherited corpus cases found');
  const remaining = corpusInputs(current);
  const changed = [];
  for (const input of before) {
    const index = remaining.indexOf(input);
    if (index < 0) changed.push(input.split('\n')[1].replace(/\r$/, ''));
    else remaining.splice(index, 1);
  }
  return { total: before.length, changed };
}
