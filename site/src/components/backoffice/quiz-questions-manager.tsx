"use client";

import { useCallback, useEffect, useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { BackofficeInlineFeedback } from "@/components/backoffice/backoffice-inline-feedback";

type Quiz = { id: string; title: string };
type Q = { id: string; prompt: string; type: "mcq" | "short"; answer_key: Record<string, unknown> | null };

export const QuizQuestionsManager = () => {
  const s = getSupabaseBrowserClient();
  const [quizId, setQuizId] = useState(""); const [quizzes, setQuizzes] = useState<Quiz[]>([]); const [rows, setRows] = useState<Q[]>([]);
  const [prompt, setPrompt] = useState(""); const [type, setType] = useState<"mcq" | "short">("mcq"); const [o1, setO1] = useState(""); const [o2, setO2] = useState(""); const [o3, setO3] = useState(""); const [o4, setO4] = useState(""); const [answer, setAnswer] = useState("A"); const [msg, setMsg] = useState("");
  const [tone, setTone] = useState<"success" | "error" | "info">("info");
  const [search, setSearch] = useState("");
  const [viewType, setViewType] = useState<"all" | "mcq" | "short">("all");
  const [sortMode, setSortMode] = useState<"newest" | "az" | "za">("newest");
  const load = useCallback(async () => {
    const qz = await s.from("quizzes").select("id,title").order("id", { ascending: false }).limit(50);
    const list = (qz.data || []) as Quiz[]; setQuizzes(list); if (!quizId && list[0]) setQuizId(list[0].id);
  }, [s, quizId]);
  const loadQuestions = useCallback(async () => {
    if (!quizId) return; const r = await s.from("quiz_questions").select("id,prompt,type,answer_key").eq("quiz_id", quizId).order("id", { ascending: false }).limit(50);
    setRows((r.data || []) as Q[]);
  }, [s, quizId]);
  useEffect(() => { const t = window.setTimeout(() => { void load(); }, 0); return () => window.clearTimeout(t); }, [load]);
  useEffect(() => { const t = window.setTimeout(() => { void loadQuestions(); }, 0); return () => window.clearTimeout(t); }, [loadQuestions]);
  const create = async () => {
    if (!quizId || !prompt.trim()) return setMsg("Choisis un quiz et écris la question.");
    const opts = [o1, o2, o3, o4].map((x) => x.trim()).filter(Boolean);
    if (type === "mcq" && opts.length < 2) return setMsg("Ajoute au moins 2 options pour un QCM.");
    const key = type === "mcq" ? { options: opts, answer } : { answer: answer.trim() };
    const r = await s.from("quiz_questions").insert({ quiz_id: quizId, type, prompt, answer_key: key }); setMsg(r.error ? r.error.message : "Question ajoutée."); setTone(r.error ? "error" : "success");
    if (!r.error) { setPrompt(""); setO1(""); setO2(""); setO3(""); setO4(""); setAnswer("A"); await loadQuestions(); }
  };
  const edit = async (x: Q) => {
    const p = window.prompt("Modifier la question", x.prompt); if (!p) return;
    const r = await s.from("quiz_questions").update({ prompt: p }).eq("id", x.id); setMsg(r.error ? r.error.message : "Question mise à jour."); setTone(r.error ? "error" : "success"); if (!r.error) await loadQuestions();
  };
  const del = async (id: string) => { const r = await s.from("quiz_questions").delete().eq("id", id); setMsg(r.error ? r.error.message : "Question supprimée."); setTone(r.error ? "error" : "success"); if (!r.error) await loadQuestions(); };
  const duplicate = async (x: Q) => {
    const payload = { quiz_id: quizId, type: x.type, prompt: `${x.prompt} (copie)`, answer_key: x.answer_key || {} };
    const r = await s.from("quiz_questions").insert(payload);
    setMsg(r.error ? r.error.message : "Question dupliquee.");
    setTone(r.error ? "error" : "success");
    if (!r.error) await loadQuestions();
  };
  const canCreate = !!quizId && !!prompt.trim() && (type === "short" ? !!answer.trim() : [o1, o2, o3, o4].map((x) => x.trim()).filter(Boolean).length >= 2);
  const visibleRows = rows
    .filter((x) => (viewType === "all" || x.type === viewType) && x.prompt.toLowerCase().includes(search.toLowerCase()))
    .sort((a, b) => (sortMode === "az" ? a.prompt.localeCompare(b.prompt, "fr") : sortMode === "za" ? b.prompt.localeCompare(a.prompt, "fr") : 0));

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Questions de quiz (assistant)</h2>
      <p className="text-xs text-slate-500">Crée les questions dans l’ordre: quiz cible, type, contenu, réponse.</p>
      <div className="rounded-xl border p-3">
        <div className="grid gap-2 md:grid-cols-4">
          <select value={quizId} onChange={(e) => setQuizId(e.target.value)} className="md:col-span-2">{quizzes.map((q) => <option key={q.id} value={q.id}>{q.title}</option>)}</select>
          <select value={type} onChange={(e) => setType(e.target.value as "mcq" | "short")}><option value="mcq">QCM</option><option value="short">Réponse courte</option></select>
          <input value={prompt} onChange={(e) => setPrompt(e.target.value)} placeholder="Question" />
        </div>
        {type === "mcq" ? (
          <div className="mt-2 grid gap-2 md:grid-cols-5">
            <input value={o1} onChange={(e) => setO1(e.target.value)} placeholder="Option A" />
            <input value={o2} onChange={(e) => setO2(e.target.value)} placeholder="Option B" />
            <input value={o3} onChange={(e) => setO3(e.target.value)} placeholder="Option C (optionnel)" />
            <input value={o4} onChange={(e) => setO4(e.target.value)} placeholder="Option D (optionnel)" />
            <select value={answer} onChange={(e) => setAnswer(e.target.value)}><option>A</option><option>B</option><option>C</option><option>D</option></select>
          </div>
        ) : (
          <input className="mt-2" value={answer} onChange={(e) => setAnswer(e.target.value)} placeholder="Bonne réponse attendue" />
        )}
        <Button onClick={create} disabled={!canCreate} className="mt-2">Ajouter la question</Button>
      </div>
      <div className="eq-action-bar text-xs">
        <span className="font-semibold text-slate-600">Questions: {visibleRows.length}/{rows.length}</span>
        <span className="eq-chip eq-chip-warn">{type === "mcq" ? "Mode QCM" : "Mode courte"}</span>
        <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Rechercher une question..." className="min-w-48" />
        <select value={viewType} onChange={(e) => setViewType(e.target.value as "all" | "mcq" | "short")} className="min-w-32">
          <option value="all">Tous types</option><option value="mcq">QCM</option><option value="short">Courte</option>
        </select>
        <select value={sortMode} onChange={(e) => setSortMode(e.target.value as "newest" | "az" | "za")} className="min-w-32">
          <option value="newest">Defaut</option><option value="az">Question A - Z</option><option value="za">Question Z - A</option>
        </select>
      </div>
      <div className="space-y-1">
        {!visibleRows.length ? <p className="rounded-xl border border-dashed p-3 text-xs text-slate-500">Aucune question pour ce filtre.</p> : null}
        {visibleRows.map((x) => (
          <div key={x.id} className="eq-row flex items-center justify-between gap-2 text-xs">
            <span className="truncate"><span className={`eq-chip mr-2 ${x.type === "mcq" ? "eq-chip-ok" : "eq-chip-warn"}`}>{x.type.toUpperCase()}</span>{x.prompt}</span>
            <span className="flex gap-1"><button onClick={() => void duplicate(x)}>Dupliquer</button><button onClick={() => void edit(x)}>Modifier</button><button onClick={() => void del(x.id)}>Supprimer</button></span>
          </div>
        ))}
      </div>
      <BackofficeInlineFeedback message={msg} tone={tone} />
    </Card>
  );
};
