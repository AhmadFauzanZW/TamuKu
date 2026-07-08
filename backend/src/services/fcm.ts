import admin from 'firebase-admin';
import { config } from '../config';
import { readFileSync } from 'fs';

let initialized = false;

function getFirebaseCredentials() {
  if (config.firebase.serviceAccountJson) {
    return JSON.parse(config.firebase.serviceAccountJson);
  }
  return JSON.parse(readFileSync(config.firebase.serviceAccountPath, 'utf-8'));
}

export function initFirebase() {
  if (initialized) return;
  const serviceAccount = getFirebaseCredentials();
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
