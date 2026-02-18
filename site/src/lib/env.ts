const clean = (v?: string) => {
  const x = (v || "").trim();
  return x.length > 0 ? x : undefined;
};

const req = (name: string, value?: string) => {
  if (!value) throw new Error(`Missing env: ${name}`);
  return value;
};

const isServer = typeof window === "undefined";

const nextPublicSupabaseUrl = clean(process.env.NEXT_PUBLIC_SUPABASE_URL);
const nextPublicSupabaseAnonKey = clean(process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY);

const serverSupabaseUrl = isServer ? clean(process.env.SUPABASE_URL) : undefined;
const serverSupabaseAnonKey = isServer ? clean(process.env.SUPABASE_ANON_KEY) : undefined;
const serverServiceRole = isServer ? clean(process.env.SUPABASE_SERVICE_ROLE_KEY) : undefined;

export const env = {
  supabaseUrl: req("NEXT_PUBLIC_SUPABASE_URL", nextPublicSupabaseUrl ?? serverSupabaseUrl),
  supabaseAnonKey: req("NEXT_PUBLIC_SUPABASE_ANON_KEY", nextPublicSupabaseAnonKey ?? serverSupabaseAnonKey),
  siteUrl: clean(process.env.NEXT_PUBLIC_SITE_URL) ?? "http://localhost:3000",
  serviceRoleKey: serverServiceRole,
  appDeepLink: clean(process.env.NEXT_PUBLIC_APP_DEEP_LINK) ?? "eduquest://home",
  supportEmail: clean(process.env.NEXT_PUBLIC_SUPPORT_EMAIL) ?? "support@eduquest.app",
  supportWhatsApp: clean(process.env.NEXT_PUBLIC_SUPPORT_WHATSAPP) ?? "https://wa.me/22800000000",
  ticketShopUrl: clean(process.env.NEXT_PUBLIC_TICKET_SHOP_URL) ?? "https://eduquest.tg/tickets",
};
