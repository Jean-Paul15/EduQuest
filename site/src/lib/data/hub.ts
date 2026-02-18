import { createSupabaseServerClient } from "@/lib/supabase/server";

type HubCounts = {
  contests: number;
  events: number;
  live_classes: number;
  surveys: number;
};

export const getHubCounts = async () => {
  const supabase = await createSupabaseServerClient();
  const [contests, events, lives, surveys] = await Promise.all([
    supabase.from("contests").select("id", { count: "exact", head: true }),
    supabase.from("events").select("id", { count: "exact", head: true }),
    supabase
      .from("live_classes")
      .select("id", { count: "exact", head: true })
      .eq("is_visible", true),
    supabase
      .from("surveys")
      .select("id", { count: "exact", head: true })
      .eq("is_visible", true),
  ]);
  return {
    contests: contests.count ?? 0,
    events: events.count ?? 0,
    live_classes: lives.count ?? 0,
    surveys: surveys.count ?? 0,
  } satisfies HubCounts;
};
