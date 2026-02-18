"use client";

import { useCallback, useEffect, useState } from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";

type Req = { id: string; full_name: string | null; email: string; status: string };
type Act = { action: string; target_id: string; created_at: string };

export const ModerationActionsManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [rows, setRows] = useState<Req[]>([]); const [acts, setActs] = useState<Act[]>([]); const [msg, setMsg] = useState("");

  const load = useCallback(async () => {
    const [r, a] = await Promise.all([
      supabase.from("data_deletion_requests").select("id,full_name,email,status").order("created_at", { ascending: false }).limit(20),
      supabase.from("moderation_actions").select("action,target_id,created_at").eq("target_table", "data_deletion_requests").order("created_at", { ascending: false }).limit(20),
    ]);
    setRows((r.data as Req[]) || []); setActs((a.data as Act[]) || []);
  }, [supabase]);
  useEffect(() => { const id = window.setTimeout(() => { void load(); }, 0); return () => window.clearTimeout(id); }, [load]);

  const doAction = async (id: string, action: "approve" | "reject" | "cancel") => {
    const r = await supabase.rpc("moderate_data_deletion_request", { p_request_id: id, p_action: action, p_note: "backoffice" });
    setMsg(r.error ? r.error.message : (r.data?.message || "Action appliquée."));
    if (!r.error) await load();
  };

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Modération demandes support</h2>
      {rows.map((x) => <div key={x.id} className="rounded border p-2 text-sm"><p>{x.full_name || "-"} • {x.email} • {x.status}</p><div className="mt-2 flex gap-2"><Button variant="outline" onClick={() => doAction(x.id, "approve")}>Approve</Button><Button variant="outline" onClick={() => doAction(x.id, "reject")}>Reject</Button><Button variant="outline" onClick={() => doAction(x.id, "cancel")}>Review</Button></div></div>)}
      <div className="rounded border p-2">{acts.map((x, i) => <p key={i} className="text-xs text-slate-600">{x.created_at} • {x.action} • {x.target_id}</p>)}</div>
      {msg ? <p className="text-sm text-slate-600">{msg}</p> : null}
    </Card>
  );
};
