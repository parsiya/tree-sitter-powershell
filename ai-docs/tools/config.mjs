// Every path the ai-docs tools use. The defaults suit this grammar repo checked out
// as Opengrep's submodule; ai-docs/local/config.json (Git-ignored, optional) overrides:
//   {
//     "opengrepRoot": "DIR",    default: the superproject of this repo
//     "buildEnv": "SCRIPT",     default: none; a shell script sourced before every build
//                               command. Without it PATH must provide opam/dune,
//                               tree-sitter CLI 0.22.6 and `pkg-config tree-sitter` (0.22.6).
//     "corpusRoot": "DIR",      default: ai-docs/local/corpus; every subfolder is a batch
//     "vendor": "DIR"           default: ai-docs/local/vendor (filled by setup.mjs)
//   }
// Relative values are resolved against ai-docs/local/. Outputs (runs, results,
// baselines.json, caches) always live under ai-docs/local/.
import { execFileSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

export const TOOLS = path.dirname(fileURLToPath(import.meta.url));
export const AI_DOCS = path.dirname(TOOLS);
// The grammar repo these tools belong to (the default parser under test).
export const PARSER = path.dirname(AI_DOCS);
export const LOCAL = path.join(AI_DOCS, 'local');
export const CONFIG_FILE = path.join(LOCAL, 'config.json');

const SETTINGS = ['opengrepRoot', 'buildEnv', 'corpusRoot', 'vendor'];
const local = fs.existsSync(CONFIG_FILE) ? JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf8')) : {};
for (const key of Object.keys(local)) {
  if (!SETTINGS.includes(key)) throw new Error(`${CONFIG_FILE}: unknown setting ${key} (known: ${SETTINGS.join(', ')})`);
}
const setting = (key, fallback) => (local[key] ? path.resolve(LOCAL, local[key]) : fallback);

function superproject() {
  try {
    return execFileSync('git', ['-C', PARSER, 'rev-parse', '--show-superproject-working-tree'],
      { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }).trim();
  } catch {
    return '';
  }
}

export const ROOT = setting('opengrepRoot', superproject() || null);
export const ENV_SH = setting('buildEnv', null);
export const CORPUS = setting('corpusRoot', path.join(LOCAL, 'corpus'));
export const VENDOR = setting('vendor', path.join(LOCAL, 'vendor'));

export const PWSH_VERSION = '7.6.7';
export const PWSH = path.join(VENDOR, `powershell-${PWSH_VERSION}/pwsh`);
export const RT22 = path.join(VENDOR, 'tree-sitter-0.22.6/lib');
export const ABI14_LIB = path.join(PARSER, 'opengrep/ocaml/lib');
export const GENERATOR = ROOT && path.join(ROOT, '_build/default/libs/ocaml-tree-sitter-core/src/gen/bin/Ocaml_tree_sitter_main.exe');

export const RUNS = path.join(LOCAL, 'runs');
export const BASELINES = path.join(LOCAL, 'baselines.json');
export const RESULTS = path.join(LOCAL, 'results');
export const KIT = path.join(LOCAL, 'proof-kit');
export const PROBE = path.join(LOCAL, 'build/corpus-probe');
export const NATIVE_CACHE = path.join(LOCAL, 'native-cache', PWSH_VERSION);
export const NATIVE_HOME = path.join(LOCAL, 'native-home');
export const LOCK = path.join(LOCAL, 'validate-full.lock');

// Grammar builds under local/ run tree-sitter on a CommonJS grammar.js; this repo's
// package.json says "type": "module", so local/ gets its own package.json.
export function prepareLocal() {
  fs.mkdirSync(LOCAL, { recursive: true });
  const file = path.join(LOCAL, 'package.json');
  if (!fs.existsSync(file)) fs.writeFileSync(file, '{ "type": "commonjs" }\n');
}

export function requireRoot() {
  if (!ROOT || !fs.existsSync(path.join(ROOT, 'languages/powershell'))) {
    throw new Error(`no Opengrep checkout (${ROOT ?? 'this repo is not a submodule'}); set opengrepRoot in ${CONFIG_FILE}`);
  }
  return ROOT;
}

export function requireVendor(file) {
  if (!fs.existsSync(file)) throw new Error(`missing ${file}; run: node ai-docs/tools/setup.mjs`);
  return file;
}

// Corpus batches: the subfolders of the corpus root, sorted; none when it is absent.
export function batches() {
  if (!fs.existsSync(CORPUS)) return [];
  return fs.readdirSync(CORPUS)
    .filter(name => !name.startsWith('.') && fs.statSync(path.join(CORPUS, name)).isDirectory())
    .sort();
}

// Native PowerShell runs parse-only, with its caches and settings kept under local/.
export const PWSH_ARGS = ['-NoLogo', '-NoProfile', '-NonInteractive'];
export function nativeEnv() {
  for (const dir of ['cache', 'config', 'data', 'tmp']) fs.mkdirSync(path.join(NATIVE_HOME, dir), { recursive: true });
  return {
    ...process.env, POWERSHELL_TELEMETRY_OPTOUT: '1', POWERSHELL_UPDATECHECK: 'Off',
    XDG_CACHE_HOME: `${NATIVE_HOME}/cache`, XDG_CONFIG_HOME: `${NATIVE_HOME}/config`,
    XDG_DATA_HOME: `${NATIVE_HOME}/data`, TMPDIR: `${NATIVE_HOME}/tmp`,
  };
}
