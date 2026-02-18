import { redirect } from "next/navigation";
import { BackofficeShell } from "@/components/backoffice/backoffice-shell";
import { BackofficeRefineShell } from "@/components/backoffice/backoffice-refine-shell";
import { loadBackofficeContext } from "@/lib/data/backoffice-server";

export default async function SecureBackofficeLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const context = await loadBackofficeContext();
  if (!context) redirect("/login?next=/backoffice");
  if (context.mustReset) redirect("/backoffice/reset-password");

  return (
    <BackofficeRefineShell>
      <BackofficeShell sections={context.sections} email={context.user.email}>
        {children}
      </BackofficeShell>
    </BackofficeRefineShell>
  );
}
