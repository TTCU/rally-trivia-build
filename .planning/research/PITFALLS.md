# Pitfalls Research

**Domain:** Astro marketing site on Cloudflare Workers — v1.1 feature additions
**Researched:** 2026-02-22
**Confidence:** HIGH for Resend/Cloudflare integration (official docs verified); HIGH for analytics injection (multiple community reports + official docs); MEDIUM for UX/content pitfalls (multi-source verified)

---

## Milestone Context: v1.1 Additions

This document covers pitfalls specific to adding these four features to the existing, working static site:

1. **Form backend** — Resend API via a new Astro server endpoint on Cloudflare Workers
2. **Cloudflare Web Analytics** — Beacon script injection into existing pages
3. **Social proof rework** — Replacing hardcoded placeholder stats with qualitative copy
4. **Real team section** — Replacing placeholder team members with real names, titles, and photos

The v1.0 pitfalls (output mode, Tailwind v4, image CLS, etc.) are preserved below for completeness but the **critical pitfalls for v1.1 are listed first**.

---

## Critical Pitfalls — v1.1 Feature Additions

### Pitfall 1: Adding a Server Endpoint Requires the Cloudflare Adapter — The Existing wrangler.jsonc Is Insufficient

**What goes wrong:**
The current deployment is pure static assets (`wrangler.jsonc` has only `assets.directory`, no `main` field). When you add a server endpoint (`src/pages/api/submit.ts` with `export const prerender = false`), Astro needs the `@astrojs/cloudflare` adapter installed to compile the endpoint into a `_worker.js`. Without the adapter, `npm run build` either errors or silently omits the endpoint. The form posts to `/api/submit` and gets a 404 in production.

**Why it happens:**
The existing static site works without an adapter — Astro's default `output: 'static'` pre-renders everything. Developers add an API file expecting it to "just work," not realizing the Cloudflare runtime worker compilation step is entirely gated behind the adapter.

**How to avoid:**
Run `npx astro add cloudflare` before writing any endpoint code. This command:
- Installs `@astrojs/cloudflare`
- Updates `astro.config.mjs` with the adapter
- Rewrites `wrangler.jsonc` to add `"main": "dist/_worker.js/index.js"` and the required `compatibility_flags`

After adding the adapter, explicitly mark all existing pages with `export const prerender = true` OR confirm that the project `output` remains `'static'` (Astro 5's default behavior: `prerender = false` on any single file triggers Worker compilation only for that file while static pages remain pre-rendered).

Verify the correct `wrangler.jsonc` structure after adapter install:
```jsonc
{
  "name": "rally-trivia-build",
  "compatibility_date": "2025-10-08",
  "main": "dist/_worker.js/index.js",
  "compatibility_flags": ["nodejs_compat"],
  "assets": {
    "directory": "./dist"
  }
}
```

**Warning signs:**
- `npm run build` output has no `_worker.js` directory when an API endpoint exists
- POST to `/api/submit` returns 404 in production but works locally with `npm run dev`
- `wrangler deploy` succeeds but form submissions fail silently
- No `@astrojs/cloudflare` in `package.json` dependencies

**Phase to address:** Form backend phase — before writing any endpoint code

---

### Pitfall 2: Resend "From" Address Requires a Verified Domain — `onboarding@resend.dev` Is Test-Only

**What goes wrong:**
Resend's free tier restricts the `from` address to `onboarding@resend.dev` until a custom domain is verified. Developers test locally with this address, the emails arrive, and they ship to production — only to discover that all production emails still arrive "from" Resend's sandbox address, appear suspicious to recipients, or (if using a real `from` address pre-verification) are rejected entirely with a 403 validation error. This is a blocking issue if domain verification is skipped.

**Why it happens:**
The Resend onboarding flow makes it easy to generate an API key and send test emails without verifying a domain. The sandbox restriction is not enforced until sending to addresses other than your own verified account email.

**How to avoid:**
Before writing any application code:
1. Log into Resend dashboard → Domains → Add Domain
2. Add the sending domain (e.g., `rallytrivia.com` or a subdomain like `mail.rallytrivia.com`)
3. Add the required DNS records in Cloudflare:
   - MX record for `send` subdomain
   - TXT SPF record for `send` subdomain
   - TXT DKIM record for `resend._domainkey` — **set Cloudflare Proxy Status to "DNS Only" (grey cloud) for DKIM records**
4. Wait for DNS propagation (typically 5-15 minutes with Cloudflare)
5. Confirm green verification status in Resend dashboard before writing code

Use `sending_access` scope (not `full_access`) for the API key used in production.

**Warning signs:**
- Resend API returns `403` with message about unverified domain
- Test emails work but "from" shows `onboarding@resend.dev` in production
- DKIM record shows "pending" because it was added with orange cloud proxy
- DNS records added but Resend shows "not verified" — check for orange cloud on DKIM

**Phase to address:** Form backend phase — Day 1, before any code is written

---

### Pitfall 3: Resend API Key Exposed via Client-Side Code or Committed to Repository

**What goes wrong:**
The Resend API key is placed in a `.env` file, committed to the repository, or worse — embedded in client-side JavaScript that gets shipped in the static bundle. Any of these means the key is compromised. With a full-access key, an attacker can send unlimited email from your domain, ruining deliverability reputation.

**Why it happens:**
Developers accustomed to client-side fetch calls try to call the Resend API directly from the browser (which also fails due to CORS). Others add the key to `.env` and forget to add `.env` to `.gitignore`. Some place it in `astro.config.mjs` constants thinking it will only be server-side.

**How to avoid:**
- Store the key as a Cloudflare Workers secret: `npx wrangler secret put RESEND_API_KEY`
- Access it only via `context.locals.runtime.env.RESEND_API_KEY` in the server endpoint
- Never reference it in any `.astro` component or client-side `<script>` tag
- Confirm `.env` is in `.gitignore` before first commit containing any secrets
- For local dev, use `.dev.vars` (Cloudflare's local secret file, also gitignored):
  ```
  RESEND_API_KEY=re_xxxxxxxxxxxx
  ```
- Use `sending_access` permission scope on the production API key (not `full_access`)

**Warning signs:**
- `RESEND_API_KEY` appears in `git log` or `git diff` output
- Key visible in browser DevTools Network tab
- Resend API errors logged to client console instead of server logs
- CORS errors when calling Resend from browser — means the call is happening client-side

**Phase to address:** Form backend phase — security review before first deployment

---

### Pitfall 4: Form Endpoint CORS Errors Are Misleading — The Real Error Is Often in the Worker

**What goes wrong:**
When the Cloudflare Worker endpoint throws any unhandled error (Resend key missing, malformed request, DNS/module import failure), Cloudflare returns a 500 with no CORS headers on the error response. The browser sees this as a CORS error and logs "has been blocked by CORS policy" — completely obscuring the actual error. Developers spend hours debugging CORS configuration when the real issue is an environment variable not being set.

**Why it happens:**
CORS headers are added by the endpoint handler. If the handler throws before reaching the response, no CORS headers are added. The browser's CORS error message is technically accurate but deeply misleading about root cause.

**How to avoid:**
- Wrap the entire endpoint handler body in a `try/catch`
- Return error responses that include CORS headers even on failure:
  ```typescript
  export const POST: APIRoute = async ({ request }) => {
    const corsHeaders = {
      'Access-Control-Allow-Origin': 'https://rallytrivia.com',
      'Content-Type': 'application/json',
    };
    try {
      // ... handler logic
    } catch (error) {
      return new Response(JSON.stringify({ error: 'Internal server error' }), {
        status: 500,
        headers: corsHeaders,
      });
    }
  };
  ```
- Use `wrangler tail` to see real-time Worker logs in production: `npx wrangler tail`
- In local dev, check the terminal running `npm run dev` — Worker errors appear there, not in browser console

**Warning signs:**
- Browser console shows CORS error but local dev shows a different error
- Form works in `npm run dev` but fails in production after `wrangler deploy`
- No error logged in Cloudflare Workers dashboard but CORS errors appear in browser

**Phase to address:** Form backend phase — implement error handling before first end-to-end test

---

### Pitfall 5: Existing ContactForm Simulates Success — Must Wire Actual Fetch Call

**What goes wrong:**
The existing `ContactForm.astro` component has a simulated 1500ms delay and then shows a success state — it never posts to any endpoint. When the real backend is added, the form needs the `fetch` call added, success/failure branching added, and the simulated delay removed. Developers add the backend endpoint but forget to update the client-side submit handler, leaving the form permanently in "fake success" mode in production.

**Why it happens:**
The endpoint and the form component are separate files. It's easy to add `src/pages/api/submit.ts` and assume the form will automatically use it. The simulated submit logic in `ContactForm.astro`'s `<script>` tag must be replaced.

**How to avoid:**
Update the form's submit handler to replace the `setTimeout` simulation with a real `fetch`:
```typescript
// Replace the simulated delay with:
const formData = new FormData(form);
const response = await fetch('/api/submit', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(Object.fromEntries(formData)),
});

if (!response.ok) {
  // Show error state — do NOT show thank-you
  throw new Error(`Submission failed: ${response.status}`);
}
// Only now show thank-you state
```
Add an error state to the form UI (the existing component has no error path after submit — it only has validation errors and the thank-you state).

**Warning signs:**
- Form shows "Thank you" even when the API endpoint returns 500
- No network request visible in DevTools when form is submitted
- Form works locally against no backend (the simulation still runs)

**Phase to address:** Form backend phase — wire form and endpoint together as a single task

---

### Pitfall 6: Cloudflare Web Analytics Auto-Inject Is Unreliable on Workers — Use Manual Script

**What goes wrong:**
Cloudflare's "automatic" Web Analytics injection (enabled via the dashboard toggle) fails intermittently on Workers-served sites. Community reports confirm the auto-inject does not fire consistently after Workers deployments. The dashboard shows analytics "enabled" but data never appears. The issue is compounded by `Cache-Control: public, no-transform` headers, which prevent Cloudflare's edge from modifying the HTML payload to inject the beacon.

**Why it happens:**
Auto-inject works by Cloudflare modifying HTML responses at the edge. Workers serving static assets may return headers that block this modification. The feature was designed primarily for proxied origin servers, not Workers-hosted static assets.

**How to avoid:**
Skip auto-inject entirely. Use the manual beacon script:
1. In Cloudflare dashboard → Web Analytics → Add a site → choose "JS Snippet" installation
2. Copy the `<script>` snippet provided (it includes your site-specific token)
3. Add it to `BaseHead.astro` before the closing `</head>` tag:
   ```html
   <script defer src='https://static.cloudflareinsights.com/beacon.min.js'
     data-cf-beacon='{"token": "YOUR_TOKEN_HERE"}'></script>
   ```
4. Rebuild and deploy — analytics data should appear in the dashboard within minutes

The `defer` attribute prevents the beacon from blocking page rendering.

**Warning signs:**
- Analytics dashboard shows "No data" after 24 hours with auto-inject enabled
- Workers analytics (in Workers dashboard) shows requests, but Web Analytics shows 0 visitors
- Toggling auto-inject on/off in dashboard has no effect
- No `cloudflareinsights.com` request visible in browser DevTools Network tab

**Phase to address:** Analytics phase — use manual installation from the start, never attempt auto-inject

---

### Pitfall 7: Team Photos Without Defined Dimensions Cause CLS on the About Page

**What goes wrong:**
Team member photos added via `<img>` tags without `width` and `height` attributes (or via Astro's `<Image>` without proper sizing) cause layout shift as images load. The About page currently has placeholder content — replacing it with real photos from inconsistent sources (phone camera, LinkedIn, professional photos at different aspect ratios) makes this worse.

**Why it happens:**
Photos from different sources have unpredictable dimensions. Developers use CSS to constrain them (`object-fit: cover; width: 150px; height: 150px`) but forget that the browser needs the attributes in HTML to reserve space before the image loads.

**How to avoid:**
- Store all team photos in `src/assets/team/` (not `public/`) so Astro can optimize them
- Use Astro's `<Image>` component with explicit `width` and `height`:
  ```astro
  import { Image } from 'astro:assets';
  import teamPhoto from '../assets/team/person-name.jpg';
  ---
  <Image
    src={teamPhoto}
    alt="Person Name, Title"
    width={300}
    height={300}
    class="rounded-full object-cover"
  />
  ```
- Standardize photo dimensions before adding to repo — crop to square (1:1) at minimum 600px × 600px for quality at 300px display size
- Use `loading="lazy"` for team photos (they're below the fold)

**Warning signs:**
- Lighthouse CLS score worsens after adding team section
- Team photo section "jumps" as page loads on slower connections
- Photos display at inconsistent sizes despite CSS rules

**Phase to address:** Team section phase — enforce dimensions at the time photos are added

---

### Pitfall 8: Replacing Placeholder Social Proof Stats Without Removing All Instances

**What goes wrong:**
The placeholder social proof stats ("500+ events hosted", "99% satisfaction rate") may appear in multiple places: the landing page, the features page, meta descriptions, or OG tags. Updating one instance while leaving others creates inconsistency — a visitor reads one number on the homepage and a different one on the features page.

**Why it happens:**
Content is duplicated across components during initial build for speed. There's no single source of truth for marketing claims. When updating, developers fix the visible instance but miss the others.

**How to avoid:**
Before making any changes, search the entire codebase for all instances of the placeholder content:
```bash
grep -r "500+" src/
grep -r "99%" src/
grep -r "satisfaction" src/
grep -ri "placeholder" src/
```
Centralize social proof claims in `src/consts.ts` so they have one authoritative source:
```typescript
export const SOCIAL_PROOF = {
  eventsHosted: "50+",
  tagline: "Trusted by nonprofits and corporate teams across the region",
} as const;
```
Import from consts in all components.

**Warning signs:**
- Different numbers or claims visible when switching between pages
- `grep` reveals more matches than expected for placeholder text
- Old stats visible in `<meta>` description or OG tags even after page content updated

**Phase to address:** Social proof rework phase — grep first, change second

---

## Critical Pitfalls — v1.0 Foundation (Preserved)

### Pitfall 9: Wrong Output Mode — Deploying SSR When Static Is Correct

**What goes wrong:**
The `@astrojs/cloudflare` adapter defaults to `output: 'server'`, which server-renders every page on-demand as a Cloudflare Worker invocation. A marketing site like Rally Trivia has zero dynamic data — every page can (and should) be pre-rendered at build time as static HTML. Defaulting to SSR adds latency, consumes Worker CPU quota, and complicates deployment for zero benefit.

**Why it happens:**
Developers install `@astrojs/cloudflare` and accept defaults, not realizing the adapter default assumes SSR. The Cloudflare adapter documentation focuses heavily on SSR use cases.

**How to avoid:**
In v1.1, when the adapter is added for the API endpoint, confirm that all existing pages remain pre-rendered. In Astro 5, with `output: 'static'` (the default), adding `export const prerender = false` to one file does NOT force all pages into SSR — only that file becomes server-rendered. All other pages remain statically pre-rendered. Verify the build output: only `dist/_worker.js/` and the endpoint should be dynamic; all page HTML files should exist as static files in `dist/`.

**Warning signs:**
- Every page load appearing in Cloudflare Workers CPU metrics
- Build output has no `.html` files in `dist/` for pages that should be static
- TTFB significantly higher than expected for "static" pages

**Phase to address:** Form backend phase — verify build output after adding adapter

---

### Pitfall 10: Missing or Misconfigured `wrangler.jsonc` After Adapter Install

**What goes wrong:**
The current `wrangler.jsonc` has only `assets.directory`. After `npx astro add cloudflare`, the file is updated to include `main` and `compatibility_flags`. If this update is applied incorrectly (or `astro add` is skipped and the adapter is installed manually), the Worker deployment fails or assets stop being served.

**How to avoid:**
Always use `npx astro add cloudflare` rather than manual installation. After running it, verify `wrangler.jsonc` contains:
- `"main": "dist/_worker.js/index.js"`
- `"compatibility_flags": ["nodejs_compat"]`
- `"assets": { "directory": "./dist" }`

Run `npm run check` (which runs `astro build && tsc && wrangler deploy --dry-run`) to catch config issues before deploying.

**Warning signs:**
- `wrangler deploy` succeeds but form endpoint returns 404
- Build output lacks `dist/_worker.js/` directory
- `wrangler deploy --dry-run` shows errors about missing main field

**Phase to address:** Form backend phase — run `astro add cloudflare`, verify with dry-run

---

### Pitfall 11: `nodejs_compat` Flag Required for Resend SDK

**What goes wrong:**
The Resend Node.js SDK (`import { Resend } from 'resend'`) depends on Node.js built-in modules. Cloudflare Workers do not support Node built-ins by default. Without the `nodejs_compat` compatibility flag, the Worker fails at import time with an opaque module resolution error.

**How to avoid:**
Ensure `wrangler.jsonc` includes:
```jsonc
"compatibility_flags": ["nodejs_compat"]
```
This is added automatically by `npx astro add cloudflare`. Verify it exists before running `wrangler deploy`.

**Warning signs:**
- Worker fails with "Cannot find module 'node:...' " or similar import error
- Resend SDK works in local `npm run dev` but fails after `wrangler deploy`
- `wrangler tail` shows module resolution errors on first Worker invocation

**Phase to address:** Form backend phase — verify flag before first deploy

---

## Moderate Pitfalls

### Pitfall 12: No Error State in the Form After Real Submission Fails

**What goes wrong:**
The current form has only two states: validation error (pre-submit) and success (thank-you view). There is no failure state for a successful POST that returns a non-200 response. If Resend is down, the API key is wrong, or any server error occurs, the form silently swallows the error and the user is left staring at a spinning button until they give up. The lead is lost and they have no way to contact you.

**How to avoid:**
Add a third state to the form — a server error state with a fallback message:
```html
<!-- Add above the form -->
<div id="submit-error" class="hidden mb-6 p-4 bg-red-50 border border-red-200 rounded-lg">
  <p>Something went wrong. Please email us directly at <a href="mailto:hello@rallytrivia.com">hello@rallytrivia.com</a>.</p>
</div>
```
In the submit handler, catch non-200 responses and show this banner rather than the thank-you state.

**Warning signs:**
- Form submit hangs indefinitely during an API outage
- No fallback contact method visible if form fails
- Error logged to console but user sees no feedback

**Phase to address:** Form backend phase — add error state when wiring the fetch call

---

### Pitfall 13: Resend Rate Limit Is 2 Requests Per Second — Not a Real Concern at This Scale, But Log It

**What goes wrong:**
Resend's default rate limit is 2 requests per second. For a marketing site receiving occasional demo requests, this is irrelevant. However, if the form lacks spam protection (no honeypot, no rate limiting), a bot could trigger rapid sequential submissions and exhaust the limit, causing legitimate submissions to be rejected with 429 errors.

**How to avoid:**
The existing form has client-side validation but no honeypot field. Before wiring the backend, add a honeypot input (hidden from users, bots fill it in):
```html
<div style="position:absolute;left:-9999px;opacity:0;height:0;overflow:hidden;" aria-hidden="true">
  <label for="website">Leave empty</label>
  <input type="text" id="website" name="website" tabindex="-1" autocomplete="off">
</div>
```
In the server endpoint, reject any submission where this field is non-empty:
```typescript
if (body.website) {
  return new Response(JSON.stringify({ ok: true }), { status: 200 }); // Silently discard
}
```
Silent discard (vs. 400 error) avoids confirming to bots that protection exists.

**Warning signs:**
- Resend dashboard shows unusually high send volume shortly after launch
- Multiple submissions with identical or nonsensical content
- Resend API returns 429 errors in Worker logs

**Phase to address:** Form backend phase — add honeypot to form HTML before wiring endpoint

---

### Pitfall 14: Analytics Beacon Blocked by Ad Blockers — Do Not Rely Solely on It

**What goes wrong:**
Cloudflare Web Analytics uses a client-side beacon (`beacon.min.js`) that most ad blockers and privacy extensions block. On a B2B audience (event planners, nonprofit coordinators) that may use tools like uBlock Origin, a meaningful percentage of traffic will not be counted. Decisions based solely on Cloudflare Analytics data will undercount real traffic.

**How to avoid:**
Accept this as an inherent limitation of any client-side analytics solution (including Google Analytics). For a marketing site at this scale, the signal is still useful for relative trends even if absolute counts are deflated. Cloudflare's paid plans offer edge-level analytics that cannot be blocked, but this is unnecessary at current scale.

Treat analytics data as directional, not absolute. Note this limitation in any reporting.

**Warning signs:**
- Analytics traffic appears much lower than email click-through rates suggest
- Traffic from known sources (e.g., a newsletter link) doesn't show in analytics

**Phase to address:** Analytics phase — document limitation, accept as acceptable for current scale

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Inline social proof claims in components | Fast content update | Copy changes require code deploys, claims can drift out of sync | Never — centralize in `src/consts.ts` |
| Auto-inject Cloudflare Analytics (vs manual) | Zero code change | Unreliable, data often missing entirely | Never — use manual beacon |
| Storing Resend API key in `.env` without wrangler secret | Easier local dev | Risk of key exposure via git commit; doesn't work in Cloudflare Workers runtime anyway | Never — use `.dev.vars` locally, `wrangler secret put` for production |
| Skip error handling in form endpoint | Faster implementation | Silent failures lose leads, no debugging signal | Never for a conversion-critical form |
| Using `full_access` scope Resend key in production | One key for everything | If key leaks, attacker can delete emails, domains, API keys | Never — use `sending_access` scope in production |
| Skip team photo size standardization | Add any photo quickly | Inconsistent sizing, layout shift, pixelated images | Never — 5-minute Figma/Photoshop crop upfront saves hours of CSS fighting |

---

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| `@astrojs/cloudflare` adapter | Adding manually without `astro add cloudflare` | Always use `npx astro add cloudflare` — it wires up `wrangler.jsonc` correctly |
| Resend API | Using `onboarding@resend.dev` as the `from` address in production | Verify custom domain in Resend before writing any code |
| Resend domain verification in Cloudflare DNS | Adding DKIM record with orange cloud proxy | Set DKIM record to "DNS Only" (grey cloud) or verification fails |
| Cloudflare Web Analytics | Enabling "automatic" injection via dashboard toggle | Use manual JS snippet in `BaseHead.astro` — auto-inject is unreliable on Workers |
| Resend API key in Astro endpoint | Accessing via `import.meta.env.RESEND_API_KEY` | Access via `context.locals.runtime.env.RESEND_API_KEY` in Cloudflare Workers runtime |
| Resend SDK in Cloudflare Workers | Missing `nodejs_compat` flag | Add `"compatibility_flags": ["nodejs_compat"]` to `wrangler.jsonc` |

---

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| Committing `.env` with Resend API key | Key exposed in git history — revoke and rotate immediately | Add `.env` and `.dev.vars` to `.gitignore`; use `wrangler secret put` |
| Using `full_access` Resend API key in production Worker | Compromised key gives attacker full account control | Create `sending_access`-scoped key specifically for the Worker |
| No server-side validation of form fields | Bypassing client-side validation to inject malicious content | Validate required fields and field lengths in the endpoint handler, not just in the browser |
| No honeypot field | Bot spam floods Resend quota and inbox | Add honeypot field; silently discard submissions where it's filled |
| Calling Resend API from client-side JS | API key exposed in browser; CORS will block it anyway | All Resend calls must happen in the server endpoint, never in `<script>` tags |

---

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| No form error state after backend failure | User loses submission, no fallback contact info | Show error banner with direct email address fallback |
| Form shows success even when API returns error | Submission lost without user awareness | Gate thank-you state on confirmed 2xx response from endpoint |
| Double-submit on slow connection | Duplicate email notifications | Disable submit button immediately on first click; re-enable only on error |
| Team photos without alt text | Inaccessible to screen readers | Use descriptive alt text: "Jane Smith, Co-Founder and Head of Events" |
| Qualitative social proof without specificity | Vague claims read as marketing fluff | "Trusted by 12 nonprofits in the Chicago area" > "Trusted by nonprofits everywhere" |

---

## "Looks Done But Isn't" Checklist

### Form Backend
- [ ] **Adapter installed:** `@astrojs/cloudflare` appears in `package.json` dependencies
- [ ] **Endpoint exists:** `src/pages/api/submit.ts` with `export const prerender = false`
- [ ] **wrangler.jsonc updated:** Contains `"main"` field and `"nodejs_compat"` flag
- [ ] **Secret configured:** `wrangler secret put RESEND_API_KEY` run in production environment
- [ ] **Domain verified:** Resend dashboard shows green status for sending domain
- [ ] **DKIM grey cloud:** Cloudflare DNS shows DKIM record as "DNS Only"
- [ ] **Real fetch in form:** Client-side submit handler sends actual POST, not `setTimeout` simulation
- [ ] **Error state exists:** Form shows error banner (not thank-you) on non-200 response
- [ ] **Honeypot present:** Hidden field in form HTML, validated server-side
- [ ] **End-to-end test:** Submit form on production deployment, confirm email arrives in inbox

### Analytics
- [ ] **Manual snippet added:** `beacon.min.js` script tag in `BaseHead.astro`
- [ ] **Token is site-specific:** Beacon `data-cf-beacon` token matches the registered site in dashboard
- [ ] **Network tab confirms:** DevTools shows request to `cloudflareinsights.com` on page load
- [ ] **Dashboard shows data:** At least one pageview visible in Cloudflare Analytics within 30 minutes of manual testing

### Social Proof
- [ ] **All instances updated:** `grep` confirms no old placeholder numbers remain anywhere in `src/`
- [ ] **Claims centralized:** Stats/claims live in `src/consts.ts`, not hardcoded in multiple components
- [ ] **Copy reviewed:** No claims that could be misread as specific statistics without basis

### Team Section
- [ ] **Photos optimized:** All images stored in `src/assets/team/`, processed by Astro `<Image>`
- [ ] **Dimensions explicit:** Each `<Image>` has `width` and `height` set
- [ ] **Alt text meaningful:** Alt text includes name and title for each team member
- [ ] **CLS clean:** Lighthouse CLS remains under 0.1 after team photos added

---

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Missing adapter (404 on endpoint) | LOW | Run `npx astro add cloudflare`, verify wrangler.jsonc, redeploy |
| Resend domain not verified (403 errors) | MEDIUM | Add DNS records, wait propagation, re-test — emails queue until fixed |
| API key committed to git | HIGH | Revoke key immediately in Resend dashboard, rotate, force-push history clean (or accept exposure), update wrangler secret |
| Analytics auto-inject not working | LOW | Switch to manual beacon in BaseHead.astro, redeploy |
| Fake success on form failure | LOW | Add try/catch and error state to submit handler, redeploy |
| Placeholder content surviving in production | LOW | grep, fix, redeploy |
| Team photos causing CLS | LOW | Move to `src/assets/`, use `<Image>` with dimensions, redeploy |

---

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Missing Cloudflare adapter | Form backend — Day 1 setup | `npm run build` produces `dist/_worker.js/`; `wrangler deploy --dry-run` succeeds |
| Resend domain not verified | Form backend — before any code written | Resend dashboard shows green verification status |
| API key security | Form backend — before first deploy | Key stored as wrangler secret, absent from all source files |
| CORS errors masking Worker errors | Form backend — first end-to-end test | `wrangler tail` shows real errors; browser shows meaningful error messages |
| Fake submit still running | Form backend — wiring the fetch call | DevTools Network shows POST request to `/api/submit` |
| No form error state | Form backend — wiring the fetch call | Simulate 500 response; confirm error banner appears |
| Analytics auto-inject unreliable | Analytics — Day 1 | Manual beacon script in BaseHead.astro; DevTools confirms beacon request |
| Ad blocker blocking analytics | Analytics — documentation | Noted as known limitation, no fix required |
| Placeholder content surviving | Social proof rework | `grep` for old strings returns zero results |
| Team photo CLS | Team section | Lighthouse CLS under 0.1 after team section added |
| Missing team photo alt text | Team section | Lighthouse accessibility audit shows no missing alt text |

---

## Sources

- [Astro Cloudflare Adapter Docs](https://docs.astro.build/en/guides/integrations-guide/cloudflare/) — Adapter install, wrangler.jsonc structure, compatibility flags (HIGH confidence)
- [Cloudflare Developer Spotlight: Astro + Resend Form Tutorial](https://developers.cloudflare.com/developer-spotlight/tutorials/handle-form-submission-with-astro-resend/) — End-to-end form integration pattern (HIGH confidence)
- [Cloudflare Workers: Send Emails with Resend Tutorial](https://developers.cloudflare.com/workers/tutorials/send-emails-with-resend/) — Secret management, env access pattern, Resend SDK usage (HIGH confidence)
- [Astro On-Demand Rendering Guide](https://docs.astro.build/en/guides/on-demand-rendering/) — `prerender = false` behavior, static + server endpoint mixing (HIGH confidence)
- [Resend Docs: Send with Cloudflare Workers](https://resend.com/docs/send-with-cloudflare-workers) — SDK usage, environment access (HIGH confidence)
- [Resend Docs: Domain Verification on Cloudflare](https://resend.com/docs/dashboard/domains/cloudflare) — DKIM grey cloud requirement, DNS records (HIGH confidence)
- [Resend Docs: Account Quotas and Limits](https://resend.com/docs/knowledge-base/account-quotas-and-limits) — Rate limits, free tier restrictions (HIGH confidence)
- [Cloudflare Web Analytics: Get Started](https://developers.cloudflare.com/web-analytics/get-started/) — Manual beacon installation, auto-inject limitations (HIGH confidence)
- [Cloudflare Web Analytics: FAQ](https://developers.cloudflare.com/web-analytics/faq/) — Auto-inject cache header conflict, ad blocker impact (HIGH confidence)
- [Cloudflare Community: Web Analytics Not Injecting JS Token](https://community.cloudflare.com/t/web-analytics-not-injecting-the-js-token/860770) — Real-world auto-inject failure reports (MEDIUM confidence)
- [Astro Images Guide](https://docs.astro.build/en/guides/images/) — CLS prevention, Image component dimensions (HIGH confidence)
- [Cloudflare Community: Security Considerations for Contact Form](https://community.cloudflare.com/t/security-considerations-for-a-contact-form/415120) — Honeypot, rate limiting, CORS pitfalls (MEDIUM confidence)
- [Resend GitHub: resend-cloudflare-workers-example](https://github.com/resend/resend-cloudflare-workers-example) — Reference implementation (HIGH confidence)

---

*Pitfalls research for: Astro marketing site on Cloudflare Workers — v1.1 additions (form backend, analytics, real content)*
*Researched: 2026-02-22*
