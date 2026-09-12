import { NextResponse } from "next/server";
import { recordServerEvent } from "@/lib/analytics/server";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { claimIdempotency, storeIdempotencyResult } from "@/lib/security/idempotency";
import { joinContestRpc } from "@/lib/data/join-contest-rpc";

type Payload = {
  kind?: "event" | "contest" | "ticket";
  id?: string;
  idempotencyKey?: string;
};
const isUuid = (v: string) =>
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
    .test(v);

export async function POST(request: Request) {
  const body = (await request.json()) as Payload;
  if (!body.kind || !body.id) return NextResponse.json({ message: "Payload invalide." }, { status: 400 });
  if (!isUuid(body.id)) return NextResponse.json({ message: "ID invalide." }, { status: 400 });

  const supabase = await createSupabaseServerClient();
  const { data: auth } = await supabase.auth.getUser();
  if (!auth.user) return NextResponse.json({ message: "Session requise." }, { status: 401 });
  const key = body.idempotencyKey ?? request.headers.get("x-idempotency-key");
  const claim = await claimIdempotency(
    "api:payments:complete",
    key,
    auth.user.id,
    `${body.kind}:${body.id}:${auth.user.id}`,
  );
  if (claim.mode === "conflict") {
    return NextResponse.json({ message: "Idempotency key déjà utilisé avec une autre requête." }, { status: 409 });
  }
  if (claim.mode === "replay") {
    return NextResponse.json(claim.responseBody ?? { message: "Déjà traité." }, { status: claim.statusCode ?? 200 });
  }
  if (claim.mode === "inflight") {
    return NextResponse.json({ message: "Requête en cours, réessaie dans quelques secondes." }, { status: 409 });
  }

  try {
    const admin = createSupabaseAdminClient();
    if (body.kind === "event") {
      const joined = await supabase.rpc("join_event", { p_event_id: body.id });
      if (joined.error) {
        const out = { message: joined.error.message };
        await recordServerEvent({ name: "payment_failed", profileId: auth.user.id, category: "payment", payload: { kind: body.kind, id: body.id, reason: "join_event" } });
        await storeIdempotencyResult(claim.rowId, 400, out);
        return NextResponse.json(out, { status: 400 });
      }
      const needsPayment = joined.data?.requires_payment === true || Number(joined.data?.fee_due || 0) > 0;
      if (!needsPayment) {
        const out = {
          success: true,
          message: joined.data?.message ?? "Inscription validée.",
          passCode: joined.data?.pass_code ?? null,
          qrCode: joined.data?.pass_code ?? null,
        };
        await recordServerEvent({ name: "payment_confirmed", profileId: auth.user.id, category: "payment", payload: { kind: body.kind, id: body.id, mode: "free" } });
        await storeIdempotencyResult(claim.rowId, 200, out);
        return NextResponse.json(out);
      }
      const confirmed = await admin.rpc("confirm_event_payment", { p_event_id: body.id, p_profile_id: auth.user.id });
      if (confirmed.error) {
        const out = { message: confirmed.error.message };
        await recordServerEvent({ name: "payment_failed", profileId: auth.user.id, category: "payment", payload: { kind: body.kind, id: body.id, reason: "confirm_event" } });
        await storeIdempotencyResult(claim.rowId, 400, out);
        return NextResponse.json(out, { status: 400 });
      }
      const out = {
        success: true,
        message: "Paiement validé.",
        passCode: confirmed.data?.pass_code ?? joined.data?.pass_code ?? null,
        qrCode: confirmed.data?.pass_code ?? joined.data?.pass_code ?? null,
      };
      await recordServerEvent({ name: "payment_confirmed", profileId: auth.user.id, category: "payment", payload: { kind: body.kind, id: body.id, mode: "paid" } });
      await storeIdempotencyResult(claim.rowId, 200, out);
      return NextResponse.json(out);
    }

    if (body.kind === "contest") {
      const joined = await joinContestRpc(supabase, body.id);
      if (joined.error) {
        const out = { message: joined.error };
        await recordServerEvent({ name: "payment_failed", profileId: auth.user.id, category: "payment", payload: { kind: body.kind, id: body.id, reason: "join_contest" } });
        await storeIdempotencyResult(claim.rowId, 400, out);
        return NextResponse.json(out, { status: 400 });
      }
      const needsPayment = joined.data?.requires_payment === true || Number(joined.data?.fee_due || 0) > 0;
      if (!needsPayment) {
        const out = {
          success: true,
          message: joined.data?.message ?? "Inscription validée.",
          qrCode: joined.data?.qr_code ?? null,
        };
        await recordServerEvent({ name: "payment_confirmed", profileId: auth.user.id, category: "payment", payload: { kind: body.kind, id: body.id, mode: "free" } });
        await storeIdempotencyResult(claim.rowId, 200, out);
        return NextResponse.json(out);
      }
      const confirmed = await admin.rpc("confirm_contest_payment", { p_contest_id: body.id, p_profile_id: auth.user.id });
      if (confirmed.error) {
        const out = { message: confirmed.error.message };
        await recordServerEvent({ name: "payment_failed", profileId: auth.user.id, category: "payment", payload: { kind: body.kind, id: body.id, reason: "confirm_contest" } });
        await storeIdempotencyResult(claim.rowId, 400, out);
        return NextResponse.json(out, { status: 400 });
      }
      const out = {
        success: true,
        message: "Paiement validé.",
        qrCode: confirmed.data?.qr_code ?? joined.data?.qr_code ?? null,
      };
      await recordServerEvent({ name: "payment_confirmed", profileId: auth.user.id, category: "payment", payload: { kind: body.kind, id: body.id, mode: "paid" } });
      await storeIdempotencyResult(claim.rowId, 200, out);
      return NextResponse.json(out);
    }

    const { data, error } = await admin.rpc("confirm_ticket_checkout_flexible", {
      p_product_id: body.id,
      p_profile_id: auth.user.id,
      p_idempotency_key: String(claim.rowId),
    });
    if (error) {
      const out = { message: error.message };
      await recordServerEvent({ name: "payment_failed", profileId: auth.user.id, category: "payment", payload: { kind: body.kind, id: body.id, reason: "confirm_ticket" } });
      await storeIdempotencyResult(claim.rowId, 400, out);
      return NextResponse.json(out, { status: 400 });
    }
    const out = {
      success: true,
      message: "Code d'activation généré.",
      activationCode: data?.activation_code ?? null,
      expiresAt: data?.expires_at ?? null,
    };
    await recordServerEvent({ name: "payment_confirmed", profileId: auth.user.id, category: "payment", payload: { kind: body.kind, id: body.id, mode: "ticket" } });
    await storeIdempotencyResult(claim.rowId, 200, out);
    return NextResponse.json(out);
  } catch (error) {
    const out = { message: String(error) };
    await recordServerEvent({ name: "payment_failed", profileId: auth.user.id, category: "payment", payload: { kind: body.kind, id: body.id, reason: "unexpected" } });
    await storeIdempotencyResult(claim.rowId, 500, out);
    return NextResponse.json(out, { status: 500 });
  }
}
