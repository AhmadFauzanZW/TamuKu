import { useState, useEffect, FormEvent } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  collection,
  doc,
  getDoc,
  getDocs,
  addDoc,
  updateDoc,
  serverTimestamp,
} from 'firebase/firestore';
import { db } from '../config/firebase';
import { Input } from '../components/ui/Input';
import { Button } from '../components/ui/Button';
import { Card } from '../components/ui/Card';
import { Select } from '../components/ui/Select';
import { PageLoader } from '../components/ui/LoadingSpinner';
import { showToast } from '../components/ui/Toast';
import { ArrowLeft, Save } from 'lucide-react';

export function LocationFormPage() {
  const navigate = useNavigate();
  const { id } = useParams<{ id: string }>();
  const isEdit = Boolean(id);

  const [loading, setLoading] = useState(isEdit);
  const [saving, setSaving] = useState(false);
  const [name, setName] = useState('');
  const [address, setAddress] = useState('');
  const [hostPhone, setHostPhone] = useState('');
  const [adminId, setAdminId] = useState('');
  const [isActive, setIsActive] = useState(true);
  const [errors, setErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    if (!id) return;
    async function load() {
      try {
        const snap = await getDoc(doc(db, 'locations', id!));
        if (snap.exists()) {
          const d = snap.data();
          setName(d.name ?? '');
          setAddress(d.address ?? '');
          setHostPhone(d.hostPhone ?? '');
          setAdminId(d.adminId ?? '');
          setIsActive(d.isActive ?? true);
        }
      } catch {
        showToast('error', 'Gagal memuat data lokasi');
      } finally {
        setLoading(false);
      }
    }
    load();
  }, [id]);

  function validate(): boolean {
    const e: Record<string, string> = {};
    if (!name.trim()) e.name = 'Nama lokasi wajib diisi';
    if (!address.trim()) e.address = 'Alamat wajib diisi';
    if (!hostPhone.trim()) e.hostPhone = 'Nomor telepon wajib diisi';
    setErrors(e);
    return Object.keys(e).length === 0;
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (!validate()) return;
    setSaving(true);

    try {
      const payload = {
        name: name.trim(),
        address: address.trim(),
        hostPhone: hostPhone.trim(),
        adminId: adminId.trim(),
        isActive,
        qrCodeValue: `tamuku-loc-${Date.now()}`,
      };

      if (isEdit) {
        await updateDoc(doc(db, 'locations', id!), {
          name: payload.name,
          address: payload.address,
          hostPhone: payload.hostPhone,
          adminId: payload.adminId,
          isActive: payload.isActive,
        });
        showToast('success', 'Lokasi berhasil diperbarui');
      } else {
        await addDoc(collection(db, 'locations'), {
          ...payload,
          createdAt: serverTimestamp(),
        });
        showToast('success', 'Lokasi berhasil ditambahkan');
      }
      navigate('/locations');
    } catch {
      showToast('error', 'Gagal menyimpan lokasi');
    } finally {
      setSaving(false);
    }
  }

  if (loading) return <PageLoader />;

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <div className="flex items-center gap-3">
        <button
          onClick={() => navigate('/locations')}
          className="p-2 rounded-lg hover:bg-background text-text-secondary"
        >
          <ArrowLeft size={20} />
        </button>
        <div>
          <h2 className="text-xl font-bold text-text-primary">
            {isEdit ? 'Edit Lokasi' : 'Tambah Lokasi'}
          </h2>
          <p className="text-sm text-text-secondary mt-0.5">
            {isEdit ? 'Perbarui informasi lokasi' : 'Tambahkan lokasi baru'}
          </p>
        </div>
      </div>

      <Card>
        <form onSubmit={handleSubmit} className="space-y-5">
          <Input
            label="Nama Lokasi"
            placeholder="Contoh: Kantor Desa Cakrawala"
            value={name}
            onChange={(e) => setName(e.target.value)}
            error={errors.name}
          />

          <Input
            label="Alamat"
            placeholder="Jl. Merdeka No. 17, Bandung"
            value={address}
            onChange={(e) => setAddress(e.target.value)}
            error={errors.address}
          />

          <Input
            label="Nomor Telepon Host"
            placeholder="081234567890"
            value={hostPhone}
            onChange={(e) => setHostPhone(e.target.value)}
            error={errors.hostPhone}
          />

          <Input
            label="Admin ID (opsional)"
            placeholder="Firebase UID admin"
            value={adminId}
            onChange={(e) => setAdminId(e.target.value)}
          />

          <div className="flex items-center gap-3">
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={isActive}
                onChange={(e) => setIsActive(e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-border rounded-full peer peer-checked:bg-primary-700 peer-focus:ring-2 peer-focus:ring-primary-500/30 transition-colors after:content-[''] after:absolute after:top-0.5 after:left-[2px] after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:after:translate-x-full" />
            </label>
            <span className="text-sm font-medium text-text-primary">
              {isActive ? 'Aktif' : 'Nonaktif'}
            </span>
          </div>

          <div className="flex items-center gap-3 pt-2">
            <Button type="submit" loading={saving}>
              <Save size={16} />
              {isEdit ? 'Simpan Perubahan' : 'Tambah Lokasi'}
            </Button>
            <Button
              type="button"
              variant="secondary"
              onClick={() => navigate('/locations')}
            >
              Batal
            </Button>
          </div>
        </form>
      </Card>
    </div>
  );
}
