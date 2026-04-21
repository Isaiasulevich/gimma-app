// Usage: deno run -A transform_exercises.ts <path-to-yuhonas/dist/exercises.json> [--emit-sql]
//
// Reads yuhonas free-exercise-db JSON, maps to our schema, writes
// seed_data/exercises.json. With --emit-sql, also emits a migration-ready
// INSERT statement to stdout.

type Yuhonas = {
  id: string;
  name: string;
  primaryMuscles: string[];
  secondaryMuscles: string[];
  equipment: string | null;
  instructions: string[];
  category: string;
  images: string[];
  mechanic: string | null;
};

type Exercise = {
  source: "seed";
  source_ref: string;
  name: string;
  description: string;
  primary_muscle: string;
  secondary_muscles: string[];
  equipment: string;
  is_unilateral: boolean;
};

const MUSCLE_MAP: Record<string, string> = {
  chest: "chest",
  "middle back": "upper_back",
  "lower back": "lower_back",
  lats: "lats",
  traps: "traps",
  shoulders: "side_delts",
  biceps: "biceps",
  triceps: "triceps",
  forearms: "forearms",
  quadriceps: "quads",
  hamstrings: "hamstrings",
  glutes: "glutes",
  calves: "calves",
  adductors: "adductors",
  abductors: "abductors",
  abdominals: "abs",
  neck: "neck",
};

const EQUIPMENT_MAP: Record<string, string> = {
  barbell: "barbell",
  dumbbell: "dumbbell",
  cable: "cable",
  machine: "machine",
  "body only": "bodyweight",
  kettlebells: "kettlebell",
  bands: "band",
  "medicine ball": "other",
  "exercise ball": "other",
  "foam roll": "other",
  "e-z curl bar": "barbell",
  other: "other",
};

const UNILATERAL_HINTS = [
  "single arm", "one arm", "single-arm", "one-arm",
  "single leg", "one leg", "bulgarian", "pistol",
];

function transform(row: Yuhonas): Exercise | null {
  const pm = row.primaryMuscles?.[0];
  if (!pm) return null;
  const primary = MUSCLE_MAP[pm.toLowerCase()];
  if (!primary) return null;

  const secondary = (row.secondaryMuscles ?? [])
    .map((m) => MUSCLE_MAP[m.toLowerCase()])
    .filter(Boolean);

  const equip = EQUIPMENT_MAP[(row.equipment ?? "other").toLowerCase()] ?? "other";

  const nameLower = row.name.toLowerCase();
  const unilateral = UNILATERAL_HINTS.some((h) => nameLower.includes(h));

  return {
    source: "seed",
    source_ref: row.id,
    name: row.name,
    description: (row.instructions ?? []).join("\n\n"),
    primary_muscle: primary,
    secondary_muscles: secondary,
    equipment: equip,
    is_unilateral: unilateral,
  };
}

function sqlEscape(s: string): string {
  return s.replaceAll("'", "''");
}

function emitSql(rows: Exercise[]): string {
  const values = rows.map((r) => {
    const secs = r.secondary_muscles.length
      ? `ARRAY[${r.secondary_muscles.map((m) => `'${m}'`).join(",")}]::muscle[]`
      : `ARRAY[]::muscle[]`;
    return `('${r.source}', '${sqlEscape(r.source_ref)}', '${sqlEscape(r.name)}', '${sqlEscape(r.description)}', '${r.primary_muscle}'::muscle, ${secs}, '${r.equipment}'::equipment, ${r.is_unilateral})`;
  }).join(",\n  ");
  return [
    "-- Generated from yuhonas/free-exercise-db, Unlicense.",
    "insert into public.exercises",
    "(source, source_ref, name, description, primary_muscle, secondary_muscles, equipment, is_unilateral)",
    "values",
    `  ${values};`,
  ].join("\n");
}

const [srcPath, ...flags] = Deno.args;
if (!srcPath) {
  console.error("Usage: transform_exercises.ts <path-to-yuhonas/dist/exercises.json> [--emit-sql]");
  Deno.exit(1);
}

const raw = JSON.parse(await Deno.readTextFile(srcPath)) as Yuhonas[];
const transformed = raw.map(transform).filter((x): x is Exercise => x !== null);

await Deno.writeTextFile(
  new URL("../seed_data/exercises.json", import.meta.url).pathname,
  JSON.stringify(transformed, null, 2),
);
console.error(`Wrote ${transformed.length} exercises to supabase/seed_data/exercises.json`);

if (flags.includes("--emit-sql")) {
  console.log(emitSql(transformed));
}
