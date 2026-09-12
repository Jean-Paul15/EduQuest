import { NextResponse } from "next/server";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { isSiteAnalyticsEvent } from "@/lib/analytics/events";
import { recordServerEvent } from "@/lib/analytics/server";

export async function POST(request: Request) {
  try {
    const body = await request.json() as {
      name?: string;
      category?: string;
      payload?: Record<string, unknown>;
    };
    if (!body.name || !isSiteAnalyticsEvent(body.name)) {
      return NextResponse.json({ message: "Event invalide." }, { status: 400 });
    }
    const supabase = await createSupabaseServerClient();
    const { data } = await supabase.auth.getUser();
    await recordServerEvent({
      name: body.name,
      profileId: data.user?.id ?? null,
      category: body.category,
      payload: body.payload,
      source: "site-client",
    });
    return NextResponse.json({ success: true });
  } catch {
    return NextResponse.json({ success: false }, { status: 200 });
  }
}
