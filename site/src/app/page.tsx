import { HeroSection } from "@/components/landing/hero-section";
import { FeaturesSection } from "@/components/landing/features-section";
import { ScrollStory } from "@/components/landing/scroll-story";
import { StoryTrack } from "@/components/landing/story-track";
import { TrustSection } from "@/components/landing/trust-section";
import { PricingSection } from "@/components/landing/pricing-section";
import { FinalCTASection } from "@/components/landing/final-cta-section";
import { getViewerContext } from "@/lib/data/profile";
import { listTicketProducts } from "@/lib/data/tickets";
import { env } from "@/lib/env";

export default async function Home() {
  const [viewer, products] = await Promise.all([getViewerContext(), listTicketProducts()]);
  const loggedIn = !!viewer.user;
  const appDeepLink = env.appDeepLink;

  return (
    <main className="flex flex-col w-full">
      <HeroSection loggedIn={loggedIn} appDeepLink={appDeepLink} />
      <FeaturesSection />
      <ScrollStory />
      <StoryTrack />
      <TrustSection />
      <PricingSection products={products} loggedIn={loggedIn} appDeepLink={appDeepLink} />
      <FinalCTASection loggedIn={loggedIn} appDeepLink={appDeepLink} />
    </main>
  );
}
