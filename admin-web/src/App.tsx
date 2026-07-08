import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
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

function AuthGuard({ children }: { children: React.ReactNode }) {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <PageLoader />
      </div>
    );
  }

  if (!user) {
    return <Navigate to="/login" replace />;
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
