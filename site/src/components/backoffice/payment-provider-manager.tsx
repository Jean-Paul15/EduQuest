"use client";

import { useCallback, useEffect, useState } from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

type Cfg = { provider: string; webhook_tolerance_sec: number; signature_header: string; timestamp_header: string; event_id_field: string };
type Log = { provider: string; event_id: string; status: string; processed_at: string | null };
const base: Cfg = { provider: "generic", webhook_tolerance_sec: 300, signature_header: "x-payment-signature", timestamp_header: "x-payment-timestamp", event_id_field: "event_id" };

export const PaymentProviderManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [cfg, setCfg] = useState<Cfg>(base); const [logs, setLogs] = useState<Log[]>([]); const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const [c, l] = await Promise.all([
      supabase.from("app_config").select("value").eq("key", "payment_provider_config").maybeSingle(),
      supabase.from("payment_webhook_events").select("provider,event_id,status,processed_at").order("received_at", { ascending: false }).limit(25),
    ]);
    setCfg({ ...base, ...((c.data?.value as Partial<Cfg>) || {}) }); setLogs((l.data as Log[]) || []);
  }, [supabase]);
  useEffect(() => { const id = window.setTimeout(() => { void load(); }, 0); return () => window.clearTimeout(id); }, [load]);

  const save = async () => {
    const r = await supabase.from("app_config").upsert({ key: "payment_provider_config", value: cfg });
    setMessage(r.error ? r.error.message : "Config provider enregistrée.");
  };

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Paiement provider: webhook signé</h2>
      <div className="grid gap-2 md:grid-cols-2">
        <input value={cfg.provider} onChange={(e) => setCfg({ ...cfg, provider: e.target.value })} className="rounded border p-2 text-sm" />
        <input type="number" min={60} value={cfg.webhook_tolerance_sec} onChange={(e) => setCfg({ ...cfg, webhook_tolerance_sec: Number(e.target.value) || 60 })} className="rounded border p-2 text-sm" />
        <input value={cfg.signature_header} onChange={(e) => setCfg({ ...cfg, signature_header: e.target.value })} className="rounded border p-2 text-sm" />
        <input value={cfg.timestamp_header} onChange={(e) => setCfg({ ...cfg, timestamp_header: e.target.value })} className="rounded border p-2 text-sm" />
      </div>
      <input value={cfg.event_id_field} onChange={(e) => setCfg({ ...cfg, event_id_field: e.target.value })} className="w-full rounded border p-2 text-sm" />
      <Button onClick={save}>Enregistrer</Button>
      {logs.map((x, i) => <p key={i} className="text-xs text-slate-600">{x.provider} • {x.event_id} • {x.status} • {x.processed_at || "-"}</p>)}
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
