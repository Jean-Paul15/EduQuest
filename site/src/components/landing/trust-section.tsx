"use client";

import { motion } from "framer-motion";
import { GraduationCap, ShieldCheck, Users } from "lucide-react";

const pillars = [
  { icon: <GraduationCap className="w-6 h-6" />, title: "Programme complet", body: "Du CM2 à la Terminale, tous les chapitres au programme officiel togolais et sous-régional." },
  { icon: <ShieldCheck className="w-6 h-6" />, title: "Sécurisé et fiable", body: "Données protégées, paiements sûrs, accès garanti même sans connexion internet." },
  { icon: <Users className="w-6 h-6" />, title: "Communauté active", body: "Des milliers d\u2019élèves connectés, des enseignants impliqués, un vrai réseau d\u2019entraide." },
];

const schools = ["Lycée de Tokoin", "Collège St-Joseph", "Cours Lumière", "Notre-Dame des Apôtres"];

export const TrustSection = () => (
  <section className="section-pad bg-slate-50 overflow-hidden">
    <div className="container-tight px-5 space-y-16">
      {/* Citation */}
      <motion.blockquote initial={{ opacity: 0, scale: 0.96 }} whileInView={{ opacity: 1, scale: 1 }} viewport={{ once: true, margin: "-80px" }} transition={{ duration: 0.7 }} className="relative mx-auto max-w-2xl text-center">
        <div className="absolute -top-4 left-1/2 -translate-x-1/2 text-orange-200/30 pointer-events-none select-none">
          <svg className="w-16 h-16 sm:w-24 sm:h-24" fill="currentColor" viewBox="0 0 32 32"><path d="M9.352 4C4.456 7.456 1 13.12 1 19.36c0 5.088 3.072 8.064 6.624 8.064 3.36 0 5.856-2.688 5.856-5.856 0-3.168-2.208-5.472-5.088-5.472-.576 0-1.344.096-1.536.192.48-3.264 3.552-7.104 6.624-9.024L9.352 4zm16.512 0c-4.8 3.456-8.256 9.12-8.256 15.36 0 5.088 3.072 8.064 6.624 8.064 3.264 0 5.856-2.688 5.856-5.856 0-3.168-2.304-5.472-5.184-5.472-.576 0-1.248.096-1.44.192.48-3.264 3.456-7.104 6.528-9.024L25.864 4z" /></svg>
        </div>
        <p className="relative z-10 pt-10 text-xl sm:text-2xl md:text-3xl font-bold text-slate-800 leading-snug tracking-tight italic">
          {"\u00AB\u00A0"}La réussite, c&apos;est d&apos;abord et surtout d&apos;être au travail quand les autres vont à la pêche.{"\u00A0\u00BB"}
        </p>
        <footer className="mt-5 flex items-center justify-center gap-3">
          <div className="w-8 h-[2px] bg-orange-500 rounded-full" />
          <span className="text-sm font-bold text-slate-900">Guy Bertrand</span>
        </footer>
      </motion.blockquote>

      <div className="w-16 h-px bg-slate-200 mx-auto" />

      {/* Pillars */}
      <motion.div initial={{ opacity: 0, y: 35 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true, margin: "-80px" }} transition={{ duration: 0.6 }} className="grid gap-5 sm:grid-cols-3">
        {pillars.map((p) => (
          <div key={p.title} className="group rounded-2xl bg-white border border-slate-100 p-6 transition-all duration-300 hover:shadow-lg hover:-translate-y-1">
            <div className="w-11 h-11 rounded-xl bg-blue-50 flex items-center justify-center text-blue-600 mb-3 group-hover:bg-orange-50 group-hover:text-orange-600 transition-colors">{p.icon}</div>
            <h4 className="text-base font-bold text-slate-900 mb-1.5">{p.title}</h4>
            <p className="text-sm text-slate-500 leading-relaxed">{p.body}</p>
          </div>
        ))}
      </motion.div>

      {/* Partners */}
      <motion.div initial={{ opacity: 0 }} whileInView={{ opacity: 1 }} viewport={{ once: true }} transition={{ delay: 0.2, duration: 0.5 }} className="text-center space-y-4">
        <p className="text-xs font-bold text-slate-400 uppercase tracking-[0.2em]">Ils recommandent EduQuest</p>
        <div className="flex flex-wrap justify-center gap-x-8 gap-y-2">
          {schools.map((n) => (
            <span key={n} className="text-base sm:text-lg font-extrabold text-slate-200 hover:text-slate-400 transition-colors cursor-default">{n}</span>
          ))}
        </div>
      </motion.div>
    </div>
  </section>
);
