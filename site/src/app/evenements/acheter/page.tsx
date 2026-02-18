import { redirect } from "next/navigation";
import { CalendarDays, ShieldCheck } from "lucide-react";
import { PublicEventBuyForm } from "@/components/public-event-buy-form";
import { env } from "@/lib/env";
import { listEvents } from "@/lib/data/events";

type Props = { searchParams: Promise<{ eventId?: string; next?: string }> };

export default async function EventBuyPage({ searchParams }: Props) {
  const params = await searchParams;
  const eventId = params.eventId;
  const appReturnUrl = (params.next || "").startsWith("eduquest://")
    ? String(params.next)
    : env.appDeepLink;
  if (!eventId) redirect("/evenements");

  const events = await listEvents();
  const event = events.find((item) => item.id === eventId);
  if (!event) redirect("/evenements");

  return (
    <main className="mx-auto max-w-lg px-4 py-10 space-y-5">
      {/* Hero */}
      <section className="text-center space-y-2">
        <div className="mx-auto w-12 h-12 rounded-2xl bg-gradient-to-br from-orange-500 to-orange-600 flex items-center justify-center text-white shadow-lg shadow-orange-500/25">
          <CalendarDays className="w-6 h-6" />
        </div>
        <h1 className="text-2xl sm:text-3xl font-extrabold tracking-tight">
          {event.title}
        </h1>
        <p className="text-sm text-slate-500 max-w-xs mx-auto">
          Remplissez vos coordonn\u00e9es pour recevoir votre ticket imm\u00e9diatement.
        </p>
      </section>

      {/* Trust */}
      <div className="flex items-center justify-center gap-4 text-xs text-slate-400">
        <span className="flex items-center gap-1"><ShieldCheck className="w-3.5 h-3.5 text-emerald-500" /> Paiement s\u00e9curis\u00e9</span>
        <span className="w-1 h-1 bg-slate-200 rounded-full" />
        <span>Ticket instantan\u00e9</span>
        <span className="w-1 h-1 bg-slate-200 rounded-full" />
        <span>Re\u00e7u PDF</span>
      </div>

      <PublicEventBuyForm eventId={eventId} appReturnUrl={appReturnUrl} />
    </main>
  );
}
