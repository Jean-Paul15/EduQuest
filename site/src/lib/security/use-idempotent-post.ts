"use client";

import { useCallback, useState } from "react";
import {
  postJsonWithIdem,
  type PostJsonWithIdemOptions,
} from "@/lib/security/fetch-with-idempotency";

type RunOptions = PostJsonWithIdemOptions & {
  successMessage?: string;
  errorMessage?: string;
};

type RunResult<T> = {
  response: Response | null;
  data: T | null;
  error: unknown | null;
};

const readJson = async <T>(response: Response): Promise<T | null> => {
  try {
    return (await response.json()) as T;
  } catch {
    return null;
  }
};

const readMessage = (data: unknown) => {
  if (!data || typeof data !== "object") return "";
  const msg = (data as { message?: unknown }).message;
  return typeof msg === "string" ? msg : "";
};

export const useIdempotentPost = () => {
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState("");

  const run = useCallback(async <T>(options: RunOptions): Promise<RunResult<T>> => {
    setBusy(true);
    setMessage("");
    try {
      const response = await postJsonWithIdem(options);
      const data = await readJson<T>(response);
      const messageFromApi = readMessage(data);
      if (messageFromApi) setMessage(messageFromApi);
      else if (response.ok) setMessage(options.successMessage || "Opération terminée.");
      else setMessage(options.errorMessage || "Une erreur est survenue.");
      return { response, data, error: null };
    } catch (error) {
      setMessage(options.errorMessage || "Erreur réseau.");
      return { response: null, data: null, error };
    } finally {
      setBusy(false);
    }
  }, []);

  return { busy, message, setMessage, run };
};
