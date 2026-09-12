import { createSupabaseServerClient } from "@/lib/supabase/server";

export type LegalDocument = {
  title: string;
  version: string;
  body_md: string;
  published_at: string | null;
};

export const getActiveLegalDocument = async (
  docType: "terms" | "privacy",
): Promise<LegalDocument | null> => {
  const supabase = await createSupabaseServerClient();
  // Meme requete que l'app mobile (auth_repository) : pas de filtre locale,
  // pour rester synchronise avec ce qui s'affiche cote app.
  const { data } = await supabase
    .from("legal_documents")
    .select("title,version,body_md,published_at")
    .eq("doc_type", docType)
    .eq("active", true)
    .order("published_at", { ascending: false, nullsFirst: false })
    .limit(1)
    .maybeSingle();
  return data;
};
