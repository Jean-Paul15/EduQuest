"use client";

import { useCallback, useEffect, useState } from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

type Feed = { courses: boolean; contests: boolean; events: boolean; courses_limit: number; contests_limit: number; events_limit: number };

export const FeedModulesManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [feed, setFeed] = useState<Feed>({ courses: true, contests: true, events: true, courses_limit: 8, contests_limit: 5, events_limit: 5 });
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const r = await supabase.from("app_config").select("value").eq("key", "feed_modules").maybeSingle();
    const v = (r.data?.value as Record<string, unknown>) || {};
    setFeed({
      courses: v.courses !== false,
      contests: v.contests !== false,
      events: v.events !== false,
      courses_limit: Number(v.courses_limit || 8),
      contests_limit: Number(v.contests_limit || 5),
      events_limit: Number(v.events_limit || 5),
    });
  }, [supabase]);

  useEffect(() => {
    const id = window.setTimeout(() => { void load(); }, 0);
    return () => window.clearTimeout(id);
  }, [load]);

  const save = async () => {
    const value = { ...feed, courses_limit: Math.max(1, feed.courses_limit), contests_limit: Math.max(1, feed.contests_limit), events_limit: Math.max(1, feed.events_limit) };
    const r = await supabase.from("app_config").upsert({ key: "feed_modules", value });
    setMessage(r.error ? r.error.message : "Feed modules enregistrés.");
  };
  const num = (k: "courses_limit" | "contests_limit" | "events_limit", v: string) => setFeed({ ...feed, [k]: Number(v) || 1 });

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Accueil: rubriques et quantités</h2>
      <p className="text-xs text-slate-500">Choisis ce qui s&apos;affiche sur la page d&apos;accueil et combien d&apos;éléments montrer.</p>
      <div className="grid gap-2 md:grid-cols-3">
        {([
          ["courses", "Cours"],
          ["contests", "Concours"],
          ["events", "Événements"],
        ] as const).map(([k, label]) => <label key={k} className="flex items-center justify-between rounded border p-2 text-sm"><span>{label}</span><input type="checkbox" checked={feed[k]} onChange={(e) => setFeed({ ...feed, [k]: e.target.checked })} /></label>)}
      </div>
      <div className="grid gap-2 md:grid-cols-3">
        <input value={feed.courses_limit} type="number" min={1} onChange={(e) => num("courses_limit", e.target.value)} placeholder="Nombre de cours" className="rounded border p-2 text-sm" />
        <input value={feed.contests_limit} type="number" min={1} onChange={(e) => num("contests_limit", e.target.value)} placeholder="Nombre de concours" className="rounded border p-2 text-sm" />
        <input value={feed.events_limit} type="number" min={1} onChange={(e) => num("events_limit", e.target.value)} placeholder="Nombre d'événements" className="rounded border p-2 text-sm" />
      </div>
      <Button onClick={save}>Enregistrer</Button>
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
