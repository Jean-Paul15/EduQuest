"use client";

import { useCallback, useEffect, useState } from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

type Row = { profile_id: string; score: number; rank: number; reward_granted: boolean };
type Policy = { enabled: boolean; reward_kind: string; xp_amount: number; min_score: number; reward_note: string };
const week = () => { const d = new Date(); const y = d.getUTCFullYear(); const n = Math.ceil((((Date.UTC(y, d.getUTCMonth(), d.getUTCDate()) - Date.UTC(y, 0, 1)) / 86400000) + 1) / 7); return `${y}-${String(n).padStart(2, "0")}`; };
const rewardLabel = (v: string) =>
  ({ XP: "Points (XP)", TICKET_HALF_7D: "Accès partiel 7 jours", TICKET_FULL_7D: "Accès complet 7 jours" }[v] || v);

export const WeeklyRewardsManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [period, setPeriod] = useState(week());
  const [policy, setPolicy] = useState<Policy>({ enabled: false, reward_kind: "XP", xp_amount: 100, min_score: 20, reward_note: "Cadeau hebdo" });
  const [rows, setRows] = useState<Row[]>([]);
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const [p, r] = await Promise.all([
      supabase.from("weekly_reward_policies").select("enabled,reward_kind,xp_amount,min_score,reward_note").eq("period_key", period).maybeSingle(),
      supabase.from("weekly_reward_results").select("profile_id,score,rank,reward_granted").eq("period_key", period).order("rank").limit(20),
    ]);
    if (p.data) setPolicy({ enabled: !!p.data.enabled, reward_kind: String(p.data.reward_kind || "XP"), xp_amount: Number(p.data.xp_amount || 100), min_score: Number(p.data.min_score || 20), reward_note: String(p.data.reward_note || "Cadeau hebdo") });
    setRows((r.data as Row[]) || []);
  }, [period, supabase]);
  useEffect(() => { const id = window.setTimeout(() => { void load(); }, 0); return () => window.clearTimeout(id); }, [load]);

  const save = async () => {
    const r = await supabase.from("weekly_reward_policies").upsert({ period_key: period, ...policy });
    setMessage(r.error ? r.error.message : "Règles de la semaine enregistrées.");
  };
  const build = async () => { const r = await supabase.rpc("build_weekly_reward_results", { p_period_key: period }); setMessage(r.error ? r.error.message : "Classement hebdo régénéré."); if (!r.error) await load(); };
  const gift = async (profileId: string) => {
    const r = await supabase.rpc("grant_weekly_gift", { p_period_key: period, p_profile_id: profileId });
    setMessage(r.error ? r.error.message : (r.data?.message || "Cadeau attribué."));
    if (!r.error) await load();
  };

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Récompense hebdomadaire</h2>
      <input value={period} onChange={(e) => setPeriod(e.target.value)} placeholder="Semaine (ex: 2026-08)" className="w-full rounded border p-2 text-sm" />
      <div className="grid gap-2 md:grid-cols-2">
        <select value={policy.reward_kind} onChange={(e) => setPolicy({ ...policy, reward_kind: e.target.value })} className="rounded border p-2 text-sm"><option value="XP">Points (XP)</option><option value="TICKET_HALF_7D">Accès partiel 7 jours</option><option value="TICKET_FULL_7D">Accès complet 7 jours</option></select>
        <input type="number" min={0} value={policy.xp_amount} onChange={(e) => setPolicy({ ...policy, xp_amount: Number(e.target.value) || 0 })} placeholder="Quantité de points" className="rounded border p-2 text-sm" />
        <input type="number" min={1} value={policy.min_score} onChange={(e) => setPolicy({ ...policy, min_score: Number(e.target.value) || 1 })} placeholder="Score minimum" className="rounded border p-2 text-sm" />
        <input value={policy.reward_note} onChange={(e) => setPolicy({ ...policy, reward_note: e.target.value })} placeholder="Note affichée à l'élève" className="rounded border p-2 text-sm" />
      </div>
      <label className="flex items-center gap-2 text-sm"><input type="checkbox" checked={policy.enabled} onChange={(e) => setPolicy({ ...policy, enabled: e.target.checked })} /> Activer la récompense cette semaine</label>
      <div className="flex gap-2"><Button onClick={save}>Enregistrer</Button><Button variant="outline" onClick={build}>Régénérer</Button></div>
      {rows.map((x) => <div key={x.profile_id} className="flex items-center justify-between rounded border p-2 text-sm"><p>#{x.rank} • Élève {x.profile_id.slice(0, 8)} • {x.score} pts • {rewardLabel(policy.reward_kind)}</p><Button variant="outline" onClick={() => gift(x.profile_id)} disabled={x.reward_granted}>{x.reward_granted ? "Déjà envoyé" : "Envoyer la récompense"}</Button></div>)}
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
