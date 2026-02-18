"use client";

import { useCallback, useEffect, useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";
import { Card } from "@/components/ui/card";

type Row = {
  id: string; title: string; pricing_mode: string | null; required_ticket_type: string | null;
  fee_full: number | null; fee_half: number | null; fee_free: number | null; free_for_full: boolean | null; is_visible: boolean;
};

const line = (x: Row) => {
  const f = x.free_for_full ? 0 : Number(x.fee_full || 0);
  const h = Number(x.fee_half || 0); const n = Number(x.fee_free || 0);
  return x.pricing_mode === "OPEN_PRICED"
    ? `FULL ${f} • HALF ${h} • FREE ${n}`
    : `Ticket requis: ${x.required_ticket_type || "HALF/FULL"} (fallback paiement web)`;
};

export const PricingPreviewManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [contests, setContests] = useState<Row[]>([]); const [events, setEvents] = useState<Row[]>([]);

  const load = useCallback(async () => {
    const fields = "id,title,pricing_mode,required_ticket_type,fee_full,fee_half,fee_free,free_for_full,is_visible";
    const [c, e] = await Promise.all([
      supabase.from("contests").select(fields).order("starts_at", { ascending: false }).limit(20),
      supabase.from("events").select(fields).order("starts_at", { ascending: false }).limit(20),
    ]);
    setContests((c.data as Row[]) || []); setEvents((e.data as Row[]) || []);
  }, [supabase]);

  useEffect(() => { const id = window.setTimeout(() => { void load(); }, 0); return () => window.clearTimeout(id); }, [load]);

  const block = (label: string, rows: Row[]) => (
    <Card className="space-y-2 p-4">
      <h2 className="font-semibold">{label}</h2>
      {rows.map((x) => (
        <div key={x.id} className="rounded border p-2 text-sm">
          <p className="font-medium">{x.title} {!x.is_visible ? "• masqué" : ""}</p>
          <p className="text-xs text-slate-600">{line(x)}</p>
        </div>
      ))}
    </Card>
  );

  return <div className="grid gap-3 md:grid-cols-2">{block("Preview concours", contests)}{block("Preview événements", events)}</div>;
};
