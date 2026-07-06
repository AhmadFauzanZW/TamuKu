import { config } from '../config';

/**
 * Send notification via Telegram Bot API.
 * Bot must be created via @BotFather on Telegram.
 */
export async function sendTelegramMessage(
  chatId: string,
  text: string,
): Promise<void> {
  const url = `https://api.telegram.org/bot${config.telegram.botToken}/sendMessage`;
  const response = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      chat_id: chatId,
      text,
      parse_mode: 'HTML',
    }),
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Telegram API error: ${response.status} ${error}`);
  }
}
