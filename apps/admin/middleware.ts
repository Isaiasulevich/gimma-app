// Relative import (not `@/` alias) — Vercel's Edge runtime bundler doesn't
// resolve TS path aliases in Turbopack-built middleware.
import { updateSession } from './lib/supabase/middleware';
import type { NextRequest } from 'next/server';

export async function middleware(request: NextRequest) {
  return updateSession(request);
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
};
