import { useState, useEffect } from 'react';
import { collection, getDocs } from 'firebase/firestore';
import { db } from '../config/firebase';
import { useAuth } from '../hooks/useAuth';
import { StatCard } from '../components/ui/Card';
import { DataTable } from '../components/ui/DataTable';
import { Badge } from '../components/ui/Badge';
import { PageLoader } from '../components/ui/LoadingSpinner';
import { formatDateWIB } from '../lib/utils';
import { MapPin, Users, UserCheck, UserMinus } from 'lucide-react';
import type { Guest } from "../types";

export function DashboardPage() {
  const [stats, setStats] = useState({
    locations: 0,
    hosts: 0,
    guestsToday: 0,
    activeGuests: 0,
  });
  const [recentGuests, setRecentGuests] = useState<Guest[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const { user } = useAuth();

  useEffect(() => {
    async function load() {
      if (!user) return;
      try {
        const [locSnap, hostSnap, guestSnap] = await Promise.all([
          getDocs(collection(db, 'locations')),
          getDocs(collection(db, 'hosts')),
          getDocs(collection(db, 'guests')),
        ]);

        const allGuests: Guest[] = [];
        const now = new Date();
        const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        let activeCount = 0;
        let todayCount = 0;

        guestSnap.docs.forEach((doc) => {
          const data = doc.data();
          const guest: Guest = {
            guestId: doc.id,
            name: data.name ?? '',
            phone: data.phone ?? '',
            email: data.email ?? '',
            keperluan: data.keperluan ?? 'Lainnya',
            instansi: data.instansi ?? '',
            photoUrl: data.photoUrl ?? '',
            checkInPhotoUrl: data.checkInPhotoUrl ?? '',
            checkOutPhotoUrl: data.checkOutPhotoUrl ?? '',
            locationId: data.locationId ?? '',
            checkInTime: data.checkInTime?.toDate?.() ?? new Date(),
            checkOutTime: data.checkOutTime?.toDate?.() ?? null,
            hostPhone: data.hostPhone ?? '',
            status: data.status ?? 'checked_in',
          };

          if (guest.status === 'checked_in') activeCount++;
          if (guest.checkInTime >= startOfDay) todayCount++;
          allGuests.push(guest);
        });

        setStats({
          locations: locSnap.size,
          hosts: hostSnap.size,
          guestsToday: todayCount,
          activeGuests: activeCount,
        });

        allGuests.sort(
          (a, b) => b.checkInTime.getTime() - a.checkInTime.getTime(),
        );
        setRecentGuests(allGuests.slice(0, 5));
      } catch (err) {
        console.error('Dashboard load error:', err);
        setError('Gagal memuat data dashboard. Periksa koneksi internet Anda.');
      } finally {
        setLoading(false);
      }
    }

    load();
  }, [user]);

  if (loading) return <PageLoader />;

  if (error) {
    return (
      <div className="flex flex-col items-center justify-center py-20 text-center">
        <p className="text-text-secondary mb-4">{error}</p>
        <button
          onClick={() => window.location.reload()}
          className="px-4 py-2 rounded-lg bg-primary-900 text-white text-sm font-medium hover:bg-primary-800"
        >
          Coba Lagi
        </button>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-xl font-bold text-text-primary">Dashboard</h2>
        <p className="text-sm text-text-secondary mt-0.5">
          Ringkasan aktivitas kunjungan hari ini
        </p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          label="Total Lokasi"
          value={stats.locations}
          icon={<MapPin size={20} />}
        />
        <StatCard
          label="Total Host"
          value={stats.hosts}
          icon={<Users size={20} />}
        />
        <StatCard
          label="Tamu Hari Ini"
          value={stats.guestsToday}
          icon={<UserCheck size={20} />}
        />
        <StatCard
          label="Tamu Aktif"
          value={stats.activeGuests}
          icon={<UserMinus size={20} />}
        />
      </div>

      {/* Recent Guests */}
      <div>
        <h3 className="text-base font-semibold text-text-primary mb-3">
          Tamu Terbaru
        </h3>
        <DataTable
          columns={[
            {
              key: 'name',
              header: 'Nama',
              render: (g) => (
                <span className="font-medium">{g.name}</span>
              ),
            },
            { key: 'instansi', header: 'Instansi' },
            { key: 'keperluan', header: 'Keperluan' },
            {
              key: 'checkInTime',
              header: 'Waktu Masuk',
              render: (g) => formatDateWIB(g.checkInTime),
            },
            {
              key: 'status',
              header: 'Status',
              render: (g) => (
                <Badge
                  variant={
                    g.status === 'checked_in' ? 'success' : 'neutral'
                  }
                >
                  {g.status === 'checked_in' ? 'Masuk' : 'Pulang'}
                </Badge>
              ),
            },
          ]}
          data={recentGuests}
          keyExtractor={(g) => g.guestId}
          emptyMessage="Belum ada tamu"
        />
      </div>
    </div>
  );
}
