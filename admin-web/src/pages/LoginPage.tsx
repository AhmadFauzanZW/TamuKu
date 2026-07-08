import { useState, FormEvent } from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';
import { Button } from '../components/ui/Button';
import { Input } from '../components/ui/Input';
import { Eye, EyeOff, LogIn } from 'lucide-react';

export function LoginPage() {
  const { user, loading, error, signIn, clearError } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [errors, setErrors] = useState<{ email?: string; password?: string }>({});

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-background">
        <div className="h-8 w-8 border-2 border-primary-700 border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }
  if (user) return <Navigate to="/" replace />;

  function validate(): boolean {
    const e: typeof errors = {};
    if (!email) e.email = 'Email wajib diisi';
    else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) e.email = 'Format email tidak valid';
    if (!password) e.password = 'Kata sandi wajib diisi';
    else if (password.length < 6) e.password = 'Kata sandi minimal 6 karakter';
    setErrors(e);
    return Object.keys(e).length === 0;
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    clearError();
    if (!validate()) return;
    setSubmitting(true);
    try {
      await signIn(email, password);
    } catch {
      // error set in useAuth
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-background px-4">
      <div className="w-full max-w-sm">
        {/* Logo */}
        <div className="flex flex-col items-center mb-8">
          <div className="w-16 h-16 rounded-2xl bg-primary-900 flex items-center justify-center mb-4">
            <span className="text-white text-2xl font-bold">T</span>
          </div>
          <h1 className="text-2xl font-bold text-text-primary">TamuKu</h1>
          <p className="text-sm text-text-secondary mt-1">Admin Dashboard</p>
        </div>

        {/* Form */}
        <div className="bg-surface rounded-xl shadow-sm p-6">
          <h2 className="text-lg font-semibold text-text-primary mb-1">
            Masuk ke Akun
          </h2>
          <p className="text-sm text-text-secondary mb-6">
            Gunakan email dan kata sandi admin
          </p>

          {error && (
            <div className="mb-4 px-3 py-2 rounded-lg bg-accent-red-light text-accent-red text-sm">
              {error}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            <Input
              label="Email"
              type="email"
              placeholder="admin@tamuku.app"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              error={errors.email}
            />

            <div className="relative">
              <Input
                label="Kata Sandi"
                type={showPassword ? 'text' : 'password'}
                placeholder="••••••••"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                error={errors.password}
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-[38px] text-text-disabled hover:text-text-secondary transition-colors"
              >
                {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
              </button>
            </div>

            <Button
              type="submit"
              loading={submitting}
              className="w-full"
              size="lg"
            >
              <LogIn size={18} />
              Masuk
            </Button>
          </form>
        </div>

        <p className="text-center text-xs text-text-secondary mt-6">
          Buku Tamu Digital — Universitas Cakrawala
        </p>
      </div>
    </div>
  );
}
