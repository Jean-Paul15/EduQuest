"use client";

import { useCallback, useEffect, useState } from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

type SecurityCfg = {
  enforce_sensitive_guard: boolean; block_learning_capture: boolean; block_hub_capture: boolean;
  watermark_enabled: boolean; watermark_label: string; watermark_opacity: number;
};
const base: SecurityCfg = {
  enforce_sensitive_guard: true, block_learning_capture: true, block_hub_capture: false,
  watermark_enabled: false, watermark_label: "EduQuest • Protégé", watermark_opacity: 0.2,
};

export const AdvancedSecuritySettingsManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [cfg, setCfg] = useState<SecurityCfg>(base);
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const r = await supabase.from("app_config").select("value").eq("key", "security_advanced").maybeSingle();
    setCfg({ ...base, ...((r.data?.value as Partial<SecurityCfg>) || {}) });
  }, [supabase]);
  useEffect(() => { const id = window.setTimeout(() => { void load(); }, 0); return () => window.clearTimeout(id); }, [load]);

  const save = async () => {
    const value = { ...cfg, watermark_opacity: Math.max(0.05, Math.min(0.9, cfg.watermark_opacity)) };
    const r = await supabase.from("app_config").upsert({ key: "security_advanced", value });
    setMessage(r.error ? r.error.message : "Protection avancée enregistrée.");
  };

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Protection avancée</h2>
      {([
        ["enforce_sensitive_guard", "Activer la protection renforcée"],
        ["block_learning_capture", "Bloquer capture sur contenus d'apprentissage"],
        ["block_hub_capture", "Bloquer capture sur l'accueil"],
        ["watermark_enabled", "Afficher un marquage visuel"],
      ] as const).map(([k, label]) => (
        <label key={k} className="flex items-center justify-between rounded border p-2 text-sm"><span>{label}</span><input type="checkbox" checked={cfg[k]} onChange={(e) => setCfg({ ...cfg, [k]: e.target.checked })} /></label>
      ))}
      <input value={cfg.watermark_label} onChange={(e) => setCfg({ ...cfg, watermark_label: e.target.value })} placeholder="Texte du marquage" className="w-full rounded border p-2 text-sm" />
      <input type="number" min={0.05} max={0.9} step="0.05" value={cfg.watermark_opacity} onChange={(e) => setCfg({ ...cfg, watermark_opacity: Number(e.target.value) || 0.2 })} placeholder="Intensité du marquage" className="w-full rounded border p-2 text-sm" />
      <Button onClick={save}>Enregistrer</Button>
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
