import { ErrorHandler, Injectable, NgZone } from '@angular/core';

/** Forward errors to Sentry if the SDK is loaded (optional — loaded via environment). */
function reportToSentry(err: Error): void {
  try {
    // @ts-expect-error — Sentry is optionally loaded at runtime
    if (typeof Sentry !== 'undefined') {
      // @ts-expect-error — Sentry is optionally loaded at runtime
      Sentry.captureException(err);
    }
  } catch {
    // Sentry unavailable — silently ignore
  }
}

@Injectable()
export class GlobalErrorHandler implements ErrorHandler {
  constructor(private zone: NgZone) {}

  handleError(error: unknown): void {
    // Run outside Angular's zone to avoid triggering change detection loops
    this.zone.runOutsideAngular(() => {
      const err = error instanceof Error ? error : new Error(String(error));

      // Skip chunk-load errors (lazy route not yet cached) — browser will retry
      if (err.message?.includes('ChunkLoadError') || err.message?.includes('Loading chunk')) {
        return;
      }

      console.error('[GlobalErrorHandler]', err);
      reportToSentry(err);

      // Show a non-intrusive toast-style banner at the bottom of the screen
      this.zone.run(() => showErrorBanner(err.message || 'An unexpected error occurred.'));
    });
  }
}

function showErrorBanner(message: string): void {
  // Avoid duplicate banners
  if (document.getElementById('cr4ck-error-banner')) return;

  const banner = document.createElement('div');
  banner.id = 'cr4ck-error-banner';
  banner.setAttribute('role', 'alert');
  banner.setAttribute('aria-live', 'assertive');
  banner.style.cssText = [
    'position:fixed',
    'bottom:1rem',
    'left:50%',
    'transform:translateX(-50%)',
    'background:#ef4444',
    'color:#fff',
    'padding:0.75rem 1.25rem',
    'border-radius:0.5rem',
    'font-size:0.875rem',
    'max-width:90vw',
    'z-index:9999',
    'box-shadow:0 4px 12px rgba(0,0,0,0.3)',
    'display:flex',
    'align-items:center',
    'gap:0.75rem',
  ].join(';');

  const text = document.createElement('span');
  text.textContent = `Something went wrong: ${message}`;

  const close = document.createElement('button');
  close.textContent = '✕';
  close.setAttribute('aria-label', 'Dismiss error');
  close.style.cssText =
    'background:none;border:none;color:#fff;cursor:pointer;font-size:1rem;padding:0;line-height:1';
  close.onclick = () => banner.remove();

  banner.appendChild(text);
  banner.appendChild(close);
  document.body.appendChild(banner);

  // Auto-dismiss after 8 seconds
  setTimeout(() => banner.remove(), 8000);
}
