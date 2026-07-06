import { Elysia } from 'elysia';
import { cors } from '@elysiajs/cors';
import { swagger } from '@elysiajs/swagger';
import { config } from './config';
import { healthRoutes } from './routes/health';
import { uploadRoutes } from './routes/upload';
import { notificationRoutes } from './routes/notifications';
import { guestRoutes } from './routes/guests';
import { apiKeyGuard } from './middleware/api-key-guard';

const app = new Elysia()
  // Mobile app doesn't need browser CORS — disable for MVP
  .use(cors({ origin: false }))
  .use(swagger())
  .use(healthRoutes)
  .group('/api', (app) =>
    app
      .use(apiKeyGuard)
      .use(uploadRoutes)
      .use(notificationRoutes)
      .use(guestRoutes),
  )
  .listen(config.port);

console.log(`🦊 TamuKu Backend running at http://${config.host}:${config.port}`);
console.log(`📚 Swagger docs at http://${config.host}:${config.port}/swagger`);

export type App = typeof app;
