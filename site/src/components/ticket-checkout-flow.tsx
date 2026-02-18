"use client";

import { useMemo, useState } from "react";
import {
  Loader2, CheckCircle2, AlertCircle, Copy, Download,
  Ticket, ArrowRight, Sparkles, ShieldCheck,
} from "lucide-react";
import { useIdempotentPost } from "@/lib/security/use-idempotent-post";
import type { TicketCheckoutOption } from "@/lib/data/tickets";
import { cn } from "@/lib/utils";

type Props = { options: TicketCheckoutOption[]; appReturnUrl: string };

export const TicketCheckoutFlow = ({ options, appReturnUrl }: Props) => {
  const { busy, message, run } = useIdempotentPost();
  const [selected, setSelected] = useState(options[0]?.product_id || "");
  const [code, setCode] = useState<string | null>(null);
  const [copied, setCopied] = useState(false);
  const current = useMemo(() => options.find((x) => x.product_id === selected) || null, [options, selected]);
  const success = !!code;
  const isError = !busy && !success && message.length > 0;

  const pay = async () => {
    if (!current) return;
    const { data, response } = await run<{ activationCode?: string }>({
      scope: "payments-complete",
      keyId: `ticket:${current.product_id}`,
      url: "/api/payments/complete",
      payload: { kind: "ticket", id: current.product_id },
      successMessage: "Paiement validé !",
      errorMessage: "Échec du paiement. Veuillez réessayer.",
    });
    if (response?.ok && data?.activationCode) setCode(String(data.activationCode));
  };

  const copyCode = () => {
    if (!code) return;
    navigator.clipboard.writeText(code);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="space-y-4">
      {/* Ticket selection */}
      {!success && (
        <section className="rounded-2xl border border-slate-200 bg-white p-5 space-y-4">
          <h2 className="text-base font-bold text-slate-900">Choisir votre formule</h2>
          <div className="grid gap-2.5">
            {options.map((x) => {
              const active = selected === x.product_id;
              return (
                <button
                  type="button"
                  key={x.product_id}
                  onClick={() => setSelected(x.product_id)}
                  className={cn(
                    "relative w-full rounded-xl border-2 p-4 text-left transition-all",
                    active
                      ? "border-blue-500 bg-blue-50/60 shadow-sm"
                      : "border-slate-200 bg-white hover:border-slate-300 hover:bg-slate-50"
                  )}
                >
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm font-bold text-slate-900">{x.product_code}</p>
                      <p className="text-xs text-slate-500 mt-0.5">
                        {x.ticket_type === "FULL" ? "Accès complet" : "Accès essentiel"} &middot; {x.duration_days} jours
                      </p>
                    </div>
                    <div className="text-right">
                      <p className="text-lg font-extrabold text-slate-900">{x.total_price.toLocaleString("fr-FR")}</p>
                      <p className="text-[11px] text-slate-400 font-medium">XOF</p>
                    </div>
                  </div>
                  {x.is_upgrade && (
                    <span className="mt-2 inline-flex items-center gap-1 rounded-full bg-orange-100 px-2 py-0.5 text-[11px] font-bold text-orange-700">
                      <Sparkles className="w-3 h-3" /> Upgrade +{x.upgrade_bonus_days}j bonus
                    </span>
                  )}
                  {/* Radio indicator */}
                  <div className={cn(
                    "absolute top-4 right-4 w-5 h-5 rounded-full border-2 flex items-center justify-center transition-colors",
                    active ? "border-blue-500 bg-blue-500" : "border-slate-300"
                  )}>
                    {active && <div className="w-2 h-2 rounded-full bg-white" />}
                  </div>
                </button>
              );
            })}
          </div>
        </section>
      )}

      {/* Price summary + pay */}
      {!success && current && (
        <section className="rounded-2xl border border-slate-200 bg-white p-5 space-y-4">
          <h2 className="text-base font-bold text-slate-900">Récapitulatif</h2>
          <div className="space-y-2">
            <div className="flex justify-between text-sm text-slate-600">
              <span>Prix de base</span>
              <span>{current.base_price.toLocaleString("fr-FR")} XOF</span>
            </div>
            <div className="flex justify-between text-sm text-slate-600">
              <span>Frais</span>
              <span>{current.fees.toLocaleString("fr-FR")} XOF</span>
            </div>
            <div className="h-px bg-slate-100" />
            <div className="flex justify-between text-base font-extrabold text-slate-900">
              <span>Total</span>
              <span>{current.total_price.toLocaleString("fr-FR")} XOF</span>
            </div>
          </div>

          <button
            type="button"
            onClick={pay}
            disabled={busy}
            className="btn-primary w-full justify-center disabled:opacity-60 disabled:pointer-events-none"
          >
            {busy ? (
              <><Loader2 className="w-4 h-4 animate-spin" /> Traitement en cours&hellip;</>
            ) : (
              current.total_price > 0
                ? <><Ticket className="w-4 h-4" /> Payer {current.total_price.toLocaleString("fr-FR")} XOF</>
                : <><Ticket className="w-4 h-4" /> Activer gratuitement</>
            )}
          </button>

          {isError && (
            <div className="flex items-start gap-2.5 rounded-xl bg-red-50 border border-red-100 p-3">
              <AlertCircle className="w-4 h-4 text-red-500 mt-0.5 shrink-0" />
              <p className="text-sm text-red-700">{message}</p>
            </div>
          )}

          <div className="flex items-center justify-center gap-3 text-[11px] text-slate-400">
            <span className="flex items-center gap-1"><ShieldCheck className="w-3 h-3 text-emerald-500" /> Sécurisé</span>
            <span className="w-0.5 h-0.5 bg-slate-300 rounded-full" />
            <span>Confirmation instantanée</span>
          </div>
        </section>
      )}

      {/* Success + code */}
      {success && code && (
        <section className="rounded-2xl border border-slate-200 bg-white p-5 space-y-5">
          <div className="text-center space-y-2">
            <div className="mx-auto w-14 h-14 rounded-full bg-emerald-50 flex items-center justify-center">
              <CheckCircle2 className="w-7 h-7 text-emerald-500" />
            </div>
            <p className="text-lg font-bold text-slate-900">Paiement confirmé</p>
            <p className="text-sm text-slate-500">{message}</p>
          </div>

          <div className="rounded-xl border border-slate-100 bg-slate-50 p-4 space-y-3">
            <p className="text-xs font-bold text-slate-500 uppercase tracking-wider flex items-center gap-1.5">
              <Ticket className="w-3.5 h-3.5" /> Code d&apos;activation
            </p>
            <div className="flex items-center gap-2">
              <code className="flex-1 rounded-lg bg-white border border-slate-200 px-3 py-2.5 text-base font-mono font-bold text-slate-900 select-all text-center tracking-wider">
                {code}
              </code>
              <button type="button" onClick={copyCode} className="shrink-0 rounded-lg border border-slate-200 bg-white p-2.5 text-slate-500 transition hover:bg-slate-100 active:scale-95" aria-label="Copier">
                {copied ? <CheckCircle2 className="w-4 h-4 text-emerald-500" /> : <Copy className="w-4 h-4" />}
              </button>
            </div>
            <a href={`/api/tickets/code-pdf?code=${code}`} className="inline-flex items-center gap-1.5 text-sm font-medium text-blue-600 hover:text-blue-700 transition-colors">
              <Download className="w-3.5 h-3.5" /> Télécharger le PDF
            </a>
          </div>
        </section>
      )}

      {/* Return */}
      <a href={appReturnUrl} className="btn-secondary w-full justify-center">
        Retourner dans l&apos;application <ArrowRight className="w-4 h-4" />
      </a>
    </div>
  );
};
