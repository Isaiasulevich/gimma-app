// Docs has no per-request data, but the (admin) layout above it fetches
// the authed user — so build-time prerender requires Supabase env vars.
// Render dynamically per request to keep the build clean of those deps.
export const dynamic = 'force-dynamic';

export default function DocsPage() {
  return (
    <div className="prose prose-neutral max-w-3xl">
      <h1>How the admin works</h1>
      <p className="lead text-neutral-600">
        A one-page map of every panel in this admin, what it controls, and how it
        flows through the Gimma stack. Read top-to-bottom when onboarding; jump
        to a section when debugging.
      </p>

      <hr />

      <h2 id="overview">Overview</h2>
      <p>
        Gimma has three moving parts: the <strong>Flutter app</strong> (what users
        train with), the <strong>Supabase backend</strong> (Postgres + edge
        functions), and this <strong>admin</strong>. The admin is a thin window
        onto the tables and functions that run the AI side of the app — the
        data it writes takes effect immediately, with no redeploy needed.
      </p>
      <p className="text-sm text-neutral-500">
        Access is gated by <code>users.role = &#39;admin&#39;</code>. Non-admins see a
        &ldquo;Not authorized&rdquo; screen.
      </p>

      <h3>The shape of a plan generation</h3>
      <p>When a user taps <em>Generate plan</em> in the mobile app:</p>
      <ol>
        <li>Flutter → calls the <code>generate-plan</code> edge function with the user&#39;s answers.</li>
        <li>
          The function reads <strong>AI settings</strong> (what provider/model to
          use), loads the <strong>knowledge pack</strong> matching the goal, and
          pulls the user&#39;s recent training context.
        </li>
        <li>It prompts the LLM, validates the returned plan against a schema, and writes
          a <code>plans</code> row plus <code>plan_days</code> + <code>plan_prescriptions</code>.</li>
        <li>Every call — success or failure — lands in <code>ai_calls</code>.</li>
      </ol>
      <p>Each panel below maps to one of those steps.</p>

      <hr />

      <h2 id="ai-settings">
        <span className="rounded bg-neutral-100 px-2 py-1 text-sm font-mono">
          /ai
        </span>{' '}
        AI settings
      </h2>
      <p>
        A single row in the <code>ai_config</code> table (id = <code>&#39;active&#39;</code>).
        Changes take effect on the next edge-function call — no redeploy.
      </p>

      <h3>Provider</h3>
      <p>
        Which LLM vendor to call: Google (Gemini), Anthropic (Claude), or OpenAI
        (GPT). Each requires its API key set as a Supabase function secret:
      </p>
      <pre>
        <code>{`supabase secrets set GOOGLE_GENERATIVE_AI_API_KEY=...
supabase secrets set ANTHROPIC_API_KEY=...
supabase secrets set OPENAI_API_KEY=...`}</code>
      </pre>
      <p className="text-sm text-neutral-500">
        Picking a provider whose secret isn&#39;t set will make every call fail
        until you set it.
      </p>

      <h3>Model ID</h3>
      <p>
        The exact model slug. Must be a model the provider currently serves. If
        the LLM returns &ldquo;model not available&rdquo; the value here is stale —
        update it and save.
      </p>
      <p>Known-good defaults as of launch: <code>gemini-2.5-flash</code>, <code>claude-sonnet-4-5</code>, <code>gpt-4o-mini</code>.</p>

      <h3>Temperature</h3>
      <p>
        0 = deterministic, 2 = wild. For plan generation <code>0.5&ndash;0.8</code>{' '}
        is the reasonable range: low enough the model respects constraints, high
        enough it varies exercise selection across re-generations.
      </p>

      <h3>Max tokens</h3>
      <p>
        Output ceiling. A full 4-day plan with prescriptions and reasoning
        fits comfortably in 4000. Lower caps will truncate and fail schema validation.
      </p>

      <h3>System prompt override</h3>
      <p>
        Leave <strong>blank</strong> to use the shipped prompt in{' '}
        <code>supabase/functions/_shared/system_prompt.ts</code>. Paste a value
        here to override without redeploying — useful for prompt A/B or a quick
        hotfix. Reverting = clearing the field and saving.
      </p>

      <hr />

      <h2 id="packs">
        <span className="rounded bg-neutral-100 px-2 py-1 text-sm font-mono">
          /packs
        </span>{' '}
        Knowledge packs
      </h2>
      <p>
        Packs are goal-scoped domain knowledge the LLM is grounded in. The active
        pack is selected by the user&#39;s goal (e.g. <code>muscle</code> →{' '}
        <code>hypertrophy-v1</code>). Its contents are stuffed into the prompt
        before the user&#39;s question.
      </p>

      <h3>What each field means</h3>
      <dl>
        <dt><strong>Principles (markdown)</strong></dt>
        <dd>The coaching philosophy for this goal — progressive overload rules, volume targets, RIR guidance. The LLM treats this as the <em>why</em>.</dd>

        <dt><strong>Plan templates (JSON)</strong></dt>
        <dd>
          Canonical splits (e.g. full body × 3, upper/lower × 4). Each template
          names the movements expected in each day. The LLM picks a template
          that matches <code>days_per_week</code> and fills prescriptions.
        </dd>

        <dt><strong>Rep range guidance (JSON)</strong></dt>
        <dd>Per-goal rep windows per movement category. Prevents the model from prescribing 3×3 for a goal marked hypertrophy.</dd>

        <dt><strong>Rest guidance (JSON)</strong></dt>
        <dd>Per-movement-type rest seconds. Used for auto-rest timer defaults.</dd>

        <dt><strong>Substitutions (JSON)</strong></dt>
        <dd>
          Equipment-based swaps (e.g. no barbell → goblet squat). If a user has
          restricted equipment, the LLM picks from this list.
        </dd>

        <dt><strong>Red flags (markdown)</strong></dt>
        <dd>Things the model MUST NOT do for this goal. Surfaces as hard constraints in the prompt.</dd>
      </dl>

      <h3>Version field</h3>
      <p>
        Bump it when you meaningfully change pack content. The <code>pack_id</code>{' '}
        + version pair is logged on every <code>ai_calls</code> row, so you can
        later correlate &ldquo;this plan quality dropped&rdquo; with &ldquo;we shipped
        pack v1.3.0 that morning.&rdquo;
      </p>
      <p className="text-sm text-neutral-500">
        The markdown editor stores HTML in v1 (we use Tiptap without a markdown
        extension). For the LLM this is harmless — it reads the HTML fine —
        but if you copy-paste into another tool, expect HTML tags.
      </p>

      <hr />

      <h2 id="logs">
        <span className="rounded bg-neutral-100 px-2 py-1 text-sm font-mono">
          /logs
        </span>{' '}
        AI call logs
      </h2>
      <p>
        Every LLM call — from any edge function — writes a row to{' '}
        <code>ai_calls</code>. Use this panel as your debugger.
      </p>

      <h3>Filter chips</h3>
      <ul>
        <li><strong>plan_gen</strong> — user onboarding or re-generation</li>
        <li><strong>weekly_summary</strong> — the Monday auto-summary for the Coach tab</li>
        <li><strong>review_now</strong> — on-demand Coach summary from the mobile &ldquo;Review now&rdquo; button</li>
        <li><strong>onboarding</strong> — reserved for future onboarding LLM interactions</li>
      </ul>

      <h3>What each row shows</h3>
      <p>
        Kind badge, provider/model, latency, input/output tokens, and timestamp.
        Click to expand: full request body (your prompt + user context) and
        the LLM&#39;s response JSON. Failures are tinted red and the{' '}
        <code>error</code> field is shown above the bodies.
      </p>

      <h3>Typical debug flow</h3>
      <ol>
        <li>User reports &ldquo;generate plan failed.&rdquo;</li>
        <li>Open <code>/logs</code> → filter <code>plan_gen</code> → sort newest first.</li>
        <li>Expand the top row. If the response is <code>null</code>, the error string explains why (bad API key, model retired, schema violation).</li>
        <li>Fix in <code>/ai</code> (settings) or <code>/packs</code> (content) and the next call picks it up.</li>
      </ol>

      <hr />

      <h2 id="test-plan-gen">
        <span className="rounded bg-neutral-100 px-2 py-1 text-sm font-mono">
          /test-plan-gen
        </span>{' '}
        Test plan-gen
      </h2>
      <p>
        Fire the real <code>generate-plan</code> edge function with seed inputs,
        without touching the mobile app. It authenticates as you — so the
        generated plan is saved to <strong>your</strong> user account. Use a
        throwaway admin account if you don&#39;t want test plans on your history.
      </p>
      <p>
        Errors bubble up inline. The raw server error body is shown below the
        generic &ldquo;non-2xx&rdquo; message so you don&#39;t need the Supabase log viewer
        for common failures.
      </p>

      <hr />

      <h2 id="pipeline">How a plan generation flows end-to-end</h2>
      <ol>
        <li>
          <strong>Flutter (mobile):</strong>{' '}
          <code>PlanApi.generatePlan(...)</code> calls{' '}
          <code>supabase.functions.invoke(&#39;generate-plan&#39;, body)</code>.
        </li>
        <li>
          <strong>Edge function:</strong>{' '}
          <code>loadAiConfig()</code> → <code>loadPack(goal)</code> →{' '}
          <code>buildUserContext(userId)</code> →{' '}
          <code>resolveModel(provider, model)</code> → <code>generateObject()</code>.
        </li>
        <li>
          <strong>Schema validation:</strong> the response is parsed against{' '}
          <code>PlanSchema</code> (Zod). If the model invents an{' '}
          <code>exercise_id</code> not in the user&#39;s visible library, the
          request returns 422 and no plan is saved.
        </li>
        <li>
          <strong>Persistence:</strong> prior active plan is deactivated →{' '}
          <code>plans</code> row created with <code>is_active = true</code> →{' '}
          <code>plan_days</code> + <code>plan_prescriptions</code> inserted.
        </li>
        <li>
          <strong>Logging:</strong> <code>ai_calls</code> row with provider,
          model, tokens, cost estimate, latency, and full bodies.
        </li>
        <li>
          <strong>Flutter pulls:</strong> the mobile app&#39;s{' '}
          <code>Hydrator</code> sees the new active plan on next sync and
          renders it in the Train tab.
        </li>
      </ol>

      <hr />

      <h2 id="secrets">Secrets you control (outside this admin)</h2>
      <p>Set via <code>supabase secrets set KEY=value</code> then redeploy functions:</p>
      <ul>
        <li><code>GOOGLE_GENERATIVE_AI_API_KEY</code> — Gemini</li>
        <li><code>ANTHROPIC_API_KEY</code> — Claude</li>
        <li><code>OPENAI_API_KEY</code> — GPT</li>
        <li><code>SENTRY_DSN_EDGE</code> — optional error capture in edge functions</li>
      </ul>
      <p>
        These are <em>never</em> editable from this admin — they live on
        Supabase. The admin only edits data.
      </p>

      <hr />

      <h2 id="gotchas">Common gotchas</h2>
      <ul>
        <li>
          <strong>&ldquo;Model not available&rdquo;</strong> — provider retired the
          slug. Update Model ID in <code>/ai</code>. Pricing for costs lives in{' '}
          <code>_shared/pricing.ts</code> and needs a matching key for the new
          model or <code>cost_usd</code> stays null (functional impact: none;
          reporting impact: no cost column).
        </li>
        <li>
          <strong>&ldquo;AI referenced unknown exercise_id&rdquo;</strong> — LLM
          hallucinated an ID not in the user&#39;s library. Usually means the
          prompt context is too long and the exercise list got truncated. Drop
          <code>max_tokens</code> or tighten the pack.
        </li>
        <li>
          <strong>Schema validation fails silently</strong> — bump{' '}
          <code>max_tokens</code>. Responses are truncated if the cap is hit
          mid-JSON.
        </li>
        <li>
          <strong>Monday auto-summary didn&#39;t run</strong> — check{' '}
          <code>cron.job</code> in Postgres: if <code>jobname</code>{' '}
          <code>weekly_summary</code> is missing, the cron migration never
          applied. <code>supabase db push</code> it.
        </li>
      </ul>
    </div>
  );
}
