import { Elysia, t } from 'elysia';
import { generatePresignedUrl } from '../services/s3';
import { config } from '../config';

const ALLOWED_MIME_TYPES = ['image/jpeg', 'image/png', 'image/webp'];

/**
 * Guest photo upload — generates presigned S3 URL.
 * No API key required (guest web has no key).
 * Registered outside /api group to bypass apiKeyGuard.
 */
export const guestUploadRoute = new Elysia().post(
  '/api/guests/upload',
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
    } catch (err) {
      console.error('Guest upload error:', err);
      return { success: false, error: 'Gagal membuat URL upload' };
    }
  },
  {
    body: t.Object({
      contentType: t.String(),
    }),
  },
);
