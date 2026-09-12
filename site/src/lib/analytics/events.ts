export const siteAnalyticsEvents = [
  "login_submit",
  "login_success",
  "login_failure",
  "checkout_started",
  "payment_redirected",
  "payment_confirmed",
  "payment_failed",
  "app_handoff_attempted",
  "app_handoff_succeeded",
  "app_handoff_failed",
  "event_public_buy_submitted",
  "event_public_buy_succeeded",
  "event_public_buy_failed",
  "contest_join_requested",
  "contest_join_succeeded",
  "contest_join_failed",
  "event_join_requested",
  "event_join_succeeded",
  "event_join_failed",
] as const;

export type SiteAnalyticsEvent = (typeof siteAnalyticsEvents)[number];

export const isSiteAnalyticsEvent = (value: string): value is SiteAnalyticsEvent =>
  siteAnalyticsEvents.includes(value as SiteAnalyticsEvent);
