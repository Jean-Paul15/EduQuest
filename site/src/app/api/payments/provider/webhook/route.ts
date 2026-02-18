import { NextResponse } from "next/server";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";
import { claimIdempotency, storeIdempotencyResult } from "@/lib/security/idempotency";
import { hashPayload, parseTs, verifyWebhookSignature } from "@/lib/security/webhook-signature";

const isUuid = (v: string) => /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(v);

export async function POST(request: Request) {
  const admin = createSupabaseAdminClient();
  const cfgRes = await admin.from("app_config").select("value").eq("key", "payment_provider_config").maybeSingle();
  const cfg = (cfgRes.data?.value as Record<string, unknown>) || {};
  const sigHeader = String(cfg.signature_header || "x-payment-signature");
  const tsHeader = String(cfg.timestamp_header || "x-payment-timestamp");
  const eventField = String(cfg.event_id_field || "event_id");
  const tolerance = Number(cfg.webhook_tolerance_sec || 300);
  const provider = String(cfg.provider || "generic");
  const secret = process.env.PAYMENT_PROVIDER_WEBHOOK_SECRET || "";

  const raw = await request.text();
  const payload = JSON.parse(raw || "{}") as Record<string, unknown>;
  const ts = parseTs(request.headers.get(tsHeader));
  const sig = request.headers.get(sigHeader) || "";
  const eventId = String(payload[eventField] || payload.event_id || "");
  if (!eventId) return NextResponse.json({ message: "event_id manquant." }, { status: 400 });
  const okSig = verifyWebhookSignature(raw, ts, sig, secret, tolerance);
  if (!okSig) return NextResponse.json({ message: "Signature invalide." }, { status: 401 });

  const idem = await claimIdempotency("api:webhook:provider", eventId, null, `${provider}:${eventId}`);
  if (idem.mode === "replay") return NextResponse.json(idem.responseBody ?? { success: true }, { status: idem.statusCode ?? 200 });
  if (idem.mode === "conflict" || idem.mode === "inflight") return NextResponse.json({ message: "Webhook déjà traité." }, { status: 409 });

  await admin.from("payment_webhook_events").upsert({ provider, event_id: eventId, signature: sig, payload_hash: hashPayload(raw, secret), status: "received" });
  const kind = String(payload.kind || ""); const targetId = String(payload.target_id || ""); const profileId = String(payload.profile_id || "");
  if (!["event", "contest", "ticket"].includes(kind) || (kind !== "ticket" && (!isUuid(targetId) || !isUuid(profileId)))) {
    await admin.from("payment_webhook_events").update({ status: "rejected", error_text: "payload_invalid", processed_at: new Date().toISOString() }).eq("provider", provider).eq("event_id", eventId);
    const out = { message: "Payload invalide." }; await storeIdempotencyResult(idem.rowId, 400, out); return NextResponse.json(out, { status: 400 });
  }

  try {
    const out = kind === "event"
      ? await admin.rpc("confirm_event_payment", { p_event_id: targetId, p_profile_id: profileId })
      : kind === "contest"
      ? await admin.rpc("confirm_contest_payment", { p_contest_id: targetId, p_profile_id: profileId })
      : await admin.rpc("confirm_ticket_checkout", { p_product_id: targetId, p_profile_id: profileId || null });
    if (out.error) throw new Error(out.error.message);
    await admin.from("payment_webhook_events").update({ status: "processed", processed_at: new Date().toISOString() }).eq("provider", provider).eq("event_id", eventId);
    const res = { success: true, data: out.data || {} };
    await storeIdempotencyResult(idem.rowId, 200, res);
    return NextResponse.json(res);
  } catch (e) {
    const err = String(e);
    await admin.from("payment_webhook_events").update({ status: "failed", error_text: err, processed_at: new Date().toISOString() }).eq("provider", provider).eq("event_id", eventId);
    await storeIdempotencyResult(idem.rowId, 500, { message: err });
    return NextResponse.json({ message: err }, { status: 500 });
  }
}
