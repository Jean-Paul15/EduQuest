import { requireBackofficeSection } from "@/lib/data/backoffice-guard";
import { NotificationCenterManager } from "@/components/backoffice/notification-center-manager";
import { CrudJsonStudio } from "@/components/backoffice/crud-json-studio";

export default async function BackofficeNotificationsPage() {
  await requireBackofficeSection("/backoffice/notifications");
  return (
    <div className="space-y-3">
      <h1 className="text-2xl font-semibold">Notifications</h1>
      <p className="text-sm text-slate-600">
        Crée les campagnes push et pilote les notifications stockées en base.
      </p>
      <NotificationCenterManager />
      <CrudJsonStudio table="notification_campaigns" title="CRUD Campagnes (JSON)" />
      <CrudJsonStudio table="user_notifications" title="CRUD Notifications Utilisateur (JSON)" />
      <CrudJsonStudio table="notification_dispatch_logs" title="CRUD Logs Envoi (JSON)" />
    </div>
  );
}
