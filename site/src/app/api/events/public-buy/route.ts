import { NextResponse } from "next/server";
import { z } from "zod";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { claimIdempotency, storeIdempotencyResult } from "@/lib/security/idempotency";

const schema = z.object({
  eventId: z.string().uuid(),
  firstName: z.string().min(2),
  lastName: z.string().min(2),
  email: z.string().email(),
  phone: z.string().min(8),
  idempotencyKey: z.string().optional(),
});

export async function POST(request: Request) {
  const parsed = schema.safeParse(await request.json());
  if (!parsed.success) return NextResponse.json({ message: "Informations invalides." }, { status: 400 });

  const p = parsed.data;
  const supabase = await createSupabaseServerClient();
  const key = p.idempotencyKey ?? request.headers.get("x-idempotency-key");
  const claim = await claimIdempotency(
    "api:events:public-buy",
    key,
    null,
    `${p.eventId}:${p.email}:${p.phone}`,
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
  const { data, error } = await supabase.rpc("buy_public_event_ticket", {
    p_event_id: p.eventId,
    p_first_name: p.firstName,
    p_last_name: p.lastName,
    p_email: p.email,
    p_phone: p.phone,
  });

  if (error) {
    const out = { message: error.message };
    await storeIdempotencyResult(claim.rowId, 400, out);
    return NextResponse.json(out, { status: 400 });
  }
  const out = {
    success: true,
    message: data?.message || "Ticket créé.",
    ticketCode: data?.ticket_code,
    qrCode: data?.qr_code,
    amount: Number(data?.amount_paid || 0),
  };
  await storeIdempotencyResult(claim.rowId, 200, out);
  return NextResponse.json(out);
}
