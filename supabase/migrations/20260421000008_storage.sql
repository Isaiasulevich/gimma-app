insert into storage.buckets (id, name, public)
values ('exercise-photos', 'exercise-photos', false)
on conflict (id) do nothing;

create policy "users upload own photos"
  on storage.objects for insert
  with check (
    bucket_id = 'exercise-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "users read own photos"
  on storage.objects for select
  using (
    bucket_id = 'exercise-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "users update own photos"
  on storage.objects for update
  using (
    bucket_id = 'exercise-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "users delete own photos"
  on storage.objects for delete
  using (
    bucket_id = 'exercise-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );
