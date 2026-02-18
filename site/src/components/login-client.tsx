"use client";

import { useMemo, useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

type Props = { nextPath: string; error?: string | null };

export const LoginClient = ({ nextPath, error }: Props) => {
  const supabase = useMemo(() => getSupabaseBrowserClient(), []);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [busy, setBusy] = useState(false);
  const [info, setInfo] = useState(error ? "Session transférée invalide." : "");

  const oauth = async (provider: "google" | "apple") => {
    setBusy(true);
    const redirectTo = `${window.location.origin}/auth/callback?next=${encodeURIComponent(nextPath)}`;
    const { error: authError } = await supabase.auth.signInWithOAuth({ provider, options: { redirectTo } });
    setInfo(authError?.message ?? "");
    setBusy(false);
  };

  const emailLogin = async () => {
    setBusy(true);
    const { error: authError } = await supabase.auth.signInWithPassword({ email, password });
    if (!authError) window.location.assign(nextPath);
    setInfo(authError?.message ?? "");
    setBusy(false);
  };

  return (
    <div className="space-y-4 rounded-2xl border bg-white p-5 shadow-sm">
      <button disabled={busy} onClick={() => oauth("google")} className="w-full rounded bg-slate-900 p-2 text-white">
        Continuer avec Google
      </button>
      <button disabled={busy} onClick={() => oauth("apple")} className="w-full rounded border p-2">
        Continuer avec Apple
      </button>
      <div className="space-y-2 border-t pt-3">
        <input value={email} onChange={(e) => setEmail(e.target.value)} placeholder="Email" className="w-full rounded border p-2" />
        <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} placeholder="Mot de passe" className="w-full rounded border p-2" />
        <button disabled={busy} onClick={emailLogin} className="w-full rounded bg-blue-600 p-2 text-white">
          Connexion email
        </button>
      </div>
      {info ? <p className="text-sm text-red-600">{info}</p> : null}
    </div>
  );
};
