"use client";

type Tone = "success" | "error" | "info";

export const BackofficeInlineFeedback = ({
  message,
  tone = "info",
}: {
  message: string;
  tone?: Tone;
}) => {
  if (!message) return null;
  const cls =
    tone === "success"
      ? "border-emerald-200 bg-emerald-50 text-emerald-700"
      : tone === "error"
        ? "border-red-200 bg-red-50 text-red-700"
        : "border-blue-200 bg-blue-50 text-blue-700";
  return <p className={`rounded-xl border px-3 py-2 text-sm ${cls}`}>{message}</p>;
};

