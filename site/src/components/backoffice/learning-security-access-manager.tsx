"use client";

import { useCallback, useEffect, useState } from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

type Sec = { capture_allowed: boolean; keep_awake: boolean };
type Access = Record<string, string>;
const keys = ["courses", "exams", "epreuves", "mockExams", "videos", "youtube"];

export const LearningSecurityAccessManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [sec, setSec] = useState<Sec>({ capture_allowed: true, keep_awake: true });
  const [access, setAccess] = useState<Access>({});
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const r = await supabase.from("app_config").select("key,value").in("key", ["learning_security", "learning_access"]);
    const rows = new Map((r.data || []).map((x: { key: string; value: unknown }) => [x.key, x.value as Record<string, unknown>]));
    const s = rows.get("learning_security") || {};
    const a = rows.get("learning_access") || {};
    setSec({ capture_allowed: !!s.capture_allowed, keep_awake: s.keep_awake !== false });
    setAccess(Object.fromEntries(keys.map((k) => [k, String((a[k] || "HALF")).toUpperCase()])));
  }, [supabase]);

  useEffect(() => {
    const id = window.setTimeout(() => { void load(); }, 0);
    return () => window.clearTimeout(id);
  }, [load]);

  const save = async () => {
    const payload = [{ key: "learning_security", value: sec }, { key: "learning_access", value: access }];
    const r = await supabase.from("app_config").upsert(payload);
    setMessage(r.error ? r.error.message : "Protection et accès enregistrés.");
  };
  const allTier = (tier: string) => setAccess(Object.fromEntries(keys.map((k) => [k, tier])));

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Contenus: protection et accès</h2>
      <label className="flex items-center justify-between rounded border p-2 text-sm"><span>Capture autorisée</span><input type="checkbox" checked={sec.capture_allowed} onChange={(e) => setSec({ ...sec, capture_allowed: e.target.checked })} /></label>
      <label className="flex items-center justify-between rounded border p-2 text-sm"><span>Garder écran actif</span><input type="checkbox" checked={sec.keep_awake} onChange={(e) => setSec({ ...sec, keep_awake: e.target.checked })} /></label>
      <div className="flex flex-wrap gap-2">
        <Button variant="outline" onClick={() => allTier("FREE")}>Tout FREE</Button>
        <Button variant="outline" onClick={() => allTier("HALF")}>Tout HALF</Button>
        <Button variant="outline" onClick={() => allTier("FULL")}>Tout FULL</Button>
      </div>
      <div className="grid gap-2 md:grid-cols-2">
        {keys.map((k) => (
          <label key={k} className="flex items-center justify-between rounded border p-2 text-sm">
            <span>{{ courses: "Cours", exams: "Examens", epreuves: "Épreuves", mockExams: "Examens blancs", videos: "Vidéos", youtube: "YouTube" }[k] || k}</span>
            <select value={access[k] || "HALF"} onChange={(e) => setAccess({ ...access, [k]: e.target.value })} className="rounded border p-1 text-xs">
              <option value="FREE">Gratuit</option><option value="HALF">Partiel</option><option value="FULL">Complet</option>
            </select>
          </label>
        ))}
      </div>
      <Button onClick={save}>Enregistrer</Button>
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
