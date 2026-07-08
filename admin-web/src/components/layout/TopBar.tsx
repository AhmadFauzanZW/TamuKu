import { Menu, Bell } from 'lucide-react';
import { getInitials } from '../../lib/utils';
import { useAuth } from '../../hooks/useAuth';
import { roleLabels } from '../../lib/roles';
import { Role } from '../../lib/roles';

interface TopBarProps {
  onMenuToggle: () => void;
  title?: string;
}

export function TopBar({ onMenuToggle, title }: TopBarProps) {
  const { hostData } = useAuth();
  const roleName = hostData?.role
    ? roleLabels[hostData.role as Role] ?? hostData.role
    : '';

  return (
    <header className="h-16 bg-surface border-b border-border-light flex items-center justify-between px-4 md:px-6 shrink-0">
      <div className="flex items-center gap-3">
        <button
          onClick={onMenuToggle}
          className="p-2 rounded-lg hover:bg-background text-text-secondary md:hidden"
        >
          <Menu size={20} />
        </button>
        {title && (
          <h1 className="text-lg font-semibold text-text-primary">{title}</h1>
        )}
      </div>

      <div className="flex items-center gap-3">
        <button className="p-2 rounded-lg hover:bg-background text-text-secondary relative">
          <Bell size={20} />
          <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-accent-red rounded-full" />
        </button>

        <div className="flex items-center gap-3 pl-3 border-l border-border-light">
          <div className="text-right hidden sm:block">
            <p className="text-sm font-medium text-text-primary leading-tight">
              {hostData?.name ?? 'Admin'}
            </p>
            <p className="text-xs text-text-secondary">{roleName}</p>
          </div>
          <div className="w-9 h-9 rounded-full bg-primary-900 text-white flex items-center justify-center text-sm font-semibold">
            {getInitials(hostData?.name ?? 'A')}
          </div>
        </div>
      </div>
    </header>
  );
}
