# Gimma — AI-Powered Gym App

**Design document · 2026-04-21**

## 1. Overview

Gimma is a cross-platform mobile gym app (iOS + Android, Flutter) that lets a
lifter log their training in the gym, and uses AI to generate and evolve
training plans based on how the user has actually been training. The AI acts
as a trainer's "brain": a code-controlled system prompt plus a set of
swappable **knowledge packs** (one per training focus — hypertrophy, strength,
armwrestling, etc.), combined per-request with the user's own training
history and exercise library.

The app is built for the author first (personal use), with architecture
choices that keep the option of a public release open.

## 2. Scope

### In scope for v1

- iOS + Android mobile app built with Flutter
- Email + Google sign-in (Sign in with Apple deferred; added pre-public-release)
- Offline-first in-gym logging: exercises, sessions, sets, rest timer
- Seed exercise library (bundled) plus user-created exercises with optional photo
- AI-generated training plans via Q&A, with two onboarding modes:
  - **Guided** — Q&A → plan on day 1
  - **Observation** — free-log for 2 weeks, AI proposes plan
- Weekly auto-generated training summary ("Coach" tab) and on-demand "Review now"
- Admin web app (Next.js on Vercel) for managing AI model, system prompt, knowledge
  packs, and viewing AI call logs
- Swappable AI providers (default Google Gemini; Claude and OpenAI as fallbacks),
  swap controlled by admin
- Observability (Sentry + ai_calls log table)

### Out of scope for v1

- Nutrition / diet tracking
- Social features (friends, sharing, leaderboards)
- Video / camera form-check / AI vision
- Apple Watch or WearOS companion apps
- Payments, subscriptions, paywall
- Multi-language / localization (English only; tokens ready for future i18n)
- Push notifications (deferred to v1.5)
- Mid-session AI chat (deferred to v1.5)
- HealthKit / Google Fit integration (deferred to v2, but schema is ready now)

### Non-goals (explicit)

- Building another generic fitness tracker. Gimma is opinionated — it's for
  serious lifters who want evidence-based programming, not step counters.
- Real-time coaching via computer vision.
- Replacing a human trainer for post-injury rehab. The app flags red-flag pain
  patterns but always defers to "see a physio."

## 3. Users & personas

**Primary user (v1):** the author — a lifter who trains seriously, wants
structured plans, and wants to log minimally while in the gym.

**Persona A — "Just tell me what to do."** Wants structure from day 1. Takes
the Guided onboarding, follows the AI's plan.

**Persona B — "Observe me."** Experienced lifter with opinions. Free-logs for
two weeks, then has the AI propose a plan that respects their established
pattern.

Both personas share one top-priority constraint:

> **In-gym data entry must be frictionless.** A few taps per set, no spinners,
> no hesitation, nothing that interrupts rest. This is a non-negotiable design
> principle that overrides other considerations.

## 4. Architecture

Three deployed pieces, one shared Postgres database.

```
┌─────────────────────┐          ┌──────────────────────┐
│  Flutter Mobile App │          │   Next.js Admin      │
│  iOS + Android      │          │   (Vercel)           │
│  - Local SQLite     │          │   - Prompt/pack CRUD │
│  - Offline-first    │          │   - AI call logs     │
│  - Sync engine      │          │   - Model switcher   │
└─────────┬───────────┘          └──────────┬───────────┘
          │                                 │
          │  supabase-dart                  │  @supabase/ssr
          │                                 │
          ▼                                 ▼
     ┌──────────────────────────────────────────────┐
     │          Supabase (managed)                  │
     │  - Postgres + Row-Level Security             │
     │  - Auth (email + Google)                     │
     │  - Storage (exercise photos)                 │
     │  - Edge Functions (AI gateway, scheduled)    │
     └────────────────┬─────────────────────────────┘
                      │ Vercel AI SDK
                      ▼
          ┌──────────────────────────┐
          │ AI Providers (swappable) │
          │ - Gemini (default)       │
          │ - Claude                 │
          │ - OpenAI                 │
          └──────────────────────────┘

     Bundled in the app (no runtime fetch):
     - yuhonas/free-exercise-db (public domain, ~870 exercises)
```

### Key architectural decisions

- **AI calls never happen from the Flutter app directly.** All LLM calls go
  through a Supabase Edge Function (`generate-plan`, `weekly-summary`,
  `review-now`) which reads the active model + system prompt from the
  `ai_config` table and calls the selected provider via **Vercel AI SDK**.
  This keeps API keys server-side and makes provider-swap a DB change, no
  app release required.
- **Vercel AI SDK `generateObject`** enforces structured output against a Zod
  schema across every provider, so plan JSON is always schema-valid or the
  call fails.
- **Offline-first** is achieved via a local SQLite mirror of the Postgres
  schema. The Flutter UI reads and writes to local SQLite only; a sync engine
  pushes/pulls in the background.
- **Row-level security** on every user-scoped table enforces data isolation
  from day one, even though v1 has one user.

## 5. Data model

All tables live in Postgres (Supabase). Local SQLite (Drift) mirrors the same
table/column names with added `sync_status`, `local_created_at`, `synced_at`
columns on syncable rows.

### 5.1 Identity

**`users`** (extends `auth.users`)

| column | type | notes |
|---|---|---|
| id | uuid (PK, FK to auth.users) | |
| email | text | |
| display_name | text | |
| role | enum('user','admin') | default 'user' |
| unit_system | enum('metric','imperial') | default 'metric' |
| experience_level | enum('beginner','intermediate','advanced') | |
| goal | text | e.g. 'muscle', 'strength', 'armwrestling', 'general', 'custom' |
| onboarding_mode | enum('guided','observe') | |
| onboarding_completed_at | timestamptz | null until completed |
| created_at | timestamptz | |

### 5.2 Library

**`exercises`** — single unified table for seed + user-created exercises.

| column | type | notes |
|---|---|---|
| id | uuid (PK) | UUIDv7 client-generated for idempotent sync |
| owner_user_id | uuid (nullable FK → users) | null = seed / global |
| source | enum('seed','user') | |
| source_ref | text | yuhonas id if seed |
| name | text | |
| description | text | |
| photo_url | text | Supabase Storage URL |
| primary_muscle | enum | see muscle enum |
| secondary_muscles | enum[] | |
| equipment | enum('barbell','dumbbell','machine','cable','bodyweight','band','other') | |
| is_unilateral | bool | |
| is_archived | bool | |
| created_at | timestamptz | |

**Why one table, not two:** the AI and the UI both want "all exercises
available to me." A single table with a `source` discriminator + RLS (user
sees rows where `owner_user_id = me OR owner_user_id IS NULL`) is simpler
than UNION-ing everywhere.

**`knowledge_packs`** — the AI brain packs.

| column | type | notes |
|---|---|---|
| id | text (PK) | e.g. 'hypertrophy-v1' |
| name | text | |
| version | text | |
| goal | text | matches users.goal vocabulary |
| principles_md | text | markdown — core training principles |
| plan_templates | jsonb | list of split structures |
| rep_range_guidance | jsonb | by goal & exercise type |
| rest_guidance | jsonb | by exercise type |
| substitutions | jsonb | equipment / injury rules |
| red_flags_md | text | markdown — what to flag |
| is_active | bool | |
| updated_at | timestamptz | |

### 5.3 Planning (the template)

**`plans`** — a training program.

| column | type | notes |
|---|---|---|
| id | uuid (PK) | |
| user_id | uuid (FK) | |
| name | text | |
| goal | text | |
| pack_id | text (FK → knowledge_packs) | |
| split_type | enum('full_body','upper_lower','ppl','custom') | |
| days_per_week | int | |
| generated_by_ai | bool | |
| ai_reasoning | text | human-readable why |
| is_active | bool | only one active per user — enforced via partial unique index where is_active = true |
| started_at | timestamptz | |
| ended_at | timestamptz | null if active |
| created_at | timestamptz | |

**`plan_days`** — a session template inside a plan.

| column | type | notes |
|---|---|---|
| id | uuid (PK) | |
| plan_id | uuid (FK) | |
| day_number | int | 1..N |
| name | text | e.g. 'Push A' |
| focus | text | e.g. 'Chest / Shoulders / Triceps' |

**`plan_prescriptions`** — an exercise prescribed in a plan day with targets.

| column | type | notes |
|---|---|---|
| id | uuid (PK) | |
| plan_day_id | uuid (FK) | |
| exercise_id | uuid (FK) | |
| order | int | |
| target_sets | int | |
| target_reps_min | int | |
| target_reps_max | int | |
| target_rir | int | |
| target_rest_seconds | int | |
| notes | text | |

### 5.4 Execution (what actually happened)

**`sessions`** — a real workout.

| column | type | notes |
|---|---|---|
| id | uuid (PK) | |
| user_id | uuid (FK) | |
| plan_day_id | uuid (nullable FK) | null = free-log session |
| started_at | timestamptz | |
| ended_at | timestamptz | null = in progress |
| status | enum('in_progress','completed','abandoned') | |
| bodyweight | numeric (nullable) | ready for HealthKit |
| heart_rate_avg | int (nullable) | ready for HealthKit |
| heart_rate_max | int (nullable) | ready for HealthKit |
| calories_est | int (nullable) | ready for HealthKit |
| notes | text | |

**`session_exercises`** — an exercise during an actual session.

| column | type | notes |
|---|---|---|
| id | uuid (PK) | |
| session_id | uuid (FK) | |
| exercise_id | uuid (FK) | |
| order | int | |
| status | enum('pending','in_progress','skipped','done') | |
| skip_reason | text | e.g. 'machine busy' |

**`sets`** — the real logged set.

| column | type | notes |
|---|---|---|
| id | uuid (PK) | |
| session_exercise_id | uuid (FK) | |
| set_number | int | |
| weight | numeric (nullable) | null for bodyweight |
| reps | int | |
| rir | int (nullable) | |
| rest_seconds | int | auto-timed from previous |
| tempo | text (nullable) | advanced, opt-in |
| is_unilateral_left | bool (nullable) | advanced, opt-in |
| notes | text (nullable) | advanced, opt-in |
| logged_at | timestamptz | |

### 5.5 AI / Ops

**`ai_config`** (singleton row, keyed by `id = 'active'`)

| column | type | notes |
|---|---|---|
| id | text (PK) | 'active' |
| active_provider | enum('google','anthropic','openai') | |
| active_model | text | e.g. 'gemini-2.0-flash' |
| system_prompt_override | text (nullable) | null = use code default |
| temperature | numeric | |
| max_tokens | int | |
| updated_by_user_id | uuid | |
| updated_at | timestamptz | |

**`ai_calls`** (observability log)

| column | type | notes |
|---|---|---|
| id | uuid (PK) | |
| user_id | uuid (nullable) | null for system runs |
| kind | enum('plan_gen','weekly_summary','review_now','onboarding') | |
| provider | text | |
| model | text | |
| input_tokens | int | |
| output_tokens | int | |
| cost_usd | numeric | |
| latency_ms | int | |
| system_prompt_hash | text | for version tracking |
| pack_id | text (nullable) | |
| request_body | jsonb | |
| response_body | jsonb | |
| error | text (nullable) | |
| created_at | timestamptz | |

**`weekly_summaries`**

| column | type | notes |
|---|---|---|
| id | uuid (PK) | |
| user_id | uuid (FK) | |
| week_start | date | Monday of the summarized week |
| summary_md | text | AI-generated |
| volume_by_muscle | jsonb | computed, not AI |
| frequency | jsonb | computed |
| stalls | jsonb | computed |
| prs | jsonb | computed |
| generated_at | timestamptz | |

### 5.6 Row-level security

- `users` — user can read/update own row; admin can read all.
- `exercises` — user can read where `owner_user_id = auth.uid() OR owner_user_id IS NULL`; user can insert/update where `owner_user_id = auth.uid()`; admin can edit seed rows.
- `plans`, `plan_days`, `plan_prescriptions`, `sessions`, `session_exercises`, `sets`, `weekly_summaries` — user-scoped via `user_id` / joined FK. Admin read-only.
- `knowledge_packs` — read for any authenticated user; write for admin only.
- `ai_config`, `ai_calls` — admin only.

## 6. AI "brain" design

### 6.1 Three-layer assembly

Every LLM call is `system_prompt + active_pack + user_context`, evaluated
against a Zod schema for structured output.

1. **System prompt** — identity, rules, output format. Defaults live in the
   Flutter/Next.js codebase (source of truth). Admin can override at runtime
   via `ai_config.system_prompt_override`. The override is a debug /
   iteration tool, not a user-facing setting.
2. **Knowledge pack** — the expertise library for a specific goal
   (hypertrophy, strength, armwrestling, etc.). Stored as `knowledge_packs`
   rows; seeded at deploy from markdown/JSON files in the repo. Admin edits
   propagate immediately. The pack holds:
   - `principles_md` — the textbook
   - `plan_templates` — concrete split structures with movement patterns
   - `rep_range_guidance` / `rest_guidance` — numeric targets
   - `substitutions` — equipment & injury rules
   - `red_flags_md` — safety flags
3. **Per-request user context** — assembled by the edge function at call time
   from Postgres:
   - Onboarding / plan-Q&A answers (goal, days/wk, equipment, injuries)
   - Last 30 days of training data: volume per muscle, frequency, PRs, stalls
   - Current exercise library (seed + user-created)

### 6.2 Plan generation flow

```
Flutter Q&A
  → POST /generate-plan edge function
    → load ai_config (provider, model, prompt override, temperature)
    → select pack by goal (default: hypertrophy-v1)
    → compute user profile from recent sessions
    → build prompt = system + pack + user context
    → Vercel AI SDK generateObject({ schema: planSchema })
    → validate structured JSON against Zod
    → INSERT plans / plan_days / plan_prescriptions in a transaction
    → log to ai_calls
    → return plan_id to client
```

The Zod `planSchema` enforces shape like:

```ts
z.object({
  name: z.string(),
  split_type: z.enum(['full_body','upper_lower','ppl','custom']),
  days_per_week: z.number().int().min(2).max(6),
  reasoning: z.string(),
  days: z.array(z.object({
    day_number: z.number().int(),
    name: z.string(),
    focus: z.string(),
    prescriptions: z.array(z.object({
      exercise_id: z.string().uuid(),  // must match a known exercise
      order: z.number().int(),
      target_sets: z.number().int().min(1).max(10),
      target_reps_min: z.number().int(),
      target_reps_max: z.number().int(),
      target_rir: z.number().int().min(0).max(5),
      target_rest_seconds: z.number().int(),
      notes: z.string().optional(),
    }))
  }))
})
```

`exercise_id` must be validated server-side against the user's visible
exercises — the AI can hallucinate a UUID that doesn't exist, so the edge
function rejects unknown IDs and retries once with the specific error in the
prompt.

### 6.3 Training systems supported in v1

AI can generate: **Full Body (2–3x/wk), Upper/Lower (4x/wk), Push/Pull/Legs
(3–6x/wk)**. Progression: **double progression** default with
**RIR-based autoregulation** on set targets. Block periodization and
undulating schemes are deferred.

### 6.4 Set-level data model depth

Required per set: **weight, reps, RIR, rest_seconds**. Advanced/opt-in (hidden
by default): **tempo, is_unilateral_left, notes**.

Exercise-level: **equipment** (required), **is_unilateral** flag.

### 6.5 Insights

**Weekly summary** — Supabase scheduled edge function runs every Monday
06:00. For each active user, loads last 7 days of sets, computes
volume/frequency/PRs/stalls deterministically, then calls AI with an
*analyst* system prompt (different from plan-gen) to write a short narrative
summary. Result stored in `weekly_summaries`.

**Review now** — same pipeline, user-triggered, not cached. Bypasses weekly
cadence.

### 6.6 "Learning" from training history

The AI doesn't fine-tune. "Learning" is context engineering: the user profile
(volume/frequency/preferences/stalls) is freshly computed before every call
and injected into the prompt. The AI reads a summary of the user's pattern
and writes plans that honor it.

## 7. In-gym workout flow

### 7.1 Flow (fully offline)

1. **Pick & start.** Home shows today's plan-suggested session with a one-tap
   option to swap to any other day in the plan.
2. **Exercise view.** For each exercise: target (e.g. `4 × 6–10 @ RIR 1–2, rest
   3:00`), set table with previous-session values pre-filled, primary button
   "Log set · start rest."
3. **Auto rest timer.** Starts on log. Duration = `target_rest_seconds`.
   +30s / Skip-rest controls. Haptic + tone at end.
4. **Skip support.** One-tap skip with optional reason (e.g. "machine busy").
   Skipped exercises queue for end-of-session re-prompt.
5. **Re-prompt.** Before "finish," app prompts for any skipped exercises. User
   can do them or dismiss.
6. **Finish & sync.** Summary (volume by muscle, PRs vs history). Sync queued
   writes to Supabase when online.

### 7.2 UX principles (non-negotiable)

- **Always-visible offline-OK indicator** — green pill near top of screen,
  visible confidence the app works in-gym.
- **Pre-fill from history** — weight/reps/RIR default to the last completed
  set of the same exercise; user only taps if changing.
- **One primary action per screen** — "Log set," "Start rest," "Finish."
  Secondary actions are pills or small buttons.
- **No modals during workout** — nothing interrupts the flow.

### 7.3 UI source of truth

Wireframes and a design system (tokens, components, references) will be
provided by the author and committed under `docs/design/`. The mockups in
this spec illustrate functional behavior only; pixel design will iterate
post-spec.

## 8. Onboarding

At first sign-in, user picks a mode:

### 8.1 Guided mode

Q&A (6–8 questions): goal, experience, days/wk, session length, equipment,
injuries, optional style notes. On submit: `generate-plan` runs with a
slightly expanded prompt (no history yet), returns a starter plan. User
starts training immediately.

### 8.2 Observation mode

Shorter Q&A (goal, days/wk, equipment). No plan generated. User goes
straight to free-log mode (sessions with `plan_day_id = NULL`). After
`14 calendar days` OR `8 logged sessions` (whichever first), the app prompts:
"Ready for a plan? I've seen enough." On confirm, `generate-plan` runs with
observed-profile context and returns a plan that respects the user's
existing pattern.

### 8.3 Mode switching

- Guided → "Free train today" button logs a session without following the plan.
- Observation → "Generate plan now" button bypasses the 14-day / 8-session
  threshold.

## 9. Admin dashboard (Next.js)

### 9.1 Stack

Next.js 15+ App Router on Vercel. Supabase SSR client for DB + auth. Admin
access gated by `users.role = 'admin'`.

### 9.2 Pages (v1)

- **`/login`** — Supabase Google / email; redirects if role ≠ admin.
- **`/ai`** — Model picker, model ID, temperature, max tokens, system prompt
  editor (markdown textarea) with a "use code default" toggle, Save & Activate.
- **`/packs`** — list view with active badge. `/packs/[id]` = markdown editor
  (Tiptap or MDXEditor) for text fields, Monaco JSON editor for structured
  fields, version bump, diff vs last saved.
- **`/logs`** — `ai_calls` table, filterable by user/kind/date. Row click
  opens full request + response JSON, token counts, cost, latency.
- **`/test-plan-gen`** — harness: fake user inputs + pick a pack → calls the
  same `generate-plan` edge function the mobile app uses → renders returned
  plan + tokens + cost. Same code path as production; admin never talks to
  LLM providers directly.

### 9.3 Non-goals

User management, feature flags, A/B prompt testing UI, analytics dashboards,
customer support, billing.

## 10. Offline-first sync strategy

### 10.1 Local DB choice

**Drift** (typed SQLite for Flutter). Schema mirrors Postgres with added
sync metadata columns.

### 10.2 Offline capabilities

Must work offline:

- View active plan and today's session
- Swap today's session to another day
- Start / log / skip / finish a session
- Create a new exercise with photo (photo queues for upload)
- View exercise library + history
- View cached weekly summary

Requires connectivity:

- Sign-in (unless refresh token valid — offline for 30 days)
- Generate new plan
- "Review now" insights
- Fetching updated knowledge packs

### 10.3 Sync mechanism

Syncable rows carry: `sync_status ('pending'|'synced'|'conflict')`,
`local_created_at`, `synced_at`, `server_id`.

1. Every user action writes to local SQLite first as `pending`. UI reads
   from local only — no spinners.
2. Sync engine triggers: app start, app foreground, online-network-change,
   after every successful write, and every 60s while foregrounded.
3. Push order respects FKs: exercises → sessions → session_exercises →
   sets → photos.
4. Photos upload via a background isolate; exercise row's `photo_url`
   updated after upload completes.
5. Conflicts resolved last-writer-wins on server `updated_at`. Sets are
   append-only (rare conflict). Exercises use field-level merge.
6. Idempotency: UUIDv7 generated client-side, used on server; re-sending
   the same row is a no-op.

### 10.4 Sync status UI

Small pill near top of screen: `● Offline`, `● Syncing 4`, `● Synced`. Tap
opens a drawer with retry button and last-error detail.

### 10.5 Failure handling

- **Server offline** → retry with exponential backoff; pill stays orange.
- **Auth token expired** → refresh silently; if refresh fails, prompt sign-in
  *after* the current session ends — never interrupt a workout.
- **Schema drift** (server added a field the app doesn't know) → tolerated;
  app logs warning, ignores unknown fields.
- **User uninstalls with pending writes** → acknowledged data loss.

## 11. Tech stack

| Layer | Choice | Reason |
|---|---|---|
| Mobile framework | **Flutter (Dart)** | iOS + Android, chosen by author |
| Local DB | **Drift (SQLite)** | Typed, mature, strong migration tooling |
| Backend | **Supabase** | Managed Postgres + auth + storage + edge funcs + RLS |
| Admin | **Next.js 15 on Vercel** | Admin UIs are web-shaped; great tooling |
| Server-side AI | **Vercel AI SDK** in Edge Functions | `generateObject` for structured output across providers |
| Default AI provider | **Google Gemini** (2.0 Flash to start) | Cheap, fast, generous free tier |
| AI provider fallbacks | Anthropic Claude, OpenAI | Swappable via admin |
| Exercise seed | **yuhonas/free-exercise-db** | Unlicense (public domain), works offline |
| Error monitoring | **Sentry** | Flutter + Next.js + Edge Functions |
| CI | **GitHub Actions** | Flutter tests + Deno tests on PR |

## 12. Error handling & observability

### 12.1 Principles

- **Never block the in-gym flow.** Any error during a workout falls back to
  local-only; background sync tries later.
- **AI failures are first-class.** Plan-gen either inserts the full
  transactionally-valid plan or nothing at all. User-facing error is
  "plan generation unavailable, try again" with a retry button.
- **User-visible errors are actionable.** Shape:
  `{ user_message, retry_possible, technical_log_id }`. Never raw stack traces.

### 12.2 Observability

- **Sentry** from day one in all three codebases.
- **`ai_calls` log table** — every LLM call logged with token counts, cost,
  latency, full request/response, pack id, system prompt hash.
- **Admin `/logs` page** reads directly from `ai_calls`.

## 13. Testing strategy

Scaled to "personal app that may go public" — enough to protect the critical
path, not enough to slow iteration.

- **Flutter unit tests** on:
  - Sync engine (most error-prone component)
  - Domain logic: volume calc, PR detection, progression suggestion
- **Flutter widget tests** on the in-gym logging flow (log → rest → next).
- **Flutter integration tests** (patrol or `flutter_driver`) for one
  end-to-end happy path: create exercise → log session → finish.
- **Edge function tests** (Deno test) for `generate-plan`: fixture inputs
  → schema-valid output → correct DB rows. Snapshot tests for prompt
  assembly.
- **No tests for UI chrome / visual polish** during v1 — design system is
  still iterating.
- **CI:** GitHub Actions running Flutter + Deno tests on PR.

## 14. MVP definition of done

v1 ships when all of the following are true:

- [ ] Sign up with email or Google
- [ ] Complete onboarding in either Guided or Observation mode
- [ ] Seed exercise library loaded on first launch; search works
- [ ] Create custom exercise with optional photo (works offline)
- [ ] View plan; swap today's session to another day
- [ ] Complete a full in-gym session offline (log sets, auto-rest, skip +
      re-prompt, finish)
- [ ] Session syncs to Supabase when network available
- [ ] "Generate new plan" Q&A → AI returns structured plan → saved and viewable
- [ ] Weekly auto-summary appears in Coach tab every Monday
- [ ] "Review now" button in Coach tab works on-demand
- [ ] Next.js admin deployed; all five pages above functional
- [ ] Sentry capturing crashes from Flutter + Next.js + Edge Functions
- [ ] At least one knowledge pack (`hypertrophy-v1`) fully authored and tested

## 15. Phasing

### v1.5 (after ~1 month of self-dogfooding)

- Push notifications (insights delivery, rest-timer reminders while app
  backgrounded)
- Exercise substitution suggestions ("no barbell today → alternative")
- Mid-session AI chat ("swap today's squat for something easier on my knees")
- Admin: pack A/B prompt testing, diff views

### v2 (pre-public release)

- Sign in with Apple, App Store + Play Store submission
- Subscription / paywall
- HealthKit / Google Fit read-only integration (schema already ready)
- Apple Watch companion (separate WatchOS project; Flutter support is weak)
- Additional knowledge packs: strength, armwrestling, endurance, bodyweight
- Localization

## 16. Open questions & deferred decisions

These are explicitly deferred, not forgotten. They do not block v1.

- **Authoring workflow for packs.** v1 admin supports direct markdown/JSON
  editing. Longer-term, packs might be versioned in git and synced to DB —
  revisit after first custom pack.
- **Unit conversion.** User-level `unit_system` toggle exists; kg/lbs
  conversions are straightforward. Not called out in v1 tasks because it's
  a small detail during UI build.
- **Plan archival vs active switch.** v1 supports one active plan + history
  of past plans. Multi-active plans (e.g., running two programs) deferred.
- **Exercise variations / groupings.** v1 treats each exercise atomically.
  Future: explicit variation relationships (e.g., "barbell bench" and
  "dumbbell bench" as variants of "horizontal push").
- **Backup / export.** Not in v1. Data lives in Supabase; user can export
  via admin dashboard if needed.

---

## Appendix A — Data flow: generating a plan

1. User taps "Create new plan" in Flutter.
2. Flutter shows the Q&A wizard (goal, days/wk, equipment, injuries, etc.).
3. On submit, Flutter POSTs the answers to Supabase Edge Function `/generate-plan`.
4. Edge function loads `ai_config`, selects active pack by `goal`, builds
   user profile from recent sessions, assembles prompt.
5. Vercel AI SDK `generateObject` calls the active provider with the prompt
   and Zod schema.
6. Provider returns structured JSON; SDK validates against schema.
7. Edge function validates `exercise_id`s against the user's visible
   exercises.
8. Edge function writes `plans` + `plan_days` + `plan_prescriptions` in a
   Postgres transaction.
9. `ai_calls` log row written with token counts, cost, latency, full I/O.
10. If the user already has an active plan, the edge function sets the
    previous plan's `is_active = false` and `ended_at = now()` in the same
    transaction before inserting the new one.
11. Edge function returns `plan_id` to Flutter.
12. Flutter fetches the new plan and displays it.

## Appendix B — Data flow: logging a set in the gym (offline)

1. User on "Exercise" screen taps "Log set · start rest."
2. Flutter writes a new `sets` row to local SQLite with `sync_status =
   'pending'`.
3. Rest timer starts immediately.
4. On network available, sync engine picks up the pending row and pushes to
   Supabase.
5. Server assigns `synced_at`; local row marked `synced`.
6. Sync pill updates to green `● Synced`.

Throughout, no UI element blocks on the network. The set "completes" at
step 2.
