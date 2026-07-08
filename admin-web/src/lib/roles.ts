export const Role = {
  SUPER_ADMIN: 'super_admin',
  ADMIN: 'admin',
  HOST: 'host',
} as const;

export type Role = (typeof Role)[keyof typeof Role];

export interface RolePermissions {
  canManageLocations: boolean;
  canManageHosts: boolean;
  canViewAllGuests: boolean;
  canDeleteLocations: boolean;
  canAssignRoles: boolean;
}

export const permissions: Record<Role, RolePermissions> = {
  [Role.SUPER_ADMIN]: {
    canManageLocations: true,
    canManageHosts: true,
    canViewAllGuests: true,
    canDeleteLocations: true,
    canAssignRoles: true,
  },
  [Role.ADMIN]: {
    canManageLocations: false,
    canManageHosts: false,
    canViewAllGuests: false,
    canDeleteLocations: false,
    canAssignRoles: false,
  },
  [Role.HOST]: {
    canManageLocations: false,
    canManageHosts: false,
    canViewAllGuests: false,
    canDeleteLocations: false,
    canAssignRoles: false,
  },
};

export const roleLabels: Record<Role, string> = {
  [Role.SUPER_ADMIN]: 'Super Admin',
  [Role.ADMIN]: 'Admin',
  [Role.HOST]: 'Host',
};

export function hasPermission(role: Role, permission: keyof RolePermissions): boolean {
  return permissions[role]?.[permission] ?? false;
}
