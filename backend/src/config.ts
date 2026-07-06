import 'dotenv/config';

export const config = {
  port: Number(process.env.PORT) || 3000,
  host: process.env.HOST || '0.0.0.0',
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
} as const;
