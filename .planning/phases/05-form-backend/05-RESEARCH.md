# Phase 5: Form Backend - Research

**Researched:** 2026-02-22
**Domain:** Resend SDK + Cloudflare Turnstile + Contact Form fetch integration
**Confidence:** HIGH

## Summary

Phase 5 wires the existing ContactForm.astro (which already has validation, loading state UI, and a thank-you animation) to actually send email through the Worker, adds Cloudflare Turnstile for spam protection, and replaces the current simulated delay with real API response handling.

The three technical domains are: (1) installing and calling the `resend` npm SDK in `src/worker/index.ts`; (2) adding Cloudflare Turnstile to the form (client-side widget + server-side siteverify verification in the Worker); and (3) updating the ContactForm.astro submit handler to do a real `fetch` to `/api/contact`, handle 2xx vs error responses, enforce a minimum loading time, and preserve user input on error.

The Resend SDK pattern is well-established: `npm install resend`, instantiate with `env.RESEND_API_KEY` (already stored as a Wrangler secret from Phase 4, and the actual key is already in `.dev.vars`), call `resend.emails.send({ from, to, subject, html })` with an HTML string body, and check the `{ data, error }` return. Turnstile follows a two-step pattern: a `<div class="cf-turnstile">` widget in the form with a `PUBLIC_TURNSTILE_SITE_KEY` env variable injected at Astro build time, plus a Worker-side call to `https://challenges.cloudflare.com/turnstile/v0/siteverify` using a `TURNSTILE_SECRET_KEY` Wrangler secret.

**Primary recommendation:** Install `resend` npm package, add Turnstile as an additional Wrangler secret (`TURNSTILE_SECRET_KEY`), expose the site key as `PUBLIC_TURNSTILE_SITE_KEY` in `.env` and Cloudflare Pages/Workers env vars, and update the Worker handler to (a) verify Turnstile before (b) sending email via Resend.

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- Single hardcoded recipient address, configured as an environment variable
- Reply-to is NOT set to the submitter's email — their email appears in the email body only
- Subject line format: "Demo Request from [Name]"
- Email body is formatted HTML (styled with sections, brand colors, clean layout)
- Body includes all submitted fields: name, email, organization, event type, message
- On Worker error, show generic user-friendly message: "Something went wrong. Please try again."
- Same generic message for network errors, timeouts, and server errors — no distinction
- Error appears in the existing top-of-form error summary banner, scrolled into view
- Include a "Try Again" retry button that resubmits the same form data
- User's input is preserved on error (never cleared)
- Minimum loading time of ~800ms-1s even if API responds instantly (prevent jarring flash)
- Keep the existing thank-you animation (fade out form, fade in checkmark + message)
- Change follow-up promise to vaguer wording: "We'll be in touch soon" (no specific timeframe)
- One submission is enough — thank-you screen shows only "Back to Home" link, no re-submit option
- Cloudflare Turnstile in managed mode (invisible for most users, challenge only if suspicious)
- Turnstile token verified server-side in the Worker before sending email
- If Turnstile verification fails, block submission with error message: "Verification failed. Please try again."
- No additional rate limiting — Turnstile is sufficient for a low-traffic marketing form

### Claude's Discretion

- HTML email template design and exact styling
- Turnstile widget placement in the form layout
- Exact retry button styling and placement
- Request timeout duration
- Worker error response format and status codes

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| FORM-01 | Contact form submissions are delivered via email to a single configurable recipient | Resend SDK `resend.emails.send()` called from Worker using `env.RESEND_API_KEY` (already stored) and `env.RECIPIENT_EMAIL` (new env var); `from: "contact@rallytrivia.com"` (verified domain) |
| FORM-03 | Form UI shows loading state during submission and success/error state after | Existing ContactForm.astro loading state + thank-you animation already built; need to: replace simulated delay with real `fetch('/api/contact')`, gate thank-you on 2xx response, add error state to existing error summary banner, add retry button |
</phase_requirements>

---

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| resend | ^4.x (latest at install time) | Send email via Resend API from Worker | Official Resend SDK; works in Cloudflare Workers edge runtime; HTML string body supported without React |
| Cloudflare Turnstile | N/A (CDN script) | Spam/bot protection on contact form | Native Cloudflare product; free; managed mode is invisible to real users; server-side verification built into Cloudflare infra |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| No additional libraries needed | — | — | All other dependencies (motion, Tailwind, Astro) are already installed |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Resend SDK (`resend` npm) | Raw `fetch` to Resend REST API | SDK handles error normalization, TypeScript types, and retry logic — worth the install for a production integration |
| Cloudflare Turnstile | hCaptcha, reCAPTCHA | Turnstile is free, no user friction in managed mode, native to this project's Cloudflare infrastructure |
| HTML string email body | React Email + `@react-email/render` | React Email requires `.tsx` worker entry and adds complexity; HTML string is simpler and fully sufficient here |

**Installation:**
```bash
npm install resend
```

---

## Architecture Patterns

### Recommended Project Structure

No new directories needed. Changes are:

```
src/
├── worker/
│   └── index.ts        # Update: replace stub with real Resend + Turnstile logic
├── components/
│   └── ContactForm.astro  # Update: replace simulated delay with real fetch + error/success handling
.env                    # Add: PUBLIC_TURNSTILE_SITE_KEY (build-time; committed — not a secret)
.dev.vars               # Add: TURNSTILE_SECRET_KEY=... and RECIPIENT_EMAIL=... (already has RESEND_API_KEY)
```

### Pattern 1: Resend SDK in Cloudflare Worker

**What:** Import `Resend` class from the `resend` package, instantiate with the env API key, call `emails.send()` with HTML body.

**When to use:** Any Worker that needs to send transactional email.

**Example:**
```typescript
// Source: https://developers.cloudflare.com/workers/tutorials/send-emails-with-resend/
import { Resend } from 'resend';

// In the Worker fetch handler:
const resend = new Resend(env.RESEND_API_KEY);

const { data, error } = await resend.emails.send({
  from: 'Rally Trivia <contact@rallytrivia.com>',
  to: [env.RECIPIENT_EMAIL],
  subject: `Demo Request from ${name}`,
  html: buildEmailHtml({ name, email, organization, eventType, message }),
});

if (error) {
  return Response.json({ ok: false, message: 'Failed to send email' }, { status: 500 });
}

return Response.json({ ok: true });
```

**Key point:** `resend.emails.send()` returns `{ data, error }`. If `error` is non-null, the send failed. Always check `error` before treating the response as a success. No try/catch needed for the API call itself (SDK normalizes errors into the `error` return value), but wrap in try/catch at the handler level for unexpected runtime errors.

### Pattern 2: Cloudflare Turnstile — Client-Side Widget (Astro)

**What:** Add the Turnstile script tag and widget div to the form component. The widget automatically injects a hidden `cf-turnstile-response` input field with the token when verification completes.

**Key constraint for Astro static site:** The site key is a PUBLIC variable (not a secret). It is embedded at build time using Astro's `PUBLIC_` prefix convention. It does NOT need to be passed through the Worker runtime.

**How sitekey is accessed in Astro component:**
```astro
---
// In ContactForm.astro frontmatter — available at build time for static output
const siteKey = import.meta.env.PUBLIC_TURNSTILE_SITE_KEY;
---
```

**Widget placement in form:**
```html
<!-- Load Turnstile script in <head> or at end of body -->
<script src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer is:inline></script>

<!-- In the form, just above the submit button -->
<div class="cf-turnstile" data-sitekey={siteKey}></div>
```

**How token is extracted in submit handler:**
```typescript
// The Turnstile widget auto-injects a hidden input named "cf-turnstile-response"
// Read it from the form data before sending to the Worker
const formData = new FormData(form);
const turnstileToken = formData.get('cf-turnstile-response') as string;

// Include in the JSON body sent to the Worker
const body = {
  name: formData.get('name'),
  email: formData.get('email'),
  // ...other fields
  turnstileToken,
};
```

**Note on `is:inline`:** The Turnstile CDN script should use `is:inline` to prevent Astro from processing it. This is the standard Astro pattern for third-party scripts that must load from an external CDN.

### Pattern 3: Cloudflare Turnstile — Server-Side Verification in Worker

**What:** Verify the Turnstile token against the siteverify API before sending email. Uses `TURNSTILE_SECRET_KEY` stored as a Wrangler secret.

**Example:**
```typescript
// Source: https://developers.cloudflare.com/turnstile/get-started/server-side-validation/
async function verifyTurnstile(token: string, secretKey: string): Promise<boolean> {
  const formData = new FormData();
  formData.append('secret', secretKey);
  formData.append('response', token);

  const result = await fetch(
    'https://challenges.cloudflare.com/turnstile/v0/siteverify',
    { method: 'POST', body: formData }
  );

  const outcome = await result.json() as { success: boolean; 'error-codes': string[] };
  return outcome.success;
}
```

**In Worker handler (before email send):**
```typescript
const isHuman = await verifyTurnstile(body.turnstileToken, env.TURNSTILE_SECRET_KEY);
if (!isHuman) {
  return Response.json(
    { ok: false, message: 'Verification failed. Please try again.' },
    { status: 400 }
  );
}
```

**Important:** Each token can only be validated once (tokens expire after 300 seconds). Retry on the client must obtain a fresh token.

### Pattern 4: Worker Env Interface Update

**What:** Add new binding declarations to the Env interface in `src/worker/index.ts`.

**Example:**
```typescript
interface Env {
  ASSETS: Fetcher;
  RESEND_API_KEY: string;       // Already declared; stored as Wrangler secret (Phase 4 complete)
  TURNSTILE_SECRET_KEY: string; // New: stored as Wrangler secret
  RECIPIENT_EMAIL: string;      // New: stored as Wrangler secret or env var
}
```

**Note:** `RECIPIENT_EMAIL` can be a regular Cloudflare Workers environment variable (not a secret) since it is not sensitive. However, storing it as a secret is also fine. In `.dev.vars`, add both `TURNSTILE_SECRET_KEY` and `RECIPIENT_EMAIL`.

### Pattern 5: Form Submit Handler — Real Fetch with Minimum Loading Time

**What:** Replace the simulated `setTimeout` with a real `fetch('/api/contact')` combined with a `Promise.all` minimum delay.

**Example:**
```typescript
// Replace simulated delay pattern:
// await new Promise((resolve) => setTimeout(resolve, 1500));

// With real fetch + minimum loading time:
const MIN_LOADING_MS = 900;

const [response] = await Promise.all([
  fetch('/api/contact', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      name: formData.get('name'),
      email: formData.get('email'),
      organization: formData.get('organization'),
      eventType: formData.get('event-type'),
      message: formData.get('message'),
      turnstileToken: formData.get('cf-turnstile-response'),
    }),
  }),
  new Promise((resolve) => setTimeout(resolve, MIN_LOADING_MS)),
]);

if (!response.ok) {
  // Show error state — do NOT clear form inputs
  showError('Something went wrong. Please try again.');
  return;
}

const result = await response.json() as { ok: boolean; message?: string };
if (!result.ok) {
  showError(result.message || 'Something went wrong. Please try again.');
  return;
}

// Only reach here on confirmed 2xx success
showThankYou();
```

**Key pattern:** `Promise.all([fetch(...), delay(...)])` ensures the minimum display time even if the API responds faster, preventing jarring flash.

### Pattern 6: Local Development — CORS Handling

**What:** During local development, Astro runs on `localhost:4321` and `wrangler dev` runs on `localhost:8787`. The form fetch must target `localhost:8787` explicitly, or CORS headers must be added to the Worker for development.

**Recommendation:** Use a CORS header in the Worker for `localhost:4321` during dev. In production (same domain), CORS is not needed.

**Worker CORS handling:**
```typescript
const CORS_HEADERS = {
  'Access-Control-Allow-Origin': 'http://localhost:4321',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

// Handle preflight
if (request.method === 'OPTIONS') {
  return new Response(null, { status: 204, headers: CORS_HEADERS });
}

// Add to success/error responses during dev — or conditionally based on origin
```

**Alternative approach (simpler for dev):** In ContactForm.astro, detect dev mode and point the fetch at the wrangler dev URL. But this leaks dev-specific code into the component. The CORS header approach is cleaner.

**Note:** This is Claude's discretion per CONTEXT.md. The recommended approach is to add CORS headers to the Worker for the `localhost:4321` origin only, controlled by a conditional check on the `Origin` header or the `env` environment (though env variables can't easily distinguish dev vs prod in this setup). Simplest pragmatic approach: always allow `localhost:4321` in the CORS header — it has no production impact since browsers only send the `Origin` header cross-origin.

### Pattern 7: Turnstile Widget Reset on Error

**What:** After a failed submission, Turnstile tokens are single-use (300s expiry + consumed on verification). The widget must be reset to generate a new token before the user can retry.

**Example:**
```typescript
// After showing error, reset Turnstile widget so user can get a fresh token
if (window.turnstile) {
  window.turnstile.reset();
}
```

**TypeScript declaration needed:**
```typescript
declare global {
  interface Window {
    turnstile?: {
      reset: () => void;
      render: (container: string | Element, options: object) => string;
    };
  }
}
```

### Anti-Patterns to Avoid

- **Showing thank-you before API response:** Current code shows thank-you after a simulated delay regardless of outcome. Phase 5 MUST gate the thank-you animation on a confirmed 2xx response.
- **Clearing form inputs on error:** User's input must be preserved. Do not call `form.reset()` on error.
- **Not resetting Turnstile on error:** A consumed or expired token will cause all retry attempts to fail. Always call `turnstile.reset()` before allowing retry.
- **Putting sitekey in Worker env:** The site key is public and needed at build time for Astro static output. It belongs in `.env` as `PUBLIC_TURNSTILE_SITE_KEY`, not in Wrangler secrets.
- **Putting secret key in Astro env:** `TURNSTILE_SECRET_KEY` must ONLY be in the Worker via Wrangler secrets. Never expose it client-side.
- **React Email dependency:** No need for `@react-email/render`. The `html` parameter on `resend.emails.send()` accepts a plain HTML string. Building the HTML template as a TypeScript function is sufficient and avoids JSX setup complexity in the Worker.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Email delivery | Custom SMTP or MailChannels integration | `resend` npm SDK | SDK handles auth, error normalization, TypeScript types; already set up in Phase 4 |
| Bot/spam protection | IP-based rate limiting, honeypot fields | Cloudflare Turnstile (managed mode) | Turnstile is free, low-friction, server-verified; CONTEXT.md locked this decision |
| Minimum loading delay + real fetch | Complex state machine | `Promise.all([fetch(...), delay(...)])` | Single line; handles both timing and actual response correctly |

**Key insight:** The Turnstile token is single-use. Never attempt to cache or reuse a token across multiple verification calls. Always reset the widget after a failed submission.

---

## Common Pitfalls

### Pitfall 1: Thank-You Fires Before API Response

**What goes wrong:** The current ContactForm.astro shows the thank-you animation after a simulated delay regardless of the API response. If Phase 5 simply replaces the delay with a real fetch but keeps the unconditional transition, users see success even on failure.

**Why it happens:** Current code structure: `await delay → show thank-you`. Phase 5 must change this to: `await fetch → check response → show thank-you OR show error`.

**How to avoid:** Restructure the submit handler so the transition to thank-you only occurs in the success branch of the response check. The error branch shows the error banner and preserves form state.

**Warning signs:** Submitting with a wrong API key or intentionally broken Worker still shows the checkmark/thank-you screen.

### Pitfall 2: Turnstile Token Already Spent on Retry

**What goes wrong:** User hits submit, gets an error (Worker returns 500), clicks "Try Again" — but Turnstile still has the same token from the previous attempt. The Worker verifies it: `{ success: false, error-codes: ['timeout-or-duplicate'] }`. Every retry fails.

**Why it happens:** Turnstile tokens are single-use. Once consumed (or after 300s), the siteverify API rejects them.

**How to avoid:** In the error handler in ContactForm.astro, always call `window.turnstile.reset()` to generate a fresh token before the retry is attempted.

**Warning signs:** First submission fails with a Worker error, retry always returns "Verification failed" even with correct form data.

### Pitfall 3: PUBLIC_ Prefix Missing on Sitekey

**What goes wrong:** `import.meta.env.TURNSTILE_SITE_KEY` is `undefined` in the rendered HTML because Astro only exposes `PUBLIC_` prefixed variables to client-side code (and to Astro component frontmatter in static mode, they are still inlined at build time).

**Why it happens:** Astro follows Vite's convention: only `PUBLIC_` prefixed env vars are safe to include in the bundle. Non-public vars are server/build-time only and may not be correctly inlined into the generated HTML attribute.

**How to avoid:** Use `PUBLIC_TURNSTILE_SITE_KEY` in `.env` and reference as `import.meta.env.PUBLIC_TURNSTILE_SITE_KEY`. The Turnstile site key is NOT sensitive (it is visible in all page source), so `PUBLIC_` is appropriate.

**Warning signs:** Turnstile widget fails to render or renders without a proper sitekey; browser console shows Turnstile error about invalid sitekey.

### Pitfall 4: Worker Receives Turnstile Token Before Widget Completes

**What goes wrong:** In managed mode, Turnstile sometimes runs a brief challenge. If the user submits the form before Turnstile finishes verifying (the hidden `cf-turnstile-response` input is still empty), the Worker receives an empty token and `siteverify` returns `success: false`.

**Why it happens:** Turnstile's managed mode is asynchronous — it signals completion via the hidden input field being populated. If the form submit fires before the widget is done, the token is empty.

**How to avoid:** Check that `cf-turnstile-response` is non-empty before submitting. If empty, show a brief message asking the user to wait and retry. Or use Turnstile's explicit rendering with a `callback` option that enables the submit button only after verification completes.

**Warning signs:** Random form failures where the error is "Verification failed" even on the first attempt by a legitimate user, especially on slow connections.

### Pitfall 5: CORS Missing for Local Dev

**What goes wrong:** In local development, the form page is at `localhost:4321` (Astro dev server) and the Worker is at `localhost:8787` (wrangler dev). The `fetch('/api/contact')` call fails silently or with a CORS error because the Worker doesn't include CORS headers for cross-origin dev requests.

**Why it happens:** Browsers enforce same-origin policy. In production, the form and Worker are on the same domain, so no CORS is needed. But during dev, the ports differ.

**How to avoid:** Add CORS headers to the Worker response for `localhost:4321`. Alternatively, change the dev fetch URL to use the absolute wrangler dev URL — but this requires environment-aware URL detection in the Astro component.

**Warning signs:** Form submission silently fails in local dev; browser console shows `CORS policy` or `blocked by CORS policy` error.

### Pitfall 6: Resend `from` Field Doesn't Match Verified Domain

**What goes wrong:** Worker calls `resend.emails.send()` with a `from` address on a domain other than `rallytrivia.com`, causing Resend to reject the send.

**Why it happens:** Only domains verified in Resend can be used as the `from` sender. `rallytrivia.com` was verified in Phase 4 with the From address `contact@rallytrivia.com`.

**How to avoid:** Hardcode `from: 'Rally Trivia <contact@rallytrivia.com>'` in the Worker. Do not make the `from` address configurable.

**Warning signs:** `resend.emails.send()` returns `error` with a message about domain verification or invalid from address.

---

## Code Examples

Verified patterns from official sources:

### Complete Worker Handler (src/worker/index.ts)

```typescript
// Source: https://developers.cloudflare.com/workers/tutorials/send-emails-with-resend/
// Source: https://developers.cloudflare.com/turnstile/get-started/server-side-validation/
import { Resend } from 'resend';

interface Env {
  ASSETS: Fetcher;
  RESEND_API_KEY: string;
  TURNSTILE_SECRET_KEY: string;
  RECIPIENT_EMAIL: string;
}

interface ContactPayload {
  name: string;
  email: string;
  organization?: string;
  eventType?: string;
  message?: string;
  turnstileToken: string;
}

function buildEmailHtml(payload: ContactPayload): string {
  return `
    <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto;">
      <h1 style="color: #1e3a5f;">New Demo Request</h1>
      <table style="width: 100%; border-collapse: collapse;">
        <tr><td style="padding: 8px; font-weight: bold;">Name</td><td style="padding: 8px;">${payload.name}</td></tr>
        <tr><td style="padding: 8px; font-weight: bold;">Email</td><td style="padding: 8px;">${payload.email}</td></tr>
        <tr><td style="padding: 8px; font-weight: bold;">Organization</td><td style="padding: 8px;">${payload.organization || '—'}</td></tr>
        <tr><td style="padding: 8px; font-weight: bold;">Event Type</td><td style="padding: 8px;">${payload.eventType || '—'}</td></tr>
        <tr><td style="padding: 8px; font-weight: bold;">Message</td><td style="padding: 8px;">${payload.message || '—'}</td></tr>
      </table>
    </div>
  `;
}

async function verifyTurnstile(token: string, secretKey: string): Promise<boolean> {
  const formData = new FormData();
  formData.append('secret', secretKey);
  formData.append('response', token);
  const result = await fetch('https://challenges.cloudflare.com/turnstile/v0/siteverify', {
    method: 'POST',
    body: formData,
  });
  const outcome = await result.json() as { success: boolean };
  return outcome.success;
}

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);

    // CORS for local dev (same-origin in production)
    const corsHeaders = {
      'Access-Control-Allow-Origin': 'http://localhost:4321',
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    };

    if (url.pathname === '/api/contact' && request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: corsHeaders });
    }

    if (url.pathname === '/api/contact' && request.method === 'POST') {
      try {
        const payload = await request.json() as ContactPayload;

        // 1. Verify Turnstile
        const isHuman = await verifyTurnstile(payload.turnstileToken, env.TURNSTILE_SECRET_KEY);
        if (!isHuman) {
          return Response.json(
            { ok: false, message: 'Verification failed. Please try again.' },
            { status: 400, headers: corsHeaders }
          );
        }

        // 2. Send email via Resend
        const resend = new Resend(env.RESEND_API_KEY);
        const { error } = await resend.emails.send({
          from: 'Rally Trivia <contact@rallytrivia.com>',
          to: [env.RECIPIENT_EMAIL],
          subject: `Demo Request from ${payload.name}`,
          html: buildEmailHtml(payload),
        });

        if (error) {
          return Response.json(
            { ok: false, message: 'Something went wrong. Please try again.' },
            { status: 500, headers: corsHeaders }
          );
        }

        return Response.json({ ok: true }, { headers: corsHeaders });
      } catch {
        return Response.json(
          { ok: false, message: 'Something went wrong. Please try again.' },
          { status: 500, headers: corsHeaders }
        );
      }
    }

    if (url.pathname === '/api/contact') {
      return Response.json(
        { ok: false, message: 'Method not allowed' },
        { status: 405 }
      );
    }

    if (url.pathname.startsWith('/api/')) {
      return Response.json({ ok: false, message: 'Not found' }, { status: 404 });
    }

    return env.ASSETS.fetch(request);
  },
} satisfies ExportedHandler<Env>;
```

### Turnstile Widget in ContactForm.astro (frontmatter + HTML)

```astro
---
// Build-time: PUBLIC_ prefix makes this available in static output
const turnstileSiteKey = import.meta.env.PUBLIC_TURNSTILE_SITE_KEY;
---

<!-- In <head> or layout -->
<script src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer is:inline></script>

<!-- In the form, just above submit button -->
<div class="cf-turnstile mb-4" data-sitekey={turnstileSiteKey}></div>
```

### Form Submit Handler Updates (in ContactForm.astro `<script>`)

```typescript
// Replace the simulated delay section with:
const MIN_LOADING_MS = 900;

// Collect form data INCLUDING the Turnstile token
const formData = new FormData(form);

const [response] = await Promise.all([
  fetch('/api/contact', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      name: formData.get('name'),
      email: formData.get('email'),
      organization: formData.get('organization'),
      eventType: formData.get('event-type'),
      message: formData.get('message'),
      turnstileToken: formData.get('cf-turnstile-response'),
    }),
  }),
  new Promise<void>((resolve) => setTimeout(resolve, MIN_LOADING_MS)),
]);

// Parse response
let result: { ok: boolean; message?: string };
try {
  result = await response.json();
} catch {
  result = { ok: false, message: 'Something went wrong. Please try again.' };
}

if (!result.ok) {
  // Show error state — do NOT clear form inputs
  // Reset loading state
  btn.disabled = false;
  btnText.classList.remove('hidden');
  btnSpinner.classList.add('hidden');

  // Show error banner
  errorList.innerHTML = `<li>${result.message || 'Something went wrong. Please try again.'}</li>`;
  errorSummary.classList.remove('hidden');
  errorSummary.scrollIntoView({ behavior: 'smooth', block: 'center' });

  // Reset Turnstile so user can get a fresh token for retry
  if (window.turnstile) {
    window.turnstile.reset();
  }
  return;
}

// SUCCESS: Animate transition (existing code)
const { animate } = await import('motion');
const formWrapper = form.parentElement!;
await animate(formWrapper, { opacity: [1, 0] }, { duration: 0.3 }).finished;

form.classList.add('hidden');
document.getElementById('error-summary')!.classList.add('hidden');
thankYou.classList.remove('hidden');
window.scrollTo({ top: 0, behavior: 'smooth' });
animate(thankYou, { opacity: [0, 1], y: [20, 0] }, { duration: 0.5 });
```

### .env File (for build-time public variables)

```bash
# Public — safe to commit (sitekey is visible in page source anyway)
PUBLIC_TURNSTILE_SITE_KEY=your_turnstile_site_key_here
```

### .dev.vars Updates (local development secrets)

```bash
# Existing
RESEND_API_KEY=re_eUvahoiK_4KLbWEtdq9NkT21a5npBkFGf

# New for Phase 5
TURNSTILE_SECRET_KEY=1x0000000000000000000000000000000AA  # test key for local dev
RECIPIENT_EMAIL=contact@rallytrivia.com
```

### Turnstile Test Keys (development)

| Key Type | Value | Behavior |
|----------|-------|----------|
| Sitekey (always passes, managed) | `1x00000000000000000000AA` | Widget renders, passes without challenge |
| Secret Key (always passes) | `1x0000000000000000000000000000000AA` | siteverify returns `{ success: true }` |
| Secret Key (always fails) | `2x0000000000000000000000000000000AA` | siteverify returns `{ success: false }` |

Use the "always passes" keys in `.dev.vars` during development. In production, use the real keys from the Cloudflare dashboard.

### Wrangler Secrets to Set for Production

```bash
# Already set in Phase 4:
npx wrangler secret put RESEND_API_KEY

# New for Phase 5:
npx wrangler secret put TURNSTILE_SECRET_KEY
npx wrangler secret put RECIPIENT_EMAIL
# OR: configure RECIPIENT_EMAIL as a plain env var in wrangler.jsonc if preferred
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Simulated form submit (setTimeout) | Real fetch to Worker with Resend | Phase 5 | Actual email delivery |
| No spam protection | Cloudflare Turnstile managed mode | Phase 5 | Bot submissions blocked |
| React Email templates (common pattern) | Plain HTML string in Worker | Current recommendation | Simpler; no JSX in Worker; React Email is optional, not required |

**Deprecated/outdated:**
- reCAPTCHA v2/v3: Cloudflare Turnstile is the preferred alternative for Cloudflare-hosted sites — free, privacy-respecting, same ecosystem.

---

## Open Questions

1. **Where should RECIPIENT_EMAIL be configured?**
   - What we know: CONTEXT.md says "single hardcoded recipient address, configured as an environment variable"
   - What's unclear: Should it be a Wrangler secret (encrypted, not visible in dashboard) or a plain `vars` entry in `wrangler.jsonc`? The email address is not truly sensitive, but the distinction matters for how it's set.
   - Recommendation: Use a Wrangler secret (`wrangler secret put RECIPIENT_EMAIL`) for consistency with `RESEND_API_KEY`. This keeps all runtime configuration in one place (secrets), avoids modifying `wrangler.jsonc` for a value that may change, and protects against accidentally committing the address.

2. **Should TURNSTILE_SITE_KEY be committed in `.env`?**
   - What we know: The site key is public (visible in page HTML source to anyone). It is not a secret. It belongs in `.env` as `PUBLIC_TURNSTILE_SITE_KEY`.
   - What's unclear: Whether `.env` is in `.gitignore` for this project.
   - Recommendation: Check `.gitignore`. If `.env` is gitignored, add it to git tracking for the site key (or add a `.env.example`). If not gitignored, commit `.env` with only the public site key. Never put `TURNSTILE_SECRET_KEY` in `.env` or anywhere that gets committed.

3. **Retry button: reset entire form state or just show form again?**
   - What we know: CONTEXT.md says "Try Again" retry button that resubmits the same form data; user input is preserved.
   - What's unclear: Is "Try Again" a button that re-triggers the submit handler, or just restores the form to a ready state for the user to click the main submit button again?
   - Recommendation: "Try Again" should be a button in the error banner that programmatically re-triggers the submit flow. It should reset the Turnstile widget and re-submit with the preserved form data, all in one click.

4. **Does the existing `scripts/test-worker.sh` need updating for Phase 5?**
   - What we know: Current test script sends `{}` and checks for `{ ok: true }`. In Phase 5, the stub response `{ ok: true }` is replaced with real logic that requires a Turnstile token and form data.
   - Recommendation: Update `test-worker.sh` to test the new behavior. At minimum, test that a missing or invalid Turnstile token returns `{ ok: false }` with status 400.

---

## Sources

### Primary (HIGH confidence)
- [Cloudflare Workers - Send Emails with Resend Tutorial](https://developers.cloudflare.com/workers/tutorials/send-emails-with-resend/) — Resend SDK import, instantiation, `emails.send()` pattern, `.dev.vars`, secrets
- [Cloudflare Turnstile - Server-Side Validation](https://developers.cloudflare.com/turnstile/get-started/server-side-validation/) — siteverify API endpoint, FormData request format, success/error response structure
- [Cloudflare Turnstile - Client-Side Rendering](https://developers.cloudflare.com/turnstile/get-started/client-side-rendering/) — `cf-turnstile` div, data-sitekey attribute, hidden input auto-injection
- [Cloudflare Turnstile - Testing](https://developers.cloudflare.com/turnstile/troubleshooting/testing/) — dummy sitekeys and secret keys with exact values
- [Cloudflare Turnstile - Widget Concepts](https://developers.cloudflare.com/turnstile/concepts/widget/) — managed mode behavior (auto-selects between non-interactive and checkbox based on risk)
- [Astro - Environment Variables](https://docs.astro.build/en/guides/environment-variables/) — `PUBLIC_` prefix for client-side/build-time exposure, static output behavior
- [Resend - Send with Node.js](https://resend.com/docs/send-with-nodejs) — `resend.emails.send()` with `html` parameter (no React required), `{ data, error }` return pattern

### Secondary (MEDIUM confidence)
- [Cloudflare Developer Spotlight - Astro + Resend Form](https://developers.cloudflare.com/developer-spotlight/tutorials/handle-form-submission-with-astro-resend/) — Astro form + Resend Worker integration pattern
- [LaunchFast - Astro Turnstile Bot Protection](https://www.launchfa.st/blog/astro-turnstile-bot-protection) — Astro-specific Turnstile implementation with `is:inline` script, `import.meta.env` sitekey, fetch token pattern
- [resend npm package page](https://www.npmjs.com/package/resend) — latest version reference

### Tertiary (LOW confidence)
- Community examples of Turnstile + Cloudflare Workers contact forms — verified against official docs for core patterns; implementation details may vary

---

## Metadata

**Confidence breakdown:**
- Resend SDK integration: HIGH — official Cloudflare tutorial + official Resend docs verified; `html` parameter confirmed
- Turnstile client-side: HIGH — official Cloudflare docs verified; Astro `PUBLIC_` prefix confirmed
- Turnstile server-side verification: HIGH — siteverify endpoint and FormData pattern from official docs
- CORS for local dev: MEDIUM — standard browser behavior, not uniquely documented for this stack
- Form fetch handler updates: HIGH — straightforward `Promise.all` pattern; well-established
- Retry/reset Turnstile: HIGH — official Turnstile docs state tokens are single-use; `window.turnstile.reset()` is the documented reset method

**Research date:** 2026-02-22
**Valid until:** 2026-03-22 (Turnstile and Resend APIs are stable; Astro env var behavior is stable)
