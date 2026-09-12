import { NextResponse } from "next/server";
import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";
import { recordServerEvent } from "@/lib/analytics/server";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";
import { env } from "@/lib/env";

type PendingCookie = {
  name: string;
  value: string;
  options: Record<string, unknown>;
};

const normalizeBase = (value?: string | null) => {
  const raw = String(value || "").trim();
  if (!raw.startsWith("http://") && !raw.startsWith("https://")) return "";
  return raw.endsWith("/") ? raw.slice(0, -1) : raw;
};
const isLoopbackBase = (v: string) => /:\/\/(localhost|127\.0\.0\.1)(:|\/|$)/i.test(v);

export async function GET(request: Request) {
  const url = new URL(request.url);
  const token = url.searchParams.get("token");
  let siteBase = normalizeBase(url.origin) || normalizeBase(env.siteUrl) || "";
  const fallbackErrorUrl = new URL("/login?error=handoff", siteBase);
  await recordServerEvent({ name: "app_handoff_attempted", category: "session", payload: { hasToken: !!token } });

  if (!token) {
    await recordServerEvent({ name: "app_handoff_failed", category: "session", payload: { reason: "missing_token" } });
    return NextResponse.redirect(fallbackErrorUrl);
  }

  try {
    const admin = createSupabaseAdminClient();
    try {
      const cfg = await admin
        .from("app_config")
        .select("value")
        .eq("key", "app_links")
        .maybeSingle();
      const fromDb = normalizeBase(cfg.data?.value?.site_base_url);
      if (fromDb && !(isLoopbackBase(fromDb) && !isLoopbackBase(siteBase))) {
        siteBase = fromDb;
      }
    } catch {
      // keep env/request fallback
    }
    const errorUrl = new URL("/login?error=handoff", siteBase);

    const { data, error } = await admin.rpc("consume_web_session_handoff", {
      p_token: token,
    });

    if (error || !data?.email) {
      await recordServerEvent({ name: "app_handoff_failed", category: "session", payload: { reason: "consume_failed" } });
      return NextResponse.redirect(errorUrl);
    }

    const rawPath = String(data.next_path || "/dashboard");
    const nextPath =
      rawPath.startsWith("/") && !rawPath.startsWith("//")
        ? rawPath
        : "/dashboard";

    const link = await admin.auth.admin.generateLink({
      type: "magiclink",
      email: String(data.email),
    });

    const hashedToken = link.data?.properties?.hashed_token;
    if (link.error || !hashedToken) {
      await recordServerEvent({ name: "app_handoff_failed", category: "session", payload: { reason: "magic_link_failed" } });
      return NextResponse.redirect(errorUrl);
    }

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

    const { error: otpError } = await supabase.auth.verifyOtp({
      token_hash: hashedToken,
      type: "email",
    });

    if (otpError) {
      await recordServerEvent({ name: "app_handoff_failed", category: "session", payload: { reason: "otp_failed" } });
      return NextResponse.redirect(errorUrl);
    }

    const response = NextResponse.redirect(new URL(nextPath, siteBase));
    await recordServerEvent({ name: "app_handoff_succeeded", category: "session", payload: { nextPath } });
    for (const { name, value, options } of pending) {
      response.cookies.set(name, value, options as never);
    }
    return response;
  } catch {
    await recordServerEvent({ name: "app_handoff_failed", category: "session", payload: { reason: "unexpected_error" } });
    return NextResponse.redirect(fallbackErrorUrl);
  }
}
