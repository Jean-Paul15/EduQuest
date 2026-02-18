import { requireBackofficeSection } from "@/lib/data/backoffice-guard";
import { BackofficeSectionGroup } from "@/components/backoffice/backoffice-section-group";
import { SupportRequestsManager } from "@/components/backoffice/support-requests-manager";
import { CrudJsonStudio } from "@/components/backoffice/crud-json-studio";
import { AuditLogManager } from "@/components/backoffice/audit-log-manager";
import { ModerationActionsManager } from "@/components/backoffice/moderation-actions-manager";
import { BackofficePageHero } from "@/components/backoffice/backoffice-page-hero";

export default async function BackofficeSupportPage() {
  await requireBackofficeSection("/backoffice/support");
  return (
    <div className="space-y-4">
      <BackofficePageHero
        title="Gestion Support"
        subtitle="Traite les demandes utilisateurs, applique la modération et garde une trace d’audit exploitable."
        badges={["Demandes", "Modération", "Conformité", "Audit"]}
        actions={[
          { label: "Demandes", href: "#support-requests" },
          { label: "Moderation", href: "#support-moderation" },
          { label: "Audit", href: "#support-audit" },
        ]}
      />
      <BackofficeSectionGroup id="support-requests" title="Demandes et traitement" defaultOpen>
        <SupportRequestsManager />
      </BackofficeSectionGroup>
      <BackofficeSectionGroup id="support-moderation" title="Modération et conformité">
        <ModerationActionsManager />
      </BackofficeSectionGroup>
      <BackofficeSectionGroup id="support-audit" title="Historique et outils avancés">
        <AuditLogManager />
        <CrudJsonStudio table="data_deletion_requests" title="Gestion avancée des demandes de suppression" />
      </BackofficeSectionGroup>
    </div>
  );
}
