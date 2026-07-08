import admin from 'firebase-admin';
import { config } from '../config';
import { readFileSync } from 'fs';

let initialized = false;

export function initFirebase() {
  if (initialized) return;
  const serviceAccount = JSON.parse(readFileSync(config.firebase.serviceAccountPath, 'utf-8'));
  admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
  initialized = true;
}

export async function sendNotification(token: string, title: string, body: string, data: Record<string, string> = {}) {
  initFirebase();
  return admin.messaging().send({
    token,
    notification: { title, body },
    data,
  });
}
