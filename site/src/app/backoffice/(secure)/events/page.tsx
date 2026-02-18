import { requireBackofficeSection } from "@/lib/data/backoffice-guard";
import { EventsManager } from "@/components/backoffice/events-manager";
import { CrudJsonStudio } from "@/components/backoffice/crud-json-studio";
import { EventLocationUpdater } from "@/components/backoffice/event-location-updater";
import { PricingPreviewManager } from "@/components/backoffice/pricing-preview-manager";

export default async function BackofficeEventsPage() {
  await requireBackofficeSection("/backoffice/events");
  return (
    <div className="space-y-3">
      <h1 className="text-2xl font-semibold">Gestion Événements</h1>
      <p className="text-sm text-slate-600">
        Pilote la visibilité concours/événements en temps réel.
      </p>
      <EventsManager />
      <PricingPreviewManager />
      <EventLocationUpdater />
      <CrudJsonStudio table="contests" title="CRUD Concours (JSON)" />
      <CrudJsonStudio table="events" title="CRUD Événements (JSON)" />
    </div>
  );
}
