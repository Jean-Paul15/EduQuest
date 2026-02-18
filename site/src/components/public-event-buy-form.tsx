"use client";

import { useState } from "react";
import {
  Loader2, CheckCircle2, AlertCircle, Copy, Download,
  ArrowRight, User, Mail, Phone, FileText,
} from "lucide-react";
import { useIdempotentPost } from "@/lib/security/use-idempotent-post";

type Props = { eventId: string; appReturnUrl: string };

const fields = [
  { key: "firstName" as const, label: "Pr\u00e9nom", icon: User, type: "text" },
  { key: "lastName" as const, label: "Nom", icon: User, type: "text" },
  { key: "email" as const, label: "Email", icon: Mail, type: "email" },
  { key: "phone" as const, label: "T\u00e9l\u00e9phone", icon: Phone, type: "tel" },
];

export const PublicEventBuyForm = ({ eventId, appReturnUrl }: Props) => {
  const [form, setForm] = useState({ firstName: "", lastName: "", email: "", phone: "" });
  const { busy, message, run } = useIdempotentPost();
  const [ticketCode, setTicketCode] = useState<string | null>(null);
  const [copied, setCopied] = useState(false);
  const success = !!ticketCode;
  const isError = !busy && !success && message.length > 0;

  const submit = async () => {
    const { data } = await run<{ message?: string; ticketCode?: string }>({
      scope: "events-public-buy",
      keyId: eventId,
      url: "/api/events/public-buy",
      payload: { eventId, ...form },
      successMessage: "Paiement valid\u00e9 !",
      errorMessage: "Impossible de finaliser l\u2019achat. V\u00e9rifiez vos informations.",
    });
    if (data?.ticketCode) setTicketCode(String(data.ticketCode));
  };

  const copyCode = () => {
    if (!ticketCode) return;
    navigator.clipboard.writeText(ticketCode);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="space-y-4">
      {/* Form */}
      {!success && (
        <section className="rounded-2xl border border-slate-200 bg-white p-5 space-y-4">
          <h2 className="text-base font-bold text-slate-900">Vos informations</h2>
          <div className="grid gap-3">
            {fields.map((f) => (
              <div key={f.key} className="relative">
                <f.icon className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
                <input
                  type={f.type}
                  value={form[f.key]}
                  onChange={(e) => setForm((v) => ({ ...v, [f.key]: e.target.value }))}
                  placeholder={f.label}
                  className="w-full rounded-xl border border-slate-200 bg-white py-3 pl-10 pr-4 text-sm text-slate-900 placeholder:text-slate-400 transition focus:border-blue-400 focus:ring-2 focus:ring-blue-100 focus:outline-none"
                />
              </div>
            ))}
          </div>

          <button
            type="button"
            onClick={submit}
            disabled={busy}
            className="btn-primary w-full justify-center disabled:opacity-60 disabled:pointer-events-none"
          >
            {busy ? (
              <><Loader2 className="w-4 h-4 animate-spin" /> Traitement en cours&hellip;</>
            ) : (
              <><FileText className="w-4 h-4" /> Payer et g\u00e9n\u00e9rer le ticket</>
            )}
          </button>

          {isError && (
            <div className="flex items-start gap-2.5 rounded-xl bg-red-50 border border-red-100 p-3">
              <AlertCircle className="w-4 h-4 text-red-500 mt-0.5 shrink-0" />
              <p className="text-sm text-red-700">{message}</p>
            </div>
          )}
        </section>
      )}

      {/* Success */}
      {success && ticketCode && (
        <section className="rounded-2xl border border-slate-200 bg-white p-5 space-y-5">
          <div className="text-center space-y-2">
            <div className="mx-auto w-14 h-14 rounded-full bg-emerald-50 flex items-center justify-center">
              <CheckCircle2 className="w-7 h-7 text-emerald-500" />
            </div>
            <p className="text-lg font-bold text-slate-900">Ticket g\u00e9n\u00e9r\u00e9</p>
            <p className="text-sm text-slate-500">{message}</p>
          </div>
          <div className="rounded-xl border border-slate-100 bg-slate-50 p-4 space-y-3">
            <p className="text-xs font-bold text-slate-500 uppercase tracking-wider flex items-center gap-1.5">
              <FileText className="w-3.5 h-3.5" /> Code ticket
            </p>
            <div className="flex items-center gap-2">
              <code className="flex-1 rounded-lg bg-white border border-slate-200 px-3 py-2.5 text-base font-mono font-bold text-slate-900 select-all text-center tracking-wider">
                {ticketCode}
              </code>
              <button type="button" onClick={copyCode} className="shrink-0 rounded-lg border border-slate-200 bg-white p-2.5 text-slate-500 transition hover:bg-slate-100 active:scale-95" aria-label="Copier">
                {copied ? <CheckCircle2 className="w-4 h-4 text-emerald-500" /> : <Copy className="w-4 h-4" />}
              </button>
            </div>
            <a href={`/api/events/public-ticket-pdf?ticket=${ticketCode}`} className="inline-flex items-center gap-1.5 text-sm font-medium text-blue-600 hover:text-blue-700 transition-colors">
              <Download className="w-3.5 h-3.5" /> T\u00e9l\u00e9charger le re\u00e7u PDF
            </a>
          </div>
        </section>
      )}

      {/* Return */}
      <a href={appReturnUrl} className="btn-secondary w-full justify-center">
        Ouvrir l&apos;application <ArrowRight className="w-4 h-4" />
      </a>
    </div>
  );
};
