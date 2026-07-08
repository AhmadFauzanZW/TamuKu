/**
 * Runtime config resolver.
 * Priority: window.__APP_CONFIG__ (runtime) > import.meta.env (build-time) > fallback
 */

interface AppConfig {
  apiBaseUrl: string;
  apiKey: string;
}

declare global {
  interface Window {
    __APP_CONFIG__?: Record<string, string>;
  }
}

const runtimeConfig = window.__APP_CONFIG__ ?? {};

function resolveString(...candidates: (string | undefined)[]): string {
  for (const c of candidates) {
    if (c && c.trim()) return c.trim();
  }
  return '';
}

export const appConfig: AppConfig = {
  apiBaseUrl: resolveString(
    runtimeConfig.apiBaseUrl || runtimeConfig.VITE_BACKEND_URL,
    import.meta.env.VITE_BACKEND_URL,
    'http://localhost:3000',
  ),
  apiKey: resolveString(
    runtimeConfig.apiKey || runtimeConfig.VITE_API_KEY,
    import.meta.env.VITE_API_KEY,
    '',
  ),
};
