"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { BackofficeInlineFeedback } from "@/components/backoffice/backoffice-inline-feedback";

type Opt = { id: string; label: string };
type SeriesOpt = { id: string; label: string; education_level_id: string };
type Mode = "course" | "quiz" | "exam";
type StatusFilter = "all" | "published" | "draft";
type Table = "resources" | "quizzes" | "exam_papers";
type Row = {
  id: string;
  title?: string;
  published?: boolean;
  year?: number;
  semester?: string;
  external_url?: string;
  paper_path?: string;
  correction_path?: string;
  chapter_id?: string;
  country_id?: string;
  education_level_id?: string;
  subject_id?: string;
};
type PagingState = Record<Table, number>;
type DisplayItem = { table: Table; title: string; rows: Row[] };

const PAGE_SIZE = 6;

export const LearningLibraryManager = () => {
  const s = getSupabaseBrowserClient();

  const [msg, setMsg] = useState("");
  const [tone, setTone] = useState<"success" | "error" | "info">("info");
  const [bucket, setBucket] = useState("eduquest-content");
  const [mode, setMode] = useState<Mode>("course");
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState<StatusFilter>("all");

  const [countries, setCountries] = useState<Opt[]>([]);
  const [levels, setLevels] = useState<Opt[]>([]);
  const [seriesOptions, setSeriesOptions] = useState<SeriesOpt[]>([]);
  const [subjects, setSubjects] = useState<Opt[]>([]);
  const [chapters, setChapters] = useState<Opt[]>([]);

  const [countryId, setCountryId] = useState("");
  const [levelId, setLevelId] = useState("");
  const [courseSeriesIds, setCourseSeriesIds] = useState<string[]>([]);
  const [quizSeriesIds, setQuizSeriesIds] = useState<string[]>([]);
  const [examSeriesIds, setExamSeriesIds] = useState<string[]>([]);
  const [subjectId, setSubjectId] = useState("");
  const [chapterId, setChapterId] = useState("");

  const [rTitle, setRTitle] = useState("");
  const [rUrl, setRUrl] = useState("");
  const [rFile, setRFile] = useState<File | null>(null);

  const [qTitle, setQTitle] = useState("");

  const [eYear, setEYear] = useState(new Date().getFullYear());
  const [eSem, setESem] = useState("S1");
  const [ePaper, setEPaper] = useState("");
  const [eCorr, setECorr] = useState("");
  const [paperFile, setPaperFile] = useState<File | null>(null);
  const [corrFile, setCorrFile] = useState<File | null>(null);

  const [pages, setPages] = useState<PagingState>({ resources: 1, quizzes: 1, exam_papers: 1 });
  const [selected, setSelected] = useState<Record<string, boolean>>({});

  const [resources, setResources] = useState<Row[]>([]);
  const [quizzes, setQuizzes] = useState<Row[]>([]);
  const [exams, setExams] = useState<Row[]>([]);

  const displayItems: DisplayItem[] = useMemo(
    () => [
      { table: "resources", title: "Cours PDF", rows: resources },
      { table: "quizzes", title: "Quiz", rows: quizzes },
      { table: "exam_papers", title: "Annales", rows: exams },
    ],
    [resources, quizzes, exams],
  );

  const rowKey = (table: Table, id: string) => `${table}:${id}`;
  const canCreateCourse = !!chapterId && !!rTitle.trim() && (!!rUrl.trim() || !!rFile);
  const canCreateQuiz = !!chapterId && !!qTitle.trim();
  const canCreateExam = !!countryId && !!levelId && !!subjectId && (!!ePaper.trim() || !!paperFile);

  const load = useCallback(async () => {
    const [c, l, se, su, ch, r, q, e] = await Promise.all([
      s.from("countries").select("id,code,name").order("code"),
      s.from("education_levels").select("id,code,label").order("code"),
      s.from("series").select("id,code,label,education_level_id").eq("is_active", true).order("code"),
      s.from("subjects").select("id,code,label").order("code"),
      s.from("chapters").select("id,title").order("position"),
      s.from("resources").select("id,title,published,external_url,chapter_id").order("id", { ascending: false }).limit(40),
      s.from("quizzes").select("id,title,published,chapter_id").order("id", { ascending: false }).limit(40),
      s.from("exam_papers").select("id,year,semester,paper_path,correction_path,country_id,education_level_id,subject_id").order("id", { ascending: false }).limit(40),
    ]);

    setCountries((c.data || []).map((x: { id: string; code: string; name: string }) => ({ id: x.id, label: `${x.code} - ${x.name}` })));
    setLevels((l.data || []).map((x: { id: string; code: string; label: string }) => ({ id: x.id, label: `${x.code} - ${x.label}` })));
    setSeriesOptions((se.data || []).map((x: { id: string; code: string; label: string; education_level_id: string }) => ({ id: x.id, label: `${x.code} - ${x.label}`, education_level_id: x.education_level_id })));
    setSubjects((su.data || []).map((x: { id: string; code: string; label: string }) => ({ id: x.id, label: `${x.code} - ${x.label}` })));
    setChapters((ch.data || []).map((x: { id: string; title: string }) => ({ id: x.id, label: x.title })));

    setResources((r.data || []) as Row[]);
    setQuizzes((q.data || []) as Row[]);
    setExams((e.data || []) as Row[]);

    if (!countryId && c.data?.[0]) setCountryId(String(c.data[0].id));
    if (!levelId && l.data?.[0]) setLevelId(String(l.data[0].id));
    if (!subjectId && su.data?.[0]) setSubjectId(String(su.data[0].id));
    if (!chapterId && ch.data?.[0]) setChapterId(String(ch.data[0].id));
  }, [s, countryId, levelId, subjectId, chapterId]);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      void load();
    }, 0);
    return () => window.clearTimeout(timer);
  }, [load]);

  const levelSeries = useMemo(
    () => seriesOptions.filter((x) => x.education_level_id === levelId),
    [levelId, seriesOptions],
  );

  useEffect(() => {
    // Reinitialise la selection de series quand le niveau change (pas un etat derive pur).
    if (!levelSeries.length) {
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setCourseSeriesIds([]);
      setQuizSeriesIds([]);
      setExamSeriesIds([]);
      return;
    }
    setCourseSeriesIds((prev) => prev.filter((id) => levelSeries.some((x) => x.id === id)));
    setQuizSeriesIds((prev) => prev.filter((id) => levelSeries.some((x) => x.id === id)));
    setExamSeriesIds((prev) => prev.length ? prev.filter((id) => levelSeries.some((x) => x.id === id)) : levelSeries.map((x) => x.id));
  }, [levelSeries]);

  const upload = async (file: File, prefix: string) => {
    const cleanName = file.name.replace(/\s+/g, "-");
    const path = `${prefix}/${Date.now()}-${cleanName}`;
    const up = await s.storage.from(bucket).upload(path, file, { upsert: false });
    if (up.error) throw new Error(`Upload echoue: ${up.error.message}`);
    return s.storage.from(bucket).getPublicUrl(path).data.publicUrl;
  };

  const createResource = async () => {
    try {
      const url = rFile ? await upload(rFile, "courses") : rUrl;
      if (!url) return setMsg("Ajoute une URL ou un PDF.");
      const res = await s.from("resources").insert({
        chapter_id: chapterId,
        type: "pdf",
        title: rTitle,
        external_url: url,
        published: true,
        access_scope: {},
      }).select("id").single();
      if (!res.error && res.data?.id && courseSeriesIds.length) {
        await s.from("resource_series_targets").insert(courseSeriesIds.map((series_id) => ({ resource_id: res.data.id, series_id })));
      }
      setMsg(res.error ? res.error.message : "Cours ajoute.");
      setTone(res.error ? "error" : "success");
      if (!res.error) {
        setRTitle("");
        setRUrl("");
        setRFile(null);
        await load();
      }
    } catch (e) {
      setMsg(e instanceof Error ? e.message : "Erreur inattendue");
    }
  };

  const createQuiz = async () => {
    const res = await s.from("quizzes").insert({ chapter_id: chapterId, title: qTitle, published: true, access_scope: {} }).select("id").single();
    if (!res.error && res.data?.id && quizSeriesIds.length) {
      await s.from("quiz_series_targets").insert(quizSeriesIds.map((series_id) => ({ quiz_id: res.data.id, series_id })));
    }
    setMsg(res.error ? res.error.message : "Quiz ajoute.");
    setTone(res.error ? "error" : "success");
    if (!res.error) {
      setQTitle("");
      await load();
    }
  };

  const createExam = async () => {
    try {
      const paper = paperFile ? await upload(paperFile, "exam-papers") : ePaper;
      const corr = corrFile ? await upload(corrFile, "exam-corrections") : eCorr;
      if (!paper) return setMsg("Ajoute le sujet.");
      const res = await s.from("exam_papers").insert({
        country_id: countryId,
        education_level_id: levelId,
        subject_id: subjectId,
        year: eYear,
        semester: eSem,
        paper_path: paper,
        correction_path: corr || null,
        access_scope: {},
      }).select("id").single();
      if (!res.error && res.data?.id && examSeriesIds.length) {
        await s.from("exam_paper_series_targets").insert(examSeriesIds.map((series_id) => ({ exam_paper_id: res.data.id, series_id })));
      }
      setMsg(res.error ? res.error.message : "Annale ajoutee.");
      setTone(res.error ? "error" : "success");
      if (!res.error) {
        setEPaper("");
        setECorr("");
        setPaperFile(null);
        setCorrFile(null);
        await load();
      }
    } catch (e) {
      setMsg(e instanceof Error ? e.message : "Erreur inattendue");
    }
  };

  const rename = async (table: "resources" | "quizzes", row: Row) => {
    const title = window.prompt("Nouveau titre", row.title || "");
    if (!title) return;
    const res = await s.from(table).update({ title }).eq("id", row.id);
    setMsg(res.error ? res.error.message : "Titre mis a jour.");
    setTone(res.error ? "error" : "success");
    if (!res.error) await load();
  };

  const toggle = async (table: "resources" | "quizzes", row: Row) => {
    const res = await s.from(table).update({ published: !row.published }).eq("id", row.id);
    setMsg(res.error ? res.error.message : "Statut mis a jour.");
    setTone(res.error ? "error" : "success");
    if (!res.error) await load();
  };

  const remove = async (table: Table, id: string) => {
    const res = await s.from(table).delete().eq("id", id);
    setMsg(res.error ? res.error.message : "Supprime.");
    setTone(res.error ? "error" : "success");
    if (!res.error) await load();
  };

  const duplicate = async (table: Table, row: Row) => {
    const payload =
      table === "resources"
        ? { chapter_id: row.chapter_id, type: "pdf", title: `${row.title || "Cours"} (copie)`, external_url: row.external_url || null, published: false, access_scope: {} }
        : table === "quizzes"
          ? { chapter_id: row.chapter_id, title: `${row.title || "Quiz"} (copie)`, published: false, access_scope: {} }
          : { country_id: row.country_id, education_level_id: row.education_level_id, subject_id: row.subject_id, year: row.year, semester: row.semester || null, paper_path: row.paper_path || "", correction_path: row.correction_path || null, access_scope: {} };

    const res = await s.from(table).insert(payload);
    setMsg(res.error ? res.error.message : "Copie creee.");
    setTone(res.error ? "error" : "success");
    if (!res.error) await load();
  };

  const baseMatch = (x: Row) => {
    const hay = `${x.title || ""} ${x.year || ""} ${x.semester || ""}`.toLowerCase();
    const txtOk = hay.includes(search.toLowerCase());
    const statusOk =
      statusFilter === "all" ||
      (statusFilter === "published" ? x.published === true : x.published !== true);
    return txtOk && statusOk;
  };

  const contextMatch = (table: Table, x: Row) => {
    if (table === "exam_papers") {
      return (!countryId || x.country_id === countryId) && (!levelId || x.education_level_id === levelId) && (!subjectId || x.subject_id === subjectId);
    }
    return !chapterId || x.chapter_id === chapterId;
  };

  const paged = (list: Row[], table: Table) => {
    const filtered = list.filter((x) => baseMatch(x) && contextMatch(table, x));
    const maxPages = Math.max(1, Math.ceil(filtered.length / PAGE_SIZE));
    const current = Math.min(pages[table], maxPages);
    return {
      rows: filtered.slice((current - 1) * PAGE_SIZE, current * PAGE_SIZE),
      pages: maxPages,
      current,
      total: filtered.length,
    };
  };

  const ids = (table: Table) =>
    Object.keys(selected)
      .filter((k) => k.startsWith(`${table}:`) && selected[k])
      .map((k) => k.split(":")[1]);

  const toggleSelect = (table: Table, id: string) => {
    const key = rowKey(table, id);
    setSelected((v) => ({ ...v, [key]: !v[key] }));
  };

  const selectPage = (table: Table, rows: Row[], on: boolean) => {
    setSelected((v) => {
      const next = { ...v };
      rows.forEach((r) => {
        next[rowKey(table, r.id)] = on;
      });
      return next;
    });
  };

  const bulkPublish = async (table: "resources" | "quizzes", publish: boolean) => {
    const list = ids(table);
    if (!list.length) return setMsg("Aucune selection.");
    const res = await s.from(table).update({ published: publish }).in("id", list);
    setMsg(res.error ? res.error.message : `${list.length} element(s) mis a jour.`);
    setTone(res.error ? "error" : "success");
    if (!res.error) {
      setSelected({});
      await load();
    }
  };

  const bulkDelete = async (table: Table) => {
    const list = ids(table);
    if (!list.length) return setMsg("Aucune selection.");
    if (!window.confirm(`Supprimer ${list.length} element(s) ?`)) return;
    const res = await s.from(table).delete().in("id", list);
    setMsg(res.error ? res.error.message : `${list.length} element(s) supprime(s).`);
    setTone(res.error ? "error" : "success");
    if (!res.error) {
      setSelected({});
      await load();
    }
  };

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Bibliotheque pedagogique (assistant)</h2>
      <p className="text-sm text-slate-600">Ajoute ce qui sera visible dans l&apos;app: cours PDF, quiz et annales/corriges.</p>

      <div className="flex flex-wrap gap-2 text-xs">
        {["1. Choisir contexte", "2. Ajouter contenu", "3. Gerer en masse"].map((x) => (
          <span key={x} className="rounded-full bg-blue-50 px-3 py-1 text-blue-700">{x}</span>
        ))}
      </div>

      <div className="flex flex-wrap gap-2">
        {[{ key: "course", label: "Cours PDF" }, { key: "quiz", label: "Quiz / QCM" }, { key: "exam", label: "Annales / Corriges" }].map((x) => (
          <button key={x.key} onClick={() => setMode(x.key as Mode)} className={mode === x.key ? "bg-orange-500 text-white" : ""}>{x.label}</button>
        ))}
      </div>

      <div className="grid gap-2 md:grid-cols-2">
        <input value={bucket} onChange={(e) => setBucket(e.target.value)} placeholder="Bucket Storage (eduquest-content)" />
        <p className="text-xs text-slate-500 md:self-center">Importer PDF ou coller URL.</p>
      </div>

      <div className="grid gap-2 md:grid-cols-2">
        <div><p className="mb-1 text-xs text-slate-500">Classe</p><select value={levelId} onChange={(e) => setLevelId(e.target.value)}>{levels.map((o) => <option key={o.id} value={o.id}>{o.label}</option>)}</select></div>
        <div><p className="mb-1 text-xs text-slate-500">Matiere</p><select value={subjectId} onChange={(e) => setSubjectId(e.target.value)}>{subjects.map((o) => <option key={o.id} value={o.id}>{o.label}</option>)}</select></div>
        <div><p className="mb-1 text-xs text-slate-500">Chapitre</p><select value={chapterId} onChange={(e) => setChapterId(e.target.value)}>{chapters.map((o) => <option key={o.id} value={o.id}>{o.label}</option>)}</select></div>
        <div><p className="mb-1 text-xs text-slate-500">Pays</p><select value={countryId} onChange={(e) => setCountryId(e.target.value)}>{countries.map((o) => <option key={o.id} value={o.id}>{o.label}</option>)}</select></div>
      </div>

      {mode === "course" ? <div className="rounded-xl border p-3"><div className="grid gap-2 md:grid-cols-4"><input value={rTitle} onChange={(e) => setRTitle(e.target.value)} placeholder="Titre cours PDF" /><input value={rUrl} onChange={(e) => setRUrl(e.target.value)} placeholder="URL PDF (optionnel)" /><input type="file" accept="application/pdf" onChange={(e) => setRFile(e.target.files?.[0] || null)} /><Button onClick={createResource} disabled={!canCreateCourse}>Ajouter cours</Button></div><p className="mt-3 text-xs text-slate-500">Override série optionnel. Laisser vide = héritage du chapitre.</p><div className="mt-2 flex flex-wrap gap-2">{levelSeries.map((serie) => <label key={serie.id} className="flex items-center gap-2 rounded-full border px-3 py-1 text-xs"><input type="checkbox" checked={courseSeriesIds.includes(serie.id)} onChange={() => setCourseSeriesIds((prev) => prev.includes(serie.id) ? prev.filter((id) => id !== serie.id) : [...prev, serie.id])} />{serie.label}</label>)}</div></div> : null}
      {mode === "quiz" ? <div className="rounded-xl border p-3"><div className="grid gap-2 md:grid-cols-3"><input value={qTitle} onChange={(e) => setQTitle(e.target.value)} placeholder="Titre quiz / QCM" /><p className="text-xs text-slate-500 md:self-center">Les questions se gerent dans la section Quiz.</p><Button onClick={createQuiz} disabled={!canCreateQuiz}>Ajouter quiz</Button></div><p className="mt-3 text-xs text-slate-500">Override série optionnel. Laisser vide = héritage du chapitre.</p><div className="mt-2 flex flex-wrap gap-2">{levelSeries.map((serie) => <label key={serie.id} className="flex items-center gap-2 rounded-full border px-3 py-1 text-xs"><input type="checkbox" checked={quizSeriesIds.includes(serie.id)} onChange={() => setQuizSeriesIds((prev) => prev.includes(serie.id) ? prev.filter((id) => id !== serie.id) : [...prev, serie.id])} />{serie.label}</label>)}</div></div> : null}
      {mode === "exam" ? <div className="rounded-xl border p-3"><div className="grid gap-2 md:grid-cols-7"><input type="number" value={eYear} onChange={(e) => setEYear(Number(e.target.value) || eYear)} placeholder="Annee" /><input value={eSem} onChange={(e) => setESem(e.target.value)} placeholder="Semestre" /><input value={ePaper} onChange={(e) => setEPaper(e.target.value)} placeholder="URL sujet (optionnel)" /><input type="file" accept="application/pdf" onChange={(e) => setPaperFile(e.target.files?.[0] || null)} /><input value={eCorr} onChange={(e) => setECorr(e.target.value)} placeholder="URL corrige (optionnel)" /><input type="file" accept="application/pdf" onChange={(e) => setCorrFile(e.target.files?.[0] || null)} /><Button onClick={createExam} disabled={!canCreateExam}>Ajouter annale</Button></div><p className="mt-3 text-xs text-slate-500">Au moins une série est recommandée pour garder l’annale visible.</p><div className="mt-2 flex flex-wrap gap-2">{levelSeries.map((serie) => <label key={serie.id} className="flex items-center gap-2 rounded-full border px-3 py-1 text-xs"><input type="checkbox" checked={examSeriesIds.includes(serie.id)} onChange={() => setExamSeriesIds((prev) => prev.includes(serie.id) ? prev.filter((id) => id !== serie.id) : [...prev, serie.id])} />{serie.label}</label>)}</div></div> : null}

      <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Rechercher..." />

      <div className="flex flex-wrap gap-2">
        {[{ key: "all", label: "Tous" }, { key: "published", label: "Publies" }, { key: "draft", label: "Brouillons" }].map((x) => (
          <button key={x.key} onClick={() => { setStatusFilter(x.key as StatusFilter); setPages({ resources: 1, quizzes: 1, exam_papers: 1 }); }} className={statusFilter === x.key ? "bg-blue-500 text-white" : ""}>{x.label}</button>
        ))}
      </div>

      <div className="grid gap-3 md:grid-cols-3">
        {displayItems.map((item) => {
          const p = paged(item.rows, item.table);
          const selectedCount = ids(item.table).length;
          return (
            <div key={item.table} className="rounded-xl border border-slate-200 p-2">
              <p className="mb-2 text-sm font-semibold">{item.title} <span className="text-xs text-slate-500">({p.total})</span></p>
              <div className="eq-action-bar mb-2 text-xs">
                <span className="font-semibold text-slate-600">Selection: {selectedCount}</span>
                <button onClick={() => selectPage(item.table, p.rows, true)}>Tout cocher</button>
                <button onClick={() => selectPage(item.table, p.rows, false)}>Tout decocher</button>
                {item.table !== "exam_papers" ? <><button onClick={() => void bulkPublish(item.table as "resources" | "quizzes", true)}>Publier selection</button><button onClick={() => void bulkPublish(item.table as "resources" | "quizzes", false)}>Depublier selection</button></> : null}
                <button onClick={() => void bulkDelete(item.table)}>Supprimer selection</button>
              </div>

              {p.rows.map((r) => (
                <div key={r.id} className="eq-row mb-1 text-xs">
                  <div className="mb-1 flex items-center gap-2"><input type="checkbox" checked={!!selected[rowKey(item.table, r.id)]} onChange={() => toggleSelect(item.table, r.id)} /><p className="truncate">{r.title || `${r.year || ""} ${r.semester || ""}`}</p></div>
                  {item.table !== "exam_papers" ? <p className={`eq-chip ${r.published ? "eq-chip-ok" : "eq-chip-warn"}`}>{r.published ? "Publie" : "Brouillon"}</p> : <p className="eq-chip eq-chip-warn">Annale</p>}
                  <div className="mt-1 flex flex-wrap gap-1">
                    {r.external_url ? <a href={r.external_url} target="_blank" rel="noreferrer" className="text-blue-600 underline">Ouvrir</a> : null}
                    {r.paper_path ? <a href={r.paper_path} target="_blank" rel="noreferrer" className="text-blue-600 underline">Sujet</a> : null}
                    {r.correction_path ? <a href={r.correction_path} target="_blank" rel="noreferrer" className="text-blue-600 underline">Corrige</a> : null}
                    <button onClick={() => void duplicate(item.table, r)}>Dupliquer</button>
                    {item.table !== "exam_papers" ? <><button onClick={() => void rename(item.table as "resources" | "quizzes", r)}>Renommer</button><button onClick={() => void toggle(item.table as "resources" | "quizzes", r)}>{r.published ? "Depublier" : "Publier"}</button></> : null}
                    <button onClick={() => void remove(item.table, r.id)}>Supprimer</button>
                  </div>
                </div>
              ))}

              <div className="mt-2 flex items-center justify-between">
                <button disabled={p.current <= 1} onClick={() => setPages((x) => ({ ...x, [item.table]: Math.max(1, x[item.table] - 1) }))}>Prec.</button>
                <span className="text-[11px] text-slate-500">{p.current}/{p.pages}</span>
                <button disabled={p.current >= p.pages} onClick={() => setPages((x) => ({ ...x, [item.table]: Math.min(p.pages, x[item.table] + 1) }))}>Suiv.</button>
              </div>
            </div>
          );
        })}
      </div>

      <BackofficeInlineFeedback message={msg} tone={tone} />
    </Card>
  );
};
