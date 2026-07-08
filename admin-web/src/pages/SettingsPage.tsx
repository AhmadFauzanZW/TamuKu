import { useState } from 'react';
import { useAuth } from '../hooks/useAuth';
import { Card } from '../components/ui/Card';
import { Input } from '../components/ui/Input';
import { Button } from '../components/ui/Button';
import { showToast } from '../components/ui/Toast';
import { updateProfile, updatePassword, reauthenticateWithCredential, EmailAuthProvider } from 'firebase/auth';
import { doc, updateDoc } from 'firebase/firestore';
import { db } from '../config/firebase';
import { Save, Shield } from 'lucide-react';
import { getInitials } from '../lib/utils';
import { roleLabels, Role } from '../lib/roles';

export function SettingsPage() {
  const { user, hostData } = useAuth();
  const [displayName, setDisplayName] = useState(hostData?.name ?? '');
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [savingProfile, setSavingProfile] = useState(false);
  const [savingPassword, setSavingPassword] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const role = (hostData?.role as Role) ?? null;

  async function handleProfileSave() {
    if (!user || !displayName.trim()) return;
    setSavingProfile(true);
    try {
      await updateProfile(user, { displayName: displayName.trim() });
      await updateDoc(doc(db, 'hosts', user.uid), { name: displayName.trim() });
      showToast('success', 'Profil berhasil diperbarui');
    } catch {
      showToast('error', 'Gagal memperbarui profil');
    } finally {
      setSavingProfile(false);
    }
  }

  async function handlePasswordChange() {
    if (!user || !user.email) return;
    const e: Record<string, string> = {};
    if (!currentPassword) e.currentPassword = 'Kata sandi saat ini wajib diisi';
    if (!newPassword) e.newPassword = 'Kata sandi baru wajib diisi';
    else if (newPassword.length < 6) e.newPassword = 'Minimal 6 karakter';
    if (newPassword !== confirmPassword) e.confirmPassword = 'Kata sandi tidak cocok';
    setErrors(e);
    if (Object.keys(e).length > 0) return;

    setSavingPassword(true);
    try {
      const credential = EmailAuthProvider.credential(user.email, currentPassword);
      await reauthenticateWithCredential(user, credential);
      await updatePassword(user, newPassword);
      setCurrentPassword('');
      setNewPassword('');
      setConfirmPassword('');
      showToast('success', 'Kata sandi berhasil diubah');
    } catch {
      showToast('error', 'Kata sandi saat ini salah');
    } finally {
      setSavingPassword(false);
    }
  }

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <div>
        <h2 className="text-xl font-bold text-text-primary">Pengaturan</h2>
        <p className="text-sm text-text-secondary mt-0.5">
          Kelola profil dan keamanan akun
        </p>
      </div>

      {/* Profile Card */}
      <Card>
        <div className="flex items-start gap-4 mb-6">
          <div className="w-14 h-14 rounded-full bg-primary-900 text-white flex items-center justify-center text-lg font-bold shrink-0">
            {getInitials(hostData?.name ?? 'A')}
          </div>
          <div>
            <h3 className="text-base font-semibold text-text-primary">
              {hostData?.name ?? 'Admin'}
            </h3>
            <p className="text-sm text-text-secondary">{user?.email}</p>
            {role && (
              <span className="inline-flex items-center gap-1 mt-1 text-xs font-medium text-primary-700">
                <Shield size={12} />
                {roleLabels[role]}
              </span>
            )}
          </div>
        </div>

        <div className="space-y-4">
          <Input
            label="Nama Tampilan"
            value={displayName}
            onChange={(e) => setDisplayName(e.target.value)}
          />
          <Button loading={savingProfile} onClick={handleProfileSave}>
            <Save size={16} /> Simpan Profil
          </Button>
        </div>
      </Card>

      {/* Password Card */}
      <Card>
        <h3 className="text-base font-semibold text-text-primary mb-4">
          Ubah Kata Sandi
        </h3>
        <div className="space-y-4">
          <Input
            label="Kata Sandi Saat Ini"
            type="password"
            value={currentPassword}
            onChange={(e) => setCurrentPassword(e.target.value)}
            error={errors.currentPassword}
          />
          <Input
            label="Kata Sandi Baru"
            type="password"
            value={newPassword}
            onChange={(e) => setNewPassword(e.target.value)}
            error={errors.newPassword}
          />
          <Input
            label="Konfirmasi Kata Sandi Baru"
            type="password"
            value={confirmPassword}
            onChange={(e) => setConfirmPassword(e.target.value)}
            error={errors.confirmPassword}
          />
          <Button loading={savingPassword} onClick={handlePasswordChange}>
            <Shield size={16} /> Ubah Kata Sandi
          </Button>
        </div>
      </Card>
    </div>
  );
}
