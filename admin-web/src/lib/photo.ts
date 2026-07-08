const API_BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';

/**
 * Fetch a presigned S3 URL for a guest photo via the backend API.
 * Returns the signed URL on success, or the raw URL as fallback.
 */
export async function getSignedPhotoUrl(rawUrl: string): Promise<string> {
  if (!rawUrl) return '';
  try {
    const res = await fetch(
      `${API_BASE}/api/guests/photo-url?url=${encodeURIComponent(rawUrl)}`,
    );
    const json = await res.json();
    if (json.success) return json.data.signedUrl as string;
  } catch {
    /* fallback */
  }
  return rawUrl;
}
