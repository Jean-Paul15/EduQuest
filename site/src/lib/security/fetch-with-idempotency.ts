"use client";

import {
  clearIdempotencyKey,
  getOrCreateIdempotencyKey,
} from "@/lib/security/client-idempotency";

export type PostJsonWithIdemOptions = {
  scope: string;
  keyId: string;
  url: string;
  payload: Record<string, unknown>;
  initialIdempotencyKey?: string;
  headers?: HeadersInit;
};

export const postJsonWithIdem = async ({
  scope,
  keyId,
  url,
  payload,
  initialIdempotencyKey,
  headers,
}: PostJsonWithIdemOptions) => {
  const idem = initialIdempotencyKey || getOrCreateIdempotencyKey(scope, keyId);
  const body = { ...payload, idempotencyKey: idem };
  const response = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      ...headers,
      "x-idempotency-key": idem,
    },
    body: JSON.stringify(body),
  });
  if (response.ok) clearIdempotencyKey(scope, keyId);
  return response;
};

export const fetchWithIdempotency = postJsonWithIdem;
