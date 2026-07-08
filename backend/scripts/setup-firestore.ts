/**
 * TamuKu Firestore Setup Script
 *
 * Creates/updates the initial Firestore documents for:
 * - Super Admin host
 * - Default location
 * - Links them together
 *
 * Usage: bun run scripts/setup-firestore.ts
 *
 * Prerequisites: serviceAccountKey.json in backend/ directory
 */

import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getAuth } from 'firebase-admin/auth';
import { readFileSync } from 'fs';
import { join } from 'path';

// --- Configuration ---
const HOST_ID = '2utKhEE094jiCNiBN12'; // Your Firebase Auth UID
const LOCATION_ID = 'os7bez2TcYgh3HyvfxUv'; // Your existing location document ID

const HOST_DATA = {
  name: 'Super Admin',
  email: 'ahfa201204@gmail.com',  // ← Update if different
  phone: '082132290468',
  photoUrl: null,
  locations: [LOCATION_ID],
  role: 'super_admin',
  createdAt: new Date('2026-07-05'),
  lastLogin: null,
  isActive: true,
};

const LOCATION_DATA = {
  name: 'Kantor Universitas Cakrawala',
  address: 'Jl. Merdeka No. 17, Bandung',
  adminId: HOST_ID,
  hostPhone: '082132290468',
  qrCodeValue: LOCATION_ID,
  createdAt: new Date('2026-07-05'),
  isActive: true,
};

// --- Initialize Firebase Admin ---
const serviceAccountPath = join(import.meta.dir, '..', 'serviceAccountKey.json');

try {
  readFileSync(serviceAccountPath);
} catch {
  console.error('❌ serviceAccountKey.json not found!');
  console.error('   Download it from: Firebase Console → Project Settings → Service accounts → Generate new private key');
  console.error(`   Save it to: ${serviceAccountPath}`);
  process.exit(1);
}

const serviceAccount = JSON.parse(readFileSync(serviceAccountPath, 'utf-8'));

initializeApp({
  credential: cert(serviceAccount),
});

const db = getFirestore();
const auth = getAuth();

// --- Password from CLI args or default ---
const PASSWORD = process.argv[2] || 'admin123';

// --- Main ---
async function setup() {
  console.log('🔥 TamuKu Firestore Setup');
  console.log('========================\n');

  // 0. Create/Update Firebase Auth user
  console.log('👤 Setting up Firebase Auth user...');
  try {
    const existingUser = await auth.getUserByEmail(HOST_DATA.email).catch(() => null);

    if (existingUser) {
      // Update password
      await auth.updateUser(existingUser.uid, { password: PASSWORD });
      console.log('   ✅ Updated existing Auth user password');
      console.log(`   📧 Email: ${HOST_DATA.email}`);
    } else {
      // Create new Auth user with specific UID
      await auth.createUser({
        uid: HOST_ID,
        email: HOST_DATA.email,
        password: PASSWORD,
        displayName: HOST_DATA.name,
      });
      console.log('   ✅ Created new Auth user');
      console.log(`   📧 Email: ${HOST_DATA.email}`);
      console.log(`   🔑 Password: ${PASSWORD}`);
    }
  } catch (err: any) {
    console.error(`   ❌ Auth setup failed: ${err.message}`);
    console.error('   Continuing with Firestore setup...');
  }

  // 1. Create/Update Super Admin Host
  console.log('📋 Setting up Super Admin host...');
  const hostRef = db.collection('hosts').doc(HOST_ID);
  const hostDoc = await hostRef.get();

  if (hostDoc.exists) {
    // Update existing document — merge new fields
    await hostRef.set(HOST_DATA, { merge: true });
    console.log('   ✅ Updated existing host document');
    console.log(`   📄 Document ID: ${HOST_ID}`);
  } else {
    // Create new document
    await hostRef.set(HOST_DATA);
    console.log('   ✅ Created new host document');
    console.log(`   📄 Document ID: ${HOST_ID}`);
  }

  // 2. Create/Update Location
  console.log('\n📍 Setting up Location...');
  const locRef = db.collection('locations').doc(LOCATION_ID);
  const locDoc = await locRef.get();

  if (locDoc.exists) {
    await locRef.set(LOCATION_DATA, { merge: true });
    console.log('   ✅ Updated existing location document');
    console.log(`   📄 Document ID: ${LOCATION_ID}`);
  } else {
    await locRef.set(LOCATION_DATA);
    console.log('   ✅ Created new location document');
    console.log(`   📄 Document ID: ${LOCATION_ID}`);
  }

  // 3. Verify
  console.log('\n🔍 Verifying setup...');
  const verifyHost = await hostRef.get();
  const verifyLoc = await locRef.get();

  if (verifyHost.exists && verifyLoc.exists) {
    const h = verifyHost.data()!;
    const l = verifyLoc.data()!;

    console.log('   ✅ Host verified:');
    console.log(`      - name: ${h.name}`);
    console.log(`      - role: ${h.role}`);
    console.log(`      - locations: [${h.locations?.join(', ')}]`);
    console.log(`      - isActive: ${h.isActive}`);

    console.log('   ✅ Location verified:');
    console.log(`      - name: ${l.name}`);
    console.log(`      - address: ${l.address}`);
    console.log(`      - adminId: ${l.adminId}`);
    console.log(`      - isActive: ${l.isActive}`);

    // 4. Check guests
    const guestsSnap = await db.collection('guests').get();
    console.log(`\n👥 Existing guests: ${guestsSnap.size}`);

    console.log('\n🎉 Firestore setup complete!');
    console.log('   You can now:');
    console.log('   1. Run the admin dashboard: cd ../admin-web && bun run dev');
    console.log('   2. Login with: ahfa201204@gmail.com');
    console.log('   3. Create more locations and hosts from the dashboard');
  } else {
    console.error('   ❌ Verification failed — documents not found after write');
  }
}

setup().catch((err) => {
  console.error('\n❌ Setup failed:', err.message);
  process.exit(1);
});
