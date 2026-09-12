"use client";

import { useCallback, useEffect, useState } from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

type OnboardingFlow = {
  enabled: boolean; blocking: boolean; require_terms: boolean;
  screens: string[]; hero_title: string; hero_subtitle: string;
};
type FreeAccessPolicy = {
  trial_enabled: boolean; trial_days: number; free_offer_code: string;
  orientation_enabled: boolean; assistant_daily_limit: number;
};
const base: OnboardingFlow = {
  enabled: true, blocking: true, require_terms: true,
  screens: ["vision", "apprendre", "tickets", "gamification", "conditions"],
  hero_title: "Bienvenue sur EduQuest", hero_subtitle: "Ton parcours scolaire, piloté chaque jour.",
};
const policyBase: FreeAccessPolicy = {
  trial_enabled: true, trial_days: 14, free_offer_code: "FREE_LIGHT",
  orientation_enabled: true, assistant_daily_limit: 6,
};

export const OnboardingFlowSettingsManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [cfg, setCfg] = useState<OnboardingFlow>(base);
  const [policy, setPolicy] = useState<FreeAccessPolicy>(policyBase);
  const [screensCsv, setScreensCsv] = useState(base.screens.join(","));
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const [r, p] = await Promise.all([
      supabase.from("app_config").select("value").eq("key", "onboarding_flow").maybeSingle(),
      supabase.from("app_config").select("value").eq("key", "free_access_policy").maybeSingle(),
    ]);
    const next = { ...base, ...((r.data?.value as Partial<OnboardingFlow>) || {}) };
    const nextPolicy = { ...policyBase, ...((p.data?.value as Partial<FreeAccessPolicy>) || {}) };
    setCfg(next); setScreensCsv((next.screens || []).join(","));
    setPolicy(nextPolicy);
  }, [supabase]);
  useEffect(() => { const id = window.setTimeout(() => { void load(); }, 0); return () => window.clearTimeout(id); }, [load]);

  const save = async () => {
    const screens = screensCsv.split(",").map((x) => x.trim()).filter((x) => x.length > 0);
    const value = { ...cfg, screens: screens.length ? screens : base.screens };
    const [r, p] = await Promise.all([
      supabase.from("app_config").upsert({ key: "onboarding_flow", value }),
      supabase.from("app_config").upsert({ key: "free_access_policy", value: policy }),
    ]);
    setMessage(r.error?.message || p.error?.message || "Onboarding et accès gratuit enregistrés.");
  };

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Première ouverture de l&apos;app</h2>
      {([
        ["enabled", "Activer le parcours d'accueil"],
        ["blocking", "Obliger le parcours complet"],
        ["require_terms", "Demander l'acceptation des conditions"],
      ] as const).map(([k, label]) => (
        <label key={k} className="flex items-center justify-between rounded border p-2 text-sm"><span>{label}</span><input type="checkbox" checked={cfg[k]} onChange={(e) => setCfg({ ...cfg, [k]: e.target.checked })} /></label>
      ))}
      <input value={cfg.hero_title} onChange={(e) => setCfg({ ...cfg, hero_title: e.target.value })} placeholder="Titre d'accueil" className="w-full rounded border p-2 text-sm" />
      <input value={cfg.hero_subtitle} onChange={(e) => setCfg({ ...cfg, hero_subtitle: e.target.value })} placeholder="Sous-titre d'accueil" className="w-full rounded border p-2 text-sm" />
      <input value={screensCsv} onChange={(e) => setScreensCsv(e.target.value)} placeholder="Étapes affichées (séparées par des virgules)" className="w-full rounded border p-2 text-sm" />
      <div className="rounded border p-3 text-sm">
        <p className="mb-2 font-medium">Essai gratuit et offre légère</p>
        <label className="mb-2 flex items-center justify-between"><span>Activer l&apos;essai onboarding</span><input type="checkbox" checked={policy.trial_enabled} onChange={(e) => setPolicy({ ...policy, trial_enabled: e.target.checked })} /></label>
        <div className="grid gap-2 md:grid-cols-3">
          <input value={policy.trial_days} onChange={(e) => setPolicy({ ...policy, trial_days: Number(e.target.value || 14) })} placeholder="Durée trial" className="rounded border p-2 text-sm" />
          <input value={policy.free_offer_code} onChange={(e) => setPolicy({ ...policy, free_offer_code: e.target.value })} placeholder="Code offre gratuite" className="rounded border p-2 text-sm" />
          <input value={policy.assistant_daily_limit} onChange={(e) => setPolicy({ ...policy, assistant_daily_limit: Number(e.target.value || 0) })} placeholder="Quota assistant/jour" className="rounded border p-2 text-sm" />
        </div>
      </div>
      <Button onClick={save}>Enregistrer</Button>
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
