"use client";

import { useCallback, useEffect, useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

type Survey = { id: string; title: string; starts_at: string; ends_at: string };
type Ref = { id: string; label: string; code?: string };

export const SurveyBuilderManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [surveys, setSurveys] = useState<Survey[]>([]);
  const [levels, setLevels] = useState<Ref[]>([]); const [series, setSeries] = useState<Ref[]>([]);
  const [surveyId, setSurveyId] = useState("");
  const [levelId, setLevelId] = useState(""); const [seriesId, setSeriesId] = useState("");
  const [title, setTitle] = useState("Nouvelle enquête");
  const [visible, setVisible] = useState(true); const [remOn, setRemOn] = useState(true); const [remDays, setRemDays] = useState(3);
  const [prompt, setPrompt] = useState(""); const [qtype, setQtype] = useState("mcq");
  const [opts, setOpts] = useState("Oui,Non"); const [pos, setPos] = useState(1);
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const [r, l] = await Promise.all([
      supabase.from("surveys").select("id,title,starts_at,ends_at").order("starts_at", { ascending: false }).limit(20),
      supabase.from("education_levels").select("id,label,code").order("label"),
    ]);
    setSurveys((r.data as Survey[]) || []);
    setLevels((l.data as Ref[]) || []); if (!levelId && l.data?.length) setLevelId(String(l.data[0].id));
    if (!surveyId && r.data?.length) setSurveyId(String(r.data[0].id));
  }, [levelId, surveyId, supabase]);

  useEffect(() => {
    const id = window.setTimeout(() => { void load(); }, 0);
    return () => window.clearTimeout(id);
  }, [load]);
  useEffect(() => {
    if (!levelId) return;
    void supabase.from("series").select("id,label,code").eq("education_level_id", levelId).order("label").then((r) => {
      setSeries((r.data as Ref[]) || []);
      setSeriesId((r.data?.[0]?.id as string) || "");
    });
  }, [levelId, supabase]);

  const createSurvey = async () => {
    const tg = await supabase.from("countries").select("id").eq("code", "TG").maybeSingle();
    const now = new Date(); const end = new Date(now.getTime() + 7 * 86400000);
    const lv = levels.find((x) => x.id === levelId); const sr = series.find((x) => x.id === seriesId);
    const target_scope = { levels: lv?.code ? [lv.code] : [], series: sr?.code ? [sr.code] : [] };
    const r = await supabase.from("surveys").insert({
      country_id: tg.data?.id, title, target_scope, starts_at: now.toISOString(), ends_at: end.toISOString(), is_visible: visible, reminder_enabled: remOn, reminder_every_days: remDays,
    }).select("id").single();
    setMessage(r.error ? r.error.message : "Enquête créée.");
    if (!r.error && r.data?.id) { setSurveyId(String(r.data.id)); await load(); }
  };

  const addQuestion = async () => {
    if (!surveyId) return setMessage("Choisis une enquête.");
    const options = qtype === "mcq" ? opts.split(",").map((x) => x.trim()).filter(Boolean) : [];
    const r = await supabase.from("survey_questions").insert({
      survey_id: surveyId, prompt, question_type: qtype, options, required: true, position: pos,
    });
    setMessage(r.error ? r.error.message : "Question ajoutée.");
    if (!r.error) { setPrompt(""); setPos((v) => v + 1); }
  };

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Builder enquêtes</h2>
      <input value={title} onChange={(e) => setTitle(e.target.value)} className="w-full rounded border p-2 text-sm" />
      <div className="grid grid-cols-2 gap-2">
        <select value={levelId} onChange={(e) => setLevelId(e.target.value)} className="rounded border p-2 text-sm">{levels.map((x) => <option key={x.id} value={x.id}>{x.label}</option>)}</select>
        <select value={seriesId} onChange={(e) => setSeriesId(e.target.value)} className="rounded border p-2 text-sm"><option value="">Toutes séries</option>{series.map((x) => <option key={x.id} value={x.id}>{x.label}</option>)}</select>
      </div>
      <div className="grid grid-cols-3 gap-2">
        <label className="text-xs"><input type="checkbox" checked={visible} onChange={(e) => setVisible(e.target.checked)} /> visible</label>
        <label className="text-xs"><input type="checkbox" checked={remOn} onChange={(e) => setRemOn(e.target.checked)} /> reminder</label>
        <input value={remDays} type="number" min={1} onChange={(e) => setRemDays(Number(e.target.value) || 1)} className="rounded border p-2 text-sm" />
      </div>
      <Button onClick={createSurvey}>Créer enquête</Button>
      <select value={surveyId} onChange={(e) => setSurveyId(e.target.value)} className="w-full rounded border p-2 text-sm">
        {surveys.map((s) => <option key={s.id} value={s.id}>{s.title}</option>)}
      </select>
      <textarea value={prompt} onChange={(e) => setPrompt(e.target.value)} placeholder="Question..." className="h-20 w-full rounded border p-2 text-sm" />
      <div className="grid grid-cols-3 gap-2">
        <select value={qtype} onChange={(e) => setQtype(e.target.value)} className="rounded border p-2 text-sm"><option value="mcq">MCQ</option><option value="text">Text</option></select>
        <input value={pos} type="number" min={1} onChange={(e) => setPos(Number(e.target.value) || 1)} className="rounded border p-2 text-sm" />
        <input value={opts} onChange={(e) => setOpts(e.target.value)} placeholder="A,B,C,D" className="rounded border p-2 text-sm" />
      </div>
      <Button onClick={addQuestion} variant="outline">Ajouter question</Button>
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
