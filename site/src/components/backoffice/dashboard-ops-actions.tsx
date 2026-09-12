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
    if (!draftId) return setMessage("Aucune campagne en brouillon.");
    const res = await fetch("/api/backoffice/notification-campaigns/queue", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ campaignId: draftId }),
    });
    const out = (await res.json()) as { message?: string };
    setMessage(out.message || (res.ok ? "Campagne programmée." : "Erreur."));
    if (res.ok) await load();
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
        <Button onClick={queueDraft}>Programmer la dernière campagne</Button>
        <Button variant="outline" onClick={rebuildRewards}>Recalculer les récompenses</Button>
        <Button variant="outline" onClick={marketingCleanup}>Nettoyage marketing</Button>
      </div>
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
