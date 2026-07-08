import { createContext } from 'react';
import { User } from 'firebase/auth';
import type { Host } from '../types';

export interface AuthContextValue {
  user: User | null;
  hostData: Host | null;
  loading: boolean;
  error: string | null;
  signIn: (email: string, password: string) => Promise<void>;
  signOut: () => Promise<void>;
  clearError: () => void;
}

export const AuthContext = createContext<AuthContextValue | null>(null);
