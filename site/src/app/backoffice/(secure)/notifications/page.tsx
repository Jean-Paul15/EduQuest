import { requireBackofficeSection } from "@/lib/data/backoffice-guard";
import { BackofficeSectionGroup } from "@/components/backoffice/backoffice-section-group";
import { NotificationCenterManager } from "@/components/backoffice/notification-center-manager";
import { CrudJsonStudio } from "@/components/backoffice/crud-json-studio";
import { BackofficePageHero } from "@/components/backoffice/backoffice-page-hero";

export default async function BackofficeNotificationsPage() {
  await requireBackofficeSection("/backoffice/notifications");
  return (
    <div className="space-y-4">
      <BackofficePageHero
        title="Notifications"
        subtitle="Lance des campagnes push, suis les envois et corrige rapidement les échecs de distribution."
        badges={["Campagnes", "Utilisateurs", "Logs d’envoi"]}
        actions={[
          { label: "Campagnes", href: "#notif-campaigns" },
          { label: "Notifications users", href: "#notif-users" },
          { label: "Logs", href: "#notif-logs" },
        ]}
      />
      <BackofficeSectionGroup id="notif-campaigns" title="Campagnes push" defaultOpen>
        <NotificationCenterManager />
      </BackofficeSectionGroup>
      <BackofficeSectionGroup id="notif-users" title="Messages utilisateurs">
        <CrudJsonStudio table="user_notifications" title="Gestion avancée des messages utilisateurs" />
      </BackofficeSectionGroup>
      <BackofficeSectionGroup id="notif-logs" title="Historique et suivi">
        <CrudJsonStudio table="notification_campaigns" title="Gestion avancée des campagnes" />
        <CrudJsonStudio table="notification_dispatch_logs" title="Historique détaillé des envois" />
      </BackofficeSectionGroup>
    </div>
  );
}
