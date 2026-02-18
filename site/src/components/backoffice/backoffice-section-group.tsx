"use client";

import { ChevronDown } from "lucide-react";
import { Card } from "@/components/ui/card";

type Props = {
  id: string;
  title: string;
  description?: string;
  defaultOpen?: boolean;
  children: React.ReactNode;
};

export const BackofficeSectionGroup = ({
  id,
  title,
  description,
  defaultOpen = false,
  children,
}: Props) => (
  <Card id={id} className="overflow-hidden border-slate-200/70 bg-white/85 shadow-sm backdrop-blur">
    <details className="group" open={defaultOpen}>
      <summary className="flex cursor-pointer list-none items-center justify-between bg-gradient-to-r from-blue-50 via-white to-orange-50 px-4 py-3">
        <div>
          <div className="flex items-center gap-2">
            <p className="text-sm font-semibold text-slate-900">{title}</p>
            <span className="rounded-full border border-slate-200 bg-white px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wide text-slate-500">
              Section
            </span>
          </div>
          {description ? <p className="text-xs text-slate-600">{description}</p> : null}
        </div>
        <ChevronDown className="h-4 w-4 text-slate-500 transition group-open:rotate-180" />
      </summary>
      <div className="space-y-3 p-4">{children}</div>
    </details>
  </Card>
);
