import { createSupabaseServerClient } from "@/lib/supabase/server";

export type MarketplaceItem = {
  id: string;
  title: string;
  item_type: string;
  description: string | null;
  image_url: string | null;
  price_label: string | null;
  external_checkout_url: string;
};

export const searchMarketplace = async (query?: string) => {
  const supabase = await createSupabaseServerClient();
  const q = query?.trim() || null;
  if (q) {
    const { data } = await supabase.rpc("search_marketplace_items", {
      p_query: q,
      p_item_type: null,
      p_limit: 60,
    });
    return (data ?? []) as MarketplaceItem[];
  }
  const { data } = await supabase
    .from("marketplace_items")
    .select("id,title,item_type,description,image_url,price_label,external_checkout_url")
    .eq("active", true)
    .order("title", { ascending: true })
    .returns<MarketplaceItem[]>();
  return data ?? [];
};
