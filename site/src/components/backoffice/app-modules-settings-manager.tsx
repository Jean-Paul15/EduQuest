"use client";

import { useCallback, useEffect, useState } from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

type BoolMap = Record<string, boolean>;
const authKeys = ["google", "apple", "email_password"];
const hubKeys = ["live", "contests", "events", "surveys", "notifications", "referral", "market", "leaderboard", "orientation"];
const labels: Record<string, string> = {
  google: "Connexion Google",
  apple: "Connexion Apple",
  email_password: "Email + mot de passe",
  live: "Cours en direct",
  contests: "Concours",
  events: "Événements",
  surveys: "Sondages",
  notifications: "Notifications",
  referral: "Parrainage",
  market: "Marketplace",
  leaderboard: "Classement",
  orientation: "Orientation",
};

export const AppModulesSettingsManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [auth, setAuth] = useState<BoolMap>({ google: true, apple: true, email_password: true });
  const [hub, setHub] = useState<BoolMap>({});
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const r = await supabase.from("app_config").select("key,value").in("key", ["auth_options", "hub_modules"]);
    const rows = new Map((r.data || []).map((x: { key: string; value: unknown }) => [x.key, x.value as Record<string, boolean>]));
    setAuth((prev) => ({ ...prev, ...(rows.get("auth_options") || {}) }));
    setHub((prev) => ({ ...prev, ...(rows.get("hub_modules") || {}) }));
  }, [supabase]);

  useEffect(() => {
    const id = window.setTimeout(() => { void load(); }, 0);
    return () => window.clearTimeout(id);
  }, [load]);

  const save = async () => {
    const r = await supabase.from("app_config").upsert([{ key: "auth_options", value: auth }, { key: "hub_modules", value: hub }]);
    setMessage(r.error ? r.error.message : "Préférences enregistrées.");
  };
  const row = (k: string, v: BoolMap, set: (x: BoolMap) => void) => (
    <label key={k} className="flex items-center justify-between rounded border p-2 text-sm">
      <span>{labels[k] || k}</span><input type="checkbox" checked={!!v[k]} onChange={(e) => set({ ...v, [k]: e.target.checked })} />
    </label>
  );

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Fonctions de l&apos;application</h2>
      <p className="text-xs text-slate-500">Connexion</p>
      <div className="grid gap-2 md:grid-cols-3">{authKeys.map((k) => row(k, auth, setAuth))}</div>
      <p className="text-xs text-slate-500">Accueil principal</p>
      <div className="grid gap-2 md:grid-cols-3">{hubKeys.map((k) => row(k, hub, setHub))}</div>
      <Button onClick={save}>Enregistrer</Button>
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
