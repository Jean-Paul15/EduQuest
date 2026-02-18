import { redirect } from "next/navigation";
import { BackofficeResetPasswordForm } from "@/components/backoffice/backoffice-reset-password-form";
import { loadBackofficeContext } from "@/lib/data/backoffice-server";

export default async function BackofficeResetPasswordPage() {
  const context = await loadBackofficeContext();
  if (!context) redirect("/login?next=/backoffice/reset-password");
  if (!context.mustReset) redirect("/backoffice");

  return (
    <main className="mx-auto max-w-xl space-y-3 px-4 py-10">
      <h1 className="text-2xl font-semibold text-slate-900">Modification obligatoire du mot de passe</h1>
      <p className="text-sm text-slate-600">Première connexion: change ton mot de passe avant ’ccéder au backoffice.</p>
      <BackofficeResetPasswordForm />
    </main>
  );
}
