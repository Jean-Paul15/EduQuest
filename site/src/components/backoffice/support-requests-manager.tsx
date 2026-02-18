"use client";

import { useCallback, useEffect, useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";
import { Card } from "@/components/ui/card";

type Item = {
  id: string;
  full_name: string | null;
  email: string;
  phone: string | null;
  status: string;
  source: string;
  created_at: string;
};

const statuses = ["pending", "in_review", "done", "rejected"];

export const SupportRequestsManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [rows, setRows] = useState<Item[]>([]);
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const r = await supabase.from("data_deletion_requests").select("*").order("created_at", { ascending: false }).limit(50);
    setRows((r.data as Item[]) || []);
  }, [supabase]);

  useEffect(() => {
    const id = window.setTimeout(() => { void load(); }, 0);
    return () => window.clearTimeout(id);
  }, [load]);

  const updateStatus = async (id: string, status: string) => {
    const r = await supabase.from("data_deletion_requests").update({ status }).eq("id", id);
    setMessage(r.error ? r.error.message : "Statut mis à jour.");
    if (!r.error) load();
  };

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Demandes suppression données</h2>
      {rows.map((r) => (
        <div key={r.id} className="grid gap-2 rounded border p-2 md:grid-cols-[1fr_160px]">
          <div>
            <p className="text-sm font-medium">{r.full_name || "Utilisateur inconnu"} • {r.email}</p>
            <p className="text-xs text-slate-500">{r.phone || "Sans téléphone"} • {r.source}</p>
          </div>
          <select
            value={r.status}
            onChange={(e) => updateStatus(r.id, e.target.value)}
            className="rounded border p-2 text-sm"
          >
            {statuses.map((s) => <option key={s} value={s}>{s}</option>)}
          </select>
        </div>
      ))}
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
