"use client";

import { useState } from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

const keys = [
  "app_links", "auth_options", "hub_modules", "learning_access", "learning_security", "feed_modules", "app_update_policy",
  "push_display_defaults", "offline_cache_policy", "security_advanced", "onboarding_flow", "gamification_tuning",
  "payment_provider_config",
];

export const AppConfigBackupManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [json, setJson] = useState("{}");
  const [message, setMessage] = useState("");

  const load = async () => {
    const r = await supabase.from("app_config").select("key,value").in("key", keys);
    const out: Record<string, unknown> = {};
    (r.data || []).forEach((x: { key: string; value: unknown }) => { out[x.key] = x.value || {}; });
    setJson(JSON.stringify(out, null, 2));
    setMessage("Sauvegarde chargée.");
  };

  const apply = async () => {
    try {
      const parsed = JSON.parse(json) as Record<string, unknown>;
      const payload = Object.entries(parsed).filter(([k]) => keys.includes(k)).map(([key, value]) => ({ key, value }));
      const r = await supabase.from("app_config").upsert(payload);
      setMessage(r.error ? r.error.message : "Restauration appliquée.");
    } catch {
      setMessage("Format invalide.");
    }
  };

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Sauvegarde des réglages</h2>
      <textarea value={json} onChange={(e) => setJson(e.target.value)} className="h-52 w-full rounded border p-2 font-mono text-xs" />
      <div className="flex gap-2">
        <Button onClick={load}>Charger la sauvegarde</Button>
        <Button variant="outline" onClick={apply}>Appliquer la restauration</Button>
      </div>
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
