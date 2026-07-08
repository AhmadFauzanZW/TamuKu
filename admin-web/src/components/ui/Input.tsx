import { InputHTMLAttributes, forwardRef } from 'react';

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
}

export const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ label, error, className = '', ...props }, ref) => {
    return (
      <div className="flex flex-col gap-1.5">
        {label && (
          <label className="text-sm font-medium text-text-primary">
            {label}
          </label>
        )}
        <input
          ref={ref}
          className={`w-full px-3 py-2.5 rounded-lg border bg-surface text-text-primary text-sm transition-shadow placeholder:text-text-disabled focus:outline-none focus:ring-2 focus:ring-primary-500/30 focus:border-primary-500 ${
            error ? 'border-accent-red' : 'border-border'
          } ${className}`}
          {...props}
        />
        {error && (
          <p className="text-xs text-accent-red">{error}</p>
        )}
      </div>
    );
  },
);

Input.displayName = 'Input';
