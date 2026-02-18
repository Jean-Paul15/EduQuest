"use client";

import { useCallback, useEffect, useState } from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

type Policy = {
  prefetch_before_nav: boolean; aggressive_navigation: boolean; background_refresh: boolean;
  home_ttl_min: number; hub_ttl_min: number; learning_ttl_min: number; feed_ttl_min: number;
  pdf_cache_days: number; max_cache_mb: number;
};
const base: Policy = {
  prefetch_before_nav: true, aggressive_navigation: true, background_refresh: true,
  home_ttl_min: 10, hub_ttl_min: 10, learning_ttl_min: 30, feed_ttl_min: 20, pdf_cache_days: 30, max_cache_mb: 512,
};

export const OfflineCachePolicyManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [cfg, setCfg] = useState<Policy>(base);
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const r = await supabase.from("app_config").select("value").eq("key", "offline_cache_policy").maybeSingle();
    setCfg({ ...base, ...((r.data?.value as Partial<Policy>) || {}) });
  }, [supabase]);
  useEffect(() => { const id = window.setTimeout(() => { void load(); }, 0); return () => window.clearTimeout(id); }, [load]);

  const save = async () => {
    const value = {
      ...cfg,
      home_ttl_min: Math.max(1, cfg.home_ttl_min), hub_ttl_min: Math.max(1, cfg.hub_ttl_min),
      learning_ttl_min: Math.max(1, cfg.learning_ttl_min), feed_ttl_min: Math.max(1, cfg.feed_ttl_min),
      pdf_cache_days: Math.max(1, cfg.pdf_cache_days), max_cache_mb: Math.max(128, cfg.max_cache_mb),
    };
    const r = await supabase.from("app_config").upsert({ key: "offline_cache_policy", value });
    setMessage(r.error ? r.error.message : "Stratégie offline/cache enregistrée.");
  };
  const n = (k: keyof Policy, v: string) => setCfg({ ...cfg, [k]: Number(v) || 0 });

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Offline/Cache: TTL et préchargement</h2>
      <div className="grid gap-2 md:grid-cols-3">
        {(["prefetch_before_nav", "aggressive_navigation", "background_refresh"] as const).map((k) => (
          <label key={k} className="flex items-center justify-between rounded border p-2 text-sm"><span>{k}</span><input type="checkbox" checked={cfg[k]} onChange={(e) => setCfg({ ...cfg, [k]: e.target.checked })} /></label>
        ))}
      </div>
      <div className="grid gap-2 md:grid-cols-3">
        <input type="number" min={1} value={cfg.home_ttl_min} onChange={(e) => n("home_ttl_min", e.target.value)} className="rounded border p-2 text-sm" />
        <input type="number" min={1} value={cfg.hub_ttl_min} onChange={(e) => n("hub_ttl_min", e.target.value)} className="rounded border p-2 text-sm" />
        <input type="number" min={1} value={cfg.learning_ttl_min} onChange={(e) => n("learning_ttl_min", e.target.value)} className="rounded border p-2 text-sm" />
        <input type="number" min={1} value={cfg.feed_ttl_min} onChange={(e) => n("feed_ttl_min", e.target.value)} className="rounded border p-2 text-sm" />
        <input type="number" min={1} value={cfg.pdf_cache_days} onChange={(e) => n("pdf_cache_days", e.target.value)} className="rounded border p-2 text-sm" />
        <input type="number" min={128} value={cfg.max_cache_mb} onChange={(e) => n("max_cache_mb", e.target.value)} className="rounded border p-2 text-sm" />
      </div>
      <Button onClick={save}>Enregistrer</Button>
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
