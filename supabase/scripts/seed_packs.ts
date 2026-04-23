// Usage: deno run -A supabase/scripts/seed_packs.ts [--emit-sql]
//
// Reads each supabase/packs/<id>/ directory, assembles a knowledge_pack
// row per pack, and emits an upsert migration on stdout.
import { parse as parseYaml } from 'https://deno.land/std@0.224.0/yaml/mod.ts';

const packsDir = new URL('../packs/', import.meta.url);
const entries: Array<Record<string, unknown>> = [];

for await (const d of Deno.readDir(packsDir)) {
  if (!d.isDirectory) continue;
  const dir = new URL(`../packs/${d.name}/`, import.meta.url);
  const meta = parseYaml(
    await Deno.readTextFile(new URL('pack.yaml', dir)),
  ) as Record<string, unknown>;

  const principles_md = await Deno.readTextFile(new URL('principles.md', dir));
  const red_flags_md = await Deno.readTextFile(new URL('red_flags.md', dir));
  const plan_templates = JSON.parse(
    await Deno.readTextFile(new URL('plan_templates.json', dir)),
  );
  const rep_range_guidance = JSON.parse(
    await Deno.readTextFile(new URL('rep_range_guidance.json', dir)),
  );
  const rest_guidance = JSON.parse(
    await Deno.readTextFile(new URL('rest_guidance.json', dir)),
  );
  const substitutions = JSON.parse(
    await Deno.readTextFile(new URL('substitutions.json', dir)),
  );

  entries.push({
    id: meta.id as string,
    name: meta.name as string,
    version: meta.version as string,
    goal: meta.goal as string,
    principles_md,
    plan_templates,
    rep_range_guidance,
    rest_guidance,
    substitutions,
    red_flags_md,
    is_active: true,
  });
}

function sqlEscape(s: string): string {
  return s.replaceAll("'", "''");
}

function emitSql(rows: typeof entries): string {
  const values = rows
    .map((r) => {
      return `('${r.id}', '${sqlEscape(r.name as string)}', '${r.version}', '${r.goal}', '${sqlEscape(r.principles_md as string)}', '${sqlEscape(JSON.stringify(r.plan_templates))}'::jsonb, '${sqlEscape(JSON.stringify(r.rep_range_guidance))}'::jsonb, '${sqlEscape(JSON.stringify(r.rest_guidance))}'::jsonb, '${sqlEscape(JSON.stringify(r.substitutions))}'::jsonb, '${sqlEscape(r.red_flags_md as string)}', ${r.is_active})`;
    })
    .join(',\n  ');
  return [
    '-- Generated from supabase/packs/ by supabase/scripts/seed_packs.ts',
    'insert into public.knowledge_packs',
    '(id, name, version, goal, principles_md, plan_templates, rep_range_guidance, rest_guidance, substitutions, red_flags_md, is_active)',
    'values',
    `  ${values}`,
    'on conflict (id) do update set',
    '  name = excluded.name, version = excluded.version, goal = excluded.goal,',
    '  principles_md = excluded.principles_md, plan_templates = excluded.plan_templates,',
    '  rep_range_guidance = excluded.rep_range_guidance, rest_guidance = excluded.rest_guidance,',
    '  substitutions = excluded.substitutions, red_flags_md = excluded.red_flags_md,',
    '  is_active = excluded.is_active;',
  ].join('\n');
}

if (Deno.args.includes('--emit-sql')) {
  console.log(emitSql(entries));
} else {
  console.error(`Ready to emit ${entries.length} pack(s). Pass --emit-sql to print SQL.`);
}
