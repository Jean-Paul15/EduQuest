import { LoginClient } from "@/components/login-client";

type Props = { searchParams: Promise<{ next?: string; error?: string }> };

export default async function LoginPage({ searchParams }: Props) {
  const params = await searchParams;
  const nextPath = params.next?.startsWith("/") ? params.next : "/dashboard";

  return (
    <main className="mx-auto flex min-h-[80vh] max-w-4xl items-center px-4 py-10">
      <div className="grid w-full gap-10 md:grid-cols-2 md:items-center">
        <section className="space-y-4">
          <h1 className="text-3xl sm:text-4xl font-extrabold tracking-tight text-slate-900">
            Bienvenue sur{" "}
            <span className="gradient-text">EduQuest</span>
          </h1>
          <p className="text-body">
            Connectez-vous pour gérer vos tickets, participer aux concours et accéder à votre tableau de bord personnel.
          </p>
          <div className="flex items-center gap-3 pt-2">
            <div className="w-10 h-10 rounded-xl bg-blue-50 flex items-center justify-center text-blue-600 text-lg font-bold">1</div>
            <p className="text-sm text-slate-600">Connexion rapide et sécurisée</p>
          </div>
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-orange-50 flex items-center justify-center text-orange-600 text-lg font-bold">2</div>
            <p className="text-sm text-slate-600">Achetez ou activez votre code</p>
          </div>
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-emerald-50 flex items-center justify-center text-emerald-600 text-lg font-bold">3</div>
            <p className="text-sm text-slate-600">Commencez à progresser</p>
          </div>
        </section>
        <LoginClient nextPath={nextPath} error={params.error} />
      </div>
    </main>
  );
}
