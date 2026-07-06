import { Elysia, t } from 'elysia';
import { sendNotification } from '../services/fcm';
import { sendGuestNotification } from '../services/telegram';

/**
 * Guest check-in notification route.
 * POST /api/guests/notify — Notify host via FCM push + Telegram when guest checks in.
 */
export const guestRoutes = new Elysia().post(
  '/guests/notify',
  async ({ body }) => {
    const errors: string[] = [];

    // Send FCM push notification (if token provided)
    let fcmResult: { success: boolean; messageId?: string } | null = null;
    if (body.hostFcmToken) {
      try {
        const messageId = await sendNotification(
          body.hostFcmToken,
          `Tamu Baru: ${body.guestName}`,
          `${body.guestName} — ${body.keperluan}${body.instansi ? ` (${body.instansi})` : ''}`,
          {
            type: 'guest_checkin',
            guestName: body.guestName,
            keperluan: body.keperluan,
            locationName: body.locationName,
          },
        );
        fcmResult = { success: true, messageId };
      } catch {
        errors.push('FCM: Gagal mengirim notifikasi push');
        fcmResult = { success: false };
      }
    }

    // Send Telegram notification (if hostPhone provided)
    let telegramResult: { success: boolean } | null = null;
    if (body.hostPhone) {
      try {
        await sendGuestNotification({
          hostPhone: body.hostPhone,
          guestName: body.guestName,
          keperluan: body.keperluan,
          instansi: body.instansi,
          locationName: body.locationName,
        });
        telegramResult = { success: true };
      } catch {
        errors.push('Telegram: Gagal mengirim notifikasi');
        telegramResult = { success: false };
      }
    }

    const overallSuccess =
      (fcmResult?.success ?? true) && (telegramResult?.success ?? true);

    return {
      success: overallSuccess,
      data: {
        fcm: fcmResult,
        telegram: telegramResult,
      },
      ...(errors.length > 0 ? { error: errors.join('; ') } : {}),
    };
  },
  {
    body: t.Object({
      guestName: t.String(),
      keperluan: t.String(),
      instansi: t.Optional(t.String()),
      locationName: t.String(),
      hostFcmToken: t.Optional(t.String()),
      hostPhone: t.Optional(t.String()),
    }),
  },
);
