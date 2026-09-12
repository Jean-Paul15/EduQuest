import { createSupabaseAdminClient } from "@/lib/supabase/admin";
import type { SiteAnalyticsEvent } from "@/lib/analytics/events";

type Args = {
  name: SiteAnalyticsEvent;
  profileId?: string | null;
  category?: string;
  payload?: Record<string, unknown>;
  source?: string;
};

export const recordServerEvent = async ({
  name,
  profileId = null,
  category,
  payload,
  source = "site",
}: Args) => {
  try {
    const admin = createSupabaseAdminClient();
    await admin.rpc("ingest_app_events", {
      batch: [{
        profile_id: profileId,
        session_id: crypto.randomUUID(),
        event_name: name,
        event_category: category ?? inferCategory(name),
        event_source: source,
        event_version: 1,
        event_time: new Date().toISOString(),
        platform: "web",
        connection_type: "server",
        device_type: "web",
        dedupe_key: crypto.randomUUID(),
        is_offline: false,
        payload: cleanPayload(payload ?? {}),
      }],
    });
  } catch {}
};

const inferCategory = (name: string) => {
  if (name.startsWith("login_")) return "auth";
  if (name.startsWith("app_handoff_")) return "session";
  if (name.startsWith("payment_") || name === "checkout_started") return "payment";
  return "site";
};

const cleanPayload = (payload: Record<string, unknown>) =>
  Object.fromEntries(
    Object.entries(payload).flatMap(([key, value]) => {
      if (value == null) return [];
      if (typeof value === "string" || typeof value === "number" || typeof value === "boolean") {
        return [[key, value]];
      }
      return [[key, String(value)]];
    }),
  );
