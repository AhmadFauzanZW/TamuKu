import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  collection,
  getDocs,
  getDoc,
  deleteDoc,
  doc,
  updateDoc,
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
import { getInitials } from '../lib/utils';
import { roleLabels, Role } from '../lib/roles';
import { Plus, Edit, Trash2 } from 'lucide-react';
import type { Host } from '../types';

export function HostsPage() {
  const navigate = useNavigate();
  const { hostData } = useAuth();
  const [hosts, setHosts] = useState<Host[]>([]);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [deleteTarget, setDeleteTarget] = useState<Host | null>(null);
  const [deleting, setDeleting] = useState(false);

  async function loadHosts() {
    if (!hostData) {
      showToast('error', 'Anda belum terdaftar sebagai host. Silakan hubungi admin.');
      setLoading(false);
      return;
    }
    try {
      let hostList: Host[] = [];
      if (hostData?.role === 'super_admin') {
        const snap = await getDocs(collection(db, 'hosts'));
        hostList = snap.docs.map((d) => ({
          hostId: d.id,
          name: d.data().name ?? '',
          phone: d.data().phone ?? '',
          email: d.data().email ?? '',
          photoUrl: d.data().photoUrl ?? null,
          locations: d.data().locations ?? [],
          role: d.data().role ?? 'host',
          createdAt: d.data().createdAt?.toDate?.() ?? new Date(),
          lastLogin: d.data().lastLogin?.toDate?.() ?? null,
          isActive: d.data().isActive ?? true,
        }));
      } else if (hostData?.hostId) {
        // Non-super_admin can only see their own profile
        const snap = await getDoc(doc(db, 'hosts', hostData.hostId));
        if (snap.exists()) {
          const d = snap.data();
          hostList = [{
            hostId: snap.id,
            name: d.name ?? '',
            phone: d.phone ?? '',
            email: d.email ?? '',
            photoUrl: d.photoUrl ?? null,
            locations: d.locations ?? [],
            role: d.role ?? 'host',
            createdAt: d.createdAt?.toDate?.() ?? new Date(),
            lastLogin: d.lastLogin?.toDate?.() ?? null,
            isActive: d.isActive ?? true,
          }];
        }
      }
      setHosts(hostList);
    } catch (err) {
      console.error(err);
      showToast('error', 'Gagal memuat data host');
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    if (!hostData) return;
    loadHosts();
  }, [hostData]);

  async function toggleActive(host: Host) {
    try {
      await updateDoc(doc(db, 'hosts', host.hostId), {
        isActive: !host.isActive,
      });
      setHosts((prev) =>
        prev.map((h) =>
          h.hostId === host.hostId ? { ...h, isActive: !h.isActive } : h,
        ),
      );
      showToast(
        'success',
        `Host ${host.isActive ? 'dinonaktifkan' : 'diaktifkan'}`,
      );
    } catch {
      showToast('error', 'Gagal mengubah status host');
    }
  }

  async function handleDelete() {
    if (!deleteTarget) return;
    setDeleting(true);
    try {
      await deleteDoc(doc(db, 'hosts', deleteTarget.hostId));
      setHosts((prev) =>
        prev.filter((h) => h.hostId !== deleteTarget.hostId),
      );
      showToast('success', 'Host berhasil dihapus');
      setDeleteTarget(null);
    } catch {
      showToast('error', 'Gagal menghapus host');
    } finally {
      setDeleting(false);
    }
  }

  const filtered = hosts.filter(
    (h) =>
      h.name.toLowerCase().includes(search.toLowerCase()) ||
      h.email.toLowerCase().includes(search.toLowerCase()) ||
      h.phone.includes(search),
  );

  if (loading) return <PageLoader />;

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-bold text-text-primary">Host</h2>
          <p className="text-sm text-text-secondary mt-0.5">
            Kelola akun host dan admin
          </p>
        </div>
        <Button onClick={() => navigate('/hosts/new')}>
          <Plus size={16} /> Tambah Host
        </Button>
      </div>

      <SearchBar
        value={search}
        onChange={setSearch}
        placeholder="Cari host..."
      />

      {filtered.length === 0 ? (
        <EmptyState
          title="Belum ada host"
          description="Tambahkan host pertama untuk mengelola lokasi"
          action={
            <Button onClick={() => navigate('/hosts/new')}>
              <Plus size={16} /> Tambah Host
            </Button>
          }
        />
      ) : (
        <DataTable
          columns={[
            {
              key: 'name',
              header: 'Nama',
              render: (h) => (
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded-full bg-primary-900 text-white flex items-center justify-center text-xs font-semibold shrink-0">
                    {getInitials(h.name)}
                  </div>
                  <div>
                    <p className="font-medium">{h.name}</p>
                    <p className="text-xs text-text-secondary">{h.email}</p>
                  </div>
                </div>
              ),
            },
            {
              key: 'role',
              header: 'Role',
              render: (h) => {
                const r = h.role as Role;
                return (
                  <Badge
                    variant={
                      r === 'super_admin'
                        ? 'warning'
                        : r === 'admin'
                          ? 'success'
                          : 'neutral'
                    }
                  >
                    {roleLabels[r] ?? h.role}
                  </Badge>
                );
              },
            },
            { key: 'phone', header: 'Telepon' },
            {
              key: 'isActive',
              header: 'Status',
              render: (h) => (
                <Badge variant={h.isActive ? 'success' : 'error'}>
                  {h.isActive ? 'Aktif' : 'Nonaktif'}
                </Badge>
              ),
            },
            {
              key: 'actions',
              header: '',
              className: 'w-[140px]',
              render: (h) => (
                <div className="flex items-center gap-1">
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      navigate(`/hosts/${h.hostId}/edit`);
                    }}
                    className="p-1.5 rounded-md hover:bg-primary-50 text-text-secondary transition-colors"
                    title="Edit"
                  >
                    <Edit size={16} />
                  </button>
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      toggleActive(h);
                    }}
                    className="px-2 py-1 rounded-md text-xs font-medium transition-colors text-text-secondary hover:bg-accent-red-light hover:text-accent-red"
                  >
                    {h.isActive ? 'Nonaktifkan' : 'Aktifkan'}
                  </button>
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      setDeleteTarget(h);
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
          keyExtractor={(h) => h.hostId}
          onRowClick={(h) => navigate(`/hosts/${h.hostId}/edit`)}
        />
      )}

      <Modal
        open={!!deleteTarget}
        onClose={() => setDeleteTarget(null)}
        title="Hapus Host"
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
          Apakah Anda yakin ingin menghapus host{' '}
          <strong className="text-text-primary">{deleteTarget?.name}</strong>?
        </p>
      </Modal>
    </div>
  );
}
