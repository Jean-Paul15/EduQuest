"use client";

import { useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";
import { Button } from "@/components/ui/button";

export const BackofficeResetPasswordForm = () => {
  const supabase = getSupabaseBrowserClient();
  const [password, setPassword] = useState("");
  const [confirm, setConfirm] = useState("");
  const [message, setMessage] = useState("");

  const submit = async () => {
    if (password.length < 8 || password != confirm) {
      setMessage("Mot de passe invalide ou confirmation différente.");
      return;
    }
    const auth = await supabase.auth.updateUser({ password });
    if (auth.error) {
      setMessage(auth.error.message);
      return;
    }
    await supabase.rpc("mark_backoffice_password_reset_done");
    setMessage("Mot de passe modifié. Tu peux continuer.");
    window.location.assign("/backoffice");
  };

  return (
    <div className="space-y-3 rounded-xl border bg-white p-5">
      <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} placeholder="Nouveau mot de passe" className="w-full rounded border p-2" />
      <input type="password" value={confirm} onChange={(e) => setConfirm(e.target.value)} placeholder="Confirmer le mot de passe" className="w-full rounded border p-2" />
      <Button onClick={submit}>Enregistrer</Button>
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </div>
  );
};
