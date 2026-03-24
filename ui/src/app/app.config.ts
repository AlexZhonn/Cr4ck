import {
  ApplicationConfig,
  ErrorHandler,
  provideBrowserGlobalErrorListeners,
  provideAppInitializer,
  inject,
} from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideMonacoEditor } from 'ngx-monaco-editor-v2';

import { routes } from './app.routes';
import { AuthService } from './services/auth.service';
import { GlobalErrorHandler } from './global-error-handler';

// Optional Sentry init — only activates when SENTRY_DSN is injected at build time.
// To enable: set window.__SENTRY_DSN__ before this script loads (e.g. via index.html
// meta tag injection in CI/CD), or replace with Angular environment files.
declare const __SENTRY_DSN__: string | undefined;
function initSentry(): void {
  const dsn = typeof __SENTRY_DSN__ !== 'undefined' ? __SENTRY_DSN__ : undefined;
  if (!dsn) return;
  const load = new Function('specifier', 'return import(specifier)');
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  load('@sentry/angular').then((sentry: any) => {
    sentry.init({
      dsn,
      integrations: [sentry.browserTracingIntegration()],
      tracesSampleRate: 0.1,
      ignoreErrors: ['ChunkLoadError', 'Loading chunk'],
    });
  });
}
initSentry();

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    { provide: ErrorHandler, useClass: GlobalErrorHandler },
    provideRouter(routes),
    provideMonacoEditor(),
    provideAppInitializer(() => inject(AuthService).restore()),
  ],
};
