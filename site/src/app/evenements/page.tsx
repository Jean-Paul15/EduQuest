import Link from "next/link";
import { CalendarDays, MapPin, Video, ArrowRight, CheckCircle2 } from "lucide-react";
import { listEvents, listMyEventRegistrations } from "@/lib/data/events";
import { getViewerContext } from "@/lib/data/profile";
import { formatDate, formatMoney } from "@/lib/format";

export default async function EventsPage() {
  const viewer = await getViewerContext();
  const [events, regs] = await Promise.all([
    listEvents(),
    viewer.user ? listMyEventRegistrations() : Promise.resolve([]),
  ]);
  const byEvent = new Map(regs.map((e) => [e.event_id, e]));

  return (
    <main className="mx-auto max-w-5xl px-4 py-10 space-y-8">
      {/* Header */}
      <section className="space-y-2">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-blue-600 to-blue-700 flex items-center justify-center text-white">
            <CalendarDays className="w-4 h-4" />
          </div>
          <span className="text-xs font-bold uppercase tracking-widest text-blue-600">Agenda</span>
        </div>
        <h1 className="text-2xl sm:text-3xl font-extrabold tracking-tight">&Eacute;v&eacute;nements</h1>
        <p className="text-sm text-slate-500 max-w-md">
          Ateliers, lives, conf&eacute;rences &mdash; ne ratez rien.
        </p>
      </section>

      {/* Grid */}
      <div className="grid gap-5 md:grid-cols-2">
        {events.map((ev) => {
          const reg = byEvent.get(ev.id);
          const enrolled = !!reg;
          const mapsUrl = ev.location_lat && ev.location_lng
            ? `https://www.google.com/maps/search/?api=1&query=${ev.location_lat},${ev.location_lng}`
            : null;
          const publicPrice = ev.public_is_free ? 0 : Number(ev.public_fee ?? ev.fee_free ?? 0);

          return (
            <article key={ev.id} className="group rounded-2xl border border-slate-200 bg-white overflow-hidden transition hover:shadow-lg hover:border-slate-300">
              <div className="p-5 space-y-4">
                {/* Type badge + title */}
                <div className="space-y-2">
                  <span className="inline-flex items-center gap-1 rounded-full bg-blue-50 px-2.5 py-1 text-[11px] font-bold text-blue-700 uppercase tracking-wide">
                    {ev.event_type}
                  </span>
                  <h2 className="text-lg font-bold text-slate-900 leading-snug">{ev.title}</h2>
                  <div className="flex flex-wrap gap-x-4 gap-y-1 text-xs text-slate-500">
                    <span className="inline-flex items-center gap-1">
                      <CalendarDays className="w-3.5 h-3.5 text-slate-400" />{formatDate(ev.starts_at)}
                    </span>
                    <span className="inline-flex items-center gap-1">
                      <MapPin className="w-3.5 h-3.5 text-slate-400" />{ev.venue || "En ligne"}
                    </span>
                  </div>
                </div>

                {/* Price grid */}
                <div className="space-y-2">
                  <div className="grid grid-cols-3 gap-2">
                    <PricePill label="Full" amount={formatMoney(ev.fee_full)} />
                    <PricePill label="Half" amount={formatMoney(ev.fee_half)} />
                    <PricePill label="Free" amount={formatMoney(ev.fee_free)} />
                  </div>
                  <div className="rounded-lg bg-orange-50 border border-orange-100 px-3 py-2 text-center">
                    <p className="text-[10px] font-bold uppercase tracking-wider text-orange-500">Visiteur</p>
                    <p className="text-sm font-extrabold text-slate-900 mt-0.5">{formatMoney(publicPrice)}</p>
                  </div>
                </div>

                {/* Links */}
                <div className="flex flex-wrap gap-3">
                  {ev.meeting_url && (
                    <a href={ev.meeting_url} className="inline-flex items-center gap-1 text-xs font-medium text-blue-600 hover:text-blue-700 transition-colors">
                      <Video className="w-3.5 h-3.5" /> Rejoindre le live
                    </a>
                  )}
                  {mapsUrl && (
                    <a href={mapsUrl} target="_blank" rel="noopener noreferrer" className="inline-flex items-center gap-1 text-xs font-medium text-blue-600 hover:text-blue-700 transition-colors">
                      <MapPin className="w-3.5 h-3.5" /> Voir sur la carte
                    </a>
                  )}
                </div>

                {/* Actions */}
                <div className="flex items-center justify-between pt-1">
                  {enrolled ? (
                    <span className="inline-flex items-center gap-1.5 rounded-full bg-emerald-50 px-3 py-1.5 text-xs font-semibold text-emerald-700">
                      <CheckCircle2 className="w-3.5 h-3.5" /> {reg.status}
                    </span>
                  ) : viewer.user ? (
                    <Link href={`/payer?kind=event&id=${ev.id}`} className="btn-primary !py-2.5 !px-5 !text-sm !rounded-xl">
                      S&apos;inscrire <ArrowRight className="w-3.5 h-3.5" />
                    </Link>
                  ) : (
                    <Link href={`/evenements/acheter?eventId=${ev.id}`} className="btn-secondary !py-2.5 !px-5 !text-sm !rounded-xl">
                      Acheter (visiteur) <ArrowRight className="w-3.5 h-3.5" />
                    </Link>
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
