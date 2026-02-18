"use client";

import Link from "next/link";
import { Check, Star } from "lucide-react";
import { motion } from "framer-motion";
import type { TicketProduct } from "@/lib/data/tickets";
import { cn } from "@/lib/utils";

type Props = { products: TicketProduct[]; loggedIn: boolean; appDeepLink: string };

const base = ["Tous les cours et exercices", "Corrections détaillées", "Mode hors ligne complet"];
const extra = ["Accès concours et événements", "Support prioritaire"];

export const PricingSection = ({ products, loggedIn, appDeepLink }: Props) => {
  const sorted = [...products].sort((a, b) => a.duration_days - b.duration_days);

  return (
    <section id="pricing" className="section-pad section-dark overflow-hidden relative">
      <div className="absolute top-0 left-1/3 w-[400px] h-[350px] bg-blue-600/15 blur-[150px] rounded-full pointer-events-none animate-glow" />
      <div className="absolute bottom-0 right-1/4 w-[300px] h-[250px] bg-orange-600/10 blur-[120px] rounded-full pointer-events-none" />

      <div className="container-tight px-5 relative z-10">
        <motion.div initial={{ opacity: 0, y: 35 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true, margin: "-80px" }} transition={{ duration: 0.6 }} className="text-center max-w-2xl mx-auto mb-12 space-y-3">
          <span className="kicker bg-orange-500/10 text-orange-400 border border-orange-500/20">Offres</span>
          <h2 className="heading-section text-white text-balance">Investissez dans la réussite de votre enfant.</h2>
          <p className="text-slate-400 text-base leading-relaxed">Un seul achat, un accès complet. Pas d&apos;abonnement caché.</p>
        </motion.div>

        <motion.div initial={{ opacity: 0, y: 40 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true, margin: "-60px" }} transition={{ duration: 0.7, delay: 0.1 }} className="grid gap-5 md:grid-cols-2 lg:grid-cols-3 max-w-5xl mx-auto">
          {sorted.map((p, i) => {
            const pop = i === sorted.length - 1;
            const feats = [...base, ...(pop ? extra : ["Accès aux quiz"])];
            const href = loggedIn ? "/tickets/checkout" : appDeepLink;

            return (
              <div key={p.id} className={cn("relative flex flex-col rounded-2xl p-6 transition-all", pop ? "bg-gradient-to-b from-slate-800 to-slate-900 border-2 border-orange-500/40 shadow-2xl shadow-orange-900/20 lg:-translate-y-3" : "bg-white/[0.03] border border-white/10 hover:bg-white/[0.06]")}>
                {pop && (
                  <span className="absolute -top-3 left-1/2 -translate-x-1/2 inline-flex items-center gap-1 bg-gradient-to-r from-orange-500 to-orange-600 text-white px-3.5 py-1 rounded-full text-xs font-bold shadow-lg uppercase tracking-wider">
                    <Star className="w-3 h-3" fill="currentColor" /> Recommandé
                  </span>
                )}
                <div className="mb-5 space-y-1">
                  <h3 className="text-base font-semibold text-slate-200">{p.code}</h3>
                  <div className="flex items-baseline gap-1">
                    <span className="text-4xl font-black text-white tracking-tight">{p.duration_days}</span>
                    <span className="text-sm text-slate-400 font-medium">jours</span>
                  </div>
                  <p className="text-xs text-slate-500">{p.ticket_type === "FULL" ? "Accès complet" : "Accès essentiel"}</p>
                </div>
                <ul className="flex-1 space-y-2.5 mb-6">
                  {feats.map((f) => (
                    <li key={f} className="flex items-start gap-2 text-sm text-slate-300"><Check className="w-4 h-4 text-orange-400 mt-0.5 shrink-0" />{f}</li>
                  ))}
                </ul>
                {loggedIn ? (
                  <Link href={href} className={cn("w-full py-3 rounded-xl font-bold text-center text-sm transition-all", pop ? "bg-gradient-to-b from-orange-500 to-orange-600 text-white shadow-lg shadow-orange-600/25 hover:brightness-110" : "bg-white/10 text-white hover:bg-white/20")}>Choisir ce plan</Link>
                ) : (
                  <a href={href} className={cn("w-full py-3 rounded-xl font-bold text-center text-sm transition-all", pop ? "bg-gradient-to-b from-orange-500 to-orange-600 text-white shadow-lg shadow-orange-600/25 hover:brightness-110" : "bg-white/10 text-white hover:bg-white/20")}>Obtenir dans l&apos;app</a>
                )}
              </div>
            );
          })}
        </motion.div>

        <motion.p initial={{ opacity: 0 }} whileInView={{ opacity: 1 }} viewport={{ once: true }} transition={{ delay: 0.3 }} className="mt-8 text-center text-sm text-slate-500">
          Partenariats établissements ?{" "}
          <Link href="/support" className="text-orange-400 hover:text-orange-300 underline underline-offset-2 font-medium">Contactez notre équipe.</Link>
        </motion.p>
      </div>
    </section>
  );
};
