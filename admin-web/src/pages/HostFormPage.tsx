import { useState, useEffect, FormEvent } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  collection,
  doc,
  getDoc,
  setDoc,
  updateDoc,
  serverTimestamp,
} from 'firebase/firestore';
import {
  createUserWithEmailAndPassword,
  getAuth,
} from 'firebase/auth';
import { db } from '../config/firebase';
import { Input } from '../components/ui/Input';
import { Button } from '../components/ui/Button';
import { Card } from '../components/ui/Card';
import { Select } from '../components/ui/Select';
import { PageLoader } from '../components/ui/LoadingSpinner';
import { showToast } from '../components/ui/Toast';
import { ArrowLeft, Save } from 'lucide-react';
import { Role, roleLabels } from '../lib/roles';

export function HostFormPage() {
  const navigate = useNavigate();
  const { id } = useParams<{ id: string }>();
  const isEdit = Boolean(id);

  const [loading, setLoading] = useState(isEdit);
  const [saving, setSaving] = useState(false);
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [role, setRole] = useState<Role>(Role.HOST);
  const [isActive, setIsActive] = useState(true);
  const [errors, setErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    if (!id) return;
    async function load() {
      try {
        const snap = await getDoc(doc(db, 'hosts', id!));
        if (snap.exists()) {
          const d = snap.data();
          setName(d.name ?? '');
          setEmail(d.email ?? '');
          setPhone(d.phone ?? '');
          setRole(d.role ?? 'host');
          setIsActive(d.isActive ?? true);
        }
      } catch {
        showToast('error', 'Gagal memuat data host');
      } finally {
        setLoading(false);
      }
    }
    load();
  }, [id]);

  function validate(): boolean {
    const e: Record<string, string> = {};
    if (!name.trim()) e.name = 'Nama wajib diisi';
    if (!email.trim()) e.email = 'Email wajib diisi';
    else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) e.email = 'Format email tidak valid';
    if (!phone.trim()) e.phone = 'Nomor telepon wajib diisi';
    if (!isEdit) {
      if (!password) e.password = 'Kata sandi wajib diisi';
      else if (password.length < 6) e.password = 'Kata sandi minimal 6 karakter';
    }
    setErrors(e);
    return Object.keys(e).length === 0;
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (!validate()) return;
    setSaving(true);

    try {
      if (isEdit) {
        await updateDoc(doc(db, 'hosts', id!), {
          name: name.trim(),
          email: email.trim(),
          phone: phone.trim(),
          role,
          isActive,
        });
        showToast('success', 'Host berhasil diperbarui');
      } else {
        // Create Firebase Auth account
        const app = getAuth();
        const cred = await createUserWithEmailAndPassword(app, email.trim(), password);

        // Create host doc — document ID must be the Auth UID
        // so useAuth() can look it up via doc(db, 'hosts', user.uid)
        await setDoc(doc(db, 'hosts', cred.user.uid), {
          name: name.trim(),
          email: email.trim(),
          phone: phone.trim(),
          photoUrl: null,
          locations: [],
          role,
          isActive,
          createdAt: serverTimestamp(),
          lastLogin: null,
        });
        showToast('success', 'Host berhasil ditambahkan');
      }
      navigate('/hosts');
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Gagal menyimpan host';
      if (msg.includes('email-already-in-use')) {
        showToast('error', 'Email sudah digunakan oleh akun lain');
      } else {
        showToast('error', 'Gagal menyimpan host');
      }
    } finally {
      setSaving(false);
    }
  }

  if (loading) return <PageLoader />;

  const roleOptions = Object.values(Role).map((r) => ({
    value: r,
    label: roleLabels[r],
  }));

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <div className="flex items-center gap-3">
        <button
          onClick={() => navigate('/hosts')}
          className="p-2 rounded-lg hover:bg-background text-text-secondary"
        >
          <ArrowLeft size={20} />
        </button>
        <div>
          <h2 className="text-xl font-bold text-text-primary">
            {isEdit ? 'Edit Host' : 'Tambah Host'}
          </h2>
          <p className="text-sm text-text-secondary mt-0.5">
            {isEdit ? 'Perbarui informasi host' : 'Buat akun host baru'}
          </p>
        </div>
      </div>

      <Card>
        <form onSubmit={handleSubmit} className="space-y-5">
          <Input
            label="Nama Lengkap"
            placeholder="Masukkan nama"
            value={name}
            onChange={(e) => setName(e.target.value)}
            error={errors.name}
          />

          <Input
            label="Email"
            type="email"
            placeholder="host@tamuku.app"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            error={errors.email}
            disabled={isEdit}
          />

          <Input
            label="Nomor Telepon"
            placeholder="081234567890"
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
            error={errors.phone}
          />

          {!isEdit && (
            <Input
              label="Kata Sandi"
              type="password"
              placeholder="Minimal 6 karakter"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              error={errors.password}
            />
          )}

          <Select
            label="Role"
            value={role}
            onChange={(e) => setRole(e.target.value as Role)}
            options={roleOptions}
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
              {isEdit ? 'Simpan Perubahan' : 'Tambah Host'}
            </Button>
            <Button
              type="button"
              variant="secondary"
              onClick={() => navigate('/hosts')}
            >
              Batal
            </Button>
          </div>
        </form>
      </Card>
    </div>
  );
}
