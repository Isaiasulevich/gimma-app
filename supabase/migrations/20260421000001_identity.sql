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
