// Client HTTP : session invitee Moodle, rate-limit sequentiel, retry backoff, cache brut.
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import { join } from 'node:path';
import { MAX_RETRIES, RAW_DIR, REQUEST_DELAY_MS, TIMEOUT_MS, USER_AGENT } from './config.mjs';

const jar = new Map();
let gate = Promise.resolve();
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

function cookieHeader() {
  return [...jar.entries()].map(([k, v]) => `${k}=${v}`).join('; ');
}
function storeCookies(res) {
  for (const line of res.headers.getSetCookie?.() ?? []) {
    const [pair] = line.split(';');
    const idx = pair.indexOf('=');
    if (idx > 0) jar.set(pair.slice(0, idx).trim(), pair.slice(idx + 1).trim());
  }
}

async function once(url, wantBinary) {
  const ac = new AbortController();
  const timer = setTimeout(() => ac.abort(), TIMEOUT_MS);
  try {
    const res = await fetch(url, {
      redirect: wantBinary ? 'follow' : 'follow',
      signal: ac.signal,
      headers: { 'user-agent': USER_AGENT, cookie: cookieHeader(), accept: '*/*' },
    });
    storeCookies(res);
    if (res.status >= 500 || res.status === 429) throw new Error(`HTTP ${res.status}`);
    const body = wantBinary ? Buffer.from(await res.arrayBuffer()) : await res.text();
    return { status: res.status, url: res.url, headers: res.headers, body };
  } finally {
    clearTimeout(timer);
  }
}

// Requete serialisee + reessais. `cache` = relire/ecrire le HTML brut sur disque.
export function request(url, { binary = false, cache = false } = {}) {
  const run = async () => {
    const rawPath = join(RAW_DIR, createHash('sha1').update(url).digest('hex') + '.html');
    if (cache && !binary) {
      try {
        return { status: 200, url, headers: new Headers(), body: await readFile(rawPath, 'utf8') };
      } catch {
        /* pas de cache, on telecharge */
      }
    }
    let lastErr;
    for (let attempt = 0; attempt <= MAX_RETRIES; attempt++) {
      try {
        await sleep(REQUEST_DELAY_MS); // delai uniquement sur requete reseau reelle
        const out = await once(url, binary);
        if (cache && !binary && out.status === 200) {
          await mkdir(RAW_DIR, { recursive: true });
          await writeFile(rawPath, out.body);
        }
        return out;
      } catch (err) {
        lastErr = err;
        await sleep(2000 * 2 ** attempt);
      }
    }
    throw new Error(`GET ${url} a echoue: ${lastErr?.message}`);
  };
  gate = gate.then(run, run);
  return gate;
}

export async function prime(base) {
  await request(base + '/', { cache: false });
}
