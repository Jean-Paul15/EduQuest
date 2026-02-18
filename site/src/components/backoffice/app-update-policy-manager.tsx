"use client";

import { useCallback, useEffect, useState } from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

type Plat = { min_build_number: number; latest_build_number: number; force_update: boolean; store_url: string };
type Policy = { enabled: boolean; enforce_exact_match: boolean; message: string; android: Plat; ios: Plat };
const emptyPlat: Plat = { min_build_number: 0, latest_build_number: 0, force_update: false, store_url: "" };

export const AppUpdatePolicyManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [p, setP] = useState<Policy>({ enabled: false, enforce_exact_match: false, message: "", android: emptyPlat, ios: emptyPlat });
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const r = await supabase.from("app_config").select("value").eq("key", "app_update_policy").maybeSingle();
    const v = (r.data?.value as Record<string, unknown>) || {};
    const a = (v.android as Record<string, unknown>) || {}; const i = (v.ios as Record<string, unknown>) || {};
    setP({
      enabled: !!v.enabled, enforce_exact_match: !!v.enforce_exact_match, message: String(v.message || ""),
      android: { min_build_number: Number(a.min_build_number || 0), latest_build_number: Number(a.latest_build_number || 0), force_update: !!a.force_update, store_url: String(a.store_url || "") },
      ios: { min_build_number: Number(i.min_build_number || 0), latest_build_number: Number(i.latest_build_number || 0), force_update: !!i.force_update, store_url: String(i.store_url || "") },
    });
  }, [supabase]);

  useEffect(() => {
    const id = window.setTimeout(() => { void load(); }, 0);
    return () => window.clearTimeout(id);
  }, [load]);

  const save = async () => {
    const r = await supabase.from("app_config").upsert({ key: "app_update_policy", value: p });
    setMessage(r.error ? r.error.message : "Politique mise à jour enregistrée.");
  };
  const num = (k: "android" | "ios", f: "min_build_number" | "latest_build_number", v: string) => setP({ ...p, [k]: { ...p[k], [f]: Number(v) || 0 } });
  const txt = (k: "android" | "ios", v: string) => setP({ ...p, [k]: { ...p[k], store_url: v } });
  const force = (k: "android" | "ios", v: boolean) => setP({ ...p, [k]: { ...p[k], force_update: v } });
  const block = (k: "android" | "ios") => <div className="rounded border p-2"><p className="text-xs font-semibold">{k}</p><div className="mt-2 grid gap-2 md:grid-cols-2"><input value={p[k].min_build_number} type="number" onChange={(e) => num(k, "min_build_number", e.target.value)} className="rounded border p-2 text-sm" /><input value={p[k].latest_build_number} type="number" onChange={(e) => num(k, "latest_build_number", e.target.value)} className="rounded border p-2 text-sm" /><input value={p[k].store_url} onChange={(e) => txt(k, e.target.value)} className="rounded border p-2 text-sm md:col-span-2" /><label className="flex items-center gap-2 text-sm"><input type="checkbox" checked={p[k].force_update} onChange={(e) => force(k, e.target.checked)} /> force_update</label></div></div>;

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Mise à jour obligatoire</h2>
      <label className="flex items-center gap-2 text-sm"><input type="checkbox" checked={p.enabled} onChange={(e) => setP({ ...p, enabled: e.target.checked })} /> enabled</label>
      <label className="flex items-center gap-2 text-sm"><input type="checkbox" checked={p.enforce_exact_match} onChange={(e) => setP({ ...p, enforce_exact_match: e.target.checked })} /> enforce_exact_match</label>
      <input value={p.message} onChange={(e) => setP({ ...p, message: e.target.value })} placeholder="Message blocage update" className="w-full rounded border p-2 text-sm" />
      <div className="grid gap-2 md:grid-cols-2">{block("android")}{block("ios")}</div>
      <Button onClick={save}>Enregistrer</Button>
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
