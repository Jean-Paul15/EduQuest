import Link from "next/link";
import type { TicketProduct } from "@/lib/data/tickets";
import { env } from "@/lib/env";

type Props = { products: TicketProduct[]; loggedIn: boolean };

export const TicketConversion = ({ products, loggedIn }: Props) => {
  return (
    <section className="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
      <p className="text-xs uppercase tracking-wide text-orange-500">Codes ’ctivation</p>
      <h3 className="text-2xl font-semibold text-slate-900">Choisis ton accès, commence à progresser aujour’ui</h3>
      <p className="mt-1 text-sm text-slate-600">
        Après paiement, ton code est créé instantanément, copiable et téléchargeable en PDF. Aucun parcours compliqué.
      </p>
      <div className="mt-4 rounded-2xl border border-orange-200 bg-orange-50 p-4 text-sm text-slate-700">
        Plus ’lève commence tôt, plus il accumule des sessions utiles avant ’xamen.
      </div>
      <div className="mt-4 grid gap-3 md:grid-cols-3">
        {products.slice(0, 3).map((item) => (
          <article key={item.id} className="rounded-xl border border-slate-200 p-4">
            <h4 className="font-semibold text-slate-900">{item.code}</h4>
            <p className="text-sm text-slate-600">{item.ticket_type} • {item.duration_days} jours ’ccès</p>
            <div className="mt-3 flex gap-2">
              {loggedIn ? (
                <Link href="/tickets/checkout" className="rounded bg-blue-600 px-3 py-1.5 text-sm text-white hover:bg-blue-500">
                  Acheter
                </Link>
              ) : (
                <a href={env.appDeepLink} className="rounded bg-blue-600 px-3 py-1.5 text-sm text-white hover:bg-blue-500">
                  Acheter via ’pp
                </a>
              )}
              <Link href="/support" className="rounded border border-slate-300 px-3 py-1.5 text-sm text-slate-700 hover:bg-slate-50">
                Besoin ’ide
              </Link>
            </div>
          </article>
        ))}
      </div>
    </section>
  );
};
