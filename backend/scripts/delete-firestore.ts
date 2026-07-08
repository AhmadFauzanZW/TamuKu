/**
 * TamuKu Firestore Delete Script
 * 
 * Usage:
 *   bun run scripts/delete-firestore.ts                    # Delete ALL data
 *   bun run scripts/delete-firestore.ts guests             # Delete only guests
 *   bun run scripts/delete-firestore.ts hosts              # Delete only hosts
 *   bun run scripts/delete-firestore.ts locations          # Delete only locations
 *   bun run scripts/delete-firestore.ts all                # Delete everything
 * 
 * ⚠️  DESTRUCTIVE — cannot be undone!
 */

import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getAuth } from 'firebase-admin/auth';
import { readFileSync } from 'fs';
import { join } from 'path';

const COLLECTIONS = ['guests', 'hosts', 'locations'] as const;

// --- Init ---
const serviceAccountPath = join(import.meta.dir, '..', 'serviceAccountKey.json');
try {
  readFileSync(serviceAccountPath);
} catch {
  console.error('❌ serviceAccountKey.json not found!');
  process.exit(1);
}

const serviceAccount = JSON.parse(readFileSync(serviceAccountPath, 'utf-8'));
initializeApp({ credential: cert(serviceAccount) });
const db = getFirestore();
const auth = getAuth();

// --- Delete all docs in a collection ---
async function deleteCollection(name: string) {
  const ref = db.collection(name);
  const snapshot = await ref.get();
  
  if (snapshot.empty) {
    console.log(`   📭 ${name}: already empty`);
    return 0;
  }

  const batch = db.batch();
  let count = 0;

  for (const doc of snapshot.docs) {
    batch.delete(doc.ref);
    count++;

    // Firestore batch limit is 500
    if (count % 500 === 0) {
      await batch.commit();
      console.log(`   🗑️  ${name}: deleted ${count} docs...`);
    }
  }

  if (count % 500 !== 0) {
    await batch.commit();
  }

  console.log(`   ✅ ${name}: deleted ${count} docs`);
  return count;
}

// --- Delete all Firebase Auth users ---
async function deleteAllAuthUsers() {
  let count = 0;
  let nextPageToken: string | undefined;

  do {
    const result = await auth.listUsers(1000, nextPageToken);
    for (const user of result.users) {
      await auth.deleteUser(user.uid);
      count++;
    }
    nextPageToken = result.pageToken;
  } while (nextPageToken);

  console.log(`   ✅ auth users: deleted ${count} users`);
  return count;
}

// --- Main ---
async function main() {
  const target = process.argv[2]?.toLowerCase();

  console.log('🗑️  TamuKu Firestore Delete');
  console.log('===========================\n');

  if (target === 'auth') {
    console.log('👤 Deleting Firebase Auth users...\n');
    await deleteAllAuthUsers();
  } else if (target && COLLECTIONS.includes(target as any)) {
    console.log(`📋 Deleting collection: ${target}\n`);
    await deleteCollection(target);
  } else if (!target || target === 'all') {
    console.log('⚠️  Deleting ALL data!\n');

    for (const col of COLLECTIONS) {
      await deleteCollection(col);
    }

    console.log('\n👤 Deleting Firebase Auth users...');
    await deleteAllAuthUsers();
  } else {
    console.error(`❌ Unknown target: "${target}"`);
    console.error('   Valid targets: guests, hosts, locations, auth, all');
    process.exit(1);
  }

  console.log('\n🎉 Done!');
}

main().catch((err) => {
  console.error('\n❌ Failed:', err.message);
  process.exit(1);
});
