"use client";

import { useCallback, useEffect, useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { BackofficeInlineFeedback } from "@/components/backoffice/backoffice-inline-feedback";

type Item = { id: string; code: string; label: string };
type CountryRow = { id: string; code: string; name: string };
type Serie = { id: string; code: string; label: string; education_level_id: string };

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
  const [series, setSeries] = useState<Serie[]>([]);
  const [message, setMessage] = useState("");
  const [tone, setTone] = useState<"success" | "error" | "info">("info");
  const [search, setSearch] = useState("");
  const [sortMode, setSortMode] = useState<"code_asc" | "code_desc" | "label_asc">("code_asc");

  const load = useCallback(async () => {
    const [c, l, sr] = await Promise.all([
      supabase.from("countries").select("id,code,name"),
      supabase.from("education_levels").select("id,code,label").order("code"),
      supabase.from("series").select("id,code,label,education_level_id").order("code"),
    ]);
    setCountries((((c.data || []) as CountryRow[])).map((x) => ({ id: x.id, code: x.code, label: x.name })));
    setLevels((l.data as Item[]) || []);
    setSeries((sr.data as Serie[]) || []);
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
    setTone(r.error ? "error" : "success");
    if (!r.error) { setLevelCode(""); setLevelLabel(""); await load(); }
  };

  const createSerie = async () => {
    const r = await supabase.from("series").insert({ education_level_id: levelId, code: serieCode, label: serieLabel });
    setMessage(r.error ? r.error.message : "Série créée.");
    setTone(r.error ? "error" : "success");
    if (!r.error) { setSerieCode(""); setSerieLabel(""); await load(); }
  };
  const rename = async (table: "education_levels" | "series", id: string, oldLabel: string) => {
    const label = window.prompt("Nouveau libellé", oldLabel);
    if (!label) return;
    const r = await supabase.from(table).update({ label }).eq("id", id);
    setMessage(r.error ? r.error.message : "Libellé mis à jour.");
    setTone(r.error ? "error" : "success");
    if (!r.error) await load();
  };
  const remove = async (table: "education_levels" | "series", id: string) => {
    const r = await supabase.from(table).delete().eq("id", id);
    setMessage(r.error ? r.error.message : "Élément supprimé.");
    setTone(r.error ? "error" : "success");
    if (!r.error) await load();
  };
  const canCreateLevel = !!countryId && !!levelCode.trim() && !!levelLabel.trim();
  const canCreateSerie = !!levelId && !!serieCode.trim() && !!serieLabel.trim();
  const sorter = (a: Item, b: Item) => sortMode === "label_asc" ? a.label.localeCompare(b.label, "fr") : sortMode === "code_desc" ? b.code.localeCompare(a.code, "fr") : a.code.localeCompare(b.code, "fr");
  const filteredLevels = levels.filter((x) => `${x.code} ${x.label}`.toLowerCase().includes(search.toLowerCase())).sort(sorter);
  const filteredSeries = series.filter((x) => (!levelId || x.education_level_id === levelId) && `${x.code} ${x.label}`.toLowerCase().includes(search.toLowerCase())).sort(sorter);

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Classes et séries</h2>
      <p className="text-xs text-slate-500">Étape 1: crée la classe, puis ajoute les séries qui y sont rattachées.</p>
      <div className="rounded-xl border p-3">
        <p className="mb-2 text-xs font-semibold uppercase tracking-wide text-slate-500">Créer une classe</p>
        <select value={countryId} onChange={(e) => setCountryId(e.target.value)} className="w-full rounded border p-2 text-sm">
          {countries.map((c) => <option key={c.id} value={c.id}>{c.code} - {c.label}</option>)}
        </select>
        <div className="mt-2 grid grid-cols-1 gap-2 md:grid-cols-2">
          <input value={levelCode} onChange={(e) => setLevelCode(e.target.value)} placeholder="Code classe (ex: TLE-D)" className="rounded border p-2 text-sm" />
          <input value={levelLabel} onChange={(e) => setLevelLabel(e.target.value)} placeholder="Nom classe (ex: Terminale D)" className="rounded border p-2 text-sm" />
        </div>
        <Button onClick={createLevel} disabled={!canCreateLevel} className="mt-2">Créer classe</Button>
      </div>
      <div className="rounded-xl border p-3">
        <p className="mb-2 text-xs font-semibold uppercase tracking-wide text-slate-500">Créer une série</p>
        <select value={levelId} onChange={(e) => setLevelId(e.target.value)} className="w-full rounded border p-2 text-sm">
          {levels.map((l) => <option key={l.id} value={l.id}>{l.code} - {l.label}</option>)}
        </select>
        <div className="mt-2 grid grid-cols-1 gap-2 md:grid-cols-2">
          <input value={serieCode} onChange={(e) => setSerieCode(e.target.value)} placeholder="Code série (ex: C)" className="rounded border p-2 text-sm" />
          <input value={serieLabel} onChange={(e) => setSerieLabel(e.target.value)} placeholder="Nom série (ex: Scientifique C)" className="rounded border p-2 text-sm" />
        </div>
        <Button onClick={createSerie} variant="outline" disabled={!canCreateSerie} className="mt-2">Créer série</Button>
      </div>
      <div className="grid gap-2 md:grid-cols-2">
        <div className="md:col-span-2 eq-action-bar text-xs">
          <span className="font-semibold text-slate-600">Classes: {filteredLevels.length} | Series: {filteredSeries.length}</span>
          <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Rechercher classe/série..." className="min-w-56" />
          <select value={sortMode} onChange={(e) => setSortMode(e.target.value as "code_asc" | "code_desc" | "label_asc")} className="min-w-40">
            <option value="code_asc">Code A - Z</option><option value="code_desc">Code Z - A</option><option value="label_asc">Nom A - Z</option>
          </select>
        </div>
        <div className="rounded-xl border p-2">
          <p className="mb-2 text-xs font-semibold uppercase text-slate-500">Classes existantes</p>
          {!filteredLevels.length ? <p className="rounded-xl border border-dashed p-3 text-xs text-slate-500">Aucune classe trouvée.</p> : null}
          {filteredLevels.map((l) => (
            <div key={l.id} className="eq-row mb-1 text-xs">
              <div className="flex items-center justify-between gap-2">
                <span className="truncate font-medium">{l.code} - {l.label}</span>
                <span className="eq-chip eq-chip-ok">Actif</span>
              </div>
              <div className="mt-2 flex flex-wrap gap-1"><button onClick={() => void rename("education_levels", l.id, l.label)}>Modifier</button><button onClick={() => void remove("education_levels", l.id)}>Supprimer</button></div>
            </div>
          ))}
        </div>
        <div className="rounded-xl border p-2">
          <p className="mb-2 text-xs font-semibold uppercase text-slate-500">Séries existantes</p>
          {!filteredSeries.length ? <p className="rounded-xl border border-dashed p-3 text-xs text-slate-500">Aucune série trouvée.</p> : null}
          {filteredSeries.map((x) => (
            <div key={x.id} className="eq-row mb-1 text-xs">
              <div className="flex items-center justify-between gap-2">
                <span className="truncate font-medium">{x.code} - {x.label}</span>
                <span className="eq-chip eq-chip-ok">Liée</span>
              </div>
              <div className="mt-2 flex flex-wrap gap-1"><button onClick={() => void rename("series", x.id, x.label)}>Modifier</button><button onClick={() => void remove("series", x.id)}>Supprimer</button></div>
            </div>
          ))}
        </div>
      </div>
      <BackofficeInlineFeedback message={message} tone={tone} />
    </Card>
  );
};
