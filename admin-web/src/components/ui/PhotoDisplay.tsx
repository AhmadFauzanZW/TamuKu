import { useState, useEffect, useCallback } from 'react';
import { getSignedPhotoUrl } from '../../lib/photo';

interface PhotoDisplayProps {
  rawUrl: string;
  label: string;
  cache?: Map<string, string>;
  onCacheHit?: (raw: string, signed: string) => void;
}

export function PhotoDisplay({ rawUrl, label, cache, onCacheHit }: PhotoDisplayProps) {
  const [src, setSrc] = useState('');
  const [loaded, setLoaded] = useState(false);

  const resolve = useCallback(async () => {
    if (!rawUrl) {
      setLoaded(true);
      return;
    }
    if (cache?.has(rawUrl)) {
      setSrc(cache.get(rawUrl)!);
      setLoaded(true);
      return;
    }
    const signed = await getSignedPhotoUrl(rawUrl);
    onCacheHit?.(rawUrl, signed);
    setSrc(signed);
    setLoaded(true);
  }, [rawUrl, cache, onCacheHit]);

  useEffect(() => {
    resolve();
  }, [resolve]);

  if (!rawUrl) {
    return <div className="text-sm text-text-secondary italic">Tidak ada foto</div>;
  }
  if (!loaded || !src) {
    return <div className="text-sm text-text-secondary">Memuat foto...</div>;
  }
  return (
    <div>
      <p className="text-xs font-medium text-text-secondary mb-1">{label}</p>
      <img
        src={src}
        alt={label}
        className="max-w-[300px] rounded-lg border border-border-light"
      />
    </div>
  );
}
