"use client";

import { useCallback, useEffect, useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";
import { Card } from "@/components/ui/card";

type Row = {
  id: string;
  title: string;
  is_visible: boolean;
  starts_at: string;
  fee_full?: number;
  fee_half?: number;
  fee_free?: number;
};

export const EventsManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [contests, setContests] = useState<Row[]>([]);
  const [events, setEvents] = useState<Row[]>([]);
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const [c, e] = await Promise.all([
      supabase.from("contests").select("id,title,is_visible,starts_at,fee_full,fee_half,fee_free").order("starts_at", { ascending: false }).limit(20),
      supabase.from("events").select("id,title,is_visible,starts_at,fee_full,fee_half,fee_free").order("starts_at", { ascending: false }).limit(20),
    ]);
    setContests((c.data as Row[]) || []);
    setEvents((e.data as Row[]) || []);
  }, [supabase]);

  useEffect(() => {
    const id = window.setTimeout(() => { void load(); }, 0);
    return () => window.clearTimeout(id);
  }, [load]);

  const toggle = async (table: "contests" | "events", row: Row) => {
    const r = await supabase.from(table).update({ is_visible: !row.is_visible }).eq("id", row.id);
    setMessage(r.error ? r.error.message : "Visibilité mise à jour.");
    if (!r.error) load();
  };

  const section = (label: string, table: "contests" | "events", rows: Row[]) => (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">{label}</h2>
      {rows.map((r) => (
        <div key={r.id} className="flex items-center justify-between rounded border p-2">
          <div>
            <p className="text-sm font-medium">{r.title}</p>
            <p className="text-xs text-slate-500">
              FULL {r.fee_full || 0} • HALF {r.fee_half || 0} • FREE {r.fee_free || 0}
            </p>
          </div>
          <button
            onClick={() => toggle(table, r)}
            className={`rounded px-3 py-1 text-xs ${r.is_visible ? "bg-orange-500 text-white" : "bg-slate-200"}`}
          >
            {r.is_visible ? "Visible" : "Masqué"}
          </button>
        </div>
      ))}
    </Card>
  );

  return (
    <div className="space-y-4">
      {section("Concours", "contests", contests)}
      {section("Événements", "events", events)}
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </div>
  );
};
