"use client";

import { useCallback, useEffect, useState } from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

type Rule = {
  id: string; code: string; label: string; trigger_type: string; schedule_cron: string | null; active: boolean; last_run_at: string | null;
  depends_on_rule_id: string | null; max_retries: number; retry_backoff_min: number;
};
type Run = { status: string; details: Record<string, unknown>; created_at: string };
const triggerLabel = (v: string) =>
  ({
    cron: "Programmé",
    manual: "Manuel",
    event: "Événement",
  }[v] || v);
const statusLabel = (v: string) =>
  ({
    success: "Réussi",
    failed: "Échec",
    running: "En cours",
  }[v] || v);

export const AutomationRulesManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [rules, setRules] = useState<Rule[]>([]); const [runs, setRuns] = useState<Run[]>([]);
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const [r, n] = await Promise.all([
      supabase.from("automation_rules").select("id,code,label,trigger_type,schedule_cron,active,last_run_at,depends_on_rule_id,max_retries,retry_backoff_min").order("created_at"),
      supabase.from("automation_runs").select("status,details,created_at").order("created_at", { ascending: false }).limit(25),
    ]);
    setRules((r.data as Rule[]) || []); setRuns((n.data as Run[]) || []);
  }, [supabase]);
  useEffect(() => { const id = window.setTimeout(() => { void load(); }, 0); return () => window.clearTimeout(id); }, [load]);

  const toggle = async (x: Rule) => {
    const r = await supabase.from("automation_rules").update({ active: !x.active }).eq("id", x.id);
    setMessage(r.error ? r.error.message : "Règle mise à jour.");
    if (!r.error) await load();
  };
  const runOne = async (x: Rule) => {
    const r = await supabase.rpc("run_automation_rule", { p_rule_id: x.id });
    setMessage(r.error ? r.error.message : (r.data?.message || "Règle exécutée."));
    if (!r.error) await load();
  };
  const runAll = async () => {
    const r = await supabase.rpc("run_due_automation_rules");
    setMessage(r.error ? r.error.message : `Règles traitées: ${r.data?.processed || 0}`);
    if (!r.error) await load();
  };
  const save = async (x: Rule) => {
    const r = await supabase.from("automation_rules").update({
      depends_on_rule_id: x.depends_on_rule_id || null,
      max_retries: Math.max(1, Number(x.max_retries || 1)),
      retry_backoff_min: Math.max(1, Number(x.retry_backoff_min || 1)),
    }).eq("id", x.id);
    setMessage(r.error ? r.error.message : "Règle sauvegardée.");
    if (!r.error) await load();
  };
  const upd = (id: string, p: Partial<Rule>) => setRules((v) => v.map((x) => x.id === id ? { ...x, ...p } : x));

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Actions automatiques</h2>
      <Button onClick={runAll}>Exécuter les règles actives</Button>
      {rules.map((x) => <div key={x.id} className="rounded border p-2 text-sm"><p>{x.label || x.code} • {triggerLabel(x.trigger_type)} • {x.schedule_cron || "Sans horaire"} • Dernière exécution: {x.last_run_at || "jamais"}</p><div className="mt-2 grid gap-2 md:grid-cols-3"><select value={x.depends_on_rule_id || ""} onChange={(e) => upd(x.id, { depends_on_rule_id: e.target.value || null })} className="rounded border p-1 text-xs"><option value="">Aucune dépendance</option>{rules.filter((r) => r.id !== x.id).map((r) => <option key={r.id} value={r.id}>{r.label || r.code}</option>)}</select><input type="number" min={1} value={x.max_retries || 3} onChange={(e) => upd(x.id, { max_retries: Number(e.target.value) || 1 })} placeholder="Nombre de tentatives" className="rounded border p-1 text-xs" /><input type="number" min={1} value={x.retry_backoff_min || 15} onChange={(e) => upd(x.id, { retry_backoff_min: Number(e.target.value) || 1 })} placeholder="Pause entre tentatives (min)" className="rounded border p-1 text-xs" /></div><div className="mt-2 flex gap-2"><Button variant="outline" onClick={() => runOne(x)}>Lancer</Button><Button variant="outline" onClick={() => toggle(x)}>{x.active ? "Actif" : "Inactif"}</Button><Button variant="outline" onClick={() => save(x)}>Enregistrer</Button></div></div>)}
      {runs.map((x, i) => <p key={i} className="text-xs text-slate-600">{x.created_at} • {statusLabel(x.status)}</p>)}
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
