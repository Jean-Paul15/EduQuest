import { Card } from "@/components/ui/card";
import { requireBackofficeSection } from "@/lib/data/backoffice-guard";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { DashboardAlertsPanel } from "@/components/backoffice/dashboard-alerts-panel";
import { DashboardOpsActions } from "@/components/backoffice/dashboard-ops-actions";
import { DashboardHealthPanel } from "@/components/backoffice/dashboard-health-panel";
import { DashboardActivityPanel } from "@/components/backoffice/dashboard-activity-panel";
import { AppModulesSettingsManager } from "@/components/backoffice/app-modules-settings-manager";
import { LearningSecurityAccessManager } from "@/components/backoffice/learning-security-access-manager";
import { FeedModulesManager } from "@/components/backoffice/feed-modules-manager";
import { AppUpdatePolicyManager } from "@/components/backoffice/app-update-policy-manager";
import { RuntimeLinksManager } from "@/components/backoffice/runtime-links-manager";
import { AppConfigPresetsManager } from "@/components/backoffice/app-config-presets-manager";
import { AppConfigBackupManager } from "@/components/backoffice/app-config-backup-manager";
import { PushDisplayDefaultsManager } from "@/components/backoffice/push-display-defaults-manager";
import { OfflineCachePolicyManager } from "@/components/backoffice/offline-cache-policy-manager";
import { AdvancedSecuritySettingsManager } from "@/components/backoffice/advanced-security-settings-manager";
import { OnboardingFlowSettingsManager } from "@/components/backoffice/onboarding-flow-settings-manager";
import { GamificationTuningManager } from "@/components/backoffice/gamification-tuning-manager";
import { AppConfigVisualStudioManager } from "@/components/backoffice/app-config-visual-studio-manager";
import { KpiAdvancedPanel } from "@/components/backoffice/kpi-advanced-panel";
import { PaymentProviderManager } from "@/components/backoffice/payment-provider-manager";

export default async function BackofficeDashboardPage() {
  await requireBackofficeSection("/backoffice/dashboard");
  const supabase = await createSupabaseServerClient();
  const [roles, users, sections, students, activeTickets, queuedPush, pendingDelete, appEvents, contestJoins, eventJoins, soldCodes, snapshot] = await Promise.all([
    supabase.from("backoffice_roles").select("id", { head: true, count: "exact" }),
    supabase.from("backoffice_user_roles").select("user_id", { head: true, count: "exact" }),
    supabase.from("backoffice_nav_sections").select("id", { head: true, count: "exact" }),
    supabase.from("profiles").select("id", { head: true, count: "exact" }).eq("role", "student"),
    supabase.from("ticket_codes").select("id", { head: true, count: "exact" }).gt("expires_at", new Date().toISOString()),
    supabase.from("notification_campaigns").select("id", { head: true, count: "exact" }).in("status", ["queued", "retrying"]),
    supabase.from("data_deletion_requests").select("id", { head: true, count: "exact" }).eq("status", "pending"),
    supabase.from("app_events").select("id", { head: true, count: "exact" }),
    supabase.from("contest_entries").select("id", { head: true, count: "exact" }),
    supabase.from("event_registrations").select("id", { head: true, count: "exact" }),
    supabase.from("ticket_codes").select("id", { head: true, count: "exact" }).not("sold_at", "is", null),
    supabase.rpc("backoffice_kpi_snapshot"),
  ]);
  const kpi = (snapshot.data || {}) as Record<string, number>;

  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-semibold text-slate-900">Dashboard Backoffice</h1>
      <div className="grid gap-3 md:grid-cols-4">
        <Card className="p-4">Rôles: {roles.count || 0}</Card>
        <Card className="p-4">Affectations: {users.count || 0}</Card>
        <Card className="p-4">Sections sidebar: {sections.count || 0}</Card>
        <Card className="p-4">Élèves: {students.count || 0}</Card>
        <Card className="p-4">Tickets actifs: {activeTickets.count || 0}</Card>
        <Card className="p-4">Codes vendus: {soldCodes.count || 0}</Card>
        <Card className="p-4">App events: {appEvents.count || 0}</Card>
        <Card className="p-4">Inscriptions concours: {contestJoins.count || 0}</Card>
        <Card className="p-4">Inscriptions events: {eventJoins.count || 0}</Card>
        <Card className="p-4">Push en attente: {queuedPush.count || 0}</Card>
        <Card className="p-4">Support en attente: {pendingDelete.count || 0}</Card>
        <Card className="p-4">Events 24h: {kpi.app_events_24h || 0}</Card>
        <Card className="p-4">Events 7j: {kpi.app_events_7d || 0}</Card>
        <Card className="p-4">Ventes tickets 24h: {kpi.tickets_sold_24h || 0}</Card>
        <Card className="p-4">Ventes tickets 7j: {kpi.tickets_sold_7d || 0}</Card>
        <Card className="p-4">Concours 7j: {kpi.contest_joins_7d || 0}</Card>
        <Card className="p-4">Événements 7j: {kpi.event_joins_7d || 0}</Card>
      </div>
      <Card className="p-4 text-sm text-slate-600">
        Accès dynamiques actifs: chaque utilisateur voit uniquement les sections autorisées.
      </Card>
      <DashboardOpsActions />
      <div className="grid gap-3 lg:grid-cols-2">
        <DashboardAlertsPanel />
        <DashboardHealthPanel />
      </div>
      <DashboardActivityPanel />
      <KpiAdvancedPanel />
      <h2 className="text-xl font-semibold text-slate-900">Paramétrage Application</h2>
      <AppModulesSettingsManager />
      <LearningSecurityAccessManager />
      <FeedModulesManager />
      <AppUpdatePolicyManager />
      <RuntimeLinksManager />
      <PushDisplayDefaultsManager />
      <OfflineCachePolicyManager />
      <AdvancedSecuritySettingsManager />
      <OnboardingFlowSettingsManager />
      <GamificationTuningManager />
      <PaymentProviderManager />
      <AppConfigVisualStudioManager />
      <AppConfigPresetsManager />
      <AppConfigBackupManager />
    </div>
  );
}
