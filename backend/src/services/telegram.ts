import { config } from '../config';

const TELEGRAM_API = 'https://api.telegram.org/bot';

/**
 * Send a text message via Telegram Bot API.
 * Uses native fetch — no external HTTP dependency.
 * Always uses server-configured bot token — client cannot override.
 * @param chatId — Telegram chat/group ID (numeric or @username)
 * @param text — Message content (supports HTML parse_mode)
 * @returns true on success
 */
export async function sendTelegramMessage(
  chatId: string,
  text: string,
): Promise<boolean> {
  const token = config.telegram.botToken;
  if (!token) throw new Error('Telegram bot token not configured');

  const url = `${TELEGRAM_API}${token}/sendMessage`;
  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      chat_id: chatId,
      text,
      parse_mode: 'HTML',
      disable_web_page_preview: true,
    }),
  });

  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(
      `Telegram API error (${res.status}): ${err.description || res.statusText}`,
    );
  }

  return true;
}

/** Params for guest check-in notification */
export interface GuestNotificationParams {
  hostPhone: string;
  guestName: string;
  keperluan: string;
  instansi?: string;
  locationName: string;
}

/**
 * Format and send a guest check-in notification via Telegram.
 * Constructs a human-readable message in Bahasa Indonesia.
 * Bot token is always loaded from server config — never from client.
 */
export async function sendGuestNotification(
  params: GuestNotificationParams,
): Promise<boolean> {
  const { hostPhone, guestName, keperluan, instansi, locationName } = params;

  const lines = [
    `🏢 <b>Tamu Baru — ${locationName}</b>`,
    '',
    `👤 <b>Nama:</b> ${guestName}`,
    `📋 <b>Keperluan:</b> ${keperluan}`,
  ];

  if (instansi) lines.push(`🏛️ <b>Instansi:</b> ${instansi}`);
  lines.push(
    '',
    `🕐 ${new Date().toLocaleString('id-ID', { timeZone: 'Asia/Jakarta' })}`,
  );

  return sendTelegramMessage(hostPhone, lines.join('\n'));
}

/** Alias for backward compatibility */
export { sendTelegramMessage as sendTelegram };
