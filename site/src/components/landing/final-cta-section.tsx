"use client";

import Link from "next/link";
import { motion } from "framer-motion";
import { ArrowRight, Download } from "lucide-react";

type Props = { loggedIn: boolean; appDeepLink: string };

export const FinalCTASection = ({ loggedIn, appDeepLink }: Props) => (
  <section className="section-pad bg-white overflow-hidden relative">
    <div className="absolute inset-0 pointer-events-none">
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[500px] h-[500px] bg-gradient-to-br from-blue-100 to-orange-50 rounded-full blur-[100px] opacity-40" />
    </div>

    <div className="container-tight px-5 relative z-10">
      <motion.div initial={{ opacity: 0, y: 35 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true, margin: "-80px" }} transition={{ duration: 0.7 }} className="mx-auto max-w-2xl text-center space-y-6">
        <h2 className="heading-section text-balance">
          Chaque jour compte.{" "}
          <span className="gradient-text">Commencez le vôtre.</span>
        </h2>

        <p className="text-body max-w-lg mx-auto">
          Des milliers d&apos;élèves progressent déjà avec EduQuest. Activez votre code ou participez à un concours — votre prochaine bonne note vous attend.
        </p>

        <div className="flex flex-col sm:flex-row items-center justify-center gap-3">
          {loggedIn ? (
            <Link href="/tickets/checkout" className="btn-primary w-full sm:w-auto">
              Activer mon code maintenant <ArrowRight className="h-4 w-4" />
            </Link>
          ) : (
            <a href={appDeepLink} className="btn-primary w-full sm:w-auto">
              Télécharger l&apos;application <Download className="h-4 w-4" />
            </a>
          )}
          <Link href="/evenements" className="btn-secondary w-full sm:w-auto">Voir les événements</Link>
        </div>

        <div className="flex items-center justify-center gap-5 pt-4 text-sm text-slate-400">
          <Link href="/support" className="hover:text-orange-600 transition-colors underline underline-offset-2">Support &amp; aide</Link>
          <span className="w-1 h-1 bg-slate-300 rounded-full" />
          <Link href="/support" className="hover:text-orange-600 transition-colors underline underline-offset-2">Partenariats écoles</Link>
        </div>
      </motion.div>
    </div>
  </section>
);
