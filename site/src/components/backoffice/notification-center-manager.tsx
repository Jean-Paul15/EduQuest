"use client";

import { useCallback, useEffect, useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";

type Campaign = { id: string; title: string; status: string; scheduled_at: string | null };
const statusLabel = (s: string) =>
  ({
    draft: "Brouillon",
    queued: "Programmé",
    retrying: "Nouvelle tentative",
    sent: "Envoyé",
    failed: "Échec",
  }[s] || s);

export const NotificationCenterManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [title, setTitle] = useState("");
  const [body, setBody] = useState("");
  const [deeplink, setDeeplink] = useState("eduquest://hub");
  const [level, setLevel] = useState("");
  const [serie, setSerie] = useState("");
  const [topic, setTopic] = useState("");
  const [rows, setRows] = useState<Campaign[]>([]);
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    const r = await supabase.from("notification_campaigns").select("id,title,status,scheduled_at").order("created_at", { ascending: false }).limit(30);
    setRows((r.data as Campaign[]) || []);
  }, [supabase]);

  useEffect(() => {
    const id = window.setTimeout(() => { void load(); }, 0);
    return () => window.clearTimeout(id);
  }, [load]);

  const createDraft = async () => {
    const target_filter = {
      ...(level ? { levels: [level] } : {}),
      ...(serie ? { series: [serie] } : {}),
      ...(topic ? { topic } : {}),
    };
    const display_payload = {
      existing_android_channel_id: "eduquest_alerts",
      android_sound: "default",
      ios_sound: "default",
      silent: false,
      ttl: 86400,
    };
    const r = await supabase.from("notification_campaigns").insert({ title, body, deeplink, target_filter, display_payload });
    setMessage(r.error ? r.error.message : "Campagne enregistrée.");
    if (!r.error) {
      setTitle("");
      setBody("");
      setLevel("");
      setSerie("");
      setTopic("");
      load();
    }
  };

  const queue = async (id: string) => {
    const r = await supabase.rpc("queue_notification_campaign", { p_campaign_id: id });
    setMessage(r.error ? r.error.message : (r.data?.message || "Campagne programmée."));
    load();
  };

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Campagnes notifications</h2>
      <p className="text-xs text-slate-500">Prépare un message puis programme son envoi aux élèves ciblés.</p>
      <input value={title} onChange={(e) => setTitle(e.target.value)} placeholder="Titre notification" className="w-full rounded border p-2" />
      <textarea value={body} onChange={(e) => setBody(e.target.value)} placeholder="Message..." className="h-24 w-full rounded border p-2" />
      <input value={deeplink} onChange={(e) => setDeeplink(e.target.value)} placeholder="Lien d'ouverture dans l'app (optionnel)" className="w-full rounded border p-2" />
      <div className="grid grid-cols-3 gap-2">
        <input value={level} onChange={(e) => setLevel(e.target.value)} placeholder="Classe (ex: Terminale)" className="rounded border p-2 text-sm" />
        <input value={serie} onChange={(e) => setSerie(e.target.value)} placeholder="Série (ex: D)" className="rounded border p-2 text-sm" />
        <input value={topic} onChange={(e) => setTopic(e.target.value)} placeholder="Thème (ex: event, contest)" className="rounded border p-2 text-sm" />
      </div>
      <Button onClick={createDraft}>Créer la campagne</Button>
      {rows.map((r) => (
        <div key={r.id} className="flex items-center justify-between rounded border p-2">
          <div>
            <p className="text-sm font-medium">{r.title}</p>
            <p className="text-xs text-slate-500">{statusLabel(r.status)}</p>
          </div>
          <Button onClick={() => queue(r.id)}>Programmer</Button>
        </div>
      ))}
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
