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
  return (data ?? []).filter((item) => !!item.id && !!item.title).map((item) => ({
    ...item,
    title: String(item.title || "").trim(),
    event_type: String(item.event_type || "event"),
    venue: item.venue ? String(item.venue) : null,
    logo_url: item.logo_url ? String(item.logo_url) : null,
    meeting_url: item.meeting_url ? String(item.meeting_url) : null,
    public_fee: Number(item.public_fee || 0),
    fee_full: Number(item.fee_full || 0),
    fee_half: Number(item.fee_half || 0),
    fee_free: Number(item.fee_free || 0),
    fee_campaign_free: Number(item.fee_campaign_free || 0),
  }));
};

export const listMyEventRegistrations = async () => {
  const supabase = await createSupabaseServerClient();
  const { data } = await supabase
    .from("event_registrations")
    .select("event_id,status,attendance_fee,pass_code")
    .returns<EventRegistration[]>();
  return (data ?? []).filter((item) => !!item.event_id).map((item) => ({
    ...item,
    status: String(item.status || "pending"),
    attendance_fee: Number(item.attendance_fee || 0),
    pass_code: item.pass_code ? String(item.pass_code) : null,
  }));
};
