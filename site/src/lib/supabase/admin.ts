import { createClient } from "@supabase/supabase-js";
import { env } from "@/lib/env";

export const createSupabaseAdminClient = () => {
  if (!env.serviceRoleKey) {
    throw new Error("Missing env: SUPABASE_SERVICE_ROLE_KEY");
  }
  return createClient(env.supabaseUrl, env.serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
};
