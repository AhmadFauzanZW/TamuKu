/**
 * TamuKu Fix Host UID Script
 *
 * The setup script uses a hardcoded HOST_ID ('2utKhEE094jiCNiBN12'), but Firebase
 * Auth may assign a different UID when creating users via auth.createUser() or when
 * users sign in via email/password. This creates a mismatch between:
 *   - The host document ID (hosts/2utKhEE094jiCNiBN12)
 *   - The actual Firebase Auth UID for the admin email
 *
 * What this script does:
 *   1. Looks up the real Auth UID for the configured admin email
 *   2. If hosts/{realUid} doesn't exist, copies data from hosts/2utKhEE094jiCNiBN12
 *      and deletes the old document
 *   3. Updates ALL locations' adminId to the real UID
 *   4. Prints the real UID and verification
 *
 * Usage:
 *   bun run scripts/fix-host-uid.ts
 *
 * Prerequisites: serviceAccountKey.json in backend/ directory
 */

import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getAuth } from 'firebase-admin/auth';
import { readFileSync } from 'fs';
import { join } from 'path';

// --- Configuration ---
const OLD_HOST_ID = '2utKhEE094jiCNiBN12';
const ADMIN_EMAIL = process.env.ADMIN_EMAIL || ''; // Set ADMIN_EMAIL environment variable before running

// --- Initialize Firebase Admin ---
const serviceAccountPath = join(import.meta.dir, '..', 'serviceAccountKey.json');

try {
  readFileSync(serviceAccountPath);
} catch {
  console.error('❌ serviceAccountKey.json not found!');
  console.error(`   Expected at: ${serviceAccountPath}`);
  process.exit(1);
}

const serviceAccount = JSON.parse(readFileSync(serviceAccountPath, 'utf-8'));

initializeApp({ credential: cert(serviceAccount) });

const db = getFirestore();
const auth = getAuth();

// --- Main ---
async function fixHostUid() {
  console.log('🔧 TamuKu Fix Host UID');
  console.log('======================\n');

  // Step 1: Get real UID from Auth
  console.log('👤 Looking up real Auth UID...');
  let realUid: string;

  try {
    const userRecord = await auth.getUserByEmail(ADMIN_EMAIL);
    realUid = userRecord.uid;
    console.log(`   ✅ Found Auth user: ${ADMIN_EMAIL}`);
    console.log(`   🔑 Real UID: ${realUid}`);
  } catch (err: any) {
    console.error(`   ❌ Cannot find Auth user for ${ADMIN_EMAIL}`);
    console.error(`   Error: ${err.message}`);
    console.error('\n   Make sure the user exists in Firebase Authentication.');
    console.error('   Run setup-firestore.ts first: bun run scripts/setup-firestore.ts');
    process.exit(1);
  }

  if (realUid === OLD_HOST_ID) {
    console.log('\n✅ Real UID already matches the old host ID. No changes needed.');
    console.log('   Skipping copy/delete — the host document ID is correct.');
    await updateLocationAdminIds(realUid);
    return;
  }

  console.log(`\n⚠️  Real UID (${realUid}) differs from old host ID (${OLD_HOST_ID})`);

  // Step 2: Check if hosts/{realUid} exists
  const newHostRef = db.collection('hosts').doc(realUid);
  const newHostDoc = await newHostRef.get();

  if (newHostDoc.exists) {
    console.log(`\n📋 hosts/${realUid} already exists — skipping copy.`);
  } else {
    console.log(`\n📋 hosts/${realUid} does not exist — copying from old host...`);

    // Read old host document
    const oldHostRef = db.collection('hosts').doc(OLD_HOST_ID);
    const oldHostDoc = await oldHostRef.get();

    if (!oldHostDoc.exists) {
      console.error(`\n   ❌ Old host document (hosts/${OLD_HOST_ID}) not found!`);
      console.error('   Nothing to copy. Run setup-firestore.ts first.');
      process.exit(1);
    }

    const oldData = oldHostDoc.data()!;

    // Create new host document with real UID
    const newData = {
      ...oldData,
      // Ensure email matches
      email: ADMIN_EMAIL,
    };

    await newHostRef.set(newData);
    console.log(`   ✅ Created hosts/${realUid} with data from hosts/${OLD_HOST_ID}`);

    // Delete old host document
    await oldHostRef.delete();
    console.log(`   🗑️  Deleted old hosts/${OLD_HOST_ID}`);
  }

  // Step 3: Update all locations' adminId
  await updateLocationAdminIds(realUid);

  // Step 4: Print verification
  console.log('\n📊 Verification');
  console.log('   -------------');

  const hostVerify = await newHostRef.get();
  if (hostVerify.exists) {
    console.log(`   ✅ hosts/${realUid} — exists`);
    console.log(`      name: ${hostVerify.data()!.name}`);
    console.log(`      email: ${hostVerify.data()!.email}`);
    console.log(`      role: ${hostVerify.data()!.role}`);
    console.log(`      locations: ${JSON.stringify(hostVerify.data()!.locations)}`);
  } else {
    console.log(`   ❌ hosts/${realUid} — NOT FOUND (something went wrong)`);
  }

  const oldCheck = await db.collection('hosts').doc(OLD_HOST_ID).get();
  console.log(`   ${oldCheck.exists ? '❌' : '✅'} hosts/${OLD_HOST_ID} — ${oldCheck.exists ? 'STILL EXISTS (delete failed)' : 'deleted'}`);

  console.log('\n✅ Done!');
}

async function updateLocationAdminIds(realUid: string) {
  console.log('\n📍 Updating all locations...');

  const locationsRef = db.collection('locations');
  const snapshot = await locationsRef.get();

  if (snapshot.empty) {
    console.log('   📭 No locations found — skipping.');
    return;
  }

  let updated = 0;
  let skipped = 0;

  for (const doc of snapshot.docs) {
    const data = doc.data();
    const currentAdminId = data.adminId;

    if (currentAdminId !== realUid) {
      await doc.ref.update({ adminId: realUid });
      console.log(`   🔄 Updated location ${doc.id}: adminId ${currentAdminId} → ${realUid}`);
      updated++;
    } else {
      skipped++;
    }
  }

  console.log(`   ✅ ${updated} location(s) updated, ${skipped} already correct.`);
}

fixHostUid().catch((err) => {
  console.error('\n💥 Script failed:', err);
  process.exit(1);
});
