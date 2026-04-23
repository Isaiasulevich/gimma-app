import { google } from '@ai-sdk/google';
import { anthropic } from '@ai-sdk/anthropic';
import { openai } from '@ai-sdk/openai';
import type { LanguageModel } from 'ai';

export type Provider = 'google' | 'anthropic' | 'openai';

export function resolveModel(provider: Provider, model: string): LanguageModel {
  switch (provider) {
    case 'google':
      return google(model);
    case 'anthropic':
      return anthropic(model);
    case 'openai':
      return openai(model);
    default: {
      const exhaustive: never = provider;
      throw new Error(`Unknown provider: ${exhaustive}`);
    }
  }
}
