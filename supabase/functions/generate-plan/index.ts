// deno-lint-ignore-file no-explicit-any
import { serve } from 'std/http/server.ts';
import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { generateObject } from 'ai';
import { PlanSchema } from '../_shared/plan_schema.ts';
import { resolveModel } from '../_shared/ai_providers.ts';
import { loadAiConfig } from '../_shared/load_ai_config.ts';
import { loadPack } from '../_shared/load_pack.ts';
import { buildUserContext } from '../_shared/build_context.ts';
import { initSentry, captureError } from '../_shared/sentry.ts';
import { estimateCostUsd } from '../_shared/pricing.ts';

initSentry();

interface RequestBody {
  goal: string;
  experience_level: string;
  days_per_week: number;
  session_length_minutes: number;
  equipment: string;
  injuries: string[];
  style_notes?: string;
}

const CORS_HEADERS: Record<string, string> = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS_HEADERS });
  }
  if (req.method !== 'POST') {
    return json({ error: 'Method not allowed' }, 405);
  }

  const jwt = req.headers.get('authorization')?.replace('Bearer ', '');
  if (!jwt) return json({ error: 'Missing auth' }, 401);

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
  if (!auth.user) return json({ error: 'Unauthorized' }, 401);
  const userId = auth.user.id;

  const body = (await req.json()) as RequestBody;

  const cfg = await loadAiConfig(admin);
  const pack = await loadPack(admin, body.goal);
  const ctx = await buildUserContext(userClient, userId);

  if (ctx.exercises.length === 0) {
    return json({ error: 'No exercises available' }, 400);
  }

  const prompt = buildPrompt(body, pack, ctx);
  const model = resolveModel(cfg.provider, cfg.model);
  const systemPromptHash = await hash(cfg.systemPrompt);
  const startedAt = Date.now();

  let generated: any;
  try {
    const result = await generateObject({
      model,
      system: cfg.systemPrompt,
      prompt,
      schema: PlanSchema,
      temperature: cfg.temperature,
      maxTokens: cfg.maxTokens,
    });
    generated = result;
  } catch (e) {
    captureError(e, { url: req.url, userId });
    await logCall(admin, {
      user_id: userId,
      kind: 'plan_gen',
      provider: cfg.provider,
      model: cfg.model,
      system_prompt_hash: systemPromptHash,
      pack_id: pack.id,
      request_body: { body, prompt_preview: prompt.slice(0, 2000) },
      response_body: null,
      error: (e as Error).message,
      latency_ms: Date.now() - startedAt,
      cost_usd: estimateCostUsd(cfg.provider, cfg.model, null, null),
    });
    return json({ error: (e as Error).message }, 500);
  }

  // Validate: every exercise_id must exist in the user's visible library.
  const visibleIds = new Set(ctx.exercises.map((e) => e.id));
  for (const day of generated.object.days) {
    for (const px of day.prescriptions) {
      if (!visibleIds.has(px.exercise_id)) {
        return json(
          {
            error: `AI referenced unknown exercise_id ${px.exercise_id}`,
            day: day.name,
          },
          422,
        );
      }
    }
  }

  // Deactivate prior active plan (partial-unique-index compliance).
  await admin
    .from('plans')
    .update({ is_active: false, ended_at: new Date().toISOString() })
    .eq('user_id', userId)
    .eq('is_active', true);

  const { data: planRow, error: planErr } = await admin
    .from('plans')
    .insert({
      user_id: userId,
      name: generated.object.name,
      goal: body.goal,
      pack_id: pack.id,
      split_type: generated.object.split_type,
      days_per_week: generated.object.days_per_week,
      generated_by_ai: true,
      ai_reasoning: generated.object.reasoning,
      is_active: true,
      started_at: new Date().toISOString(),
    })
    .select()
    .single();

  if (planErr) return json({ error: planErr.message }, 500);

  for (const day of generated.object.days) {
    const { data: dayRow } = await admin
      .from('plan_days')
      .insert({
        plan_id: planRow.id,
        day_number: day.day_number,
        name: day.name,
        focus: day.focus,
      })
      .select()
      .single();

    for (const px of day.prescriptions) {
      await admin.from('plan_prescriptions').insert({
        plan_day_id: dayRow!.id,
        exercise_id: px.exercise_id,
        order: px.order,
        target_sets: px.target_sets,
        target_reps_min: px.target_reps_min,
        target_reps_max: px.target_reps_max,
        target_rir: px.target_rir,
        target_rest_seconds: px.target_rest_seconds,
        notes: px.notes ?? null,
      });
    }
  }

  await logCall(admin, {
    user_id: userId,
    kind: 'plan_gen',
    provider: cfg.provider,
    model: cfg.model,
    input_tokens: generated.usage?.promptTokens,
    output_tokens: generated.usage?.completionTokens,
    system_prompt_hash: systemPromptHash,
    pack_id: pack.id,
    request_body: { body, prompt_preview: prompt.slice(0, 2000) },
    response_body: generated.object,
    latency_ms: Date.now() - startedAt,
    cost_usd: estimateCostUsd(
      cfg.provider,
      cfg.model,
      generated.usage?.promptTokens,
      generated.usage?.completionTokens,
    ),
  });

  return json({ plan_id: planRow.id });
});

function buildPrompt(body: RequestBody, pack: any, ctx: any): string {
  return [
    `User request:`,
    JSON.stringify(body, null, 2),
    ``,
    `Active knowledge pack (${pack.id} v${pack.version}):`,
    `Principles:\n${pack.principles_md}`,
    `Plan templates: ${JSON.stringify(pack.plan_templates)}`,
    `Rep range guidance: ${JSON.stringify(pack.rep_range_guidance)}`,
    `Rest guidance: ${JSON.stringify(pack.rest_guidance)}`,
    `Substitutions: ${JSON.stringify(pack.substitutions)}`,
    `Red flags: ${pack.red_flags_md}`,
    ``,
    `User context:`,
    `Recent sessions (last 30 days): ${ctx.sessionsCount}`,
    `Volume by muscle (trailing 30 days): ${JSON.stringify(ctx.volumeByMuscle)}`,
    ``,
    `Available exercises (use exercise_id exactly as listed — DO NOT invent new ones):`,
    ctx.exercises
      .map(
        (e: any) =>
          `- ${e.id} :: ${e.name} [${e.primary_muscle}, ${e.equipment}${e.is_unilateral ? ', unilateral' : ''}]`,
      )
      .join('\n'),
    ``,
    `Generate a training plan that matches the schema.`,
  ].join('\n');
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'content-type': 'application/json', ...CORS_HEADERS },
  });
}

async function hash(s: string): Promise<string> {
  const buf = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(s));
  return Array.from(new Uint8Array(buf))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

async function logCall(
  client: SupabaseClient,
  row: Record<string, unknown>,
): Promise<void> {
  await client.from('ai_calls').insert(row);
}
