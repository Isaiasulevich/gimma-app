import { createClient } from '@/lib/supabase/server';
import { AiConfigForm } from './form';

export const dynamic = 'force-dynamic';

export default async function AiPage() {
  const supabase = await createClient();
  const { data: cfg } = await supabase.from('ai_config').select().eq('id', 'active').single();
  return (
    <>
      <h1 className="mb-6 text-2xl font-semibold">AI settings</h1>
      <AiConfigForm initial={cfg!} />
    </>
  );
}
