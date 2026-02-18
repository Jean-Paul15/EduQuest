import { Card } from "@/components/ui/card";
import { BackofficeSectionGroup } from "@/components/backoffice/backoffice-section-group";
import { requireBackofficeSection } from "@/lib/data/backoffice-guard";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { DashboardAlertsPanel } from "@/components/backoffice/dashboard-alerts-panel";
import { DashboardOpsActions } from "@/components/backoffice/dashboard-ops-actions";
import { DashboardHealthPanel } from "@/components/backoffice/dashboard-health-panel";
import { DashboardActivityPanel } from "@/components/backoffice/dashboard-activity-panel";
import { KpiAdvancedPanel } from "@/components/backoffice/kpi-advanced-panel";
import { BackofficePageHero } from "@/components/backoffice/backoffice-page-hero";

export default async function BackofficeDashboardPage() {
  const context = await requireBackofficeSection("/backoffice/dashboard");
  const supabase = await createSupabaseServerClient();
  const [roles, users, sections, students, activeTickets, queuedPush, pendingDelete, soldCodes, snapshot] = await Promise.all([
    supabase.from("backoffice_roles").select("id", { head: true, count: "exact" }),
    supabase.from("backoffice_user_roles").select("user_id", { head: true, count: "exact" }),
    supabase.from("backoffice_nav_sections").select("id", { head: true, count: "exact" }),
    supabase.from("profiles").select("id", { head: true, count: "exact" }).eq("role", "student"),
    supabase.from("ticket_codes").select("id", { head: true, count: "exact" }).gt("expires_at", new Date().toISOString()),
    supabase.from("notification_campaigns").select("id", { head: true, count: "exact" }).in("status", ["queued", "retrying"]),
    supabase.from("data_deletion_requests").select("id", { head: true, count: "exact" }).eq("status", "pending"),
    supabase.from("ticket_codes").select("id", { head: true, count: "exact" }).not("sold_at", "is", null),
    supabase.rpc("backoffice_kpi_snapshot"),
  ]);
  const kpi = (snapshot.data || {}) as Record<string, number>;

  const top = [
    ["Élèves", students.count || 0],
    ["Accès actifs", activeTickets.count || 0],
    ["Notifications à envoyer", queuedPush.count || 0],
    ["Demandes support ouvertes", pendingDelete.count || 0],
  ] as const;
  const trend = [
    ["Activité aujourd'hui", Number(kpi.app_events_24h || 0)],
    ["Activité cette semaine", Number(kpi.app_events_7d || 0)],
    ["Ventes tickets aujourd'hui", Number(kpi.tickets_sold_24h || 0)],
    ["Ventes tickets cette semaine", Number(kpi.tickets_sold_7d || 0)],
    ["Inscriptions concours (7 jours)", Number(kpi.contest_joins_7d || 0)],
    ["Inscriptions événements (7 jours)", Number(kpi.event_joins_7d || 0)],
  ] as const;
  const max = Math.max(...trend.map(([, n]) => n), 1);

  return (
    <div className="space-y-4">
      <BackofficePageHero
        title="Dashboard Backoffice"
        subtitle="Vue générale pour piloter l'application avec des mots simples."
        badges={["Vue générale", "Alertes", "Activité", "Performance"]}
        actions={[
          { label: "Voir alertes", href: "#alerts" },
          { label: "Voir activite", href: "#activity" },
          { label: "Voir comportement élèves", href: "#kpi" },
        ]}
      />
      <div className="grid gap-3 md:grid-cols-4">
        {top.map(([label, value]) => (
          <Card key={label} className="border-0 bg-gradient-to-br from-blue-50 to-orange-50 p-4">
            <p className="text-xs uppercase tracking-wide text-slate-600">{label}</p>
            <p className="mt-1 text-2xl font-bold text-slate-900">{value}</p>
          </Card>
        ))}
      </div>

      <BackofficeSectionGroup id="overview" title="Comprendre ce tableau de bord" defaultOpen>
        <div className="grid gap-3 md:grid-cols-2">
          <Card className="p-3 text-sm text-slate-700">Élèves: total des comptes apprenants.</Card>
          <Card className="p-3 text-sm text-slate-700">Accès actifs: élèves avec ticket encore valide.</Card>
          <Card className="p-3 text-sm text-slate-700">Notifications à envoyer: campagnes encore en attente.</Card>
          <Card className="p-3 text-sm text-slate-700">Demandes support ouvertes: tickets à traiter en priorité.</Card>
        </div>
        <Card className="p-4">
          <p className="text-sm font-semibold text-slate-900">Tes droits d&apos;accès</p>
          <p className="text-sm text-slate-600">{context.admin ? "Profil administrateur: accès complet aux modules autorisés." : "Profil opérateur: accès limité aux sections assignées."}</p>
          <div className="mt-2 flex flex-wrap gap-2">
            {context.sections.map((s) => <span key={s.id} className="rounded-full bg-blue-50 px-3 py-1 text-xs font-medium text-blue-700">{s.label}</span>)}
          </div>
        </Card>
      </BackofficeSectionGroup>

      <BackofficeSectionGroup id="overview-trend" title="Tendances clés">
        <div className="grid gap-3 md:grid-cols-2">
          {trend.map(([label, value]) => (
            <div key={label} className="rounded-xl border border-slate-200 bg-white p-3">
              <div className="mb-2 flex items-center justify-between text-sm"><span>{label}</span><span className="font-semibold">{value}</span></div>
              <div className="h-2 overflow-hidden rounded-full bg-slate-100">
                <div className="h-full rounded-full bg-gradient-to-r from-orange-500 to-blue-500" style={{ width: `${(value / max) * 100}%` }} />
              </div>
            </div>
          ))}
        </div>
      </BackofficeSectionGroup>

      <DashboardOpsActions />
      <div id="alerts" className="grid gap-3 lg:grid-cols-2">
        <DashboardAlertsPanel />
        <div id="health"><DashboardHealthPanel /></div>
      </div>
      <div id="activity"><DashboardActivityPanel /></div>
      <div id="kpi"><KpiAdvancedPanel /></div>
      <BackofficeSectionGroup id="rbac-summary" title="Équipe et accès">
        <div className="grid gap-3 md:grid-cols-4">
          <Card className="p-3 text-sm">Profils d&apos;accès: <span className="font-semibold">{roles.count || 0}</span></Card>
          <Card className="p-3 text-sm">Utilisateurs avec accès: <span className="font-semibold">{users.count || 0}</span></Card>
          <Card className="p-3 text-sm">Menus disponibles: <span className="font-semibold">{sections.count || 0}</span></Card>
          <Card className="p-3 text-sm">Codes tickets vendus: <span className="font-semibold">{soldCodes.count || 0}</span></Card>
        </div>
        <p className="text-xs text-slate-500">Les accès sont gérés par profils, droits et menus assignés.</p>
      </BackofficeSectionGroup>
    </div>
  );
}
