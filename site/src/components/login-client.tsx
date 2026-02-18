"use client";

import { useMemo, useState } from "react";
import { Eye, EyeOff, Loader2, ShieldCheck } from "lucide-react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

type Props = { nextPath: string; error?: string | null };
const prettyError = (msg: string) => {
  const m = msg.toLowerCase();
  if (m.includes("invalid login credentials")) return "Email ou mot de passe incorrect.";
  if (m.includes("email not confirmed")) return "Confirme ton email avant de te connecter.";
  return "Connexion impossible pour le moment. Réessaie.";
};

export const LoginClient = ({ nextPath, error }: Props) => {
  const supabase = useMemo(() => getSupabaseBrowserClient(), []);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [busy, setBusy] = useState(false);
  const [info, setInfo] = useState(error ? "Session expirée, reconnecte-toi." : "");
  const canSubmit = email.trim().includes("@") && password.length >= 6;

  const oauth = async (provider: "google" | "apple") => {
    setBusy(true);
    setInfo("");
    const redirectTo = `${window.location.origin}/auth/callback?next=${encodeURIComponent(nextPath)}`;
    const { error: authError } = await supabase.auth.signInWithOAuth({ provider, options: { redirectTo } });
    setInfo(authError?.message ? prettyError(authError.message) : "");
    setBusy(false);
  };

  const emailLogin = async () => {
    if (!canSubmit) return setInfo("Renseigne un email valide et un mot de passe (6 caractères min).");
    setBusy(true);
    setInfo("");
    const { error: authError } = await supabase.auth.signInWithPassword({ email, password });
    if (!authError) window.location.assign(nextPath);
    setInfo(authError?.message ? prettyError(authError.message) : "");
    setBusy(false);
  };

  return (
    <div className="space-y-4 rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
      <div className="rounded-xl border border-emerald-100 bg-emerald-50 px-3 py-2 text-xs text-emerald-700">
        <p className="flex items-center gap-1"><ShieldCheck className="h-3.5 w-3.5" />Connexion sécurisée. Tes données sont protégées.</p>
      </div>
      <button disabled={busy} onClick={() => oauth("google")} className="w-full rounded-xl bg-slate-900 p-2.5 text-sm font-semibold text-white disabled:opacity-60">
        {busy ? <span className="inline-flex items-center gap-2"><Loader2 className="h-4 w-4 animate-spin" />Connexion...</span> : "Continuer avec Google"}
      </button>
      <button disabled={busy} onClick={() => oauth("apple")} className="w-full rounded-xl border border-slate-300 p-2.5 text-sm font-semibold disabled:opacity-60">
        Continuer avec Apple
      </button>
      <div className="space-y-2 border-t border-slate-200 pt-3">
        <input value={email} onChange={(e) => setEmail(e.target.value)} placeholder="Adresse email" className="w-full rounded-xl border p-2.5 text-sm" />
        <div className="flex gap-2">
          <input type={showPassword ? "text" : "password"} value={password} onChange={(e) => setPassword(e.target.value)} placeholder="Mot de passe" className="w-full rounded-xl border p-2.5 text-sm" onKeyDown={(e) => { if (e.key === "Enter") void emailLogin(); }} />
          <button type="button" onClick={() => setShowPassword((v) => !v)} className="rounded-xl border px-3 text-slate-600">
            {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
          </button>
        </div>
        <button disabled={busy || !canSubmit} onClick={emailLogin} className="w-full rounded-xl bg-blue-600 p-2.5 text-sm font-semibold text-white disabled:opacity-60">
          {busy ? <span className="inline-flex items-center gap-2"><Loader2 className="h-4 w-4 animate-spin" />Connexion...</span> : "Se connecter"}
        </button>
      </div>
      {info ? <p className="rounded-xl border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-700">{info}</p> : null}
    </div>
  );
};
