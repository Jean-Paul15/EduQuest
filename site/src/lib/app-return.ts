const schemePattern = /^([a-z][a-z0-9+\-.]*):\/\//i;

const schemeOf = (value?: string) =>
  value?.trim().match(schemePattern)?.[1]?.toLowerCase() ?? null;

export const normalizeAppReturnUrl = (raw: string | undefined, fallback: string) => {
  const candidate = (raw || "").trim();
  if (!candidate) return fallback;
  const scheme = schemeOf(candidate);
  if (!scheme) return fallback;
  const allowed = new Set(
    [schemeOf(fallback), "ruachedu", "eduquest"].filter((v): v is string => !!v),
  );
  return allowed.has(scheme) ? candidate : fallback;
};

export const appendAppReturnParams = (
  base: string,
  params: Record<string, string | null | undefined>,
) => {
  try {
    const url = new URL(base);
    Object.entries(params).forEach(([key, value]) => {
      if (value != null && value !== "") url.searchParams.set(key, value);
    });
    return url.toString();
  } catch {
    return base;
  }
};
