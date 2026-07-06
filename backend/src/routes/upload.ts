import { Elysia, t } from 'elysia';
import { generatePresignedUrl } from '../services/s3';
import { config } from '../config';

export const uploadRoutes = new Elysia().post(
  '/upload/url',
  async ({ body }) => {
    const ext = body.contentType.split('/')[1] || 'jpg';
    const objectName = `guests/${crypto.randomUUID()}.${ext}`;
    const uploadUrl = await generatePresignedUrl(objectName);
    const fileUrl = `https://${config.s3.endPoint}/${config.s3.bucketName}/${objectName}`;
    return { uploadUrl, fileUrl, objectName };
  },
  {
    body: t.Object({
      contentType: t.String(),
    }),
  }
);
