# Stack Research

**Domain:** Rally Trivia v1.1 — form backend, analytics, and content updates (additions to existing validated stack)
**Researched:** 2026-02-22
**Confidence:** HIGH — library versions confirmed via npm registry; architecture patterns confirmed via official Cloudflare Workers documentation

---

## Existing Stack (Validated — Do Not Re-research)

The following is already in production. No changes needed:

| Technology | Version | Status |
|------------|---------|--------|
| Astro | 5.16.2 | Locked — do not upgrade during this milestone |
| Tailwind CSS | v4 via `@tailwindcss/vite` | Locked |
| Motion | ^12.34.3 | Locked |
| Fontsource Plus Jakarta Sans | ^5.2.8 | Locked |
| TypeScript | 5.9.3 | Locked |
| Wrangler | ^4.67.0 | Locked (dev dep) |
| Cloudflare Workers | static assets only, no `main` entry | Changing in v1.1 |

---

## New Capabilities Required for v1.1

Three distinct additions are needed. Only one requires a new npm package:

| Capability | New npm package? | What changes |
|------------|-----------------|--------------|
| Resend email via Cloudflare Worker | YES — `resend@^6.9.0` | New Worker script + `main` in `wrangler.jsonc` + Wrangler secret |
| Cloudflare Web Analytics | NO | One `<script>` tag in `BaseHead.astro` |
| Team photos + social proof copy | NO | Image files in `public/`, markup edits in `.astro` files |

---

## Recommended Stack Additions

### New Library: Resend SDK

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| `resend` | `6.9.2` (use `^6.9.0`) | Email delivery API client | v6.9.2 (published 2026-02-10) explicitly adds Cloudflare Workers and non-Node V8 isolate compatibility. Official SDK from the Resend team. Plain HTML email support — no React Email dependency needed. Free tier: 3,000 emails/month (more than sufficient for demo request volume). Cloudflare officially documents Resend as the recommended email provider for Workers. |

**Why not alternatives:**
- `nodemailer` — Node.js-only, does not run in Cloudflare's V8 isolate runtime
- Cloudflare Email Routing native binding — limited to forwarding, cannot compose programmatic emails with custom body
- SendGrid/Mailgun/Postmark — heavier SDKs, higher cost, unnecessary complexity for a single-recipient notification email

### No New Library: Cloudflare Web Analytics

The beacon is a CDN-hosted script tag — no npm package, no build step change. The token is public (safe to commit to source).

**Embed in `BaseHead.astro`** (before `</head>`):
```html
<script
  defer
  src="https://static.cloudflareinsights.com/beacon.min.js"
  data-cf-beacon='{"token": "YOUR_TOKEN_HERE"}'
></script>
```

Token is obtained from Cloudflare Dashboard → Analytics & Logs → Web Analytics → Add site. The token is site-specific and non-secret.

**Why manual embed, not dashboard auto-inject:** Auto-injection only works reliably for Cloudflare Pages and proxied sites. Workers-deployed static assets do not receive automatic beacon injection. Manual embed in `BaseHead.astro` is the correct and reliable approach.

**Privacy:** No cookies. No personal data collected. GDPR-compliant by default. Tracks: pageviews, referrers, top pages, browser/country. Uses browser `Performance API`.

### No New Library: Content Updates

Team photos and social proof copy are plain content edits:
- Team member photos → `public/images/team/` (served as static assets)
- Markup changes in `src/pages/about.astro` and `src/pages/index.astro`
- Astro's built-in `<Image />` from `astro:assets` is already available for optimization — no new package needed

---

## Architecture Change: Adding a Worker Script

The current `wrangler.jsonc` is assets-only (no `main` field). Adding Resend requires a Worker script to handle the `POST /api/contact` endpoint.

**How assets + Worker coexist (Cloudflare routing, default behavior):**
1. Request arrives for `/api/contact` → no static asset matches → Worker `fetch()` handler runs
2. Request arrives for `/features` → static HTML in `./dist/` matches → served directly, Worker not invoked

This is documented behavior in Cloudflare's static-assets routing system. No SSR adapter, no `@astrojs/cloudflare`, no change to Astro's build output.

**Updated `wrangler.jsonc`:**
```jsonc
{
  "name": "rally-trivia-build",
  "compatibility_date": "2025-10-08",
  "main": "src/worker.ts",
  "assets": {
    "directory": "./dist",
    "binding": "ASSETS"
  }
}
```

The `binding: "ASSETS"` exposes the static asset store to the Worker script via `env.ASSETS.fetch(request)`, used as a fallback for any request that doesn't match an API route.

**`src/worker.ts` pattern:**
```typescript
import { Resend } from 'resend';

interface Env {
  RESEND_API_KEY: string;
  ASSETS: Fetcher;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    // Handle CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type',
        },
      });
    }

    if (url.pathname === '/api/contact' && request.method === 'POST') {
      return handleContact(request, env);
    }

    // Fall through: serve static assets for all other routes
    return env.ASSETS.fetch(request);
  },
};

async function handleContact(request: Request, env: Env): Promise<Response> {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };

  try {
    const body = await request.json() as Record<string, string>;
    const resend = new Resend(env.RESEND_API_KEY);

    const { error } = await resend.emails.send({
      from: 'Rally Trivia <noreply@rallytrivia.com>',
      to: ['demo@rallytrivia.com'],           // Single recipient, no auto-reply
      subject: `Demo Request from ${body.name ?? 'Unknown'}`,
      html: `
        <h2>New Demo Request</h2>
        <p><strong>Name:</strong> ${body.name}</p>
        <p><strong>Email:</strong> ${body.email}</p>
        <p><strong>Organization:</strong> ${body.organization ?? 'Not provided'}</p>
        <p><strong>Message:</strong> ${body.message ?? 'None'}</p>
      `,
    });

    if (error) {
      return Response.json({ success: false, message: 'Email delivery failed' }, {
        status: 500,
        headers: corsHeaders,
      });
    }

    return Response.json({ success: true }, { headers: corsHeaders });
  } catch {
    return Response.json({ success: false, message: 'Invalid request' }, {
      status: 400,
      headers: corsHeaders,
    });
  }
}
```

**Local development:** Create `.dev.vars` (gitignored) for secrets:
```
RESEND_API_KEY=re_your_key_here
```

Run `npx wrangler dev` (not `astro dev`) to test the Worker locally.

**Production secret setup (one-time):**
```bash
npx wrangler secret put RESEND_API_KEY
```

---

## Installation

```bash
# Only new npm dependency
npm install resend@^6.9.0
```

No other packages needed for this milestone.

---

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| `resend@^6.9.0` direct SDK | Resend REST via `fetch()` | Never — the SDK provides TypeScript types and error handling for no meaningful overhead |
| Standalone `src/worker.ts` | `@astrojs/cloudflare` adapter + hybrid SSR | Use adapter only if you need full Astro SSR (server-rendered pages, middleware, etc.) — overkill for one API endpoint |
| Manual beacon in `BaseHead.astro` | Cloudflare dashboard auto-inject | Auto-inject is unreliable for Workers-served static sites; manual is deterministic |
| Cloudflare Web Analytics | Google Analytics 4 | GA4 requires cookie consent banner (GDPR); CWA is cookie-free and already on the same platform |
| Cloudflare Web Analytics | Plausible / Fathom | Both cost money (Plausible ~$9/mo, Fathom ~$14/mo); CWA is free and sufficient for this scale |
| Plain HTML email body | React Email (`@react-email/components`) | React Email adds JSX build complexity and a React dependency; for a single notification email, a plain HTML string is sufficient and simpler |

---

## What NOT to Add

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| `@astrojs/cloudflare` adapter | Converts the Astro build to SSR mode, changes build output structure, adds Sharp compatibility requirements — all unnecessary for a single `POST` endpoint | Standalone `src/worker.ts` with `main` in `wrangler.jsonc` |
| `nodemailer` | Does not run in Cloudflare's V8 isolate runtime (not Node.js) | `resend` SDK |
| `@react-email/components` | Adds React as a dependency for email templates — far more than needed | Plain HTML string in `resend.emails.send({ html: "..." })` |
| `formspree` / `web3forms` / `netlify forms` | Third-party SaaS for form handling adds another vendor; less control; Resend is first-party via Workers | `resend` on Cloudflare Workers |
| Cloudflare D1 or KV storage | No persistence needed — this is a fire-and-forget email notification | Nothing; Resend logs delivery in its own dashboard |
| Any CRM integration (HubSpot, Salesforce) | Explicitly out-of-scope per PROJECT.md — decide on tooling later | Just the Resend email notification |

---

## Version Compatibility

| Package | Compatible With | Notes |
|---------|-----------------|-------|
| `resend@6.9.2` | Cloudflare Workers (V8 isolate) | v6.9.2 explicitly added non-Node environment compatibility; use `^6.0.0` minimum |
| `resend@6.9.2` | `wrangler@4.67.0` | No conflicts — Wrangler's esbuild bundler handles the resend ESM import |
| `resend@6.9.2` | `astro@5.16.2` | No interaction — Resend only runs in `src/worker.ts`, not in Astro's build pipeline |
| Cloudflare Web Analytics beacon | All modern browsers | Uses `Performance API`; degrades gracefully if ad-blocked (no error thrown) |
| `src/worker.ts` + `assets.directory` | `wrangler@4.67.0` | Supported — Wrangler 4.x handles the `main` + `assets` combination natively |

---

## Sources

- [npmjs.com / `npm view resend version`](https://www.npmjs.com/package/resend) — version `6.9.2` confirmed via registry (HIGH confidence)
- [GitHub: resend/resend-node releases](https://github.com/resend/resend-node/releases) — v6.9.2 changelog confirms Cloudflare Workers + non-Node environment support (HIGH confidence)
- [Cloudflare Docs: Send Emails with Resend (Workers tutorial)](https://developers.cloudflare.com/workers/tutorials/send-emails-with-resend/) — Worker pattern, `env.RESEND_API_KEY`, `.dev.vars` secrets (HIGH confidence)
- [Resend Docs: Send with Cloudflare Workers](https://resend.com/docs/send-with-cloudflare-workers) — `new Resend(env.RESEND_API_KEY)`, `emails.send()` API (HIGH confidence)
- [Cloudflare Docs: Worker Script + Static Assets routing](https://developers.cloudflare.com/workers/static-assets/routing/worker-script/) — `main` + `assets` coexistence; default routing: static first, Worker on miss (HIGH confidence)
- [Cloudflare Docs: Wrangler Configuration](https://developers.cloudflare.com/workers/wrangler/configuration/) — `assets.binding` + `main` field together (HIGH confidence)
- [Cloudflare Docs: Web Analytics Get Started](https://developers.cloudflare.com/web-analytics/get-started/) — beacon script format, auto-inject requirements (HIGH confidence)
- [Cloudflare Community: Web Analytics JS token injection](https://community.cloudflare.com/t/web-analytics-not-injecting-the-js-token/860770) — confirmed auto-inject unreliable for Workers deployments (MEDIUM confidence — community source)
- [Cloudflare Docs: Astro + Resend (Developer Spotlight)](https://developers.cloudflare.com/developer-spotlight/tutorials/handle-form-submission-with-astro-resend/) — Official Cloudflare endorsement of Resend for Astro form submissions (HIGH confidence)

---

*Stack research for: Rally Trivia v1.1 — form backend (Resend + Workers), Cloudflare Web Analytics, content updates*
*Researched: 2026-02-22*
