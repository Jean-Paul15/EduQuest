import * as React from "react";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils";

const styles = cva(
  "inline-flex items-center justify-center rounded-md text-sm font-medium transition disabled:pointer-events-none disabled:opacity-50",
  {
    variants: {
      variant: {
        primary: "bg-orange-500 text-white hover:bg-orange-600",
        ghost: "hover:bg-orange-50 text-slate-700",
        outline: "border border-slate-200 hover:bg-slate-50",
      },
      size: { md: "h-9 px-4", sm: "h-8 px-3 text-xs" },
    },
    defaultVariants: { variant: "primary", size: "md" },
  },
);

export type ButtonProps = React.ButtonHTMLAttributes<HTMLButtonElement> &
  VariantProps<typeof styles>;

export const Button = ({ className, variant, size, ...props }: ButtonProps) => (
  <button className={cn(styles({ variant, size }), className)} {...props} />
);
