import { ReactNode } from 'react';

interface CardProps {
  children: ReactNode;
  className?: string;
  padding?: boolean;
}

export function Card({ children, className = '', padding = true }: CardProps) {
  return (
    <div
      className={`bg-surface rounded-xl shadow-sm ${padding ? 'p-6' : ''} ${className}`}
    >
      {children}
    </div>
  );
}

interface StatCardProps {
  label: string;
  value: number | string;
  icon: ReactNode;
  trend?: { value: number; isPositive: boolean };
}

export function StatCard({ label, value, icon, trend }: StatCardProps) {
  return (
    <Card className="flex items-start gap-4">
      <div className="p-3 rounded-lg bg-primary-50 text-primary-700">
        {icon}
      </div>
      <div className="flex-1 min-w-0">
        <p className="text-sm text-text-secondary truncate">{label}</p>
        <p className="text-2xl font-bold text-text-primary mt-0.5">{value}</p>
        {trend && (
          <p
            className={`text-xs mt-1 ${
              trend.isPositive ? 'text-success' : 'text-accent-red'
            }`}
          >
            {trend.isPositive ? '↑' : '↓'} {Math.abs(trend.value)}%
          </p>
        )}
      </div>
    </Card>
  );
}
