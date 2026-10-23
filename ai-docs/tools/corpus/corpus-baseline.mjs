// End-to-end corpus layer for one batch: inventory (encodings, unreadable files,
// non-UTF-8 names), then per unique content the raw ABI 14 parse (local/build/corpus-probe,
// built by `validate.mjs full`) and `bin/opengrep --core -parsing_stats`, classified per file.
//
// usage: node corpus-baseline.mjs BATCH_DIRECTORY OUTPUT_DIRECTORY
// BATCH_DIRECTORY must be an immediate subfolder of the corpus root (config.mjs);
// OUTPUT_DIRECTORY must be under ai-docs/local/runs/. CORPUS_JOBS / CORPUS_CHUNK_SIZE
// set the worker count and chunk size (recorded in identity.json).
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { spawn } from 'node:child_process';
import { createReadStream, createWriteStream } from 'node:fs';
import * as fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { once } from 'node:events';

import { CORPUS, PARSER, PROBE, RUNS, requireRoot } from '../config.mjs';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = requireRoot();
const parser = PARSER;
const extensions = new Set(['.ps1', '.psm1', '.psd1']);
// Recorded in identity.json; defaults match the historical baselines.
const chunkSize = Number(process.env.CORPUS_CHUNK_SIZE ?? 16);
const jobs = Number(process.env.CORPUS_JOBS ?? 2);
assert.ok(Number.isInteger(chunkSize) && chunkSize > 0 && Number.isInteger(jobs) && jobs > 0);

function digest(data) {
  return createHash('sha256').update(data).digest('hex');
}

async function hashFile(file) {
  const hash = createHash('sha256');
  for await (const part of createReadStream(file)) hash.update(part);
  return hash.digest('hex');
}

async function save(file, data) {
  await fs.writeFile(`${file}.tmp`, `${JSON.stringify(data, null, 2)}\n`, { flag: 'wx' });
  await fs.rename(`${file}.tmp`, file);
}

async function run(command, args, prefix, timeout) {
  const stdout = createWriteStream(`${prefix}.stdout`);
  const stderr = createWriteStream(`${prefix}.stderr`);
  const started = Date.now();
  const child = spawn(command, args, {
    cwd: root,
    env: { ...process.env, TMPDIR: path.dirname(prefix) },
    stdio: ['ignore', 'pipe', 'pipe'],
  });
  child.stdout.pipe(stdout);
  child.stderr.pipe(stderr);
  let timedOut = false;
  const timer = setTimeout(() => {
    timedOut = true;
    child.kill('SIGKILL');
  }, timeout);
  try {
    const [code, signal] = await once(child, 'close');
    await Promise.all([
      stdout.closed ? undefined : once(stdout, 'close'),
      stderr.closed ? undefined : once(stderr, 'close'),
    ]);
    const result = {
      command: [command, ...args], code, signal, timed_out: timedOut,
      elapsed_ms: Date.now() - started,
    };
    await save(`${prefix}.exit.json`, result);
    assert.equal(timedOut, false, `${prefix}: process exceeded its wall limit`);
    assert.equal(code, 0, `${prefix}: process failed; inspect stderr and exit.json`);
    return result;
  } finally {
    clearTimeout(timer);
  }
}

function encoding(bytes) {
  if (bytes.subarray(0, 4).equals(Buffer.from([0xff, 0xfe, 0, 0]))) return 'utf32le-bom';
  if (bytes.subarray(0, 4).equals(Buffer.from([0, 0, 0xfe, 0xff]))) return 'utf32be-bom';
  if (bytes.subarray(0, 2).equals(Buffer.from([0xff, 0xfe]))) return 'utf16le-bom';
  if (bytes.subarray(0, 2).equals(Buffer.from([0xfe, 0xff]))) return 'utf16be-bom';
  try {
    new TextDecoder('utf-8', { fatal: true }).decode(bytes);
  } catch (error) {
    if (!(error instanceof TypeError)) throw error;
    return 'non-utf8';
  }
  if (bytes.includes(0)) return 'utf8-with-nul';
  return bytes.subarray(0, 3).equals(Buffer.from([0xef, 0xbb, 0xbf])) ? 'utf8-bom' : 'utf8';
}

async function inventory(batch) {
  const files = [];
  const exclusions = [];
  async function walk(directory, parent = Buffer.alloc(0)) {
    const entries = await fs.readdir(directory, { withFileTypes: true, encoding: 'buffer' });
    entries.sort((a, b) => Buffer.compare(a.name, b.name));
    for (const entry of entries) {
      const absolute = Buffer.concat([directory, Buffer.from('/'), entry.name]);
      const relativeBytes = Buffer.concat([parent, parent.length ? Buffer.from('/') : Buffer.alloc(0), entry.name]);
      const relative = relativeBytes.toString('utf8');
      const extension = path.extname(entry.name.toString('latin1')).toLowerCase();
      let pathBytes;
      try {
        new TextDecoder('utf-8', { fatal: true }).decode(relativeBytes);
      } catch (error) {
        if (!(error instanceof TypeError)) throw error;
        pathBytes = relativeBytes.toString('base64');
      }
      const pathInfo = { path: relative, ...(pathBytes ? { path_bytes_base64: pathBytes } : {}) };
      if (entry.isSymbolicLink()) {
        exclusions.push({ ...pathInfo, reason: 'symlink-not-followed' });
      } else if (entry.isDirectory()) {
        await walk(absolute, relativeBytes);
      } else if (entry.isFile() && extensions.has(extension)) {
        let bytes;
        try {
          bytes = await fs.readFile(absolute);
        } catch (error) {
          if (!['EACCES', 'EPERM'].includes(error.code)) throw error;
          const stat = await fs.stat(absolute);
          exclusions.push({
            ...pathInfo, reason: 'unreadable-powershell-file',
            bytes: stat.size, extension,
            error: error.code,
          });
          console.error(`UNREADABLE (${error.code}): ${absolute}`);
          continue;
        }
        files.push({
          ...pathInfo, bytes: bytes.length, sha256: digest(bytes), extension,
          encoding: encoding(bytes),
        });
      } else {
        exclusions.push({ ...pathInfo, reason: 'not-a-powershell-regular-file' });
      }
    }
  }
  await walk(Buffer.from(batch));
  assert.ok(files.length, 'No PowerShell files selected');
  return { batch, files, exclusions };
}

async function provenance() {
  const inputs = [
    path.join(root, 'bin/opengrep'),
    PROBE,
    fileURLToPath(import.meta.url),
    path.join(here, 'corpus-probe.c'),
    path.join(parser, 'opengrep/ocaml/lib/parser.c'),
    path.join(parser, 'opengrep/ocaml/lib/scanner.c'),
    path.join(root, 'languages/powershell/generic/Parse_powershell_tree_sitter.ml'),
  ];
  return Object.fromEntries(await Promise.all(inputs.map(async file => [file, await hashFile(file)])));
}

function classify(file, raw, project, diagnostic) {
  const encoded = !['utf8', 'utf8-bom'].includes(file.encoding);
  const core = project.file_count === 0 ? 'timeout'
    : diagnostic.includes('Unsupported PowerShell syntax:') ? 'unsupported_conversion'
    : diagnostic.includes(': exn =') ? 'exception'
    : project.error_file_count ? 'parse_error'
    : 'ok';
  const category = encoded ? 'encoding_review'
    : raw.status === 'timeout' || core === 'timeout' ? 'timeout'
    : raw.status === 'grammar_error' ? 'grammar_error'
    : core;
  return { category, core };
}

async function scanChunk(batch, representatives, output, number) {
  const prefix = path.join(output, `chunk-${String(number).padStart(4, '0')}`);
  const resultFile = `${prefix}.json`;
  try {
    const cached = JSON.parse(await fs.readFile(resultFile, 'utf8'));
    assert.deepEqual(cached.hashes, representatives.map(file => file.sha256));
    assert.equal(cached.results.length, representatives.length);
    return cached.results;
  } catch (error) {
    if (error.code !== 'ENOENT') throw error;
  }
  const paths = await Promise.all(representatives.map(async file => {
    if (!file.path_bytes_base64) return path.join(batch, file.path);
    const directory = path.join(output, 'inputs');
    await fs.mkdir(directory, { recursive: true });
    const alias = path.join(directory, `${file.sha256}${file.extension}`);
    const target = Buffer.concat([Buffer.from(`${batch}/`), Buffer.from(file.path_bytes_base64, 'base64')]);
    try {
      await fs.symlink(target, alias);
    } catch (error) {
      if (error.code !== 'EEXIST') throw error;
      assert.deepEqual(await fs.readlink(alias, { encoding: 'buffer' }), target);
    }
    return alias;
  }));
  const grammarExit = await run(PROBE, paths,
    `${prefix}.grammar`, chunkSize * 1500 + 10000);
  const raw = (await fs.readFile(`${prefix}.grammar.stdout`, 'utf8')).trim().split('\n').map(JSON.parse);
  assert.equal(raw.length, paths.length, `${prefix}: missing raw parser results`);
  const coreExit = await run(path.join(root, 'bin/opengrep'),
    ['--core', '-lang', 'powershell', '-parsing_stats', '-json', ...paths],
    `${prefix}.core`, chunkSize * 10000 + 15000);
  const stats = JSON.parse(await fs.readFile(`${prefix}.core.stdout`, 'utf8'));
  assert.equal(stats.language, 'Powershell');
  assert.equal(stats.projects.length, paths.length);
  const stderr = await fs.readFile(`${prefix}.core.stderr`, 'utf8');
  const results = representatives.map((file, i) => {
    assert.equal(raw[i].index, i);
    assert.ok(['ok', 'grammar_error', 'timeout'].includes(raw[i].status));
    const project = stats.projects[i];
    assert.equal(project.name, paths[i]);
    assert.ok([0, 1].includes(project.file_count));
    const marker = `processing ${paths[i]}\n`;
    const start = stderr.indexOf(marker);
    assert.notEqual(start, -1, `${prefix}: no processing diagnostic for ${paths[i]}`);
    const end = stderr.indexOf(`done parsing ${paths[i]}\n`, start + marker.length);
    assert.notEqual(end, -1, `${prefix}: missing completion diagnostic`);
    const diagnostic = stderr.slice(start + marker.length, end);
    const { category, core } = classify(file, raw[i], project, diagnostic);
    return {
      sha256: file.sha256, representative: file.path, category,
      grammar: raw[i], core_status: core, stats: project,
      exception: diagnostic.match(/^.*: exn = (.*)$/m)?.[1] ?? null,
    };
  });
  assert.equal(stats.global.file_count, results.filter(item => item.core_status !== 'timeout').length);
  await save(resultFile, {
    hashes: representatives.map(file => file.sha256), grammar_exit: grammarExit,
    core_exit: coreExit, results,
  });
  console.log(`Completed chunk ${number}: ${results.length} unique inputs`);
  return results;
}

function countBy(items, getKey) {
  const counts = {};
  for (const item of items) {
    const key = getKey(item);
    counts[key] = (counts[key] ?? 0) + 1;
  }
  return counts;
}

async function baseline(batch, output) {
  await fs.mkdir(output, { recursive: true });
  const manifest = await inventory(batch);
  const identity = { batch, chunk_size: chunkSize, jobs, inputs: await provenance(), manifest };
  const identityHash = digest(JSON.stringify(identity));
  const identityFile = path.join(output, 'identity.json');
  try {
    const previous = JSON.parse(await fs.readFile(identityFile, 'utf8'));
    assert.equal(previous.sha256, identityHash,
      'Inputs changed: use a new output directory, not cached results');
  } catch (error) {
    if (error.code !== 'ENOENT') throw error;
    await save(identityFile, { sha256: identityHash, ...identity });
  }
  const unique = [...new Map(manifest.files.map(file => [file.sha256, file])).values()];
  console.log(`Inventory: ${manifest.files.length} files; ${unique.length} distinct contents`);
  const chunks = [];
  for (let i = 0; i < unique.length; i += chunkSize) chunks.push(unique.slice(i, i + chunkSize));
  let next = 0;
  const chunkResults = [];
  async function worker() {
    while (next < chunks.length) {
      const index = next++;
      chunkResults[index] = await scanChunk(batch, chunks[index], output, index);
    }
  }
  const workers = await Promise.allSettled(Array.from({ length: jobs }, worker));
  for (const worker of workers) {
    if (worker.status === 'rejected') throw worker.reason;
  }
  const results = chunkResults.flat();
  assert.equal(results.length, unique.length);
  const byHash = new Map(results.map(item => [item.sha256, item]));
  const files = manifest.files.map(file => ({ ...file, ...byHash.get(file.sha256) }));
  assert.equal(files.length, manifest.files.length);
  const unreadable = manifest.exclusions.filter(file => file.reason === 'unreadable-powershell-file');
  const summary = {
    batch, identity_sha256: identityHash, completed_at: new Date().toISOString(),
    discovered_powershell_files: files.length + unreadable.length,
    unreadable_files: unreadable.length,
    unreadable_bytes: unreadable.reduce((sum, file) => sum + file.bytes, 0),
    unreadable_extensions: countBy(unreadable, file => file.extension),
    selected_files: files.length, selected_bytes: files.reduce((sum, file) => sum + file.bytes, 0),
    non_utf8_paths: files.filter(file => file.path_bytes_base64).length,
    unique_contents: unique.length, avoided_duplicate_parses: files.length - unique.length,
    extensions: countBy(files, file => file.extension),
    encodings: countBy(files, file => file.encoding),
    exclusions: countBy(manifest.exclusions, file => file.reason),
    categories: countBy(files, file => file.category),
    unique_categories: countBy(results, file => file.category),
    grammar_statuses: countBy(files, file => file.grammar.status),
    core_statuses: countBy(files, file => file.core_status),
    unsupported_labels: countBy(files.filter(file => file.core_status === 'unsupported_conversion'),
      file => file.exception.match(/Unsupported PowerShell syntax: ([^,]+)/)[1]),
    largest_files: [...manifest.files].sort((a, b) => b.bytes - a.bytes).slice(0, 10),
    caveats: [
      'Grammar parses original bytes as UTF-8; non-UTF-8/BOM inputs require separate encoding review.',
      'Grammar errors may be invalid source, grammar gaps, or truncated extraction; not yet adjudicated.',
      'Core exceptions can hide additional grammar/conversion failures in the same file.',
      'Core JSON omits timed-out inputs; zero-count per-file projects are retained as timeouts here.',
      'Statistics measure parsing, not matching correctness; untranslated node counts are not failure counts.',
      'Exact-byte duplicates are parsed once and expanded to all original paths; no normalized copies.',
      'Unreadable files remain explicit inventory exclusions; corpus permissions are not changed.',
      'Non-UTF-8 filenames use local symlinks under inputs/; original name bytes are retained as base64.',
    ],
  };
  await fs.writeFile(path.join(output, 'files.jsonl'), files.map(file => JSON.stringify(file)).join('\n') + '\n');
  await fs.writeFile(path.join(output, 'summary.json'), JSON.stringify(summary, null, 2) + '\n');
  console.log(JSON.stringify(summary, null, 2));
}

const [batchArg, outputArg] = process.argv.slice(2);
assert.ok(batchArg && outputArg, 'usage: node corpus-baseline.mjs BATCH_DIRECTORY OUTPUT_DIRECTORY');
assert.equal(path.dirname(path.resolve(batchArg)), path.resolve(CORPUS),
  `Select one immediate batch under the corpus root ${CORPUS}, not the whole corpus`);
const batch = await fs.realpath(batchArg);
const output = path.resolve(outputArg);
assert.ok(output.startsWith(`${RUNS}${path.sep}`), 'All output must be under ai-docs/local/runs/');
await baseline(batch, output);
