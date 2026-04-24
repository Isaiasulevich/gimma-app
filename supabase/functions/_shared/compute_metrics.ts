import type { SupabaseClient } from '@supabase/supabase-js';

export interface WeeklyMetrics {
  week_start: string;
  volume_by_muscle: Record<string, number>;
  frequency: Record<string, number>;
  prs: { exercise_id: string; exercise_name: string; weight: number; reps: number }[];
  stalls: { exercise_id: string; exercise_name: string; weeks_stalled: number }[];
  total_sets: number;
  total_sessions: number;
}

function mondayOfWeek(d: Date): string {
  const day = d.getUTCDay();
  const diff = day === 0 ? -6 : 1 - day;
  const m = new Date(d);
  m.setUTCDate(m.getUTCDate() + diff);
  return m.toISOString().slice(0, 10);
}

export async function computeWeeklyMetrics(
  client: SupabaseClient,
  userId: string,
  referenceDate: Date,
): Promise<WeeklyMetrics> {
  const weekStart = mondayOfWeek(referenceDate);
  const weekStartDate = new Date(weekStart + 'T00:00:00Z');
  const weekEnd = new Date(weekStartDate);
  weekEnd.setUTCDate(weekEnd.getUTCDate() + 7);

  const { data: sessions } = await client
    .from('sessions')
    .select('id, started_at')
    .eq('user_id', userId)
    .gte('started_at', weekStartDate.toISOString())
    .lt('started_at', weekEnd.toISOString());
  const sessionIds = (sessions ?? []).map((s) => s.id);

  if (sessionIds.length === 0) {
    return { week_start: weekStart, volume_by_muscle: {}, frequency: {}, prs: [], stalls: [], total_sets: 0, total_sessions: 0 };
  }

  const { data: sets } = await client
    .from('sets')
    .select('weight, reps, session_exercise_id, session_exercises!inner(session_id, exercise_id, exercises!inner(primary_muscle, name))')
    .in('session_exercises.session_id', sessionIds);

  const volumeByMuscle: Record<string, number> = {};
  const frequencyMuscles: Record<string, Set<string>> = {};
  let totalSets = 0;

  for (const s of sets ?? []) {
    totalSets++;
    const ex = (s as any).session_exercises.exercises;
    const sid = (s as any).session_exercises.session_id as string;
    volumeByMuscle[ex.primary_muscle] = (volumeByMuscle[ex.primary_muscle] ?? 0) + 1;
    frequencyMuscles[ex.primary_muscle] ??= new Set();
    frequencyMuscles[ex.primary_muscle].add(sid);
  }
  const frequency = Object.fromEntries(
    Object.entries(frequencyMuscles).map(([k, v]) => [k, v.size]),
  );

  const prs: WeeklyMetrics['prs'] = [];
  const byExercise: Record<string, { weight: number; reps: number; name: string }[]> = {};
  for (const s of sets ?? []) {
    const exId = (s as any).session_exercises.exercise_id as string;
    const name = (s as any).session_exercises.exercises.name as string;
    byExercise[exId] ??= [];
    byExercise[exId].push({ weight: (s as any).weight ?? 0, reps: (s as any).reps, name });
  }
  for (const [exId, thisWeek] of Object.entries(byExercise)) {
    const { data: priorMaxRow } = await client
      .from('sets')
      .select('weight, session_exercises!inner(exercise_id, sessions!inner(started_at))')
      .eq('session_exercises.exercise_id', exId)
      .lt('session_exercises.sessions.started_at', weekStartDate.toISOString())
      .order('weight', { ascending: false })
      .limit(1);
    const priorMax = (priorMaxRow?.[0] as any)?.weight ?? 0;
    const thisMax = thisWeek.reduce((a, s) => s.weight > a.weight ? s : a, thisWeek[0]);
    if (thisMax.weight > priorMax) {
      prs.push({ exercise_id: exId, exercise_name: thisMax.name, weight: thisMax.weight, reps: thisMax.reps });
    }
  }

  // Stall = exercise where best weight hasn't increased in 3+ weeks.
  const fiveWeeksAgo = new Date(weekStartDate);
  fiveWeeksAgo.setUTCDate(fiveWeeksAgo.getUTCDate() - 28);

  const { data: priorSets } = await client
    .from('sets')
    .select('weight, session_exercises!inner(exercise_id, exercises!inner(name), sessions!inner(started_at))')
    .gte('session_exercises.sessions.started_at', fiveWeeksAgo.toISOString())
    .lt('session_exercises.sessions.started_at', weekEnd.toISOString());

  const exerciseBestByWeek: Record<string, { name: string; weeks: Record<string, number> }> = {};
  for (const s of priorSets ?? []) {
    const row = s as any;
    const exId = row.session_exercises.exercise_id as string;
    const exName = row.session_exercises.exercises.name as string;
    const startedAt = new Date(row.session_exercises.sessions.started_at as string);
    const wk = mondayOfWeek(startedAt);
    const rec = exerciseBestByWeek[exId] ??= { name: exName, weeks: {} };
    const current = rec.weeks[wk] ?? 0;
    if ((row.weight ?? 0) > current) rec.weeks[wk] = row.weight ?? 0;
  }

  const stalls: WeeklyMetrics['stalls'] = [];
  for (const [exId, rec] of Object.entries(exerciseBestByWeek)) {
    const weekEntries = Object.entries(rec.weeks).sort(([a], [b]) => a.localeCompare(b));
    if (weekEntries.length < 3) continue;
    const recent = weekEntries.slice(-3).map(([, v]) => v);
    if (recent[0] === recent[1] && recent[1] === recent[2] && recent[0] > 0) {
      stalls.push({ exercise_id: exId, exercise_name: rec.name, weeks_stalled: 3 });
    }
  }

  return { week_start: weekStart, volume_by_muscle: volumeByMuscle, frequency, prs, stalls, total_sets: totalSets, total_sessions: sessionIds.length };
}
