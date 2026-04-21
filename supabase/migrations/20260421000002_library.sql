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
