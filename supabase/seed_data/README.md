# Exercise seed data

Source: https://github.com/yuhonas/free-exercise-db (Unlicense / public domain).

To refresh:

1. Download the repo's `dist/exercises.json` into a temp location.
2. Run `deno run -A supabase/scripts/transform_exercises.ts <path-to-source>`.
3. Commit the resulting `supabase/seed_data/exercises.json`.
4. Regenerate `20260421000007_seed_exercises.sql` by running the script with `--emit-sql`.

The transform maps yuhonas fields to our `exercises` schema:

- `yuhonas.primaryMuscles[0]` → `primary_muscle` (mapped via MUSCLE_MAP)
- `yuhonas.secondaryMuscles[]` → `secondary_muscles[]`
- `yuhonas.equipment` → `equipment` (mapped via EQUIPMENT_MAP)
- `yuhonas.id` → `source_ref`
- `source` fixed to `'seed'`, `owner_user_id` null
