import { redirect } from "next/navigation";
import { loadBackofficeContext } from "@/lib/data/backoffice-server";

export const requireBackofficeSection = async (path: string) => {
  const context = await loadBackofficeContext();
  if (!context) redirect(`/login?next=${encodeURIComponent(path)}`);
  if (context.mustReset) redirect("/backoffice/reset-password");
  const allowed = context.sections.some((s) => s.path === path);
  if (!allowed) redirect(context.sections[0]?.path || "/backoffice");
  return context;
};
