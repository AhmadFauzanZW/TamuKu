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
import { PhotoDisplay } from '../components/ui/PhotoDisplay';
import { formatDateWIB } from '../lib/utils';
import type { Guest, Location } from '../types';

export function GuestsPage() {
  const [guests, setGuests] = useState<Guest[]>([]);
  const [locations, setLocations] = useState<Location[]>([]);
  const [search, setSearch] = useState('');
  const [filterLocation, setFilterLocation] = useState('');
  const [filterStatus, setFilterStatus] = useState('');
  const [filterDateFrom, setFilterDateFrom] = useState('');
  const [filterDateTo, setFilterDateTo] = useState('');
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
          checkInPhotoUrl: d.data().checkInPhotoUrl ?? '',
          checkOutPhotoUrl: d.data().checkOutPhotoUrl ?? '',
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
    const fromDate = filterDateFrom ? new Date(filterDateFrom) : null;
    const toDate = filterDateTo ? new Date(filterDateTo + 'T23:59:59') : null;

    return guests.filter((g) => {
      const matchSearch =
        !search ||
        g.name.toLowerCase().includes(search.toLowerCase()) ||
        g.instansi.toLowerCase().includes(search.toLowerCase()) ||
        g.phone.includes(search);
      const matchLocation = !filterLocation || g.locationId === filterLocation;
      const matchStatus = !filterStatus || g.status === filterStatus;
      const matchDateFrom = !fromDate || g.checkInTime >= fromDate;
      const matchDateTo = !toDate || g.checkInTime <= toDate;
      return matchSearch && matchLocation && matchStatus && matchDateFrom && matchDateTo;
    });
  }, [guests, search, filterLocation, filterStatus, filterDateFrom, filterDateTo]);

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
          Daftar kunjungan tamu ({filtered.length} dari {guests.length} total)
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
        <div className="grid grid-cols-1 md:grid-cols-2 gap-3 mt-3">
          <div>
            <label className="block text-xs font-medium text-text-secondary mb-1">
              Dari Tanggal
            </label>
            <input
              type="date"
              value={filterDateFrom}
              onChange={(e) => setFilterDateFrom(e.target.value)}
              className="w-full px-3 py-2 text-sm bg-white border border-border-light rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
            />
          </div>
          <div>
            <label className="block text-xs font-medium text-text-secondary mb-1">
              Sampai Tanggal
            </label>
            <input
              type="date"
              value={filterDateTo}
              onChange={(e) => setFilterDateTo(e.target.value)}
              className="w-full px-3 py-2 text-sm bg-white border border-border-light rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
            />
          </div>
        </div>
      </Card>

      <DataTable
        columns={[
          {
            key: 'photoUrl',
            header: 'Foto',
            render: (g) => (
              <div className="flex items-center gap-2">
                {g.photoUrl ? (
                  <img
                    src={g.photoUrl}
                    alt={g.name}
                    className="w-10 h-10 rounded-full object-cover border-2 border-green-100"
                    onError={(e) => {
                      (e.target as HTMLImageElement).style.display = 'none';
                    }}
                  />
                ) : (
                  <div className="w-10 h-10 rounded-full bg-green-50 flex items-center justify-center text-green-700 font-semibold text-sm">
                    {g.name?.substring(0, 2).toUpperCase()}
                  </div>
                )}
              </div>
            ),
          },
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
            render: (g) => (
              <span className="inline-flex items-center gap-1">
                {formatDateWIB(g.checkOutTime)}
                {g.checkOutPhotoUrl && (
                  <span title="Foto check-out tersedia" className="text-xs">📸</span>
                )}
              </span>
            ),
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
        expandedRowRender={(g) => (
          <div className="flex flex-wrap gap-6">
            <PhotoDisplay rawUrl={g.checkInPhotoUrl} label="Foto Check-in" />
            <PhotoDisplay rawUrl={g.checkOutPhotoUrl} label="Foto Check-out" />
          </div>
        )}
      />
    </div>
  );
}
