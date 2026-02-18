"use client";

import { useCallback, useEffect, useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

type Item = { id: string; label: string };
type Live = { id: string; title: string; starts_at: string; ends_at: string; zoom_link: string };
type TeacherRow = { id: string; full_name: string | null };
type RefRow = { id: string; label: string };

export const LiveClassesManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [teachers, setTeachers] = useState<Item[]>([]); const [subjects, setSubjects] = useState<Item[]>([]); const [levels, setLevels] = useState<Item[]>([]);
  const [rows, setRows] = useState<Live[]>([]);
  const [teacherId, setTeacherId] = useState(""); const [subjectId, setSubjectId] = useState(""); const [levelId, setLevelId] = useState("");
  const [title, setTitle] = useState(""); const [zoom, setZoom] = useState("");
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const [t, s, l, r] = await Promise.all([
      supabase.from("profiles").select("id,full_name").in("role", ["teacher", "admin"]).limit(50),
      supabase.from("subjects").select("id,label").order("label"),
      supabase.from("education_levels").select("id,label").order("label"),
      supabase.from("live_classes").select("id,title,starts_at,ends_at,zoom_link").order("starts_at", { ascending: false }).limit(20),
    ]);
    setTeachers((((t.data || []) as TeacherRow[])).map((x) => ({ id: x.id, label: x.full_name || x.id })));
    setSubjects((((s.data || []) as RefRow[])).map((x) => ({ id: x.id, label: x.label })));
    setLevels((((l.data || []) as RefRow[])).map((x) => ({ id: x.id, label: x.label })));
    setRows((r.data as Live[]) || []);
    if (!teacherId && t.data?.length) setTeacherId(String(t.data[0].id));
    if (!subjectId && s.data?.length) setSubjectId(String(s.data[0].id));
    if (!levelId && l.data?.length) setLevelId(String(l.data[0].id));
  }, [levelId, subjectId, supabase, teacherId]);

  useEffect(() => { const id = window.setTimeout(() => { void load(); }, 0); return () => window.clearTimeout(id); }, [load]);

  const create = async () => {
    const start = new Date(Date.now() + 86400000); const end = new Date(start.getTime() + 5400000);
    const r = await supabase.from("live_classes").insert({
      teacher_id: teacherId, subject_id: subjectId, education_level_id: levelId, title, zoom_link: zoom, access_scope: {}, starts_at: start.toISOString(), ends_at: end.toISOString(),
    });
    setMessage(r.error ? r.error.message : "Live créé."); if (!r.error) { setTitle(""); setZoom(""); await load(); }
  };

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Live classes</h2>
      <select value={teacherId} onChange={(e) => setTeacherId(e.target.value)} className="w-full rounded border p-2 text-sm">{teachers.map((x) => <option key={x.id} value={x.id}>{x.label}</option>)}</select>
      <select value={subjectId} onChange={(e) => setSubjectId(e.target.value)} className="w-full rounded border p-2 text-sm">{subjects.map((x) => <option key={x.id} value={x.id}>{x.label}</option>)}</select>
      <select value={levelId} onChange={(e) => setLevelId(e.target.value)} className="w-full rounded border p-2 text-sm">{levels.map((x) => <option key={x.id} value={x.id}>{x.label}</option>)}</select>
      <input value={title} onChange={(e) => setTitle(e.target.value)} placeholder="Titre live" className="w-full rounded border p-2 text-sm" />
      <input value={zoom} onChange={(e) => setZoom(e.target.value)} placeholder="Lien Zoom/Meet" className="w-full rounded border p-2 text-sm" />
      <Button onClick={create}>Créer live</Button>
      {rows.map((x) => <div key={x.id} className="rounded border p-2 text-xs"><p className="font-semibold">{x.title}</p><p className="text-slate-500">{x.starts_at}</p></div>)}
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
