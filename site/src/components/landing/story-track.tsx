"use client";

import Image from "next/image";
import { motion } from "framer-motion";
import { Lightbulb, Target, Rocket, Award } from "lucide-react";

const acts = [
  {
    icon: <Lightbulb className="w-5 h-5 text-orange-500" />,
    label: "Acte 1",
    title: "Le déclic",
    body: "L’élève veut réussir mais ne sait pas par où commencer. EduQuest transforme ce flou en étapes claires et motivantes.",
    media: "/media/vitrine/hero-classroom.png",
  },
  {
    icon: <Target className="w-5 h-5 text-blue-500" />,
    label: "Acte 2",
    title: "Le plan",
    body: "Cours, exercices, quiz, examens blancs : tout est structuré pour avancer vite, sans se disperser.",
    media: "/media/vitrine/product-demo.mp4",
    isVideo: true,
  },
  {
    icon: <Rocket className="w-5 h-5 text-emerald-500" />,
    label: "Acte 3",
    title: "L’action",
    body: "L’élève active son accès, entre dans le rythme, suit les rappels et progresse chapitre après chapitre.",
    media: "/media/vitrine/contest-event.png",
  },
  {
    icon: <Award className="w-5 h-5 text-amber-500" />,
    label: "Acte 4",
    title: "Le résultat",
    body: "Plus de constance, plus de confiance, de meilleures notes. EduQuest vend un résultat, pas juste du contenu.",
    media: "/media/vitrine/offline-study.png",
  },
];

export const StoryTrack = () => (
  <section className="section-pad bg-slate-50 overflow-hidden">
    <div className="container-tight px-5">
      <motion.div initial={{ opacity: 0, y: 30 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true, margin: "-80px" }} transition={{ duration: 0.6 }} className="text-center max-w-2xl mx-auto mb-12 space-y-3">
        <span className="kicker bg-orange-50 text-orange-600">Le parcours</span>
        <h2 className="heading-section text-balance">Du premier jour à la réussite.</h2>
      </motion.div>

      <div className="grid gap-5 sm:grid-cols-2">
        {acts.map((a, i) => (
          <motion.article key={i} initial={{ opacity: 0, y: 40 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true, margin: "-40px" }} transition={{ duration: 0.6, delay: i * 0.08 }} className="group rounded-2xl border border-slate-200 bg-white overflow-hidden transition-shadow hover:shadow-lg">
            <div className="aspect-[2/1] relative overflow-hidden bg-slate-100">
              {a.isVideo ? (
                <video className="w-full h-full object-cover" autoPlay loop muted playsInline><source src={a.media} type="video/mp4" /></video>
              ) : (
                <Image src={a.media} alt={a.title} fill className="object-cover transition-transform duration-500 group-hover:scale-[1.03]" />
              )}
            </div>
            <div className="p-5">
              <div className="flex items-center gap-2 mb-2">
                {a.icon}
                <span className="text-xs font-bold text-slate-400 uppercase tracking-wider">{a.label}</span>
              </div>
              <h3 className="text-lg font-bold text-slate-900 mb-1.5">{a.title}</h3>
              <p className="text-sm text-slate-500 leading-relaxed">{a.body}</p>
            </div>
          </motion.article>
        ))}
      </div>
    </div>
  </section>
);
