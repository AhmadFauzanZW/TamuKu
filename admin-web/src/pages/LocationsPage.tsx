import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  collection,
  getDocs,
  deleteDoc,
  doc,
  updateDoc,
  query,
  where,
} from 'firebase/firestore';
import { db } from '../config/firebase';
import { useAuth } from '../hooks/useAuth';
import { DataTable } from '../components/ui/DataTable';
import { SearchBar } from '../components/ui/SearchBar';
import { Badge } from '../components/ui/Badge';
import { Button } from '../components/ui/Button';
import { Modal } from '../components/ui/Modal';
import { EmptyState } from '../components/ui/EmptyState';
import { PageLoader } from '../components/ui/LoadingSpinner';
import { showToast } from '../components/ui/Toast';
import { formatDateShort } from '../lib/utils';
import { Plus, MapPin, Trash2, Edit } from 'lucide-react';
import type { Location } from '../types';

export function LocationsPage() {
  const navigate = useNavigate();
  const { hostData } = useAuth();
  const [locations, setLocations] = useState<Location[]>([]);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [deleteTarget, setDeleteTarget] = useState<Location | null>(null);
  const [deleting, setDeleting] = useState(false);

  async function loadLocations() {
    if (!hostData) {
      showToast('error', 'Anda belum terdaftar sebagai host. Silakan hubungi admin.');
      setLoading(false);
      return;
    }
    try {
      let q;
      if (hostData.role === 'super_admin') {
        q = collection(db, 'locations');
      } else {
        const assignedIds = hostData.locations ?? [];
        if (assignedIds.length === 0) {
          setLocations([]);
          setLoading(false);
          return;
        }
        q = query(collection(db, 'locations'), where('__name__', 'in', assignedIds));
      }
      const snap = await getDocs(q);
      const data: Location[] = snap.docs.map((d) => ({
        locationId: d.id,
        name: d.data().name ?? '',
        address: d.data().address ?? '',
        adminId: d.data().adminId ?? '',
        hostPhone: d.data().hostPhone ?? '',
        qrCodeValue: d.data().qrCodeValue ?? '',
        createdAt: d.data().createdAt?.toDate?.() ?? new Date(),
        isActive: d.data().isActive ?? true,
      }));
      setLocations(data);
    } catch (err) {
      console.error(err);
      showToast('error', 'Gagal memuat data lokasi');
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    if (!hostData) return;
    loadLocations();
  }, [hostData]);

  async function toggleActive(loc: Location) {
    try {
      await updateDoc(doc(db, 'locations', loc.locationId), {
        isActive: !loc.isActive,
      });
      setLocations((prev) =>
        prev.map((l) =>
          l.locationId === loc.locationId
            ? { ...l, isActive: !l.isActive }
            : l,
        ),
      );
      showToast(
        'success',
        `Lokasi ${loc.isActive ? 'dinonaktifkan' : 'diaktifkan'}`,
      );
    } catch {
      showToast('error', 'Gagal mengubah status lokasi');
    }
  }

  async function handleDelete() {
    if (!deleteTarget) return;
    setDeleting(true);
    try {
      await deleteDoc(doc(db, 'locations', deleteTarget.locationId));
      setLocations((prev) =>
        prev.filter((l) => l.locationId !== deleteTarget.locationId),
      );
      showToast('success', 'Lokasi berhasil dihapus');
      setDeleteTarget(null);
    } catch {
      showToast('error', 'Gagal menghapus lokasi');
    } finally {
      setDeleting(false);
    }
  }

  const filtered = locations.filter(
    (l) =>
      l.name.toLowerCase().includes(search.toLowerCase()) ||
      l.address.toLowerCase().includes(search.toLowerCase()),
  );

  if (loading) return <PageLoader />;

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-bold text-text-primary">Lokasi</h2>
          <p className="text-sm text-text-secondary mt-0.5">
            Kelola lokasi dan QR code kunjungan
          </p>
        </div>
        <Button onClick={() => navigate('/locations/new')}>
          <Plus size={16} /> Tambah Lokasi
        </Button>
      </div>

      <SearchBar
        value={search}
        onChange={setSearch}
        placeholder="Cari lokasi..."
      />

      {filtered.length === 0 ? (
        <EmptyState
          title="Belum ada lokasi"
          description="Tambahkan lokasi pertama untuk mulai menerima tamu"
          action={
            <Button onClick={() => navigate('/locations/new')}>
              <Plus size={16} /> Tambah Lokasi
            </Button>
          }
        />
      ) : (
        <DataTable
          columns={[
            {
              key: 'name',
              header: 'Nama',
              render: (l) => (
                <div className="flex items-center gap-2">
                  <MapPin size={16} className="text-primary-500 shrink-0" />
                  <span className="font-medium">{l.name}</span>
                </div>
              ),
            },
            { key: 'address', header: 'Alamat' },
            {
              key: 'isActive',
              header: 'Status',
              render: (l) => (
                <Badge variant={l.isActive ? 'success' : 'error'}>
                  {l.isActive ? 'Aktif' : 'Nonaktif'}
                </Badge>
              ),
            },
            {
              key: 'createdAt',
              header: 'Dibuat',
              render: (l) => formatDateShort(l.createdAt),
            },
            {
              key: 'actions',
              header: '',
              className: 'w-[140px]',
              render: (l) => (
                <div className="flex items-center gap-1">
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      navigate(`/locations/${l.locationId}/edit`);
                    }}
                    className="p-1.5 rounded-md hover:bg-primary-50 text-text-secondary transition-colors"
                    title="Edit"
                  >
                    <Edit size={16} />
                  </button>
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      toggleActive(l);
                    }}
                    className={`px-2 py-1 rounded-md text-xs font-medium transition-colors ${
                      l.isActive
                        ? 'hover:bg-accent-red-light text-text-secondary hover:text-accent-red'
                        : 'hover:bg-success-bg text-text-secondary hover:text-success'
                    }`}
                  >
                    {l.isActive ? 'Nonaktifkan' : 'Aktifkan'}
                  </button>
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      setDeleteTarget(l);
                    }}
                    className="p-1.5 rounded-md hover:bg-accent-red-light text-text-secondary hover:text-accent-red transition-colors"
                    title="Hapus"
                  >
                    <Trash2 size={16} />
                  </button>
                </div>
              ),
            },
          ]}
          data={filtered}
          keyExtractor={(l) => l.locationId}
          onRowClick={(l) => navigate(`/locations/${l.locationId}/edit`)}
        />
      )}

      {/* Delete confirmation */}
      <Modal
        open={!!deleteTarget}
        onClose={() => setDeleteTarget(null)}
        title="Hapus Lokasi"
        footer={
          <>
            <Button variant="secondary" onClick={() => setDeleteTarget(null)}>
              Batal
            </Button>
            <Button variant="destructive" loading={deleting} onClick={handleDelete}>
              Hapus
            </Button>
          </>
        }
      >
        <p className="text-sm text-text-secondary">
          Apakah Anda yakin ingin menghapus lokasi{' '}
          <strong className="text-text-primary">{deleteTarget?.name}</strong>?
          Tindakan ini tidak dapat dibatalkan.
        </p>
      </Modal>
    </div>
  );
}
