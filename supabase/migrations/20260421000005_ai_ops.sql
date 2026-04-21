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
