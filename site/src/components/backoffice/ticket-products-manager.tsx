"use client";

import { useCallback, useEffect, useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

type Product = {
  id: string; code: string; label: string | null; ticket_type: string; duration_days: number;
  active: boolean; web_visible: boolean; price_full: number; price_half: number;
};
type Country = { id: string; code: string; name: string };
type Level = { id: string; code: string; label: string; country_id: string };

export const TicketProductsManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [countries, setCountries] = useState<Country[]>([]);
  const [levels, setLevels] = useState<Level[]>([]);
  const [rows, setRows] = useState<Product[]>([]);
  const [countryId, setCountryId] = useState("");
  const [levelId, setLevelId] = useState("");
  const [code, setCode] = useState("");
  const [label, setLabel] = useState("");
  const [tier, setTier] = useState("HALF");
  const [days, setDays] = useState(30);
  const [priceFull, setPriceFull] = useState(0);
  const [priceHalf, setPriceHalf] = useState(0);
  const [webVisible, setWebVisible] = useState(true);
  const [allowDownward, setAllowDownward] = useState(false);
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const [p, c, l] = await Promise.all([
      supabase.from("ticket_products").select("id,code,label,ticket_type,duration_days,active,web_visible,price_full,price_half").order("code").limit(50),
      supabase.from("countries").select("id,code,name").order("code"),
      supabase.from("education_levels").select("id,code,label,country_id").eq("is_active", true).order("label"),
    ]);
    setRows((p.data as Product[]) || []);
    const cs = (c.data as Country[]) || [];
    setCountries(cs);
    if (!countryId && cs.length) {
      const tg = cs.find((x) => x.code.toUpperCase() === "TG");
      setCountryId((tg?.id ?? cs[0].id) || "");
    }
    setLevels((l.data as Level[]) || []);
  }, [countryId, supabase]);
  useEffect(() => {
    const id = window.setTimeout(() => { void load(); }, 0);
    return () => window.clearTimeout(id);
  }, [load]);

  const create = async () => {
    if (!countryId || !code.trim()) return setMessage("Pays et code produit requis.");
    const r = await supabase.from("ticket_products").insert({
      country_id: countryId,
      code: code.trim(),
      label: label.trim() || null,
      ticket_type: tier,
      duration_days: days,
      scope: {},
      active: true,
      web_visible: webVisible,
      price_full: priceFull,
      price_half: priceHalf,
      base_education_level_id: levelId || null,
      allow_downward_access: allowDownward,
    });
    setMessage(r.error ? r.error.message : "Produit ticket créé.");
    if (!r.error) { setCode(""); setLabel(""); await load(); }
  };

  const toggle = async (x: Product) => {
    const r = await supabase.from("ticket_products").update({ active: !x.active }).eq("id", x.id);
    setMessage(r.error ? r.error.message : "Produit mis à jour.");
    if (!r.error) await load();
  };

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Produits tickets</h2>
      <select value={countryId} onChange={(e) => setCountryId(e.target.value)} className="w-full rounded border p-2 text-sm">
        <option value="">Pays</option>
        {countries.map((x) => <option key={x.id} value={x.id}>{x.code} - {x.name}</option>)}
      </select>
      <select value={levelId} onChange={(e) => setLevelId(e.target.value)} className="w-full rounded border p-2 text-sm">
        <option value="">Classe cible (optionnel)</option>
        {levels.filter((x) => !countryId || x.country_id === countryId).map((x) => (
          <option key={x.id} value={x.id}>{x.code} - {x.label}</option>
        ))}
      </select>
      <input value={code} onChange={(e) => setCode(e.target.value)} placeholder="Code produit" className="w-full rounded border p-2 text-sm" />
      <input value={label} onChange={(e) => setLabel(e.target.value)} placeholder="Libellé" className="w-full rounded border p-2 text-sm" />
      <div className="grid grid-cols-2 gap-2">
        <select value={tier} onChange={(e) => setTier(e.target.value)} className="rounded border p-2 text-sm">
          <option value="HALF">HALF</option><option value="FULL">FULL</option>
        </select>
        <input value={days} type="number" min={1} onChange={(e) => setDays(Number(e.target.value) || 30)} className="rounded border p-2 text-sm" />
      </div>
      <div className="grid grid-cols-2 gap-2">
        <input value={priceHalf} type="number" min={0} onChange={(e) => setPriceHalf(Number(e.target.value) || 0)} placeholder="Prix HALF" className="rounded border p-2 text-sm" />
        <input value={priceFull} type="number" min={0} onChange={(e) => setPriceFull(Number(e.target.value) || 0)} placeholder="Prix FULL" className="rounded border p-2 text-sm" />
      </div>
      <div className="grid grid-cols-2 gap-2 text-sm">
        <label className="rounded border p-2"><input type="checkbox" checked={webVisible} onChange={(e) => setWebVisible(e.target.checked)} className="mr-2" />Visible web</label>
        <label className="rounded border p-2"><input type="checkbox" checked={allowDownward} onChange={(e) => setAllowDownward(e.target.checked)} className="mr-2" />Accès descendant</label>
      </div>
      <Button onClick={create}>Créer produit</Button>
      {rows.map((x) => (
        <div key={x.id} className="flex items-center justify-between rounded border p-2 text-sm">
          <p>{x.code} • {x.ticket_type} • {x.duration_days}j • H:{x.price_half} F:{x.price_full} • {x.web_visible ? "WEB" : "OFF"}</p>
          <button onClick={() => toggle(x)} className={`rounded px-2 py-1 ${x.active ? "bg-blue-600 text-white" : "bg-slate-200"}`}>
            {x.active ? "Actif" : "Inactif"}
          </button>
        </div>
      ))}
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
