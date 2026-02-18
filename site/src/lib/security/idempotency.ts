import { createSupabaseAdminClient } from "@/lib/supabase/admin";

type Claim = {
  mode: "fresh" | "replay" | "conflict" | "inflight" | "none";
  rowId?: string;
  statusCode?: number;
  responseBody?: unknown;
};

const conflictCode = "23505";

export const claimIdempotency = async (
  scope: string,
  key: string | null,
  actorId: string | null,
  requestHash: string,
): Promise<Claim> => {
  if (!key || !key.trim()) return { mode: "none" };
  const admin = createSupabaseAdminClient();
  const { data: inserted, error } = await admin
    .from("api_idempotency_keys")
    .insert({
      scope,
      idempotency_key: key.trim(),
      actor_id: actorId,
      request_hash: requestHash,
    })
    .select("id")
    .single();
  if (!error) return { mode: "fresh", rowId: inserted.id };
  if (error.code !== conflictCode) return { mode: "inflight" };
  const { data: existing } = await admin
    .from("api_idempotency_keys")
    .select("id,request_hash,response_body,status_code")
    .eq("scope", scope)
    .eq("idempotency_key", key.trim())
    .single();
  if (!existing) return { mode: "inflight" };
  if ((existing.request_hash || "") !== requestHash) return { mode: "conflict" };
  if (existing.response_body != null) {
    return {
      mode: "replay",
      statusCode: existing.status_code || 200,
      responseBody: existing.response_body,
    };
  }
  return { mode: "inflight" };
};

export const storeIdempotencyResult = async (
  rowId: string | undefined,
  statusCode: number,
  responseBody: unknown,
) => {
  if (!rowId) return;
  const admin = createSupabaseAdminClient();
  await admin
    .from("api_idempotency_keys")
    .update({ status_code: statusCode, response_body: responseBody })
    .eq("id", rowId);
};
