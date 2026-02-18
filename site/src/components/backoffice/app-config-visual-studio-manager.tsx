"use client";

import { useCallback, useEffect, useState } from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

type Row = { key: string; value: Record<string, unknown> };
const keys = (o: Record<string, unknown>) => Object.keys(o).sort();
const str = (v: unknown) => String(v ?? "");
const pretty = (k: string) =>
  ({
    app_links: "Liens app/site",
    auth_options: "Options de connexion",
    hub_modules: "Fonctions accueil",
    learning_access: "Accès aux contenus",
    learning_security: "Protection contenus",
    feed_modules: "Contenu d'accueil",
    app_update_policy: "Mise à jour obligatoire",
  }[k] || k);

export const AppConfigVisualStudioManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [rows, setRows] = useState<Row[]>([]); const [key, setKey] = useState(""); const [draft, setDraft] = useState<Record<string, unknown>>({});
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const r = await supabase.from("app_config").select("key,value").order("key");
    const v = ((r.data || []) as Row[]).map((x) => ({ key: x.key, value: (x.value || {}) as Record<string, unknown> }));
    const current = key ? v.find((x) => x.key === key) : v[0];
    setRows(v); if (current) { setKey(current.key); setDraft(current.value); }
  }, [key, supabase]);
  useEffect(() => { const id = window.setTimeout(() => { void load(); }, 0); return () => window.clearTimeout(id); }, [load]);

  const setField = (k: string, v: unknown) => setDraft((p) => ({ ...p, [k]: v }));
  const setSub = (k: string, s: string, v: unknown) => setDraft((p) => ({ ...p, [k]: { ...((p[k] as Record<string, unknown>) || {}), [s]: v } }));
  const save = async () => { const r = await supabase.from("app_config").upsert({ key, value: draft }); setMessage(r.error ? r.error.message : `Réglages "${pretty(key)}" enregistrés.`); if (!r.error) await load(); };

  const control = (val: unknown, on: (v: unknown) => void) =>
    typeof val === "boolean" ? <input type="checkbox" checked={val} onChange={(e) => on(e.target.checked)} /> :
    typeof val === "number" ? <input type="number" value={val} onChange={(e) => on(Number(e.target.value) || 0)} className="rounded border p-1 text-xs" /> :
    Array.isArray(val) ? <input value={(val as unknown[]).map(str).join(",")} onChange={(e) => on(e.target.value.split(",").map((x) => x.trim()).filter(Boolean))} className="rounded border p-1 text-xs" /> :
    <input value={str(val)} onChange={(e) => on(e.target.value)} className="rounded border p-1 text-xs" />;

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Éditeur avancé des réglages</h2>
      <select value={key} onChange={(e) => { const next = rows.find((x) => x.key === e.target.value); setKey(e.target.value); setDraft((next?.value || {}) as Record<string, unknown>); }} className="w-full rounded border p-2 text-sm">{rows.map((x) => <option key={x.key} value={x.key}>{pretty(x.key)}</option>)}</select>
      <div className="grid gap-2">
        {keys(draft).map((k) => {
          const v = draft[k];
          if (v && typeof v === "object" && !Array.isArray(v)) {
            return <div key={k} className="rounded border p-2 text-xs"><p className="mb-2 font-semibold">{k}</p>{keys(v as Record<string, unknown>).map((s) => <label key={s} className="mb-1 flex items-center justify-between gap-2"><span>{s}</span>{control((v as Record<string, unknown>)[s], (x) => setSub(k, s, x))}</label>)}</div>;
          }
          return <label key={k} className="flex items-center justify-between rounded border p-2 text-xs"><span>{k}</span>{control(v, (x) => setField(k, x))}</label>;
        })}
      </div>
      <Button onClick={save}>Enregistrer</Button>
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
