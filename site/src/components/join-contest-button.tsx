"use client";

import { useIdempotentPost } from "@/lib/security/use-idempotent-post";

type Props = { contestId: string };

export const JoinContestButton = ({ contestId }: Props) => {
  const { busy, message, run } = useIdempotentPost();

  const onJoin = async () => {
    const { data } = await run<{ message?: string; paymentUrl?: string }>({
      scope: "contests-join",
      keyId: contestId,
      url: "/api/contests/join",
      payload: { contestId },
      successMessage: "Participation enregistrée.",
      errorMessage: "Impossible de traiter la participation.",
    });
    if (data?.paymentUrl) window.location.assign(data.paymentUrl);
  };

  return (
    <div className="space-y-2">
      <button onClick={onJoin} disabled={busy} className="rounded bg-blue-600 px-3 py-2 text-white">
        {busy ? "Traitement..." : "Postuler"}
      </button>
      {message ? <p className="text-sm text-slate-700">{message}</p> : null}
    </div>
  );
};
