"use client";

import { useCallback, useEffect, useState } from "react";
import { Card } from "@/components/ui/card";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

const asInt = (x: number | null | undefined) => Number(x || 0);

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
      <p className={`font-semibold ${n > 0 ? "text-orange-600" : "text-emerald-600"}`}>{n}</p>
    </div>
  );

  return (
    <Card className="space-y-2 p-4">
      <h2 className="font-semibold">Alertes opérationnelles</h2>
      {line("Push utilisateur en échec", values.pushFailed)}
      {line("Campagnes push en échec", values.campaignsFailed)}
      {line("Paiements events en attente", values.eventPay)}
      {line("Paiements concours en attente", values.contestPay)}
      {line("Tickets expirés activés", values.expiredTickets)}
    </Card>
  );
};
