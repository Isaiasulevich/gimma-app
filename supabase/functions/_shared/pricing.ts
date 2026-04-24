const PRICING: Record<string, { input: number; output: number }> = {
  'google:gemini-2.0-flash': { input: 0.075, output: 0.30 },
  'google:gemini-2.0-pro':   { input: 1.25,  output: 5.00 },
  'anthropic:claude-opus-4-5':   { input: 3.00,  output: 15.00 },
  'anthropic:claude-sonnet-4-5': { input: 3.00,  output: 15.00 },
  'openai:gpt-4o':           { input: 2.50,  output: 10.00 },
  'openai:gpt-4o-mini':      { input: 0.15,  output: 0.60 },
};

export function estimateCostUsd(
  provider: string,
  model: string,
  inputTokens?: number | null,
  outputTokens?: number | null,
): number | null {
  const key = `${provider}:${model}`;
  const p = PRICING[key];
  if (!p) return null;
  const inputCost = ((inputTokens ?? 0) / 1_000_000) * p.input;
  const outputCost = ((outputTokens ?? 0) / 1_000_000) * p.output;
  return +(inputCost + outputCost).toFixed(6);
}
