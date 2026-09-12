import { NextResponse } from "next/server";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export async function POST(request: Request) {
  const supabase = await createSupabaseServerClient();
  const { data: auth } = await supabase.auth.getUser();
  if (!auth.user) {
    return NextResponse.json({ message: "Non autorisé." }, { status: 401 });
  }
  const adminCheck = await supabase.rpc("is_backoffice_admin");
  if (adminCheck.data !== true) {
    return NextResponse.json({ message: "Accès refusé." }, { status: 403 });
  }
  const body = (await request.json()) as { campaignId?: string };
  if (!body.campaignId) {
    return NextResponse.json({ message: "Campagne invalide." }, { status: 400 });
  }

  const admin = createSupabaseAdminClient();
  const queued = await admin
    .from("notification_campaigns")
    .update({ status: "queued", queued_at: new Date().toISOString() })
    .eq("id", body.campaignId)
    .select("id")
    .maybeSingle();
  if (queued.error) {
    return NextResponse.json({ message: queued.error.message }, { status: 400 });
  }
  if (!queued.data) {
    return NextResponse.json({ message: "Campagne introuvable." }, { status: 404 });
  }

  const log = await admin
    .from("notification_dispatch_logs")
    .insert({ campaign_id: body.campaignId, status: "queued" });
  if (log.error) {
    return NextResponse.json({ message: log.error.message }, { status: 400 });
  }
  return NextResponse.json({ success: true, message: "Campagne mise en file." });
}
