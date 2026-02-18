"use client";

import { useCallback, useEffect, useState } from "react";
import { Card } from "@/components/ui/card";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

type Status = { key: string; ok: boolean; detail: string };
type AppCfgRow = { key: string; value: unknown };
const keys = ["app_links", "hub_modules", "auth_options", "learning_access"];
const labels: Record<string, string> = {
  app_links: "Liens App ↔ Site",
  hub_modules: "Fonctions d'accueil",
  auth_options: "Options de connexion",
  learning_access: "Accès aux contenus",
};

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
      <h2 className="font-semibold">Vérification de l&apos;application</h2>
      <p className="text-xs text-slate-500">Vérifie que les réglages importants de l&apos;application sont bien remplis.</p>
      {rows.map((x) => (
        <div key={x.key} className="rounded border p-2 text-sm">
          <div className="flex items-center justify-between">
            <p>{labels[x.key] || x.key}</p>
            <p className={x.ok ? "text-emerald-600 font-semibold" : "text-orange-600 font-semibold"}>{x.ok ? "OK" : "Action requise"}</p>
          </div>
          {!x.ok ? <p className="text-xs text-slate-500">Ouvre la section Paramètres application pour compléter cet élément.</p> : null}
        </div>
      ))}
    </Card>
  );
};
