"use client";

import { motion, useReducedMotion } from "framer-motion";
import { Spinner } from "@/components/ui/loading/spinner";

type Props = { progress: number };

const dots = Array.from({ length: 8 }, (_, i) => i);
const particles = Array.from({ length: 14 }, (_, i) => i);

export const RouteChangeLoader = ({ progress }: Props) => {
  const reduce = useReducedMotion();
  return (
    <motion.div
      role="status"
      aria-live="polite"
      aria-label="Chargement de la page en cours"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      transition={{ duration: reduce ? 0.01 : 0.18 }}
      className="fixed inset-0 z-[9999] overflow-hidden"
    >
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_18%_20%,var(--loading-glow-start),transparent_42%),radial-gradient(circle_at_80%_18%,var(--loading-glow-end),transparent_45%),linear-gradient(135deg,#0b1220_0%,#121a2e_100%)]" />
      {particles.map((i) => (
        <span
          key={i}
          className="eq-loading-gradient absolute rounded-full opacity-60"
          style={{ width: 6 + (i % 4) * 3, height: 6 + (i % 4) * 3, left: `${(i * 17) % 100}%`, top: `${(i * 29) % 100}%` }}
        />
      ))}
      <div className="absolute inset-0 grid place-items-center px-6">
        <div className="w-full max-w-sm rounded-3xl border border-white/15 bg-slate-950/55 p-6 backdrop-blur-xl">
          <div className="mx-auto flex w-fit items-center gap-4">
            <Spinner variant="logo" />
            <div>
              <p className="text-xs uppercase tracking-[0.2em] text-white/70">EduQuest</p>
              <p className="text-base font-bold text-white">Chargement en cours</p>
            </div>
          </div>
          <div className="mt-5 h-2 overflow-hidden rounded-full bg-white/10">
            <div className="eq-loading-gradient relative h-full rounded-full transition-[width] duration-300" style={{ width: `${Math.max(8, Math.min(100, progress))}%` }}>
              <div className="eq-loading-sheen absolute inset-0" />
            </div>
          </div>
          <div className="mt-4 flex justify-center gap-1.5">
            {dots.map((i) => (
              <span
                key={i}
                className="eq-loading-gradient h-1.5 w-1.5 rounded-full"
                style={{ opacity: 0.45 + ((progress + i * 11) % 100) / 200 }}
              />
            ))}
          </div>
        </div>
      </div>
    </motion.div>
  );
};

