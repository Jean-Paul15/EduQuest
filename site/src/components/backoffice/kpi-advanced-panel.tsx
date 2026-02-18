"use client";

import { useCallback, useEffect, useState } from "react";
import { Card } from "@/components/ui/card";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

type Top = { event: string; count: number };
type Cohort = { cohort: string; users: number };
const eventLabel = (event: string) => {
  const map: Record<string, string> = {
    home_opened: "Accueil ouvert",
    feed_opened: "Feed ouvert",
    contests_opened: "Concours ouverts",
    events_opened: "Evenements ouverts",
    surveys_opened: "Sondages ouverts",
    feed_item_tapped: "Clic sur contenu feed",
    daily_checkin_claimed: "Check-in journalier valide",
    app_open: "Ouverture app",
    lesson_opened: "Cours ouvert",
    quiz_submitted: "Quiz soumis",
    ticket_activated: "Ticket active",
    active_24h: "Eleves actifs 24h",
    active_7d: "Eleves actifs 7j",
  };
  return map[event] || event.replaceAll("_", " ");
};

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
  const maxTop = Math.max(...top.map((x) => Number(x.count || 0)), 1);
  const maxCohort = Math.max(...cohorts.map((x) => Number(x.users || 0)), 1);

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Comportement des élèves</h2>
      <div className="grid gap-3 md:grid-cols-3">
        <div className="space-y-2 rounded border p-2">
          <p className="text-xs font-semibold">Fidélité</p>
          {Object.entries(ret).map(([k, v]) => <p key={k} className="text-xs text-slate-600">{eventLabel(k)}: <span className="font-semibold text-slate-900">{Number(v || 0)}</span></p>)}
        </div>
        <div className="space-y-2 rounded border p-2">
          <p className="text-xs font-semibold">Parcours sur 7 jours</p>
          {Object.entries(funnel).map(([k, v]) => <p key={k} className="text-xs text-slate-600">{eventLabel(k)}: <span className="font-semibold text-slate-900">{Number(v || 0)}</span></p>)}
        </div>
        <div className="space-y-2 rounded border p-2">
          <p className="text-xs font-semibold">Actions les plus fréquentes (7 jours)</p>
          {!top.length ? <p className="text-xs text-slate-500">Pas encore de donnees sur la periode.</p> : null}
          {top.map((x) => (
            <div key={x.event}>
              <div className="mb-1 flex justify-between text-[11px] text-slate-600"><span>{eventLabel(x.event)}</span><span>{x.count}</span></div>
              <div className="h-1.5 rounded-full bg-slate-100"><div className="h-full rounded-full bg-gradient-to-r from-orange-500 to-blue-500" style={{ width: `${(Number(x.count || 0) / maxTop) * 100}%` }} /></div>
            </div>
          ))}
        </div>
      </div>
      <div className="space-y-2 rounded border p-2">
        <p className="text-xs font-semibold">Progression par semaines</p>
        {!cohorts.length ? <p className="text-xs text-slate-500">Pas encore assez d&apos;historique pour afficher les cohortes.</p> : null}
        {cohorts.map((x) => (
          <div key={x.cohort}>
            <div className="mb-1 flex justify-between text-[11px] text-slate-600"><span>{x.cohort}</span><span>{x.users}</span></div>
            <div className="h-1.5 rounded-full bg-slate-100"><div className="h-full rounded-full bg-gradient-to-r from-blue-500 to-orange-500" style={{ width: `${(Number(x.users || 0) / maxCohort) * 100}%` }} /></div>
          </div>
        ))}
      </div>
    </Card>
  );
};
