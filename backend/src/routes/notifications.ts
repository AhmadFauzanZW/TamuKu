import { Elysia, t } from 'elysia';
import { sendNotification } from '../services/fcm';
import { sendTelegramMessage } from '../services/telegram';

export const notificationRoutes = new Elysia()
  // Send FCM push notification
  .post(
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
  )
  // Send Telegram notification
  .post(
    '/notifications/telegram',
    async ({ body }) => {
      await sendTelegramMessage(body.chatId, body.text);
      return { success: true };
    },
    {
      body: t.Object({
        chatId: t.String(),
        text: t.String(),
      }),
    }
  );
