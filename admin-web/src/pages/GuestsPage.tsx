import { useState, useEffect, useMemo } from 'react';
import { collection, getDocs } from 'firebase/firestore';
import { db } from '../config/firebase';
import { DataTable } from '../components/ui/DataTable';
import { SearchBar } from '../components/ui/SearchBar';
import { Badge } from '../components/ui/Badge';
import { Select } from '../components/ui/Select';
import { Card } from '../components/ui/Card';
import { PageLoader } from '../components/ui/LoadingSpinner';
import { showToast } from '../components/ui/Toast';
import { formatDateWIB } from '../lib/utils';
import type { Guest, Location } from '../types';

export function GuestsPage() {
  const [guests, setGuests] = useState<Guest[]>([]);
  const [locations, setLocations] = useState<Location[]>([]);
  const [search, setSearch] = useState('');
  const [filterLocation, setFilterLocation] = useState('');
  const [filterStatus, setFilterStatus] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function load() {
      try {
        const [guestSnap, locSnap] = await Promise.all([
          getDocs(collection(db, 'guests')),
          getDocs(collection(db, 'locations')),
        ]);

        const locMap = new Map<string, string>();
        locSnap.docs.forEach((d) => {
          locMap.set(d.id, d.data().name ?? '');
        });

        setLocations(
          locSnap.docs.map((d) => ({
            locationId: d.id,
            name: d.data().name ?? '',
            address: d.data().address ?? '',
            adminId: d.data().adminId ?? '',
            hostPhone: d.data().hostPhone ?? '',
            qrCodeValue: d.data().qrCodeValue ?? '',
            createdAt: d.data().createdAt?.toDate?.() ?? new Date(),
            isActive: d.data().isActive ?? true,
          })),
        );

        const data: Guest[] = guestSnap.docs.map((d) => ({
          guestId: d.id,
          name: d.data().name ?? '',
          phone: d.data().phone ?? '',
          email: d.data().email ?? '',
          keperluan: d.data().keperluan ?? 'Lainnya',
          instansi: d.data().instansi ?? '',
          photoUrl: d.data().photoUrl ?? '',
          locationId: d.data().locationId ?? '',
          checkInTime: d.data().checkInTime?.toDate?.() ?? new Date(),
          checkOutTime: d.data().checkOutTime?.toDate?.() ?? null,
          hostPhone: d.data().hostPhone ?? '',
          status: d.data().status ?? 'checked_in',
        }));

        data.sort((a, b) => b.checkInTime.getTime() - a.checkInTime.getTime());
        setGuests(data);
      } catch (err) {
        console.error(err);
        showToast('error', 'Gagal memuat data tamu');
      } finally {
        setLoading(false);
      }
    }

    load();
  }, []);

  const locationNameMap = useMemo(() => {
    const map = new Map<string, string>();
    locations.forEach((l) => map.set(l.locationId, l.name));
    return map;
  }, [locations]);

  const filtered = useMemo(() => {
    return guests.filter((g) => {
      const matchSearch =
        !search ||
        g.name.toLowerCase().includes(search.toLowerCase()) ||
        g.instansi.toLowerCase().includes(search.toLowerCase()) ||
        g.phone.includes(search);
      const matchLocation = !filterLocation || g.locationId === filterLocation;
      const matchStatus = !filterStatus || g.status === filterStatus;
      return matchSearch && matchLocation && matchStatus;
    });
  }, [guests, search, filterLocation, filterStatus]);

  const locationOptions = locations.map((l) => ({
    value: l.locationId,
    label: l.name,
  }));

  if (loading) return <PageLoader />;

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-xl font-bold text-text-primary">Tamu</h2>
        <p className="text-sm text-text-secondary mt-0.5">
          Daftar kunjungan tamu ({guests.length} total)
        </p>
      </div>

      {/* Filters */}
      <Card padding={false} className="p-4">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
          <SearchBar
            value={search}
            onChange={setSearch}
            placeholder="Cari nama, instansi, telepon..."
          />
          <Select
            value={filterLocation}
            onChange={(e) => setFilterLocation(e.target.value)}
            options={[{ value: '', label: 'Semua Lokasi' }, ...locationOptions]}
            placeholder="Semua Lokasi"
          />
          <Select
            value={filterStatus}
            onChange={(e) => setFilterStatus(e.target.value)}
            options={[
              { value: '', label: 'Semua Status' },
              { value: 'checked_in', label: 'Sedang Di Lokasi' },
              { value: 'checked_out', label: 'Sudah Pulang' },
            ]}
            placeholder="Semua Status"
          />
        </div>
      </Card>

      <DataTable
        columns={[
          {
            key: 'name',
            header: 'Nama',
            render: (g) => <span className="font-medium">{g.name}</span>,
          },
          { key: 'instansi', header: 'Instansi' },
          { key: 'keperluan', header: 'Keperluan' },
          {
            key: 'locationId',
            header: 'Lokasi',
            render: (g) => locationNameMap.get(g.locationId) ?? '—',
          },
          {
            key: 'checkInTime',
            header: 'Masuk',
            render: (g) => formatDateWIB(g.checkInTime),
          },
          {
            key: 'checkOutTime',
            header: 'Pulang',
            render: (g) => formatDateWIB(g.checkOutTime),
          },
          {
            key: 'status',
            header: 'Status',
            render: (g) => (
              <Badge
                variant={g.status === 'checked_in' ? 'success' : 'neutral'}
              >
                {g.status === 'checked_in' ? 'Masuk' : 'Pulang'}
              </Badge>
            ),
          },
        ]}
        data={filtered}
        keyExtractor={(g) => g.guestId}
        emptyMessage="Tidak ada tamu ditemukan"
      />
    </div>
  );
}
