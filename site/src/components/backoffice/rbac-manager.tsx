/* eslint-disable react-hooks/exhaustive-deps */
"use client";

import { useEffect, useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";

type Role = { id: string; name: string; slug: string };
type Section = { id: string; label: string };

export const RbacManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [roles, setRoles] = useState<Role[]>([]);
  const [sections, setSections] = useState<Section[]>([]);
  const [roleId, setRoleId] = useState("");
  const [checked, setChecked] = useState<string[]>([]);
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [message, setMessage] = useState("");

  const load = async () => {
    const [r, s] = await Promise.all([
      supabase.from("backoffice_roles").select("id,name,slug").order("name"),
      supabase.from("backoffice_nav_sections").select("id,label").eq("active", true).order("position"),
    ]);
    setRoles((r.data as Role[]) || []);
    setSections((s.data as Section[]) || []);
    if (!roleId && r.data?.[0]?.id) setRoleId(r.data[0].id);
  };

  const loadRoleSections = async (id: string) => {
    const r = await supabase.from("backoffice_role_nav_sections").select("section_id").eq("role_id", id);
    setChecked((r.data || []).map((x: { section_id: string }) => x.section_id));
  };

  useEffect(() => { load(); }, []);
  useEffect(() => { if (roleId) loadRoleSections(roleId); }, [roleId]);

  const save = async () => {
    await supabase.from("backoffice_role_nav_sections").delete().eq("role_id", roleId);
    if (checked.length) await supabase.from("backoffice_role_nav_sections").insert(checked.map((id) => ({ role_id: roleId, section_id: id })));
    setMessage("Sections mises à jour.");
  };

  return (
    <div className="space-y-4">
      <Card className="space-y-3 p-4">
        <h2 className="font-semibold">Créer un profil d&apos;accès</h2>
        <input value={name} onChange={(e) => setName(e.target.value)} placeholder="Nom du profil (ex: Responsable contenu)" className="w-full rounded border p-2" />
        <Button onClick={async () => { await supabase.from("backoffice_roles").insert({ name, slug: name.toLowerCase().replaceAll(" ", "-") }); setName(""); load(); }}>Créer le profil</Button>
      </Card>
      <Card className="space-y-3 p-4">
        <h2 className="font-semibold">Menus visibles par profil</h2>
        <select value={roleId} onChange={(e) => setRoleId(e.target.value)} className="w-full rounded border p-2">
          {roles.map((r) => <option key={r.id} value={r.id}>{r.name}</option>)}
        </select>
        <div className="grid gap-2 md:grid-cols-2">
          {sections.map((s) => <label key={s.id} className="flex items-center gap-2 text-sm"><input type="checkbox" checked={checked.includes(s.id)} onChange={(e)=>setChecked((v)=>e.target.checked?[...v,s.id]:v.filter((x)=>x!==s.id))} /> {s.label}</label>)}
        </div>
        <Button onClick={save}>Enregistrer</Button>
      </Card>
      <Card className="space-y-3 p-4">
        <h2 className="font-semibold">Associer un profil à une adresse email</h2>
        <input value={email} onChange={(e) => setEmail(e.target.value)} placeholder="email@domaine.com" className="w-full rounded border p-2" />
        <Button onClick={async () => { const r = await supabase.rpc("grant_backoffice_role", { p_role_id: roleId, p_user_email: email }); setMessage(r.data?.message || "Profil attribué."); }}>Associer</Button>
      </Card>
      {message ? <p className="text-sm text-slate-600">{message}</p> : null}
    </div>
  );
};
