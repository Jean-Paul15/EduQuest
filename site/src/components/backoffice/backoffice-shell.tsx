"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useMemo, useState } from "react";
import { Bell, BookOpen, Calendar, ChevronDown, LayoutDashboard, LifeBuoy, Scale, Shield } from "lucide-react";
import { cn } from "@/lib/utils";

type Section = { id: string; label: string; path: string; icon: string | null };

const icons = {
  "layout-dashboard": LayoutDashboard,
  shield: Shield,
  "book-open": BookOpen,
  calendar: Calendar,
  "life-buoy": LifeBuoy,
  bell: Bell,
  scale: Scale,
} as const;

const subNav: Record<string, Array<{ label: string; hash: string }>> = {
  "/backoffice/dashboard": [
    { label: "Vue globale", hash: "overview" },
    { label: "Alertes", hash: "alerts" },
    { label: "Vérification app", hash: "health" },
    { label: "Activité", hash: "activity" },
    { label: "Comportement élèves", hash: "kpi" },
  ],
  "/backoffice/content": [
    { label: "Catalogue", hash: "catalog" },
    { label: "Tickets", hash: "ticketing" },
    { label: "Lives & Sondages", hash: "live" },
    { label: "Actions auto", hash: "automation" },
    { label: "Paramètres app", hash: "app-config" },
    { label: "Outils avancés", hash: "json-studio" },
  ],
  "/backoffice/events": [
    { label: "Pilotage", hash: "events-core" },
    { label: "Tarifs", hash: "pricing" },
    { label: "Localisation", hash: "location" },
    { label: "Outils avancés", hash: "events-json" },
  ],
  "/backoffice/support": [
    { label: "Demandes", hash: "support-requests" },
    { label: "Modération", hash: "support-moderation" },
    { label: "Historique", hash: "support-audit" },
  ],
  "/backoffice/notifications": [
    { label: "Campagnes", hash: "notif-campaigns" },
    { label: "Messages utilisateurs", hash: "notif-users" },
    { label: "Historique", hash: "notif-logs" },
  ],
  "/backoffice/rbac": [
    { label: "Profils", hash: "rbac-roles" },
    { label: "Droits", hash: "rbac-perms" },
    { label: "Menus", hash: "rbac-sections" },
    { label: "Utilisateurs", hash: "rbac-assign" },
  ],
};

export const BackofficeShell = ({
  sections,
  children,
  email,
}: {
  sections: Section[];
  children: React.ReactNode;
  email?: string;
}) => {
  const pathname = usePathname();
  const [query, setQuery] = useState("");
  const filtered = useMemo(
    () =>
      sections.filter((s) =>
        `${s.label} ${(subNav[s.path] || []).map((x) => x.label).join(" ")}`
          .toLowerCase()
          .includes(query.toLowerCase()),
      ),
    [sections, query],
  );
  return (
    <div className="relative grid min-h-[calc(100vh-60px)] grid-cols-1 md:grid-cols-[280px_1fr]">
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_10%_0%,rgba(59,130,246,.18),transparent_35%),radial-gradient(circle_at_85%_0%,rgba(249,115,22,.14),transparent_32%)]" />
      <aside className="relative border-r border-slate-200/70 bg-white/80 p-4 backdrop-blur-xl md:sticky md:top-[60px] md:h-[calc(100vh-60px)] md:overflow-y-auto">
        <div className="mb-4 rounded-2xl border border-slate-200/70 bg-gradient-to-r from-blue-50 to-orange-50 p-3">
          <p className="text-xs uppercase tracking-wide text-orange-600">Backoffice</p>
          <p className="truncate text-sm font-medium text-slate-700">{email || ""}</p>
        </div>
        <input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Rechercher une page..."
          className="mb-3 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm outline-none focus:border-blue-400"
        />
        <nav className="space-y-1">
          {filtered.map((s) => {
            const Icon = icons[(s.icon || "") as keyof typeof icons] || LayoutDashboard;
            const open = pathname === s.path;
            return (
              <details key={s.id} open={open} className="group rounded-lg">
                <summary className={cn("flex cursor-pointer list-none items-center justify-between rounded-xl px-3 py-2 text-sm", open ? "bg-gradient-to-r from-orange-500 to-blue-500 text-white shadow-md" : "text-slate-700 hover:bg-orange-50")}>
                  <span className="flex items-center gap-2"><Icon size={16} /> {s.label}</span>
                  <ChevronDown size={15} className={cn("transition group-open:rotate-180", open ? "text-white" : "text-slate-400")} />
                </summary>
                <div className="mt-1 ml-3 space-y-1 border-l border-slate-200 pl-3">
                  <Link href={s.path} className="block rounded-lg px-2 py-1 text-xs text-slate-600 hover:bg-slate-100">Ouvrir</Link>
                  {(subNav[s.path] || []).map((n) => (
                    <Link key={n.hash} href={`${s.path}#${n.hash}`} className="block rounded-lg px-2 py-1 text-xs text-slate-600 hover:bg-slate-100">
                      {n.label}
                    </Link>
                  ))}
                </div>
              </details>
            );
          })}
          {!filtered.length ? <p className="rounded-xl border border-dashed border-slate-200 p-3 text-xs text-slate-500">Aucun module pour cette recherche.</p> : null}
        </nav>
      </aside>
      <main className="eq-backoffice relative bg-transparent p-4 md:p-6">{children}</main>
    </div>
  );
};
