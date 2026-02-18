"use client";

import { useIdempotentPost } from "@/lib/security/use-idempotent-post";

type Props = { eventId: string };

export const JoinEventButton = ({ eventId }: Props) => {
  const { busy, message, run } = useIdempotentPost();

  const onJoin = async () => {
    const { data } = await run<{ message?: string; paymentUrl?: string }>({
      scope: "events-join",
      keyId: eventId,
      url: "/api/events/join",
      payload: { eventId },
      successMessage: "Inscription enregistrée.",
      errorMessage: "Impossible de traiter ’nscription.",
    });
    if (data?.paymentUrl) window.location.assign(data.paymentUrl);
  };

  return (
    <div className="space-y-2">
      <button onClick={onJoin} disabled={busy} className="rounded bg-orange-500 px-3 py-2 text-white">
        {busy ? "Traitement..." : "’nscrire"}
      </button>
      {message ? <p className="text-sm text-slate-700">{message}</p> : null}
    </div>
  );
};
