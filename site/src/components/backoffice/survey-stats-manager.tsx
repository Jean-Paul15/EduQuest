"use client";

import { useCallback, useEffect, useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/browser";
import { Card } from "@/components/ui/card";

type Survey = { id: string; title: string };
type Q = { survey_id: string };
type A = { survey_id: string; profile_id: string };

export const SurveyStatsManager = () => {
  const supabase = getSupabaseBrowserClient();
  const [rows, setRows] = useState<Array<{ id: string; title: string; questions: number; answers: number; respondents: number }>>([]);

  const load = useCallback(async () => {
    const [s, q, a] = await Promise.all([
      supabase.from("surveys").select("id,title").order("starts_at", { ascending: false }).limit(30),
      supabase.from("survey_questions").select("survey_id"),
      supabase.from("survey_answers").select("survey_id,profile_id"),
    ]);
    const questions = new Map<string, number>(); const answers = new Map<string, number>(); const users = new Map<string, Set<string>>();
    ((q.data || []) as Q[]).forEach((x) => questions.set(x.survey_id, (questions.get(x.survey_id) || 0) + 1));
    ((a.data || []) as A[]).forEach((x) => {
      answers.set(x.survey_id, (answers.get(x.survey_id) || 0) + 1);
      if (!users.has(x.survey_id)) users.set(x.survey_id, new Set<string>());
      users.get(x.survey_id)!.add(x.profile_id);
    });
    setRows((((s.data || []) as Survey[])).map((x) => ({
      id: x.id, title: x.title, questions: questions.get(x.id) || 0, answers: answers.get(x.id) || 0, respondents: users.get(x.id)?.size || 0,
    })));
  }, [supabase]);

  useEffect(() => { const id = window.setTimeout(() => { void load(); }, 0); return () => window.clearTimeout(id); }, [load]);

  return (
    <Card className="space-y-2 p-4">
      <h2 className="font-semibold">Statistiques enquêtes</h2>
      {rows.map((x) => (
        <div key={x.id} className="rounded border p-2 text-sm">
          <p className="font-medium">{x.title}</p>
          <p className="text-xs text-slate-600">Questions {x.questions} • Réponses {x.answers} • Répondants {x.respondents}</p>
        </div>
      ))}
    </Card>
  );
};
