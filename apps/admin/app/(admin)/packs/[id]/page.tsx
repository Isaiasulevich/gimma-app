import { createClient } from '@/lib/supabase/server';
import { PackEditor } from './editor';
import { notFound } from 'next/navigation';

export const dynamic = 'force-dynamic';

export default async function PackPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const supabase = await createClient();
  const { data: pack } = await supabase.from('knowledge_packs').select().eq('id', id).maybeSingle();
  if (!pack) notFound();
  return <PackEditor initial={pack} />;
}
