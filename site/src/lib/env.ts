const clean = (v?: string) => {
  const x = (v || "").trim();
  return x.length > 0 ? x : undefined;
};

const req = (name: string, value?: string) => {
  if (!value) throw new Error(`Missing env: ${name}`);
  return value;
};

const isServer = typeof window === "undefined";
const pickFirstKey = (raw?: string) => {
  const value = clean(raw);
  if (!value) return undefined;
  try {
    const parsed = JSON.parse(value) as unknown;
    const queue = [parsed];
    while (queue.length > 0) {
      const current = queue.shift();
      if (typeof current === "string" && current.trim()) return current.trim();
      if (Array.isArray(current)) queue.push(...current);
      if (current && typeof current === "object") {
        const data = current as Record<string, unknown>;
        ["default", "web", "site", "client", "primary"].forEach((key) => {
          if (key in data) queue.unshift(data[key]);
        });
        Object.values(data).forEach((item) => queue.push(item));
      }
    }
  } catch {
    return value;
  }
  return undefined;
};

// Nouvelle convention Supabase : sb_publishable_/sb_secret_ (*_KEYS, JSON).
// Repli sur les anciens noms (anon/service_role) pour les environnements
// (ex. Vercel) pas encore migres, sans casser le build.
const nextPublicSupabaseUrl = clean(process.env.NEXT_PUBLIC_SUPABASE_URL);
const nextPublicPublishableKey =
  pickFirstKey(process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEYS) ??
  clean(process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY);

const serverSupabaseUrl = isServer ? clean(process.env.SUPABASE_URL) : undefined;
const serverPublishableKey = isServer
  ? pickFirstKey(process.env.SUPABASE_PUBLISHABLE_KEYS) ?? clean(process.env.SUPABASE_ANON_KEY)
  : undefined;
const serverSecretKey = isServer
  ? pickFirstKey(process.env.SUPABASE_SECRET_KEYS) ?? clean(process.env.SUPABASE_SERVICE_ROLE_KEY)
  : undefined;

export const env = {
  supabaseUrl: req("NEXT_PUBLIC_SUPABASE_URL", nextPublicSupabaseUrl ?? serverSupabaseUrl),
  supabasePublishableKey: req(
    "NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEYS",
    nextPublicPublishableKey ?? serverPublishableKey,
  ),
  siteUrl: clean(process.env.NEXT_PUBLIC_SITE_URL) ?? "https://edu.ruachnova.com",
  supabaseSecretKey: serverSecretKey,
  appDeepLink: clean(process.env.NEXT_PUBLIC_APP_DEEP_LINK) ?? "ruachedu://home",
  supportEmail: clean(process.env.NEXT_PUBLIC_SUPPORT_EMAIL) ?? "support@ruachnova.com",
  supportWhatsApp: clean(process.env.NEXT_PUBLIC_SUPPORT_WHATSAPP) ?? "https://wa.me/22800000000",
  ticketShopUrl: clean(process.env.NEXT_PUBLIC_TICKET_SHOP_URL) ?? "https://edu.ruachnova.com/tickets",
};
