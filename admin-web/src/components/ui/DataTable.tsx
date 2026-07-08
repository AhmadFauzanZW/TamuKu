import { Fragment, useState } from 'react';
import type { ReactNode } from 'react';

interface Column<T> {
  key: string;
  header: string;
  render?: (item: T) => ReactNode;
  className?: string;
}

interface DataTableProps<T> {
  columns: Column<T>[];
  data: T[];
  keyExtractor: (item: T) => string;
  emptyMessage?: string;
  onRowClick?: (item: T) => void;
  expandedRowRender?: (item: T) => ReactNode;
}

export function DataTable<T>({
  columns,
  data,
  keyExtractor,
  emptyMessage = 'Tidak ada data',
  onRowClick,
  expandedRowRender,
}: DataTableProps<T>) {
  const [expandedKey, setExpandedKey] = useState<string | null>(null);

  function handleRowClick(item: T) {
    if (expandedRowRender) {
      const key = keyExtractor(item);
      setExpandedKey((prev) => (prev === key ? null : key));
    } else {
      onRowClick?.(item);
    }
  }

  if (data.length === 0) {
    return (
      <div className="bg-surface rounded-xl shadow-sm p-12 text-center text-text-secondary">
        {emptyMessage}
      </div>
    );
  }

  return (
    <div className="bg-surface rounded-xl shadow-sm overflow-hidden">
      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead>
            <tr className="bg-background border-b border-border-light">
              {columns.map((col) => (
                <th
                  key={col.key}
                  className={`px-4 py-3 text-left text-xs font-semibold text-text-secondary uppercase tracking-wider ${col.className ?? ''}`}
                >
                  {col.header}
                </th>
              ))}
              {expandedRowRender && (
                <th className="px-4 py-3 w-10" />
              )}
            </tr>
          </thead>
          <tbody className="divide-y divide-border-light">
            {data.map((item) => {
              const key = keyExtractor(item);
              const isExpanded = expandedKey === key;
              return (
                <Fragment key={key}>
                  <tr
                    onClick={() => handleRowClick(item)}
                    className={`transition-colors hover:bg-primary-50/50 ${
                      expandedRowRender || onRowClick ? 'cursor-pointer' : ''
                    }`}
                  >
                    {columns.map((col) => (
                      <td key={col.key} className={`px-4 py-3 ${col.className ?? ''}`}>
                        {col.render
                          ? col.render(item)
                          : String((item as Record<string, unknown>)[col.key] ?? '')}
                      </td>
                    ))}
                    {expandedRowRender && (
                      <td className="px-4 py-3 text-right">
                        <svg
                          className={`w-4 h-4 text-text-secondary transition-transform duration-200 ${isExpanded ? 'rotate-90' : ''}`}
                          fill="none"
                          viewBox="0 0 24 24"
                          stroke="currentColor"
                          strokeWidth={2}
                        >
                          <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
                        </svg>
                      </td>
                    )}
                  </tr>
                  {expandedRowRender && (
                    <tr>
                      <td colSpan={columns.length + 1} className="p-0">
                        <div
                          className="overflow-hidden transition-all duration-300 ease-in-out"
                          style={{ maxHeight: isExpanded ? '500px' : '0' }}
                        >
                          <div className="px-4 py-4 bg-background/60 border-b border-border-light">
                            {expandedRowRender(item)}
                          </div>
                        </div>
                      </td>
                    </tr>
                  )}
                </Fragment>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}
