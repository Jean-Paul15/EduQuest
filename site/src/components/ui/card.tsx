import { cn } from "@/lib/utils";

type Props = React.HTMLAttributes<HTMLDivElement>;

export const Card = ({ className, ...props }: Props) => (
  <div className={cn("rounded-xl border border-slate-200 bg-white shadow-sm", className)} {...props} />
);
