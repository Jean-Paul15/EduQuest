"use client";

import Link from "next/link";
import { Card } from "@/components/ui/card";

type Action = { label: string; href: string };
type Props = {
  title: string;
  subtitle: string;
  badges?: string[];
  actions?: Action[];
};

export const BackofficePageHero = ({ title, subtitle, badges = [], actions = [] }: Props) => (
  <Card className="overflow-hidden border-slate-200/70 bg-white/85 p-0 shadow-sm backdrop-blur">
    <div className="bg-[radial-gradient(circle_at_0%_0%,rgba(59,130,246,.18),transparent_45%),radial-gradient(circle_at_100%_0%,rgba(249,115,22,.15),transparent_45%)] p-5">
      <p className="text-[11px] font-semibold uppercase tracking-[0.18em] text-slate-500">Backoffice EduQuest</p>
      <h1 className="mt-1 text-2xl font-semibold text-slate-900">{title}</h1>
      <p className="mt-1 text-sm text-slate-600">{subtitle}</p>
      {badges.length ? (
        <div className="mt-3 flex flex-wrap gap-2">
          {badges.map((x) => (
            <span key={x} className="rounded-full border border-slate-200 bg-white/80 px-3 py-1 text-xs font-medium text-slate-700">
              {x}
            </span>
          ))}
        </div>
      ) : null}
      {actions.length ? (
        <div className="mt-3 flex flex-wrap gap-2">
          {actions.map((x) => (
            <Link key={x.label} href={x.href} className="rounded-full bg-gradient-to-r from-orange-500 to-blue-500 px-3 py-1.5 text-xs font-semibold text-white shadow-sm transition hover:brightness-110">
              {x.label}
            </Link>
          ))}
        </div>
      ) : null}
    </div>
  </Card>
);
