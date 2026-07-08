import { useState, useEffect, useCallback } from 'react';
import {
  onAuthStateChanged,
  signInWithEmailAndPassword,
  signOut as firebaseSignOut,
} from 'firebase/auth';
import type { User } from 'firebase/auth';
import { doc, getDoc, collection, getDocs } from 'firebase/firestore';
import { auth, db } from '../config/firebase';
import type { Host } from '../types';

interface AuthState {
  user: User | null;
  hostData: Host | null;
  loading: boolean;
  error: string | null;
}

/** Find host document by Auth UID or email fallback. Logs every step. */
async function findHost(user: User): Promise<Host | null> {
  console.log(`[Auth] findHost: uid=${user.uid}, email=${user.email}`);

  // Strategy 1: Direct lookup by Auth UID
  try {
    const snap = await getDoc(doc(db, 'hosts', user.uid));
    console.log(`[Auth] UID lookup: exists=${snap.exists()}, id=${snap.id}`);
    if (snap.exists()) {
      const d = snap.data();
      console.log(`[Auth] Host found by UID: role=${d.role}, email=${d.email}`);
      return { hostId: snap.id, ...d } as Host;
    }
  } catch (err) {
    console.error('[Auth] UID lookup FAILED:', err);
  }

  // Strategy 2: Fallback — scan all hosts, match email case-insensitively
  if (user.email) {
    try {
      const allSnap = await getDocs(collection(db, 'hosts'));
      console.log(`[Auth] Email fallback: total hosts=${allSnap.size}`);

      const emailLower = user.email.toLowerCase();
      for (const docSnap of allSnap.docs) {
        const d = docSnap.data();
        const hostEmail = d.email ?? '';
        console.log(`[Auth]  host id=${docSnap.id} email="${hostEmail}" role=${d.role}`);
        if (hostEmail.toLowerCase() === emailLower) {
          console.log(`[Auth] MATCH by email! hostId=${docSnap.id}`);
          return { hostId: docSnap.id, ...d } as Host;
        }
      }

      console.warn(`[Auth] No host matches email="${user.email}". Host emails:`,
        allSnap.docs.map(d => d.data().email));
    } catch (err) {
      console.error('[Auth] Email fallback FAILED:', err);
    }
  }

  return null;
}

export function useAuth() {
  const [state, setState] = useState<AuthState>({
    user: null,
    hostData: null,
    loading: true,
    error: null,
  });

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (user) {
        try {
          const hostData = await findHost(user);
          setState({ user, hostData, loading: false, error: null });
        } catch {
          setState({ user, hostData: null, loading: false, error: null });
        }
      } else {
        setState({ user: null, hostData: null, loading: false, error: null });
      }
    });

    return () => unsubscribe();
  }, []);

  const signIn = useCallback(async (email: string, password: string) => {
    setState((s) => ({ ...s, error: null }));
    try {
      await signInWithEmailAndPassword(auth, email, password);
    } catch (err: unknown) {
      const message =
        err instanceof Error ? err.message : 'Gagal masuk. Periksa email dan kata sandi.';
      setState((s) => ({ ...s, error: message }));
      throw err;
    }
  }, []);

  const signOut = useCallback(async () => {
    await firebaseSignOut(auth);
  }, []);

  const clearError = useCallback(() => {
    setState((s) => ({ ...s, error: null }));
  }, []);

  return { ...state, signIn, signOut, clearError };
}
