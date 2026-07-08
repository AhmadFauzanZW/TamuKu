import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { signOut as firebaseSignOut } from 'firebase/auth';
import { auth } from './config/firebase';
import { useAuth } from './hooks/useAuth';
import { AdminLayout } from './components/layout/AdminLayout';
import { LoginPage } from './pages/LoginPage';
import { DashboardPage } from './pages/DashboardPage';
import { LocationsPage } from './pages/LocationsPage';
import { LocationFormPage } from './pages/LocationFormPage';
import { HostsPage } from './pages/HostsPage';
import { HostFormPage } from './pages/HostFormPage';
import { GuestsPage } from './pages/GuestsPage';
import { SettingsPage } from './pages/SettingsPage';
import { ToastContainer } from './components/ui/Toast';
import { PageLoader } from './components/ui/LoadingSpinner';

const WEB_ADMIN_ROLES = ['super_admin', 'admin'];

function AuthGuard({ children }: { children: React.ReactNode }) {
  const { user, hostData, loading } = useAuth();

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <PageLoader />
      </div>
    );
  }

  // Not logged in → redirect to login
  if (!user) {
    return <Navigate to="/login" replace />;
  }

  // Logged in but no host document → not registered
  if (!hostData) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen gap-4 px-4">
        <div className="w-16 h-16 rounded-2xl bg-red-100 flex items-center justify-center">
          <span className="text-red-600 text-2xl">⚠</span>
        </div>
        <h1 className="text-xl font-bold text-text-primary text-center">
          Akun Tidak Terdaftar
        </h1>
        <p className="text-sm text-text-secondary text-center max-w-md">
          Akun Anda belum terdaftar sebagai host/admin.
          Silakan hubungi Super Admin untuk mendaftarkan akun Anda.
        </p>
        <button
          onClick={() => firebaseSignOut(auth)}
          className="mt-2 px-4 py-2 rounded-lg bg-primary-900 text-white text-sm font-medium hover:bg-primary-800"
        >
          Keluar
        </button>
      </div>
    );
  }

  // Check role — only super_admin and admin can access web admin
  if (!WEB_ADMIN_ROLES.includes(hostData.role)) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen gap-4 px-4">
        <div className="w-16 h-16 rounded-2xl bg-red-100 flex items-center justify-center">
          <span className="text-red-600 text-2xl">🚫</span>
        </div>
        <h1 className="text-xl font-bold text-text-primary text-center">
          Akses Ditolak
        </h1>
        <p className="text-sm text-text-secondary text-center max-w-md">
          Anda tidak memiliki akses ke Dashboard Admin Web.
          Role Anda: <span className="font-semibold">{hostData.role}</span>.
          <br />
          Host dapat mengakses aplikasi mobile TamuKu.
        </p>
        <button
          onClick={() => firebaseSignOut(auth)}
          className="mt-2 px-4 py-2 rounded-lg bg-primary-900 text-white text-sm font-medium hover:bg-primary-800"
        >
          Keluar
        </button>
      </div>
    );
  }

  return <>{children}</>;
}

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route
          element={
            <AuthGuard>
              <AdminLayout />
            </AuthGuard>
          }
        >
          <Route path="/" element={<DashboardPage />} />
          <Route path="/locations" element={<LocationsPage />} />
          <Route path="/locations/new" element={<LocationFormPage />} />
          <Route path="/locations/:id/edit" element={<LocationFormPage />} />
          <Route path="/hosts" element={<HostsPage />} />
          <Route path="/hosts/new" element={<HostFormPage />} />
          <Route path="/hosts/:id/edit" element={<HostFormPage />} />
          <Route path="/guests" element={<GuestsPage />} />
          <Route path="/settings" element={<SettingsPage />} />
        </Route>
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
      <ToastContainer />
    </BrowserRouter>
  );
}
