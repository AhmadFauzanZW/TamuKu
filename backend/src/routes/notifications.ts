import { Elysia, t } from 'elysia';
import { sendNotification } from '../services/fcm';
import { sendTelegramMessage } from '../services/telegram';

export const notificationRoutes = new Elysia()
  // Send FCM push notification
  .post(
    '/notifications/send',
    async ({ body }) => {
      try {
        const messageId = await sendNotification(
          body.token,
          body.title,
          body.body,
          body.data,
        );
        return { success: true, data: { messageId } };
      } catch (error: any) {
        return {
          success: false,
          error: error.message || 'Gagal mengirim notifikasi push',
        };
      }
    },
    {
      body: t.Object({
        token: t.String(),
        title: t.String(),
        body: t.String(),
        data: t.Optional(t.Record(t.String(), t.String())),
      }),
    },
  )
  // Send Telegram notification
  .post(
    '/notifications/telegram',
    async ({ body }) => {
      try {
        await sendTelegramMessage(body.chatId, body.text, body.botToken);
        return { success: true };
      } catch (error: any) {
        return {
          success: false,
          error: error.message || 'Gagal mengirim notifikasi Telegram',
        };
      }
    },
    {
      body: t.Object({
        chatId: t.String(),
        text: t.String(),
        botToken: t.Optional(t.String()),
      }),
    },
  );
