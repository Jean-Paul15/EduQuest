import { createSupabaseServerClient } from "@/lib/supabase/server";
import { joinContestRpc } from "@/lib/data/join-contest-rpc";

export type CheckoutKind = "event" | "contest" | "ticket";

export type CheckoutPreview = {
  success: boolean;
  message: string;
  requiresPayment: boolean;
  feeDue: number;
};

export const prepareCheckout = async (kind: CheckoutKind, id: string) => {
  const supabase = await createSupabaseServerClient();
  if (kind === "event") {
    const { data, error } = await supabase.rpc("join_event", { p_event_id: id });
    if (error) return { success: false, message: error.message, requiresPayment: false, feeDue: 0 };
    return { success: true, message: data?.message || "Événement traité.", requiresPayment: !!data?.requires_payment, feeDue: Number(data?.fee_due || 0) };
  }
  if (kind === "contest") {
    const { data, error } = await joinContestRpc(supabase, id);
    if (error) return { success: false, message: error, requiresPayment: false, feeDue: 0 };
    return { success: true, message: data?.message || "Concours traité.", requiresPayment: !!data?.requires_payment, feeDue: Number(data?.fee_due || 0) };
  }
  const { data, error } = await supabase.rpc("prepare_ticket_checkout", { p_product_id: id });
  if (error) return { success: false, message: error.message, requiresPayment: false, feeDue: 0 };
  return { success: !!data?.success, message: data?.message || "Ticket traité.", requiresPayment: !!data?.requires_payment, feeDue: Number(data?.fee_due || 0) };
};
