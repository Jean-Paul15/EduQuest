"use client";

import { useCallback, useEffect, useState } from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

type G = {
  xp_daily_checkin: number; xp_open_lesson: number; xp_complete_quiz: number;
  xp_review_15min: number; xp_referral_bonus: number; streak_bonus: number; reward_threshold: number;
};
const base: G = {
  xp_daily_checkin: 20, xp_open_lesson: 10, xp_complete_quiz: 20,
  xp_review_15min: 15, xp_referral_bonus: 50, streak_bonus: 25, reward_threshold: 500,
};

export const GamificationTuningManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [cfg, setCfg] = useState<G>(base);
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const r = await supabase.from("app_config").select("value").eq("key", "gamification_tuning").maybeSingle();
    setCfg({ ...base, ...((r.data?.value as Partial<G>) || {}) });
  }, [supabase]);
  useEffect(() => { const id = window.setTimeout(() => { void load(); }, 0); return () => window.clearTimeout(id); }, [load]);

  const save = async () => {
    const value = Object.fromEntries(Object.entries(cfg).map(([k, v]) => [k, Math.max(0, Number(v) || 0)]));
    const r = await supabase.from("app_config").upsert({ key: "gamification_tuning", value });
    setMessage(r.error ? r.error.message : "Gamification enregistrée.");
  };
  const n = (k: keyof G, v: string) => setCfg({ ...cfg, [k]: Number(v) || 0 });

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Points et récompenses</h2>
      <div className="grid gap-2 md:grid-cols-3">
        <input type="number" min={0} value={cfg.xp_daily_checkin} onChange={(e) => n("xp_daily_checkin", e.target.value)} placeholder="Points check-in quotidien" className="rounded border p-2 text-sm" />
        <input type="number" min={0} value={cfg.xp_open_lesson} onChange={(e) => n("xp_open_lesson", e.target.value)} placeholder="Points ouverture cours" className="rounded border p-2 text-sm" />
        <input type="number" min={0} value={cfg.xp_complete_quiz} onChange={(e) => n("xp_complete_quiz", e.target.value)} placeholder="Points quiz terminé" className="rounded border p-2 text-sm" />
        <input type="number" min={0} value={cfg.xp_review_15min} onChange={(e) => n("xp_review_15min", e.target.value)} placeholder="Points révision 15 min" className="rounded border p-2 text-sm" />
        <input type="number" min={0} value={cfg.xp_referral_bonus} onChange={(e) => n("xp_referral_bonus", e.target.value)} placeholder="Bonus parrainage" className="rounded border p-2 text-sm" />
        <input type="number" min={0} value={cfg.streak_bonus} onChange={(e) => n("streak_bonus", e.target.value)} placeholder="Bonus série de jours" className="rounded border p-2 text-sm" />
      </div>
      <input type="number" min={0} value={cfg.reward_threshold} onChange={(e) => n("reward_threshold", e.target.value)} placeholder="Seuil points pour récompense" className="w-full rounded border p-2 text-sm" />
      <Button onClick={save}>Enregistrer</Button>
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
