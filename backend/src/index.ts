import { Elysia } from 'elysia';
import { cors } from '@elysiajs/cors';
import { swagger } from '@elysiajs/swagger';
import { staticPlugin } from '@elysiajs/static';
import { join } from 'path';
import { config } from './config';
import { healthRoutes } from './routes/health';
import { guestUploadRoute } from './routes/guest-upload';
import { uploadRoutes } from './routes/upload';
import { notificationRoutes } from './routes/notifications';
import { guestRoutes } from './routes/guests';
import { exportRoutes } from './routes/export';
import { apiKeyGuard } from './middleware/api-key-guard';

const app = new Elysia()
  // Mobile app doesn't need browser CORS — disable for MVP
  .use(cors({ origin: false }))
  .use(swagger())
  .use(healthRoutes)
  // Static files — serve web guest page (before /api to avoid apiKeyGuard)
  .use(
    staticPlugin({
      prefix: '/guest',
      assets: join(import.meta.dir, '../web/guest'),
      index: 'index.html',
    }),
  )
  // Guest upload — no API key (guest web has no key)
  .use(guestUploadRoute)
  .group('/api', (app) =>
    app
      .use(apiKeyGuard)
      .use(uploadRoutes)
      .use(notificationRoutes)
      .use(guestRoutes)
      .use(exportRoutes),
  )
  .listen(config.port);

console.log(`🦊 TamuKu Backend running at http://${config.host}:${config.port}`);
console.log(`📚 Swagger docs at http://${config.host}:${config.port}/swagger`);

export type App = typeof app;
