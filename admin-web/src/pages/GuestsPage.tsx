import { useState, useEffect, useMemo, useCallback } from 'react';
import { collection, getDocs } from 'firebase/firestore';
import { db } from '../config/firebase';
import { DataTable } from '../components/ui/DataTable';
import { SearchBar } from '../components/ui/SearchBar';
import { Badge } from '../components/ui/Badge';
import { Select } from '../components/ui/Select';
import { Card } from '../components/ui/Card';
import { PageLoader } from '../components/ui/LoadingSpinner';
import { showToast } from '../components/ui/Toast';
import { PhotoDisplay } from '../components/ui/PhotoDisplay';
import { formatDateWIB } from '../lib/utils';
import type { Guest, Location } from '../types';

type DateMode = 'daily' | 'weekly' | 'monthly' | 'custom';

/** Get start of day in WIB (Asia/Jakarta). */
function startOfDayWIB(d: Date): Date {
  // Create date in WIB by using locale string approach
  const wib = new Date(d.toLocaleString('en-US', { timeZone: 'Asia/Jakarta' }));
  return new Date(wib.getFullYear(), wib.getMonth(), wib.getDate());
}

/** Get today's date in WIB as a plain Date (00:00). */
function todayWIB(): Date {
  return startOfDayWIB(new Date());
}

/** Add months to a date, clamping to last day. */
function addMonthsClamped(d: Date, months: number): Date {
  const result = new Date(d);
  result.setMonth(result.getMonth() + months);
  // clamp to last valid day
  const maxDay = new Date(result.getFullYear(), result.getMonth() + 1, 0).getDate();
  if (result.getDate() > maxDay) result.setDate(maxDay);
  return result;
}

/** Format date as "8 Juli 2026" (Indonesian long date). */
function formatDateLong(d: Date): string {
  return d.toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' });
}

/** Format date as "7 - 13 Juli 2026" (Indonesian week range). */
function formatDateRange(from: Date, to: Date): string {
  const fDay = from.getDate();
  const tDay = to.getDate();
  const monthYear = from.toLocaleDateString('id-ID', { month: 'long', year: 'numeric' });
  return `${fDay} - ${tDay} ${monthYear}`;
}

/** Format month label "Juli 2026". */
function formatMonthYear(d: Date): string {
  return d.toLocaleDateString('id-ID', { month: 'long', year: 'numeric' });
}

/** Convert Date to YYYY-MM-DD for input[type=date]. */
function toISODate(d: Date): string {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

export function GuestsPage() {
  const [guests, setGuests] = useState<Guest[]>([]);
  const [locations, setLocations] = useState<Location[]>([]);
  const [search, setSearch] = useState('');
  const [filterLocation, setFilterLocation] = useState('');
  const [filterStatus, setFilterStatus] = useState('');
  const [dateMode, setDateMode] = useState<DateMode>('daily');
  const [dateOffset, setDateOffset] = useState(0);
  const [customDateFrom, setCustomDateFrom] = useState('');
  const [customDateTo, setCustomDateTo] = useState('');
  const [loading, setLoading] = useState(true);

  const switchMode = useCallback((mode: DateMode) => {
    setDateMode(mode);
    setDateOffset(0);
    if (mode !== 'custom') {
      setCustomDateFrom('');
      setCustomDateTo('');
    }
  }, []);

  const goPrev = useCallback(() => {
    setDateOffset((o) => o - 1);
  }, []);

  const goNext = useCallback(() => {
    setDateOffset((o) => (o < 0 ? o + 1 : o));
  }, []);

  /** Computed date range from mode + offset. */
  const { filterDateFrom, filterDateTo, periodLabel, canGoNext } = useMemo(() => {
    if (dateMode === 'custom') {
      return {
        filterDateFrom: customDateFrom,
        filterDateTo: customDateTo,
        periodLabel: '',
        canGoNext: false,
      };
    }

    const today = todayWIB();

    if (dateMode === 'daily') {
      const d = new Date(today);
      d.setDate(d.getDate() + dateOffset);
      const to = new Date(d);
      to.setDate(to.getDate() + 1);
      to.setMilliseconds(to.getTime() - 1);
      return {
        filterDateFrom: toISODate(d),
        filterDateTo: toISODate(to),
        periodLabel: formatDateLong(d),
        canGoNext: dateOffset >= 0,
      };
    }

    if (dateMode === 'weekly') {
      // Find Monday of current week
      const dayOfWeek = today.getDay(); // 0=Sun,1=Mon
      const mondayOffset = dayOfWeek === 0 ? -6 : 1 - dayOfWeek;
      const monday = new Date(today);
      monday.setDate(monday.getDate() + mondayOffset + dateOffset * 7);
      const sunday = new Date(monday);
      sunday.setDate(sunday.getDate() + 6);
      sunday.setHours(23, 59, 59, 999);
      return {
        filterDateFrom: toISODate(monday),
        filterDateTo: toISODate(sunday),
        periodLabel: formatDateRange(monday, sunday),
        canGoNext: dateOffset >= 0,
      };
    }

    // monthly
    const monthStart = addMonthsClamped(today, dateOffset);
    const monthEnd = new Date(monthStart.getFullYear(), monthStart.getMonth() + 1, 0, 23, 59, 59, 999);
    return {
      filterDateFrom: toISODate(monthStart),
      filterDateTo: toISODate(monthEnd),
      periodLabel: formatMonthYear(monthStart),
      canGoNext: dateOffset >= 0,
    };
  }, [dateMode, dateOffset, customDateFrom, customDateTo]);

  useEffect(() => {
    async function load() {
      try {
        const [guestSnap, locSnap] = await Promise.all([
          getDocs(collection(db, 'guests')),
          getDocs(collection(db, 'locations')),
        ]);

        const locMap = new Map<string, string>();
        locSnap.docs.forEach((d) => {
          locMap.set(d.id, d.data().name ?? '');
        });

        setLocations(
          locSnap.docs.map((d) => ({
            locationId: d.id,
            name: d.data().name ?? '',
            address: d.data().address ?? '',
            adminId: d.data().adminId ?? '',
            hostPhone: d.data().hostPhone ?? '',
            qrCodeValue: d.data().qrCodeValue ?? '',
            createdAt: d.data().createdAt?.toDate?.() ?? new Date(),
            isActive: d.data().isActive ?? true,
          })),
        );

        const data: Guest[] = guestSnap.docs.map((d) => ({
          guestId: d.id,
          name: d.data().name ?? '',
          phone: d.data().phone ?? '',
          email: d.data().email ?? '',
          keperluan: d.data().keperluan ?? 'Lainnya',
          instansi: d.data().instansi ?? '',
          photoUrl: d.data().photoUrl ?? '',
          checkInPhotoUrl: d.data().checkInPhotoUrl ?? '',
          checkOutPhotoUrl: d.data().checkOutPhotoUrl ?? '',
          locationId: d.data().locationId ?? '',
          checkInTime: d.data().checkInTime?.toDate?.() ?? new Date(),
          checkOutTime: d.data().checkOutTime?.toDate?.() ?? null,
          hostPhone: d.data().hostPhone ?? '',
          status: d.data().status ?? 'checked_in',
        }));

        data.sort((a, b) => b.checkInTime.getTime() - a.checkInTime.getTime());
        setGuests(data);
      } catch (err) {
        console.error(err);
        showToast('error', 'Gagal memuat data tamu');
      } finally {
        setLoading(false);
      }
    }

    load();
  }, []);

  const locationNameMap = useMemo(() => {
    const map = new Map<string, string>();
    locations.forEach((l) => map.set(l.locationId, l.name));
    return map;
  }, [locations]);

  const filtered = useMemo(() => {
    const fromDate = filterDateFrom ? new Date(filterDateFrom) : null;
    const toDate = filterDateTo ? new Date(filterDateTo) : null;

    return guests.filter((g) => {
      const matchSearch =
        !search ||
        g.name.toLowerCase().includes(search.toLowerCase()) ||
        g.instansi.toLowerCase().includes(search.toLowerCase()) ||
        g.phone.includes(search);
      const matchLocation = !filterLocation || g.locationId === filterLocation;
      const matchStatus = !filterStatus || g.status === filterStatus;
      const matchDateFrom = !fromDate || g.checkInTime >= fromDate;
      const matchDateTo = !toDate || g.checkInTime <= toDate;
      return matchSearch && matchLocation && matchStatus && matchDateFrom && matchDateTo;
    });
  }, [guests, search, filterLocation, filterStatus, filterDateFrom, filterDateTo]);

  const locationOptions = locations.map((l) => ({
    value: l.locationId,
    label: l.name,
  }));

  if (loading) return <PageLoader />;

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-xl font-bold text-text-primary">Tamu</h2>
        <p className="text-sm text-text-secondary mt-0.5">
          Daftar kunjungan tamu ({filtered.length} dari {guests.length} total)
        </p>
      </div>

      {/* Filters */}
      <Card padding={false} className="p-4">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
          <SearchBar
            value={search}
            onChange={setSearch}
            placeholder="Cari nama, instansi, telepon..."
          />
          <Select
            value={filterLocation}
            onChange={(e) => setFilterLocation(e.target.value)}
            options={[{ value: '', label: 'Semua Lokasi' }, ...locationOptions]}
            placeholder="Semua Lokasi"
          />
          <Select
            value={filterStatus}
            onChange={(e) => setFilterStatus(e.target.value)}
            options={[
              { value: '', label: 'Semua Status' },
              { value: 'checked_in', label: 'Sedang Di Lokasi' },
              { value: 'checked_out', label: 'Sudah Pulang' },
            ]}
            placeholder="Semua Status"
          />
        </div>
        {/* Smart Date Filter */}
        <div className="flex flex-col sm:flex-row items-start sm:items-center gap-3 mt-3">
          {/* Mode Selector — pill buttons */}
          <div className="flex rounded-lg border border-border-light overflow-hidden">
            {([
              ['daily', 'Harian'],
              ['weekly', 'Mingguan'],
              ['monthly', 'Bulanan'],
              ['custom', 'Custom'],
            ] as const).map(([mode, label]) => (
              <button
                key={mode}
                onClick={() => switchMode(mode)}
                className={`px-3 py-1.5 text-xs font-medium transition-colors ${
                  dateMode === mode
                    ? 'bg-primary-900 text-white'
                    : 'bg-white text-primary hover:bg-primary-50'
                }`}
              >
                {label}
              </button>
            ))}
          </div>

          {/* Navigation arrows + period label (non-custom) */}
          {dateMode !== 'custom' && (
            <div className="flex items-center gap-2">
              <button
                onClick={goPrev}
                className="w-7 h-7 flex items-center justify-center rounded-md border border-border-light bg-white text-text-primary hover:bg-primary-50 transition-colors text-sm"
              >
                ‹
              </button>
              <span className="text-sm font-semibold text-text-primary min-w-[180px] text-center whitespace-nowrap">
                {periodLabel}
              </span>
              <button
                onClick={goNext}
                disabled={!canGoNext}
                className={`w-7 h-7 flex items-center justify-center rounded-md border text-sm transition-colors ${
                  canGoNext
                    ? 'border-border-light bg-white text-text-primary hover:bg-primary-50'
                    : 'border-border-light bg-white opacity-50 cursor-not-allowed text-text-secondary'
                }`}
              >
                ›
              </button>
            </div>
          )}

          {/* Custom date inputs */}
          {dateMode === 'custom' && (
            <div className="flex items-center gap-2">
              <div className="flex items-center gap-1.5">
                <label className="text-xs text-text-secondary">Dari</label>
                <input
                  type="date"
                  value={customDateFrom}
                  onChange={(e) => setCustomDateFrom(e.target.value)}
                  className="px-2 py-1 text-xs bg-white border border-border-light rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                />
              </div>
              <div className="flex items-center gap-1.5">
                <label className="text-xs text-text-secondary">Sampai</label>
                <input
                  type="date"
                  value={customDateTo}
                  onChange={(e) => setCustomDateTo(e.target.value)}
                  className="px-2 py-1 text-xs bg-white border border-border-light rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                />
              </div>
            </div>
          )}
        </div>
      </Card>

      <DataTable
        columns={[
          {
            key: 'photoUrl',
            header: 'Foto',
            render: (g) => (
              <div className="flex items-center gap-2">
                {g.photoUrl ? (
                  <img
                    src={g.photoUrl}
                    alt={g.name}
                    className="w-10 h-10 rounded-full object-cover border-2 border-green-100"
                    onError={(e) => {
                      (e.target as HTMLImageElement).style.display = 'none';
                    }}
                  />
                ) : (
                  <div className="w-10 h-10 rounded-full bg-green-50 flex items-center justify-center text-green-700 font-semibold text-sm">
                    {g.name?.substring(0, 2).toUpperCase()}
                  </div>
                )}
              </div>
            ),
          },
          {
            key: 'name',
            header: 'Nama',
            render: (g) => <span className="font-medium">{g.name}</span>,
          },
          { key: 'instansi', header: 'Instansi' },
          { key: 'keperluan', header: 'Keperluan' },
          {
            key: 'locationId',
            header: 'Lokasi',
            render: (g) => locationNameMap.get(g.locationId) ?? '—',
          },
          {
            key: 'checkInTime',
            header: 'Masuk',
            render: (g) => formatDateWIB(g.checkInTime),
          },
          {
            key: 'checkOutTime',
            header: 'Pulang',
            render: (g) => (
              <span className="inline-flex items-center gap-1">
                {formatDateWIB(g.checkOutTime)}
                {g.checkOutPhotoUrl && (
                  <span title="Foto check-out tersedia" className="text-xs">📸</span>
                )}
              </span>
            ),
          },
          {
            key: 'status',
            header: 'Status',
            render: (g) => (
              <Badge
                variant={g.status === 'checked_in' ? 'success' : 'neutral'}
              >
                {g.status === 'checked_in' ? 'Masuk' : 'Pulang'}
              </Badge>
            ),
          },
        ]}
        data={filtered}
        keyExtractor={(g) => g.guestId}
        emptyMessage="Tidak ada tamu ditemukan"
        expandedRowRender={(g) => (
          <div className="flex flex-wrap gap-6">
            <PhotoDisplay rawUrl={g.checkInPhotoUrl} label="Foto Check-in" />
            <PhotoDisplay rawUrl={g.checkOutPhotoUrl} label="Foto Check-out" />
          </div>
        )}
      />
    </div>
  );
}
