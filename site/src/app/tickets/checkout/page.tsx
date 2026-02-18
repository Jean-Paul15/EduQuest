import { redirect } from "next/navigation";
import { Ticket, ShieldCheck, HelpCircle } from "lucide-react";
import { env } from "@/lib/env";
import { getViewerContext } from "@/lib/data/profile";
import { listTicketCheckoutOptions } from "@/lib/data/tickets";
import { TicketCheckoutFlow } from "@/components/ticket-checkout-flow";

type Props = { searchParams: Promise<{ next?: string }> };

export default async function TicketCheckoutPage({ searchParams }: Props) {
  const viewer = await getViewerContext();
  const params = await searchParams;
  const appReturnUrl = (params.next || "").startsWith("eduquest://") ? String(params.next) : env.appDeepLink;
  if (!viewer.user) redirect("/login?error=session_required&next=/tickets/checkout");
  const options = await listTicketCheckoutOptions();

  if (!options.length) {
    return (
      <main className="mx-auto max-w-lg px-4 py-10">
        <section className="rounded-2xl border border-slate-200 bg-white p-6 text-center space-y-3">
          <div className="mx-auto w-12 h-12 rounded-2xl bg-slate-100 flex items-center justify-center text-slate-400">
            <Ticket className="w-6 h-6" />
          </div>
          <h1 className="text-xl font-extrabold tracking-tight">Aucune offre disponible</h1>
          <p className="text-sm text-slate-500">Contactez le support pour activer des offres adapt\u00e9es \u00e0 votre profil.</p>
          <a href="/support" className="btn-secondary inline-flex !text-sm">
            <HelpCircle className="w-4 h-4" /> Contacter le support
          </a>
        </section>
      </main>
    );
  }

  return (
    <main className="mx-auto max-w-lg px-4 py-10 space-y-5">
      {/* Hero */}
      <section className="text-center space-y-2">
        <div className="mx-auto w-12 h-12 rounded-2xl bg-gradient-to-br from-blue-600 to-blue-700 flex items-center justify-center text-white shadow-lg shadow-blue-600/25">
          <Ticket className="w-6 h-6" />
        </div>
        <h1 className="text-2xl sm:text-3xl font-extrabold tracking-tight">
          Activer mon acc\u00e8s EduQuest
        </h1>
        <p className="text-sm text-slate-500 max-w-xs mx-auto">
          Choisissez votre formule, payez en un clic, r\u00e9cup\u00e9rez votre code.
        </p>
      </section>

      {/* Trust */}
      <div className="flex items-center justify-center gap-4 text-xs text-slate-400">
        <span className="flex items-center gap-1"><ShieldCheck className="w-3.5 h-3.5 text-emerald-500" /> Paiement s\u00e9curis\u00e9</span>
        <span className="w-1 h-1 bg-slate-200 rounded-full" />
        <span>Code instantan\u00e9</span>
        <span className="w-1 h-1 bg-slate-200 rounded-full" />
        <span>Retour automatique</span>
      </div>

      <TicketCheckoutFlow options={options} appReturnUrl={appReturnUrl} />
    </main>
  );
}
