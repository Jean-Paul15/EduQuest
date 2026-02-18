import { NextResponse } from "next/server";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { buildReceiptPdf } from "@/lib/pdf/build-receipt-pdf";

export async function GET(request: Request) {
  const eventId = new URL(request.url).searchParams.get("eventId");
  if (!eventId) return NextResponse.json({ message: "eventId manquant." }, { status: 400 });

  const supabase = await createSupabaseServerClient();
  const { data: auth } = await supabase.auth.getUser();
  if (!auth.user) return NextResponse.json({ message: "Session requise." }, { status: 401 });

  const [regRes, profileRes] = await Promise.all([
    supabase.from("event_registrations").select("pass_code, attendance_fee, events(title)").eq("event_id", eventId).eq("profile_id", auth.user.id).single(),
    supabase.from("profiles").select("full_name, whatsapp_phone, country_id, education_level_id").eq("id", auth.user.id).single(),
  ]);
  const reg = regRes.data;
  if (!reg || !reg.pass_code) return NextResponse.json({ message: "Ticket événement introuvable." }, { status: 404 });
  const profile = profileRes.data;
  const [countryRes, levelRes] = await Promise.all([
    profile?.country_id ? supabase.from("countries").select("name, code").eq("id", profile.country_id).maybeSingle() : Promise.resolve({ data: null }),
    profile?.education_level_id ? supabase.from("education_levels").select("label, code").eq("id", profile.education_level_id).maybeSingle() : Promise.resolve({ data: null }),
  ]);

  const pdf = await buildReceiptPdf(
    "EduQuest - Ticket Événement",
    "Facture / reçu officiel",
    [
      ["Nom", profile?.full_name || "-"],
      ["Email", auth.user.email || "-"],
      ["Téléphone", profile?.whatsapp_phone || "-"],
      ["Classe", levelRes.data?.label || levelRes.data?.code || "-"],
      ["Pays", countryRes.data?.name || countryRes.data?.code || "-"],
      ["Événement", (reg.events as { title?: string } | null)?.title || "-"],
      ["Code", reg.pass_code],
      ["Montant", `${Number(reg.attendance_fee || 0)} XOF`],
    ],
    reg.pass_code,
  );

  return new NextResponse(Buffer.from(pdf), {
    headers: {
      "Content-Type": "application/pdf",
      "Content-Disposition": `attachment; filename=eduquest-event-${reg.pass_code}.pdf`,
    },
  });
}
