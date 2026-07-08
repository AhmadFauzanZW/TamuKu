export interface Host {
  hostId: string;
  name: string;
  phone: string;
  email: string;
  photoUrl: string | null;
  locations: string[];
  role: 'super_admin' | 'admin' | 'host';
  createdAt: Date;
  lastLogin: Date | null;
  isActive: boolean;
}

export interface Location {
  locationId: string;
  name: string;
  address: string;
  adminId: string;
  hostPhone: string;
  qrCodeValue: string;
  createdAt: Date;
  isActive: boolean;
}

export interface Guest {
  guestId: string;
  name: string;
  phone: string;
  email: string;
  keperluan: 'Meeting' | 'Personal' | 'Kantor' | 'Pengiriman' | 'Lainnya';
  instansi: string;
  photoUrl: string;
  checkOutPhotoUrl: string;
  locationId: string;
  checkInTime: Date;
  checkOutTime: Date | null;
  hostPhone: string;
  status: 'checked_in' | 'checked_out';
}
