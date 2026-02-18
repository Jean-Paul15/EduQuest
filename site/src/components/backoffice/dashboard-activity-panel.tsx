"use client";

import { useCallback, useEffect, useState } from "react";
import { Card } from "@/components/ui/card";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

type Item = { id: string; label: string; at: string; detail: string };
type Log = { id: string; status: string; provider: string; created_at: string };
type Audit = { id: string; action: string; created_at: string };
const fmt = (iso: string) => {
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return iso;
  return new Intl.DateTimeFormat("fr-FR", { dateStyle: "short", timeStyle: "short" }).format(d);
};
const actionLabel = (value: string) => {
  const map: Record<string, string> = {
    moderation_approved: "Contenu approuve",
    moderation_rejected: "Contenu rejete",
    support_ticket_updated: "Ticket support mis a jour",
    support_ticket_closed: "Ticket support cloture",
  };
  return map[value] || value.replaceAll("_", " ");
};
const pushLabel = (provider: string, status: string) => {
  const statusMap: Record<string, string> = {
    delivered: "envoye",
    failed: "en echec",
    queued: "en attente",
    retrying: "nouvelle tentative",
  };
  return `${provider} - ${statusMap[status] || status}`;
};

export const DashboardActivityPanel = () => {
  const supabase = getSupabaseBrowserClient();
  const [items, setItems] = useState<Item[]>([]);

  const load = useCallback(async () => {
    const [n, a] = await Promise.all([
      supabase.from("notification_dispatch_logs").select("id,status,provider,created_at").order("created_at", { ascending: false }).limit(8),
      supabase.from("compliance_audit_logs").select("id,action,created_at").order("created_at", { ascending: false }).limit(8),
    ]);
    const x = ((n.data || []) as Log[]).map((r) => ({
      id: `n-${r.id}`, label: "Push", at: r.created_at, detail: pushLabel(r.provider, r.status),
    }));
    const y = ((a.data || []) as Audit[]).map((r) => ({
      id: `a-${r.id}`, label: "Audit", at: r.created_at, detail: actionLabel(r.action),
    }));
    setItems([...x, ...y].sort((i, j) => String(j.at).localeCompare(String(i.at))).slice(0, 12));
  }, [supabase]);

  useEffect(() => {
    const id = window.setTimeout(() => { void load(); }, 0);
    return () => window.clearTimeout(id);
  }, [load]);

  return (
    <Card className="space-y-2 p-4">
      <h2 className="font-semibold">Activité récente</h2>
      <p className="text-xs text-slate-500">Dernières actions système et journal de conformité.</p>
      {!items.length ? <p className="rounded border border-dashed p-3 text-xs text-slate-500">Aucune activité récente détectée.</p> : null}
      {items.map((x) => (
        <div key={x.id} className="rounded border p-2 text-sm">
          <p className="font-medium">{x.label === "Push" ? "Envoi notification" : "Journal audit"}</p>
          <p className="text-xs text-slate-600">{x.detail}</p>
          <p className="text-[11px] text-slate-500">{fmt(x.at)}</p>
        </div>
      ))}
    </Card>
  );
};
