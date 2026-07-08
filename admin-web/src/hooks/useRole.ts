import { useState, useEffect } from 'react';
import { doc, getDoc } from 'firebase/firestore';
import { db } from '../config/firebase';
import { auth } from '../config/firebase';
import { Role, permissions, RolePermissions } from '../lib/roles';

interface UseRoleReturn {
  role: Role | null;
  permissions: RolePermissions | null;
  isSuperAdmin: boolean;
  isAdmin: boolean;
  loading: boolean;
}

export function useRole(): UseRoleReturn {
  const [role, setRole] = useState<Role | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = auth.onAuthStateChanged(async (user) => {
      if (!user) {
        setRole(null);
        setLoading(false);
        return;
      }
      try {
        const snap = await getDoc(doc(db, 'hosts', user.uid));
        if (snap.exists()) {
          setRole((snap.data().role as Role) ?? null);
        } else {
          setRole(null);
        }
      } catch {
        setRole(null);
      } finally {
        setLoading(false);
      }
    });
    return () => unsubscribe();
  }, []);

  const perms = role ? permissions[role] ?? null : null;

  return {
    role,
    permissions: perms,
    isSuperAdmin: role === Role.SUPER_ADMIN,
    isAdmin: role === Role.ADMIN,
    loading,
  };
}
