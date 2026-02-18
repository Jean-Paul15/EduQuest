"use client";

import { useCallback, useEffect, useState } from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

type PushDisplay = {
  android_channel_id: string; android_sound: string; ios_sound: string;
  ios_interruption_level: string; ios_relevance_score: number; ttl: number;
  silent: boolean; priority: number;
};
const base: PushDisplay = {
  android_channel_id: "eduquest_alerts", android_sound: "default", ios_sound: "default",
  ios_interruption_level: "active", ios_relevance_score: 0.9, ttl: 86400, silent: false, priority: 10,
};

export const PushDisplayDefaultsManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [cfg, setCfg] = useState<PushDisplay>(base);
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const r = await supabase.from("app_config").select("value").eq("key", "push_display_defaults").maybeSingle();
    const v = (r.data?.value as Partial<PushDisplay>) || {};
    setCfg({ ...base, ...v });
  }, [supabase]);
  useEffect(() => { const id = window.setTimeout(() => { void load(); }, 0); return () => window.clearTimeout(id); }, [load]);

  const save = async () => {
    const value = { ...cfg, ttl: Math.max(60, cfg.ttl), ios_relevance_score: Math.max(0, Math.min(1, cfg.ios_relevance_score)) };
    const r = await supabase.from("app_config").upsert({ key: "push_display_defaults", value });
    setMessage(r.error ? r.error.message : "Préférences notifications enregistrées.");
  };
  const n = (k: "ttl" | "priority" | "ios_relevance_score", v: string) => setCfg({ ...cfg, [k]: Number(v) || 0 });

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Notifications: affichage par défaut</h2>
      <div className="grid gap-2 md:grid-cols-2">
        <input value={cfg.android_channel_id} onChange={(e) => setCfg({ ...cfg, android_channel_id: e.target.value })} placeholder="Canal Android" className="rounded border p-2 text-sm" />
        <select value={cfg.ios_interruption_level} onChange={(e) => setCfg({ ...cfg, ios_interruption_level: e.target.value })} className="rounded border p-2 text-sm"><option value="active">Standard</option><option value="time_sensitive">Prioritaire</option><option value="passive">Discret</option></select>
        <input value={cfg.android_sound} onChange={(e) => setCfg({ ...cfg, android_sound: e.target.value })} placeholder="Son Android" className="rounded border p-2 text-sm" />
        <input value={cfg.ios_sound} onChange={(e) => setCfg({ ...cfg, ios_sound: e.target.value })} placeholder="Son iPhone" className="rounded border p-2 text-sm" />
        <input type="number" min={60} value={cfg.ttl} onChange={(e) => n("ttl", e.target.value)} placeholder="Durée de vie message (secondes)" className="rounded border p-2 text-sm" />
        <input type="number" min={0} max={1} step="0.1" value={cfg.ios_relevance_score} onChange={(e) => n("ios_relevance_score", e.target.value)} placeholder="Importance (0 à 1)" className="rounded border p-2 text-sm" />
      </div>
      <label className="flex items-center justify-between rounded border p-2 text-sm"><span>Notification silencieuse</span><input type="checkbox" checked={cfg.silent} onChange={(e) => setCfg({ ...cfg, silent: e.target.checked })} /></label>
      <Button onClick={save}>Enregistrer</Button>
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
