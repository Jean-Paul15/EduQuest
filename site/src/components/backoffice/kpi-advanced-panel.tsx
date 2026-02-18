"use client";

import { useCallback, useEffect, useState } from "react";
import { Card } from "@/components/ui/card";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

type Top = { event: string; count: number };
type Cohort = { cohort: string; users: number };

export const KpiAdvancedPanel = () => {
  const supabase = getSupabaseBrowserClient();
  const [top, setTop] = useState<Top[]>([]); const [cohorts, setCohorts] = useState<Cohort[]>([]);
  const [funnel, setFunnel] = useState<Record<string, number>>({}); const [ret, setRet] = useState<Record<string, number>>({});

  const load = useCallback(async () => {
    const r = await supabase.rpc("backoffice_kpi_advanced");
    const d = (r.data || {}) as Record<string, unknown>;
    setTop((d.top_actions_7d as Top[]) || []);
    setCohorts((d.cohorts_8w as Cohort[]) || []);
    setFunnel((d.funnel_7d as Record<string, number>) || {});
    setRet((d.retention as Record<string, number>) || {});
  }, [supabase]);
  useEffect(() => { const id = window.setTimeout(() => { void load(); }, 0); return () => window.clearTimeout(id); }, [load]);
  const line = (k: string, v: number) => <p key={k} className="text-xs text-slate-600">{k}: {Number(v || 0)}</p>;

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">KPI avancés (rétention/cohortes/funnel)</h2>
      <div className="grid gap-3 md:grid-cols-3">
        <div className="rounded border p-2"><p className="text-xs font-semibold">Rétention</p>{Object.entries(ret).map(([k, v]) => line(k, Number(v || 0)))}</div>
        <div className="rounded border p-2"><p className="text-xs font-semibold">Funnel 7j</p>{Object.entries(funnel).map(([k, v]) => line(k, Number(v || 0)))}</div>
        <div className="rounded border p-2"><p className="text-xs font-semibold">Top actions 7j</p>{top.map((x) => <p key={x.event} className="text-xs text-slate-600">{x.event}: {x.count}</p>)}</div>
      </div>
      <div className="rounded border p-2">
        <p className="text-xs font-semibold">Cohortes 8 semaines</p>
        {cohorts.map((x) => <p key={x.cohort} className="text-xs text-slate-600">{x.cohort}: {x.users}</p>)}
      </div>
    </Card>
  );
};
