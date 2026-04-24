import { serve } from 'std/http/server.ts';
import { createClient } from '@supabase/supabase-js';
import { generateObject } from 'ai';
import { z } from 'zod';
import { resolveModel } from '../_shared/ai_providers.ts';
import { loadAiConfig } from '../_shared/load_ai_config.ts';
import { computeWeeklyMetrics } from '../_shared/compute_metrics.ts';
import { ANALYST_SYSTEM_PROMPT } from '../_shared/analyst_prompt.ts';
import { initSentry, captureError } from '../_shared/sentry.ts';

initSentry();

const SummarySchema = z.object({ summary_md: z.string().min(20).max(2000) });

const CORS_HEADERS: Record<string, string> = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

serve(async (req) => {
  try {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS_HEADERS });
  }

  const jwt = req.headers.get('authorization')?.replace('Bearer ', '');
  if (!jwt) return new Response('Unauthorized', { status: 401, headers: CORS_HEADERS });

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const userClient = createClient(
    supabaseUrl,
    Deno.env.get('SUPABASE_ANON_KEY')!,
    { global: { headers: { Authorization: `Bearer ${jwt}` } } },
  );
  const admin = createClient(
    supabaseUrl,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  );

  const { data: auth } = await userClient.auth.getUser();
  if (!auth.user) return new Response('Unauthorized', { status: 401, headers: CORS_HEADERS });
  const userId = auth.user.id;

  const cfg = await loadAiConfig(admin);
  const model = resolveModel(cfg.provider, cfg.model);
  const metrics = await computeWeeklyMetrics(admin, userId, new Date());

  if (metrics.total_sets === 0) {
    return new Response(JSON.stringify({ summary_md: 'No training logged this week yet.' }), {
      headers: { 'content-type': 'application/json', ...CORS_HEADERS },
    });
  }

  const { object, usage } = await generateObject({
    model,
    system: ANALYST_SYSTEM_PROMPT,
    prompt: `User metrics:\n${JSON.stringify(metrics, null, 2)}`,
    schema: SummarySchema,
    temperature: cfg.temperature,
  });

  await admin.from('ai_calls').insert({
    user_id: userId,
    kind: 'review_now',
    provider: cfg.provider,
    model: cfg.model,
    input_tokens: usage?.promptTokens,
    output_tokens: usage?.completionTokens,
    request_body: metrics,
    response_body: object,
  });

  return new Response(JSON.stringify(object), {
    headers: { 'content-type': 'application/json', ...CORS_HEADERS },
  });
  } catch (e) {
    captureError(e, { url: req.url });
    throw e;
  }
});
