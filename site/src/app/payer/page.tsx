import { redirect } from "next/navigation";
import { ShieldCheck, Zap } from "lucide-react";
import { PaymentRunner } from "@/components/payment-runner";
import { env } from "@/lib/env";
import { getViewerContext } from "@/lib/data/profile";
import { normalizeAppReturnUrl } from "@/lib/app-return";

type Params = { kind?: string; id?: string; next?: string; idempotencyKey?: string };
type Props = { searchParams: Promise<Params> };

const normalizeKind = (value?: string) => {
  if (value === "event" || value === "contest" || value === "ticket") return value;
  return null;
};

const kindLabel: Record<string, string> = {
  event: "Événement",
  contest: "Concours",
  ticket: "Code d'activation",
};

export default async function PayerPage({ searchParams }: Props) {
  const params = await searchParams;
  const kind = normalizeKind(params.kind);
  const id = params.id;
  const appReturnUrl = normalizeAppReturnUrl(params.next, env.appDeepLink);
  if (kind === "ticket" && !id) redirect(`/tickets/checkout?next=${encodeURIComponent(appReturnUrl)}`);
  if (!kind || !id) redirect("/dashboard");
  const viewer = await getViewerContext();
  if (!viewer.user) {
    if (kind === "event") redirect(`/evenements/acheter?eventId=${id}&next=${encodeURIComponent(appReturnUrl)}`);
    const returnPath = encodeURIComponent(`/payer?kind=${kind}&id=${id}&next=${encodeURIComponent(appReturnUrl)}`);
    redirect(`/login?error=session_required&next=${returnPath}`);
  }

  return (
    <main className="mx-auto max-w-lg px-4 py-10 space-y-5">
      {/* Hero compact */}
      <section className="text-center space-y-2">
        <div className="mx-auto w-12 h-12 rounded-2xl bg-gradient-to-br from-blue-600 to-blue-700 flex items-center justify-center text-white shadow-lg shadow-blue-600/25">
          <Zap className="w-6 h-6" />
        </div>
        <h1 className="text-2xl sm:text-3xl font-extrabold tracking-tight">
          Finaliser mon {kindLabel[kind] ?? "achat"}
        </h1>
        <p className="text-sm text-slate-500 max-w-xs mx-auto">
          Confirmez votre paiement en un clic. Vous serez redirigé automatiquement vers l&apos;application.
        </p>
      </section>

      {/* Trust strip */}
      <div className="flex items-center justify-center gap-4 text-xs text-slate-400">
        <span className="flex items-center gap-1"><ShieldCheck className="w-3.5 h-3.5 text-emerald-500" /> Paiement sécurisé</span>
        <span className="w-1 h-1 bg-slate-200 rounded-full" />
        <span>Confirmation instantanée</span>
        <span className="w-1 h-1 bg-slate-200 rounded-full" />
        <span>Retour automatique</span>
      </div>

      {/* Payment runner */}
      <PaymentRunner
        kind={kind}
        id={id}
        appReturnUrl={appReturnUrl}
        initialIdempotencyKey={params.idempotencyKey}
      />
    </main>
  );
}
