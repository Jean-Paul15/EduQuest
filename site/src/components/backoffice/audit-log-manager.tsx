"use client";

import { useCallback, useEffect, useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";
import { Card } from "@/components/ui/card";

type Audit = { id: string; action: string; details: Record<string, unknown>; created_at: string };
const label = (x: string) => x.replaceAll("_", " ");

export const AuditLogManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [rows, setRows] = useState<Audit[]>([]);

  const load = useCallback(async () => {
    const r = await supabase.from("compliance_audit_logs").select("id,action,details,created_at").order("created_at", { ascending: false }).limit(40);
    setRows((r.data as Audit[]) || []);
  }, [supabase]);

  useEffect(() => {
    const id = window.setTimeout(() => { void load(); }, 0);
    return () => window.clearTimeout(id);
  }, [load]);

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Historique des actions</h2>
      {rows.map((r) => (
        <div key={r.id} className="rounded border p-2">
          <p className="text-sm font-medium">{label(r.action)}</p>
          <p className="text-xs text-slate-500">{r.created_at}</p>
          <div className="mt-1 rounded bg-slate-50 p-2 text-[11px]">
            {Object.entries(r.details || {}).slice(0, 6).map(([k, v]) => (
              <p key={k}><span className="font-semibold">{label(k)}:</span> {String(v)}</p>
            ))}
          </div>
        </div>
      ))}
    </Card>
  );
};
