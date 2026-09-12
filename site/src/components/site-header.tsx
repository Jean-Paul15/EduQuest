"use client";

import Link from "next/link";
import Image from "next/image";
import { useState } from "react";
import { Menu, X } from "lucide-react";

type Props = { email?: string | null };

const publicLinks = [
  ["/evenements", "Événements"],
  ["/concours", "Concours"],
  ["/support", "Support"],
] as const;

export const SiteHeader = ({ email }: Props) => {
  const [open, setOpen] = useState(false);
  const memberLinks = email
    ? ([["/dashboard", "Mon espace"], ["/tickets/checkout", "Activer un code"]] as const)
    : ([] as const);
  const links = [...memberLinks, ...publicLinks];

  return (
    <header className="sticky top-0 z-50 border-b border-slate-200/60 bg-white/80 backdrop-blur-xl">
      <div className="mx-auto flex max-w-6xl items-center justify-between px-4 py-3">
        <Link href="/" className="flex items-center gap-2 text-xl font-black tracking-tight text-[var(--eq-blue)]">
          <Image src="/ruachedu-logo.svg" alt="RuachEdu" width={32} height={32} priority />
          RuachEdu
        </Link>

        {/* Desktop nav */}
        <nav className="hidden items-center gap-1 md:flex">
          {links.map(([href, label]) => (
            <Link key={href} href={href} className="rounded-lg px-3 py-1.5 text-sm font-medium text-slate-600 transition hover:bg-slate-100 hover:text-slate-900">
              {label}
            </Link>
          ))}
          {email ? (
            <a href="/auth/signout" className="ml-2 rounded-full bg-slate-900 px-4 py-1.5 text-sm font-semibold text-white transition hover:bg-slate-800">
              Déconnexion
            </a>
          ) : (
            <Link href="/login" className="ml-2 btn-primary !py-2 !px-5 !text-sm">
              Connexion
            </Link>
          )}
        </nav>

        {/* Mobile hamburger */}
        <button type="button" onClick={() => setOpen(!open)} className="rounded-lg p-2 text-slate-700 md:hidden hover:bg-slate-100" aria-label="Menu">
          {open ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
        </button>
      </div>

      {/* Mobile drawer */}
      {open && (
        <nav className="border-t border-slate-100 bg-white px-4 pb-4 pt-2 md:hidden">
          <div className="flex flex-col gap-1">
            {links.map(([href, label]) => (
              <Link key={href} href={href} onClick={() => setOpen(false)} className="rounded-lg px-3 py-2.5 text-sm font-medium text-slate-700 hover:bg-slate-50">
                {label}
              </Link>
            ))}
            {email ? (
              <a href="/auth/signout" className="mt-2 rounded-xl bg-slate-900 py-2.5 text-center text-sm font-semibold text-white">
                Déconnexion
              </a>
            ) : (
              <Link href="/login" className="mt-2 btn-primary justify-center !text-sm">
                Connexion
              </Link>
            )}
          </div>
        </nav>
      )}
    </header>
  );
};
