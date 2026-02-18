"use client";

import { Refine, type DataProvider } from "@refinedev/core";
import routerProvider from "@refinedev/nextjs-router";

const dataProvider = {
  getApiUrl: () => "",
  getList: async () => ({ data: [] as never[], total: 0 }),
  getMany: async () => ({ data: [] as never[] }),
  getOne: async () => ({ data: {} as never }),
  create: async ({ variables }: { variables?: unknown }) => ({ data: (variables as never) ?? ({} as never) }),
  update: async ({ variables }: { variables?: unknown }) => ({ data: (variables as never) ?? ({} as never) }),
  deleteOne: async () => ({ data: {} as never }),
  custom: async () => ({ data: {} as never }),
} as unknown as DataProvider;

export const BackofficeRefineShell = ({ children }: { children: React.ReactNode }) => (
  <Refine dataProvider={dataProvider} routerProvider={routerProvider}>
    {children}
  </Refine>
);
