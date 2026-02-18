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
  const options = ((data || []) as TicketCheckoutOption[]).map((x) => ({
    ...x,
    base_price: Number(x.base_price || 0),
    fees: Number(x.fees || 0),
    total_price: Number(x.total_price || 0),
    duration_days: Number(x.duration_days || 0),
    upgrade_bonus_days: Number(x.upgrade_bonus_days || 0),
  }));
  const badIds = options.filter((x) => x.total_price <= 0).map((x) => x.product_id);
  if (!badIds.length) return options;

  const { data: products } = await supabase
    .from("ticket_products")
    .select("id, ticket_type, price_full, price_half")
    .in("id", badIds);
  const priceMap = new Map(
    (products || []).map((p: { id: string; ticket_type: "FULL" | "HALF"; price_full: number; price_half: number }) => {
      const full = Number(p.price_full || 0);
      const half = Number(p.price_half || 0);
      const base = p.ticket_type === "FULL" ? full : half;
      return [p.id, base];
    }),
  );

  return options.map((x) => {
    if (x.total_price > 0) return x;
    const base = Number(priceMap.get(x.product_id) || 0);
    if (base <= 0) return x;
    const fees = Number(x.fees || 0);
    return { ...x, base_price: base, total_price: base + fees };
  });
};
