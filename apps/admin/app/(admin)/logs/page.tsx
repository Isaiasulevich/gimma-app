import { createClient } from '@/lib/supabase/server';
import { LogRow } from './row';

export const dynamic = 'force-dynamic';

export default async function LogsPage({ searchParams }: { searchParams: Promise<{ kind?: string }> }) {
  const { kind } = await searchParams;
  const supabase = await createClient();
  let q = supabase.from('ai_calls').select().order('created_at', { ascending: false }).limit(100);
  if (kind) q = q.eq('kind', kind);
  const { data } = await q;
  return (
    <>
      <h1 className="mb-4 text-2xl font-semibold">AI call logs</h1>
      <div className="mb-4 flex gap-2 text-sm">
        {['all', 'plan_gen', 'weekly_summary', 'review_now', 'onboarding'].map((k) => (
          <a key={k} href={k === 'all' ? '/logs' : `/logs?kind=${k}`}
             className="rounded border px-3 py-1 hover:bg-neutral-50">{k}</a>
        ))}
      </div>
      <div className="space-y-2">
        {(data ?? []).map((r) => <LogRow key={r.id} row={r} />)}
      </div>
    </>
  );
}
