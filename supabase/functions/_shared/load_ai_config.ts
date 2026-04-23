import type { SupabaseClient } from '@supabase/supabase-js';
import { DEFAULT_SYSTEM_PROMPT } from './system_prompt.ts';

export interface AiConfig {
  provider: 'google' | 'anthropic' | 'openai';
  model: string;
  systemPrompt: string;
  temperature: number;
  maxTokens: number;
}

export async function loadAiConfig(client: SupabaseClient): Promise<AiConfig> {
  const { data, error } = await client
    .from('ai_config')
    .select('*')
    .eq('id', 'active')
    .single();
  if (error) throw error;
  return {
    provider: data.active_provider as AiConfig['provider'],
    model: data.active_model as string,
    systemPrompt:
      (data.system_prompt_override as string | null) ?? DEFAULT_SYSTEM_PROMPT,
    temperature: Number(data.temperature),
    maxTokens: Number(data.max_tokens),
  };
}
