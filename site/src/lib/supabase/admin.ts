import { createClient } from "@supabase/supabase-js";
import { env } from "@/lib/env";

export const createSupabaseAdminClient = () => {
  if (!env.supabaseSecretKey) {
    throw new Error("Missing env: SUPABASE_SECRET_KEYS");
  }
  return createClient(env.supabaseUrl, env.supabaseSecretKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
};
