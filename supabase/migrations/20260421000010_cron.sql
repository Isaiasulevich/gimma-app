create extension if not exists pg_cron with schema extensions;

-- Drop any prior schedule (idempotent).
select cron.unschedule('weekly_summary') where exists (
  select 1 from cron.job where jobname = 'weekly_summary'
);

-- Monday 06:00 UTC.
select cron.schedule(
  'weekly_summary',
  '0 6 * * 1',
  $$
  select net.http_post(
    url := current_setting('app.edge_url', true) || '/functions/v1/weekly-summary-run',
    headers := jsonb_build_object(
      'Authorization', 'Bearer ' || current_setting('app.service_role_key', true),
      'Content-Type', 'application/json'
    ),
    body := '{}'::jsonb
  );
  $$
);
