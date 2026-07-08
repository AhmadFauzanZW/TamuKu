import { Elysia, t } from 'elysia';
import {
  generatePresignedUrl,
  generatePresignedGetUrl,
  getObjectNameFromUrl,
} from '../services/s3';
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
)
/**
 * GET /api/guests/photo-url — generate presigned GET URL for guest photos.
 * No API key required (guest web / Flutter app has no key).
 */
.get(
  '/api/guests/photo-url',
  async ({ query }) => {
    const { url } = query;
    if (!url) {
      return { success: false, error: 'Parameter url diperlukan' };
    }

    const objectName = getObjectNameFromUrl(url as string);
    if (!objectName) {
      return { success: false, error: 'URL S3 tidak valid' };
    }

    try {
      const signedUrl = await generatePresignedGetUrl(objectName, 3600);
      return { success: true, data: { signedUrl } };
    } catch (err) {
      console.error('Presigned GET error:', err);
      return { success: false, error: 'Gagal membuat URL akses foto' };
    }
  },
);
