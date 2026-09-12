// Upload des PDF d'epreuves vers le bucket Storage `eduquest-content` (cle service).
import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';

const LYCEE = fileURLToPath(new URL('../../../curriculum/lycee/', import.meta.url));
const BUCKET = 'eduquest-content';

function env() {
  const url = process.env.SUPABASE_URL;
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SECRET_KEY;
  if (!url || !key) throw new Error('SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY manquants (source site/.env)');
  return { url, key };
}

async function putOne({ url, key }, storageKey, relPath) {
  const body = await readFile(join(LYCEE, relPath));
  const res = await fetch(`${url}/storage/v1/object/${BUCKET}/${storageKey}`, {
    method: 'POST',
    headers: {
      authorization: `Bearer ${key}`,
      apikey: key,
      'content-type': 'application/pdf',
      'x-upsert': 'true',
      'cache-control': '3600',
    },
    body,
  });
  if (!res.ok && res.status !== 409) throw new Error(`${res.status} ${await res.text()}`);
  return res.status;
}

// pairs: [{ storageKey, relPath }]
export async function uploadAll(pairs, { concurrency = 5 } = {}) {
  const cfg = env();
  const q = [...pairs];
  const failures = [];
  let done = 0;
  async function worker() {
    while (q.length) {
      const item = q.shift();
      try {
        await putOne(cfg, item.storageKey, item.relPath);
      } catch (e) {
        failures.push({ ...item, error: String(e.message).slice(0, 200) });
      }
      if (++done % 50 === 0) console.log(`  upload ${done}/${pairs.length}`);
    }
  }
  await Promise.all(Array.from({ length: concurrency }, worker));
  return { uploaded: pairs.length - failures.length, failures };
}
