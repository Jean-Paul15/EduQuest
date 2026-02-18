import { redirect } from "next/navigation";
import { loadBackofficeContext } from "@/lib/data/backoffice-server";

export default async function BackofficeIndexPage() {
  const context = await loadBackofficeContext();
  if (!context) {
    redirect("/login?next=/backoffice");
  }
  if (context.mustReset) {
    redirect("/backoffice/reset-password");
  }
  redirect(context.sections[0]?.path || "/dashboard");
}
