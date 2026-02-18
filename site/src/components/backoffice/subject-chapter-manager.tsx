"use client";

import { useCallback, useEffect, useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { BackofficeInlineFeedback } from "@/components/backoffice/backoffice-inline-feedback";

type Item = { id: string; code: string; label: string };
type Level = { id: string; code: string; label: string };
type CountryRow = { id: string; code: string; name: string };
type Chapter = { id: string; title: string; position: number; subject_id: string; education_level_id: string };

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
  const [chapters, setChapters] = useState<Chapter[]>([]);
  const [message, setMessage] = useState("");
  const [tone, setTone] = useState<"success" | "error" | "info">("info");
  const [search, setSearch] = useState("");
  const [sortMode, setSortMode] = useState<"code_asc" | "code_desc" | "label_asc" | "chapter_pos">("code_asc");

  const load = useCallback(async () => {
    const [c, l, s, ch] = await Promise.all([
      supabase.from("countries").select("id,code,name"),
      supabase.from("education_levels").select("id,code,label").order("code"),
      supabase.from("subjects").select("id,code,label").order("code"),
      supabase.from("chapters").select("id,title,position,subject_id,education_level_id").order("position"),
    ]);
    setCountries((((c.data || []) as CountryRow[])).map((x) => ({ id: x.id, code: x.code, label: x.name })));
    setLevels((l.data as Level[]) || []); setSubjects((s.data as Item[]) || []);
    setChapters((ch.data as Chapter[]) || []);
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
    setTone(r.error ? "error" : "success");
    if (!r.error) { setSubCode(""); setSubLabel(""); await load(); }
  };
  const createChapter = async () => {
    const r = await supabase.from("chapters").insert({ subject_id: subjectId, education_level_id: levelId, title: chTitle, position: chPos });
    setMessage(r.error ? r.error.message : "Chapitre créé.");
    setTone(r.error ? "error" : "success");
    if (!r.error) { setChTitle(""); setChPos(1); await load(); }
  };
  const rename = async (table: "subjects" | "chapters", id: string, old: string) => {
    const value = window.prompt(table === "subjects" ? "Nouveau nom matière" : "Nouveau titre chapitre", old);
    if (!value) return;
    const col = table === "subjects" ? "label" : "title";
    const r = await supabase.from(table).update({ [col]: value }).eq("id", id);
    setMessage(r.error ? r.error.message : "Mise à jour effectuée.");
    setTone(r.error ? "error" : "success");
    if (!r.error) await load();
  };
  const remove = async (table: "subjects" | "chapters", id: string) => {
    const r = await supabase.from(table).delete().eq("id", id);
    setMessage(r.error ? r.error.message : "Suppression effectuée.");
    setTone(r.error ? "error" : "success");
    if (!r.error) await load();
  };
  const canCreateSubject = !!countryId && !!subCode.trim() && !!subLabel.trim();
  const canCreateChapter = !!levelId && !!subjectId && !!chTitle.trim();
  const filteredSubjects = subjects
    .filter((x) => `${x.code} ${x.label}`.toLowerCase().includes(search.toLowerCase()))
    .sort((a, b) => (sortMode === "code_desc" ? b.code.localeCompare(a.code, "fr") : sortMode === "label_asc" ? a.label.localeCompare(b.label, "fr") : a.code.localeCompare(b.code, "fr")));
  const filteredChapters = chapters
    .filter((x) => (!subjectId || x.subject_id === subjectId) && (!levelId || x.education_level_id === levelId) && `${x.position} ${x.title}`.toLowerCase().includes(search.toLowerCase()))
    .sort((a, b) => (sortMode === "chapter_pos" ? a.position - b.position : a.title.localeCompare(b.title, "fr")));

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Matières et chapitres</h2>
      <p className="text-xs text-slate-500">Étape 1: crée la matière, étape 2: crée ses chapitres par classe.</p>
      <div className="rounded-xl border p-3">
        <p className="mb-2 text-xs font-semibold uppercase tracking-wide text-slate-500">Créer une matière</p>
        <select value={countryId} onChange={(e) => setCountryId(e.target.value)} className="w-full rounded border p-2 text-sm">{countries.map((c) => <option key={c.id} value={c.id}>{c.code} - {c.label}</option>)}</select>
        <div className="mt-2 grid grid-cols-1 gap-2 md:grid-cols-2">
          <input value={subCode} onChange={(e) => setSubCode(e.target.value)} placeholder="Code matière (ex: MATH)" className="rounded border p-2 text-sm" />
          <input value={subLabel} onChange={(e) => setSubLabel(e.target.value)} placeholder="Nom matière (ex: Mathématiques)" className="rounded border p-2 text-sm" />
        </div>
        <Button onClick={createSubject} disabled={!canCreateSubject} className="mt-2">Créer matière</Button>
      </div>
      <div className="rounded-xl border p-3">
        <p className="mb-2 text-xs font-semibold uppercase tracking-wide text-slate-500">Créer un chapitre</p>
        <div className="grid gap-2 md:grid-cols-2">
          <select value={levelId} onChange={(e) => setLevelId(e.target.value)} className="w-full rounded border p-2 text-sm">{levels.map((l) => <option key={l.id} value={l.id}>{l.code} - {l.label}</option>)}</select>
          <select value={subjectId} onChange={(e) => setSubjectId(e.target.value)} className="w-full rounded border p-2 text-sm">{subjects.map((s) => <option key={s.id} value={s.id}>{s.code} - {s.label}</option>)}</select>
        </div>
        <div className="mt-2 grid grid-cols-1 gap-2 md:grid-cols-2">
          <input value={chTitle} onChange={(e) => setChTitle(e.target.value)} placeholder="Titre chapitre (ex: Fonctions)" className="rounded border p-2 text-sm" />
          <input value={chPos} type="number" min={1} onChange={(e) => setChPos(Number(e.target.value) || 1)} className="rounded border p-2 text-sm" />
        </div>
        <Button onClick={createChapter} variant="outline" disabled={!canCreateChapter} className="mt-2">Créer chapitre</Button>
      </div>
      <div className="grid gap-2 md:grid-cols-2">
        <div className="md:col-span-2 eq-action-bar text-xs">
          <span className="font-semibold text-slate-600">Matières: {filteredSubjects.length} | Chapitres: {filteredChapters.length}</span>
          <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Rechercher matière/chapitre..." className="min-w-56" />
          <select value={sortMode} onChange={(e) => setSortMode(e.target.value as "code_asc" | "code_desc" | "label_asc" | "chapter_pos")} className="min-w-44">
            <option value="code_asc">Code A - Z</option><option value="code_desc">Code Z - A</option><option value="label_asc">Nom A - Z</option><option value="chapter_pos">Ordre chapitre</option>
          </select>
        </div>
        <div className="rounded-xl border p-2">
          <p className="mb-2 text-xs font-semibold uppercase text-slate-500">Matières existantes</p>
          {!filteredSubjects.length ? <p className="rounded-xl border border-dashed p-3 text-xs text-slate-500">Aucune matière trouvée.</p> : null}
          {filteredSubjects.map((s) => (
            <div key={s.id} className="eq-row mb-1 text-xs">
              <div className="flex items-center justify-between gap-2">
                <span className="truncate font-medium">{s.code} - {s.label}</span>
                <span className="eq-chip eq-chip-ok">Active</span>
              </div>
              <div className="mt-2 flex flex-wrap gap-1"><button onClick={() => void rename("subjects", s.id, s.label)}>Modifier</button><button onClick={() => void remove("subjects", s.id)}>Supprimer</button></div>
            </div>
          ))}
        </div>
        <div className="rounded-xl border p-2">
          <p className="mb-2 text-xs font-semibold uppercase text-slate-500">Chapitres existants</p>
          {!filteredChapters.length ? <p className="rounded-xl border border-dashed p-3 text-xs text-slate-500">Aucun chapitre trouvé.</p> : null}
          {filteredChapters.map((x) => (
            <div key={x.id} className="eq-row mb-1 text-xs">
              <div className="flex items-center justify-between gap-2">
                <span className="truncate font-medium">{x.position}. {x.title}</span>
                <span className="eq-chip eq-chip-warn">Chapitre</span>
              </div>
              <div className="mt-2 flex flex-wrap gap-1"><button onClick={() => void rename("chapters", x.id, x.title)}>Modifier</button><button onClick={() => void remove("chapters", x.id)}>Supprimer</button></div>
            </div>
          ))}
        </div>
      </div>
      <BackofficeInlineFeedback message={message} tone={tone} />
    </Card>
  );
};
