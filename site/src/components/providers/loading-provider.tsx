"use client";

import { useEffect, useRef, useState } from "react";
import { AnimatePresence } from "framer-motion";
import { usePathname, useSearchParams } from "next/navigation";
import { RouteChangeLoader } from "@/components/ui/loading/route-change-loader";

type Props = { children: React.ReactNode };

export const LoadingProvider = ({ children }: Props) => {
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const [loading, setLoading] = useState(false);
  const [progress, setProgress] = useState(18);
  const startedAt = useRef<number | null>(null);
  const targetPath = useRef<string | null>(null);

  useEffect(() => {
    const onClick = (event: MouseEvent) => {
      const target = event.target as HTMLElement | null;
      const link = target?.closest("a[href]") as HTMLAnchorElement | null;
      if (!link || link.target === "_blank" || link.hasAttribute("download")) return;
      const href = link.getAttribute("href");
      if (!href || href.startsWith("#") || href.startsWith("mailto:") || href.startsWith("tel:")) return;
      const to = new URL(link.href, window.location.href);
      const current = new URL(window.location.href);
      if (to.origin !== current.origin) return;
      const nextPath = `${to.pathname}${to.search}`;
      const currentPath = `${current.pathname}${current.search}`;
      targetPath.current = nextPath === currentPath ? currentPath : nextPath;
      startedAt.current = Date.now();
      setProgress(28);
      setLoading(true);
    };
    document.addEventListener("click", onClick, true);
    return () => document.removeEventListener("click", onClick, true);
  }, []);

  useEffect(() => {
    if (!loading) return;
    const currentPath = `${pathname}${searchParams.toString() ? `?${searchParams.toString()}` : ""}`;
    if (targetPath.current && currentPath !== targetPath.current) return;
    const elapsed = startedAt.current ? Date.now() - startedAt.current : 0;
    const remaining = Math.max(0, 600 - elapsed);
    const settle = window.setTimeout(() => setProgress(100), 30);
    const timer = window.setTimeout(() => {
      setLoading(false);
      targetPath.current = null;
    }, remaining);
    return () => {
      window.clearTimeout(settle);
      window.clearTimeout(timer);
    };
  }, [pathname, searchParams, loading]);

  useEffect(() => {
    if (!loading) return;
    const timer = window.setInterval(() => setProgress((v) => Math.min(95, v + 5)), 120);
    return () => window.clearInterval(timer);
  }, [loading]);

  useEffect(() => {
    if (!loading) return;
    const timeout = window.setTimeout(() => {
      setLoading(false);
      targetPath.current = null;
    }, 12000);
    return () => window.clearTimeout(timeout);
  }, [loading]);

  return (
    <>
      {children}
      <AnimatePresence>{loading ? <RouteChangeLoader progress={progress} /> : null}</AnimatePresence>
    </>
  );
};
