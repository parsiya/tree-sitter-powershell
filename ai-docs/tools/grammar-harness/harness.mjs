// Compare a tree-sitter-powershell parser (ts-dump; validate.mjs builds it from
// the ABI14 parser Opengrep uses) with PowerShell's own parser (parse only) over
// one corpus batch, and group disagreements.
//
// usage: TS_DUMP=BINARY node harness.mjs BATCH_DIRECTORY OUTPUT_DIRECTORY
// TS_DUMP (required) is the ts-dump binary; TS_DUMP_NAMES reaches it unchanged (see
// ts-dump.c); TS_DUMP_PARSER describes the parser in summary.json. OUTPUT_DIRECTORY must
// be under ai-docs/local/. Native results are cached in local/native-cache/.
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { spawn } from 'node:child_process';
import * as fs from 'node:fs/promises';
import path from 'node:path';
import readline from 'node:readline';
import { fileURLToPath } from 'node:url';
import { LOCAL, NATIVE_CACHE, PWSH, PWSH_ARGS, PWSH_VERSION, nativeEnv, requireVendor } from '../config.mjs';

const here = path.dirname(fileURLToPath(import.meta.url));
const extensions = new Set(['.ps1', '.psm1', '.psd1']);
const tsJobs = 4;
const tsChunk = 100;
const nativeJobs = 3;
const nativeVersion = PWSH_VERSION;
const nativeCache = NATIVE_CACHE;
const maxProblemsPerFile = 50;

const sha256 = data => createHash('sha256').update(data).digest('hex');

function encoding(bytes) {
  if (bytes.subarray(0, 2).equals(Buffer.from([0xff, 0xfe]))) return 'utf16le-bom';
  if (bytes.subarray(0, 2).equals(Buffer.from([0xfe, 0xff]))) return 'utf16be-bom';
  try {
    new TextDecoder('utf-8', { fatal: true }).decode(bytes);
  } catch (error) {
    if (!(error instanceof TypeError)) throw error;
    return 'non-utf8';
  }
  return bytes.subarray(0, 3).equals(Buffer.from([0xef, 0xbb, 0xbf])) ? 'utf8-bom' : 'utf8';
}

async function inventory(batch, output) {
  const files = [];
  const excluded = {};
  const count = reason => { excluded[reason] = (excluded[reason] ?? 0) + 1; };
  async function walk(directory, relative) {
    const entries = await fs.readdir(directory, { withFileTypes: true, encoding: 'buffer' });
    entries.sort((a, b) => Buffer.compare(a.name, b.name));
    for (const entry of entries) {
      const absolute = Buffer.concat([directory, Buffer.from('/'), entry.name]);
      const rel = Buffer.concat([relative, relative.length ? Buffer.from('/') : Buffer.alloc(0), entry.name]);
      const extension = path.extname(entry.name.toString('latin1')).toLowerCase();
      if (entry.isSymbolicLink()) count('symlink');
      else if (entry.isDirectory()) await walk(absolute, rel);
      else if (!entry.isFile() || !extensions.has(extension)) count('not-powershell');
      else {
        let bytes;
        try {
          bytes = await fs.readFile(absolute);
        } catch (error) {
          if (!['EACCES', 'EPERM'].includes(error.code)) throw error;
          count('unreadable');
          continue;
        }
        let readable = rel.toString('utf8');
        let target = absolute.toString('utf8');
        if (!Buffer.from(readable).equals(rel)) {
          // Non-UTF-8 file names reach the parsers through a local symlink.
          const alias = path.join(output, 'inputs', `${sha256(bytes)}${extension}`);
          await fs.mkdir(path.dirname(alias), { recursive: true });
          await fs.symlink(absolute, alias).catch(error => { if (error.code !== 'EEXIST') throw error; });
          target = alias;
        }
        files.push({ path: readable, target, sha256: sha256(bytes), bytes: bytes.length, encoding: encoding(bytes) });
      }
    }
  }
  await walk(Buffer.from(batch), Buffer.alloc(0));
  return { files, excluded };
}

function runTsChunk(paths) {
  return new Promise((resolve, reject) => {
    const child = spawn(process.env.TS_DUMP, [], { stdio: ['pipe', 'pipe', 'pipe'] });
    let out = '', err = '';
    child.stdout.on('data', data => { out += data; });
    child.stderr.on('data', data => { err += data; });
    const timer = setTimeout(() => child.kill('SIGKILL'), paths.length * 5000 + 30000);
    child.on('close', code => {
      clearTimeout(timer);
      if (code !== 0) return reject(new Error(`ts-dump exited ${code}: ${err.slice(0, 500)}`));
      const lines = out.trim().split('\n').filter(Boolean).map(JSON.parse);
      if (lines.length !== paths.length) return reject(new Error(`ts-dump returned ${lines.length}/${paths.length}`));
      resolve(lines);
    });
    child.stdin.end(Buffer.concat(paths.map(p => Buffer.from(`${p}\0`))));
  });
}

async function runTs(unique) {
  const chunks = [];
  for (let i = 0; i < unique.length; i += tsChunk) chunks.push(unique.slice(i, i + tsChunk));
  const results = [];
  let next = 0;
  await Promise.all(Array.from({ length: tsJobs }, async () => {
    while (next < chunks.length) {
      const index = next++;
      results[index] = await runTsChunk(chunks[index].map(f => f.target));
    }
  }));
  return results.flat();
}

class NativeWorker {
  constructor() {
    this.child = spawn(PWSH, [...PWSH_ARGS, '-File', path.join(here, 'native-dump.ps1')], {
      stdio: ['pipe', 'pipe', 'inherit'], env: nativeEnv(),
    });
    this.pending = [];
    readline.createInterface({ input: this.child.stdout }).on('line', line => {
      const { resolve, timer } = this.pending.shift();
      clearTimeout(timer);
      resolve(JSON.parse(line));
    });
    this.child.on('exit', code => {
      for (const { reject } of this.pending.splice(0)) reject(new Error(`native worker exited ${code}`));
    });
  }
  request(target, offsets = []) {
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => this.child.kill('SIGKILL'), 120000);
      this.pending.push({ resolve, reject, timer });
      this.child.stdin.write(`${offsets.join(',')}\t${target}\n`);
    });
  }
  close() { this.child.stdin.end(); }
}

async function runNative(requests) {
  const workers = Array.from({ length: nativeJobs }, () => new NativeWorker());
  const results = new Array(requests.length);
  let next = 0;
  await Promise.all(workers.map(async worker => {
    while (next < requests.length) {
      const index = next++;
      const { file, offsets } = requests[index];
      const cached = path.join(nativeCache, `${file.sha256}.json`);
      if (!offsets.length) {
        try {
          results[index] = JSON.parse(await fs.readFile(cached, 'utf8'));
          continue;
        } catch (error) {
          if (error.code !== 'ENOENT') throw error;
        }
      }
      results[index] = await worker.request(file.target, offsets);
      if (!offsets.length && results[index].st === 'ok') {
        await fs.mkdir(nativeCache, { recursive: true });
        await fs.writeFile(`${cached}.${process.pid}`, JSON.stringify(results[index]));
        await fs.rename(`${cached}.${process.pid}`, cached);
      }
    }
  }));
  workers.forEach(worker => worker.close());
  return results;
}

const containing = (spans, offset) => spans.find(([s, e]) => s <= offset && offset < Math.max(e, s + 1));

function compare(ts, native) {
  const problems = [];
  const add = (kind, offset, detail, needsPath = false) => {
    if (problems.length < maxProblemsPerFile) problems.push({ kind, offset, detail, needsPath });
  };
  if (native.st !== 'ok') return { category: `native_${native.st}`, problems };
  // These depend on installed modules and types, not on syntax. The last two are
  // Windows PowerShell 5.1 workflow syntax, which pwsh 7 still parses into a whole AST.
  const environmental = new Set(['TypeNotFound', 'ModuleNotFoundDuringParse', 'ErrorLoadingAssembly',
    'WorkflowNotSupportedInPowerShellCore', 'KeywordParameterReservedForFutureUse']);
  const syntaxErrors = native.err.filter(e => !environmental.has(e.id));
  if (syntaxErrors.length) return { category: 'native_invalid', detail: syntaxErrors[0].id, problems };
  if (ts.st === 'timeout') return { category: 'ts_timeout', problems };
  if (ts.st === 'error') {
    const first = ts.err[0];
    add('rejected', first.s, `ts ${first.h ? 'hidden missing token in' : 'error under'} ${first.p || 'root'}${first.m && !first.h ? ' (missing token)' : ''}`, true);
    return { category: 'rejected', problems };
  }
  const tsElements = ts.cmd.flatMap(c => c.el);
  const nativeElements = native.cmd.flatMap(c => c.el);
  const nativeCommands = new Map(native.cmd.map(c => [c.s, c]));
  const tsCommands = new Map(ts.cmd.map(c => [c.s, c]));
  for (const c of ts.cmd) if (!nativeCommands.has(c.s)) add('extra_command', c.s, 'ts command', true);
  for (const c of native.cmd) {
    if (!tsCommands.has(c.s)) add('missing_command', c.s, `inside ts ${containing(tsElements, c.s)?.[2] ?? 'nothing'}`);
  }
  const nativeRedirections = new Set(native.rd.map(r => r[0]));
  const tsRedirections = new Set(ts.rd.map(r => r[0]));
  for (const [s] of native.rd) {
    if (!tsRedirections.has(s)) add('missing_redirection', s, `inside ts ${containing(tsElements, s)?.[2] ?? 'nothing'}`);
  }
  for (const [s] of ts.rd) if (!nativeRedirections.has(s)) add('extra_redirection', s, 'ts redirection', true);
  for (const n of native.cmd) {
    const t = tsCommands.get(n.s);
    if (!t || n.sp || t.sp) continue;
    const nativeStarts = new Set(n.el.map(e => e[0]));
    const tsStarts = new Set(t.el.map(e => e[0]));
    for (const [s, , type] of t.el) {
      // A misread redirection is already reported as missing_redirection.
      if (!nativeStarts.has(s) && !nativeRedirections.has(s)) {
        add('extra_element', s, `ts ${type} inside native ${containing(n.el, s)?.[2] ?? 'nothing'}`);
      }
    }
    for (const [s, , kind] of n.el) {
      if (!tsStarts.has(s)) add('missing_element', s, `native ${kind} inside ts ${containing(t.el, s)?.[2] ?? 'nothing'}`);
    }
  }
  return { category: problems.length ? 'disagree' : 'agree', problems };
}

async function locate(file, offset) {
  const bytes = await fs.readFile(file.target);
  const skip = bytes.subarray(0, 3).equals(Buffer.from([0xef, 0xbb, 0xbf])) ? 3 : 0;
  const text = bytes.subarray(skip);
  const start = text.lastIndexOf(0x0a, Math.max(offset - 1, 0)) + 1;
  let end = text.indexOf(0x0a, offset);
  if (end < 0) end = text.length;
  let line = 1;
  for (let i = 0; i < start; i++) if (text[i] === 0x0a) line++;
  return { line, snippet: text.subarray(start, end).toString('utf8').trim().slice(0, 160) };
}

const [batchArg, outputArg] = process.argv.slice(2);
assert.ok(batchArg && outputArg && process.env.TS_DUMP, 'usage: TS_DUMP=BINARY node harness.mjs BATCH_DIRECTORY OUTPUT_DIRECTORY');
requireVendor(PWSH);
const batch = await fs.realpath(batchArg);
const output = path.resolve(outputArg);
assert.ok(output.startsWith(`${LOCAL}${path.sep}`), 'Output must be under ai-docs/local');
await fs.mkdir(output, { recursive: true });
const started = Date.now();
const { files, excluded } = await inventory(batch, output);
const parseable = files.filter(f => f.encoding === 'utf8' || f.encoding === 'utf8-bom');
const unique = [...new Map(parseable.map(f => [f.sha256, f])).values()];
console.log(`Inventory: ${files.length} PowerShell files, ${parseable.length} UTF-8, ${unique.length} distinct`);

const ts = await runTs(unique);
console.log(`Grammar parse done in ${((Date.now() - started) / 1000).toFixed(1)}s`);
const native = await runNative(unique.map(file => ({ file, offsets: [] })));
console.log(`Native parse done in ${((Date.now() - started) / 1000).toFixed(1)}s`);

const results = unique.map((file, i) => ({ file, ts: ts[i], ...compare(ts[i], native[i]) }));
const located = results.filter(r => r.problems.some(p => p.needsPath));
const paths = await runNative(located.map(r => ({
  file: r.file,
  offsets: [...new Set(r.problems.filter(p => p.needsPath).map(p => p.offset))].slice(0, 20),
})));
located.forEach((r, i) => {
  const at = new Map((paths[i].at ?? []).map(a => [a.o, a.path]));
  for (const p of r.problems) if (p.needsPath) p.detail += ` at native ${at.get(p.offset) || 'nothing'}`;
});

const copies = new Map();
for (const f of parseable) copies.set(f.sha256, (copies.get(f.sha256) ?? 0) + 1);
const categories = {};
const groups = new Map();
for (const r of results) {
  const n = copies.get(r.file.sha256);
  const category = r.category === 'native_invalid' ? `native_invalid` : r.category;
  categories[category] = (categories[category] ?? 0) + n;
  for (const key of new Set(r.problems.map(p => `${p.kind}: ${p.detail}`))) {
    const group = groups.get(key) ?? { key, files: 0, distinct: 0, examples: [] };
    group.files += n;
    group.distinct++;
    if (group.examples.length < 5) {
      const problem = r.problems.find(p => `${p.kind}: ${p.detail}` === key);
      group.examples.push({ path: r.file.path, offset: problem.offset, ...(await locate(r.file, problem.offset)) });
    }
    groups.set(key, group);
  }
}
const invalidReasons = {};
for (const r of results) if (r.category === 'native_invalid') invalidReasons[r.detail] = (invalidReasons[r.detail] ?? 0) + copies.get(r.file.sha256);
const summary = {
  batch, completed_at: new Date().toISOString(), elapsed_s: (Date.now() - started) / 1000,
  parser: process.env.TS_DUMP_PARSER ?? `ts-dump at ${process.env.TS_DUMP}`,
  native_parser: `PowerShell ${nativeVersion} Parser.ParseInput`,
  powershell_files: files.length, utf8_files: parseable.length, distinct_utf8: unique.length,
  other_encodings: files.length - parseable.length, excluded,
  categories,
  native_invalid_reasons: Object.fromEntries(Object.entries(invalidReasons).sort((a, b) => b[1] - a[1])),
  groups: [...groups.values()].sort((a, b) => b.files - a.files),
};
assert.equal(Object.values(categories).reduce((a, b) => a + b, 0), parseable.length);
await fs.writeFile(path.join(output, 'summary.json'), `${JSON.stringify(summary, null, 2)}\n`);
await fs.writeFile(path.join(output, 'files.jsonl'), results.map(r => JSON.stringify({
  path: r.file.path, sha256: r.file.sha256, copies: copies.get(r.file.sha256), category: r.category,
  detail: r.detail, ts_ms: r.ts.ms, problems: r.problems.map(({ needsPath, ...p }) => p),
})).join('\n') + '\n');
console.log(JSON.stringify({ categories, top_groups: summary.groups.slice(0, 15).map(g => [g.files, g.key]) }, null, 2));
