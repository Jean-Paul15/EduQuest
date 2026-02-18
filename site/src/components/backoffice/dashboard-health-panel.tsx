"use client";

import { useCallback, useEffect, useState } from "react";
import { Card } from "@/components/ui/card";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

type Status = { key: string; ok: boolean; detail: string };
type AppCfgRow = { key: string; value: unknown };
const keys = ["app_links", "hub_modules", "auth_options", "learning_access"];

export const DashboardHealthPanel = () => {
  const supabase = getSupabaseBrowserClient();
  const [rows, setRows] = useState<Status[]>([]);

  const load = useCallback(async () => {
    const r = await supabase.from("app_config").select("key,value").in("key", keys);
    const map = new Map((((r.data || []) as AppCfgRow[])).map((x) => [String(x.key), x.value]));
    const out = keys.map((k) => {
      const v = map.get(k);
      const ok = !!v && typeof v === "object" && Object.keys(v as object).length > 0;
      return { key: k, ok, detail: ok ? "ok" : "vide/manquant" };
    });
    setRows(out);
  }, [supabase]);

  useEffect(() => {
    const id = window.setTimeout(() => { void load(); }, 0);
    return () => window.clearTimeout(id);
  }, [load]);

  return (
    <Card className="space-y-2 p-4">
      <h2 className="font-semibold">Santé configuration runtime</h2>
      {rows.map((x) => (
        <div key={x.key} className="flex items-center justify-between rounded border p-2 text-sm">
          <p>{x.key}</p>
          <p className={x.ok ? "text-emerald-600 font-semibold" : "text-orange-600 font-semibold"}>{x.detail}</p>
        </div>
      ))}
    </Card>
  );
};
