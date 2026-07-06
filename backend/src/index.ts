import { Elysia } from 'elysia';
import { cors } from '@elysiajs/cors';
import { swagger } from '@elysiajs/swagger';
import { config } from './config';
import { healthRoutes } from './routes/health';
import { uploadRoutes } from './routes/upload';
import { notificationRoutes } from './routes/notifications';

const app = new Elysia()
  .use(cors())
  .use(swagger())
  .use(healthRoutes)
  .use(uploadRoutes.group('/api'))
  .use(notificationRoutes.group('/api'))
  .listen(config.port);

console.log(`🦊 TamuKu Backend running at http://${config.host}:${config.port}`);
console.log(`📚 Swagger docs at http://${config.host}:${config.port}/swagger`);

export type App = typeof app;
