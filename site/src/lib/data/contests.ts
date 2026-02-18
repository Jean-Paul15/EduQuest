import { createSupabaseServerClient } from "@/lib/supabase/server";

export type ContestRow = {
  id: string;
  title: string;
  rules_md: string;
  starts_at: string;
  ends_at: string;
  venue: string | null;
  logo_url: string | null;
  location_lat: number | null;
  location_lng: number | null;
  fee_full: number | null;
  fee_half: number | null;
  fee_free: number | null;
  fee_campaign_free: number | null;
};

export type ContestEntry = {
  contest_id: string;
  status: string;
  attendance_fee: number | null;
  qr_code: string | null;
};

export const listContests = async () => {
  const supabase = await createSupabaseServerClient();
  const { data } = await supabase
    .from("contests")
    .select("id,title,rules_md,starts_at,ends_at,venue,logo_url,location_lat,location_lng,fee_full,fee_half,fee_free,fee_campaign_free")
    .eq("is_visible", true)
    .order("starts_at", { ascending: true })
    .returns<ContestRow[]>();
  return data ?? [];
};

export const listMyContestEntries = async () => {
  const supabase = await createSupabaseServerClient();
  const { data } = await supabase
    .from("contest_entries")
    .select("contest_id,status,attendance_fee,qr_code")
    .returns<ContestEntry[]>();
  return data ?? [];
};
