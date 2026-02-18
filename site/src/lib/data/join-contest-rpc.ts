import type { SupabaseClient } from "@supabase/supabase-js";

type Json = Record<string, unknown>;

const isMissingOverload = (text: string) =>
  text.includes("42883") || (text.includes("function") && text.includes("join_contest"));

export const joinContestRpc = async (supabase: SupabaseClient, contestId: string) => {
  try {
    const first = await supabase.rpc("join_contest", {
      p_contest_id: contestId,
      p_whatsapp: "",
    });
    if (!first.error) {
      return { data: (first.data ?? null) as Json | null, error: null as string | null };
    }
    const msg = String(first.error.message || "").toLowerCase();
    if (!isMissingOverload(msg)) {
      return { data: null, error: first.error.message };
    }
  } catch (e) {
    const msg = String(e).toLowerCase();
    if (!isMissingOverload(msg)) {
      return { data: null, error: String(e) };
    }
  }

  const second = await supabase.rpc("join_contest", { p_contest_id: contestId });
  if (second.error) return { data: null, error: second.error.message };
  return { data: (second.data ?? null) as Json | null, error: null as string | null };
};
