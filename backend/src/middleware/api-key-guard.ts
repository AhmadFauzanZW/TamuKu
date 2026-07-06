import { Elysia } from 'elysia';
import { config } from '../config';

/**
 * API key authentication guard for all /api/* routes.
 * Reads x-api-key header and validates against server config.
 */
export const apiKeyGuard = new Elysia().onBeforeHandle(({ request }) => {
  const apiKey = request.headers.get('x-api-key');
  if (!apiKey || apiKey !== config.apiKey) {
    return { success: false, error: 'Unauthorized: API key tidak valid' };
  }
});
