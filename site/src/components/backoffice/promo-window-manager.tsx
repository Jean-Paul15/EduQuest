"use client";

import { useCallback, useEffect, useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

type Campaign = { id: string; name: string; active: boolean; starts_at: string; ends_at: string };

export const PromoWindowManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [name, setName] = useState("Promo EduQuest");
  const [days, setDays] = useState(7);
  const [rows, setRows] = useState<Campaign[]>([]);
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const r = await supabase.from("access_campaigns").select("id,name,active,starts_at,ends_at").eq("campaign_type", "FREE_ALL").order("starts_at", { ascending: false }).limit(10);
    setRows((r.data as Campaign[]) || []);
  }, [supabase]);
  useEffect(() => {
    const id = window.setTimeout(() => { void load(); }, 0);
    return () => window.clearTimeout(id);
  }, [load]);

  const create = async () => {
    const start = new Date().toISOString();
    const end = new Date(Date.now() + days * 86400000).toISOString();
    const r = await supabase.from("access_campaigns").insert({
      name,
      campaign_type: "FREE_ALL",
      target_filter: {},
      access_scope: { all: true },
      starts_at: start,
      ends_at: end,
      priority: 50,
      active: true,
    });
    setMessage(r.error ? r.error.message : "Promo FREE_ALL créée.");
    if (!r.error) await load();
  };

  const toggle = async (x: Campaign) => {
    const r = await supabase.from("access_campaigns").update({ active: !x.active }).eq("id", x.id);
    setMessage(r.error ? r.error.message : "Statut promo mis à jour.");
    if (!r.error) await load();
  };

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Promotions rapides (FREE_ALL)</h2>
      <input value={name} onChange={(e) => setName(e.target.value)} className="w-full rounded border p-2 text-sm" />
      <input value={days} type="number" min={1} onChange={(e) => setDays(Number(e.target.value) || 1)} className="w-full rounded border p-2 text-sm" />
      <Button onClick={create}>Créer promo active</Button>
      {rows.map((x) => (
        <div key={x.id} className="flex items-center justify-between rounded border p-2 text-sm">
          <p>{x.name}</p>
          <button onClick={() => toggle(x)} className={`rounded px-2 py-1 ${x.active ? "bg-orange-500 text-white" : "bg-slate-200"}`}>
            {x.active ? "Active" : "Inactive"}
          </button>
        </div>
      ))}
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
