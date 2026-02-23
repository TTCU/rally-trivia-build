# Architecture Research

**Domain:** Astro static site with Cloudflare Workers API backend and third-party analytics
**Researched:** 2026-02-22
**Confidence:** HIGH

---

## v1.1 Integration Architecture

This section covers integration of the three new features: Resend form backend, Cloudflare Web Analytics, and content updates. It assumes the existing v1.0 architecture (documented below) is in place and working.

### What Changes in v1.1 vs v1.0

| Area | v1.0 State | v1.1 Change |
|------|-----------|-------------|
| `wrangler.jsonc` | `assets.directory` only, no Worker script | Add `main`, `assets.binding`, `assets.run_worker_first` |
| `worker/index.ts` | Does not exist | NEW: handles POST /api/contact, proxies all other requests to ASSETS |
| `ContactForm.astro` | Simulated 1.5s delay, never posts anywhere | Replace fake submit with real `fetch('/api/contact')`, wire success/error to existing UI states |
| `BaseHead.astro` | No analytics | Add single `<script defer>` Cloudflare Web Analytics beacon tag |
| `src/pages/index.astro` | Placeholder social proof stats | Rework social proof section — qualitative highlights, no fake numbers |
| `src/pages/about.astro` | Placeholder team members | Replace with real names, titles, and photos |
| `package.json` | No email dependency | Add `resend` npm package |
| Wrangler secrets | None | Add `RESEND_API_KEY` via `wrangler secret put` |

Nothing else in the architecture changes. Build process, Astro config, Tailwind, and all other pages remain untouched.

### System Overview — Current (v1.0)

```
Browser
  |
  | GET any page
  v
Cloudflare Workers (assets only)
  wrangler.jsonc: assets.directory = "./dist"
  No main entrypoint — pure static delivery
  Serves pre-built HTML/CSS/JS from Astro build
```

### System Overview — Target (v1.1)

```
┌────────────────────────────────────────────────────────────────┐
│                         Browser                                │
│                                                                │
│  Static pages (Astro HTML/CSS/JS)                              │
│  ContactForm.astro — POST /api/contact via fetch()             │
│  CF Analytics beacon.min.js — deferred, from CF CDN           │
└──────────────┬──────────────────────────┬──────────────────────┘
               │ GET (all non-API routes) │ POST /api/contact
               v                          v
┌──────────────────────────────────────────────────────────────────┐
│             Cloudflare Workers (assets + Worker script)          │
│                                                                  │
│  wrangler.jsonc:                                                 │
│    main = "worker/index.ts"                                      │
│    assets.directory = "./dist"                                   │
│    assets.binding = "ASSETS"                                     │
│    assets.run_worker_first = ["/api/*"]                          │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │  worker/index.ts (NEW)                                   │    │
│  │  POST /api/contact → validate → Resend.send()            │    │
│  │  All other routes → env.ASSETS.fetch(request)            │    │
│  └──────────────────────────────────────────────────────────┘    │
└────────────────────────────────┬─────────────────────────────────┘
                                 │ HTTPS (Resend SDK)
                                 v
┌──────────────────────────────────────────────────────────────────┐
│  Resend API (api.resend.com)                                      │
│  Delivers to single recipient (demo@rallytrivia.com)             │
│  Auth: RESEND_API_KEY wrangler secret (never in source code)     │
└──────────────────────────────────────────────────────────────────┘
```

### Component Map: New vs Modified vs Unchanged

| File | Status | What Changes |
|------|--------|--------------|
| `worker/index.ts` | NEW | Entire file. POST /api/contact handler + ASSETS proxy fallback |
| `wrangler.jsonc` | MODIFIED | Add `main`, `assets.binding`, `assets.run_worker_first` |
| `package.json` | MODIFIED | Add `"resend"` to dependencies |
| `src/components/ContactForm.astro` | MODIFIED | Replace simulated submit delay with real fetch to /api/contact; add error handling for failed requests |
| `src/components/BaseHead.astro` | MODIFIED | Add CF Web Analytics `<script defer>` tag before `</head>` |
| `src/pages/about.astro` | MODIFIED | Replace placeholder team section with real member data + photos |
| `src/pages/index.astro` | MODIFIED | Rework social proof section — remove fake stats, add qualitative highlights |
| `src/layouts/BaseLayout.astro` | UNCHANGED | |
| `src/components/Nav.astro` | UNCHANGED | |
| `src/components/Footer.astro` | UNCHANGED | |
| `src/pages/features.astro` | UNCHANGED | |
| `src/pages/contact.astro` | UNCHANGED | |

### New Data Flows

**Form Submission (v1.1):**
```
User fills form
  → client-side validation (existing, unchanged)
  → validateAll() passes
  → ContactForm.astro submit handler
  → fetch('/api/contact', { method: 'POST', body: JSON.stringify(formData) })
  → Cloudflare edge: run_worker_first matches /api/*
  → worker/index.ts handleContact()
  → server-side validation (name, email required)
  → Resend API → email delivered to demo@rallytrivia.com
  → Response.json({ ok: true }) OR Response.json({ error }, { status: 500 })
  → ContactForm: success → thank-you animation (existing, unchanged)
             OR: error → re-enable button, show inline error message
```

**Analytics Data Flow:**
```
Browser loads any page
  → BaseHead.astro includes beacon script (deferred — no render blocking)
  → beacon.min.js loads from static.cloudflareinsights.com after page interactive
  → fires page view + Core Web Vitals to CF Analytics
  → visible in Cloudflare Dashboard → Web Analytics
  No PII, no cookies, GDPR-compliant by default
```

**Content Updates (team, social proof):**
```
Edit src/pages/about.astro (team data)
Edit src/pages/index.astro (social proof section)
Add team photos to public/images/team/
  → astro build → updated static HTML in dist/
  → wrangler deploy → pushed to Cloudflare edge
Pure static — no runtime data flow, no new components needed
```

### Integration Patterns

#### Pattern A: Worker-Augmented Static Site

The key architectural decision: keep Astro in static output mode and add a standalone Worker script for the single API endpoint. This avoids the `@astrojs/cloudflare` SSR adapter entirely.

**`wrangler.jsonc` after change:**
```jsonc
{
  "name": "rally-trivia-build",
  "compatibility_date": "2025-10-08",
  "main": "worker/index.ts",
  "assets": {
    "directory": "./dist",
    "binding": "ASSETS",
    "run_worker_first": ["/api/*"]
  }
}
```

**`worker/index.ts` (new file):**
```typescript
import { Resend } from 'resend';

interface Env {
  ASSETS: Fetcher;
  RESEND_API_KEY: string;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    if (request.method === 'POST' && url.pathname === '/api/contact') {
      return handleContact(request, env);
    }

    // All other requests: serve static assets
    return env.ASSETS.fetch(request);
  },
};

async function handleContact(request: Request, env: Env): Promise<Response> {
  let body: Record<string, string>;
  try {
    body = await request.json();
  } catch {
    return Response.json({ error: 'Invalid request body' }, { status: 400 });
  }

  const { name, email, organization, eventType, message } = body;

  if (!name?.trim() || !email?.trim()) {
    return Response.json({ error: 'Name and email are required' }, { status: 400 });
  }

  const resend = new Resend(env.RESEND_API_KEY);

  const { error } = await resend.emails.send({
    from: 'Rally Trivia <noreply@rallytrivia.com>',
    to: ['demo@rallytrivia.com'],
    subject: `Demo Request from ${name}`,
    html: `
      <p><strong>Name:</strong> ${name}</p>
      <p><strong>Email:</strong> ${email}</p>
      <p><strong>Organization:</strong> ${organization || '—'}</p>
      <p><strong>Event Type:</strong> ${eventType || '—'}</p>
      <p><strong>Message:</strong> ${message || '—'}</p>
    `,
  });

  if (error) {
    return Response.json({ error: 'Failed to send. Please try again.' }, { status: 500 });
  }

  return Response.json({ ok: true });
}
```

Source: [Cloudflare Workers Static Assets Binding docs](https://developers.cloudflare.com/workers/static-assets/binding/) — HIGH confidence

#### Pattern B: Cloudflare Web Analytics Script Tag in BaseHead

One-line addition to `src/components/BaseHead.astro`. Token is a public identifier (not a secret) — safe to commit to source.

**Addition to `BaseHead.astro` (before `</head>`):**
```html
<!-- Cloudflare Web Analytics -->
<script
  defer
  src="https://static.cloudflareinsights.com/beacon.min.js"
  data-cf-beacon='{"token": "YOUR_TOKEN_HERE"}'
></script>
```

Token obtained from: Cloudflare Dashboard → Web Analytics → Add Site → Copy snippet. Replace `YOUR_TOKEN_HERE` with the actual token value.

`defer` ensures the beacon script never blocks page rendering. No npm package needed. No build change needed.

Source: [Cloudflare Web Analytics FAQs](https://developers.cloudflare.com/web-analytics/faq/) — HIGH confidence

#### Pattern C: ContactForm Submit Handler Replacement

The existing form UI, validation, loading state, and thank-you animation are all preserved. Only the simulated delay block is replaced with a real fetch call.

**Replace in `ContactForm.astro` `<script>` block — the simulated delay:**
```typescript
// REMOVE this:
await new Promise((resolve) => setTimeout(resolve, 1500));

// REPLACE with:
const formData = {
  name: (form.querySelector('#name') as HTMLInputElement).value.trim(),
  email: (form.querySelector('#email') as HTMLInputElement).value.trim(),
  organization: (form.querySelector('#organization') as HTMLInputElement).value.trim(),
  eventType: (form.querySelector('#event-type') as HTMLSelectElement).value,
  message: (form.querySelector('#message') as HTMLTextAreaElement).value.trim(),
};

const res = await fetch('/api/contact', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(formData),
});

if (!res.ok) {
  // Re-enable button, show error state
  btn.disabled = false;
  btnText.classList.remove('hidden');
  btnSpinner.classList.add('hidden');
  // Show error banner (reuse existing #error-summary element)
  const errorSummary = document.getElementById('error-summary')!;
  const errorList = document.getElementById('error-list')!;
  errorList.innerHTML = '<li>Something went wrong. Please try again or email us directly.</li>';
  errorSummary.classList.remove('hidden');
  return;
}

// Continue to existing animate/thank-you block unchanged
```

### Anti-Patterns for v1.1

#### Anti-Pattern 1: Using @astrojs/cloudflare SSR Adapter for the Form Endpoint

**What people do:** `npx astro add cloudflare`, set `output: 'server'`, create `src/pages/api/contact.ts` as an Astro API route.

**Why it's wrong:** Switching to SSR means every page request goes through a Worker at runtime — no more static edge caching. Adds the adapter package, changes the build pipeline, and converts a static site to a server-rendered one for the sake of one POST endpoint. This is the wrong tool for this job.

**Do this instead:** Keep `output: 'static'`. Add `worker/index.ts` with `run_worker_first = ["/api/*"]`. Static pages stay fully cached; only the contact form endpoint hits the Worker.

#### Anti-Pattern 2: Storing Resend API Key in Source Code or wrangler.jsonc

**What people do:** Hardcode `new Resend('re_live_xxxxxxxxx')` in `worker/index.ts`.

**Why it's wrong:** Key is committed to git history and visible in deployed Worker bundles. Anyone can use it to send unlimited email from your Resend account.

**Do this instead:** `npx wrangler secret put RESEND_API_KEY`. Access in Worker via `env.RESEND_API_KEY`. The key never appears in any file.

#### Anti-Pattern 3: Calling Resend from the Browser

**What people do:** Import `resend` client-side to avoid building a Worker.

**Why it's wrong:** The Resend API key would be visible in browser JavaScript. Anyone could extract it and send email from your account.

**Do this instead:** Browser calls `/api/contact` on your own domain. Worker calls Resend server-side with the secret key.

#### Anti-Pattern 4: Adding CF Analytics Script in Body Instead of BaseHead

**What people do:** Add the beacon `<script>` at the bottom of `<body>` or in a layout slot.

**Why it's wrong:** This codebase already has `BaseHead.astro` as the canonical location for all `<head>` content. Adding analytics elsewhere creates an inconsistency and means it won't benefit from the `defer` attribute semantics in `<head>`.

**Do this instead:** One `<script defer ...>` line in `BaseHead.astro` before `</head>`. Appears on every page automatically.

### Build Order for v1.1

Dependencies between v1.1 tasks determine the recommended sequence:

```
Step 1: wrangler.jsonc — add main, binding, run_worker_first
        worker/index.ts — stub handler (return { ok: true } immediately, no Resend yet)
        Verify: wrangler dev → POST /api/contact returns 200
               GET / → still serves index.html correctly
        This confirms routing works before adding email complexity.

Step 2: npm install resend
        wrangler secret put RESEND_API_KEY
        Wire Resend into worker/index.ts handleContact()
        Verify: wrangler dev → POST /api/contact → email delivered to inbox

Step 3: ContactForm.astro — replace simulated delay with real fetch to /api/contact
        Wire success (existing thank-you animation) and failure (error banner) paths
        Verify: full end-to-end in browser via wrangler dev

Step 4: BaseHead.astro — add CF Web Analytics script tag
        (Requires CF dashboard token — independent of Steps 1-3)
        Verify: view source on any page, confirm script tag present

Step 5: src/pages/index.astro — rework social proof section
        src/pages/about.astro — replace placeholder team section
        public/images/team/ — add real photos
        (Pure static, fully independent of all backend work)
        Verify: visual QA on rebuilt site
```

Steps 4 and 5 are fully independent of Steps 1-3 and can be done in any order or in parallel.

### Integration Points Summary

| Integration | Pattern | Auth | Files Touched |
|-------------|---------|------|---------------|
| Resend API | Worker POST handler calls SDK | `RESEND_API_KEY` wrangler secret | `worker/index.ts`, `package.json` |
| Cloudflare Workers routing | `run_worker_first = ["/api/*"]` | None | `wrangler.jsonc` |
| Cloudflare Web Analytics | `<script defer>` tag | Public token in HTML attr | `src/components/BaseHead.astro` |
| Form → Worker | `fetch('/api/contact')` JSON POST | None (same origin) | `src/components/ContactForm.astro` |

---

## v1.0 Architecture (Reference)

The foundation this milestone builds on.

### Standard Architecture (v1.0)

```
Browser → Cloudflare Workers (assets only) → pre-built HTML/CSS/JS from Astro

wrangler.jsonc: { "assets": { "directory": "./dist" } }
No main entrypoint. Pure static delivery.
```

### Component Responsibilities (v1.0)

| Component | Responsibility |
|-----------|----------------|
| `src/layouts/BaseLayout.astro` | Full HTML shell, meta tags, global styles, nav, footer |
| `src/pages/index.astro` | Landing page: hero, value props, social proof, dual-audience CTA |
| `src/pages/features.astro` | 12-card icon grid of platform capabilities |
| `src/pages/about.astro` | Mission narrative and team section |
| `src/pages/contact.astro` | Demo request form page wrapper |
| `src/components/Nav.astro` | Site navigation — logo, links, mobile hamburger |
| `src/components/Footer.astro` | Footer — links, copyright |
| `src/components/ContactForm.astro` | Form fields with client-side validation, simulated submit |
| `src/components/BaseHead.astro` | `<head>` — meta, OG tags, canonical URL |
| `src/components/ScrollAnimations.astro` | Intersection Observer-based fade-in animations |
| `public/` | Logo images, favicon — served as-is |

### Project Structure (v1.0)

```
rally-trivia-web/
├── src/
│   ├── pages/
│   │   ├── index.astro
│   │   ├── features.astro
│   │   ├── about.astro
│   │   └── contact.astro
│   ├── layouts/
│   │   └── BaseLayout.astro
│   ├── components/
│   │   ├── BaseHead.astro
│   │   ├── Nav.astro
│   │   ├── Footer.astro
│   │   ├── ContactForm.astro
│   │   └── ScrollAnimations.astro
│   ├── styles/
│   │   └── global.css
│   ├── consts.ts
│   └── env.d.ts
├── public/
│   └── favicon.svg
├── assets/
│   └── images/            # Brand logos (PNG + SVG)
├── wrangler.jsonc
├── astro.config.mjs
├── tsconfig.json
└── package.json
```

### Anti-Patterns (v1.0)

#### Installing the Cloudflare Adapter for a Static Site

**What people do:** Run `npx astro add cloudflare` because the project deploys to Cloudflare, then set `output: 'server'`.
**Why it's wrong:** Switches Astro to server-side rendering — a Worker runs on every request. Wastes compute, adds latency, no benefit for a marketing site with pre-known content.
**Do this instead:** `output: 'static'` (Astro default). No adapter. `wrangler.jsonc` with `assets.directory: "./dist"` only.

#### Inline Styles Instead of Tailwind Classes

**What people do:** `style="color: #1a3a6b"` instead of `class="text-deep-blue"`.
**Why it's wrong:** Bypasses the design system; magic hex values cause brand drift; makes global token changes difficult.
**Do this instead:** Define brand palette as named Tailwind tokens. Use semantic class names throughout.

## Sources

- [Send Emails With Resend · Cloudflare Workers docs](https://developers.cloudflare.com/workers/tutorials/send-emails-with-resend/) — HIGH confidence (official)
- [Send emails with Cloudflare Workers · Resend docs](https://resend.com/docs/send-with-cloudflare-workers) — HIGH confidence (official)
- [Configuration and Bindings · Cloudflare Workers Static Assets](https://developers.cloudflare.com/workers/static-assets/binding/) — HIGH confidence (official)
- [Static Assets · Cloudflare Workers docs](https://developers.cloudflare.com/workers/static-assets/) — HIGH confidence (official)
- [Enabling Cloudflare Web Analytics · Cloudflare docs](https://developers.cloudflare.com/web-analytics/get-started/) — HIGH confidence (official)
- [Cloudflare Web Analytics FAQs](https://developers.cloudflare.com/web-analytics/faq/) — HIGH confidence (official)
- [Astro Project Structure — official docs](https://docs.astro.build/en/basics/project-structure/) — HIGH confidence (official)
- [Deploy Astro to Cloudflare — official docs](https://docs.astro.build/en/guides/deploy/cloudflare/) — HIGH confidence (official)

---
*Architecture research for: Rally Trivia v1.1 — Resend form backend, Cloudflare Web Analytics, content updates*
*Researched: 2026-02-22*
