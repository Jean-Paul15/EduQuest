"use client";

import { useCallback, useEffect, useState } from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

type Rules = { fee_fixed: number; fee_percent: number; upgrade_discount_percent: number; upgrade_bonus_days: number };
const defaults: Rules = { fee_fixed: 0, fee_percent: 0, upgrade_discount_percent: 0, upgrade_bonus_days: 0 };

export const TicketCheckoutRulesManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [rules, setRules] = useState<Rules>(defaults);
  const [message, setMessage] = useState("");
  const n = (k: keyof Rules, v: string) => setRules((x) => ({ ...x, [k]: Number(v) || 0 }));

  const load = useCallback(async () => {
    const r = await supabase.from("app_config").select("value").eq("key", "ticket_checkout_rules").maybeSingle();
    const v = (r.data?.value || {}) as Partial<Rules>;
    setRules({ fee_fixed: Number(v.fee_fixed || 0), fee_percent: Number(v.fee_percent || 0), upgrade_discount_percent: Number(v.upgrade_discount_percent || 0), upgrade_bonus_days: Number(v.upgrade_bonus_days || 0) });
  }, [supabase]);
  useEffect(() => { const id = window.setTimeout(() => { void load(); }, 0); return () => window.clearTimeout(id); }, [load]);

  const save = async () => {
    const clean = { fee_fixed: Math.max(0, rules.fee_fixed), fee_percent: Math.max(0, rules.fee_percent), upgrade_discount_percent: Math.max(0, rules.upgrade_discount_percent), upgrade_bonus_days: Math.max(0, Math.floor(rules.upgrade_bonus_days)) };
    const r = await supabase.from("app_config").upsert({ key: "ticket_checkout_rules", value: clean });
    setMessage(r.error ? r.error.message : "Règles d'achat tickets enregistrées.");
  };

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Règles d&apos;achat tickets</h2>
      <div className="grid gap-2 md:grid-cols-2">
        <input value={rules.fee_fixed} type="number" min={0} onChange={(e) => n("fee_fixed", e.target.value)} className="rounded border p-2 text-sm" placeholder="Frais fixes (XOF)" />
        <input value={rules.fee_percent} type="number" min={0} onChange={(e) => n("fee_percent", e.target.value)} className="rounded border p-2 text-sm" placeholder="Frais en pourcentage" />
        <input value={rules.upgrade_discount_percent} type="number" min={0} onChange={(e) => n("upgrade_discount_percent", e.target.value)} className="rounded border p-2 text-sm" placeholder="Réduction en cas d'amélioration" />
        <input value={rules.upgrade_bonus_days} type="number" min={0} onChange={(e) => n("upgrade_bonus_days", e.target.value)} className="rounded border p-2 text-sm" placeholder="Jours bonus en cas d'amélioration" />
      </div>
      <Button onClick={save}>Enregistrer</Button>
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
