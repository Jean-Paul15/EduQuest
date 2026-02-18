"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { Bell, Calendar, BookOpen, LayoutDashboard, LifeBuoy, Shield } from "lucide-react";
import { cn } from "@/lib/utils";

type Section = { id: string; label: string; path: string; icon: string | null };

const icons = {
  "layout-dashboard": LayoutDashboard,
  shield: Shield,
  "book-open": BookOpen,
  calendar: Calendar,
  "life-buoy": LifeBuoy,
  bell: Bell,
} as const;

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
  return (
    <div className="grid min-h-[calc(100vh-60px)] grid-cols-1 md:grid-cols-[260px_1fr]">
      <aside className="border-r bg-white p-4">
        <p className="text-xs uppercase tracking-wide text-orange-500">Backoffice</p>
        <p className="mb-4 text-sm text-slate-500">{email || ""}</p>
        <nav className="space-y-1">
          {sections.map((s) => {
            const Icon = icons[(s.icon || "") as keyof typeof icons] || LayoutDashboard;
            return (
              <Link
                key={s.id}
                href={s.path}
                className={cn(
                  "flex items-center gap-2 rounded-md px-3 py-2 text-sm",
                  pathname === s.path ? "bg-orange-500 text-white" : "text-slate-700 hover:bg-orange-50",
                )}
              >
                <Icon size={16} /> {s.label}
              </Link>
            );
          })}
        </nav>
      </aside>
      <main className="bg-slate-50 p-4 md:p-6">{children}</main>
    </div>
  );
};
