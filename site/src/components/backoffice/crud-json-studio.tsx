"use client";

import { useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

type Props = { table: string; title: string; pk?: string };
type JsonRow = { [key: string]: unknown };

export const CrudJsonStudio = ({ table, title, pk = "id" }: Props) => {
  const supabase = getSupabaseBrowserClient();
  const [rows, setRows] = useState<string[]>([]);
  const [draft, setDraft] = useState("{}");
  const [message, setMessage] = useState("");

  const load = async () => {
    const r = await supabase.from(table).select("*").limit(25);
    const data = (r.data as JsonRow[] | null) || [];
    setRows(data.map((x) => JSON.stringify(x, null, 2)));
  };

  const saveRow = async (raw: string) => {
    try {
      const row = JSON.parse(raw) as JsonRow;
      if (!row[pk]) throw new Error();
      const r = await supabase.from(table).update(row).eq(pk, String(row[pk]));
      setMessage(r.error ? r.error.message : "Ligne mise à jour.");
      if (!r.error) load();
    } catch {
      setMessage("Format invalide ou identifiant manquant.");
    }
  };

  const deleteRow = async (raw: string) => {
    const row = JSON.parse(raw) as JsonRow;
    const id = row[pk] ? String(row[pk]) : "";
    if (!id) return setMessage("Identifiant manquant.");
    const r = await supabase.from(table).delete().eq(pk, id);
    setMessage(r.error ? r.error.message : "Ligne supprimée.");
    if (!r.error) load();
  };

  const insertRow = async () => {
    try {
      const row = JSON.parse(draft) as JsonRow;
      const r = await supabase.from(table).insert(row);
      setMessage(r.error ? r.error.message : "Ligne ajoutée.");
      if (!r.error) load();
    } catch {
      setMessage("Format invalide.");
    }
  };

  return (
    <Card className="space-y-3 p-4">
      <div className="flex items-center justify-between">
        <h2 className="font-semibold">{title}</h2>
        <Button onClick={load}>Charger</Button>
      </div>
      <p className="text-xs text-slate-500">Mode avancé réservé aux administrateurs.</p>
      <textarea value={draft} onChange={(e) => setDraft(e.target.value)} className="h-28 w-full rounded border p-2 font-mono text-xs" />
      <Button onClick={insertRow}>Ajouter</Button>
      {rows.map((raw, i) => (
        <div key={i} className="space-y-2 rounded border p-2">
          <textarea value={raw} onChange={(e) => setRows((v) => v.map((x, k) => (k == i ? e.target.value : x)))} className="h-40 w-full rounded border p-2 font-mono text-xs" />
          <div className="flex gap-2">
            <Button onClick={() => saveRow(rows[i])}>Enregistrer</Button>
            <Button variant="outline" onClick={() => deleteRow(rows[i])}>Supprimer</Button>
          </div>
        </div>
      ))}
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
