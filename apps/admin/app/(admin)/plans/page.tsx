import Link from 'next/link';
import { createClient } from '@/lib/supabase/server';

export const dynamic = 'force-dynamic';

type PlanRow = {
  id: string;
  user_id: string;
  name: string;
  goal: string;
  split_type: string;
  days_per_week: number;
  generated_by_ai: boolean;
  is_active: boolean;
  pack_id: string | null;
  created_at: string;
  users: { email: string | null } | null;
};

type CallCostRow = {
  user_id: string | null;
  created_at: string;
  cost_usd: number | null;
};

export default async function PlansPage() {
  const supabase = await createClient();

  const { data: plans, error } = await supabase
    .from('plans')
    .select('id, user_id, name, goal, split_type, days_per_week, generated_by_ai, is_active, pack_id, created_at, users(email)')
    .order('created_at', { ascending: false })
    .limit(100)
    .returns<PlanRow[]>();

  if (error) {
    return (
      <>
        <h1 className="mb-4 text-2xl font-semibold">Plans</h1>
        <p className="rounded bg-red-50 p-3 text-sm text-red-800">
          Error loading plans: {error.message}
        </p>
        <p className="mt-3 text-sm text-neutral-500">
          If the error mentions &ldquo;permission denied&rdquo;, you need to apply migration{' '}
          <code>20260421000012_admin_plan_read.sql</code> to the hosted DB.
        </p>
      </>
    );
  }

  // Fetch matching ai_call rows (one per user, latest plan_gen) for cost mapping.
  // Simpler: pull all plan_gen calls in a window around plan creation times.
  const userIds = Array.from(new Set((plans ?? []).map((p) => p.user_id)));
  const { data: calls = [] } = userIds.length
    ? await supabase
        .from('ai_calls')
        .select('user_id, created_at, cost_usd')
        .eq('kind', 'plan_gen')
        .in('user_id', userIds)
        .returns<CallCostRow[]>()
    : { data: [] as CallCostRow[] };

  // Match each plan to the nearest ai_call (user_id + closest created_at).
  function costFor(plan: PlanRow): number | null {
    const planTime = new Date(plan.created_at).getTime();
    let best: CallCostRow | null = null;
    let bestDelta = Infinity;
    for (const c of calls ?? []) {
      if (c.user_id !== plan.user_id) continue;
      const d = Math.abs(new Date(c.created_at).getTime() - planTime);
      if (d < bestDelta && d < 60_000) {
        bestDelta = d;
        best = c;
      }
    }
    return best?.cost_usd ?? null;
  }

  const totalCost = (plans ?? []).reduce((acc, p) => acc + (costFor(p) ?? 0), 0);

  return (
    <>
      <div className="mb-4 flex items-baseline justify-between">
        <h1 className="text-2xl font-semibold">Plans</h1>
        <div className="text-xs text-neutral-500">
          {(plans ?? []).length} plans · total plan-gen spend ≈ ${totalCost.toFixed(4)}
        </div>
      </div>
      {(!plans || plans.length === 0) ? (
        <p className="text-sm text-neutral-500">No plans yet. Generate one from <Link className="underline" href="/test-plan-gen">/test-plan-gen</Link> or the mobile app.</p>
      ) : (
        <div className="overflow-x-auto rounded border">
          <table className="w-full text-sm">
            <thead className="bg-neutral-50 text-left text-xs text-neutral-500">
              <tr>
                <th className="px-3 py-2">When</th>
                <th className="px-3 py-2">User</th>
                <th className="px-3 py-2">Name</th>
                <th className="px-3 py-2">Goal / Split</th>
                <th className="px-3 py-2">Days</th>
                <th className="px-3 py-2">Pack</th>
                <th className="px-3 py-2">Cost</th>
                <th className="px-3 py-2"></th>
              </tr>
            </thead>
            <tbody>
              {plans.map((p) => {
                const cost = costFor(p);
                return (
                  <tr key={p.id} className="border-t hover:bg-neutral-50">
                    <td className="px-3 py-2 whitespace-nowrap text-neutral-500">{new Date(p.created_at).toLocaleString()}</td>
                    <td className="px-3 py-2 whitespace-nowrap">{p.users?.email ?? p.user_id.slice(0, 8)}</td>
                    <td className="px-3 py-2">
                      <div className="flex items-center gap-2">
                        <span>{p.name}</span>
                        {p.is_active && <span className="rounded-full bg-green-100 px-2 py-0.5 text-xs text-green-800">active</span>}
                        {p.generated_by_ai && <span className="rounded-full bg-blue-100 px-2 py-0.5 text-xs text-blue-800">AI</span>}
                      </div>
                    </td>
                    <td className="px-3 py-2 text-xs">{p.goal} · {p.split_type}</td>
                    <td className="px-3 py-2">{p.days_per_week}×</td>
                    <td className="px-3 py-2 text-xs">{p.pack_id ?? '—'}</td>
                    <td className="px-3 py-2">{cost !== null ? `$${cost.toFixed(4)}` : '—'}</td>
                    <td className="px-3 py-2">
                      <Link className="text-xs underline" href={`/plans/${p.id}`}>view</Link>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}
    </>
  );
}
