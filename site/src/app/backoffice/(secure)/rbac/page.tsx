import { redirect } from "next/navigation";
import { RbacManager } from "@/components/backoffice/rbac-manager";
import { requireBackofficeSection } from "@/lib/data/backoffice-guard";

export default async function BackofficeRbacPage() {
  const context = await requireBackofficeSection("/backoffice/rbac");
  if (!context.admin) redirect(context.sections[0]?.path || "/backoffice");

  return (
    <div className="space-y-3">
      <h1 className="text-2xl font-semibold text-slate-900">RBAC dynamique</h1>
      <p className="text-sm text-slate-600">Admin crée les rôles, attribue les sections sidebar et assigne les utilisateurs.</p>
      <RbacManager />
    </div>
  );
}
