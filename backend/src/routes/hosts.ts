import { Elysia, t } from 'elysia';
import * as admin from 'firebase-admin';
import { readFileSync, existsSync } from 'fs';
import { resolve } from 'path';
import { config } from '../config';

let fbInit = false;

function ensureFirebase() {
  if (fbInit) return;
  const saPath = resolve(config.firebase.serviceAccountPath);
  console.log(`[Hosts] Resolved service account path: ${saPath}`);
  console.log(`[Hosts] File exists: ${existsSync(saPath)}`);
  const raw = readFileSync(saPath, 'utf-8');
  const sa = JSON.parse(raw);
  console.log(`[Hosts] Service account project_id: ${sa.project_id}`);
  console.log(`[Hosts] Service account keys: ${Object.keys(sa).join(', ')}`);
  admin.initializeApp({ credential: admin.credential.cert(sa) });
  fbInit = true;
}

/**
 * Host management routes — uses Admin SDK (bypasses Firestore rules).
 * Protected by apiKeyGuard (registered in /api group).
 */
export const hostsRoute = new Elysia().post(
  '/hosts',
  async ({ body }) => {
    // Inline validation (before Admin SDK calls)
    if (!body.name?.trim()) return { success: false, error: 'Nama wajib diisi' };
    if (!body.email?.trim()) return { success: false, error: 'Email wajib diisi' };
    if (!body.phone?.trim()) return { success: false, error: 'Nomor telepon wajib diisi' };
    if (!body.password || body.password.length < 6) {
      return { success: false, error: 'Kata sandi minimal 6 karakter' };
    }

    const validRoles = ['super_admin', 'admin', 'host'] as const;
    const hostRole = validRoles.includes(body.role as any) ? body.role : 'host';

    try {
      ensureFirebase();
      const auth = admin.auth();
      const db = admin.firestore();

      // 1. Create Firebase Auth user (Admin SDK — no auto sign-in)
      const userRecord = await auth.createUser({
        email: body.email.trim(),
        password: body.password,
        displayName: body.name.trim(),
      });

      // 2. Create host document with Auth UID as doc ID
      await db.collection('hosts').doc(userRecord.uid).set({
        name: body.name.trim(),
        email: body.email.trim(),
        phone: body.phone.trim(),
        photoUrl: null,
        locations: [],
        role: hostRole,
        isActive: body.isActive ?? true,
        createdAt: new Date(),
        lastLogin: null,
      });

      return {
        success: true,
        data: { uid: userRecord.uid, email: userRecord.email },
      };
    } catch (err: any) {
      console.error('Host creation error:', err);
      if (err.code === 'auth/email-already-exists') {
        return { success: false, error: 'Email sudah digunakan oleh akun lain' };
      }
      // If Auth user created but Firestore write failed, the Auth user becomes orphan.
      // Future: add cleanup logic or a scheduled job to reconcile orphans.
      return { success: false, error: 'Gagal membuat akun host' };
    }
  },
  {
    body: t.Object({
      name: t.String(),
      email: t.String(),
      phone: t.String(),
      password: t.String(),
      role: t.Optional(t.String()),
      isActive: t.Optional(t.Boolean()),
    }),
  },
);
