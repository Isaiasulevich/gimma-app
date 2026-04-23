import type { SupabaseClient } from '@supabase/supabase-js';

export async function loadPack(client: SupabaseClient, goal: string) {
  const { data } = await client
    .from('knowledge_packs')
    .select('*')
    .eq('goal', goal)
    .eq('is_active', true)
    .order('version', { ascending: false })
    .limit(1);
  if (data && data.length > 0) return data[0];

  // Fallback: hypertrophy-v1.
  const { data: fallback, error } = await client
    .from('knowledge_packs')
    .select('*')
    .eq('id', 'hypertrophy-v1')
    .single();
  if (error) throw error;
  return fallback;
}
