import { redirect } from "next/navigation";
import { env } from "@/lib/env";
import { getViewerContext } from "@/lib/data/profile";

export default async function TicketsPage() {
  const viewer = await getViewerContext();
  if (!viewer.user) redirect(env.appDeepLink);
  redirect("/tickets/checkout");
}
