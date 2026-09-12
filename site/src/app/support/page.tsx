import { Mail, MessageCircle, ArrowLeft } from "lucide-react";
import { env } from "@/lib/env";
import { SupportDeleteForm } from "@/components/support-delete-form";
import { getViewerContext } from "@/lib/data/profile";
import { normalizeAppReturnUrl } from "@/lib/app-return";
import { createSupabaseServerClient } from "@/lib/supabase/server";

type Props = { searchParams: Promise<{ next?: string }> };

export default async function SupportPage({ searchParams }: Props) {
  const viewer = await getViewerContext();
  const supabase = await createSupabaseServerClient();
  const linksResult = await supabase
    .from("app_config")
    .select("value")
    .eq("key", "app_links")
    .maybeSingle();
  const params = await searchParams;
  const returnUrl = normalizeAppReturnUrl(params.next, env.appDeepLink);
  const supportUrl =
    ((linksResult.data?.value as Record<string, unknown> | null)?.support_url
      ?.toString()
      .trim() || env.supportWhatsApp);

  return (
    <main className="mx-auto max-w-4xl px-4 py-10 space-y-6">
      <section className="rounded-2xl border border-slate-200 bg-white p-6 space-y-2">
        <h1 className="text-2xl sm:text-3xl font-extrabold tracking-tight">Support EduQuest</h1>
        <p className="text-sm text-slate-500">
          Assistance tickets, partenariats écoles, questions techniques — nous sommes là pour vous aider.
        </p>
      </section>

      <section className="grid gap-4 sm:grid-cols-2">
        <a href={`mailto:${env.supportEmail}`} className="group rounded-2xl border border-slate-200 bg-white p-5 transition hover:shadow-md hover:border-blue-200">
          <div className="w-10 h-10 rounded-xl bg-blue-50 flex items-center justify-center text-blue-600 mb-3 group-hover:bg-blue-100 transition-colors">
            <Mail className="w-5 h-5" />
          </div>
          <p className="text-xs font-bold text-slate-400 uppercase tracking-wider">Email</p>
          <p className="font-semibold text-slate-900 mt-0.5">{env.supportEmail}</p>
        </a>
        <a href={supportUrl} target="_blank" rel="noopener noreferrer" className="group rounded-2xl border border-slate-200 bg-white p-5 transition hover:shadow-md hover:border-emerald-200">
          <div className="w-10 h-10 rounded-xl bg-emerald-50 flex items-center justify-center text-emerald-600 mb-3 group-hover:bg-emerald-100 transition-colors">
            <MessageCircle className="w-5 h-5" />
          </div>
          <p className="text-xs font-bold text-slate-400 uppercase tracking-wider">WhatsApp</p>
          <p className="font-semibold text-slate-900 mt-0.5">Contacter l&apos;équipe</p>
        </a>
      </section>

      <SupportDeleteForm logged={!!viewer.user} />

      <a href={returnUrl} className="btn-secondary inline-flex !text-sm">
        <ArrowLeft className="w-4 h-4" /> Retourner dans l&apos;application
      </a>
    </main>
  );
}
