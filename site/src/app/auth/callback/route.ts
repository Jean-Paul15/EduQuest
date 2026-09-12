import { NextResponse } from "next/server";
import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";
import type { EmailOtpType } from "@supabase/supabase-js";
import { recordServerEvent } from "@/lib/analytics/server";
import { env } from "@/lib/env";

type PendingCookie = {
  name: string;
  value: string;
  options: Record<string, unknown>;
};

export async function GET(request: Request) {
  const url = new URL(request.url);
  const next = url.searchParams.get("next") || "/dashboard";
  const code = url.searchParams.get("code");
  const tokenHash = url.searchParams.get("token_hash");
  const type = url.searchParams.get("type") as EmailOtpType | null;

  const cookieStore = await cookies();
  const pending: PendingCookie[] = [];

  const supabase = createServerClient(
    env.supabaseUrl,
    env.supabasePublishableKey,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(items) {
          items.forEach((c) => pending.push(c as PendingCookie));
        },
      },
    },
  );

  if (code) await supabase.auth.exchangeCodeForSession(code);
  if (tokenHash && type) {
    await supabase.auth.verifyOtp({ token_hash: tokenHash, type });
  }
  const { data: auth } = await supabase.auth.getUser();
  if (auth.user) {
    await recordServerEvent({ name: "login_success", profileId: auth.user.id, category: "auth", payload: { provider: code ? "oauth" : "magiclink" } });
  }

  const response = NextResponse.redirect(new URL(next, url.origin));
  for (const { name, value, options } of pending) {
    response.cookies.set(name, value, options as never);
  }
  return response;
}
