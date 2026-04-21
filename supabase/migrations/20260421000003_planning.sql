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
