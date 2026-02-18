"use client";

import { useCallback, useEffect, useState } from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

type Live = { id: string; title: string; status: string };
type Survey = { id: string; title: string; is_visible: boolean; reminder_enabled: boolean; reminder_every_days: number };

export const LiveSurveyWorkflowManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [lives, setLives] = useState<Live[]>([]); const [surveys, setSurveys] = useState<Survey[]>([]);
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const [l, s] = await Promise.all([
      supabase.from("live_classes").select("id,title,status").order("starts_at", { ascending: false }).limit(20),
      supabase.from("surveys").select("id,title,is_visible,reminder_enabled,reminder_every_days").order("starts_at", { ascending: false }).limit(20),
    ]);
    setLives((l.data as Live[]) || []); setSurveys((s.data as Survey[]) || []);
  }, [supabase]);
  useEffect(() => { const id = window.setTimeout(() => { void load(); }, 0); return () => window.clearTimeout(id); }, [load]);

  const setLive = async (id: string, status: string) => {
    const r = await supabase.rpc("backoffice_set_live_status", { p_live_id: id, p_status: status });
    setMessage(r.error ? r.error.message : (r.data?.message || "Status live mis à jour."));
    if (!r.error) await load();
  };
  const saveSurvey = async (x: Survey) => {
    const r = await supabase.rpc("backoffice_update_survey_workflow", { p_survey_id: x.id, p_visible: x.is_visible, p_reminder_enabled: x.reminder_enabled, p_reminder_every_days: x.reminder_every_days, p_target_scope: {} });
    setMessage(r.error ? r.error.message : (r.data?.message || "Workflow enquête mis à jour."));
    if (!r.error) await load();
  };
  const queueReminder = async (id: string) => {
    const r = await supabase.rpc("queue_survey_reminder", { p_survey_id: id });
    setMessage(r.error ? r.error.message : (r.data?.message || "Rappel enquête en file."));
  };

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Workflows avancés: live & enquêtes</h2>
      {lives.map((x) => <div key={x.id} className="flex items-center justify-between rounded border p-2 text-sm"><p>{x.title}</p><select value={x.status || "draft"} onChange={(e) => setLive(x.id, e.target.value)} className="rounded border p-1 text-xs"><option value="draft">draft</option><option value="live">live</option><option value="ended">ended</option></select></div>)}
      {surveys.map((x) => <div key={x.id} className="rounded border p-2 text-sm"><p className="font-medium">{x.title}</p><div className="mt-2 flex flex-wrap items-center gap-2"><label className="text-xs"><input type="checkbox" checked={x.is_visible} onChange={(e) => setSurveys((v) => v.map((s) => s.id === x.id ? { ...s, is_visible: e.target.checked } : s))} /> visible</label><label className="text-xs"><input type="checkbox" checked={x.reminder_enabled} onChange={(e) => setSurveys((v) => v.map((s) => s.id === x.id ? { ...s, reminder_enabled: e.target.checked } : s))} /> reminder</label><input type="number" min={1} value={x.reminder_every_days || 3} onChange={(e) => setSurveys((v) => v.map((s) => s.id === x.id ? { ...s, reminder_every_days: Number(e.target.value) || 1 } : s))} className="w-20 rounded border p-1 text-xs" /><Button variant="outline" onClick={() => saveSurvey(x)}>Sauver</Button><Button variant="outline" onClick={() => queueReminder(x.id)}>Rappel</Button></div></div>)}
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
