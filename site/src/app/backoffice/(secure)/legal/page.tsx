import { requireBackofficeSection } from "@/lib/data/backoffice-guard";
import { BackofficeSectionGroup } from "@/components/backoffice/backoffice-section-group";
import { LegalDocumentEditor } from "@/components/backoffice/legal-document-editor";
import { BackofficePageHero } from "@/components/backoffice/backoffice-page-hero";

export default async function BackofficeLegalPage() {
  await requireBackofficeSection("/backoffice/legal");
  return (
    <div className="space-y-4">
      <BackofficePageHero
        title="Documents légaux"
        subtitle="Publie les conditions d'utilisation et la politique de confidentialité affichées dans l'application."
        badges={["CGU", "Confidentialité", "Versionné"]}
      />
      <BackofficeSectionGroup id="legal-documents" title="Publication des versions" defaultOpen>
        <LegalDocumentEditor />
      </BackofficeSectionGroup>
    </div>
  );
}
