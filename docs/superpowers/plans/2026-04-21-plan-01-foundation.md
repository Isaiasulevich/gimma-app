# Plan 01: Foundation — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stand up the monorepo, Supabase backend (schema + RLS + seed exercise data), and a Flutter app skeleton with working email + Google sign-in that lands on a signed-in home screen.

**Architecture:** Monorepo with `apps/mobile` (Flutter) and `apps/admin` (reserved for Plan 7). Supabase project under `supabase/` drives schema via migration files. Flutter uses `supabase_flutter`, `go_router`, `flutter_riverpod`, `google_sign_in`, `flutter_dotenv`. Auth logic lives behind a repository so it's unit-testable without hitting Supabase.

**Tech Stack:** Flutter (Dart) · Supabase CLI + Postgres · go_router · flutter_riverpod · supabase_flutter · google_sign_in · flutter_dotenv · mocktail (tests) · GitHub Actions

**Spec reference:** `docs/superpowers/specs/2026-04-21-gimma-gym-app-design.md` — §4 Architecture, §5 Data Model, §11 Tech Stack.

---

## File structure produced by this plan

```
gimma-app/
├── apps/
│   └── mobile/                        # Flutter app (created here)
│       ├── lib/
│       │   ├── main.dart
│       │   ├── app.dart
│       │   ├── config/
│       │   │   ├── env.dart
│       │   │   └── supabase_bootstrap.dart
│       │   ├── core/
│       │   │   ├── routing/app_router.dart
│       │   │   └── theme/app_theme.dart
│       │   └── features/
│       │       ├── auth/
│       │       │   ├── data/auth_repository.dart
│       │       │   └── presentation/
│       │       │       ├── auth_controller.dart
│       │       │       └── sign_in_screen.dart
│       │       └── home/presentation/home_screen.dart
│       ├── test/
│       │   ├── features/auth/
│       │   │   ├── auth_repository_test.dart
│       │   │   └── sign_in_screen_test.dart
│       │   └── features/home/home_screen_test.dart
│       ├── pubspec.yaml
│       └── analysis_options.yaml
├── supabase/
│   ├── config.toml
│   ├── migrations/
│   │   ├── 20260421000001_identity.sql
│   │   ├── 20260421000002_library.sql
│   │   ├── 20260421000003_planning.sql
│   │   ├── 20260421000004_execution.sql
│   │   ├── 20260421000005_ai_ops.sql
│   │   ├── 20260421000006_rls.sql
│   │   └── 20260421000007_seed_exercises.sql
│   ├── seed_data/
│   │   └── exercises.json             # yuhonas data, transformed
│   └── scripts/
│       └── transform_exercises.ts     # one-time transform
├── .github/workflows/ci.yaml
├── .env.example
└── README.md
```

---

## Manual external setup (not codable — reference section)

These three things require you (human) to click through external consoles. Do them **before** Task 13 (Google sign-in). Document as you go in a local file — don't commit credentials.

**M1 — Supabase hosted project**

1. `supabase.com` → New project → pick region + strong DB password.
2. Copy `SUPABASE_URL` and `SUPABASE_ANON_KEY` from Project Settings → API.
3. Under Auth → Providers → Google: enable, leave Client ID blank for now (fill in M2).

**M2 — Google OAuth client for Sign-in-with-Google**

1. `console.cloud.google.com` → New project → OAuth consent screen → External, Testing mode.
2. Credentials → Create OAuth client ID → **Web application** (for Supabase to use):
   - Authorized redirect URIs: `https://<project-ref>.supabase.co/auth/v1/callback`
   - Copy web Client ID + Secret → paste into Supabase Auth → Providers → Google.
3. Credentials → Create OAuth client ID → **iOS**:
   - Bundle ID: `com.gimma.app` (match Flutter iOS bundle)
   - Copy iOS Client ID (no secret).
4. Credentials → Create OAuth client ID → **Android**:
   - Package name: `com.gimma.app`
   - SHA-1: run `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android` for dev key.

**M3 — Supabase CLI installed locally**

```bash
brew install supabase/tap/supabase
supabase --version   # expect >= 1.170.0
```

---

## Task 1 — Initialize monorepo structure

**Files:**
- Create: `apps/.gitkeep`
- Create: `docs/design/.gitkeep`
- Modify: `README.md`

- [ ] **Step 1:** Create the directory scaffolding.

```bash
mkdir -p apps docs/design
touch apps/.gitkeep docs/design/.gitkeep
```

- [ ] **Step 2:** Replace the (non-existent) README with a short project overview.

Write `README.md`:

```markdown
# Gimma

AI-powered gym app — personal-first, publishable-later.

## Repo layout

- `apps/mobile/` — Flutter app (iOS + Android)
- `apps/admin/` — Next.js admin (added in Plan 7)
- `supabase/` — database schema, RLS, edge functions, seed data
- `docs/` — specs, plans, design system

## Spec and plans

- Spec: [`docs/superpowers/specs/2026-04-21-gimma-gym-app-design.md`](docs/superpowers/specs/2026-04-21-gimma-gym-app-design.md)
- Plans: `docs/superpowers/plans/`

## Setup

See [`docs/setup.md`](docs/setup.md) (TBD in Plan 1).
```

- [ ] **Step 3:** Commit.

```bash
git add apps/.gitkeep docs/design/.gitkeep README.md
git commit -m "chore: initialize monorepo structure"
```

---

## Task 2 — Supabase local dev setup

**Files:**
- Create: `supabase/config.toml` (via `supabase init`)
- Modify: `.gitignore`

- [ ] **Step 1:** Initialize Supabase at repo root.

```bash
supabase init
```

Accept the default VS Code settings prompt as you prefer. This creates `supabase/config.toml`.

- [ ] **Step 2:** Verify local Supabase starts. Requires Docker Desktop running.

```bash
supabase start
```

Expected output includes URLs like `API URL: http://127.0.0.1:54321`, `DB URL: postgresql://postgres:postgres@127.0.0.1:54322/postgres`, and an anon key. Copy these — you'll paste them into `.env` in Task 9.

- [ ] **Step 3:** Stop Supabase (we'll restart it later after writing migrations).

```bash
supabase stop
```

- [ ] **Step 4:** Ignore Supabase local files we don't want committed.

Append to `.gitignore`:

```
# Supabase local
supabase/.branches
supabase/.temp
```

- [ ] **Step 5:** Commit.

```bash
git add supabase/config.toml .gitignore
git commit -m "chore(supabase): initialize local project"
```

---

## Task 3 — Migration: identity domain (users table)

**Files:**
- Create: `supabase/migrations/20260421000001_identity.sql`

- [ ] **Step 1:** Create the migration file.

Write `supabase/migrations/20260421000001_identity.sql`:

```sql
-- Identity domain: extends auth.users with our profile data.

create type user_role as enum ('user', 'admin');
create type unit_system as enum ('metric', 'imperial');
create type experience_level as enum ('beginner', 'intermediate', 'advanced');
create type onboarding_mode as enum ('guided', 'observe');

create table public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  display_name text,
  role user_role not null default 'user',
  unit_system unit_system not null default 'metric',
  experience_level experience_level,
  goal text,
  onboarding_mode onboarding_mode,
  onboarding_completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Keep updated_at current.
create or replace function public.tg_set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger users_set_updated_at
  before update on public.users
  for each row execute function public.tg_set_updated_at();

-- When a new auth user is created, create a matching profile row.
create or replace function public.handle_new_auth_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.users (id, email, display_name)
  values (new.id, new.email, new.raw_user_meta_data->>'full_name');
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_auth_user();
```

- [ ] **Step 2:** Start Supabase, apply the migration, verify.

```bash
supabase start
supabase db reset   # applies all migrations from scratch
```

- [ ] **Step 3:** Verify schema.

```bash
supabase db execute "select table_name from information_schema.tables where table_schema='public';"
```

Expected output includes `users`.

- [ ] **Step 4:** Commit.

```bash
git add supabase/migrations/20260421000001_identity.sql
git commit -m "feat(db): identity domain — users table + auth trigger"
```

---

## Task 4 — Migration: library domain (exercises, knowledge_packs)

**Files:**
- Create: `supabase/migrations/20260421000002_library.sql`

- [ ] **Step 1:** Write the migration.

Write `supabase/migrations/20260421000002_library.sql`:

```sql
-- Library domain: exercises (seed + user) and knowledge packs.

create type exercise_source as enum ('seed', 'user');

create type muscle as enum (
  'chest','upper_back','lats','traps','lower_back',
  'front_delts','side_delts','rear_delts',
  'biceps','triceps','forearms',
  'quads','hamstrings','glutes','calves','adductors','abductors',
  'abs','obliques','neck','core'
);

create type equipment as enum (
  'barbell','dumbbell','machine','cable','bodyweight','band','kettlebell','other'
);

create table public.exercises (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid references public.users(id) on delete cascade,
  source exercise_source not null,
  source_ref text,
  name text not null,
  description text,
  photo_url text,
  primary_muscle muscle not null,
  secondary_muscles muscle[] not null default '{}',
  equipment equipment not null,
  is_unilateral boolean not null default false,
  is_archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger exercises_set_updated_at
  before update on public.exercises
  for each row execute function public.tg_set_updated_at();

create index exercises_owner_idx on public.exercises(owner_user_id);
create index exercises_primary_muscle_idx on public.exercises(primary_muscle);
create index exercises_source_idx on public.exercises(source);

create table public.knowledge_packs (
  id text primary key,
  name text not null,
  version text not null,
  goal text not null,
  principles_md text not null,
  plan_templates jsonb not null default '[]'::jsonb,
  rep_range_guidance jsonb not null default '{}'::jsonb,
  rest_guidance jsonb not null default '{}'::jsonb,
  substitutions jsonb not null default '[]'::jsonb,
  red_flags_md text not null default '',
  is_active boolean not null default false,
  updated_at timestamptz not null default now()
);

create trigger knowledge_packs_set_updated_at
  before update on public.knowledge_packs
  for each row execute function public.tg_set_updated_at();
```

- [ ] **Step 2:** Apply + verify.

```bash
supabase db reset
supabase db execute "select table_name from information_schema.tables where table_schema='public' and table_name in ('exercises','knowledge_packs');"
```

Expected: both rows returned.

- [ ] **Step 3:** Commit.

```bash
git add supabase/migrations/20260421000002_library.sql
git commit -m "feat(db): library domain — exercises + knowledge_packs"
```

---

## Task 5 — Migration: planning domain

**Files:**
- Create: `supabase/migrations/20260421000003_planning.sql`

- [ ] **Step 1:** Write the migration.

Write `supabase/migrations/20260421000003_planning.sql`:

```sql
-- Planning domain: plans, plan_days, plan_prescriptions.

create type split_type as enum ('full_body','upper_lower','ppl','custom');

create table public.plans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  name text not null,
  goal text not null,
  pack_id text references public.knowledge_packs(id),
  split_type split_type not null,
  days_per_week int not null check (days_per_week between 2 and 7),
  generated_by_ai boolean not null default false,
  ai_reasoning text,
  is_active boolean not null default false,
  started_at timestamptz,
  ended_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger plans_set_updated_at
  before update on public.plans
  for each row execute function public.tg_set_updated_at();

-- Only one active plan per user at a time.
create unique index plans_one_active_per_user
  on public.plans(user_id) where is_active = true;

create table public.plan_days (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid not null references public.plans(id) on delete cascade,
  day_number int not null check (day_number >= 1),
  name text not null,
  focus text not null,
  unique (plan_id, day_number)
);

create table public.plan_prescriptions (
  id uuid primary key default gen_random_uuid(),
  plan_day_id uuid not null references public.plan_days(id) on delete cascade,
  exercise_id uuid not null references public.exercises(id),
  "order" int not null check ("order" >= 1),
  target_sets int not null check (target_sets between 1 and 10),
  target_reps_min int not null check (target_reps_min >= 1),
  target_reps_max int not null check (target_reps_max >= target_reps_min),
  target_rir int not null check (target_rir between 0 and 5),
  target_rest_seconds int not null check (target_rest_seconds between 0 and 600),
  notes text,
  unique (plan_day_id, "order")
);

create index plan_prescriptions_plan_day_idx on public.plan_prescriptions(plan_day_id);
```

- [ ] **Step 2:** Apply + verify.

```bash
supabase db reset
supabase db execute "select table_name from information_schema.tables where table_schema='public' and table_name in ('plans','plan_days','plan_prescriptions');"
```

Expected: three rows.

- [ ] **Step 3:** Commit.

```bash
git add supabase/migrations/20260421000003_planning.sql
git commit -m "feat(db): planning domain — plans, plan_days, plan_prescriptions"
```

---

## Task 6 — Migration: execution domain

**Files:**
- Create: `supabase/migrations/20260421000004_execution.sql`

- [ ] **Step 1:** Write the migration.

Write `supabase/migrations/20260421000004_execution.sql`:

```sql
-- Execution domain: sessions, session_exercises, sets.

create type session_status as enum ('in_progress','completed','abandoned');
create type session_exercise_status as enum ('pending','in_progress','skipped','done');

create table public.sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  plan_day_id uuid references public.plan_days(id) on delete set null,
  started_at timestamptz not null,
  ended_at timestamptz,
  status session_status not null default 'in_progress',
  bodyweight numeric,
  heart_rate_avg int,
  heart_rate_max int,
  calories_est int,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger sessions_set_updated_at
  before update on public.sessions
  for each row execute function public.tg_set_updated_at();

create index sessions_user_idx on public.sessions(user_id, started_at desc);

create table public.session_exercises (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.sessions(id) on delete cascade,
  exercise_id uuid not null references public.exercises(id),
  "order" int not null check ("order" >= 1),
  status session_exercise_status not null default 'pending',
  skip_reason text,
  unique (session_id, "order")
);

create index session_exercises_session_idx on public.session_exercises(session_id);

create table public.sets (
  id uuid primary key default gen_random_uuid(),
  session_exercise_id uuid not null references public.session_exercises(id) on delete cascade,
  set_number int not null check (set_number >= 1),
  weight numeric,
  reps int not null check (reps >= 0),
  rir int check (rir between 0 and 10),
  rest_seconds int check (rest_seconds >= 0),
  tempo text,
  is_unilateral_left boolean,
  notes text,
  logged_at timestamptz not null default now(),
  unique (session_exercise_id, set_number)
);

create index sets_session_exercise_idx on public.sets(session_exercise_id);
```

- [ ] **Step 2:** Apply + verify.

```bash
supabase db reset
supabase db execute "select table_name from information_schema.tables where table_schema='public' and table_name in ('sessions','session_exercises','sets');"
```

Expected: three rows.

- [ ] **Step 3:** Commit.

```bash
git add supabase/migrations/20260421000004_execution.sql
git commit -m "feat(db): execution domain — sessions, session_exercises, sets"
```

---

## Task 7 — Migration: AI / ops domain

**Files:**
- Create: `supabase/migrations/20260421000005_ai_ops.sql`

- [ ] **Step 1:** Write the migration.

Write `supabase/migrations/20260421000005_ai_ops.sql`:

```sql
-- AI / ops domain: ai_config (singleton), ai_calls (log), weekly_summaries.

create type ai_provider as enum ('google','anthropic','openai');
create type ai_call_kind as enum ('plan_gen','weekly_summary','review_now','onboarding');

create table public.ai_config (
  id text primary key check (id = 'active'),
  active_provider ai_provider not null default 'google',
  active_model text not null default 'gemini-2.0-flash',
  system_prompt_override text,
  temperature numeric not null default 0.7 check (temperature between 0 and 2),
  max_tokens int not null default 4000 check (max_tokens between 100 and 32000),
  updated_by_user_id uuid references public.users(id),
  updated_at timestamptz not null default now()
);

create trigger ai_config_set_updated_at
  before update on public.ai_config
  for each row execute function public.tg_set_updated_at();

insert into public.ai_config (id) values ('active');

create table public.ai_calls (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.users(id) on delete set null,
  kind ai_call_kind not null,
  provider ai_provider not null,
  model text not null,
  input_tokens int,
  output_tokens int,
  cost_usd numeric,
  latency_ms int,
  system_prompt_hash text,
  pack_id text references public.knowledge_packs(id),
  request_body jsonb,
  response_body jsonb,
  error text,
  created_at timestamptz not null default now()
);

create index ai_calls_created_at_idx on public.ai_calls(created_at desc);
create index ai_calls_user_idx on public.ai_calls(user_id, created_at desc);

create table public.weekly_summaries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  week_start date not null,
  summary_md text not null,
  volume_by_muscle jsonb not null default '{}'::jsonb,
  frequency jsonb not null default '{}'::jsonb,
  stalls jsonb not null default '[]'::jsonb,
  prs jsonb not null default '[]'::jsonb,
  generated_at timestamptz not null default now(),
  unique (user_id, week_start)
);

create index weekly_summaries_user_idx on public.weekly_summaries(user_id, week_start desc);
```

- [ ] **Step 2:** Apply + verify.

```bash
supabase db reset
supabase db execute "select table_name from information_schema.tables where table_schema='public' and table_name in ('ai_config','ai_calls','weekly_summaries');"
```

Expected: three rows. Also confirm singleton:

```bash
supabase db execute "select id, active_provider, active_model from public.ai_config;"
```

Expected: `active | google | gemini-2.0-flash`.

- [ ] **Step 3:** Commit.

```bash
git add supabase/migrations/20260421000005_ai_ops.sql
git commit -m "feat(db): ai/ops domain — ai_config, ai_calls, weekly_summaries"
```

---

## Task 8 — RLS policies (all tables)

**Files:**
- Create: `supabase/migrations/20260421000006_rls.sql`

- [ ] **Step 1:** Write the RLS migration.

Write `supabase/migrations/20260421000006_rls.sql`:

```sql
-- Row-level security per spec §5.6.

-- Helper: is current user admin?
create or replace function public.is_admin()
returns boolean language sql stable as $$
  select exists (
    select 1 from public.users u
    where u.id = auth.uid() and u.role = 'admin'
  );
$$;

-- users: user reads/updates own row; admin reads all.
alter table public.users enable row level security;
create policy users_select_self on public.users
  for select using (id = auth.uid() or public.is_admin());
create policy users_update_self on public.users
  for update using (id = auth.uid()) with check (id = auth.uid());

-- exercises: user sees own + seed; inserts/updates own.
alter table public.exercises enable row level security;
create policy exercises_select on public.exercises
  for select using (owner_user_id = auth.uid() or owner_user_id is null);
create policy exercises_insert_own on public.exercises
  for insert with check (owner_user_id = auth.uid() and source = 'user');
create policy exercises_update_own on public.exercises
  for update using (owner_user_id = auth.uid());
create policy exercises_admin_all on public.exercises
  for all using (public.is_admin()) with check (public.is_admin());

-- knowledge_packs: read for authed users; write for admin.
alter table public.knowledge_packs enable row level security;
create policy knowledge_packs_select_all on public.knowledge_packs
  for select using (auth.role() = 'authenticated');
create policy knowledge_packs_admin_write on public.knowledge_packs
  for all using (public.is_admin()) with check (public.is_admin());

-- plans: user-scoped.
alter table public.plans enable row level security;
create policy plans_user on public.plans
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- plan_days: scoped via parent plan.
alter table public.plan_days enable row level security;
create policy plan_days_user on public.plan_days
  for all using (
    exists (select 1 from public.plans p where p.id = plan_id and p.user_id = auth.uid())
  ) with check (
    exists (select 1 from public.plans p where p.id = plan_id and p.user_id = auth.uid())
  );

-- plan_prescriptions: scoped via plan_day → plan.
alter table public.plan_prescriptions enable row level security;
create policy plan_prescriptions_user on public.plan_prescriptions
  for all using (
    exists (
      select 1 from public.plan_days pd
      join public.plans p on p.id = pd.plan_id
      where pd.id = plan_day_id and p.user_id = auth.uid()
    )
  ) with check (
    exists (
      select 1 from public.plan_days pd
      join public.plans p on p.id = pd.plan_id
      where pd.id = plan_day_id and p.user_id = auth.uid()
    )
  );

-- sessions: user-scoped.
alter table public.sessions enable row level security;
create policy sessions_user on public.sessions
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- session_exercises: scoped via parent session.
alter table public.session_exercises enable row level security;
create policy session_exercises_user on public.session_exercises
  for all using (
    exists (select 1 from public.sessions s where s.id = session_id and s.user_id = auth.uid())
  ) with check (
    exists (select 1 from public.sessions s where s.id = session_id and s.user_id = auth.uid())
  );

-- sets: scoped via session_exercise → session.
alter table public.sets enable row level security;
create policy sets_user on public.sets
  for all using (
    exists (
      select 1 from public.session_exercises se
      join public.sessions s on s.id = se.session_id
      where se.id = session_exercise_id and s.user_id = auth.uid()
    )
  ) with check (
    exists (
      select 1 from public.session_exercises se
      join public.sessions s on s.id = se.session_id
      where se.id = session_exercise_id and s.user_id = auth.uid()
    )
  );

-- weekly_summaries: user-scoped.
alter table public.weekly_summaries enable row level security;
create policy weekly_summaries_user on public.weekly_summaries
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- ai_config, ai_calls: admin only.
alter table public.ai_config enable row level security;
create policy ai_config_admin on public.ai_config
  for all using (public.is_admin()) with check (public.is_admin());

alter table public.ai_calls enable row level security;
create policy ai_calls_admin on public.ai_calls
  for select using (public.is_admin());
-- inserts happen from edge functions using service_role (bypasses RLS).
```

- [ ] **Step 2:** Apply + verify.

```bash
supabase db reset
supabase db execute "select tablename, rowsecurity from pg_tables where schemaname='public' order by tablename;"
```

Expected: every user-data table shows `rowsecurity = t`.

- [ ] **Step 3:** Commit.

```bash
git add supabase/migrations/20260421000006_rls.sql
git commit -m "feat(db): row-level security across all tables"
```

---

## Task 9 — Seed exercise data (yuhonas → exercises)

**Files:**
- Create: `supabase/seed_data/README.md`
- Create: `supabase/scripts/transform_exercises.ts`
- Create: `supabase/seed_data/exercises.json` (generated)
- Create: `supabase/migrations/20260421000007_seed_exercises.sql`

- [ ] **Step 1:** Document where the data comes from.

Write `supabase/seed_data/README.md`:

```markdown
# Exercise seed data

Source: https://github.com/yuhonas/free-exercise-db (Unlicense / public domain).

To refresh:

1. Clone or download the repo's `dist/exercises.json` into a temp location.
2. Run `deno run -A supabase/scripts/transform_exercises.ts <path-to-source>`.
3. Commit the resulting `supabase/seed_data/exercises.json`.
4. Regenerate `20260421000007_seed_exercises.sql` by running the script in `--emit-sql` mode (or hand-write — see that script).

The transform maps yuhonas fields to our `exercises` schema:

- `yuhonas.primaryMuscles[0]` → `primary_muscle` (mapped via MUSCLE_MAP)
- `yuhonas.secondaryMuscles[]` → `secondary_muscles[]`
- `yuhonas.equipment` → `equipment` (mapped via EQUIPMENT_MAP)
- `yuhonas.id` → `source_ref`
- `source` fixed to `'seed'`, `owner_user_id` null
```

- [ ] **Step 2:** Write the transform script.

Write `supabase/scripts/transform_exercises.ts`:

```ts
// Usage: deno run -A transform_exercises.ts <path-to-yuhonas/dist/exercises.json> [--emit-sql]
//
// Reads yuhonas free-exercise-db JSON, maps to our schema, writes
// seed_data/exercises.json. With --emit-sql, also emits a migration-ready
// INSERT statement to stdout.

type Yuhonas = {
  id: string;
  name: string;
  primaryMuscles: string[];
  secondaryMuscles: string[];
  equipment: string | null;
  instructions: string[];
  category: string;
  images: string[];
  mechanic: string | null;
};

type Exercise = {
  source: "seed";
  source_ref: string;
  name: string;
  description: string;
  primary_muscle: string;
  secondary_muscles: string[];
  equipment: string;
  is_unilateral: boolean;
};

const MUSCLE_MAP: Record<string, string> = {
  chest: "chest",
  "middle back": "upper_back",
  "lower back": "lower_back",
  lats: "lats",
  traps: "traps",
  shoulders: "side_delts",
  biceps: "biceps",
  triceps: "triceps",
  forearms: "forearms",
  quadriceps: "quads",
  hamstrings: "hamstrings",
  glutes: "glutes",
  calves: "calves",
  adductors: "adductors",
  abductors: "abductors",
  abdominals: "abs",
  neck: "neck",
};

const EQUIPMENT_MAP: Record<string, string> = {
  barbell: "barbell",
  dumbbell: "dumbbell",
  cable: "cable",
  machine: "machine",
  "body only": "bodyweight",
  kettlebells: "kettlebell",
  bands: "band",
  "medicine ball": "other",
  "exercise ball": "other",
  "foam roll": "other",
  "e-z curl bar": "barbell",
  other: "other",
};

const UNILATERAL_HINTS = [
  "single arm", "one arm", "single-arm", "one-arm",
  "single leg", "one leg", "bulgarian", "pistol",
];

function transform(row: Yuhonas): Exercise | null {
  const pm = row.primaryMuscles?.[0];
  if (!pm) return null;
  const primary = MUSCLE_MAP[pm.toLowerCase()];
  if (!primary) return null;

  const secondary = (row.secondaryMuscles ?? [])
    .map((m) => MUSCLE_MAP[m.toLowerCase()])
    .filter(Boolean);

  const equip = EQUIPMENT_MAP[(row.equipment ?? "other").toLowerCase()] ?? "other";

  const nameLower = row.name.toLowerCase();
  const unilateral = UNILATERAL_HINTS.some((h) => nameLower.includes(h));

  return {
    source: "seed",
    source_ref: row.id,
    name: row.name,
    description: (row.instructions ?? []).join("\n\n"),
    primary_muscle: primary,
    secondary_muscles: secondary,
    equipment: equip,
    is_unilateral: unilateral,
  };
}

function sqlEscape(s: string): string {
  return s.replaceAll("'", "''");
}

function emitSql(rows: Exercise[]): string {
  const values = rows.map((r) => {
    const secs = r.secondary_muscles.length
      ? `ARRAY[${r.secondary_muscles.map((m) => `'${m}'`).join(",")}]::muscle[]`
      : `ARRAY[]::muscle[]`;
    return `('${r.source}', '${sqlEscape(r.source_ref)}', '${sqlEscape(r.name)}', '${sqlEscape(r.description)}', '${r.primary_muscle}'::muscle, ${secs}, '${r.equipment}'::equipment, ${r.is_unilateral})`;
  }).join(",\n  ");
  return [
    "insert into public.exercises",
    "(source, source_ref, name, description, primary_muscle, secondary_muscles, equipment, is_unilateral)",
    "values",
    `  ${values};`,
  ].join("\n");
}

const [srcPath, ...flags] = Deno.args;
if (!srcPath) {
  console.error("Usage: transform_exercises.ts <path-to-yuhonas/dist/exercises.json> [--emit-sql]");
  Deno.exit(1);
}

const raw = JSON.parse(await Deno.readTextFile(srcPath)) as Yuhonas[];
const transformed = raw.map(transform).filter((x): x is Exercise => x !== null);

await Deno.writeTextFile(
  new URL("../seed_data/exercises.json", import.meta.url).pathname,
  JSON.stringify(transformed, null, 2),
);
console.error(`Wrote ${transformed.length} exercises to supabase/seed_data/exercises.json`);

if (flags.includes("--emit-sql")) {
  console.log("-- Generated from yuhonas/free-exercise-db, Unlicense.");
  console.log(emitSql(transformed));
}
```

- [ ] **Step 3:** Download yuhonas data and run the transform.

```bash
# From a temp dir:
mkdir -p /tmp/yuhonas && cd /tmp/yuhonas
curl -L -o exercises.json \
  https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json

# Back in the repo root:
cd /Users/isaias/Desktop/gimma-app
deno run -A supabase/scripts/transform_exercises.ts /tmp/yuhonas/exercises.json --emit-sql \
  > supabase/migrations/20260421000007_seed_exercises.sql
```

Verify the generated SQL file starts with `-- Generated from yuhonas` and that `supabase/seed_data/exercises.json` contains ~800 entries.

- [ ] **Step 4:** Apply + verify row count.

```bash
supabase db reset
supabase db execute "select count(*) from public.exercises where source='seed';"
```

Expected: a count between 700 and 900.

- [ ] **Step 5:** Commit.

```bash
git add supabase/seed_data/README.md supabase/scripts/transform_exercises.ts \
        supabase/seed_data/exercises.json supabase/migrations/20260421000007_seed_exercises.sql
git commit -m "feat(db): seed exercises from yuhonas/free-exercise-db"
```

---

## Task 10 — Flutter project bootstrap

**Files:**
- Create: `apps/mobile/` (via `flutter create`)
- Modify: `apps/mobile/pubspec.yaml`
- Create: `apps/mobile/analysis_options.yaml` (replaces default)
- Create: `apps/mobile/.env.example`

- [ ] **Step 1:** Create the Flutter app.

```bash
cd apps
flutter create --org com.gimma --project-name gimma mobile
cd mobile
flutter pub get
```

- [ ] **Step 2:** Add core dependencies.

From `apps/mobile/`:

```bash
flutter pub add supabase_flutter flutter_riverpod go_router flutter_dotenv google_sign_in
flutter pub add --dev mocktail riverpod_test
```

- [ ] **Step 3:** Replace `apps/mobile/analysis_options.yaml` with strict lints.

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  errors:
    invalid_annotation_target: ignore

linter:
  rules:
    - always_declare_return_types
    - avoid_dynamic_calls
    - avoid_print
    - prefer_single_quotes
    - unawaited_futures
    - use_key_in_widget_constructors
```

- [ ] **Step 4:** Add an `assets/.env` entry to pubspec.

In `apps/mobile/pubspec.yaml`, inside the existing `flutter:` section, set:

```yaml
flutter:
  uses-material-design: true
  assets:
    - .env
```

- [ ] **Step 5:** Create `apps/mobile/.env.example`.

```
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=REPLACE_WITH_LOCAL_ANON_KEY
GOOGLE_IOS_CLIENT_ID=
GOOGLE_WEB_CLIENT_ID=
```

- [ ] **Step 6:** Ignore the real `.env`.

Append to repo-root `.gitignore`:

```
apps/mobile/.env
```

- [ ] **Step 7:** Verify analyzer passes on the default scaffold.

```bash
cd apps/mobile
flutter analyze
```

Expected: `No issues found!` (or only deprecation warnings for the default counter example).

- [ ] **Step 8:** Commit.

```bash
git add apps/mobile .gitignore
git commit -m "feat(mobile): bootstrap Flutter app with core deps and strict lints"
```

---

## Task 11 — Environment + Supabase bootstrap

**Files:**
- Create: `apps/mobile/lib/config/env.dart`
- Create: `apps/mobile/lib/config/supabase_bootstrap.dart`
- Modify: `apps/mobile/lib/main.dart`
- Create: `apps/mobile/.env` (local only, gitignored)

- [ ] **Step 1:** Copy `.env.example` to `.env` and fill with the local Supabase anon key.

```bash
cp apps/mobile/.env.example apps/mobile/.env
# then open apps/mobile/.env and paste SUPABASE_ANON_KEY from `supabase status`
```

- [ ] **Step 2:** Create `apps/mobile/lib/config/env.dart`.

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL']!;
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY']!;
  static String? get googleIosClientId => dotenv.env['GOOGLE_IOS_CLIENT_ID'];
  static String? get googleWebClientId => dotenv.env['GOOGLE_WEB_CLIENT_ID'];

  static Future<void> load() => dotenv.load(fileName: '.env');
}
```

- [ ] **Step 3:** Create `apps/mobile/lib/config/supabase_bootstrap.dart`.

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

import 'env.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
    debug: false,
  );
}

SupabaseClient get supabase => Supabase.instance.client;
```

- [ ] **Step 4:** Replace `apps/mobile/lib/main.dart`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'config/env.dart';
import 'config/supabase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load();
  await initSupabase();
  runApp(const ProviderScope(child: GimmaApp()));
}
```

- [ ] **Step 5:** Verify build (app widget doesn't exist yet — next task creates it).

```bash
cd apps/mobile
flutter analyze lib/config lib/main.dart
```

Expected: errors about missing `app.dart` and `GimmaApp` (expected, fixed in Task 12).

- [ ] **Step 6:** Commit.

```bash
git add apps/mobile/lib/config apps/mobile/lib/main.dart
git commit -m "feat(mobile): env loader + Supabase bootstrap"
```

---

## Task 12 — App widget, routing, theme

**Files:**
- Create: `apps/mobile/lib/app.dart`
- Create: `apps/mobile/lib/core/routing/app_router.dart`
- Create: `apps/mobile/lib/core/theme/app_theme.dart`

- [ ] **Step 1:** Create `apps/mobile/lib/core/theme/app_theme.dart`.

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A7FE7),
        ),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A7FE7),
          brightness: Brightness.dark,
        ),
      );
}
```

Note: the real design-token-driven theme is introduced when the design system lands (out of scope for Plan 1). This is a placeholder.

- [ ] **Step 2:** Create `apps/mobile/lib/core/routing/app_router.dart`.

```dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/home/presentation/home_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthed = Supabase.instance.client.auth.currentSession != null;
      final goingToSignIn = state.matchedLocation == '/sign-in';
      if (!isAuthed && !goingToSignIn) return '/sign-in';
      if (isAuthed && goingToSignIn) return '/';
      return null;
    },
    refreshListenable:
        GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/sign-in', builder: (_, __) => const SignInScreen()),
    ],
  );
});

/// Bridges a Stream to a Listenable so GoRouter refreshes on auth changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
```

- [ ] **Step 3:** Create `apps/mobile/lib/app.dart`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

class GimmaApp extends ConsumerWidget {
  const GimmaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Gimma',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}
```

- [ ] **Step 4:** Flutter will still fail until sign-in / home screens exist. That's fine — next tasks.

- [ ] **Step 5:** Commit.

```bash
git add apps/mobile/lib/app.dart apps/mobile/lib/core
git commit -m "feat(mobile): app widget, go_router, theme placeholder"
```

---

## Task 13 — Auth repository (TDD)

**Files:**
- Create: `apps/mobile/test/features/auth/auth_repository_test.dart`
- Create: `apps/mobile/lib/features/auth/data/auth_repository.dart`

- [ ] **Step 1:** Write the failing tests.

Write `apps/mobile/test/features/auth/auth_repository_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gimma/features/auth/data/auth_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}
class _MockGoTrueClient extends Mock implements GoTrueClient {}
class _FakeAuthResponse extends Fake implements AuthResponse {}

void main() {
  late _MockSupabaseClient client;
  late _MockGoTrueClient auth;
  late AuthRepository repo;

  setUpAll(() {
    registerFallbackValue(OAuthProvider.google);
  });

  setUp(() {
    client = _MockSupabaseClient();
    auth = _MockGoTrueClient();
    when(() => client.auth).thenReturn(auth);
    repo = AuthRepository(client);
  });

  test('signInWithEmail calls auth.signInWithPassword', () async {
    when(() => auth.signInWithPassword(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async => _FakeAuthResponse());

    await repo.signInWithEmail(email: 'a@b.com', password: 'secret');

    verify(() => auth.signInWithPassword(email: 'a@b.com', password: 'secret')).called(1);
  });

  test('signUpWithEmail calls auth.signUp', () async {
    when(() => auth.signUp(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async => _FakeAuthResponse());

    await repo.signUpWithEmail(email: 'a@b.com', password: 'secret');

    verify(() => auth.signUp(email: 'a@b.com', password: 'secret')).called(1);
  });

  test('signOut calls auth.signOut', () async {
    when(() => auth.signOut()).thenAnswer((_) async {});

    await repo.signOut();

    verify(() => auth.signOut()).called(1);
  });
}
```

- [ ] **Step 2:** Run the tests to confirm they fail.

```bash
cd apps/mobile
flutter test test/features/auth/auth_repository_test.dart
```

Expected: FAIL — `AuthRepository` not found.

- [ ] **Step 3:** Implement `apps/mobile/lib/features/auth/data/auth_repository.dart`.

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Stream<AuthState> authStateChanges() => _client.auth.onAuthStateChange;

  Session? currentSession() => _client.auth.currentSession;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    await _client.auth.signUp(email: email, password: password);
  }

  Future<void> signInWithGoogle({
    required String idToken,
    required String accessToken,
  }) async {
    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  Future<void> signOut() => _client.auth.signOut();
}
```

- [ ] **Step 4:** Run the tests to verify they pass.

```bash
flutter test test/features/auth/auth_repository_test.dart
```

Expected: all 3 tests PASS.

- [ ] **Step 5:** Commit.

```bash
git add apps/mobile/lib/features/auth/data apps/mobile/test/features/auth/auth_repository_test.dart
git commit -m "feat(auth): AuthRepository with email + Google sign-in"
```

---

## Task 14 — Auth controller (Riverpod)

**Files:**
- Create: `apps/mobile/lib/features/auth/presentation/auth_controller.dart`

- [ ] **Step 1:** Create the controller + providers.

Write `apps/mobile/lib/features/auth/presentation/auth_controller.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/supabase_bootstrap.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(supabase);
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signInWithEmail(String email, String password) async {
    final repo = ref.read(authRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repo.signInWithEmail(
          email: email,
          password: password,
        ));
  }

  Future<void> signUpWithEmail(String email, String password) async {
    final repo = ref.read(authRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repo.signUpWithEmail(
          email: email,
          password: password,
        ));
  }

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repo.signOut());
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
```

- [ ] **Step 2:** Run analyzer.

```bash
cd apps/mobile
flutter analyze lib/features/auth
```

Expected: no errors.

- [ ] **Step 3:** Commit.

```bash
git add apps/mobile/lib/features/auth/presentation/auth_controller.dart
git commit -m "feat(auth): Riverpod controller for sign-in / sign-up / sign-out"
```

---

## Task 15 — Sign-in screen (widget test first)

**Files:**
- Create: `apps/mobile/test/features/auth/sign_in_screen_test.dart`
- Create: `apps/mobile/lib/features/auth/presentation/sign_in_screen.dart`

- [ ] **Step 1:** Write the failing widget test.

Write `apps/mobile/test/features/auth/sign_in_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gimma/features/auth/presentation/sign_in_screen.dart';

void main() {
  testWidgets('SignInScreen shows email, password, and primary button', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: SignInScreen()),
      ),
    );

    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
```

- [ ] **Step 2:** Run the test — should fail.

```bash
flutter test test/features/auth/sign_in_screen_test.dart
```

Expected: FAIL — `SignInScreen` not defined.

- [ ] **Step 3:** Implement the screen.

Write `apps/mobile/lib/features/auth/presentation/sign_in_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_controller.dart';
import 'google_sign_in_button.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _signUp = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final controller = ref.read(authControllerProvider.notifier);
    if (_signUp) {
      await controller.signUpWithEmail(_emailCtrl.text, _pwCtrl.text);
    } else {
      await controller.signInWithEmail(_emailCtrl.text, _pwCtrl.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final loading = state.isLoading;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Gimma', style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pwCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  const SizedBox(height: 16),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        state.error.toString(),
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: loading ? null : _submit,
                      child: Text(_signUp ? 'Create account' : 'Sign in'),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _signUp = !_signUp),
                    child: Text(_signUp ? 'I have an account' : 'Create an account'),
                  ),
                  const Divider(height: 32),
                  const GoogleSignInButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4:** Create a stub `GoogleSignInButton` so the test compiles (real impl in Task 16).

Write `apps/mobile/lib/features/auth/presentation/google_sign_in_button.dart`:

```dart
import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: null, // wired in Task 16
        icon: const Icon(Icons.g_mobiledata),
        label: const Text('Continue with Google'),
      ),
    );
  }
}
```

- [ ] **Step 5:** Run the test — should pass.

```bash
flutter test test/features/auth/sign_in_screen_test.dart
```

Expected: PASS.

- [ ] **Step 6:** Commit.

```bash
git add apps/mobile/lib/features/auth/presentation apps/mobile/test/features/auth/sign_in_screen_test.dart
git commit -m "feat(auth): sign-in screen with email + Google button stub"
```

---

## Task 16 — Google Sign-in wiring

**Files:**
- Modify: `apps/mobile/lib/features/auth/presentation/google_sign_in_button.dart`
- Modify: `apps/mobile/ios/Runner/Info.plist`
- Modify: `apps/mobile/android/app/build.gradle` (may require update to signingConfig)

Prereq: manual steps M1 and M2 (see top of this plan) are done, and `.env` contains `GOOGLE_IOS_CLIENT_ID` + `GOOGLE_WEB_CLIENT_ID`.

- [ ] **Step 1:** Implement `GoogleSignInButton`.

Replace `apps/mobile/lib/features/auth/presentation/google_sign_in_button.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../config/env.dart';
import '../data/auth_repository.dart';
import 'auth_controller.dart';

class GoogleSignInButton extends ConsumerStatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  ConsumerState<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends ConsumerState<GoogleSignInButton> {
  bool _busy = false;

  Future<void> _signIn() async {
    setState(() => _busy = true);
    try {
      final gsi = GoogleSignIn(
        clientId: Env.googleIosClientId,
        serverClientId: Env.googleWebClientId,
        scopes: const ['email', 'profile'],
      );
      final account = await gsi.signIn();
      if (account == null) return; // user cancelled
      final auth = await account.authentication;
      final idToken = auth.idToken;
      final accessToken = auth.accessToken;
      if (idToken == null || accessToken == null) {
        throw Exception('Missing Google tokens');
      }
      final repo = ref.read(authRepositoryProvider);
      await repo.signInWithGoogle(idToken: idToken, accessToken: accessToken);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _busy ? null : _signIn,
        icon: const Icon(Icons.g_mobiledata),
        label: const Text('Continue with Google'),
      ),
    );
  }
}
```

- [ ] **Step 2:** iOS platform setup — edit `apps/mobile/ios/Runner/Info.plist` to add URL scheme for Google Sign-in. Replace `REVERSED_IOS_CLIENT_ID` with the value from Google Cloud Console (the iOS Client ID reversed — it will look like `com.googleusercontent.apps.12345-abcdef`).

Inside `<dict>`, add:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>REVERSED_IOS_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

- [ ] **Step 3:** Android platform setup. Android Google Sign-in requires:
  1. SHA-1 of debug keystore registered in the Google Cloud Console OAuth client (Android) — done in manual step M2.
  2. No gradle changes needed if the package name already matches `com.gimma.app` (set by `--org com.gimma --project-name gimma` in Task 10, yielding `com.gimma.gimma` — **verify**: if it's `com.gimma.gimma`, update M2's Android client to match OR rename).

Verify:

```bash
grep applicationId apps/mobile/android/app/build.gradle
```

Expected line like `applicationId "com.gimma.gimma"` — make sure your Google Cloud Android client uses this exact package name.

- [ ] **Step 4:** Manual smoke test (requires connected device / simulator).

```bash
cd apps/mobile
flutter run
```

Tap "Continue with Google" → complete flow → expect to land on the home screen with an authenticated session. (Home screen itself is Task 17; for now, expect redirect back to `/` which will be black since `HomeScreen` not defined yet — fine to validate only that the auth step completes without error in logs.)

- [ ] **Step 5:** Commit.

```bash
git add apps/mobile/lib/features/auth/presentation/google_sign_in_button.dart \
        apps/mobile/ios/Runner/Info.plist
git commit -m "feat(auth): wire Google sign-in for iOS + Android"
```

---

## Task 17 — Home screen (signed-in empty state)

**Files:**
- Create: `apps/mobile/test/features/home/home_screen_test.dart`
- Create: `apps/mobile/lib/features/home/presentation/home_screen.dart`

- [ ] **Step 1:** Write the failing widget test.

Write `apps/mobile/test/features/home/home_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gimma/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('HomeScreen shows welcome title and sign-out action', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.text('Gimma'), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsOneWidget);
  });
}
```

- [ ] **Step 2:** Run test — should fail.

```bash
flutter test test/features/home/home_screen_test.dart
```

Expected: FAIL — `HomeScreen` not found.

- [ ] **Step 3:** Implement the screen.

Write `apps/mobile/lib/features/home/presentation/home_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gimma'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Welcome', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              Text(
                'Your home screen is ready. Training features arrive in Plan 2 and beyond.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4:** Run tests to confirm all pass.

```bash
flutter test
```

Expected: all tests PASS.

- [ ] **Step 5:** Manual smoke test.

```bash
flutter run
```

Sign in with email (or Google). Expect to land on the home screen showing "Welcome" and a logout icon. Tap logout; expect to return to sign-in.

- [ ] **Step 6:** Commit.

```bash
git add apps/mobile/lib/features/home apps/mobile/test/features/home
git commit -m "feat(home): signed-in empty state with sign-out"
```

---

## Task 18 — GitHub Actions CI

**Files:**
- Create: `.github/workflows/ci.yaml`

- [ ] **Step 1:** Create the workflow.

Write `.github/workflows/ci.yaml`:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  mobile-tests:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: apps/mobile
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - name: Create .env (CI placeholder)
        run: |
          cat > .env <<EOF
          SUPABASE_URL=http://127.0.0.1:54321
          SUPABASE_ANON_KEY=ci-placeholder
          EOF
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
```

- [ ] **Step 2:** Push to GitHub (first push since this is the bootstrap branch — skip if remote not set).

Only run this step if the user already has a remote configured:

```bash
git remote -v   # if empty, skip — CI will run on first push later
```

- [ ] **Step 3:** Commit.

```bash
git add .github/workflows/ci.yaml
git commit -m "ci: run Flutter analyze + tests on PRs"
```

---

## Task 19 — Setup doc

**Files:**
- Create: `docs/setup.md`

- [ ] **Step 1:** Document what a fresh dev needs to do to run the app locally.

Write `docs/setup.md`:

```markdown
# Local setup

## Prerequisites

- macOS or Linux
- Docker Desktop running
- Flutter SDK (stable channel) — `flutter --version` should be >= 3.24
- Supabase CLI — `brew install supabase/tap/supabase`
- Deno (for the seed transform script) — `brew install deno`

## Steps

1. Clone the repo.
2. Start Supabase locally:

   ```bash
   supabase start
   supabase db reset   # applies all migrations + seed
   ```

3. Copy the printed `API URL` and `anon key` into `apps/mobile/.env`:

   ```bash
   cp apps/mobile/.env.example apps/mobile/.env
   # edit apps/mobile/.env
   ```

4. Install Flutter deps and run:

   ```bash
   cd apps/mobile
   flutter pub get
   flutter run
   ```

## Google Sign-in

For email auth alone, no external setup is required. To test Google sign-in
locally, follow the manual steps at the top of
`docs/superpowers/plans/2026-04-21-plan-01-foundation.md` (sections M1, M2, M3).

## Resetting the database

```bash
supabase db reset   # wipes local DB and re-applies all migrations
```

## Running tests

```bash
cd apps/mobile
flutter test
```
```

- [ ] **Step 2:** Update `README.md` to point to the setup doc (replace the "(TBD in Plan 1)" placeholder).

Edit `README.md` — change the "Setup" section:

```markdown
## Setup

See [`docs/setup.md`](docs/setup.md).
```

- [ ] **Step 3:** Commit.

```bash
git add docs/setup.md README.md
git commit -m "docs: local setup guide"
```

---

## Plan 1 Definition of Done

This plan is complete when all of the following are true:

- [ ] `supabase db reset` succeeds and populates all tables per schema in spec §5
- [ ] `select count(*) from public.exercises where source='seed'` returns 700–900
- [ ] RLS is enabled on every user-scoped table (verify via `pg_tables.rowsecurity`)
- [ ] `flutter test` from `apps/mobile/` passes all suites
- [ ] `flutter analyze` reports no issues
- [ ] `flutter run` launches the app; sign-up with email → lands on Home; sign-out → returns to sign-in
- [ ] Google sign-in completes successfully on at least one platform (iOS or Android)
- [ ] GitHub Actions CI workflow exists and (if remote is set) passes on main
- [ ] `docs/setup.md` is complete and accurate for a fresh clone

---

## Tasks deferred to later plans (do not scope-creep into Plan 1)

- **Drift local DB + sync engine** → Plan 2
- **Exercise browsing / create-exercise UI** → Plan 2
- **Photo upload** → Plan 2
- **Sentry wiring** → Plan 8
- **Design-system / token-driven theme** → arrives when author provides design system; Plan 1 uses a placeholder color scheme
- **Apple Sign-in** → deferred to v2 per spec §2
- **Next.js admin** → Plan 7
