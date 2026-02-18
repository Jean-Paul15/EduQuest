import { NextResponse } from "next/server";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";
import { claimIdempotency, storeIdempotencyResult } from "@/lib/security/idempotency";
const isUuid = (v: string) =>
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
    .test(v);

export async function POST(request: Request) {
  const secret = process.env.PAYMENT_WEBHOOK_SECRET;
  if (!secret || request.headers.get("x-payment-secret") !== secret) {
    return NextResponse.json({ message: "Unauthorized" }, { status: 401 });
  }

  const body = (await request.json()) as { eventId?: string; profileId?: string; idempotencyKey?: string };
  if (!body.eventId || !body.profileId) {
    return NextResponse.json({ message: "Payload invalide." }, { status: 400 });
  }
  if (!isUuid(body.eventId) || !isUuid(body.profileId)) {
    return NextResponse.json({ message: "IDs invalides." }, { status: 400 });
  }
  const key = body.idempotencyKey ?? request.headers.get("x-idempotency-key") ?? `event:${body.eventId}:profile:${body.profileId}`;
  const claim = await claimIdempotency(
    "api:webhook:event:confirm",
    key,
    body.profileId,
    `${body.eventId}:${body.profileId}`,
  );
  if (claim.mode === "conflict") return NextResponse.json({ message: "Conflit idempotence." }, { status: 409 });
  if (claim.mode === "replay") return NextResponse.json(claim.responseBody ?? { success: true }, { status: claim.statusCode ?? 200 });
  if (claim.mode === "inflight") return NextResponse.json({ message: "Traitement déjà en cours." }, { status: 409 });

  try {
    const admin = createSupabaseAdminClient();
    const { data, error } = await admin.rpc("confirm_event_payment", {
      p_event_id: body.eventId,
      p_profile_id: body.profileId,
    });
    if (error) {
      const out = { message: error.message };
      await storeIdempotencyResult(claim.rowId, 400, out);
      return NextResponse.json(out, { status: 400 });
    }
    const out = data ?? { success: true };
    await storeIdempotencyResult(claim.rowId, 200, out);
    return NextResponse.json(out);
  } catch (error) {
    const out = { message: String(error) };
    await storeIdempotencyResult(claim.rowId, 500, out);
    return NextResponse.json(out, { status: 500 });
  }
}
