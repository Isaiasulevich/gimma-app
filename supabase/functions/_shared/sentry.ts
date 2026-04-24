import * as Sentry from '@sentry/deno';

let initialized = false;

export function initSentry(): void {
  if (initialized) return;
  const dsn = Deno.env.get('SENTRY_DSN_EDGE');
  if (!dsn) return;
  Sentry.init({ dsn, tracesSampleRate: 0.2 });
  initialized = true;
}

export function captureError(e: unknown, extra?: Record<string, unknown>): void {
  initSentry();
  if (!initialized) return;
  Sentry.captureException(e, { extra });
}
