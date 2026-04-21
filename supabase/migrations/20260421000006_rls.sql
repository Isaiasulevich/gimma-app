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
