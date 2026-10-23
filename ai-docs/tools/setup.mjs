// Fetch the pinned downloads the tools need, verify their SHA-256 and unpack them into
// the vendor folder (config.mjs; default ai-docs/local/vendor):
//   PowerShell 7.6.7 linux-x64 (GitHub release tarball)     -> VENDOR/powershell-7.6.7/
//   tree-sitter 0.22.6 runtime sources (lib/include and lib/src of the v0.22.6 tag
//   tarball, as Opengrep's libs/ocaml-tree-sitter-core downloads it) -> VENDOR/tree-sitter-0.22.6/lib/
//
//   node ai-docs/tools/setup.mjs [--from DIR]
//
// --from DIR uses already-downloaded files (DIR/<file name> below) instead of the network.
// A folder that is already set up from the same SHA-256 is left alone. Nothing is
// executed, and the corpus is never touched.
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { VENDOR } from './config.mjs';

const DOWNLOADS = [
  {
    name: 'powershell-7.6.7', file: 'powershell-7.6.7-linux-x64.tar.gz',
    url: 'https://github.com/PowerShell/PowerShell/releases/download/v7.6.7/powershell-7.6.7-linux-x64.tar.gz',
    sha256: '6896f9e3a6b0a354bf470835a96da76d2f801cd50dcf047ad7c4563bf93bf431',
    tar: [], check: 'pwsh',
  },
  {
    name: 'tree-sitter-0.22.6', file: 'tree-sitter-0.22.6.tar.gz',
    url: 'https://github.com/tree-sitter/tree-sitter/archive/refs/tags/v0.22.6.tar.gz',
    sha256: 'e2b687f74358ab6404730b7fb1a1ced7ddb3780202d37595ecd7b20a8f41861f',
    tar: ['--strip-components=1', 'tree-sitter-0.22.6/lib/include', 'tree-sitter-0.22.6/lib/src'], check: 'lib/src/lib.c',
  },
];

const args = process.argv.slice(2);
assert.ok(args.length === 0 || (args.length === 2 && args[0] === '--from'), 'usage: node ai-docs/tools/setup.mjs [--from DIR]');
const from = args[1] && path.resolve(args[1]);
fs.mkdirSync(VENDOR, { recursive: true });

for (const item of DOWNLOADS) {
  const dest = path.join(VENDOR, item.name);
  const marker = path.join(dest, '.setup-sha256');
  if (fs.existsSync(marker) && fs.readFileSync(marker, 'utf8').trim() === item.sha256) {
    console.log(`${item.name}: already set up in ${dest}`);
    continue;
  }
  let archive;
  if (from) {
    archive = path.join(from, item.file);
    assert.ok(fs.existsSync(archive), `--from: missing ${archive}`);
  } else {
    console.log(`${item.name}: downloading ${item.url}`);
    const response = await fetch(item.url);
    assert.ok(response.ok, `${item.url}: HTTP ${response.status}`);
    archive = path.join(VENDOR, item.file);
    fs.writeFileSync(`${archive}.part`, Buffer.from(await response.arrayBuffer()));
    fs.renameSync(`${archive}.part`, archive);
  }
  const actual = createHash('sha256').update(fs.readFileSync(archive)).digest('hex');
  assert.equal(actual, item.sha256, `${archive}: SHA-256 mismatch (expected ${item.sha256})`);
  const tmp = `${dest}.tmp-${process.pid}`;
  fs.rmSync(tmp, { recursive: true, force: true });
  fs.mkdirSync(tmp);
  const tar = spawnSync('tar', ['-xzf', archive, '-C', tmp, ...item.tar], { stdio: 'inherit' });
  assert.equal(tar.status, 0, `tar failed on ${archive}`);
  assert.ok(fs.existsSync(path.join(tmp, item.check)), `${archive}: ${item.check} missing after unpacking`);
  if (item.check === 'pwsh') fs.chmodSync(path.join(tmp, 'pwsh'), 0o755);
  fs.writeFileSync(path.join(tmp, '.setup-sha256'), `${item.sha256}\n`);
  fs.rmSync(dest, { recursive: true, force: true });
  fs.renameSync(tmp, dest);
  console.log(`${item.name}: SHA-256 ok, unpacked into ${dest}`);
}
