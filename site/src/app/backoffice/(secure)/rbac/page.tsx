import { redirect } from "next/navigation";
import { RbacManager } from "@/components/backoffice/rbac-manager";
import { BackofficeSectionGroup } from "@/components/backoffice/backoffice-section-group";
import { requireBackofficeSection } from "@/lib/data/backoffice-guard";
import { BackofficePageHero } from "@/components/backoffice/backoffice-page-hero";

export default async function BackofficeRbacPage() {
  const context = await requireBackofficeSection("/backoffice/rbac");
  if (!context.admin) redirect(context.sections[0]?.path || "/backoffice");

  return (
    <div className="space-y-4">
      <BackofficePageHero
        title="Gestion des accès"
        subtitle="Définis qui peut voir et utiliser chaque partie du backoffice."
        badges={["Profils", "Droits", "Menus", "Utilisateurs"]}
        actions={[
          { label: "Profils", href: "#rbac-roles" },
          { label: "Droits", href: "#rbac-perms" },
          { label: "Utilisateurs", href: "#rbac-assign" },
        ]}
      />
      <BackofficeSectionGroup id="rbac-roles" title="Profils, droits, menus et utilisateurs" defaultOpen>
        <div id="rbac-perms" />
        <div id="rbac-sections" />
        <div id="rbac-assign" />
        <RbacManager />
      </BackofficeSectionGroup>
    </div>
  );
}
