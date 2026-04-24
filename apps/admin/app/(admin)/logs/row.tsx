'use client';
import { useState } from 'react';

type CallRow = {
  id: string;
  kind: string;
  provider: string;
  model: string;
  latency_ms: number | null;
  input_tokens: number | null;
  output_tokens: number | null;
  created_at: string;
  error: string | null;
  request_body: unknown;
  response_body: unknown;
};

export function LogRow({ row }: { row: CallRow }) {
  const [open, setOpen] = useState(false);
  return (
    <div className="rounded border">
      <button onClick={() => setOpen((o) => !o)} className="flex w-full items-center justify-between p-3 text-left hover:bg-neutral-50">
        <div className="flex items-center gap-3 text-sm">
          <span className={`rounded px-2 py-0.5 text-xs ${row.error ? 'bg-red-100 text-red-800' : 'bg-neutral-100'}`}>{row.kind}</span>
          <span>{row.provider} / {row.model}</span>
          <span className="text-neutral-500">{row.latency_ms}ms</span>
          <span className="text-neutral-500">in:{row.input_tokens ?? '-'} out:{row.output_tokens ?? '-'}</span>
        </div>
        <span className="text-xs text-neutral-500">{new Date(row.created_at).toLocaleString()}</span>
      </button>
      {open && (
        <div className="border-t bg-neutral-50 p-3 font-mono text-xs">
          {row.error && <div className="mb-3 text-red-700">Error: {row.error}</div>}
          <div className="mb-2 font-semibold">Request</div>
          <pre className="max-h-80 overflow-auto whitespace-pre-wrap">{JSON.stringify(row.request_body, null, 2)}</pre>
          <div className="mb-2 mt-4 font-semibold">Response</div>
          <pre className="max-h-80 overflow-auto whitespace-pre-wrap">{JSON.stringify(row.response_body, null, 2)}</pre>
        </div>
      )}
    </div>
  );
}
