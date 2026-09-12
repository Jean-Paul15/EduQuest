"use client";

import type { SiteAnalyticsEvent } from "@/lib/analytics/events";

type Args = {
  name: SiteAnalyticsEvent;
  category?: string;
  payload?: Record<string, unknown>;
};

export const trackSiteEvent = async ({ name, category, payload }: Args) => {
  try {
    await fetch("/api/analytics/track", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      credentials: "include",
      keepalive: true,
      body: JSON.stringify({ name, category, payload }),
    });
  } catch {}
};
