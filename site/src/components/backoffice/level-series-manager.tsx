"use client";

import { useCallback, useEffect, useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

type Item = { id: string; code: string; label: string };
type CountryRow = { id: string; code: string; name: string };

export const LevelSeriesManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [countryId, setCountryId] = useState("");
  const [levelId, setLevelId] = useState("");
  const [levels, setLevels] = useState<Item[]>([]);
  const [countries, setCountries] = useState<Item[]>([]);
  const [levelCode, setLevelCode] = useState("");
  const [levelLabel, setLevelLabel] = useState("");
  const [serieCode, setSerieCode] = useState("");
  const [serieLabel, setSerieLabel] = useState("");
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const [c, l] = await Promise.all([
      supabase.from("countries").select("id,code,name"),
      supabase.from("education_levels").select("id,code,label").order("code"),
    ]);
    setCountries((((c.data || []) as CountryRow[])).map((x) => ({ id: x.id, code: x.code, label: x.name })));
    setLevels((l.data as Item[]) || []);
    if (!countryId && c.data?.length) setCountryId(String(c.data[0].id));
    if (!levelId && l.data?.length) setLevelId(String(l.data[0].id));
  }, [countryId, levelId, supabase]);
  useEffect(() => {
    const id = window.setTimeout(() => { void load(); }, 0);
    return () => window.clearTimeout(id);
  }, [load]);

  const createLevel = async () => {
    const r = await supabase.from("education_levels").insert({ country_id: countryId, code: levelCode, label: levelLabel });
    setMessage(r.error ? r.error.message : "Classe créée.");
    if (!r.error) { setLevelCode(""); setLevelLabel(""); await load(); }
  };

  const createSerie = async () => {
    const r = await supabase.from("series").insert({ education_level_id: levelId, code: serieCode, label: serieLabel });
    setMessage(r.error ? r.error.message : "Série créée.");
    if (!r.error) { setSerieCode(""); setSerieLabel(""); }
  };

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Classes et séries</h2>
      <select value={countryId} onChange={(e) => setCountryId(e.target.value)} className="w-full rounded border p-2 text-sm">
        {countries.map((c) => <option key={c.id} value={c.id}>{c.code} - {c.label}</option>)}
      </select>
      <div className="grid grid-cols-2 gap-2">
        <input value={levelCode} onChange={(e) => setLevelCode(e.target.value)} placeholder="Code classe" className="rounded border p-2 text-sm" />
        <input value={levelLabel} onChange={(e) => setLevelLabel(e.target.value)} placeholder="Label classe" className="rounded border p-2 text-sm" />
      </div>
      <Button onClick={createLevel}>Créer classe</Button>
      <select value={levelId} onChange={(e) => setLevelId(e.target.value)} className="w-full rounded border p-2 text-sm">
        {levels.map((l) => <option key={l.id} value={l.id}>{l.code} - {l.label}</option>)}
      </select>
      <div className="grid grid-cols-2 gap-2">
        <input value={serieCode} onChange={(e) => setSerieCode(e.target.value)} placeholder="Code série" className="rounded border p-2 text-sm" />
        <input value={serieLabel} onChange={(e) => setSerieLabel(e.target.value)} placeholder="Label série" className="rounded border p-2 text-sm" />
      </div>
      <Button onClick={createSerie} variant="outline">Créer série</Button>
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
