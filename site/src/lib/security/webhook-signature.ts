import { createHmac, timingSafeEqual } from "crypto";

export const parseTs = (v: string | null) => Number(v || 0);

export const verifyWebhookSignature = (
  rawBody: string,
  timestamp: number,
  signature: string,
  secret: string,
  toleranceSec = 300,
) => {
  if (!secret || !signature || !timestamp) return false;
  if (Math.abs(Math.floor(Date.now() / 1000) - timestamp) > toleranceSec) return false;
  const signed = `${timestamp}.${rawBody}`;
  const digest = createHmac("sha256", secret).update(signed).digest("hex");
  const a = Buffer.from(digest); const b = Buffer.from(signature);
  return a.length === b.length && timingSafeEqual(a, b);
};

export const hashPayload = (rawBody: string, secret: string) =>
  createHmac("sha256", secret).update(rawBody).digest("hex");
