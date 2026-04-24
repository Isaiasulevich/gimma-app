'use client';
import Editor from '@monaco-editor/react';

export function JsonEditor({ value, onChange }: { value: unknown; onChange: (v: unknown) => void }) {
  return (
    <div className="rounded border">
      <Editor
        height="240px"
        defaultLanguage="json"
        value={JSON.stringify(value, null, 2)}
        onChange={(v) => {
          try {
            onChange(v ? JSON.parse(v) : null);
          } catch {
            // ignore invalid JSON while typing
          }
        }}
        options={{ minimap: { enabled: false }, fontSize: 12 }}
      />
    </div>
  );
}
