const ttlMs = 15 * 60 * 1000;

const randomPart = () => {
  if (typeof crypto !== "undefined" && "randomUUID" in crypto) {
    return crypto.randomUUID();
  }
  return `${Date.now()}-${Math.random().toString(36).slice(2, 12)}`;
};

const keyName = (scope: string, id: string) => `idem:${scope}:${id}`;

export const getOrCreateIdempotencyKey = (scope: string, id: string) => {
  const k = keyName(scope, id);
  if (typeof window === "undefined") return `${scope}:${id}:${randomPart()}`;
  try {
    const raw = window.sessionStorage.getItem(k);
    if (raw) {
      const parsed = JSON.parse(raw) as { value: string; ts: number };
      if (parsed.value && Date.now() - parsed.ts <= ttlMs) return parsed.value;
    }
  } catch {}
  const value = `${scope}:${id}:${randomPart()}`;
  try {
    window.sessionStorage.setItem(k, JSON.stringify({ value, ts: Date.now() }));
  } catch {}
  return value;
};

export const clearIdempotencyKey = (scope: string, id: string) => {
  if (typeof window === "undefined") return;
  try {
    window.sessionStorage.removeItem(keyName(scope, id));
  } catch {}
};
