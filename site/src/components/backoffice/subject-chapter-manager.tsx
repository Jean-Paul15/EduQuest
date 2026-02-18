"use client";

import { useCallback, useEffect, useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

type Item = { id: string; code: string; label: string };
type Level = { id: string; code: string; label: string };
type CountryRow = { id: string; code: string; name: string };

export const SubjectChapterManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [countryId, setCountryId] = useState("");
  const [levelId, setLevelId] = useState("");
  const [subjectId, setSubjectId] = useState("");
  const [countries, setCountries] = useState<Item[]>([]);
  const [levels, setLevels] = useState<Level[]>([]);
  const [subjects, setSubjects] = useState<Item[]>([]);
  const [subCode, setSubCode] = useState(""); const [subLabel, setSubLabel] = useState("");
  const [chTitle, setChTitle] = useState(""); const [chPos, setChPos] = useState(1);
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const [c, l, s] = await Promise.all([
      supabase.from("countries").select("id,code,name"),
      supabase.from("education_levels").select("id,code,label").order("code"),
      supabase.from("subjects").select("id,code,label").order("code"),
    ]);
    setCountries((((c.data || []) as CountryRow[])).map((x) => ({ id: x.id, code: x.code, label: x.name })));
    setLevels((l.data as Level[]) || []); setSubjects((s.data as Item[]) || []);
    if (!countryId && c.data?.length) setCountryId(String(c.data[0].id));
    if (!levelId && l.data?.length) setLevelId(String(l.data[0].id));
    if (!subjectId && s.data?.length) setSubjectId(String(s.data[0].id));
  }, [countryId, levelId, subjectId, supabase]);
  useEffect(() => {
    const id = window.setTimeout(() => { void load(); }, 0);
    return () => window.clearTimeout(id);
  }, [load]);

  const createSubject = async () => {
    const r = await supabase.from("subjects").insert({ country_id: countryId, code: subCode, label: subLabel });
    setMessage(r.error ? r.error.message : "Matière créée.");
    if (!r.error) { setSubCode(""); setSubLabel(""); await load(); }
  };
  const createChapter = async () => {
    const r = await supabase.from("chapters").insert({ subject_id: subjectId, education_level_id: levelId, title: chTitle, position: chPos });
    setMessage(r.error ? r.error.message : "Chapitre créé.");
    if (!r.error) { setChTitle(""); setChPos(1); }
  };

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Matières et chapitres</h2>
      <select value={countryId} onChange={(e) => setCountryId(e.target.value)} className="w-full rounded border p-2 text-sm">{countries.map((c) => <option key={c.id} value={c.id}>{c.code}</option>)}</select>
      <div className="grid grid-cols-2 gap-2">
        <input value={subCode} onChange={(e) => setSubCode(e.target.value)} placeholder="Code matière" className="rounded border p-2 text-sm" />
        <input value={subLabel} onChange={(e) => setSubLabel(e.target.value)} placeholder="Label matière" className="rounded border p-2 text-sm" />
      </div>
      <Button onClick={createSubject}>Créer matière</Button>
      <select value={levelId} onChange={(e) => setLevelId(e.target.value)} className="w-full rounded border p-2 text-sm">{levels.map((l) => <option key={l.id} value={l.id}>{l.code} - {l.label}</option>)}</select>
      <select value={subjectId} onChange={(e) => setSubjectId(e.target.value)} className="w-full rounded border p-2 text-sm">{subjects.map((s) => <option key={s.id} value={s.id}>{s.code} - {s.label}</option>)}</select>
      <div className="grid grid-cols-2 gap-2">
        <input value={chTitle} onChange={(e) => setChTitle(e.target.value)} placeholder="Titre chapitre" className="rounded border p-2 text-sm" />
        <input value={chPos} type="number" min={1} onChange={(e) => setChPos(Number(e.target.value) || 1)} className="rounded border p-2 text-sm" />
      </div>
      <Button onClick={createChapter} variant="outline">Créer chapitre</Button>
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
