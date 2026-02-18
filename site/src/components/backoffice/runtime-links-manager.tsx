"use client";

import { useCallback, useEffect, useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

type Links = Record<string, string>;
const fields = ["site_base_url", "handoff_path", "payment_path", "ticket_checkout_path", "public_event_buy_path", "support_url", "ticket_shop_url"];

export const RuntimeLinksManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [links, setLinks] = useState<Links>({});
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const r = await supabase.from("app_config").select("value").eq("key", "app_links").maybeSingle();
    setLinks((r.data?.value as Links) || {});
  }, [supabase]);

  useEffect(() => {
    const id = window.setTimeout(() => { void load(); }, 0);
    return () => window.clearTimeout(id);
  }, [load]);

  const save = async () => {
    const r = await supabase.from("app_config").upsert({ key: "app_links", value: links });
    setMessage(r.error ? r.error.message : "Liens runtime enregistrés.");
  };

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Liens runtime app-site</h2>
      {fields.map((f) => (
        <input
          key={f}
          value={links[f] || ""}
          onChange={(e) => setLinks((v) => ({ ...v, [f]: e.target.value }))}
          placeholder={f}
          className="w-full rounded border p-2 text-sm"
        />
      ))}
      <Button onClick={save}>Enregistrer les liens</Button>
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
