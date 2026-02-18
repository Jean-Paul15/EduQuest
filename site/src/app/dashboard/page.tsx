import Link from "next/link";
import { redirect } from "next/navigation";
import { Trophy, CalendarDays, Radio, ClipboardList, Ticket } from "lucide-react";
import { getHubCounts } from "@/lib/data/hub";
import { getViewerContext } from "@/lib/data/profile";

const statCards = [
  { key: "contests", label: "Concours", icon: <Trophy className="w-5 h-5" />, color: "text-orange-500 bg-orange-50" },
  { key: "events", label: "Événements", icon: <CalendarDays className="w-5 h-5" />, color: "text-blue-500 bg-blue-50" },
  { key: "live_classes", label: "Lives", icon: <Radio className="w-5 h-5" />, color: "text-emerald-500 bg-emerald-50" },
  { key: "surveys", label: "Enquêtes", icon: <ClipboardList className="w-5 h-5" />, color: "text-purple-500 bg-purple-50" },
] as const;

export default async function DashboardPage() {
  const viewer = await getViewerContext();
  if (!viewer.user) redirect("/login?next=/dashboard");
  const counts = await getHubCounts();

  return (
    <main className="mx-auto max-w-5xl px-4 py-10 space-y-6">
      <section className="rounded-2xl border border-slate-200 bg-white p-6">
        <p className="text-xs font-bold text-slate-400 uppercase tracking-widest">Mon espace</p>
        <h1 className="text-2xl font-extrabold tracking-tight mt-1">{viewer.profile?.full_name || viewer.user.email}</h1>
        <p className="text-sm text-slate-500 mt-0.5">Niveau d&apos;accès : <span className="font-semibold text-slate-700">{viewer.access?.tier ?? "FREE"}</span></p>
      </section>

      <section className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {statCards.map((s) => (
          <div key={s.key} className="rounded-2xl border border-slate-200 bg-white p-5 flex items-center gap-4">
            <div className={`w-11 h-11 rounded-xl flex items-center justify-center ${s.color}`}>{s.icon}</div>
            <div>
              <p className="text-2xl font-black text-slate-900">{counts[s.key]}</p>
              <p className="text-xs text-slate-500">{s.label}</p>
            </div>
          </div>
        ))}
      </section>

      <section className="flex flex-wrap gap-3">
        <Link href="/tickets/checkout" className="btn-primary !text-sm"><Ticket className="w-4 h-4" /> Acheter un ticket</Link>
        <Link href="/concours" className="btn-secondary !text-sm">Concours</Link>
        <Link href="/evenements" className="btn-secondary !text-sm">Événements</Link>
      </section>
    </main>
  );
}
