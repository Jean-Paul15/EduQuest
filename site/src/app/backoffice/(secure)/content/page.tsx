import { requireBackofficeSection } from "@/lib/data/backoffice-guard";
import { ContentManager } from "@/components/backoffice/content-manager";
import { CrudJsonStudio } from "@/components/backoffice/crud-json-studio";
import { RuntimeLinksManager } from "@/components/backoffice/runtime-links-manager";
import { PromoWindowManager } from "@/components/backoffice/promo-window-manager";
import { TicketProductsManager } from "@/components/backoffice/ticket-products-manager";
import { TicketCodesManager } from "@/components/backoffice/ticket-codes-manager";
import { LevelSeriesManager } from "@/components/backoffice/level-series-manager";
import { SubjectChapterManager } from "@/components/backoffice/subject-chapter-manager";
import { SurveyBuilderManager } from "@/components/backoffice/survey-builder-manager";
import { SurveyStatsManager } from "@/components/backoffice/survey-stats-manager";
import { LiveClassesManager } from "@/components/backoffice/live-classes-manager";
import { OnboardingCampaignManager } from "@/components/backoffice/onboarding-campaign-manager";
import { MonthlyRewardsManager } from "@/components/backoffice/monthly-rewards-manager";
import { WeeklyRewardsManager } from "@/components/backoffice/weekly-rewards-manager";
import { TicketSupportWorkflowManager } from "@/components/backoffice/ticket-support-workflow-manager";
import { AutomationRulesManager } from "@/components/backoffice/automation-rules-manager";
import { LiveSurveyWorkflowManager } from "@/components/backoffice/live-survey-workflow-manager";
import { AppConfigVisualStudioManager } from "@/components/backoffice/app-config-visual-studio-manager";
import { TicketCheckoutRulesManager } from "@/components/backoffice/ticket-checkout-rules-manager";

export default async function BackofficeContentPage() {
  await requireBackofficeSection("/backoffice/content");
  return (
    <div className="space-y-3">
      <h1 className="text-2xl font-semibold">Gestion Contenus</h1>
      <p className="text-sm text-slate-600">
        Modifie les configurations runtime (liens, auth, hub, accès).
      </p>
      <RuntimeLinksManager />
      <PromoWindowManager />
      <TicketProductsManager />
      <TicketCheckoutRulesManager />
      <TicketCodesManager />
      <LevelSeriesManager />
      <SubjectChapterManager />
      <SurveyBuilderManager />
      <SurveyStatsManager />
      <LiveClassesManager />
      <OnboardingCampaignManager />
      <MonthlyRewardsManager />
      <WeeklyRewardsManager />
      <TicketSupportWorkflowManager />
      <LiveSurveyWorkflowManager />
      <AutomationRulesManager />
      <AppConfigVisualStudioManager />
      <ContentManager />
      <CrudJsonStudio table="surveys" title="CRUD Enquêtes (JSON)" />
      <CrudJsonStudio table="live_classes" title="CRUD Lives (JSON)" />
      <CrudJsonStudio table="resources" title="CRUD Ressources (JSON)" />
      <CrudJsonStudio table="quizzes" title="CRUD Quiz (JSON)" />
      <CrudJsonStudio table="exam_papers" title="CRUD Examens/Épreuves (JSON)" />
      <CrudJsonStudio table="marketplace_items" title="CRUD Marketplace (JSON)" />
      <CrudJsonStudio table="ticket_products" title="CRUD Produits Tickets (JSON)" />
      <CrudJsonStudio table="ticket_checkout_orders" title="CRUD Checkout Tickets (JSON)" />
      <CrudJsonStudio table="access_campaigns" title="CRUD Campagnes Accès (JSON)" />
    </div>
  );
}
