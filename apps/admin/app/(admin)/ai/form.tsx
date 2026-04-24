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

type ModelOption = { id: string; label: string; hint: string };

// Curated per-provider model options. The `*-latest` aliases are listed
// first because they survive model rotations (e.g. when Google retires a
// specific dated version). Pricing is per 1M tokens as of 2026-04 — check
// pricing.ts for the cost_usd calculator and update both when rotating.
const MODELS_BY_PROVIDER: Record<string, ModelOption[]> = {
  google: [
    { id: 'gemini-flash-latest', label: 'Gemini Flash (latest)', hint: 'Always current · cheap + fast · recommended' },
    { id: 'gemini-2.5-flash', label: 'Gemini 2.5 Flash', hint: '~$0.08/M in · $0.30/M out' },
    { id: 'gemini-2.5-flash-lite', label: 'Gemini 2.5 Flash Lite', hint: 'Cheapest Gemini · lower quality' },
    { id: 'gemini-2.5-pro', label: 'Gemini 2.5 Pro', hint: '~$1.25/M in · $5/M out · smartest Gemini' },
  ],
  anthropic: [
    { id: 'claude-haiku-4-5', label: 'Claude Haiku 4.5', hint: 'Fast + cheap Claude' },
    { id: 'claude-sonnet-4-5', label: 'Claude Sonnet 4.5', hint: 'Balanced' },
    { id: 'claude-opus-4-5', label: 'Claude Opus 4.5', hint: 'Smartest Claude · expensive' },
  ],
  openai: [
    { id: 'gpt-4o-mini', label: 'GPT-4o mini', hint: 'Cheap + fast OpenAI' },
    { id: 'gpt-4o', label: 'GPT-4o', hint: 'Balanced' },
  ],
};

export function AiConfigForm({ initial }: { initial: AiConfig }) {
  const [provider, setProvider] = useState(initial.active_provider);
  const [model, setModel] = useState(initial.active_model);
  const [overridePrompt, setOverridePrompt] = useState<string>(initial.system_prompt_override ?? '');
  const [temperature, setTemperature] = useState<number>(initial.temperature);
  const [maxTokens, setMaxTokens] = useState<number>(initial.max_tokens);
  const [saving, setSaving] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);

  const options = MODELS_BY_PROVIDER[provider] ?? [];
  const modelInList = options.some((m) => m.id === model);
  const useCustom = !modelInList && model !== '__custom__';
  const [customMode, setCustomMode] = useState(useCustom);

  function onProviderChange(next: string) {
    setProvider(next);
    // Jump to the top (recommended) model for the new provider so we don't
    // save a Google model under an Anthropic provider.
    const first = MODELS_BY_PROVIDER[next]?.[0];
    if (first) {
      setModel(first.id);
      setCustomMode(false);
    }
  }

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
        <select
          className="w-full rounded border p-2"
          value={provider}
          onChange={(e) => onProviderChange(e.target.value)}
        >
          <option value="google">Google (Gemini)</option>
          <option value="anthropic">Anthropic (Claude)</option>
          <option value="openai">OpenAI (GPT)</option>
        </select>
      </div>

      <div>
        <label className="mb-1 block text-sm font-medium">Model</label>
        {!customMode ? (
          <>
            <select
              className="w-full rounded border p-2"
              value={modelInList ? model : ''}
              onChange={(e) => {
                if (e.target.value === '__custom__') {
                  setCustomMode(true);
                } else {
                  setModel(e.target.value);
                }
              }}
            >
              {!modelInList && (
                <option value="" disabled>
                  {model} (not in list — switch to custom)
                </option>
              )}
              {options.map((o) => (
                <option key={o.id} value={o.id}>
                  {o.label} — {o.hint}
                </option>
              ))}
              <option value="__custom__">Custom…</option>
            </select>
            <p className="mt-1 text-xs text-neutral-500">
              Saving an ID the provider doesn&#39;t serve returns a runtime error —
              check <a className="underline" href="/logs">/logs</a> if generation fails.
            </p>
          </>
        ) : (
          <div className="flex gap-2">
            <input
              className="flex-1 rounded border p-2 font-mono text-sm"
              value={model}
              onChange={(e) => setModel(e.target.value)}
              placeholder="e.g. gemini-2.5-flash-preview-05-20"
            />
            <button
              type="button"
              className="rounded border px-3 py-2 text-sm hover:bg-neutral-50"
              onClick={() => {
                setCustomMode(false);
                const first = options[0];
                if (first) setModel(first.id);
              }}
            >
              Back to list
            </button>
          </div>
        )}
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
