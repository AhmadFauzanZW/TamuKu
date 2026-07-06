import { Elysia } from 'elysia';
import { checkBucketExists } from '../services/s3';

export const healthRoutes = new Elysia().get('/health', async () => {
  const s3Healthy = await checkBucketExists().catch(() => false);
  return {
    status: 'ok',
    timestamp: new Date().toISOString(),
    services: {
      s3: s3Healthy ? 'connected' : 'unavailable',
      firebase: 'configured',
    },
  };
});
