# Phase 4: Worker Foundation - Research

**Researched:** 2026-02-22
**Domain:** Cloudflare Workers + Static Assets Routing + Resend DNS Verification
**Confidence:** HIGH (core config) / MEDIUM (Resend DNS steps)

## Summary

Phase 4 introduces a Cloudflare Worker alongside the existing static Astro site. The key technical challenge is routing: `/api/*` requests must reach the Worker, while all other paths continue to serve Astro's static output from `dist/`. Cloudflare's native `run_worker_first` array pattern (added ~mid-2025) handles this directly in `wrangler.jsonc` — no custom fallthrough logic needed for static pages.

The Worker stub is minimal: a TypeScript `fetch` handler that checks `request.method === 'POST'` and `request.url` matches `/api/contact`, returning `Response.json({ ok: true })`. TypeScript types are generated via `wrangler types` and referenced in `tsconfig.json`. Secrets are stored via `wrangler secret put` for production and `.dev.vars` for local dev — `.gitignore` already covers both patterns.

Resend domain DNS verification has one consistent Cloudflare-specific pitfall: every DNS record Resend requires (DKIM, SPF/MX) **must be set to DNS Only (grey cloud)** in Cloudflare. Proxied (orange cloud) records cause DKIM verification to fail. The MX and SPF records land on the `send` subdomain; DKIM uses `resend._domainkey`. DMARC is a separate optional TXT on `_dmarc` but is referenced in the success criteria.

**Primary recommendation:** Use `assets.run_worker_first: ["/api/*"]` in `wrangler.jsonc` with `main` pointing to `src/worker/index.ts`. This is the correct pattern for a static-first site with a single API route family.

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- API response shape: `{ ok: true/false, message: "...", data: {...} }`
- RESTful HTTP status codes (200, 201, 400, 401, 404, 422, 500)
- Stub endpoint returns `{ ok: true }` for any POST to `/api/contact` — no input validation in this phase
- Single Worker with assets binding — Worker handles `/api/*`, static assets served alongside
- Existing `wrangler.jsonc` needs restructuring (already exists in repo root)
- Worker source: `src/worker/` with `src/worker/index.ts` as entry point
- Single environment config (no dev/staging split)
- Sending domain: `rallytrivia.com` (main domain, not a subdomain)
- From address: `contact@rallytrivia.com`
- DNS managed through Cloudflare (same account as Workers)
- DNS verification steps documented directly in the phase plan (no separate runbook)
- Combined dev command — single `npm run dev` runs both Astro and Worker together
- Automated test script to verify the stub endpoint works
- Add `npm test` script as part of this phase
- Resend API key stored as Wrangler secret (`wrangler secret put RESEND_API_KEY`)

### Claude's Discretion

- CORS header approach (same-origin vs cross-origin)
- Testing framework choice (Vitest, Jest, or other)
- Exact wrangler.jsonc structure for assets + Worker coexistence

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| FORM-02 | Worker handles POST `/api/contact` and sends email via Resend API | Worker fetch handler with method + path check; `Response.json()` pattern; TypeScript Env interface with `RESEND_API_KEY` |
| FORM-04 | Resend API key is stored as a Cloudflare Workers secret (not in code) | `wrangler secret put RESEND_API_KEY` for production; `.dev.vars` for local; `.gitignore` already covers both |
</phase_requirements>

---

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| wrangler | ^4.67.0 (already installed) | CLI: deploy, dev, secrets, type-gen | Official Cloudflare toolchain; already a devDependency |
| TypeScript | 5.9.3 (already installed) | Type-safe Worker code | First-class on Workers; types generated from wrangler config |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| concurrently | ^9.x (latest) | Run `astro dev` + `wrangler dev` in parallel | Needed for the combined `npm run dev` requirement |
| resend | ^4.x (latest) | Resend Node/Edge SDK | Phase 5 email sending — install now only if needed for stub |

> **Note on resend npm package:** The stub in Phase 4 does NOT send email. Do not install the `resend` npm package in Phase 4. It belongs to Phase 5. What Phase 4 needs from Resend is only: the secret stored, and the DNS verified.

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| concurrently | npm-run-all | Both work; `concurrently` gives named process output, kills-others-on-fail flag — preferred for local DX |
| wrangler types (generate) | @cloudflare/workers-types (npm package) | `wrangler types` generates from actual config — more accurate; recommended by Cloudflare docs 2025 |

**Installation:**
```bash
npm install --save-dev concurrently
```

---

## Architecture Patterns

### Recommended Project Structure

```
src/
├── worker/
│   └── index.ts        # Worker entry point (fetch handler)
├── pages/              # Astro static pages (unchanged)
├── components/         # Astro components (unchanged)
└── layouts/            # Astro layouts (unchanged)
worker-configuration.d.ts   # Generated by `wrangler types` — DO NOT edit
.dev.vars                   # Local secrets (gitignored already)
wrangler.jsonc              # Restructured for Worker + assets
```

### Pattern 1: wrangler.jsonc with Worker + Static Assets

**What:** Single Worker handles `/api/*` routes; all other requests served from static `dist/` without invoking Worker code.

**When to use:** Static-first site with one or more API routes — this project's exact shape.

**Example:**
```jsonc
// Source: https://developers.cloudflare.com/workers/static-assets/binding/
{
  "name": "rally-trivia-build",
  "compatibility_date": "2026-02-22",
  "main": "./src/worker/index.ts",
  "assets": {
    "directory": "./dist",
    "binding": "ASSETS",
    "run_worker_first": ["/api/*"]
  }
}
```

> **Current state:** `wrangler.jsonc` has only `name`, `compatibility_date`, and `assets.directory`. It needs `main` added and `assets.binding` + `assets.run_worker_first` added inside the assets object.

### Pattern 2: Worker Fetch Handler (TypeScript)

**What:** Minimal TypeScript Worker with routing on method + URL path.

**When to use:** All Workers in this project.

**Example:**
```typescript
// Source: https://developers.cloudflare.com/workers/tutorials/send-emails-with-resend/
interface Env {
  ASSETS: Fetcher;
  RESEND_API_KEY: string;
}

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);

    if (url.pathname === '/api/contact' && request.method === 'POST') {
      return Response.json({ ok: true });
    }

    // Unknown API path — 404
    if (url.pathname.startsWith('/api/')) {
      return Response.json({ ok: false, message: 'Not found' }, { status: 404 });
    }

    // Fall through to static assets (should not be reached with run_worker_first: ["/api/*"])
    return env.ASSETS.fetch(request);
  },
} satisfies ExportedHandler<Env>;
```

> **Note on fallthrough:** With `run_worker_first: ["/api/*"]`, the Worker is only invoked for `/api/*` routes. The `env.ASSETS.fetch(request)` fallback is a safety net; static pages are served directly by the Cloudflare asset layer without the Worker being called.

### Pattern 3: Wrangler Secret Management

**What:** Secrets stored encrypted server-side; `.dev.vars` for local development.

**Production secret (run once, before or after deploy):**
```bash
npx wrangler secret put RESEND_API_KEY
# wrangler prompts for value; does not echo it
```

**Local development (`.dev.vars` file in project root):**
```
RESEND_API_KEY=re_YOUR_KEY_HERE
```

**Accessing in Worker code:**
```typescript
const apiKey = env.RESEND_API_KEY; // string
```

### Pattern 4: Combined Dev Command

**What:** Single `npm run dev` starts Astro dev server and `wrangler dev` in parallel.

**Example package.json:**
```json
{
  "scripts": {
    "dev": "concurrently \"astro dev\" \"wrangler dev --port 8787\"",
    "dev:astro": "astro dev",
    "dev:worker": "wrangler dev --port 8787"
  }
}
```

> **Port note:** Astro defaults to 4321; wrangler dev defaults to 8787. Running them as separate processes avoids port conflict. In production they are unified under one Worker deployment — no port separation needed.

### Pattern 5: TypeScript Type Generation

**What:** `wrangler types` generates `worker-configuration.d.ts` from `wrangler.jsonc` bindings.

```bash
npx wrangler types
```

This creates/updates `worker-configuration.d.ts` with typed `Env` interface matching your bindings. Reference it in `tsconfig.json`:

```json
{
  "compilerOptions": {
    "types": ["./worker-configuration.d.ts"]
  }
}
```

> **Caution:** The existing `tsconfig.json` extends `astro/tsconfigs/strict`. Adding `worker-configuration.d.ts` to `types` array may conflict with Astro's type setup. Safer approach: keep the Astro tsconfig as-is and create a separate `src/worker/tsconfig.json` that extends the root but adds Worker types.

### Pattern 6: Test Script for Stub Verification

**What:** Simple `curl`-based test or Node.js fetch to verify stub returns `{ ok: true }`.

**Example (shell test script):**
```bash
#!/bin/bash
# scripts/test-worker.sh
RESPONSE=$(curl -s -X POST http://localhost:8787/api/contact \
  -H "Content-Type: application/json" \
  -d '{}')
echo "$RESPONSE"
if echo "$RESPONSE" | grep -q '"ok":true'; then
  echo "PASS: stub returns { ok: true }"
  exit 0
else
  echo "FAIL: unexpected response"
  exit 1
fi
```

**Or as npm test script:**
```json
"test": "node scripts/test-worker.js"
```

> **Framework choice (Claude's discretion):** For this phase, a simple shell/Node fetch script is sufficient. Vitest can be added in Phase 5 when actual email logic needs unit testing. Avoid introducing a test framework just for the stub.

### Anti-Patterns to Avoid

- **`run_worker_first: true` (boolean):** Runs Worker for EVERY request including static pages. This adds latency to all page loads. Use the array form `["/api/*"]` instead.
- **Secrets in `wrangler.jsonc` `vars`:** Cloudflare docs explicitly warn against this. Use `wrangler secret put` or `.dev.vars`.
- **DKIM records with orange cloud (proxied) in Cloudflare:** Breaks DKIM verification. All email DNS records must be DNS Only (grey cloud).
- **Installing `resend` npm package in Phase 4:** The stub returns `{ ok: true }` without Resend. Install `resend` in Phase 5 only.
- **Committing `.dev.vars`:** Already covered by `.gitignore` (`.dev.vars*` pattern is present). Do not remove this pattern.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Parallel npm scripts | Custom bash forking | `concurrently` package | Cross-platform, handles signal forwarding, named process labels |
| TypeScript Env types | Manual `interface Env {}` | `wrangler types` generated file | Stays in sync with wrangler.jsonc; auto-includes all bindings |
| Worker routing | Custom URL-parsing router | URL path checks + `run_worker_first` | Cloudflare handles asset routing at edge; Worker only sees `/api/*` |

**Key insight:** The `run_worker_first` array pattern is the correct Cloudflare-native solution for hybrid static+API Workers. Custom routing frameworks (like Hono) are unnecessary for a single endpoint.

---

## Common Pitfalls

### Pitfall 1: DKIM Grey Cloud Requirement

**What goes wrong:** Developer adds all Resend DNS records in Cloudflare, but leaves them as proxied (orange cloud). DKIM verification stays stuck as "pending" indefinitely.

**Why it happens:** Cloudflare's proxy intercepts DNS lookups for proxied records, preventing the DKIM public key lookup from resolving correctly.

**How to avoid:** When adding any DNS record for Resend in Cloudflare, set the proxy status to "DNS Only" (grey cloud icon). This applies to ALL records: MX, SPF TXT, DKIM TXT.

**Warning signs:** Resend dashboard shows DKIM as "pending" or "failed" despite records appearing correct in Cloudflare DNS.

### Pitfall 2: wrangler.jsonc Missing `main` Field

**What goes wrong:** `wrangler deploy` or `wrangler dev` errors with "no entrypoint" because the existing `wrangler.jsonc` only has `assets.directory` (the v1.0 static-only config).

**Why it happens:** The current `wrangler.jsonc` was set up for static assets only. Adding a Worker requires the `main` field.

**How to avoid:** When restructuring `wrangler.jsonc`, confirm both `"main": "./src/worker/index.ts"` and the updated `assets` object (with `binding` and `run_worker_first`) are present.

**Warning signs:** `wrangler dev` starts but reports no Worker script running; or `wrangler deploy` error about missing entrypoint.

### Pitfall 3: TypeScript Config Conflict

**What goes wrong:** Adding `worker-configuration.d.ts` to the root `tsconfig.json` types array conflicts with Astro's type setup, causing `astro build` errors.

**Why it happens:** Astro extends its own strict tsconfig; mixing Worker types can introduce conflicting globals.

**How to avoid:** Create `src/worker/tsconfig.json` that extends the root but includes Worker-specific types, rather than modifying the root `tsconfig.json` directly.

### Pitfall 4: Static Pages Break After wrangler.jsonc Changes

**What goes wrong:** After adding `main` and Worker routing, static pages like `/`, `/features`, `/about`, `/contact` return Worker responses instead of HTML.

**Why it happens:** Using `run_worker_first: true` (boolean) instead of the array form, causing the Worker to intercept all requests.

**How to avoid:** Use `run_worker_first: ["/api/*"]` (array, not boolean). Verify all four static pages after deployment.

### Pitfall 5: Resend Domain Using Subdomain vs Root

**What goes wrong:** DNS records placed at root domain when Resend expects `send` subdomain, or vice versa.

**Why it happens:** Resend's SPF and MX records are intended for the `send` subdomain (e.g., `send.rallytrivia.com`), not `rallytrivia.com` itself. The DKIM record goes to `resend._domainkey.rallytrivia.com`.

**How to avoid:** Copy record names exactly from the Resend dashboard. In Cloudflare's DNS editor, enter only the subdomain portion (e.g., `send`, not `send.rallytrivia.com`).

### Pitfall 6: wrangler dev Port vs Astro dev Port

**What goes wrong:** `wrangler dev` and `astro dev` both try to use the same port.

**Why it happens:** Default ports may conflict depending on wrangler version.

**How to avoid:** Explicitly set `--port 8787` for `wrangler dev` in the concurrent dev script. Astro uses 4321 by default.

---

## Code Examples

Verified patterns from official sources:

### Complete wrangler.jsonc for Worker + Static Assets
```jsonc
// Source: https://developers.cloudflare.com/workers/static-assets/binding/
{
  "name": "rally-trivia-build",
  "compatibility_date": "2026-02-22",
  "main": "./src/worker/index.ts",
  "assets": {
    "directory": "./dist",
    "binding": "ASSETS",
    "run_worker_first": ["/api/*"]
  }
}
```

### Worker Stub: src/worker/index.ts
```typescript
// Source: https://developers.cloudflare.com/workers/tutorials/send-emails-with-resend/
interface Env {
  ASSETS: Fetcher;
  RESEND_API_KEY: string;
}

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);

    // Phase 4: stub — returns { ok: true } for any POST to /api/contact
    if (url.pathname === '/api/contact' && request.method === 'POST') {
      return Response.json({ ok: true });
    }

    if (url.pathname === '/api/contact') {
      return Response.json(
        { ok: false, message: 'Method not allowed' },
        { status: 405 }
      );
    }

    return Response.json({ ok: false, message: 'Not found' }, { status: 404 });
  },
} satisfies ExportedHandler<Env>;
```

### .dev.vars (local development)
```
# Source: https://developers.cloudflare.com/workers/configuration/secrets/
# DO NOT commit this file — already covered by .gitignore (.dev.vars* pattern)
RESEND_API_KEY=re_YOUR_KEY_HERE
```

### Production Secret Storage
```bash
# Source: https://developers.cloudflare.com/workers/wrangler/commands/
npx wrangler secret put RESEND_API_KEY
# wrangler prompts securely; value is never echoed or stored in any file
```

### CORS Headers (if cross-origin needed — Claude's discretion)
```typescript
// Source: https://developers.cloudflare.com/workers/examples/cors-header-proxy/
// Since the form and Worker are on the same domain (rallytrivia.com), CORS is not required.
// Add only if testing from localhost requires it during dev:
const corsHeaders = {
  'Access-Control-Allow-Origin': 'http://localhost:4321',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};
```

> **CORS recommendation (Claude's discretion):** The form page and the Worker endpoint are both served from `rallytrivia.com` in production — same origin, no CORS needed. During development, Astro runs on `:4321` and wrangler on `:8787` — different origins. Add minimal CORS headers in the Worker only for local dev, or proxy the Worker through Astro's dev server. The simplest approach: add CORS headers that allow `localhost:4321` during development; omit or restrict in production.

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `run_worker_first: true` (boolean) | `run_worker_first: ["/api/*"]` (array) | ~June 2025 (changelog entry) | Worker only invoked for matching routes; static pages bypass Worker entirely |
| `@cloudflare/workers-types` npm package | `wrangler types` generated file | Ongoing (Cloudflare recommendation) | Type file matches actual wrangler.jsonc bindings exactly |
| Workers + Pages as separate products | Workers with static assets (unified) | Ongoing | Single wrangler.jsonc handles both; no Cloudflare Pages required |

**Deprecated/outdated:**
- `wrangler.toml`: JSON with comments (`wrangler.jsonc`) is now standard — already used in this project.
- Cloudflare Pages for static sites with Workers: The unified Workers + assets model is the current approach. Migration guides exist but are not needed here since this project hasn't shipped on Pages.

---

## Open Questions

1. **Is `rallytrivia.com` already added as a sending domain in Resend?**
   - What we know: STATE.md flags this as a concern: "Confirm whether rallytrivia.com is already added in Resend dashboard"
   - What's unclear: If already added but DNS records were never set, the records need to be added. If the domain was never added, the flow starts fresh from "Add Domain" in Resend dashboard.
   - Recommendation: Plan step 1 of DNS work should be "Check Resend dashboard → Domains for rallytrivia.com status". If not present, add it. If present and unverified, add the DNS records shown there.

2. **`compatibility_date` value for array `run_worker_first` support**
   - What we know: The `run_worker_first` array was announced in the Cloudflare changelog dated 2025-06-17. Current `wrangler.jsonc` has `2025-10-08`.
   - What's unclear: Whether there is a minimum `compatibility_date` required for this feature.
   - Recommendation: Keep the existing `2025-10-08` date (it post-dates the feature launch). Do not downgrade it.

3. **tsconfig.json strategy for Worker types**
   - What we know: Root `tsconfig.json` extends `astro/tsconfigs/strict`. `wrangler types` generates `worker-configuration.d.ts`.
   - What's unclear: Whether adding `worker-configuration.d.ts` to the root tsconfig breaks Astro's type checking.
   - Recommendation: Research approach is to create `src/worker/tsconfig.json` extending root with added Worker types. Verify with `astro check` after changes.

---

## Sources

### Primary (HIGH confidence)
- [Cloudflare Workers - Static Assets Binding](https://developers.cloudflare.com/workers/static-assets/binding/) — `run_worker_first` array config, ASSETS binding, Env interface
- [Cloudflare Workers - Worker Script Routing](https://developers.cloudflare.com/workers/static-assets/routing/worker-script/) — routing behavior, fallthrough pattern
- [Cloudflare Workers - Secrets](https://developers.cloudflare.com/workers/configuration/secrets/) — `wrangler secret put`, `.dev.vars`, gitignore
- [Cloudflare Workers - Environment Variables](https://developers.cloudflare.com/workers/development-testing/environment-variables/) — `.dev.vars` format, vars vs secrets distinction
- [Cloudflare Workers - TypeScript](https://developers.cloudflare.com/workers/languages/typescript/) — `wrangler types`, `worker-configuration.d.ts`
- [Cloudflare Workers - Send Emails with Resend (tutorial)](https://developers.cloudflare.com/workers/tutorials/send-emails-with-resend/) — Worker pattern with Resend, Env interface, `.dev.vars`
- [Cloudflare Workers - Wrangler Configuration](https://developers.cloudflare.com/workers/wrangler/configuration/) — `main`, `assets`, `compatibility_date` field reference
- [Resend DNS Setup - Cloudflare](https://resend.com/docs/dashboard/domains/cloudflare) — DNS record types, names, grey cloud requirement

### Secondary (MEDIUM confidence)
- [Cloudflare Changelog - Advanced Routing 2025-06-17](https://developers.cloudflare.com/changelog/2025-06-17-advanced-routing/) — confirms `run_worker_first` array feature availability date
- [DmarcDkim.com - Resend SPF/DKIM/DMARC](https://dmarcdkim.com/setup/how-to-setup-resend-spf-dkim-and-dmarc-records) — DNS record walkthrough verified against Cloudflare community reports
- [Cloudflare Community - DKIM not verified with Resend](https://community.cloudflare.com/t/i-have-set-up-dkim-as-presented-in-resend-but-it-is-not-verified/806974) — grey cloud / orange cloud pitfall, confirmed by multiple independent sources

### Tertiary (LOW confidence)
- Community and blog posts about `concurrently` for parallel npm scripts — well-established pattern but not from official Cloudflare docs specifically

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — wrangler already installed; concurrently is a stable well-known package
- Architecture (wrangler.jsonc): HIGH — verified against official Cloudflare docs with exact config syntax
- Architecture (Worker TypeScript): HIGH — verified against official tutorial and type docs
- Resend DNS records: MEDIUM — official Resend Cloudflare doc accessed; grey cloud requirement cross-verified via community
- Pitfalls: HIGH for Cloudflare-side pitfalls; MEDIUM for Resend DNS edge cases

**Research date:** 2026-02-22
**Valid until:** 2026-03-22 (Cloudflare routing config is stable; Resend DNS requirements unlikely to change)
