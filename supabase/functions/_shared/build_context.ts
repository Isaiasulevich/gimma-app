// deno-lint-ignore-file no-explicit-any
import type { SupabaseClient } from '@supabase/supabase-js';

export interface UserContext {
  sessionsCount: number;
  volumeByMuscle: Record<string, number>;
  exercises: Array<{
    id: string;
    name: string;
    primary_muscle: string;
    secondary_muscles: string[];
    equipment: string;
    is_unilateral: boolean;
  }>;
}

export async function buildUserContext(
  client: SupabaseClient,
  userId: string,
): Promise<UserContext> {
  const since = new Date(Date.now() - 30 * 86400_000).toISOString();

  const { data: recentSessions } = await client
    .from('sessions')
    .select('id')
    .eq('user_id', userId)
    .gte('started_at', since);

  const { data: exercises } = await client
    .from('exercises')
    .select('id, name, primary_muscle, secondary_muscles, equipment, is_unilateral')
    .or(`owner_user_id.eq.${userId},owner_user_id.is.null`)
    .eq('is_archived', false);

  // Volume per primary muscle for the recent window.
  const sessionIds = (recentSessions ?? []).map((s: any) => s.id);
  const volumeByMuscle: Record<string, number> = {};
  if (sessionIds.length > 0) {
    const { data: sets } = await client
      .from('sets')
      .select(
        'session_exercise_id, session_exercises!inner(exercise_id, session_id, exercises!inner(primary_muscle))',
      )
      .in('session_exercises.session_id', sessionIds);
    for (const row of (sets ?? []) as any[]) {
      const muscle = row?.session_exercises?.exercises?.primary_muscle as
        | string
        | undefined;
      if (muscle) {
        volumeByMuscle[muscle] = (volumeByMuscle[muscle] ?? 0) + 1;
      }
    }
  }

  return {
    sessionsCount: recentSessions?.length ?? 0,
    volumeByMuscle,
    exercises: (exercises ?? []) as UserContext['exercises'],
  };
}
