import { serve } from 'std/http/server.ts';
import { createClient } from '@supabase/supabase-js';
import { generateObject } from 'ai';
import { z } from 'zod';
import { resolveModel } from '../_shared/ai_providers.ts';
import { loadAiConfig } from '../_shared/load_ai_config.ts';
import { computeWeeklyMetrics } from '../_shared/compute_metrics.ts';
import { ANALYST_SYSTEM_PROMPT } from '../_shared/analyst_prompt.ts';

const SummarySchema = z.object({ summary_md: z.string().min(20).max(2000) });

serve(async (_req) => {
  const admin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  );

  const cfg = await loadAiConfig(admin);
  const model = resolveModel(cfg.provider, cfg.model);

  const { data: users } = await admin
    .from('users')
    .select('id')
    .not('onboarding_completed_at', 'is', null);

  const results: Record<string, string> = {};
  for (const u of users ?? []) {
    const metrics = await computeWeeklyMetrics(admin, u.id, new Date());
    if (metrics.total_sets === 0) continue;

    const { object, usage } = await generateObject({
      model,
      system: ANALYST_SYSTEM_PROMPT,
      prompt: `User metrics:\n${JSON.stringify(metrics, null, 2)}`,
      schema: SummarySchema,
      temperature: cfg.temperature,
    });

    await admin.from('weekly_summaries').upsert({
      user_id: u.id,
      week_start: metrics.week_start,
      summary_md: object.summary_md,
      volume_by_muscle: metrics.volume_by_muscle,
      frequency: metrics.frequency,
      stalls: metrics.stalls,
      prs: metrics.prs,
      generated_at: new Date().toISOString(),
    }, { onConflict: 'user_id,week_start' });

    await admin.from('ai_calls').insert({
      user_id: u.id,
      kind: 'weekly_summary',
      provider: cfg.provider,
      model: cfg.model,
      input_tokens: usage?.promptTokens,
      output_tokens: usage?.completionTokens,
      request_body: metrics,
      response_body: object,
    });

    results[u.id] = 'ok';
  }

  return new Response(JSON.stringify({ processed: results }), {
    headers: { 'content-type': 'application/json' },
  });
});
