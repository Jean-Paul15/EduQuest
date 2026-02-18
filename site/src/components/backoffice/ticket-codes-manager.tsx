"use client";

import { useCallback, useEffect, useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

type Product = { id: string; code: string; ticket_type: string };
type CodeRow = { code: string; sold_at: string | null; activated_at: string | null; expires_at: string | null };

const makeCode = () => `EQ${Date.now().toString(36)}${Math.random().toString(36).slice(2, 8)}`.toUpperCase();

export const TicketCodesManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [products, setProducts] = useState<Product[]>([]);
  const [rows, setRows] = useState<CodeRow[]>([]);
  const [productId, setProductId] = useState("");
  const [count, setCount] = useState(10);
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const [p, c] = await Promise.all([
      supabase.from("ticket_products").select("id,code,ticket_type").eq("active", true).order("code"),
      supabase.from("ticket_codes").select("code,sold_at,activated_at,expires_at").order("sold_at", { ascending: false }).limit(25),
    ]);
    setProducts((p.data as Product[]) || []);
    setRows((c.data as CodeRow[]) || []);
    if (!productId && p.data?.length) setProductId(String(p.data[0].id));
  }, [productId, supabase]);

  useEffect(() => {
    const id = window.setTimeout(() => { void load(); }, 0);
    return () => window.clearTimeout(id);
  }, [load]);

  const createBatch = async () => {
    if (!productId) return setMessage("Produit ticket requis.");
    const n = Math.max(1, Math.min(200, count));
    const payload = Array.from({ length: n }).map(() => ({
      product_id: productId, code: makeCode(), sold_to_phone: "BACKOFFICE_BATCH", sold_at: new Date().toISOString(),
    }));
    const r = await supabase.from("ticket_codes").insert(payload);
    setMessage(r.error ? r.error.message : `${n} codes générés.`);
    if (!r.error) await load();
  };

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Codes tickets (batch)</h2>
      <select value={productId} onChange={(e) => setProductId(e.target.value)} className="w-full rounded border p-2 text-sm">
        {products.map((p) => <option key={p.id} value={p.id}>{p.code} • {p.ticket_type}</option>)}
      </select>
      <input value={count} type="number" min={1} max={200} onChange={(e) => setCount(Number(e.target.value) || 1)} className="w-full rounded border p-2 text-sm" />
      <Button onClick={createBatch}>Générer un batch</Button>
      {rows.map((x, i) => (
        <div key={i} className="rounded border p-2 text-xs">
          <p className="font-semibold">{x.code}</p>
          <p className="text-slate-500">sold: {x.sold_at || "-"} • active: {x.activated_at || "-"}</p>
        </div>
      ))}
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
