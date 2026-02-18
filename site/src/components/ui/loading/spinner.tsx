"use client";

import { cn } from "@/lib/utils";

type SpinnerProps = {
  size?: number;
  className?: string;
  variant?: "ring" | "logo";
};

export const Spinner = ({ size = 52, className, variant = "ring" }: SpinnerProps) => (
  <div
    aria-hidden="true"
    className={cn("relative shrink-0", className)}
    style={{ width: size, height: size }}
  >
    <div className="absolute inset-0 rounded-full border border-white/15" />
    <div className="eq-loading-gradient absolute inset-0 rounded-full p-[3px]">
      <div className="h-full w-full rounded-full bg-slate-950/85" />
    </div>
    {variant === "logo" ? (
      <div className="absolute inset-[22%] rounded-full eq-loading-gradient" />
    ) : (
      <div className="absolute inset-[16%] rounded-full border border-white/25" />
    )}
  </div>
);

