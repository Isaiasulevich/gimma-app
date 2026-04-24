import { createClient } from '@/lib/supabase/server';

type Plan = {
  id: string;
  user_id: string;
  name: string;
  goal: string;
  split_type: string;
  days_per_week: number;
  generated_by_ai: boolean;
  ai_reasoning: string | null;
  is_active: boolean;
  started_at: string | null;
  created_at: string;
  pack_id: string | null;
};

type Day = {
  id: string;
  day_number: number;
  name: string;
  focus: string;
};

type Prescription = {
  id: string;
  plan_day_id: string;
  exercise_id: string;
  order: number;
  target_sets: number;
  target_reps_min: number;
  target_reps_max: number;
  target_rir: number;
  target_rest_seconds: number;
  notes: string | null;
};

type Exercise = { id: string; name: string; primary_muscle: string };

type AiCall = {
  id: string;
  provider: string;
  model: string;
  latency_ms: number | null;
  input_tokens: number | null;
  output_tokens: number | null;
  cost_usd: number | null;
  created_at: string;
};

export async function PlanDisplay({ planId }: { planId: string }) {
  const supabase = await createClient();

  const { data: plan, error: planErr } = await supabase
    .from('plans')
    .select()
    .eq('id', planId)
    .maybeSingle<Plan>();

  if (planErr || !plan) {
    return <div className="rounded border bg-red-50 p-4 text-sm text-red-700">Plan not found: {planErr?.message ?? planId}</div>;
  }

  const { data: days = [] } = await supabase
    .from('plan_days')
    .select()
    .eq('plan_id', planId)
    .order('day_number')
    .returns<Day[]>();

  const dayIds = (days ?? []).map((d) => d.id);
  const { data: prescriptions = [] } = dayIds.length
    ? await supabase
        .from('plan_prescriptions')
        .select()
        .in('plan_day_id', dayIds)
        .order('order')
        .returns<Prescription[]>()
    : { data: [] as Prescription[] };

  const exerciseIds = Array.from(new Set((prescriptions ?? []).map((p) => p.exercise_id)));
  const { data: exercises = [] } = exerciseIds.length
    ? await supabase
        .from('exercises')
        .select('id, name, primary_muscle')
        .in('id', exerciseIds)
        .returns<Exercise[]>()
    : { data: [] as Exercise[] };

  const exerciseById = new Map((exercises ?? []).map((e) => [e.id, e]));

  // Most recent plan_gen AI call for this user — almost certainly the one
  // that produced this plan (no FK on ai_calls → plans yet).
  const { data: call } = await supabase
    .from('ai_calls')
    .select('id, provider, model, latency_ms, input_tokens, output_tokens, cost_usd, created_at')
    .eq('user_id', plan.user_id)
    .eq('kind', 'plan_gen')
    .lte('created_at', new Date(new Date(plan.created_at).getTime() + 5000).toISOString())
    .gte('created_at', new Date(new Date(plan.created_at).getTime() - 60000).toISOString())
    .order('created_at', { ascending: false })
    .limit(1)
    .maybeSingle<AiCall>();

  const prescriptionsByDay = new Map<string, Prescription[]>();
  for (const p of prescriptions ?? []) {
    const list = prescriptionsByDay.get(p.plan_day_id) ?? [];
    list.push(p);
    prescriptionsByDay.set(p.plan_day_id, list);
  }

  return (
    <div className="space-y-6">
      <header className="space-y-1">
        <div className="flex items-center gap-2">
          <h2 className="text-xl font-semibold">{plan.name}</h2>
          {plan.is_active && <span className="rounded-full bg-green-100 px-2 py-0.5 text-xs text-green-800">active</span>}
          {plan.generated_by_ai && <span className="rounded-full bg-blue-100 px-2 py-0.5 text-xs text-blue-800">AI</span>}
        </div>
        <p className="text-sm text-neutral-500">
          Goal: {plan.goal} · Split: {plan.split_type} · {plan.days_per_week}×/week · Pack: {plan.pack_id ?? '—'}
        </p>
        <p className="text-xs text-neutral-400">Created {new Date(plan.created_at).toLocaleString()}</p>
      </header>

      {call && (
        <div className="grid grid-cols-4 gap-3 rounded border bg-neutral-50 p-3 text-xs">
          <div>
            <div className="text-neutral-500">Model</div>
            <div className="font-mono">{call.provider}/{call.model}</div>
          </div>
          <div>
            <div className="text-neutral-500">Latency</div>
            <div>{call.latency_ms ? `${(call.latency_ms / 1000).toFixed(1)}s` : '—'}</div>
          </div>
          <div>
            <div className="text-neutral-500">Tokens</div>
            <div>in {call.input_tokens ?? '-'} · out {call.output_tokens ?? '-'}</div>
          </div>
          <div>
            <div className="text-neutral-500">Cost</div>
            <div>{call.cost_usd !== null ? `$${Number(call.cost_usd).toFixed(4)}` : '—'}</div>
          </div>
        </div>
      )}

      {plan.ai_reasoning && (
        <details className="rounded border p-3 text-sm">
          <summary className="cursor-pointer font-medium">AI reasoning</summary>
          <p className="mt-2 whitespace-pre-wrap text-neutral-700">{plan.ai_reasoning}</p>
        </details>
      )}

      <div className="space-y-4">
        {(days ?? []).map((day) => {
          const pxs = prescriptionsByDay.get(day.id) ?? [];
          return (
            <div key={day.id} className="rounded border">
              <div className="border-b bg-neutral-50 p-3">
                <div className="text-sm font-semibold">Day {day.day_number}: {day.name}</div>
                <div className="text-xs text-neutral-500">{day.focus}</div>
              </div>
              <table className="w-full text-sm">
                <thead className="text-left text-xs text-neutral-500">
                  <tr>
                    <th className="px-3 py-2">#</th>
                    <th className="px-3 py-2">Exercise</th>
                    <th className="px-3 py-2">Sets × Reps</th>
                    <th className="px-3 py-2">RIR</th>
                    <th className="px-3 py-2">Rest</th>
                    <th className="px-3 py-2">Notes</th>
                  </tr>
                </thead>
                <tbody>
                  {pxs.map((p) => {
                    const ex = exerciseById.get(p.exercise_id);
                    return (
                      <tr key={p.id} className="border-t">
                        <td className="px-3 py-2 text-neutral-400">{p.order}</td>
                        <td className="px-3 py-2">
                          <div>{ex?.name ?? <span className="text-red-600">unknown ({p.exercise_id.slice(0, 8)})</span>}</div>
                          {ex && <div className="text-xs text-neutral-400">{ex.primary_muscle}</div>}
                        </td>
                        <td className="px-3 py-2">{p.target_sets} × {p.target_reps_min}–{p.target_reps_max}</td>
                        <td className="px-3 py-2">{p.target_rir}</td>
                        <td className="px-3 py-2">{p.target_rest_seconds}s</td>
                        <td className="px-3 py-2 text-xs text-neutral-500">{p.notes ?? '—'}</td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          );
        })}
      </div>
    </div>
  );
}
