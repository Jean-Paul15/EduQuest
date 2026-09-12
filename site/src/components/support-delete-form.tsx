"use client";

import { useState } from "react";
import { useIdempotentPost } from "@/lib/security/use-idempotent-post";

type Props = { logged: boolean };

export const SupportDeleteForm = ({ logged }: Props) => {
  const { busy, message, run } = useIdempotentPost();
  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [reason, setReason] = useState("");

  const submit = async () => {
    const payload = logged ? { reason } : { fullName, email, phone, reason };
    await run({
      scope: "support-delete",
      keyId: email || "me",
      url: "/api/support/delete-request",
      payload,
      successMessage: "Demande envoyée.",
      errorMessage: "Impossible d'envoyer la demande.",
    });
  };

  return (
    <section className="space-y-3 rounded-2xl border bg-white p-5">
      <h2 className="text-lg font-semibold">Demande de suppression des données</h2>
      {!logged ? (
        <>
          <input value={fullName} onChange={(e) => setFullName(e.target.value)} placeholder="Nom complet" className="w-full rounded border p-2" />
          <input value={email} onChange={(e) => setEmail(e.target.value)} placeholder="Email" className="w-full rounded border p-2" />
          <input value={phone} onChange={(e) => setPhone(e.target.value)} placeholder="Téléphone" className="w-full rounded border p-2" />
        </>
      ) : null}
      <textarea value={reason} onChange={(e) => setReason(e.target.value)} placeholder="Raison (optionnel)" className="min-h-24 w-full rounded border p-2" />
      <button onClick={submit} disabled={busy} className="rounded bg-slate-900 px-4 py-2 text-white disabled:opacity-60">
        {busy ? "Envoi..." : "Envoyer la demande"}
      </button>
      {message ? <p className="text-sm text-slate-700">{message}</p> : null}
    </section>
  );
};
