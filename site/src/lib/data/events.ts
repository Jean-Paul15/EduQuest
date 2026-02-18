import { createSupabaseServerClient } from "@/lib/supabase/server";

export type EventRow = {
  id: string;
  title: string;
  event_type: string;
  starts_at: string;
  venue: string | null;
  logo_url: string | null;
  meeting_url: string | null;
  location_lat: number | null;
  location_lng: number | null;
  public_fee: number | null;
  public_is_free: boolean | null;
  fee_full: number | null;
  fee_half: number | null;
  fee_free: number | null;
  fee_campaign_free: number | null;
};

export type EventRegistration = {
  event_id: string;
  status: string;
  attendance_fee: number | null;
  pass_code: string | null;
};

export const listEvents = async () => {
  const supabase = await createSupabaseServerClient();
  const { data } = await supabase
    .from("events")
    .select("id,title,event_type,starts_at,venue,logo_url,meeting_url,location_lat,location_lng,public_fee,public_is_free,fee_full,fee_half,fee_free,fee_campaign_free")
    .eq("is_visible", true)
    .order("starts_at", { ascending: true })
    .returns<EventRow[]>();
  return data ?? [];
};

export const listMyEventRegistrations = async () => {
  const supabase = await createSupabaseServerClient();
  const { data } = await supabase
    .from("event_registrations")
    .select("event_id,status,attendance_fee,pass_code")
    .returns<EventRegistration[]>();
  return data ?? [];
};
