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
