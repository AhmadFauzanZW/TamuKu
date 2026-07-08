import { useState, useEffect, useCallback } from 'react';
import {
  onAuthStateChanged,
  signInWithEmailAndPassword,
  signOut as firebaseSignOut,
} from 'firebase/auth';
import type { User } from 'firebase/auth';
import { doc, getDoc, collection, query, where, getDocs } from 'firebase/firestore';
import { auth, db } from '../config/firebase';
import type { Host } from '../types';

interface AuthState {
  user: User | null;
  hostData: Host | null;
  loading: boolean;
  error: string | null;
}

async function findHost(user: User): Promise<Host | null> {
  // Strategy 1: Direct lookup by Auth UID
  try {
    const snap = await getDoc(doc(db, 'hosts', user.uid));
    if (snap.exists()) {
      return { hostId: snap.id, ...snap.data() } as Host;
    }
  } catch (err) {
    console.warn('Direct host lookup failed:', err);
  }

  // Strategy 2: Fallback — query by email
  if (user.email) {
    try {
      const q = query(collection(db, 'hosts'), where('email', '==', user.email));
      const querySnap = await getDocs(q);
      if (!querySnap.empty) {
        const docSnap = querySnap.docs[0];
        console.warn(
          `Host document ID (${docSnap.id}) doesn't match Auth UID (${user.uid}). ` +
          `Consider running the setup script to fix this.`
        );
        return { hostId: docSnap.id, ...docSnap.data() } as Host;
      }
    } catch (err) {
      console.warn('Email-based host lookup failed:', err);
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
