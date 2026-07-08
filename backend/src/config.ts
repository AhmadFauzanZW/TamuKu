import 'dotenv/config';

function parseFirebaseServiceAccount(): string | null {
  const jsonStr = process.env.FIREBASE_SERVICE_ACCOUNT;
  if (jsonStr) {
    try {
      JSON.parse(jsonStr);
      return jsonStr;
    } catch {
      console.error('⚠️ FIREBASE_SERVICE_ACCOUNT is not valid JSON');
    }
  }
  return null;
}

export const config = {
  port: Number(process.env.PORT) || 3000,
  host: process.env.HOST || '0.0.0.0',
  apiKey: process.env.API_KEY || '',
  s3: {
    endPoint: process.env.S3_ENDPOINT || 'sg.contabostorage.com',
    accessKey: process.env.S3_ACCESS_KEY || '',
    secretKey: process.env.S3_SECRET_KEY || '',
    bucketName: process.env.S3_BUCKET || 'tamuku-guest-photos',
    useSsl: process.env.S3_USE_SSL !== 'false',
  },
  firebase: {
    serviceAccountJson: parseFirebaseServiceAccount(),
    serviceAccountPath: process.env.FIREBASE_SERVICE_ACCOUNT_PATH || './serviceAccountKey.json',
  },
  telegram: {
    botToken: process.env.TELEGRAM_BOT_TOKEN || '',
    chatId: process.env.TELEGRAM_CHAT_ID || '',
  },
  corsOrigins: process.env.CORS_ORIGINS
    ? process.env.CORS_ORIGINS.split(',').map((s) => s.trim())
    : ['http://localhost:5173', 'http://localhost:3000'],
} as const;
