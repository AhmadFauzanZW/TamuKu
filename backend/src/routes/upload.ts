import { Elysia, t } from 'elysia';
import { generatePresignedUrl } from '../services/s3';
import { config } from '../config';

const ALLOWED_MIME_TYPES = ['image/jpeg', 'image/png', 'image/webp'];

export const uploadRoutes = new Elysia().post(
  '/upload/url',
  async ({ body }) => {
    try {
      if (!ALLOWED_MIME_TYPES.includes(body.contentType)) {
        return {
          success: false,
          error: 'Tipe file tidak didukung. Gunakan JPEG, PNG, atau WebP',
        };
      }

      const ext = body.contentType.split('/')[1] || 'jpg';
      const objectName = `guests/${crypto.randomUUID()}.${ext}`;
      const uploadUrl = await generatePresignedUrl(objectName);
      const fileUrl = `https://${config.s3.endPoint}/${config.s3.bucketName}/${objectName}`;
      return { success: true, data: { uploadUrl, fileUrl, objectName } };
    } catch {
      return { success: false, error: 'Gagal membuat URL upload' };
    }
  },
  {
    body: t.Object({
      contentType: t.String(),
    }),
  },
);
