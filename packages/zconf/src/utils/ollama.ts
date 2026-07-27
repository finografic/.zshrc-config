/**
 * Thin Ollama HTTP client. Deliberately not the Vercel AI SDK: this is one
 * local-only, one-shot generate call — no streaming, no provider-switching,
 * nothing the SDK's abstractions earn their keep on yet. If this grows into a
 * multi-provider tool later (a cloud fallback when Ollama isn't running),
 * that's the point to reconsider it.
 */

const DEFAULT_HOST = 'http://localhost:11434';
/** Detection call — Ollama not running should fail fast, not hang the commit. */
const TAGS_TIMEOUT_MS = 1000;
/** Generation call — a cold model load (observed ~9s for a 4B model) can be slow; still bounded. */
const GENERATE_TIMEOUT_MS = 30000;

export function resolveOllamaHost(): string {
  return process.env.OLLAMA_HOST?.trim() || DEFAULT_HOST;
}

export function resolveOllamaKeepAlive(
  value: string | undefined = process.env.OLLAMA_KEEP_ALIVE,
): string | undefined {
  const keepAlive = value?.trim();
  return keepAlive === '' ? undefined : keepAlive;
}

export function buildGeneratePayload(
  model: string,
  prompt: string,
  keepAlive: string | undefined = resolveOllamaKeepAlive(),
): { model: string; prompt: string; stream: false; keep_alive?: string } {
  return {
    model,
    prompt,
    stream: false,
    ...(keepAlive === undefined ? {} : { keep_alive: keepAlive }),
  };
}

async function withTimeout<T>(promise: Promise<T>, ms: number): Promise<T> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), ms);
  try {
    return await promise;
  } finally {
    clearTimeout(timer);
  }
}

/** Lists installed model names (e.g. `gemma4:e4b-it-qat`). Empty on any failure. */
export async function listInstalledModels(host: string): Promise<string[]> {
  try {
    const response = await withTimeout(
      fetch(`${host}/api/tags`, { signal: AbortSignal.timeout(TAGS_TIMEOUT_MS) }),
      TAGS_TIMEOUT_MS,
    );
    if (!response.ok) return [];

    const body = (await response.json()) as { models?: Array<{ name?: string }> };
    return (body.models ?? []).map((m) => m.name).filter((name): name is string => Boolean(name));
  } catch {
    return [];
  }
}

/** Runs one generation call. Returns null on any failure — callers fall back silently. */
export async function generate(host: string, model: string, prompt: string): Promise<string | null> {
  try {
    const response = await withTimeout(
      fetch(`${host}/api/generate`, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify(buildGeneratePayload(model, prompt)),
        signal: AbortSignal.timeout(GENERATE_TIMEOUT_MS),
      }),
      GENERATE_TIMEOUT_MS,
    );
    if (!response.ok) return null;

    const body = (await response.json()) as { response?: string };
    return body.response ?? null;
  } catch {
    return null;
  }
}
