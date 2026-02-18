"use client";

import { useCallback, useEffect, useState } from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

type Product = { id: string; code: string; ticket_type: string; duration_days: number };
type Action = { action: string; target_profile_id: string; created_at: string };

export const TicketSupportWorkflowManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [products, setProducts] = useState<Product[]>([]);
  const [productId, setProductId] = useState(""); const [profileId, setProfileId] = useState(""); const [days, setDays] = useState(7);
  const [actions, setActions] = useState<Action[]>([]); const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const [p, a] = await Promise.all([
      supabase.from("ticket_products").select("id,code,ticket_type,duration_days").eq("active", true).order("code"),
      supabase.from("support_ticket_actions").select("action,target_profile_id,created_at").order("created_at", { ascending: false }).limit(20),
    ]);
    setProducts((p.data as Product[]) || []); setActions((a.data as Action[]) || []);
    if (!productId && p.data?.length) setProductId(String(p.data[0].id));
  }, [productId, supabase]);
  useEffect(() => { const id = window.setTimeout(() => { void load(); }, 0); return () => window.clearTimeout(id); }, [load]);

  const assign = async () => {
    const r = await supabase.rpc("backoffice_assign_ticket_to_user", { p_profile_id: profileId, p_product_id: productId, p_days: days, p_reason: "support_dashboard" });
    setMessage(r.error ? r.error.message : (r.data?.message || "Ticket assigné."));
    if (!r.error) await load();
  };
  const extend = async () => {
    const r = await supabase.rpc("backoffice_extend_active_tickets", { p_profile_id: profileId, p_days: days });
    setMessage(r.error ? r.error.message : (r.data?.message || "Tickets prolongés."));
    if (!r.error) await load();
  };
  const expire = async () => {
    const r = await supabase.rpc("backoffice_expire_active_tickets", { p_profile_id: profileId });
    setMessage(r.error ? r.error.message : (r.data?.message || "Tickets expirés."));
    if (!r.error) await load();
  };

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Support tickets: assigner / prolonger / expirer</h2>
      <input value={profileId} onChange={(e) => setProfileId(e.target.value)} placeholder="profile_id (uuid)" className="w-full rounded border p-2 text-sm" />
      <select value={productId} onChange={(e) => setProductId(e.target.value)} className="w-full rounded border p-2 text-sm">{products.map((x) => <option key={x.id} value={x.id}>{x.code} • {x.ticket_type} • {x.duration_days}j</option>)}</select>
      <input type="number" min={1} value={days} onChange={(e) => setDays(Number(e.target.value) || 1)} className="w-full rounded border p-2 text-sm" />
      <div className="flex flex-wrap gap-2"><Button onClick={assign}>Assigner</Button><Button variant="outline" onClick={extend}>Prolonger</Button><Button variant="outline" onClick={expire}>Expirer</Button></div>
      {actions.map((x, i) => <p key={i} className="text-xs text-slate-600">{x.created_at} • {x.action} • {x.target_profile_id}</p>)}
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
