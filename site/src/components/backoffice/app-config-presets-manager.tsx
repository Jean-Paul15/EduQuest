"use client";

import { useState } from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

const presets: Record<string, Record<string, unknown>> = {
  open_week: {
    hub_modules: { live: true, contests: true, events: true, surveys: true, notifications: true, referral: true, market: true, leaderboard: true, orientation: true },
    learning_access: { courses: "FREE", exams: "FREE", epreuves: "FREE", mockExams: "FREE", videos: "FREE", youtube: "FREE" },
    learning_security: { capture_allowed: true, keep_awake: true },
    feed_modules: { courses: true, contests: true, events: true, courses_limit: 12, contests_limit: 8, events_limit: 8 },
  },
  strict_secure: {
    learning_security: { capture_allowed: false, keep_awake: true },
    learning_access: { courses: "HALF", exams: "HALF", epreuves: "HALF", mockExams: "FULL", videos: "HALF", youtube: "HALF" },
  },
  minimal_hub: {
    hub_modules: { live: true, contests: true, events: true, surveys: false, notifications: true, referral: false, market: false, leaderboard: true, orientation: false },
    feed_modules: { courses: true, contests: true, events: true, courses_limit: 6, contests_limit: 4, events_limit: 4 },
  },
};

export const AppConfigPresetsManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [message, setMessage] = useState("");

  const apply = async (name: keyof typeof presets) => {
    const payload = Object.entries(presets[name]).map(([key, value]) => ({ key, value }));
    const r = await supabase.from("app_config").upsert(payload);
    setMessage(r.error ? r.error.message : `Preset appliqué: ${name}`);
  };

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Presets configuration (1-clic)</h2>
      <div className="flex flex-wrap gap-2">
        <Button onClick={() => apply("open_week")}>Promo ouverte</Button>
        <Button variant="outline" onClick={() => apply("strict_secure")}>Mode strict</Button>
        <Button variant="outline" onClick={() => apply("minimal_hub")}>Hub minimal</Button>
      </div>
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
