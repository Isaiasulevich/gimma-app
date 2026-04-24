import { createClient } from '@/lib/supabase/server';
import { LogRow } from './row';

export const dynamic = 'force-dynamic';

type CallRow = {
  id: string;
  kind: string;
  provider: string;
  model: string;
  latency_ms: number | null;
  input_tokens: number | null;
  output_tokens: number | null;
  cost_usd: number | null;
  created_at: string;
  error: string | null;
  request_body: unknown;
  response_body: unknown;
};

export default async function LogsPage({ searchParams }: { searchParams: Promise<{ kind?: string }> }) {
  const { kind } = await searchParams;
  const supabase = await createClient();

  let q = supabase
    .from('ai_calls')
    .select('id, kind, provider, model, latency_ms, input_tokens, output_tokens, cost_usd, created_at, error, request_body, response_body')
    .order('created_at', { ascending: false })
    .limit(100);
  if (kind) q = q.eq('kind', kind);
  const { data } = await q.returns<CallRow[]>();

  const rows = data ?? [];

  const totalCost = rows.reduce((acc, r) => acc + (Number(r.cost_usd) || 0), 0);
  const errorCount = rows.filter((r) => r.error).length;

  // eslint-disable-next-line react-hooks/purity -- server component, runs once per request
  const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString();
  const { data: spendRows } = await supabase
    .from('ai_calls')
    .select('cost_usd, kind')
    .gte('created_at', thirtyDaysAgo)
    .returns<{ cost_usd: number | null; kind: string }[]>();
  const spend30 = (spendRows ?? []).reduce((acc, r) => acc + (Number(r.cost_usd) || 0), 0);
  const spendByKind = new Map<string, number>();
  for (const r of spendRows ?? []) {
    spendByKind.set(r.kind, (spendByKind.get(r.kind) ?? 0) + (Number(r.cost_usd) || 0));
  }
  const topKind = [...spendByKind.entries()].sort((a, b) => b[1] - a[1])[0];

  return (
    <>
      <h1 className="mb-4 text-2xl font-semibold">AI call logs</h1>

      <div className="mb-4 grid grid-cols-2 gap-3 md:grid-cols-4">
        <Stat label="Last 30d spend" value={`$${spend30.toFixed(4)}`} />
        <Stat
          label="Top kind (30d)"
          value={topKind ? `${topKind[0]} · $${topKind[1].toFixed(4)}` : '—'}
        />
        <Stat label="Shown" value={`${rows.length} rows · $${totalCost.toFixed(4)}`} />
        <Stat label="Failures shown" value={errorCount.toString()} tone={errorCount ? 'red' : 'neutral'} />
      </div>

      <div className="mb-4 flex flex-wrap gap-2 text-sm">
        {['all', 'plan_gen', 'weekly_summary', 'review_now', 'onboarding'].map((k) => {
          const active = (k === 'all' && !kind) || k === kind;
          return (
            <a
              key={k}
              href={k === 'all' ? '/logs' : `/logs?kind=${k}`}
              className={`rounded border px-3 py-1 hover:bg-neutral-50 ${active ? 'bg-black text-white hover:bg-black' : ''}`}
            >
              {k}
            </a>
          );
        })}
      </div>

      <div className="space-y-2">
        {rows.map((r) => <LogRow key={r.id} row={r} />)}
      </div>
    </>
  );
}

function Stat({ label, value, tone = 'neutral' }: { label: string; value: string; tone?: 'neutral' | 'red' }) {
  return (
    <div className={`rounded border p-3 ${tone === 'red' ? 'bg-red-50' : 'bg-neutral-50'}`}>
      <div className="text-xs text-neutral-500">{label}</div>
      <div className="mt-1 text-lg font-semibold">{value}</div>
    </div>
  );
}
