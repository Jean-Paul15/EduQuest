"use client";

import { motion } from "framer-motion";

export const ScrollStory = () => (
  <section className="section-pad bg-[var(--eq-blue-deep)] overflow-hidden relative">
    <div className="absolute inset-0 pointer-events-none">
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[400px] bg-blue-700/10 blur-[120px] rounded-full" />
    </div>

    <div className="container-tight px-5 relative z-10">
      <motion.div initial={{ opacity: 0, y: 30 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true, margin: "-80px" }} transition={{ duration: 0.6 }} className="text-center max-w-2xl mx-auto mb-10 space-y-3">
        <span className="kicker bg-white/5 text-orange-300 border border-white/10">Démo produit</span>
        <h2 className="heading-section text-white text-balance">Voyez EduQuest en action.</h2>
        <p className="text-slate-400 text-base leading-relaxed">
          Interface fluide, contenu structuré, progression visible. En quelques secondes, comprenez pourquoi des milliers d&apos;élèves nous font confiance.
        </p>
      </motion.div>

      <motion.div initial={{ opacity: 0, y: 40 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true, margin: "-60px" }} transition={{ duration: 0.7, delay: 0.1 }} className="mx-auto max-w-4xl">
        <div className="rounded-2xl overflow-hidden border border-white/10 shadow-2xl shadow-black/30 aspect-video bg-slate-900">
          <video className="w-full h-full object-cover" autoPlay loop muted playsInline poster="/media/vitrine/hero-classroom.png">
            <source src="/media/vitrine/product-demo.mp4" type="video/mp4" />
          </video>
        </div>
      </motion.div>
    </div>
  </section>
);
