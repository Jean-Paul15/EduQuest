"use client";

import { useCallback, useEffect, useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

type Result = { profile_id: string; score: number; rank: number; reward_granted: boolean };

const monthKey = () => {
  const d = new Date(); return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}`;
};

export const MonthlyRewardsManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [period, setPeriod] = useState(monthKey()); const [enabled, setEnabled] = useState(false);
  const [note, setNote] = useState("Cadeau gagnant"); const [min, setMin] = useState(40);
  const [rows, setRows] = useState<Result[]>([]); const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const [p, r] = await Promise.all([
      supabase.from("monthly_reward_policies").select("enabled,reward_note,min_score").eq("period_key", period).maybeSingle(),
      supabase.from("monthly_reward_results").select("profile_id,score,rank,reward_granted").eq("period_key", period).order("rank").limit(20),
    ]);
    if (p.data) { setEnabled(!!p.data.enabled); setNote(String(p.data.reward_note || "")); setMin(Number(p.data.min_score || 40)); }
    setRows((r.data as Result[]) || []);
  }, [period, supabase]);

  useEffect(() => { const id = window.setTimeout(() => { void load(); }, 0); return () => window.clearTimeout(id); }, [load]);

  const savePolicy = async () => {
    const r = await supabase.from("monthly_reward_policies").upsert({ period_key: period, enabled, reward_note: note, min_score: min });
    setMessage(r.error ? r.error.message : "Politique enregistrée.");
  };
  const run = async () => { const r = await supabase.rpc("build_monthly_reward_results", { p_period_key: period }); setMessage(r.error ? r.error.message : "Classement régénéré."); if (!r.error) await load(); };

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Récompenses mensuelles</h2>
      <input value={period} onChange={(e) => setPeriod(e.target.value)} className="w-full rounded border p-2 text-sm" />
      <div className="grid grid-cols-2 gap-2"><input value={min} type="number" min={1} onChange={(e) => setMin(Number(e.target.value) || 1)} className="rounded border p-2 text-sm" /><input value={note} onChange={(e) => setNote(e.target.value)} className="rounded border p-2 text-sm" /></div>
      <label className="flex items-center gap-2 text-sm"><input type="checkbox" checked={enabled} onChange={(e) => setEnabled(e.target.checked)} /> Récompense active</label>
      <div className="flex gap-2"><Button onClick={savePolicy}>Enregistrer</Button><Button onClick={run} variant="outline">Régénérer</Button></div>
      {rows.map((x, i) => <p key={i} className="text-xs text-slate-600">#{x.rank} • {x.profile_id} • score {x.score}</p>)}
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
