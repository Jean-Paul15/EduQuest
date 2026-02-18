/* eslint-disable @next/next/no-img-element */
import Link from "next/link";
import { redirect } from "next/navigation";
import { Trophy, MapPin, Calendar, ArrowRight, Users } from "lucide-react";
import { listContests, listMyContestEntries } from "@/lib/data/contests";
import { getViewerContext } from "@/lib/data/profile";
import { formatDate, formatMoney } from "@/lib/format";

export default async function ConcoursPage() {
  const viewer = await getViewerContext();
  if (!viewer.user) redirect("/login?next=/concours");
  const [contests, entries] = await Promise.all([listContests(), listMyContestEntries()]);
  const byContest = new Map(entries.map((e) => [e.contest_id, e]));

  return (
    <main className="mx-auto max-w-5xl px-4 py-10 space-y-8">
      {/* Header */}
      <section className="space-y-2">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-orange-500 to-orange-600 flex items-center justify-center text-white">
            <Trophy className="w-4 h-4" />
          </div>
          <span className="text-xs font-bold uppercase tracking-widest text-orange-600">Comp&eacute;titions</span>
        </div>
        <h1 className="text-2xl sm:text-3xl font-extrabold tracking-tight">Concours</h1>
        <p className="text-sm text-slate-500 max-w-md">
          Inscrivez-vous, mesurez-vous aux meilleurs et gagnez des prix.
        </p>
      </section>

      {/* Grid */}
      <div className="grid gap-5 md:grid-cols-2">
        {contests.map((c) => {
          const entry = byContest.get(c.id);
          const enrolled = !!entry;
          const mapsUrl = c.location_lat && c.location_lng
            ? `https://www.google.com/maps/search/?api=1&query=${c.location_lat},${c.location_lng}`
            : null;

          return (
            <article key={c.id} className="group rounded-2xl border border-slate-200 bg-white overflow-hidden transition hover:shadow-lg hover:border-slate-300">
              {/* Cover */}
              {c.logo_url && (
                <div className="relative h-40 overflow-hidden">
                  <img src={c.logo_url} alt={c.title} className="h-full w-full object-cover transition group-hover:scale-105" />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/40 to-transparent" />
                </div>
              )}

              <div className="p-5 space-y-4">
                {/* Title + meta */}
                <div className="space-y-2">
                  <h2 className="text-lg font-bold text-slate-900 leading-snug">{c.title}</h2>
                  <div className="flex flex-wrap gap-x-4 gap-y-1 text-xs text-slate-500">
                    <span className="inline-flex items-center gap-1">
                      <Calendar className="w-3.5 h-3.5 text-slate-400" />{formatDate(c.starts_at)}
                    </span>
                    <span className="inline-flex items-center gap-1">
                      <MapPin className="w-3.5 h-3.5 text-slate-400" />{c.venue || "\u00c0 pr\u00e9ciser"}
                    </span>
                  </div>
                </div>

                {/* Price grid */}
                <div className="grid grid-cols-3 gap-2">
                  <PricePill label="Full" amount={formatMoney(c.fee_full)} />
                  <PricePill label="Half" amount={formatMoney(c.fee_half)} />
                  <PricePill label="Free" amount={formatMoney(c.fee_free)} />
                </div>

                {/* Actions */}
                <div className="flex items-center justify-between pt-1">
                  {enrolled ? (
                    <span className="inline-flex items-center gap-1.5 rounded-full bg-emerald-50 px-3 py-1.5 text-xs font-semibold text-emerald-700">
                      <Users className="w-3.5 h-3.5" /> {entry.status}
                    </span>
                  ) : (
                    <Link href={`/payer?kind=contest&id=${c.id}`} className="btn-primary !py-2.5 !px-5 !text-sm !rounded-xl">
                      Participer <ArrowRight className="w-3.5 h-3.5" />
                    </Link>
                  )}
                  {mapsUrl && (
                    <a href={mapsUrl} target="_blank" rel="noopener noreferrer" className="text-xs font-medium text-blue-600 hover:text-blue-700 transition-colors">
                      Voir sur la carte
                    </a>
                  )}
                </div>
              </div>
            </article>
          );
        })}
      </div>
    </main>
  );
}

const PricePill = ({ label, amount }: { label: string; amount: string }) => (
  <div className="rounded-lg bg-slate-50 border border-slate-100 px-3 py-2 text-center">
    <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">{label}</p>
    <p className="text-sm font-extrabold text-slate-900 mt-0.5">{amount}</p>
  </div>
);
