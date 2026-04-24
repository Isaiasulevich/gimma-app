'use client';
import { useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import { MarkdownEditor } from '@/components/markdown-editor';
import { JsonEditor } from '@/components/json-editor';

type Pack = {
  id: string;
  name: string;
  version: string;
  principles_md: string;
  red_flags_md: string;
  plan_templates: unknown;
  rep_range_guidance: unknown;
  rest_guidance: unknown;
  substitutions: unknown;
};

export function PackEditor({ initial }: { initial: Pack }) {
  const [principles, setPrinciples] = useState(initial.principles_md);
  const [redFlags, setRedFlags] = useState(initial.red_flags_md);
  const [templates, setTemplates] = useState<unknown>(initial.plan_templates);
  const [reps, setReps] = useState<unknown>(initial.rep_range_guidance);
  const [rest, setRest] = useState<unknown>(initial.rest_guidance);
  const [subs, setSubs] = useState<unknown>(initial.substitutions);
  const [version, setVersion] = useState<string>(initial.version);
  const [saving, setSaving] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);

  async function save() {
    setSaving(true); setMsg(null);
    const supabase = createClient();
    const { error } = await supabase.from('knowledge_packs').update({
      version,
      principles_md: principles,
      red_flags_md: redFlags,
      plan_templates: templates,
      rep_range_guidance: reps,
      rest_guidance: rest,
      substitutions: subs,
    }).eq('id', initial.id);
    setMsg(error ? `Error: ${error.message}` : `Saved v${version}`);
    setSaving(false);
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold">{initial.name}</h1>
          <p className="text-sm text-neutral-500">{initial.id}</p>
        </div>
        <div className="flex items-center gap-2">
          <label className="text-sm">Version</label>
          <input className="w-24 rounded border p-1 text-sm" value={version} onChange={(e) => setVersion(e.target.value)} />
          <button onClick={save} disabled={saving} className="rounded bg-black px-4 py-2 text-white disabled:opacity-50">
            {saving ? 'Saving…' : 'Save'}
          </button>
        </div>
      </div>
      {msg && <p className="text-sm">{msg}</p>}

      <section>
        <h2 className="mb-2 font-semibold">Principles</h2>
        <MarkdownEditor value={principles} onChange={setPrinciples} />
      </section>
      <section>
        <h2 className="mb-2 font-semibold">Plan templates</h2>
        <JsonEditor value={templates} onChange={setTemplates} />
      </section>
      <section>
        <h2 className="mb-2 font-semibold">Rep range guidance</h2>
        <JsonEditor value={reps} onChange={setReps} />
      </section>
      <section>
        <h2 className="mb-2 font-semibold">Rest guidance</h2>
        <JsonEditor value={rest} onChange={setRest} />
      </section>
      <section>
        <h2 className="mb-2 font-semibold">Substitutions</h2>
        <JsonEditor value={subs} onChange={setSubs} />
      </section>
      <section>
        <h2 className="mb-2 font-semibold">Red flags</h2>
        <MarkdownEditor value={redFlags} onChange={setRedFlags} />
      </section>
    </div>
  );
}
