import { requireBackofficeSection } from "@/lib/data/backoffice-guard";
import { BackofficeSectionGroup } from "@/components/backoffice/backoffice-section-group";
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
import { LearningLibraryManager } from "@/components/backoffice/learning-library-manager";
import { QuizQuestionsManager } from "@/components/backoffice/quiz-questions-manager";
import { AppModulesSettingsManager } from "@/components/backoffice/app-modules-settings-manager";
import { LearningSecurityAccessManager } from "@/components/backoffice/learning-security-access-manager";
import { FeedModulesManager } from "@/components/backoffice/feed-modules-manager";
import { AppUpdatePolicyManager } from "@/components/backoffice/app-update-policy-manager";
import { AppConfigPresetsManager } from "@/components/backoffice/app-config-presets-manager";
import { AppConfigBackupManager } from "@/components/backoffice/app-config-backup-manager";
import { PushDisplayDefaultsManager } from "@/components/backoffice/push-display-defaults-manager";
import { OfflineCachePolicyManager } from "@/components/backoffice/offline-cache-policy-manager";
import { AdvancedSecuritySettingsManager } from "@/components/backoffice/advanced-security-settings-manager";
import { OnboardingFlowSettingsManager } from "@/components/backoffice/onboarding-flow-settings-manager";
import { GamificationTuningManager } from "@/components/backoffice/gamification-tuning-manager";
import { PaymentProviderManager } from "@/components/backoffice/payment-provider-manager";
import { BackofficePageHero } from "@/components/backoffice/backoffice-page-hero";

export default async function BackofficeContentPage() {
  await requireBackofficeSection("/backoffice/content");
  return (
    <div className="space-y-4">
      <BackofficePageHero
        title="Gestion Contenus"
        subtitle="Organise le catalogue pédagogique, les tickets et les réglages de l'application avec des écrans simples."
        badges={["Catalogue", "Tickets", "Live", "Automations", "Config app"]}
        actions={[
          { label: "Catalogue", href: "#catalog" },
          { label: "Tickets", href: "#ticketing" },
          { label: "Config app", href: "#app-config" },
        ]}
      />

      <BackofficeSectionGroup id="catalog" title="Catalogue pédagogique" defaultOpen description="Niveaux, matières, contenus et ressources.">
        <LevelSeriesManager />
        <SubjectChapterManager />
        <LearningLibraryManager />
        <QuizQuestionsManager />
        <ContentManager />
      </BackofficeSectionGroup>

      <BackofficeSectionGroup id="ticketing" title="Tickets, checkout et campagnes" defaultOpen description="Produits, règles d'achat, codes et support ticket.">
        <PromoWindowManager />
        <TicketProductsManager />
        <TicketCheckoutRulesManager />
        <TicketCodesManager />
        <OnboardingCampaignManager />
        <TicketSupportWorkflowManager />
      </BackofficeSectionGroup>

      <BackofficeSectionGroup id="live" title="Live classes, surveys et récompenses" description="Animation pédagogique et gamification.">
        <SurveyBuilderManager />
        <SurveyStatsManager />
        <LiveClassesManager />
        <LiveSurveyWorkflowManager />
        <MonthlyRewardsManager />
        <WeeklyRewardsManager />
      </BackofficeSectionGroup>

      <BackofficeSectionGroup id="automation" title="Actions automatiques" description="Règles automatiques pour gagner du temps.">
        <AutomationRulesManager />
      </BackofficeSectionGroup>

      <BackofficeSectionGroup id="app-config" title="Paramètres application" defaultOpen description="Réglages généraux, sécurité et mises à jour.">
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
      </BackofficeSectionGroup>

      <BackofficeSectionGroup id="json-studio" title="Outils avancés (admin)" description="Réservé à l'administrateur pour les cas spécifiques.">
        <CrudJsonStudio table="surveys" title="Gestion avancée des enquêtes" />
        <CrudJsonStudio table="live_classes" title="Gestion avancée des lives" />
        <CrudJsonStudio table="marketplace_items" title="Gestion avancée marketplace" />
        <CrudJsonStudio table="ticket_products" title="Gestion avancée produits tickets" />
        <CrudJsonStudio table="ticket_checkout_orders" title="Gestion avancée commandes tickets" />
        <CrudJsonStudio table="access_campaigns" title="Gestion avancée campagnes d'accès" />
      </BackofficeSectionGroup>
    </div>
  );
}
