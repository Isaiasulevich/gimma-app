'use client';
import { useState } from 'react';
import { createClient } from '@/lib/supabase/client';

type AiConfig = {
  active_provider: string;
  active_model: string;
  system_prompt_override: string | null;
  temperature: number;
  max_tokens: number;
};

export function AiConfigForm({ initial }: { initial: AiConfig }) {
  const [provider, setProvider] = useState(initial.active_provider);
  const [model, setModel] = useState(initial.active_model);
  const [overridePrompt, setOverridePrompt] = useState<string>(initial.system_prompt_override ?? '');
  const [temperature, setTemperature] = useState<number>(initial.temperature);
  const [maxTokens, setMaxTokens] = useState<number>(initial.max_tokens);
  const [saving, setSaving] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);

  async function save() {
    setSaving(true); setMsg(null);
    const supabase = createClient();
    const { error } = await supabase.from('ai_config').update({
      active_provider: provider,
      active_model: model,
      system_prompt_override: overridePrompt.trim() || null,
      temperature,
      max_tokens: maxTokens,
    }).eq('id', 'active');
    setMsg(error ? `Error: ${error.message}` : 'Saved.');
    setSaving(false);
  }

  return (
    <div className="max-w-2xl space-y-4">
      <div>
        <label className="mb-1 block text-sm font-medium">Provider</label>
        <select className="w-full rounded border p-2" value={provider} onChange={(e) => setProvider(e.target.value)}>
          <option value="google">Google (Gemini)</option>
          <option value="anthropic">Anthropic (Claude)</option>
          <option value="openai">OpenAI (GPT)</option>
        </select>
      </div>
      <div>
        <label className="mb-1 block text-sm font-medium">Model ID</label>
        <input className="w-full rounded border p-2" value={model} onChange={(e) => setModel(e.target.value)} />
      </div>
      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="mb-1 block text-sm font-medium">Temperature</label>
          <input type="number" step="0.1" min="0" max="2" className="w-full rounded border p-2"
                 value={temperature} onChange={(e) => setTemperature(parseFloat(e.target.value))} />
        </div>
        <div>
          <label className="mb-1 block text-sm font-medium">Max tokens</label>
          <input type="number" min="100" max="32000" className="w-full rounded border p-2"
                 value={maxTokens} onChange={(e) => setMaxTokens(parseInt(e.target.value, 10))} />
        </div>
      </div>
      <div>
        <label className="mb-1 block text-sm font-medium">System prompt override</label>
        <p className="mb-1 text-xs text-neutral-500">Leave blank to use the code default.</p>
        <textarea rows={10} className="w-full rounded border p-2 font-mono text-xs"
                  value={overridePrompt} onChange={(e) => setOverridePrompt(e.target.value)} />
      </div>
      <button onClick={save} disabled={saving} className="rounded bg-black px-4 py-2 text-white disabled:opacity-50">
        {saving ? 'Saving…' : 'Save'}
      </button>
      {msg && <p className="text-sm">{msg}</p>}
    </div>
  );
}
