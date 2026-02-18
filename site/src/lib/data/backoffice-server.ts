import { createSupabaseServerClient } from "@/lib/supabase/server";

type RpcSection = {
  section_id: string;
  section_key: string;
  section_label: string;
  section_path: string;
  section_icon: string | null;
  section_position: number;
};
type Section = {
  id: string;
  key: string;
  label: string;
  path: string;
  icon: string | null;
  position: number;
};

type Context = {
  user: { id: string; email?: string };
  mustReset: boolean;
  sections: Section[];
  admin: boolean;
};

export const loadBackofficeContext = async (): Promise<Context | null> => {
  const supabase = await createSupabaseServerClient();
  const { data: auth } = await supabase.auth.getUser();
  if (!auth.user) return null;

  const [profile, sections, admin] = await Promise.all([
    supabase.from("profiles").select("must_reset_password").eq("id", auth.user.id).single(),
    supabase.rpc("list_backoffice_sections"),
    supabase.rpc("is_backoffice_admin"),
  ]);

  const list = ((sections.data ?? []) as RpcSection[])
    .map((s) => ({
      id: s.section_id,
      key: s.section_key,
      label: s.section_label,
      path: s.section_path,
      icon: s.section_icon,
      position: s.section_position,
    }))
    .sort((a, b) => a.position - b.position);
  if (list.length === 0) return null;

  return {
    user: { id: auth.user.id, email: auth.user.email ?? undefined },
    mustReset: profile.data?.must_reset_password == true,
    sections: list,
    admin: admin.data == true,
  };
};
