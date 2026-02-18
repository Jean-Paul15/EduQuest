"use client";

import { useCallback, useEffect, useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

const keys = ["app_links", "hub_modules", "learning_access", "auth_options"];
const pretty: Record<string, string> = {
  app_links: "Liens app et site",
  hub_modules: "Fonctions d'accueil",
  learning_access: "Accès aux contenus",
  auth_options: "Options de connexion",
};

export const ContentManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [items, setItems] = useState<Record<string, string>>({});
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const r = await supabase.from("app_config").select("key,value").in("key", keys);
    const out: Record<string, string> = {};
    (r.data || []).forEach((x: { key: string; value: unknown }) => {
      out[x.key] = JSON.stringify(x.value || {}, null, 2);
    });
    setItems(out);
  }, [supabase]);

  useEffect(() => {
    const id = window.setTimeout(() => { void load(); }, 0);
    return () => window.clearTimeout(id);
  }, [load]);

  const save = async (key: string) => {
    try {
      const value = JSON.parse(items[key] || "{}");
      const r = await supabase.from("app_config").upsert({ key, value });
      if (r.error) throw r.error;
      setMessage(`Réglage "${pretty[key] || key}" enregistré.`);
    } catch {
      setMessage(`Format invalide pour "${pretty[key] || key}".`);
    }
  };

  return (
    <div className="space-y-4">
      {keys.map((key) => (
        <Card key={key} className="space-y-3 p-4">
          <p className="text-sm font-semibold text-slate-900">{pretty[key] || key}</p>
          <p className="text-xs text-slate-500">Édition avancée (réservée administrateur).</p>
          <textarea
            value={items[key] || "{}"}
            onChange={(e) => setItems((v) => ({ ...v, [key]: e.target.value }))}
            className="h-40 w-full rounded border p-2 font-mono text-xs"
          />
          <Button onClick={() => save(key)}>Enregistrer</Button>
        </Card>
      ))}
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </div>
  );
};
