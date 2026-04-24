-- Let admins SELECT all plans / plan_days / plan_prescriptions so the
-- admin app can show every user's generated plans. Writes stay user-scoped;
-- the only new grant is read.

create policy plans_admin_select on public.plans
  for select using (public.is_admin());

create policy plan_days_admin_select on public.plan_days
  for select using (public.is_admin());

create policy plan_prescriptions_admin_select on public.plan_prescriptions
  for select using (public.is_admin());
