"use client";

import { useEffect, useState } from "react";
import {
  Loader2, CheckCircle2, AlertCircle, Copy, Download,
  ArrowRight, QrCode, Ticket, FileText,
} from "lucide-react";
import { trackSiteEvent } from "@/lib/analytics/client";
import { useIdempotentPost } from "@/lib/security/use-idempotent-post";
import { appendAppReturnParams } from "@/lib/app-return";
import { copyToClipboard } from "@/lib/clipboard";

type Kind = "event" | "contest" | "ticket";
type Props = {
  kind: Kind;
  id: string;
  appReturnUrl: string;
  initialIdempotencyKey?: string;
};

type PayResult = {
  message?: string;
  activationCode?: string;
  passCode?: string;
  qrCode?: string;
};

export const PaymentRunner = ({ kind, id, appReturnUrl, initialIdempotencyKey }: Props) => {
  const { busy, message, run } = useIdempotentPost();
  const [activationCode, setActivationCode] = useState<string | null>(null);
  const [passCode, setPassCode] = useState<string | null>(null);
  const [qrCode, setQrCode] = useState<string | null>(null);
  const [returnUrl, setReturnUrl] = useState(appReturnUrl);
  const [success, setSuccess] = useState(false);
  const [copied, setCopied] = useState<string | null>(null);
  const [copyError, setCopyError] = useState<string | null>(null);

  useEffect(() => {
    if (!success) return;
    const timeout = window.setTimeout(() => {
      window.location.assign(returnUrl);
    }, 900);
    return () => window.clearTimeout(timeout);
  }, [returnUrl, success]);

  const payNow = async () => {
    void trackSiteEvent({ name: "payment_redirected", category: "payment", payload: { kind, id } });
    const { response, data } = await run<PayResult>({
      scope: "payments-complete",
      keyId: `${kind}:${id}`,
      url: "/api/payments/complete",
      payload: { kind, id },
      initialIdempotencyKey,
      successMessage: "Paiement validé avec succès !",
      errorMessage: "Une erreur est survenue. Veuillez réessayer.",
    });
    if (data?.activationCode) setActivationCode(String(data.activationCode));
    if (data?.passCode) setPassCode(String(data.passCode));
    if (data?.qrCode) setQrCode(String(data.qrCode));
    if (response?.ok) {
      setSuccess(true);
      setReturnUrl(appendAppReturnParams(appReturnUrl, {
        payment_status: "ok",
        kind,
        activation_code: data?.activationCode ? String(data.activationCode) : null,
        pass_code: data?.passCode ? String(data.passCode) : null,
        qr_code: data?.qrCode ? String(data.qrCode) : null,
      }));
    }
  };

  const copyText = async (text: string, label: string) => {
    try {
      await copyToClipboard(text);
      setCopied(label);
      setCopyError(null);
      window.setTimeout(() => setCopied(null), 2000);
    } catch {
      setCopyError("Copie impossible sur cet appareil.");
    }
  };

  const isError = !busy && !success && message.length > 0;

  return (
    <div className="space-y-4">
      {/* Main card */}
      <section className="rounded-2xl border border-slate-200 bg-white p-5 sm:p-6 space-y-5">
        {!success && (
          <div className="space-y-4">
            <button
              type="button"
              disabled={busy}
              onClick={payNow}
              className="btn-primary w-full justify-center disabled:opacity-60 disabled:pointer-events-none"
            >
              {busy ? (
                <><Loader2 className="w-4 h-4 animate-spin" /> Traitement en cours…</>
              ) : (
                <><Ticket className="w-4 h-4" /> Confirmer le paiement</>
              )}
            </button>

            {isError && (
              <div className="flex items-start gap-2.5 rounded-xl bg-red-50 border border-red-100 p-3.5">
                <AlertCircle className="w-4 h-4 text-red-500 mt-0.5 shrink-0" />
                <p className="text-sm text-red-700 leading-snug">{message}</p>
              </div>
            )}
          </div>
        )}

        {success && (
          <div className="text-center space-y-3">
            <div className="mx-auto w-14 h-14 rounded-full bg-emerald-50 flex items-center justify-center">
              <CheckCircle2 className="w-7 h-7 text-emerald-500" />
            </div>
            <div>
              <p className="text-lg font-bold text-slate-900">Paiement confirmé</p>
              <p className="text-sm text-slate-500 mt-0.5">{message}</p>
              <p className="mt-2 text-xs font-medium text-slate-400" aria-live="polite">
                Retour vers l&apos;application en cours…
              </p>
            </div>
          </div>
        )}

        {copyError && (
          <div className="flex items-start gap-2.5 rounded-xl border border-amber-100 bg-amber-50 p-3.5">
            <AlertCircle className="mt-0.5 h-4 w-4 shrink-0 text-amber-600" />
            <p className="text-sm text-amber-800">{copyError}</p>
          </div>
        )}

        {activationCode && (
          <CodeCard
            label="Code d'activation"
            icon={<Ticket className="w-4 h-4" />}
            code={activationCode}
            copied={copied === "activation"}
            onCopy={() => void copyText(activationCode, "activation")}
            downloadHref={`/api/tickets/code-pdf?code=${activationCode}`}
            downloadLabel="Télécharger le PDF"
          />
        )}

        {passCode && (
          <CodeCard
            label="Pass événement"
            icon={<FileText className="w-4 h-4" />}
            code={passCode}
            copied={copied === "pass"}
            onCopy={() => void copyText(passCode, "pass")}
            downloadHref={`/api/events/ticket-pdf?eventId=${id}`}
            downloadLabel="Télécharger le reçu"
          />
        )}

        {qrCode && (
          <div className="flex items-center gap-3 rounded-xl bg-blue-50 border border-blue-100 p-3.5">
            <QrCode className="w-5 h-5 text-blue-600 shrink-0" />
            <div>
              <p className="text-xs font-semibold text-blue-700 uppercase tracking-wider">QR Concours</p>
              <p className="text-sm font-mono text-slate-800 mt-0.5">{qrCode}</p>
            </div>
          </div>
        )}
      </section>

      <a href={returnUrl} className="btn-secondary w-full justify-center">
        Retourner dans l&apos;application <ArrowRight className="w-4 h-4" />
      </a>
    </div>
  );
};

/* Composant interne : carte code copiable */

type CodeCardProps = {
  label: string;
  icon: React.ReactNode;
  code: string;
  copied: boolean;
  onCopy: () => void;
  downloadHref: string;
  downloadLabel: string;
};

const CodeCard = ({ label, icon, code, copied, onCopy, downloadHref, downloadLabel }: CodeCardProps) => (
  <div className="rounded-xl border border-slate-100 bg-slate-50 p-4 space-y-3">
    <div className="flex items-center gap-2 text-xs font-semibold text-slate-500 uppercase tracking-wider">
      {icon} {label}
    </div>
    <div className="flex items-center gap-2">
      <code className="flex-1 rounded-lg bg-white border border-slate-200 px-3 py-2 text-sm font-mono font-semibold text-slate-900 select-all">
        {code}
      </code>
      <button
        type="button"
        onClick={onCopy}
        className="shrink-0 rounded-lg border border-slate-200 bg-white p-2 text-slate-500 transition hover:bg-slate-100 hover:text-slate-700 active:scale-95"
        aria-label="Copier"
      >
        {copied ? <CheckCircle2 className="w-4 h-4 text-emerald-500" /> : <Copy className="w-4 h-4" />}
      </button>
    </div>
    <a
      href={downloadHref}
      className="inline-flex items-center gap-1.5 text-sm font-medium text-blue-600 hover:text-blue-700 transition-colors"
    >
      <Download className="w-3.5 h-3.5" /> {downloadLabel}
    </a>
  </div>
);
