import { requireBackofficeSection } from "@/lib/data/backoffice-guard";
import { SupportRequestsManager } from "@/components/backoffice/support-requests-manager";
import { CrudJsonStudio } from "@/components/backoffice/crud-json-studio";
import { AuditLogManager } from "@/components/backoffice/audit-log-manager";
import { ModerationActionsManager } from "@/components/backoffice/moderation-actions-manager";

export default async function BackofficeSupportPage() {
  await requireBackofficeSection("/backoffice/support");
  return (
    <div className="space-y-3">
      <h1 className="text-2xl font-semibold">Gestion Support</h1>
      <p className="text-sm text-slate-600">
        Suivi des demandes de suppression de données et opérations support.
      </p>
      <SupportRequestsManager />
      <ModerationActionsManager />
      <AuditLogManager />
      <CrudJsonStudio
        table="data_deletion_requests"
        title="CRUD Demandes Suppression (JSON)"
      />
    </div>
  );
}
