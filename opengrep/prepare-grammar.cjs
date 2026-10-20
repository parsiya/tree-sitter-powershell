const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const [repository, destination] = process.argv.slice(2);
assert.ok(repository && destination, 'usage: node prepare-grammar.cjs REPOSITORY DESTINATION');

const source = fs.readFileSync(path.join(repository, 'grammar.js'), 'utf8');
const esmExport = /^export default grammar\(/gm;
assert.equal(
  [...source.matchAll(esmExport)].length,
  1,
  'The upstream grammar export changed; review the CommonJS build adaptation.',
);

fs.writeFileSync(
  path.join(destination, 'upstream.cjs'),
  source.replace(esmExport, 'module.exports = grammar('),
);
fs.copyFileSync(
  path.join(repository, 'opengrep', 'grammar.cjs'),
  path.join(destination, 'grammar.js'),
);
