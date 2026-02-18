"use client";

import { useCallback, useEffect, useState } from "react";
import { AlertTriangle, CheckCircle2 } from "lucide-react";
import { Card } from "@/components/ui/card";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

const asInt = (x: number | null | undefined) => Number(x || 0);
const level = (n: number) => (n > 10 ? "Critique" : n > 0 ? "A traiter" : "OK");

export const DashboardAlertsPanel = () => {
  const supabase = getSupabaseBrowserClient();
  const [values, setValues] = useState({ pushFailed: 0, campaignsFailed: 0, eventPay: 0, contestPay: 0, expiredTickets: 0 });

  const count = useCallback(async (table: string, col?: string, val?: string) => {
    const q = supabase.from(table).select("id", { head: true, count: "exact" });
    const r = col ? await q.eq(col, val) : await q;
    return r.error ? 0 : asInt(r.count);
  }, [supabase]);

  const load = useCallback(async () => {
    const now = new Date().toISOString();
    const [pushFailed, campaignsFailed, eventPay, contestPay, expiredTickets] = await Promise.all([
      count("user_notifications", "push_status", "failed"),
      count("notification_campaigns", "status", "failed"),
      count("event_registrations", "status", "pending_payment"),
      count("contest_entries", "status", "pending_payment"),
      supabase.from("ticket_codes").select("id", { head: true, count: "exact" }).lt("expires_at", now).not("activated_by", "is", null),
    ]);
    setValues({
      pushFailed,
      campaignsFailed,
      eventPay,
      contestPay,
      expiredTickets: expiredTickets.error ? 0 : asInt(expiredTickets.count),
    });
  }, [count, supabase]);

  useEffect(() => {
    const id = window.setTimeout(() => { void load(); }, 0);
    return () => window.clearTimeout(id);
  }, [load]);

  const line = (label: string, n: number) => (
    <div className="flex items-center justify-between rounded border p-2 text-sm">
      <p>{label}</p>
      <div className="flex items-center gap-2">
        <span className={`rounded-full px-2 py-0.5 text-[10px] font-semibold ${n > 10 ? "bg-red-100 text-red-700" : n > 0 ? "bg-orange-100 text-orange-700" : "bg-emerald-100 text-emerald-700"}`}>{level(n)}</span>
        <p className={`font-semibold ${n > 0 ? "text-orange-600" : "text-emerald-600"}`}>{n}</p>
      </div>
    </div>
  );

  return (
    <Card className="space-y-2 p-4">
      <h2 className="font-semibold">Alertes opérationnelles</h2>
      <p className="text-xs text-slate-500">Indicateurs qui demandent une action immédiate.</p>
      {line("Notifications push en échec", values.pushFailed)}
      {line("Campagnes push en échec", values.campaignsFailed)}
      {line("Paiements événements en attente", values.eventPay)}
      {line("Paiements concours en attente", values.contestPay)}
      {line("Tickets activés mais expirés", values.expiredTickets)}
      <div className="rounded-xl border border-slate-200 bg-white p-2 text-xs text-slate-600">
        <p className="font-semibold text-slate-700">Actions conseillées:</p>
        <p>1. Traiter d&apos;abord les paiements en attente.</p>
        <p>2. Relancer les campagnes en échec.</p>
        <p>3. Vérifier les tickets expirés activés.</p>
      </div>
      <div className="rounded-xl border border-slate-200 bg-slate-50 p-2 text-xs">
        {Object.values(values).some((n) => n > 0) ? (
          <p className="flex items-center gap-1 text-orange-700"><AlertTriangle className="h-3.5 w-3.5" />Des éléments nécessitent un traitement.</p>
        ) : (
          <p className="flex items-center gap-1 text-emerald-700"><CheckCircle2 className="h-3.5 w-3.5" />Aucune alerte critique actuellement.</p>
        )}
      </div>
    </Card>
  );
};
