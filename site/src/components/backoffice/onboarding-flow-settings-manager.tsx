"use client";

import { useCallback, useEffect, useState } from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

type OnboardingFlow = {
  enabled: boolean; blocking: boolean; require_terms: boolean;
  screens: string[]; hero_title: string; hero_subtitle: string;
};
const base: OnboardingFlow = {
  enabled: true, blocking: true, require_terms: true,
  screens: ["vision", "apprendre", "tickets", "gamification", "conditions"],
  hero_title: "Bienvenue sur EduQuest", hero_subtitle: "Ton parcours scolaire, piloté chaque jour.",
};

export const OnboardingFlowSettingsManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [cfg, setCfg] = useState<OnboardingFlow>(base);
  const [screensCsv, setScreensCsv] = useState(base.screens.join(","));
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const r = await supabase.from("app_config").select("value").eq("key", "onboarding_flow").maybeSingle();
    const next = { ...base, ...((r.data?.value as Partial<OnboardingFlow>) || {}) };
    setCfg(next); setScreensCsv((next.screens || []).join(","));
  }, [supabase]);
  useEffect(() => { const id = window.setTimeout(() => { void load(); }, 0); return () => window.clearTimeout(id); }, [load]);

  const save = async () => {
    const screens = screensCsv.split(",").map((x) => x.trim()).filter((x) => x.length > 0);
    const value = { ...cfg, screens: screens.length ? screens : base.screens };
    const r = await supabase.from("app_config").upsert({ key: "onboarding_flow", value });
    setMessage(r.error ? r.error.message : "Onboarding enregistré.");
  };

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Onboarding: ordre et blocage</h2>
      {(["enabled", "blocking", "require_terms"] as const).map((k) => (
        <label key={k} className="flex items-center justify-between rounded border p-2 text-sm"><span>{k}</span><input type="checkbox" checked={cfg[k]} onChange={(e) => setCfg({ ...cfg, [k]: e.target.checked })} /></label>
      ))}
      <input value={cfg.hero_title} onChange={(e) => setCfg({ ...cfg, hero_title: e.target.value })} className="w-full rounded border p-2 text-sm" />
      <input value={cfg.hero_subtitle} onChange={(e) => setCfg({ ...cfg, hero_subtitle: e.target.value })} className="w-full rounded border p-2 text-sm" />
      <input value={screensCsv} onChange={(e) => setScreensCsv(e.target.value)} className="w-full rounded border p-2 text-sm" />
      <Button onClick={save}>Enregistrer</Button>
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
