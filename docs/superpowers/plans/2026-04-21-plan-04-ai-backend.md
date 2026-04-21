# Plan 04: AI Backend — Knowledge Pack + Plan Generation — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stand up the server-side AI pipeline: author the `hypertrophy-v1` knowledge pack, write the `generate-plan` Supabase Edge Function using Vercel AI SDK with Gemini as the default provider, enforce structured JSON output via Zod, validate exercise IDs against the caller's visible library, and transactionally insert plans + plan_days + plan_prescriptions.

**Architecture:** Edge Functions run Deno. Vercel AI SDK is imported via esm.sh. A singleton `ai_config` row holds provider + model + system prompt override + temperature. Each request: load config → load pack by goal → build user context (Q&A + recent training) → `generateObject` with Zod schema → validate exercise IDs → insert rows → log to `ai_calls`.

**Tech Stack:** Supabase Edge Functions (Deno) · Vercel AI SDK (`ai`, `@ai-sdk/google`, `@ai-sdk/anthropic`, `@ai-sdk/openai`) · Zod · Supabase service-role client (for bypassing RLS during server-side inserts)

**Spec reference:** `docs/superpowers/specs/2026-04-21-gimma-gym-app-design.md` — §6 AI brain design, §13 Testing.

**Depends on:** Plans 01 (schema), 02 (seed exercises), 03 (plan persistence locally).

---

## Manual external setup

**M1 — Google AI Studio API key for Gemini.** Get key at https://aistudio.google.com/apikey. Store in Supabase:

```bash
supabase secrets set GOOGLE_GENERATIVE_AI_API_KEY=...
```

**M2 — (Optional) Anthropic and OpenAI keys for fallback providers.**

```bash
supabase secrets set ANTHROPIC_API_KEY=...
supabase secrets set OPENAI_API_KEY=...
```

**M3 — Supabase service-role key** is already present in `supabase secrets list` after `supabase start`. Used server-side for RLS-bypassing inserts.

---

## File structure produced by this plan

```
supabase/functions/
├── _shared/
│   ├── ai_providers.ts         # maps provider string → AI SDK model
│   ├── load_ai_config.ts
│   ├── load_pack.ts
│   ├── build_context.ts
│   ├── plan_schema.ts          # Zod schema for plan JSON
│   └── system_prompt.ts
├── generate-plan/
│   └── index.ts
└── import_map.json

supabase/packs/
├── hypertrophy-v1/
│   ├── pack.yaml
│   ├── principles.md
│   ├── plan_templates.json
│   ├── rep_range_guidance.json
│   ├── rest_guidance.json
│   ├── substitutions.json
│   └── red_flags.md

supabase/migrations/
└── 20260421000009_seed_packs.sql

supabase/scripts/
└── seed_packs.ts               # reads packs/ folders → inserts rows

apps/mobile/lib/features/plans/data/
└── plan_api.dart                # client calling generate-plan
```

---

## Task 1 — Import map for edge functions

**Files:**
- Create: `supabase/functions/import_map.json`

- [ ] **Step 1:** Write the import map.

```json
{
  "imports": {
    "ai": "https://esm.sh/ai@4.0.0?deps=zod@3.23.0",
    "@ai-sdk/google": "https://esm.sh/@ai-sdk/google@1.0.0?deps=ai@4.0.0,zod@3.23.0",
    "@ai-sdk/anthropic": "https://esm.sh/@ai-sdk/anthropic@1.0.0?deps=ai@4.0.0,zod@3.23.0",
    "@ai-sdk/openai": "https://esm.sh/@ai-sdk/openai@1.0.0?deps=ai@4.0.0,zod@3.23.0",
    "zod": "https://esm.sh/zod@3.23.0",
    "@supabase/supabase-js": "https://esm.sh/@supabase/supabase-js@2"
  }
}
```

- [ ] **Step 2:** Configure Supabase to use it.

Edit `supabase/config.toml` — under `[edge_runtime]` (create if missing):

```toml
[edge_runtime]
import_map = "./functions/import_map.json"
```

- [ ] **Step 3:** Commit.

```bash
git add supabase/functions/import_map.json supabase/config.toml
git commit -m "feat(functions): import map for Vercel AI SDK + Supabase"
```

---

## Task 2 — AI provider adapter

**Files:**
- Create: `supabase/functions/_shared/ai_providers.ts`

- [ ] **Step 1:** Write the adapter.

```ts
import { google } from '@ai-sdk/google';
import { anthropic } from '@ai-sdk/anthropic';
import { openai } from '@ai-sdk/openai';
import type { LanguageModel } from 'ai';

export type Provider = 'google' | 'anthropic' | 'openai';

export function resolveModel(provider: Provider, model: string): LanguageModel {
  switch (provider) {
    case 'google':
      return google(model);
    case 'anthropic':
      return anthropic(model);
    case 'openai':
      return openai(model);
    default: {
      const exhaustive: never = provider;
      throw new Error(`Unknown provider: ${exhaustive}`);
    }
  }
}
```

- [ ] **Step 2:** Commit.

```bash
git add supabase/functions/_shared/ai_providers.ts
git commit -m "feat(functions): AI provider adapter for Gemini/Claude/OpenAI"
```

---

## Task 3 — Author `hypertrophy-v1` pack content

**Files:**
- Create: `supabase/packs/hypertrophy-v1/pack.yaml`
- Create: `supabase/packs/hypertrophy-v1/principles.md`
- Create: `supabase/packs/hypertrophy-v1/plan_templates.json`
- Create: `supabase/packs/hypertrophy-v1/rep_range_guidance.json`
- Create: `supabase/packs/hypertrophy-v1/rest_guidance.json`
- Create: `supabase/packs/hypertrophy-v1/substitutions.json`
- Create: `supabase/packs/hypertrophy-v1/red_flags.md`

- [ ] **Step 1:** `pack.yaml`:

```yaml
id: hypertrophy-v1
name: Hypertrophy-focused training
version: 1.0.0
goal: muscle
recommended_splits: [full_body, upper_lower, ppl]
```

- [ ] **Step 2:** `principles.md`:

```markdown
# Hypertrophy principles

- **Progressive overload is the driver.** Increase weight or reps vs the
  previous session whenever set targets are met at the prescribed RIR.
- **Volume is king.** Target 10–20 hard sets per muscle per week for most
  intermediates. Beginners can progress on less; advanced often need more.
- **Rep range 6–15 is optimal for hypertrophy.** Compounds lean to the low
  end (6–10); isolations to the high end (10–15).
- **RIR 0–3 across working sets.** Most sets should be 1–3 reps from failure.
  Push final sets to RIR 0 on isolations only.
- **Prioritize compounds early, isolations late.** Heaviest work first when
  fresh; focus-pump work at the end.
- **Rest 2–3 min for compounds, 60–90s for isolations.**
- **Frequency matters.** Each muscle group trained 2x/week beats 1x/week at
  matched volume.
- **Deload every 4–6 weeks** OR when two or more exercises stall
  simultaneously. A deload is 50% volume at the same intensity.
- **Sleep, stress, and protein (1.6–2.2 g/kg/day) are non-negotiable.**
- **Do not prescribe plans that:** exceed 6 days/week; place the same muscle
  in consecutive days without a clear reason; prescribe < 5 total sets/week
  for a trained muscle; use rep ranges below 5 or above 20 for hypertrophy
  goals.
```

- [ ] **Step 3:** `plan_templates.json`:

```json
[
  {
    "split": "full_body",
    "days_per_week": 3,
    "structure": [
      {
        "day": "Full Body A",
        "focus": "compound lifts",
        "movements": ["squat_pattern", "horizontal_push", "horizontal_pull", "core", "biceps", "triceps"]
      },
      {
        "day": "Full Body B",
        "focus": "compound lifts",
        "movements": ["hinge_pattern", "vertical_push", "vertical_pull", "lunge", "calves"]
      },
      {
        "day": "Full Body C",
        "focus": "moderate intensity",
        "movements": ["squat_pattern", "horizontal_push", "vertical_pull", "rear_delts", "forearms"]
      }
    ]
  },
  {
    "split": "upper_lower",
    "days_per_week": 4,
    "structure": [
      {
        "day": "Upper A",
        "focus": "heavy push",
        "movements": ["horizontal_push", "vertical_pull", "horizontal_pull", "vertical_push", "biceps", "triceps"]
      },
      {
        "day": "Lower A",
        "focus": "heavy lower",
        "movements": ["squat_pattern", "hinge_pattern", "lunge", "calves", "core"]
      },
      {
        "day": "Upper B",
        "focus": "volume push",
        "movements": ["vertical_push", "horizontal_pull", "horizontal_push", "vertical_pull", "rear_delts", "arms"]
      },
      {
        "day": "Lower B",
        "focus": "volume lower + posterior",
        "movements": ["hinge_pattern", "squat_pattern", "hamstrings", "calves", "glutes"]
      }
    ]
  },
  {
    "split": "ppl",
    "days_per_week": 6,
    "structure": [
      {
        "day": "Push A",
        "movements": ["horizontal_push", "vertical_push", "side_delts", "triceps", "triceps_isolation"]
      },
      {
        "day": "Pull A",
        "movements": ["vertical_pull", "horizontal_pull", "rear_delts", "biceps", "forearms"]
      },
      {
        "day": "Legs A",
        "movements": ["squat_pattern", "hinge_pattern", "quads_isolation", "hamstrings", "calves"]
      },
      {
        "day": "Push B",
        "movements": ["vertical_push", "horizontal_push_isolation", "chest_isolation", "side_delts", "triceps"]
      },
      {
        "day": "Pull B",
        "movements": ["horizontal_pull", "vertical_pull", "lats_isolation", "rear_delts", "biceps"]
      },
      {
        "day": "Legs B",
        "movements": ["hinge_pattern", "lunge", "quads_isolation", "glutes", "calves"]
      }
    ]
  }
]
```

- [ ] **Step 4:** `rep_range_guidance.json`:

```json
{
  "compound": { "reps_min": 5, "reps_max": 10, "rir_min": 1, "rir_max": 3 },
  "isolation": { "reps_min": 8, "reps_max": 15, "rir_min": 0, "rir_max": 2 },
  "core": { "reps_min": 10, "reps_max": 20, "rir_min": 0, "rir_max": 3 }
}
```

- [ ] **Step 5:** `rest_guidance.json`:

```json
{
  "compound": 180,
  "isolation": 90,
  "core": 60
}
```

- [ ] **Step 6:** `substitutions.json`:

```json
[
  { "when": "no_barbell", "avoid": ["barbell"], "prefer": ["dumbbell", "machine"] },
  { "when": "knee_pain", "avoid_exercises": ["barbell back squat", "walking lunge", "pistol squat"], "prefer_exercises": ["leg press", "goblet squat", "split squat"] },
  { "when": "lower_back_pain", "avoid_exercises": ["barbell deadlift", "good morning", "bent-over row"], "prefer_exercises": ["romanian deadlift", "trap bar deadlift", "seated row"] },
  { "when": "shoulder_pain", "avoid_exercises": ["barbell overhead press", "behind-the-neck press", "upright row"], "prefer_exercises": ["dumbbell overhead press", "lateral raise", "landmine press"] }
]
```

- [ ] **Step 7:** `red_flags.md`:

```markdown
# Red flags

If the user reports any of the following, the AI should:
1. Acknowledge the concern.
2. Suggest seeing a qualified professional (physio, physician).
3. Still generate a conservative plan avoiding the flagged area.
4. Never diagnose or treat.

## Signs to flag

- Sharp joint pain during movement
- Radiating nerve pain (numbness, tingling down a limb)
- Pain that worsens with rest
- Chest pain during exertion
- Dizziness or severe shortness of breath
- Pain described as "stabbing" rather than muscular soreness
```

- [ ] **Step 8:** Commit.

```bash
git add supabase/packs/hypertrophy-v1
git commit -m "content: hypertrophy-v1 knowledge pack"
```

---

## Task 4 — Seed script for packs

**Files:**
- Create: `supabase/scripts/seed_packs.ts`
- Create: `supabase/migrations/20260421000009_seed_packs.sql`

- [ ] **Step 1:** Write the script.

```ts
// Usage: deno run -A supabase/scripts/seed_packs.ts [--emit-sql]
import { parse as parseYaml } from 'https://deno.land/std@0.224.0/yaml/mod.ts';

const packsDir = new URL('../packs/', import.meta.url);
const entries = [];
for await (const d of Deno.readDir(packsDir)) {
  if (!d.isDirectory) continue;
  const dir = new URL(`../packs/${d.name}/`, import.meta.url);
  const meta = parseYaml(await Deno.readTextFile(new URL('pack.yaml', dir))) as Record<string, unknown>;
  const principles_md = await Deno.readTextFile(new URL('principles.md', dir));
  const red_flags_md = await Deno.readTextFile(new URL('red_flags.md', dir));
  const plan_templates = JSON.parse(await Deno.readTextFile(new URL('plan_templates.json', dir)));
  const rep_range_guidance = JSON.parse(await Deno.readTextFile(new URL('rep_range_guidance.json', dir)));
  const rest_guidance = JSON.parse(await Deno.readTextFile(new URL('rest_guidance.json', dir)));
  const substitutions = JSON.parse(await Deno.readTextFile(new URL('substitutions.json', dir)));

  entries.push({
    id: meta.id as string,
    name: meta.name as string,
    version: meta.version as string,
    goal: meta.goal as string,
    principles_md,
    plan_templates,
    rep_range_guidance,
    rest_guidance,
    substitutions,
    red_flags_md,
    is_active: true,
  });
}

function sqlEscape(s: string): string {
  return s.replaceAll("'", "''");
}

function emitSql(rows: typeof entries): string {
  const values = rows.map((r) => {
    return `('${r.id}', '${sqlEscape(r.name)}', '${r.version}', '${r.goal}', '${sqlEscape(r.principles_md)}', '${sqlEscape(JSON.stringify(r.plan_templates))}'::jsonb, '${sqlEscape(JSON.stringify(r.rep_range_guidance))}'::jsonb, '${sqlEscape(JSON.stringify(r.rest_guidance))}'::jsonb, '${sqlEscape(JSON.stringify(r.substitutions))}'::jsonb, '${sqlEscape(r.red_flags_md)}', ${r.is_active})`;
  }).join(',\n  ');
  return [
    'insert into public.knowledge_packs',
    '(id, name, version, goal, principles_md, plan_templates, rep_range_guidance, rest_guidance, substitutions, red_flags_md, is_active)',
    'values',
    `  ${values}`,
    'on conflict (id) do update set',
    '  name = excluded.name, version = excluded.version, goal = excluded.goal,',
    '  principles_md = excluded.principles_md, plan_templates = excluded.plan_templates,',
    '  rep_range_guidance = excluded.rep_range_guidance, rest_guidance = excluded.rest_guidance,',
    '  substitutions = excluded.substitutions, red_flags_md = excluded.red_flags_md,',
    '  is_active = excluded.is_active;',
  ].join('\n');
}

if (Deno.args.includes('--emit-sql')) {
  console.log(emitSql(entries));
}
```

- [ ] **Step 2:** Generate the migration.

```bash
deno run -A supabase/scripts/seed_packs.ts --emit-sql \
  > supabase/migrations/20260421000009_seed_packs.sql
```

- [ ] **Step 3:** Apply + verify.

```bash
supabase db reset
supabase db execute "select id, name, is_active from public.knowledge_packs;"
```

Expected: `hypertrophy-v1 | Hypertrophy-focused training | t`.

- [ ] **Step 4:** Commit.

```bash
git add supabase/scripts/seed_packs.ts supabase/migrations/20260421000009_seed_packs.sql
git commit -m "feat(db): seed knowledge_packs from supabase/packs/"
```

---

## Task 5 — System prompt file

**Files:**
- Create: `supabase/functions/_shared/system_prompt.ts`

- [ ] **Step 1:** Write the system prompt.

```ts
export const DEFAULT_SYSTEM_PROMPT = `
You are Gimma, an evidence-based personal trainer speaking through an app.

Your job: generate training plans that honor:
  - the user's stated goal and preferences
  - the principles of the active knowledge pack (the "textbook")
  - the user's existing exercise library (only use exercise_ids from the
    provided list — do NOT invent new exercises)
  - the user's recent training patterns when provided

Your output is ALWAYS structured JSON matching the provided schema. No
prose outside the structured response.

Rules:
  - Be honest and direct. Do not hedge for politeness.
  - If the user reports pain or injury, recommend they see a professional
    AND still produce a conservative plan avoiding the flagged area.
  - You are not a medical authority. You do not diagnose.
  - Do not prescribe plans that violate the pack's principles.
  - Each plan_day should have a clear focus. Name it something the user
    will recognize ("Push A", "Upper A", "Full Body B").
  - Use UUIDs from the provided exercise list exactly as given.
`.trim();
```

- [ ] **Step 2:** Commit.

```bash
git add supabase/functions/_shared/system_prompt.ts
git commit -m "feat(functions): default system prompt for Gimma trainer role"
```

---

## Task 6 — Plan output Zod schema

**Files:**
- Create: `supabase/functions/_shared/plan_schema.ts`

- [ ] **Step 1:** Write the schema.

```ts
import { z } from 'zod';

export const PlanSchema = z.object({
  name: z.string().min(3).max(100),
  split_type: z.enum(['full_body', 'upper_lower', 'ppl', 'custom']),
  days_per_week: z.number().int().min(2).max(6),
  reasoning: z.string().min(50).max(2000),
  days: z
    .array(
      z.object({
        day_number: z.number().int().min(1).max(7),
        name: z.string().min(2).max(60),
        focus: z.string().min(2).max(100),
        prescriptions: z
          .array(
            z.object({
              exercise_id: z.string().uuid(),
              order: z.number().int().min(1).max(20),
              target_sets: z.number().int().min(1).max(10),
              target_reps_min: z.number().int().min(1).max(30),
              target_reps_max: z.number().int().min(1).max(30),
              target_rir: z.number().int().min(0).max(5),
              target_rest_seconds: z.number().int().min(30).max(600),
              notes: z.string().max(500).optional(),
            }),
          )
          .min(1)
          .max(15),
      }),
    )
    .min(2)
    .max(7),
});

export type GeneratedPlan = z.infer<typeof PlanSchema>;
```

- [ ] **Step 2:** Commit.

```bash
git add supabase/functions/_shared/plan_schema.ts
git commit -m "feat(functions): Zod schema for AI plan output"
```

---

## Task 7 — Config + pack + context loaders

**Files:**
- Create: `supabase/functions/_shared/load_ai_config.ts`
- Create: `supabase/functions/_shared/load_pack.ts`
- Create: `supabase/functions/_shared/build_context.ts`

- [ ] **Step 1:** `load_ai_config.ts`:

```ts
import type { SupabaseClient } from '@supabase/supabase-js';
import { DEFAULT_SYSTEM_PROMPT } from './system_prompt.ts';

export async function loadAiConfig(client: SupabaseClient) {
  const { data, error } = await client
    .from('ai_config')
    .select('*')
    .eq('id', 'active')
    .single();
  if (error) throw error;
  return {
    provider: data.active_provider as 'google' | 'anthropic' | 'openai',
    model: data.active_model as string,
    systemPrompt: (data.system_prompt_override as string | null) ?? DEFAULT_SYSTEM_PROMPT,
    temperature: data.temperature as number,
    maxTokens: data.max_tokens as number,
  };
}
```

- [ ] **Step 2:** `load_pack.ts`:

```ts
import type { SupabaseClient } from '@supabase/supabase-js';

export async function loadPack(client: SupabaseClient, goal: string) {
  const { data } = await client
    .from('knowledge_packs')
    .select('*')
    .eq('goal', goal)
    .eq('is_active', true)
    .order('version', { ascending: false })
    .limit(1);
  if (!data || data.length === 0) {
    // Fallback: hypertrophy-v1.
    const { data: fallback, error } = await client
      .from('knowledge_packs')
      .select('*')
      .eq('id', 'hypertrophy-v1')
      .single();
    if (error) throw error;
    return fallback;
  }
  return data[0];
}
```

- [ ] **Step 3:** `build_context.ts`:

```ts
import type { SupabaseClient } from '@supabase/supabase-js';

export async function buildUserContext(client: SupabaseClient, userId: string) {
  const since = new Date(Date.now() - 30 * 86400_000).toISOString();
  const { data: recentSessions } = await client
    .from('sessions')
    .select('id, started_at, plan_day_id')
    .eq('user_id', userId)
    .gte('started_at', since);

  const { data: exercises } = await client
    .from('exercises')
    .select('id, name, primary_muscle, secondary_muscles, equipment, is_unilateral')
    .or(`owner_user_id.eq.${userId},owner_user_id.is.null`)
    .eq('is_archived', false);

  // Volume per muscle (trailing 30 days).
  const sessionIds = (recentSessions ?? []).map((s) => s.id);
  let volumeByMuscle: Record<string, number> = {};
  if (sessionIds.length > 0) {
    const { data: sets } = await client
      .from('sets')
      .select('session_exercise_id, session_exercises!inner(exercise_id, session_id), session_exercises.exercises!inner(primary_muscle)')
      .in('session_exercises.session_id', sessionIds);
    // Supabase nested select returns nested objects. Reduce to counts.
    volumeByMuscle = (sets ?? []).reduce<Record<string, number>>((acc, row: any) => {
      const muscle = row.session_exercises?.exercises?.primary_muscle as string | undefined;
      if (muscle) acc[muscle] = (acc[muscle] ?? 0) + 1;
      return acc;
    }, {});
  }

  return {
    sessionsCount: recentSessions?.length ?? 0,
    volumeByMuscle,
    exercises: exercises ?? [],
  };
}
```

- [ ] **Step 4:** Commit.

```bash
git add supabase/functions/_shared
git commit -m "feat(functions): ai config, pack, and user context loaders"
```

---

## Task 8 — `generate-plan` edge function

**Files:**
- Create: `supabase/functions/generate-plan/index.ts`

- [ ] **Step 1:** Write the function.

```ts
// deno-lint-ignore-file no-explicit-any
import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from '@supabase/supabase-js';
import { generateObject } from 'ai';
import { PlanSchema } from '../_shared/plan_schema.ts';
import { resolveModel } from '../_shared/ai_providers.ts';
import { loadAiConfig } from '../_shared/load_ai_config.ts';
import { loadPack } from '../_shared/load_pack.ts';
import { buildUserContext } from '../_shared/build_context.ts';

interface RequestBody {
  goal: string;
  experience_level: string;
  days_per_week: number;
  session_length_minutes: number;
  equipment: string;
  injuries: string[];
  style_notes?: string;
}

serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 });
  }

  const userJwt = req.headers.get('authorization')?.replace('Bearer ', '');
  if (!userJwt) return new Response('Missing auth', { status: 401 });

  const userClient = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!,
    { global: { headers: { Authorization: `Bearer ${userJwt}` } } },
  );
  const adminClient = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  );

  const { data: auth } = await userClient.auth.getUser();
  if (!auth.user) return new Response('Unauthorized', { status: 401 });
  const userId = auth.user.id;

  const body = (await req.json()) as RequestBody;

  const cfg = await loadAiConfig(adminClient);
  const pack = await loadPack(adminClient, body.goal);
  const ctx = await buildUserContext(userClient, userId);

  if (ctx.exercises.length === 0) {
    return new Response(JSON.stringify({ error: 'No exercises available' }), { status: 400 });
  }

  const prompt = [
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
    ctx.exercises.map((e: any) => `- ${e.id} :: ${e.name} [${e.primary_muscle}, ${e.equipment}${e.is_unilateral ? ', unilateral' : ''}]`).join('\n'),
    ``,
    `Generate a training plan that matches the schema.`,
  ].join('\n');

  const model = resolveModel(cfg.provider, cfg.model);
  const systemPromptHash = await hash(cfg.systemPrompt);

  const startedAt = Date.now();
  let generated: any;
  try {
    const { object, usage } = await generateObject({
      model,
      system: cfg.systemPrompt,
      prompt,
      schema: PlanSchema,
      temperature: cfg.temperature,
      maxTokens: cfg.maxTokens,
    });
    generated = { object, usage };
  } catch (e) {
    await logAiCall(adminClient, {
      user_id: userId, kind: 'plan_gen',
      provider: cfg.provider, model: cfg.model,
      system_prompt_hash: systemPromptHash, pack_id: pack.id,
      request_body: { body, prompt_preview: prompt.slice(0, 2000) },
      response_body: null,
      error: (e as Error).message,
      latency_ms: Date.now() - startedAt,
    });
    return new Response(JSON.stringify({ error: (e as Error).message }), { status: 500 });
  }

  // Validate: every exercise_id in the plan must exist in the user's visible library.
  const visibleIds = new Set(ctx.exercises.map((e: any) => e.id as string));
  for (const day of generated.object.days) {
    for (const px of day.prescriptions) {
      if (!visibleIds.has(px.exercise_id)) {
        return new Response(
          JSON.stringify({ error: `AI referenced unknown exercise_id ${px.exercise_id}` }),
          { status: 422 },
        );
      }
    }
  }

  // Transactional insert.
  const { data: planRows, error: planErr } = await adminClient.from('plans').insert({
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
  }).select().single();
  if (planErr) {
    // Handle "only one active" constraint: deactivate old plan first.
    if (planErr.code === '23505') {
      await adminClient.from('plans').update({
        is_active: false,
        ended_at: new Date().toISOString(),
      }).eq('user_id', userId).eq('is_active', true);
      // retry once
      const retry = await adminClient.from('plans').insert({
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
      }).select().single();
      if (retry.error) return new Response(retry.error.message, { status: 500 });
      (planRows as any) = retry.data;
    } else {
      return new Response(planErr.message, { status: 500 });
    }
  }

  for (const day of generated.object.days) {
    const { data: dayRow } = await adminClient.from('plan_days').insert({
      plan_id: planRows!.id,
      day_number: day.day_number,
      name: day.name,
      focus: day.focus,
    }).select().single();

    for (const px of day.prescriptions) {
      await adminClient.from('plan_prescriptions').insert({
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

  await logAiCall(adminClient, {
    user_id: userId, kind: 'plan_gen',
    provider: cfg.provider, model: cfg.model,
    input_tokens: generated.usage?.promptTokens,
    output_tokens: generated.usage?.completionTokens,
    system_prompt_hash: systemPromptHash, pack_id: pack.id,
    request_body: { body, prompt_preview: prompt.slice(0, 2000) },
    response_body: generated.object,
    latency_ms: Date.now() - startedAt,
  });

  return new Response(JSON.stringify({ plan_id: planRows!.id }), {
    headers: { 'content-type': 'application/json' },
  });
});

async function hash(s: string): Promise<string> {
  const buf = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(s));
  return Array.from(new Uint8Array(buf)).map((b) => b.toString(16).padStart(2, '0')).join('');
}

async function logAiCall(client: any, row: Record<string, unknown>) {
  await client.from('ai_calls').insert(row);
}
```

- [ ] **Step 2:** Commit.

```bash
git add supabase/functions/generate-plan
git commit -m "feat(functions): generate-plan edge function"
```

---

## Task 9 — Deploy + smoke test

- [ ] **Step 1:** Deploy locally.

```bash
supabase functions serve --env-file <(echo 'GOOGLE_GENERATIVE_AI_API_KEY='$GOOGLE_GENERATIVE_AI_API_KEY)
```

- [ ] **Step 2:** Call it from curl with a valid user JWT (grab one from the Flutter app's debug screen, to be added in Plan 7; for now, sign in and extract the access token from Supabase Studio's auth.sessions).

```bash
curl -X POST http://127.0.0.1:54321/functions/v1/generate-plan \
  -H "Authorization: Bearer $USER_JWT" \
  -H "Content-Type: application/json" \
  -d '{
    "goal": "muscle",
    "experience_level": "intermediate",
    "days_per_week": 4,
    "session_length_minutes": 60,
    "equipment": "full gym",
    "injuries": []
  }'
```

Expected: `{"plan_id":"..."}` in a few seconds. Verify in Studio that `plans`, `plan_days`, `plan_prescriptions` rows exist and `ai_calls` has a log entry.

- [ ] **Step 3:** No commit — this is a local-only verification.

---

## Task 10 — Flutter client: call `generate-plan`

**Files:**
- Create: `apps/mobile/lib/features/plans/data/plan_api.dart`

- [ ] **Step 1:** Write the client.

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class PlanApi {
  PlanApi(this._client);
  final SupabaseClient _client;

  Future<String> generatePlan({
    required String goal,
    required String experienceLevel,
    required int daysPerWeek,
    required int sessionLengthMinutes,
    required String equipment,
    required List<String> injuries,
    String? styleNotes,
  }) async {
    final res = await _client.functions.invoke('generate-plan', body: {
      'goal': goal,
      'experience_level': experienceLevel,
      'days_per_week': daysPerWeek,
      'session_length_minutes': sessionLengthMinutes,
      'equipment': equipment,
      'injuries': injuries,
      if (styleNotes != null) 'style_notes': styleNotes,
    });
    if (res.status >= 400) {
      throw Exception('generate-plan failed: ${res.data}');
    }
    final data = res.data as Map<String, dynamic>;
    return data['plan_id'] as String;
  }
}
```

- [ ] **Step 2:** Commit.

```bash
git add apps/mobile/lib/features/plans/data/plan_api.dart
git commit -m "feat(plans): Flutter client for generate-plan edge function"
```

---

## Plan 4 Definition of Done

- [ ] `hypertrophy-v1` knowledge pack authored and seeded into DB
- [ ] `generate-plan` edge function deployed and callable
- [ ] Calling with a valid user token returns a plan_id; plan rows exist
- [ ] `ai_calls` row is written per call with tokens, cost (populate later), latency
- [ ] AI output passes Zod validation OR the function returns 500 cleanly
- [ ] Unknown `exercise_id` in AI output → 422 error (not a crash)
- [ ] Previous active plan is deactivated when a new one is generated
- [ ] Flutter `PlanApi` client exists and can be called (tested in Plan 5 onboarding)

---

## Deferred

- **Cost tracking in `ai_calls`**: currently null. Add a pricing table and populate after each call in Plan 8 polish.
- **Retry with fallback provider on failure** — single-provider call only for v1.
- **Streaming plan output** — uses `generateObject` (non-streaming). Streaming is a v1.5 UX win.
- **Prompt caching** (Gemini supports it). Not needed at low volume.
