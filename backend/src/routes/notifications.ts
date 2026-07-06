import { Elysia, t } from 'elysia';
import { sendNotification } from '../services/fcm';

export const notificationRoutes = new Elysia().post(
  '/notifications/send',
  async ({ body }) => {
    const result = await sendNotification(
      body.token,
      body.title,
      body.body,
      body.data,
    );
    return { success: true, messageId: result };
  },
  {
    body: t.Object({
      token: t.String(),
      title: t.String(),
      body: t.String(),
      data: t.Optional(t.Record(t.String(), t.String())),
    }),
  }
);
