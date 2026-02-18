import Link from "next/link";
import { env } from "@/lib/env";

type Props = { loggedIn: boolean };

export const PaymentStrip = ({ loggedIn }: Props) => {
  return (
    <section className="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
      <div className="grid gap-4 md:grid-cols-3 md:items-stretch">
        <div>
          <p className="text-xs uppercase tracking-wide text-orange-500">Passage à ’chat</p>
          <h3 className="text-xl font-semibold text-slate-900">Un seul parcours: décider, payer, avancer</h3>
          <p className="mt-2 text-sm text-slate-600">Tu peux démarrer en moins de 2 minutes.</p>
        </div>
        {loggedIn ? (
          <Link href="/tickets/checkout" className="rounded-xl border border-blue-200 bg-blue-50 p-4 text-slate-900 hover:border-blue-400">
            <p className="text-sm font-semibold">Acheter un code ’ctivation</p>
            <p className="mt-1 text-xs text-slate-600">Active ’pp et débloque ton parcours.</p>
          </Link>
        ) : (
          <a href={env.appDeepLink} className="rounded-xl border border-blue-200 bg-blue-50 p-4 text-slate-900 hover:border-blue-400">
            <p className="text-sm font-semibold">Acheter un code ’ctivation</p>
            <p className="mt-1 text-xs text-slate-600">Cette action se fait depuis ’pplication.</p>
          </a>
        )}
        <Link href="/evenements" className="rounded-xl border border-orange-200 bg-orange-50 p-4 text-slate-900 hover:border-orange-400">
          <p className="text-sm font-semibold">Réserver un événement</p>
          <p className="mt-1 text-xs text-slate-600">Inscription rapide + reçu immédiat.</p>
        </Link>
        <Link href="/support" className="rounded-xl border border-slate-200 p-4 hover:border-blue-400">
          <p className="text-sm font-semibold">Parler au support</p>
          <p className="mt-1 text-xs text-slate-600">On ’ide à choisir la meilleure option.</p>
        </Link>
      </div>
    </section>
  );
};
