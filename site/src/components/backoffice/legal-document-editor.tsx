"use client";

import { useCallback, useEffect, useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

type LegalDoc = {
  id: string;
  doc_type: "terms" | "privacy";
  version: string;
  locale: string;
  title: string;
  body_md: string;
  active: boolean;
  published_at: string;
};

export const LegalDocumentEditor = () => {
  const supabase = getSupabaseBrowserClient();
  const [docs, setDocs] = useState<LegalDoc[]>([]);
  const [docType, setDocType] = useState<"terms" | "privacy">("terms");
  const [version, setVersion] = useState("");
  const [locale, setLocale] = useState("fr-TG");
  const [title, setTitle] = useState("");
  const [body, setBody] = useState("");
  const [message, setMessage] = useState("");
  const [saving, setSaving] = useState(false);

  const load = useCallback(async () => {
    const r = await supabase
      .from("legal_documents")
      .select("id,doc_type,version,locale,title,body_md,active,published_at")
      .order("doc_type")
      .order("published_at", { ascending: false });
    setDocs((r.data as LegalDoc[] | null) || []);
  }, [supabase]);

  useEffect(() => {
    load();
  }, [load]);

  const publish = async () => {
    if (!version.trim() || !title.trim() || !body.trim()) {
      setMessage("Version, titre et contenu sont requis.");
      return;
    }
    setSaving(true);
    try {
      await supabase
        .from("legal_documents")
        .update({ active: false })
        .eq("doc_type", docType)
        .eq("active", true);
      const r = await supabase.from("legal_documents").insert({
        doc_type: docType,
        version: version.trim(),
        locale: locale.trim() || "fr-TG",
        title: title.trim(),
        body_md: body,
        active: true,
        published_at: new Date().toISOString(),
      });
      setMessage(r.error ? r.error.message : "Nouvelle version publiée.");
      if (!r.error) {
        setVersion("");
        setTitle("");
        setBody("");
        load();
      }
    } finally {
      setSaving(false);
    }
  };

  const toggleActive = async (doc: LegalDoc) => {
    if (!doc.active) {
      await supabase.from("legal_documents").update({ active: false }).eq("doc_type", doc.doc_type).eq("active", true);
    }
    await supabase.from("legal_documents").update({ active: !doc.active }).eq("id", doc.id);
    load();
  };

  return (
    <Card className="space-y-4 p-4">
      <div>
        <h2 className="font-semibold">Publier une nouvelle version</h2>
        <p className="text-xs text-slate-500">
          Publier crée une nouvelle ligne versionnée et désactive automatiquement l&apos;ancienne version active du même
          document — l&apos;historique de consentement des utilisateurs reste intact.
        </p>
      </div>
      <div className="grid grid-cols-2 gap-3">
        <label className="text-sm">
          Type de document
          <select
            value={docType}
            onChange={(e) => setDocType(e.target.value as "terms" | "privacy")}
            className="mt-1 w-full rounded border p-2 text-sm"
          >
            <option value="terms">Conditions d&apos;utilisation</option>
            <option value="privacy">Politique de confidentialité</option>
          </select>
        </label>
        <label className="text-sm">
          Version (ex. 1.1.0)
          <input value={version} onChange={(e) => setVersion(e.target.value)} className="mt-1 w-full rounded border p-2 text-sm" />
        </label>
        <label className="text-sm">
          Titre
          <input value={title} onChange={(e) => setTitle(e.target.value)} className="mt-1 w-full rounded border p-2 text-sm" />
        </label>
        <label className="text-sm">
          Locale
          <input value={locale} onChange={(e) => setLocale(e.target.value)} className="mt-1 w-full rounded border p-2 text-sm" />
        </label>
      </div>
      <label className="text-sm">
        Contenu (Markdown)
        <textarea
          value={body}
          onChange={(e) => setBody(e.target.value)}
          className="mt-1 h-80 w-full rounded border p-3 font-mono text-xs"
        />
      </label>
      <Button onClick={publish} disabled={saving}>
        {saving ? "Publication…" : "Publier cette version"}
      </Button>
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}

      <div className="space-y-2 border-t pt-3">
        <h3 className="text-sm font-semibold">Versions existantes</h3>
        {docs.map((d) => (
          <div key={d.id} className="flex items-center justify-between rounded border p-2 text-sm">
            <span>
              {d.doc_type} · v{d.version} · {d.locale} {d.active ? "· actif" : ""}
            </span>
            <Button variant="outline" onClick={() => toggleActive(d)}>
              {d.active ? "Désactiver" : "Activer"}
            </Button>
          </div>
        ))}
      </div>
    </Card>
  );
};
