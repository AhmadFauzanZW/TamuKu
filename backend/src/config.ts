import 'dotenv/config';

export const config = {
  port: Number(process.env.PORT) || 3000,
  host: process.env.HOST || '0.0.0.0',
  apiKey: process.env.API_KEY || 'tamuku-dev-key-2026',
  s3: {
    endPoint: process.env.S3_ENDPOINT || 'sg.contabostorage.com',
    accessKey: process.env.S3_ACCESS_KEY || '',
    secretKey: process.env.S3_SECRET_KEY || '',
    bucketName: process.env.S3_BUCKET || 'tamuku-guest-photos',
    useSsl: process.env.S3_USE_SSL !== 'false',
  },
  firebase: {
    serviceAccountPath: process.env.FIREBASE_SERVICE_ACCOUNT_PATH || './serviceAccountKey.json',
  },
  telegram: {
    botToken: process.env.TELEGRAM_BOT_TOKEN || '',
    chatId: process.env.TELEGRAM_CHAT_ID || '',
  },
} as const;
