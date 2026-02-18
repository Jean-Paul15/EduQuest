import { createSupabaseServerClient } from "@/lib/supabase/server";

export type TicketProduct = {
  id: string;
  code: string;
  ticket_type: "FULL" | "HALF";
  duration_days: number;
};

export type ActiveTicket = {
  code: string;
  expires_at: string | null;
  ticket_products: { code: string; ticket_type: string } | null;
};

export type TicketCheckoutOption = {
  product_id: string;
  product_code: string;
  ticket_type: "FULL" | "HALF";
  duration_days: number;
  base_price: number;
  fees: number;
  total_price: number;
  is_upgrade: boolean;
  upgrade_bonus_days: number;
};

export const listTicketProducts = async () => {
  const supabase = await createSupabaseServerClient();
  const { data } = await supabase
    .from("ticket_products")
    .select("id, code, ticket_type, duration_days")
    .eq("active", true)
    .order("duration_days", { ascending: true })
    .returns<TicketProduct[]>();
  return data ?? [];
};

export const listMyTickets = async () => {
  const supabase = await createSupabaseServerClient();
  const { data } = await supabase
    .from("ticket_codes")
    .select("code, expires_at, ticket_products(code, ticket_type)")
    .gt("expires_at", new Date().toISOString())
    .order("expires_at", { ascending: true })
    .returns<ActiveTicket[]>();
  return data ?? [];
};

export const listTicketCheckoutOptions = async () => {
  const supabase = await createSupabaseServerClient();
  const { data } = await supabase.rpc("list_ticket_checkout_options");
  return ((data || []) as TicketCheckoutOption[]).map((x) => ({
    ...x,
    base_price: Number(x.base_price || 0),
    fees: Number(x.fees || 0),
    total_price: Number(x.total_price || 0),
    duration_days: Number(x.duration_days || 0),
    upgrade_bonus_days: Number(x.upgrade_bonus_days || 0),
  }));
};
