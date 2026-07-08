import * as Minio from 'minio';
import { config } from '../config';

export const s3Client = new Minio.Client({
  endPoint: config.s3.endPoint,
  useSSL: config.s3.useSsl,
  accessKey: config.s3.accessKey,
  secretKey: config.s3.secretKey,
});

export async function generatePresignedUrl(objectName: string): Promise<string> {
  return s3Client.presignedPutObject(config.s3.bucketName, objectName, 60 * 15); // 15 min
}

export async function generatePresignedGetUrl(
  objectName: string,
  expiresIn = 3600,
): Promise<string> {
  return s3Client.presignedGetObject(config.s3.bucketName, objectName, expiresIn);
}

export function getObjectNameFromUrl(url: string): string | null {
  const bucketUrl = `https://${config.s3.endPoint}/${config.s3.bucketName}/`;
  if (url.startsWith(bucketUrl)) {
    return url.substring(bucketUrl.length);
  }
  return null;
}

export async function checkBucketExists(): Promise<boolean> {
  return s3Client.bucketExists(config.s3.bucketName);
}
