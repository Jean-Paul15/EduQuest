import { NextResponse } from "next/server";
import { z } from "zod";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { claimIdempotency, storeIdempotencyResult } from "@/lib/security/idempotency";

const publicSchema = z.object({
  fullName: z.string().min(2),
  email: z.string().email(),
  phone: z.string().optional().default(""),
  reason: z.string().optional().default(""),
});

export async function POST(request: Request) {
  const body = await request.json();
  const supabase = await createSupabaseServerClient();
  const { data: auth } = await supabase.auth.getUser();
  const key = body?.idempotencyKey ?? request.headers.get("x-idempotency-key");

  if (auth.user) {
    const claim = await claimIdempotency(
      "api:support:delete-request:auth",
      key,
      auth.user.id,
      `${auth.user.id}:${body?.reason ?? ""}`,
    );
    if (claim.mode === "conflict") {
      return NextResponse.json({ message: "Idempotency key invalide pour cette action." }, { status: 409 });
    }
    if (claim.mode === "replay") {
      return NextResponse.json(claim.responseBody ?? { message: "Déjà traité." }, { status: claim.statusCode ?? 200 });
    }
    if (claim.mode === "inflight") {
      return NextResponse.json({ message: "Requête déjà en cours." }, { status: 409 });
    }
    const reason = typeof body?.reason === "string" ? body.reason : "";
    const { data, error } = await supabase.rpc("request_data_deletion", {
      p_reason: reason,
    });
    if (error) {
      const out = { message: error.message };
      await storeIdempotencyResult(claim.rowId, 400, out);
      return NextResponse.json(out, { status: 400 });
    }
    const out = { success: true, message: data?.message || "Demande envoyée." };
    await storeIdempotencyResult(claim.rowId, 200, out);
    return NextResponse.json(out);
  }

  const parsed = publicSchema.safeParse(body);
  if (!parsed.success) {
    return NextResponse.json({ message: "Informations invalides." }, { status: 400 });
  }

  const p = parsed.data;
  const claim = await claimIdempotency(
    "api:support:delete-request:public",
    key,
    null,
    `${p.email}:${p.phone}:${p.reason}`,
  );
  if (claim.mode === "conflict") {
    return NextResponse.json({ message: "Idempotency key invalide pour cette action." }, { status: 409 });
  }
  if (claim.mode === "replay") {
    return NextResponse.json(claim.responseBody ?? { message: "Déjà traité." }, { status: claim.statusCode ?? 200 });
  }
  if (claim.mode === "inflight") {
    return NextResponse.json({ message: "Requête déjà en cours." }, { status: 409 });
  }
  const { data, error } = await supabase.rpc("request_data_deletion_public", {
    p_full_name: p.fullName,
    p_email: p.email,
    p_phone: p.phone,
    p_reason: p.reason,
  });

  if (error) {
    const out = { message: error.message };
    await storeIdempotencyResult(claim.rowId, 400, out);
    return NextResponse.json(out, { status: 400 });
  }
  const out = { success: true, message: data?.message || "Demande envoyée." };
  await storeIdempotencyResult(claim.rowId, 200, out);
  return NextResponse.json(out);
}
