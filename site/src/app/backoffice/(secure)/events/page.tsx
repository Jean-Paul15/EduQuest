import { requireBackofficeSection } from "@/lib/data/backoffice-guard";
import { BackofficeSectionGroup } from "@/components/backoffice/backoffice-section-group";
import { EventsManager } from "@/components/backoffice/events-manager";
import { CrudJsonStudio } from "@/components/backoffice/crud-json-studio";
import { EventLocationUpdater } from "@/components/backoffice/event-location-updater";
import { PricingPreviewManager } from "@/components/backoffice/pricing-preview-manager";
import { BackofficePageHero } from "@/components/backoffice/backoffice-page-hero";

export default async function BackofficeEventsPage() {
  await requireBackofficeSection("/backoffice/events");
  return (
    <div className="space-y-4">
      <BackofficePageHero
        title="Gestion Événements"
        subtitle="Crée, ajuste et publie concours et événements avec contrôle des tarifs et de la localisation."
        badges={["Événements", "Concours", "Pricing", "Localisation"]}
        actions={[
          { label: "Pilotage", href: "#events-core" },
          { label: "Pricing", href: "#pricing" },
          { label: "Localisation", href: "#location" },
        ]}
      />
      <BackofficeSectionGroup id="events-core" title="Pilotage concours & événements" defaultOpen>
        <EventsManager />
      </BackofficeSectionGroup>
      <BackofficeSectionGroup id="pricing" title="Aperçu des tarifs">
        <PricingPreviewManager />
      </BackofficeSectionGroup>
      <BackofficeSectionGroup id="location" title="Localisation et coordonnées">
        <EventLocationUpdater />
      </BackofficeSectionGroup>
      <BackofficeSectionGroup id="events-json" title="Outils avancés (admin)">
        <CrudJsonStudio table="contests" title="Gestion avancée des concours" />
        <CrudJsonStudio table="events" title="Gestion avancée des événements" />
      </BackofficeSectionGroup>
    </div>
  );
}
