import { createSupabaseServerClient } from "@/lib/supabase/server";

type AccessState = {
  tier: string;
  has_access: boolean;
  expires_at: string | null;
};

type ProfileRow = {
  id: string;
  full_name: string | null;
  whatsapp_phone: string | null;
};

export const getViewerContext = async () => {
  const supabase = await createSupabaseServerClient();
  const { data: auth } = await supabase.auth.getUser();
  const user = auth.user ?? null;
  if (!user) return { user: null, profile: null, access: null };

  const [profileResult, accessResult] = await Promise.all([
    supabase
      .from("profiles")
      .select("id, full_name, whatsapp_phone")
      .eq("id", user.id)
      .single<ProfileRow>(),
    supabase.rpc("resolve_access_scope").single<AccessState>(),
  ]);

  return {
    user,
    profile: profileResult.data ?? null,
    access: accessResult.data ?? null,
  };
};
