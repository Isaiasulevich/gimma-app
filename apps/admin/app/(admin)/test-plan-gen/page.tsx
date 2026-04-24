'use client';
import { useState } from 'react';
import { createClient } from '@/lib/supabase/client';

export default function TestPlanGen() {
  const [goal, setGoal] = useState('muscle');
  const [daysPerWeek, setDays] = useState(4);
  const [running, setRunning] = useState(false);
  const [result, setResult] = useState<unknown>(null);
  const [err, setErr] = useState<string | null>(null);

  async function run() {
    setRunning(true); setErr(null); setResult(null);
    const supabase = createClient();
    const { data, error } = await supabase.functions.invoke('generate-plan', {
      body: {
        goal,
        experience_level: 'intermediate',
        days_per_week: daysPerWeek,
        session_length_minutes: 60,
        equipment: 'full gym',
        injuries: [],
      },
    });
    setRunning(false);
    if (error) {
      // Supabase FunctionsHttpError exposes the Response on .context. Try to
      // surface the server-side error body so debugging doesn't require
      // `supabase functions logs`.
      const ctx = (error as { context?: Response }).context;
      if (ctx && typeof ctx.text === 'function') {
        try {
          const text = await ctx.text();
          setErr(`${error.message}\n\n${text}`);
        } catch {
          setErr(error.message);
        }
      } else {
        setErr(error.message);
      }
      return;
    }
    setResult(data);
  }

  return (
    <>
      <h1 className="mb-4 text-2xl font-semibold">Test plan-gen</h1>
      <div className="mb-4 flex gap-3 items-end">
        <div>
          <label className="block text-xs">Goal</label>
          <select value={goal} onChange={(e) => setGoal(e.target.value)} className="rounded border p-2">
            <option value="muscle">muscle</option>
            <option value="strength">strength</option>
            <option value="general">general</option>
          </select>
        </div>
        <div>
          <label className="block text-xs">Days / week</label>
          <input type="number" min={2} max={6} value={daysPerWeek} onChange={(e) => setDays(parseInt(e.target.value, 10))} className="w-20 rounded border p-2" />
        </div>
        <button onClick={run} disabled={running} className="rounded bg-black px-4 py-2 text-white disabled:opacity-50">
          {running ? 'Running…' : 'Generate'}
        </button>
      </div>
      {err && <pre className="rounded bg-red-100 p-3 text-sm text-red-800">{err}</pre>}
      {result !== null && (
        <pre className="rounded bg-neutral-100 p-4 text-xs max-h-[600px] overflow-auto">
          {JSON.stringify(result, null, 2)}
        </pre>
      )}
    </>
  );
}
