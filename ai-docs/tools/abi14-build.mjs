// Shared by validate.mjs and proof-kit.mjs: build the parser Opengrep uses (the
// simplified ABI 14 parser on the tree-sitter 0.22.6 runtime) from a parser
// worktree, without Dune and without shared generator output, so several fix
// agents can build at once. The steps are those of opengrep/generate.sh:
//   compat-repo   the worktree's grammar.js plus its opengrep/grammar.cjs (the submodule's
//                 when the worktree has none, e.g. an old Airbus-based branch);
//   compat-022    prepare-grammar.cjs, scanner.c, parameter_letters.h; tree-sitter 0.22.6
//                 generates the unsimplified parser (src/grammar.json keeps root names);
//   compat-abi14  ocaml-tree-sitter `simplify`, regenerated as ABI 14 (src/parser.c).
import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { once } from 'node:events';
import { TOOLS, PARSER, ROOT, ENV_SH, GENERATOR, LOCK } from './config.mjs';

// Static like Opengrep's build: the ABI14 parser on the pkg-config 0.22.6 runtime.
export const ABI14_CC = 'cc -std=c11 -D_POSIX_C_SOURCE=200809L -O2 -Wall -Wextra -Werror -Wno-unused-parameter $(pkg-config --cflags tree-sitter)';
export const ABI14_RUNTIME = '"$(pkg-config --variable=libdir tree-sitter)/libtree-sitter.a"';

export const q = value => `'${String(value).replace(/'/g, `'\\''`)}'`;

// The Opengrep layer (grammar.cjs, prepare-grammar.cjs, test/*.txt) to build FORK with:
// the worktree's own, so og/ fix branches test their pattern-syntax edits.
export function opengrepDir(fork) {
  const own = path.join(fork, 'opengrep');
  return fs.existsSync(path.join(own, 'grammar.cjs')) ? own : path.join(PARSER, 'opengrep');
}

export class StageFailure extends Error {}

// Run SCRIPT in bash with the build environment; the command and its output go to FD.
export function sh(fd, script, { cwd = ROOT ?? TOOLS, env = {}, capture = false, allowFail = false } = {}) {
  fs.writeSync(fd, `\n$ (cd ${cwd}) ${script}\n`);
  const child = spawn('bash', ['-c', `${ENV_SH ? `source ${q(ENV_SH)}\n` : ''}set -euo pipefail\nulimit -c 0\n${script}`], {
    cwd, env: { ...process.env, ...env }, stdio: ['ignore', capture ? 'pipe' : fd, fd],
  });
  let stdout = '';
  if (capture) child.stdout.on('data', data => { stdout += data; fs.writeSync(fd, data); });
  return once(child, 'close').then(([code, signal]) => {
    if (code !== 0 && !allowFail) {
      throw new StageFailure(`command failed (${signal ?? `exit ${code}`}): ${script.split('\n')[0].slice(0, 160)}`);
    }
    return { code, stdout };
  });
}

// Build FORK's ABI14 parser in DIR (layout above; DIR's compat-* folders must not
// exist). RUN is a bound sh(fd, ...). AFTER_022(work) runs once the unsimplified
// parser is generated (validate.mjs runs the 0.22 corpus tests there).
export async function buildAbi14(run, fork, dir, { after022 } = {}) {
  const repo = path.join(dir, 'compat-repo');
  const work = path.join(dir, 'compat-022');
  const simple = path.join(dir, 'compat-abi14');
  const layer = opengrepDir(fork);
  fs.mkdirSync(path.join(repo, 'opengrep'), { recursive: true });
  fs.copyFileSync(path.join(fork, 'grammar.js'), path.join(repo, 'grammar.js'));
  fs.copyFileSync(path.join(layer, 'grammar.cjs'), path.join(repo, 'opengrep/grammar.cjs'));
  fs.mkdirSync(path.join(work, 'src'), { recursive: true });
  await run(`node ${q(`${layer}/prepare-grammar.cjs`)} ${q(repo)} ${q(work)}`);
  for (const file of ['scanner.c', 'parameter_letters.h']) {
    if (fs.existsSync(path.join(fork, 'src', file))) fs.copyFileSync(path.join(fork, 'src', file), path.join(work, 'src', file));
  }
  await run('tree-sitter generate --no-bindings', { cwd: work });
  if (after022) await after022(work);

  assert.ok(GENERATOR && fs.existsSync(GENERATOR), `no ocaml-tree-sitter generator at ${GENERATOR}; build Opengrep once (dune build)`);
  const generator = path.join(dir, 'ocaml-tree-sitter-gen.exe');
  fs.mkdirSync(path.dirname(LOCK), { recursive: true });
  // A shared lock: a full validation (exclusive) may be rebuilding the generator.
  await run(`flock -s -w 900 ${q(LOCK)} cp ${q(GENERATOR)} ${q(generator)}`);
  fs.cpSync(path.join(work, 'src'), path.join(simple, 'src'), { recursive: true });
  await run(`${q(generator)} simplify src/grammar.json src/grammar.simplified.json\nmv src/grammar.simplified.json src/grammar.json\n` +
    'tree-sitter generate src/grammar.json --no-bindings', { cwd: simple });
  const src = path.join(simple, 'src');
  assert.match(fs.readFileSync(path.join(src, 'parser.c'), 'utf8'), /^#define LANGUAGE_VERSION 14$/m, 'simplified parser is not ABI 14');
  return {
    work, simple, src, generator,
    unsimplified: path.join(work, 'src/grammar.json'), simplified: path.join(src, 'grammar.json'),
  };
}

// The node-name map that makes ts-dump report ABI14 trees with the unsimplified
// grammar's names (grammar-harness/abi14-names.mjs). Returns its summary line.
export async function abi14NamesMap(run, unsimplified, simplified, output) {
  const { stdout } = await run(`node grammar-harness/abi14-names.mjs ${q(unsimplified)} ${q(simplified)} ${q(output)}`,
    { cwd: TOOLS, capture: true });
  return stdout.trim();
}

// grammar-harness/ts-dump.c linked with the ABI14 parser sources in SRC.
export function tsDumpCommand(src, output) {
  return `${ABI14_CC} -I ${q(src)} ${q(`${TOOLS}/grammar-harness/ts-dump.c`)} ${q(`${src}/parser.c`)} ${q(`${src}/scanner.c`)} ` +
    `${ABI14_RUNTIME} -o ${q(output)}`;
}
