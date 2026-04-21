# Local setup

## Prerequisites

- macOS or Linux
- Flutter SDK (stable) — `flutter --version` should be >= 3.24
- Supabase CLI — either `brew install supabase/tap/supabase` or download
  the binary from https://github.com/supabase/cli/releases
- Deno (for the seed transform script) — `brew install deno` or install
  via https://deno.land/

No Docker is required for the current "hosted Supabase" workflow. If you
later want a fully-local DB, install Docker Desktop and run
`supabase start` — but the hosted project at
`osxccuqqivyngqitzbyf.supabase.co` is the source of truth for v1.

## First-time setup

1. Clone the repo.
2. Set up environment variables:

   ```bash
   cp apps/mobile/.env.example apps/mobile/.env
   # edit apps/mobile/.env — SUPABASE_URL and SUPABASE_ANON_KEY are
   # already correct for the hosted project; leave GOOGLE_*_CLIENT_ID
   # empty until you set up Google Sign-in.
   ```

3. Link the Supabase CLI to the hosted project (one-time, requires
   your personal access token from
   https://supabase.com/dashboard/account/tokens):

   ```bash
   export SUPABASE_ACCESS_TOKEN=sbp_...
   supabase link --project-ref osxccuqqivyngqitzbyf
   ```

4. Install Flutter deps:

   ```bash
   cd apps/mobile
   flutter pub get
   ```

## Running the app

```bash
cd apps/mobile
flutter run
```

Running on a device requires either an iOS Simulator (Xcode) or an
Android emulator (Android Studio). `flutter doctor` will flag any
missing platform SDKs.

## Database migrations

Migrations live in `supabase/migrations/`. To push changes to the
hosted DB:

```bash
export SUPABASE_ACCESS_TOKEN=sbp_...
export SUPABASE_DB_PASSWORD=<db-password>
supabase db push
```

Note: migrations are forward-only on the hosted DB. To reset, drop
and recreate the project in the Supabase dashboard.

## Running tests

```bash
cd apps/mobile
flutter test
```

## Refreshing the exercise seed

```bash
curl -L https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json \
  -o /tmp/exercises.json
deno run -A supabase/scripts/transform_exercises.ts /tmp/exercises.json --emit-sql \
  > supabase/migrations/<next-timestamp>_seed_exercises.sql
```
