"use client";

import Link from "next/link";
import { motion } from "framer-motion";
import { ArrowRight, Download } from "lucide-react";

type Props = { loggedIn: boolean; appDeepLink: string };

const fade = (i: number) => ({
  hidden: { opacity: 0, y: 28 },
  show: { opacity: 1, y: 0, transition: { delay: 0.12 * i, duration: 0.65, ease: [0.22, 1, 0.36, 1] as const } },
});

const stats = [
  { value: "10 000+", label: "Élèves actifs" },
  { value: "95 %", label: "Satisfaction" },
  { value: "24/7", label: "Même hors ligne" },
];

export const HeroSection = ({ loggedIn, appDeepLink }: Props) => (
  <section className="relative flex min-h-[100svh] w-full items-center justify-center overflow-hidden bg-[var(--eq-blue-deep)] text-white">
    {/* Video bg */}
    <div className="absolute inset-0">
      <video className="h-full w-full object-cover opacity-20" autoPlay loop muted playsInline poster="/media/vitrine/hero-classroom.png">
        <source src="/media/vitrine/hero-campus.mp4" type="video/mp4" />
      </video>
      <div className="absolute inset-0 bg-gradient-to-b from-[var(--eq-blue-deep)]/70 via-[var(--eq-blue-deep)]/85 to-[var(--eq-blue-deep)]" />
    </div>

    {/* Glows */}
    <div className="absolute top-1/4 left-1/2 -translate-x-1/2 w-[500px] h-[500px] rounded-full bg-blue-600/20 blur-[140px] pointer-events-none animate-glow" />
    <div className="absolute bottom-1/3 right-0 w-[250px] h-[250px] rounded-full bg-orange-500/15 blur-[100px] pointer-events-none" />

    {/* Content */}
    <div className="container-tight relative z-10 flex flex-col items-center px-5 pt-28 pb-16 text-center">
      <motion.div initial="hidden" animate="show" className="space-y-6 max-w-3xl">
        <motion.div variants={fade(0)} className="flex justify-center">
          <span className="kicker border border-white/10 bg-white/5 text-orange-300 backdrop-blur-sm">
            <span className="relative flex h-2 w-2">
              <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-orange-400 opacity-75" />
              <span className="relative inline-flex h-2 w-2 rounded-full bg-orange-500" />
            </span>
            Plateforme éducative n°1 au Togo
          </span>
        </motion.div>

        <motion.h1 variants={fade(1)} className="heading-hero text-balance">
          Chaque effort mérite{" "}
          <span className="gradient-text">un résultat concret.</span>
        </motion.h1>

        <motion.p variants={fade(2)} className="mx-auto max-w-xl text-base sm:text-lg leading-relaxed text-slate-300">
          Cours structurés, exercices corrigés, concours motivants et coaching intelligent — le tout accessible même sans connexion internet.
        </motion.p>

        <motion.div variants={fade(3)} className="flex flex-col items-center gap-3 pt-1 sm:flex-row sm:justify-center">
          {loggedIn ? (
            <Link href="/tickets/checkout" className="btn-primary w-full sm:w-auto">Activer mon accès <ArrowRight className="h-4 w-4" /></Link>
          ) : (
            <a href={appDeepLink} className="btn-primary w-full sm:w-auto">Télécharger gratuitement <Download className="h-4 w-4" /></a>
          )}
          <Link href="/#methode" className="btn-ghost-light w-full sm:w-auto">Découvrir la méthode</Link>
        </motion.div>

        <motion.div variants={fade(4)} className="pt-8 flex items-center justify-center gap-8 sm:gap-12 flex-wrap">
          {stats.map((s) => (
            <div key={s.label} className="text-center">
              <div className="text-2xl sm:text-3xl font-black">{s.value}</div>
              <div className="text-[11px] text-slate-400 mt-1 uppercase tracking-wider font-medium">{s.label}</div>
            </div>
          ))}
        </motion.div>
      </motion.div>
    </div>

    {/* Scroll hint */}
    <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 2 }} className="absolute bottom-6 left-1/2 -translate-x-1/2 z-10">
      <div className="flex flex-col items-center gap-2">
        <span className="text-[10px] uppercase tracking-[0.2em] text-slate-500">Scroll</span>
        <div className="h-7 w-[1px] bg-gradient-to-b from-slate-500 to-transparent" />
      </div>
    </motion.div>
  </section>
);
