"use client";

import { useCallback, useEffect, useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

type Country = { id: string; code: string };
type Campaign = { id: string; name: string; ticket_type: string; duration_days: number; active: boolean };

export const OnboardingCampaignManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [countries, setCountries] = useState<Country[]>([]); const [rows, setRows] = useState<Campaign[]>([]);
  const [countryId, setCountryId] = useState(""); const [name, setName] = useState("Onboarding boost");
  const [ticketType, setTicketType] = useState("HALF"); const [days, setDays] = useState(14);
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const [c, r] = await Promise.all([
      supabase.from("countries").select("id,code").order("code"),
      supabase.from("onboarding_ticket_campaigns").select("id,name,ticket_type,duration_days,active").order("created_at", { ascending: false }).limit(20),
    ]);
    setCountries((c.data as Country[]) || []); setRows((r.data as Campaign[]) || []);
    if (!countryId && c.data?.length) setCountryId(String(c.data[0].id));
  }, [countryId, supabase]);

  useEffect(() => { const id = window.setTimeout(() => { void load(); }, 0); return () => window.clearTimeout(id); }, [load]);

  const create = async () => {
    const now = new Date(); const end = new Date(now.getTime() + days * 86400000);
    const r = await supabase.from("onboarding_ticket_campaigns").insert({
      country_id: countryId, name, ticket_type: ticketType, duration_days: days, starts_at: now.toISOString(), ends_at: end.toISOString(), active: true,
    });
    setMessage(r.error ? r.error.message : "Campagne onboarding créée."); if (!r.error) await load();
  };

  const toggle = async (x: Campaign) => {
    const r = await supabase.from("onboarding_ticket_campaigns").update({ active: !x.active }).eq("id", x.id);
    setMessage(r.error ? r.error.message : "Statut onboarding mis à jour."); if (!r.error) await load();
  };

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Onboarding auto-ticket</h2>
      <select value={countryId} onChange={(e) => setCountryId(e.target.value)} className="w-full rounded border p-2 text-sm">{countries.map((x) => <option key={x.id} value={x.id}>{x.code}</option>)}</select>
      <input value={name} onChange={(e) => setName(e.target.value)} className="w-full rounded border p-2 text-sm" />
      <div className="grid grid-cols-2 gap-2">
        <select value={ticketType} onChange={(e) => setTicketType(e.target.value)} className="rounded border p-2 text-sm"><option value="HALF">HALF</option><option value="FULL">FULL</option></select>
        <input value={days} type="number" min={1} onChange={(e) => setDays(Number(e.target.value) || 1)} className="rounded border p-2 text-sm" />
      </div>
      <Button onClick={create}>Créer campagne onboarding</Button>
      {rows.map((x) => <div key={x.id} className="flex items-center justify-between rounded border p-2 text-xs"><p>{x.name} • {x.ticket_type} • {x.duration_days}j</p><button onClick={() => toggle(x)} className={`rounded px-2 py-1 ${x.active ? "bg-orange-500 text-white" : "bg-slate-200"}`}>{x.active ? "Active" : "Inactive"}</button></div>)}
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
