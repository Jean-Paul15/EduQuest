"use client";

import { RouteChangeLoader } from "@/components/ui/loading/route-change-loader";

type Props = { active?: boolean; progress?: number };

export const PageLoader = ({ active = true, progress = 72 }: Props) =>
  active ? <RouteChangeLoader progress={progress} /> : null;

