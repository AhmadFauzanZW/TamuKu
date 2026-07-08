interface BadgeProps {
  variant: 'success' | 'error' | 'warning' | 'neutral';
  children: React.ReactNode;
}

const styles = {
  success: 'bg-success-bg text-success',
  error: 'bg-accent-red-light text-accent-red',
  warning: 'bg-accent-amber-light text-accent-amber',
  neutral: 'bg-background text-text-secondary',
};

export function Badge({ variant, children }: BadgeProps) {
  return (
    <span
      className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${styles[variant]}`}
    >
      {children}
    </span>
  );
}
