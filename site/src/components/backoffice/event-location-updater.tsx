"use client";

import { useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

export const EventLocationUpdater = () => {
  const supabase = getSupabaseBrowserClient();
  const [table, setTable] = useState<"events" | "contests">("events");
  const [id, setId] = useState("");
  const [lat, setLat] = useState("");
  const [lng, setLng] = useState("");
  const [message, setMessage] = useState("");

  const current = () => navigator.geolocation.getCurrentPosition(
    (p) => { setLat(String(p.coords.latitude)); setLng(String(p.coords.longitude)); },
    () => setMessage("Permission refusée ou GPS indisponible."),
    { enableHighAccuracy: true, timeout: 10000 },
  );

  const save = async () => {
    const r = await supabase.from(table).update({
      location_lat: Number(lat),
      location_lng: Number(lng),
    }).eq("id", id.trim());
    setMessage(r.error ? r.error.message : "Coordonnées enregistrées.");
  };

  return (
    <Card className="space-y-3 p-4">
      <h2 className="font-semibold">Localisation rapide</h2>
      <select value={table} onChange={(e) => setTable(e.target.value as "events" | "contests")} className="w-full rounded border p-2 text-sm">
        <option value="events">Event</option><option value="contests">Contest</option>
      </select>
      <input value={id} onChange={(e) => setId(e.target.value)} placeholder="ID event/contest" className="w-full rounded border p-2 text-sm" />
      <div className="grid grid-cols-2 gap-2">
        <input value={lat} onChange={(e) => setLat(e.target.value)} placeholder="Latitude" className="rounded border p-2 text-sm" />
        <input value={lng} onChange={(e) => setLng(e.target.value)} placeholder="Longitude" className="rounded border p-2 text-sm" />
      </div>
      <div className="flex gap-2">
        <Button onClick={current}>Utiliser ma position</Button>
        <Button onClick={save} variant="outline">Enregistrer</Button>
      </div>
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </Card>
  );
};
