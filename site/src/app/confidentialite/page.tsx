import Link from "next/link";
import ReactMarkdown, { type Components } from "react-markdown";
import remarkGfm from "remark-gfm";
import { ArrowLeft } from "lucide-react";
import { getActiveLegalDocument } from "@/lib/data/legal";
import { getViewerContext } from "@/lib/data/profile";
import { SupportDeleteForm } from "@/components/support-delete-form";
import { formatDate } from "@/lib/format";

// react-markdown passe un prop `node` (AST) a chaque composant : a exclure
// avant de spreader le reste sur l'element DOM, sinon React le rend en
// attribut litteral `node="[object Object]"`. La destructuration `node`
// est donc volontairement inutilisee ci-dessous.
/* eslint-disable @typescript-eslint/no-unused-vars */
const markdownComponents: Components = {
  h1: ({ node, ...props }) => <h1 className="text-2xl font-extrabold tracking-tight mt-8 first:mt-0" {...props} />,
  h2: ({ node, ...props }) => <h2 className="text-xl font-bold tracking-tight mt-8" {...props} />,
  h3: ({ node, ...props }) => <h3 className="text-lg font-semibold mt-6" {...props} />,
  p: ({ node, ...props }) => <p className="text-[15px] leading-relaxed text-slate-600 mt-3" {...props} />,
  ul: ({ node, ...props }) => <ul className="list-disc pl-5 space-y-1.5 text-[15px] leading-relaxed text-slate-600 mt-3" {...props} />,
  ol: ({ node, ...props }) => <ol className="list-decimal pl-5 space-y-1.5 text-[15px] leading-relaxed text-slate-600 mt-3" {...props} />,
  strong: ({ node, ...props }) => <strong className="font-semibold text-slate-900" {...props} />,
  a: ({ node, ...props }) => <a className="text-[#C89A5A] underline underline-offset-2 hover:text-[#A07838]" {...props} />,
};
/* eslint-enable @typescript-eslint/no-unused-vars */

export default async function ConfidentialitePage() {
  const [doc, viewer] = await Promise.all([
    getActiveLegalDocument("privacy"),
    getViewerContext(),
  ]);

  return (
    <main className="mx-auto max-w-3xl px-4 py-10 space-y-6">
      <section className="rounded-2xl border border-slate-200 bg-white p-6 sm:p-8">
        <h1 className="text-2xl sm:text-3xl font-extrabold tracking-tight">
          {doc?.title ?? "Politique de confidentialité"}
        </h1>
        {doc ? (
          <p className="text-xs text-slate-400 mt-1">
            Version {doc.version}
            {doc.published_at ? ` · publiée le ${formatDate(doc.published_at)}` : ""}
          </p>
        ) : null}

        {doc ? (
          <div className="mt-4">
            <ReactMarkdown remarkPlugins={[remarkGfm]} components={markdownComponents}>
              {doc.body_md}
            </ReactMarkdown>
          </div>
        ) : (
          <p className="text-[15px] text-slate-500 mt-4">
            La politique de confidentialité n&apos;est pas disponible pour le moment.
          </p>
        )}
      </section>

      <SupportDeleteForm logged={!!viewer.user} />

      <Link href="/" className="btn-secondary inline-flex !text-sm">
        <ArrowLeft className="w-4 h-4" /> Retour à l&apos;accueil
      </Link>
    </main>
  );
}
