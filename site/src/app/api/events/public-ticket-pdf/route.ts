import { NextResponse } from "next/server";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";
import { buildReceiptPdf } from "@/lib/pdf/build-receipt-pdf";

export async function GET(request: Request) {
  const ticketCode = new URL(request.url).searchParams.get("ticket");
  if (!ticketCode) return NextResponse.json({ message: "ticket manquant." }, { status: 400 });

  const admin = createSupabaseAdminClient();
  const { data } = await admin
    .from("event_public_tickets")
    .select("ticket_code, qr_code, amount_paid, full_name, email, phone, events(title)")
    .eq("ticket_code", ticketCode)
    .single();

  if (!data) return NextResponse.json({ message: "Reçu introuvable." }, { status: 404 });

  const pdf = await buildReceiptPdf(
    "EduQuest - Reçu Visiteur",
    "Facture ticket événement (site vitrine)",
    [
      ["Nom", data.full_name || "-"],
      ["Email", data.email || "-"],
      ["Téléphone", data.phone || "-"],
      ["Classe", "Visiteur"],
      ["Pays", "-"],
      ["Événement", (data.events as { title?: string } | null)?.title || "-"],
      ["Code", data.ticket_code],
      ["Montant", `${Number(data.amount_paid || 0)} XOF`],
    ],
    data.qr_code || data.ticket_code,
  );

  return new NextResponse(Buffer.from(pdf), {
    headers: {
      "Content-Type": "application/pdf",
      "Content-Disposition": `attachment; filename=eduquest-public-${data.ticket_code}.pdf`,
    },
  });
}
