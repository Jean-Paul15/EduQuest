import { NextResponse } from "next/server";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { buildReceiptPdf } from "@/lib/pdf/build-receipt-pdf";

export async function GET(request: Request) {
  const code = new URL(request.url).searchParams.get("code");
  if (!code) return NextResponse.json({ message: "Code manquant." }, { status: 400 });

  const supabase = await createSupabaseServerClient();
  const { data: auth } = await supabase.auth.getUser();
  if (!auth.user) return NextResponse.json({ message: "Session requise." }, { status: 401 });

  const { data: ticket } = await supabase
    .from("ticket_codes")
    .select("code, activated_at, expires_at, ticket_products(code, label, ticket_type, duration_days)")
    .eq("code", code)
    .eq("activated_by", auth.user.id)
    .single();

  if (!ticket) return NextResponse.json({ message: "Code introuvable." }, { status: 404 });
  const product = Array.isArray(ticket.ticket_products) ? ticket.ticket_products[0] : ticket.ticket_products;
  const [profileRes, orderRes] = await Promise.all([
    supabase.from("profiles").select("full_name, whatsapp_phone, country_id, education_level_id").eq("id", auth.user.id).single(),
    supabase.from("ticket_checkout_orders").select("total_price").eq("activation_code", ticket.code).maybeSingle(),
  ]);
  const profile = profileRes.data;
  const [countryRes, levelRes] = await Promise.all([
    profile?.country_id ? supabase.from("countries").select("name, code").eq("id", profile.country_id).maybeSingle() : Promise.resolve({ data: null }),
    profile?.education_level_id ? supabase.from("education_levels").select("label, code").eq("id", profile.education_level_id).maybeSingle() : Promise.resolve({ data: null }),
  ]);
  const price = Number(orderRes.data?.total_price ?? 0);
  const pdf = await buildReceiptPdf(
    "EduQuest - Reçu d'activation",
    "Facture ticket / code d'activation",
    [
      ["Nom", profile?.full_name || "-"],
      ["Email", auth.user.email || "-"],
      ["Téléphone", profile?.whatsapp_phone || "-"],
      ["Classe", levelRes.data?.label || levelRes.data?.code || "-"],
      ["Pays", countryRes.data?.name || countryRes.data?.code || "-"],
      ["Produit", product?.label || product?.code || "-"],
      ["Type ticket", product?.ticket_type || "-"],
      ["Durée", `${Number(product?.duration_days || 0)} jours`],
      ["Code d'activation", ticket.code],
      ["Activé le", String(ticket.activated_at || "-")],
      ["Expire le", String(ticket.expires_at || "-")],
      ["Montant payé", `${price} XOF`],
    ],
    ticket.code,
  );
  return new NextResponse(Buffer.from(pdf), {
    headers: {
      "Content-Type": "application/pdf",
      "Content-Disposition": `attachment; filename=eduquest-activation-${ticket.code}.pdf`,
    },
  });
}
