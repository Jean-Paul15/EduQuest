// Ecriture disque idempotente sous curriculum/ + empreinte SHA-256.
import { access, mkdir, readFile, writeFile } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import { dirname, join } from 'node:path';
import { LYCEE_DIR, OUT_ROOT } from './config.mjs';

export async function fileExists(relPath) {
  try {
    await access(join(LYCEE_DIR, relPath));
    return true;
  } catch {
    return false;
  }
}

const sha256 = (buf) => createHash('sha256').update(buf).digest('hex');

async function ensureDir(file) {
  await mkdir(dirname(file), { recursive: true });
}

// Ecrit sous curriculum/lycee/<relPath>. Retourne { sha256, bytes, skipped }.
export async function writeBinary(relPath, buffer, knownSha) {
  const hash = sha256(buffer);
  if (knownSha === hash) return { sha256: hash, bytes: buffer.length, skipped: true };
  const file = join(LYCEE_DIR, relPath);
  await ensureDir(file);
  await writeFile(file, buffer);
  return { sha256: hash, bytes: buffer.length, skipped: false };
}

export async function writeTextFile(relPath, text) {
  const file = join(LYCEE_DIR, relPath);
  await ensureDir(file);
  await writeFile(file, text, 'utf8');
}

export async function writeRootJson(name, obj) {
  const file = join(OUT_ROOT, name);
  await ensureDir(file);
  await writeFile(file, JSON.stringify(obj, null, 2) + '\n', 'utf8');
}

export async function writeRootText(name, text) {
  const file = join(OUT_ROOT, name);
  await ensureDir(file);
  await writeFile(file, text, 'utf8');
}

export async function readRootJson(name, fallback) {
  try {
    return JSON.parse(await readFile(join(OUT_ROOT, name), 'utf8'));
  } catch {
    return fallback;
  }
}
