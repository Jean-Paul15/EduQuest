import type { Metadata } from "next";
import { Inter, Sora } from "next/font/google";
import { Analytics } from "@vercel/analytics/next";
import { SiteHeader } from "@/components/site-header";
import { LoadingProvider } from "@/components/providers/loading-provider";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import "./globals.css";

const inter = Inter({ subsets: ["latin"], variable: "--font-body" });
const sora = Sora({ subsets: ["latin"], variable: "--font-display", weight: ["400", "600", "700", "800"] });

export const metadata: Metadata = {
  title: "RuachEdu — Ta réussite, ton combat",
  description: "Cours structurés, exercices corrigés, QCM, examens blancs — la plateforme éducative qui te prépare aux examens.",
};

export default async function RootLayout({ children }: { children: React.ReactNode }) {
  const supabase = await createSupabaseServerClient();
  const { data } = await supabase.auth.getUser();

  return (
    <html lang="fr" suppressHydrationWarning>
      <body className={`${inter.variable} ${sora.variable} min-h-screen bg-[var(--eq-bg)] text-[var(--eq-text)]`}>
        <LoadingProvider>
          <SiteHeader email={data.user?.email} />
          {children}
          <Analytics />
        </LoadingProvider>
      </body>
    </html>
  );
}
