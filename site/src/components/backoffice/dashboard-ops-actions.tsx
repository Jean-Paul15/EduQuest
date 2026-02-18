"use client";

import { useCallback, useEffect, useState } from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

const monthKey = () => {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}`;
};

export const DashboardOpsActions = () => {
  const supabase = getSupabaseBrowserClient();
  const [draftId, setDraftId] = useState("");
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const r = await supabase.from("notification_campaigns").select("id").eq("status", "draft").order("created_at", { ascending: false }).limit(1).maybeSingle();
    setDraftId(String(r.data?.id || ""));
  }, [supabase]);

  useEffect(() => {
    const id = window.setTimeout(() => { void load(); }, 0);
    return () => window.clearTimeout(id);
  }, [load]);

  const queueDraft = async () => {
    if (!draftId) return setMessage("Aucun draft push.");
    const r = await supabase.rpc("queue_notification_campaign", { p_campaign_id: draftId });
    setMessage(r.error ? r.error.message : (r.data?.message || "Campagne mise en file."));
    if (!r.error) await load();
  };

  const rebuildRewards = async () => {
    const r = await supabase.rpc("build_monthly_reward_results", { p_period_key: monthKey() });
    setMessage(r.error ? r.error.message : "Classement mensuel régénéré.");
  };

  const marketingCleanup = async () => {
    const r = await supabase.rpc("run_marketing_lifecycle_cleanup");
    setMessage(r.error ? r.error.message : "Nettoyage marketing exécuté.");
  };

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Actions rapides</h2>
      <div className="flex flex-wrap gap-2">
        <Button onClick={queueDraft}>Queue dernier draft push</Button>
        <Button variant="outline" onClick={rebuildRewards}>Régénérer rewards</Button>
        <Button variant="outline" onClick={marketingCleanup}>Nettoyage marketing</Button>
      </div>
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
