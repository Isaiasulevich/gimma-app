import Link from 'next/link';
import { createClient } from '@/lib/supabase/server';

export const dynamic = 'force-dynamic';

export default async function PacksPage() {
  const supabase = await createClient();
  const { data: packs } = await supabase.from('knowledge_packs').select().order('id');
  return (
    <>
      <h1 className="mb-6 text-2xl font-semibold">Knowledge packs</h1>
      <div className="space-y-2">
        {(packs ?? []).map((p) => (
          <Link key={p.id} href={`/packs/${p.id}`}
                className="block rounded border p-4 hover:bg-neutral-50">
            <div className="flex items-center justify-between">
              <div>
                <div className="font-medium">{p.name}</div>
                <div className="text-xs text-neutral-500">{p.id} · v{p.version} · goal: {p.goal}</div>
              </div>
              {p.is_active && <span className="rounded-full bg-green-100 px-2 py-1 text-xs text-green-800">active</span>}
            </div>
          </Link>
        ))}
      </div>
    </>
  );
}
