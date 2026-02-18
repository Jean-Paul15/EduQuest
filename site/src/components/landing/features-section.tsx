"use client";

import Image from "next/image";
import { motion } from "framer-motion";
import { AlertTriangle, ListChecks, WifiOff, Trophy } from "lucide-react";
import { cn } from "@/lib/utils";

const chapters = [
  {
    kicker: "Le constat",
    icon: <AlertTriangle className="w-5 h-5" />,
    color: "text-red-500",
    title: "80 % des élèves révisent sans méthode. Le résultat est prévisible.",
    body: "Pas de programme clair, pas de correction, pas de suivi. Les familles investissent dans l\u2019éducation mais les outils manquent cruellement.",
    media: "/media/vitrine/hero-classroom.png",
  },
  {
    kicker: "La méthode",
    icon: <ListChecks className="w-5 h-5" />,
    color: "text-orange-500",
    title: "Un plan de travail structuré, jour après jour.",
    body: "Cours organisés par matière et chapitre, exercices progressifs, corrections détaillées et examens blancs chronométrés. Tout ce qu\u2019il faut pour progresser.",
    media: "/media/vitrine/product-demo.mp4",
    isVideo: true,
  },
  {
    kicker: "L\u2019avantage terrain",
    icon: <WifiOff className="w-5 h-5" />,
    color: "text-emerald-500",
    title: "Fonctionne sans internet. Partout. Tout le temps.",
    body: "Téléchargez vos chapitres une fois, révisez hors ligne autant que vous voulez. Conçu pour la réalité du terrain en Afrique de l\u2019Ouest.",
    media: "/media/vitrine/offline-study.png",
  },
  {
    kicker: "Le boost",
    icon: <Trophy className="w-5 h-5" />,
    color: "text-blue-500",
    title: "Des concours pour se dépasser. Des prix pour se motiver.",
    body: "Concours hebdomadaires, classements en direct, récompenses réelles. L\u2019émulation entre élèves crée une dynamique de progrès impossible à reproduire seul.",
    media: "/media/vitrine/contest-event.png",
  },
];

const reveal = {
  hidden: { opacity: 0, y: 50 },
  show: { opacity: 1, y: 0, transition: { duration: 0.7, ease: [0.22, 1, 0.36, 1] as const } },
};

export const FeaturesSection = () => (
  <section id="methode" className="section-pad bg-white overflow-hidden">
    <div className="container-tight px-5 space-y-16 sm:space-y-24">
      <motion.div initial={{ opacity: 0, y: 35 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true, margin: "-80px" }} transition={{ duration: 0.6 }} className="text-center max-w-2xl mx-auto space-y-3">
        <span className="kicker bg-blue-50 text-blue-700">Pourquoi EduQuest</span>
        <h2 className="heading-section text-balance">Un écosystème complet pour réussir ses examens.</h2>
        <p className="text-body max-w-lg mx-auto">De la préparation au jour J, chaque fonctionnalité maximise les chances de succès.</p>
      </motion.div>

      <div className="space-y-14 sm:space-y-20">
        {chapters.map((c, i) => (
          <motion.div key={i} variants={reveal} initial="hidden" whileInView="show" viewport={{ once: true, margin: "-60px" }} className={cn("grid gap-6 lg:gap-12 items-center lg:grid-cols-2", i % 2 !== 0 && "lg:[direction:rtl] lg:*:[direction:ltr]")}>
            <div className="space-y-4">
              <div className={cn("kicker bg-current/10", c.color)}>
                {c.icon}
                <span className="text-slate-700">{c.kicker}</span>
              </div>
              <h3 className="text-xl sm:text-2xl md:text-3xl font-bold text-slate-900 leading-snug tracking-tight">{c.title}</h3>
              <p className="text-body">{c.body}</p>
            </div>
            <div className="rounded-2xl overflow-hidden bg-slate-100 aspect-[4/3] relative">
              {c.isVideo ? (
                <video className="w-full h-full object-cover" autoPlay loop muted playsInline><source src={c.media} type="video/mp4" /></video>
              ) : (
                <Image src={c.media} alt={c.title} fill className="object-cover" />
              )}
            </div>
          </motion.div>
        ))}
      </div>
    </div>
  </section>
);
