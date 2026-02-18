import { NextResponse } from "next/server";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { claimIdempotency, storeIdempotencyResult } from "@/lib/security/idempotency";
import { joinContestRpc } from "@/lib/data/join-contest-rpc";

type Payload = { contestId?: string; idempotencyKey?: string };
const isUuid = (v: string) =>
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
    .test(v);

export async function POST(request: Request) {
  const body = (await request.json()) as Payload;
  if (!body.contestId) {
    return NextResponse.json({ message: "Concours invalide." }, { status: 400 });
  }
  if (!isUuid(body.contestId)) {
    return NextResponse.json({ message: "ID concours invalide." }, { status: 400 });
  }

  const supabase = await createSupabaseServerClient();
  const { data: auth } = await supabase.auth.getUser();
  if (!auth.user) return NextResponse.json({ message: "Session requise." }, { status: 401 });
  const key = body.idempotencyKey ?? request.headers.get("x-idempotency-key");
  const claim = await claimIdempotency(
    "api:contests:join",
    key,
    auth.user.id,
    `${body.contestId}:${auth.user.id}`,
  );
  if (claim.mode === "conflict") {
    return NextResponse.json({ message: "Idempotency key invalide pour cette action." }, { status: 409 });
  }
  if (claim.mode === "replay") {
    return NextResponse.json(claim.responseBody ?? { message: "Déjà traité." }, { status: claim.statusCode ?? 200 });
  }
  if (claim.mode === "inflight") {
    return NextResponse.json({ message: "Postulation déjà en cours." }, { status: 409 });
  }
  const { data, error } = await joinContestRpc(supabase, body.contestId);

  if (error) {
    const out = { message: error };
    await storeIdempotencyResult(claim.rowId, 400, out);
    return NextResponse.json(out, { status: 400 });
  }

  const out = {
    message: data?.message ?? "Postulation enregistrée.",
    paymentUrl: data?.requires_payment ? data?.payment_url : null,
    feeDue: data?.fee_due ?? 0,
    status: data?.status ?? null,
    qrCode: data?.qr_code ?? null,
  };
  await storeIdempotencyResult(claim.rowId, 200, out);
  return NextResponse.json(out);
}
