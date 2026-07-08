import { useState, useEffect, useCallback } from 'react';
import {
  onAuthStateChanged,
  signInWithEmailAndPassword,
  signOut as firebaseSignOut,
} from 'firebase/auth';
import type { User } from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';
import { auth, db } from '../config/firebase';
import type { Host } from '../types';

interface AuthState {
  user: User | null;
  hostData: Host | null;
  loading: boolean;
  error: string | null;
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
          const snap = await getDoc(doc(db, 'hosts', user.uid));
          const hostData = snap.exists()
            ? ({ hostId: snap.id, ...snap.data() } as Host)
            : null;
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
