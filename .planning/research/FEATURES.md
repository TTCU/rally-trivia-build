# Feature Research

**Domain:** SaaS marketing/landing site — live event trivia platform targeting nonprofit fundraisers and corporate events
**Researched:** 2026-02-22
**Confidence:** HIGH (core form backend verified against Cloudflare official docs and Resend official docs; analytics verified against Cloudflare official docs; social proof and team section patterns verified against multiple practitioner sources)

---

## Scope Note

This file covers both the original v1.0 feature landscape and the **v1.1 Production Polish** milestone features. The v1.1 additions are:

1. Form backend email delivery — Resend API on Cloudflare Workers
2. Cloudflare Web Analytics integration
3. Social proof rework — qualitative highlights replacing placeholder stats
4. Real team section on About page

The v1.0 feature table and MVP definition are preserved below for historical reference. New v1.1 sections follow.

---

## Feature Landscape

### Table Stakes (Users Expect These)

Features visitors assume exist on any credible SaaS product site. Missing these makes the site feel unfinished or untrustworthy.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Hero section with value proposition headline | Every SaaS site leads with a clear outcome-focused headline. Visitors leave within 10 seconds if they can't parse what the product does. | LOW | Headline must be outcome-driven ("Run a flawless trivia fundraiser") not feature-driven. Subheadline clarifies audience and mechanism. |
| Primary CTA — demo request | Nonprofit and corporate buyers don't self-serve; they need a sales touchpoint. "Request a Demo" is the expected conversion action. | LOW | CTA must appear above the fold and repeat at logical intervals. Button label matters — "Request a Demo" outperforms "Contact Us" for software. |
| Product/platform visuals | 30% of SaaS sites don't show the product — this is a conversion killer. Visitors need confidence before booking a demo. | MEDIUM | Screenshots, interface preview, or a short video clip. Does not need to be a full interactive demo at MVP. |
| Features page with platform capabilities | Buyers research before contacting sales. A dedicated features page is expected for any non-trivial SaaS product. | MEDIUM | Should address both nonprofit and corporate use cases. Tie features to outcomes, not technical specs. |
| Social proof | 92% of buyers trust peer recommendations over advertising. Absence of social proof reads as "no customers yet." | LOW | Real qualitative highlights or testimonials. Even 2-3 genuine outcome statements are enough at launch. Numbers only when real data exists. |
| About/story page | Buyers for nonprofit-sector software want to understand the people and mission behind the product before entrusting events to it. | LOW | Who built this, why, what values drive it. Humanizes the product for relationship-oriented nonprofit buyers. |
| Contact/demo request form that actually submits | A form that does nothing is worse than no form — it destroys trust the moment a prospect submits. | MEDIUM | The form UI exists. Backend wiring is the v1.1 gap. Single recipient, no auto-reply, reasonable error handling. |
| Responsive design (mobile, tablet, desktop) | 83% of web visits are mobile. Non-responsive site signals neglect and directly harms bounce rate. | MEDIUM | Already shipped in v1.0. |
| Shared navigation and footer | Visitors need to find their way around. Lack of consistent nav erodes professionalism. | LOW | Already shipped in v1.0. |

### Differentiators (Competitive Advantage)

Features that set Rally Trivia's site apart from generic event platform competitors.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Dual audience messaging — nonprofit vs. corporate | Competitors pick one segment; Rally serves both. Showing clear use cases for each audience reduces bounce and improves relevance. | MEDIUM | Already shipped in v1.0 as dual audience cards. |
| Pain-point-first messaging for event organizers | Most event platform sites lead with features; leading with the actual frustrations creates immediate recognition. | LOW | Copy/content effort. Already implemented in v1.0. |
| "How it works" section with clear step-by-step flow | Event organizers want to visualize the night before they commit. A simple 3-step visual dramatically reduces objection anxiety. | LOW | Already shipped in v1.0. |
| Qualitative social proof highlights (not fake stats) | Authentic highlights about real capabilities ("Every screen branded to your event," "Questions generated in seconds") land better than fabricated numbers. Non-profits are sophisticated enough to detect fake social proof and it destroys trust. | LOW | Replaces placeholder stat blocks with honest qualitative outcome statements. No vanity metrics. |
| Real team section with names and photos | "Placeholder team members" on a live site signals the site is unfinished. Real names and headshots establish the founders are real people investing in the product. | LOW | Data entry effort, not engineering effort. Grid layout already exists — swap placeholders with real data and real photos. |
| Clear demo value framing | Stating "30-minute walkthrough, no sales pressure, see the host dashboard live" reduces booking friction for time-scarce nonprofit staff. | LOW | One paragraph of copy on the contact page. Already partially present. |
| Analytics visibility into conversion funnel | Understanding where visitors drop off allows improvement. Without analytics, the site is flying blind. | LOW | Cloudflare Web Analytics is free, privacy-friendly, requires a single script tag. No user consent pop-up required (no cookie tracking). |

### Anti-Features (Commonly Requested, Often Problematic)

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Form auto-reply email to submitter | Feels professional; confirms receipt to the prospect. | Requires a verified "from" domain, adds Reply-To complexity, and is an additional Resend email. More importantly, auto-replies get filtered as transactional spam and rarely seen. The thank-you UI state already confirms submission to the user. | Animated thank-you state (already built) confirms receipt. No auto-reply needed at this stage. |
| Google Analytics / GA4 | Familiar, feature-rich analytics. | GA4 requires a cookie consent banner to comply with GDPR/CCPA for EU/CA users. Adds JS weight. Overkill for a simple marketing site at this stage. | Cloudflare Web Analytics — cookieless, privacy-first, free, no consent banner required. |
| Honeypot + CAPTCHA on contact form | Prevents bot spam. | CAPTCHAs introduce significant friction and drop conversion rates. At early traction volumes, spam is not yet a real problem. Honeypot alone is sufficient. | Simple hidden honeypot field (a hidden input bots fill but humans don't). No CAPTCHA. Add rate limiting later if spam becomes an issue. |
| Pricing page | Users often ask "how much does it cost?" | Rally Trivia is not ready to publish pricing. A "Contact for pricing" page highlights the absence. | Acknowledge pricing on the demo request page: "Pricing is tailored to your event size — we'll walk you through options on the demo." |
| Blog / content marketing section | SEO value long-term. | A blog with 0-2 posts looks worse than no blog. Distraction from core conversion goal. | Defer to v2 once content production is resourced. |
| Live chat widget | Feels responsive; good conversion tool. | Operational overhead at this stage. Intrusive on B2B nonprofit sites. | Demo request form is sufficient. Add chat after launch when volume justifies it. |
| Fake/estimated stats ("100+ events run") | Social proof fills a credibility gap. | Nonprofit coordinators specifically are skilled at detecting fabricated social proof. Getting caught with made-up numbers destroys all trust. Legal exposure for false advertising. | Use qualitative outcome highlights instead. "Every screen branded to your mission" is honest and concrete. |
| Calendly/scheduling embed | Reduces back-and-forth scheduling. | Explicitly out of scope per PROJECT.md. Forces a calendar commitment Rally Trivia may not be ready to operationalize. | Simple form. Manual scheduling follow-up. |

---

## v1.1 Feature Details

### 1. Form Backend — Email Delivery via Resend on Cloudflare Workers

**What it does:** When a visitor submits the demo request form, an HTTP POST request is made to a Cloudflare Worker endpoint (`/api/contact`) which calls the Resend API to send an email to the Rally Trivia team.

**Expected behavior pattern:**
- Form submits via `fetch()` POST to `/api/contact` with JSON body (name, email, org, event type, message)
- Worker validates the body (required fields), calls Resend SDK to send a notification email to a single recipient
- Worker returns `200 OK` with JSON `{ success: true }` on success, `400` or `500` on error
- Front-end already shows the animated thank-you state — it should do so only on `200`, show a friendly error message on failure
- No auto-reply to the submitter
- RESEND_API_KEY stored as a Wrangler secret (not in code)

**Architecture change required:** The existing `wrangler.jsonc` is purely static (`assets.directory: ./dist` with no `main` entry). Adding a Worker endpoint requires:
- A `src/worker.ts` (or similar) entry point file
- Adding `"main": "src/worker.ts"` to `wrangler.jsonc`
- Adding `"run_worker_first": ["/api/*"]` to the `assets` block so POST to `/api/contact` hits the Worker, not the static asset handler
- `npm install resend` in the project

**Complexity:** MEDIUM — the Resend + Workers integration is well-documented with official Cloudflare tutorials. The main work is the wrangler.jsonc restructuring to support a mixed static + Worker deploy, writing the Worker handler, and updating the front-end fetch call. The existing form UI is already built.

**Key constraints:**
- Resend requires a verified sending domain (DNS DKIM/SPF/DMARC records) — this is a prerequisite that must be completed before the Worker can send
- The Resend free tier allows 100 emails/day and 3,000/month — sufficient for a low-volume demo request form
- CORS is not needed if the form fetch is same-origin (i.e., the worker is deployed to the same Cloudflare zone as the site)
- The existing form submit handler uses a simulated 1500ms delay — this must be replaced with a real `fetch('/api/contact', { method: 'POST', ... })` call

**Dependencies:** Requires real Resend account + domain verification before deployment. Worker endpoint must exist before front-end can be wired.

| Sub-feature | Complexity | Notes |
|-------------|------------|-------|
| Cloudflare Worker endpoint (`/api/contact`) | MEDIUM | New file; wrangler.jsonc change; Resend SDK integration |
| wrangler.jsonc restructuring (static + Worker) | LOW | Add `main` field and `run_worker_first` to assets config |
| Resend domain verification | LOW (setup) | DNS records in Cloudflare — DKIM, SPF, DMARC. One-time setup. |
| Front-end fetch call replacing simulated delay | LOW | Replace `setTimeout` with real `fetch('/api/contact', ...)` |
| Error state in form UI | LOW | Show user-visible error if Worker returns non-200 |
| Resend API key as Wrangler secret | LOW | `npx wrangler secret put RESEND_API_KEY` |

---

### 2. Cloudflare Web Analytics

**What it does:** Adds privacy-first, cookieless analytics to every page. Tracks page views, visit duration, referrers, top pages, and browser/device breakdown. Data visible in Cloudflare dashboard.

**Expected behavior pattern:**
- A single `<script>` beacon tag is added to every page (via `BaseLayout.astro` or `BaseHead.astro`)
- No cookies set, no user consent banner required (Cloudflare Web Analytics is cookieless and GDPR-compliant by design)
- Data appears in Cloudflare dashboard under Web Analytics within a few minutes of deploy

**Beacon snippet:**
```html
<script defer src='https://static.cloudflareinsights.com/beacon.min.js'
  data-cf-beacon='{"token": "YOUR_TOKEN"}'></script>
```

**Setup options:**
- **Automatic (for Cloudflare Pages):** Cloudflare auto-injects the script on next deployment
- **Manual (for Cloudflare Workers / this project):** Add the script tag to `BaseHead.astro` with the token from the Cloudflare dashboard
- This project uses Workers (not Pages), so manual script tag insertion is the correct approach

**Complexity:** LOW — one script tag in `BaseHead.astro`. Token is not a secret (it's embedded in public HTML). No npm package needed, no build changes, no env vars.

**Key constraints:**
- Requires creating a Web Analytics site in the Cloudflare dashboard to get a token — one-time setup
- Analytics data is available only after deployment (no retroactive data)
- The beacon is 8KB — negligible performance impact

| Sub-feature | Complexity | Notes |
|-------------|------------|-------|
| Add beacon script to BaseHead.astro | LOW | One line of HTML, deferred script |
| Create Web Analytics site in Cloudflare dashboard | LOW | UI setup, generates token |
| Token placement in BaseHead.astro | LOW | Hardcoded public token — not a secret |

---

### 3. Social Proof Rework — Qualitative Highlights

**What it does:** Replaces placeholder stat blocks (fake numbers) with honest qualitative highlights about what the Rally Trivia platform does and why it matters. Maintains the section's visual presence without fabricating data.

**Expected behavior pattern:**
- The "Why Teams Love Rally Trivia" section on the homepage already shows qualitative capability highlights (Native Apps + Web, Host Control Console, AI-Powered Questions, Your Brand Front & Center) — this pattern is already the correct direction
- If there is a separate "stats" section with placeholder numbers (e.g., "500+ events," "98% satisfaction"), those blocks must be replaced
- Replace with: short outcome-focused statements, real capability callouts, or honest "coming soon" framing for stats
- No testimonials with fake names or fabricated quotes

**What qualitative social proof looks like:**
- Capability highlights: "Every screen branded to your mission" (concrete, honest, specific)
- Outcome statements: "Run your event without a tech degree" (credible, relatable)
- Platform differentiators: "Questions reviewed by a human before they go live" (specific process claim)
- Authentic framing for early stage: "Designed by event organizers, for event organizers" (narrative trust, no made-up numbers)

**Complexity:** LOW — content/copy change, not engineering. The section structure and visual components already exist. This is replacing data in Astro component arrays.

**Key constraints:**
- No fabricated testimonials — do not invent customer names, organizations, or quotes
- No estimated or projected stats ("100+ events run" is not acceptable if actual event count is 0 or 5)
- If real testimonials from actual users exist, they can be added as genuine quotes with real names

| Sub-feature | Complexity | Notes |
|-------------|------------|-------|
| Audit homepage for any fake stat blocks | LOW | Review index.astro and about.astro for placeholder numbers |
| Replace fake stats with capability highlights | LOW | Content writing + data update in Astro component arrays |
| Add genuine testimonials if available | LOW | Add real quotes with name/org/role — only if real data exists |

---

### 4. Real Team Section

**What it does:** Replaces the three placeholder team members (`[Founder Name]`, `[Team Member]`) in `about.astro` with real names, titles, bios (optional), and real headshot photos.

**Expected behavior pattern:**
- Names and titles are the minimum. Real photos are strongly preferred over placeholder avatar circles.
- Standard pattern: 3-column grid on desktop, stacked on mobile (already built)
- Photo: circular or rounded crop, consistent sizing (e.g., 112x112px or 200x200px), consistent lighting/background treatment across all headshots
- Optional bio: 1-2 sentences about background or role focus
- Optional LinkedIn link: common on B2B SaaS team sections, adds credibility

**Layout considerations for small teams:**
- 2-3 people: center the cards in the grid row rather than leaving empty grid cells on the right
- 1 person: use a wider single-card layout or a split image/text layout rather than a small grid cell
- If only a founder is ready to be named, show one card well rather than filling fake cards

**Photo format:**
- Preferred: professional headshot or high-quality casual photo with consistent background
- Acceptable: well-lit photo, cropped to face/shoulders, consistent style across team
- Avoid: low-res phone selfies, different aspect ratios, wildly different backgrounds (creates inconsistency)
- Use Astro's `<Image>` component for optimization — store photos in `assets/images/team/`
- Format: JPEG or PNG at 400x400px source; Astro's `<Image>` will output WebP at appropriate size

**Complexity:** LOW (engineering) + depends on content availability (photos/bios). The grid layout already exists. Work is replacing the data array in `about.astro` and adding real photos to the assets directory.

| Sub-feature | Complexity | Notes |
|-------------|------------|-------|
| Replace placeholder names and titles in about.astro | LOW | Data update in component array |
| Add real headshot photos to assets/images/team/ | LOW | File addition; Astro `<Image>` component usage |
| Update avatar placeholder divs to real `<Image>` elements | LOW | Small markup change per card |
| Optional: add bio text | LOW | Copy addition |
| Optional: add LinkedIn links | LOW | Link addition |
| Handle grid centering for small team (1-2 people) | LOW | Tailwind justify-center on grid container |

---

## Feature Dependencies

```
[Form Backend Worker — /api/contact]
    └──requires──> [Resend account + domain verification] (DNS records must be live first)
    └──requires──> [wrangler.jsonc restructuring] (main + run_worker_first)
    └──requires──> [RESEND_API_KEY Wrangler secret] (set before deploy)

[Form Frontend — fetch() call]
    └──requires──> [Form Backend Worker] (endpoint must exist before front-end can call it)
    └──replaces──> [Simulated setTimeout delay] (existing fake submit behavior)

[Cloudflare Web Analytics]
    └──requires──> [Cloudflare dashboard setup] (generate token first)
    └──integrates-into──> [BaseHead.astro] (beacon script tag, no other dependencies)

[Real Team Section]
    └──requires──> [Real photos available] (content dependency, not engineering)
    └──replaces──> [Placeholder avatar divs in about.astro]

[Social Proof Rework]
    └──requires──> [Audit of placeholder stat content] (find and remove fake numbers)
    └──replaces──> [Placeholder stats in index.astro / about.astro]
    └──enhances──> [Hero + CTA sections] (authentic trust signals near conversion points)

[Resend domain verification]
    └──requires──> [DNS record access in Cloudflare] (DKIM/SPF/DMARC setup)
    └──blocks──> [Form Backend Worker deployment] (Worker will fail to send until domain is verified)
```

### Dependency Notes

- **Domain verification blocks Worker deploy:** The Resend API will reject sends from an unverified domain. Domain DNS verification must be completed before the Worker is deployed. This is a one-time setup step, not an ongoing concern.
- **Worker endpoint must exist before front-end fetch:** The form's submit handler currently runs a fake 1500ms delay. The real fetch call should not be added until the Worker endpoint is deployed and tested.
- **Analytics has no blocking dependencies:** The Cloudflare Web Analytics script tag can be added in any order — it does not depend on form wiring or team content.
- **Team section is a content dependency:** The engineering work (replacing placeholder markup) is trivial. The blocker is having real photos and names ready. If only some team members are ready, ship what's available rather than waiting.
- **Social proof rework has no blocking dependencies:** It is purely a content change. Can be done in parallel with any other work.

---

## MVP Definition

### This Milestone Ships (v1.1)

All four features are required for v1.1 completion. Ordering by dependency:

- [ ] **Cloudflare Web Analytics** — Add beacon to BaseHead.astro. No dependencies. Ship first (zero risk).
- [ ] **Social proof rework** — Replace fake stats with qualitative highlights. No dependencies. Content-only change.
- [ ] **Real team section** — Replace placeholders with real names/photos/titles. Blocked only on content availability.
- [ ] **Form backend (Resend + Worker)** — Most complex; requires domain verification first, then Worker build, then front-end wiring. Ship last within the milestone.

### Add After Validation (v1.x)

- [ ] **Quantified social proof** — Add real stats from events once Rally Trivia has run them ("Teams served," "Funds raised via trivia," etc.). Defer until real data exists.
- [ ] **Form rate limiting** — Add Cloudflare rate limiting rule on `/api/contact` if spam becomes an issue. Not needed at current volume.
- [ ] **Honeypot spam prevention** — Hidden `<input>` field; Worker rejects if populated. Low priority until spam occurs.
- [ ] **Form auto-reply** — Send confirmation email to submitter. Only add if demo-request-to-call conversion data suggests prospects need the reassurance.
- [ ] **Testimonials with real customer quotes** — Add genuine quotes with name/org/role once Rally Trivia has real event organizer clients willing to provide them.

### Future Consideration (v2+)

- [ ] **Blog / content marketing** — Defer until content production is resourced
- [ ] **Calendly integration** — Defer until scheduling workflow is established
- [ ] **Pricing page** — Add when pricing is ready to publish publicly
- [ ] **Case studies with detailed ROI** — Requires relationships with real event organizer clients

---

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Form backend (Resend Worker) | HIGH — broken form destroys trust | MEDIUM | P1 |
| Cloudflare Web Analytics | MEDIUM — visibility into traffic | LOW | P1 |
| Social proof rework | HIGH — removes trust-destroying fake stats | LOW | P1 |
| Real team section | MEDIUM — removes "unfinished" signal | LOW | P1 |
| Honeypot spam prevention | LOW — not yet a real problem | LOW | P2 |
| Quantified social proof | HIGH — when real data exists | LOW (data is the constraint) | P2 |
| Form auto-reply | LOW — thank-you state is sufficient | LOW | P2 |
| Rate limiting on /api/contact | LOW — not yet a real problem | LOW | P2 |
| Genuine customer testimonials | HIGH — when real clients exist | LOW (data is the constraint) | P2 |
| Blog / content marketing | MEDIUM | HIGH (ongoing) | P3 |
| Pricing page | MEDIUM | LOW | P3 |
| Calendly integration | LOW | LOW | P3 |

**Priority key:**
- P1: Required for v1.1 milestone
- P2: Add after v1.1 when trigger conditions are met
- P3: Future consideration

---

## Implementation Notes by Feature

### Form Backend — Cloudflare Worker + Resend

**Critical path:** Domain verification in Resend → Wrangler secret setup → Worker build → wrangler.jsonc update → front-end fetch wiring

**Worker structure (minimal):**
```typescript
// src/worker.ts
import { Resend } from 'resend';

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    if (url.pathname === '/api/contact' && request.method === 'POST') {
      const body = await request.json() as Record<string, string>;
      const resend = new Resend(env.RESEND_API_KEY);

      const { error } = await resend.emails.send({
        from: 'Rally Trivia Site <noreply@rallytrivia.com>',
        to: ['team@rallytrivia.com'],  // single recipient
        subject: `Demo Request: ${body.name} — ${body.organization || 'No org'}`,
        html: `<p><strong>Name:</strong> ${body.name}</p>
               <p><strong>Email:</strong> ${body.email}</p>
               <p><strong>Organization:</strong> ${body.organization || '—'}</p>
               <p><strong>Event Type:</strong> ${body.eventType || '—'}</p>
               <p><strong>Message:</strong> ${body.message || '—'}</p>`,
      });

      if (error) return Response.json({ success: false }, { status: 500 });
      return Response.json({ success: true });
    }

    // Fall through to static assets (handled by Cloudflare runtime when run_worker_first is set)
    return new Response('Not found', { status: 404 });
  }
} satisfies ExportedHandler<Env>;

interface Env {
  RESEND_API_KEY: string;
  ASSETS: Fetcher;  // bound automatically when assets.binding is set in wrangler.jsonc
}
```

**wrangler.jsonc update:**
```jsonc
{
  "name": "rally-trivia-build",
  "compatibility_date": "2025-10-08",
  "main": "src/worker.ts",
  "assets": {
    "directory": "./dist",
    "binding": "ASSETS",
    "run_worker_first": ["/api/*"]
  }
}
```

**Front-end update (ContactForm.astro submit handler):**
Replace the `await new Promise((resolve) => setTimeout(resolve, 1500))` simulation with:
```typescript
const formData = { name, email, organization, eventType, message };
const res = await fetch('/api/contact', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(formData),
});
if (!res.ok) {
  // Show error state — do not transition to thank-you
  // Re-enable submit button
  return;
}
// Proceed to animate thank-you transition
```

### Cloudflare Web Analytics

**Script tag placement:** Add to `src/components/BaseHead.astro` before `</head>`:
```html
<!-- Cloudflare Web Analytics -->
<script defer src='https://static.cloudflareinsights.com/beacon.min.js'
  data-cf-beacon='{"token": "YOUR_CF_WEB_ANALYTICS_TOKEN"}'></script>
```

The token is obtained from Cloudflare dashboard → Web Analytics → Add a site. It is not a secret — it is embedded in public HTML and that is expected behavior.

### Social Proof Rework

**Audit targets:**
- `src/pages/index.astro` — Check for any stat-based section (e.g., "500+ events," percentage claims)
- `src/pages/about.astro` — Check for any quantified achievement claims
- The "Why Teams Love Rally Trivia" section on the homepage already uses qualitative capability cards — this is the correct pattern

**Qualitative highlight examples (honest, specific):**
- "Native iOS and Android apps — no downloads required for guests" (factual capability)
- "Run your event from a single host console" (concrete, believable)
- "Questions reviewed before they go live" (process claim, builds trust)
- "Branded to your event — logos, colors, and sponsor screens on every display" (specific outcome)

### Real Team Section

**Photo handling:**
- Store photos as `assets/images/team/[name].jpg` (or `.png`)
- Use Astro `<Image>` component: `import { Image } from 'astro:assets'`
- Recommended source size: 400x400px at 2x for retina display
- Astro will auto-convert to WebP at build time (Sharp runs at build time, not runtime — safe for static output)

**Layout for small team (2-3 people):**
```astro
<!-- For 2 people: justify-center prevents lonely left-aligned card -->
<div class="grid grid-cols-1 sm:grid-cols-2 gap-10 justify-items-center max-w-lg mx-auto">
```

---

## Sources

- [Send Emails with Resend — Cloudflare Workers Docs (Official)](https://developers.cloudflare.com/workers/tutorials/send-emails-with-resend/) — HIGH confidence
- [Send with Cloudflare Workers — Resend Official Docs](https://resend.com/docs/send-with-cloudflare-workers) — HIGH confidence
- [Handle Form Submission with Astro + Resend — Cloudflare Developer Spotlight (Official)](https://developers.cloudflare.com/developer-spotlight/tutorials/handle-form-submission-with-astro-resend/) — HIGH confidence
- [Cloudflare Workers Static Assets Configuration and Bindings (Official)](https://developers.cloudflare.com/workers/static-assets/binding/) — HIGH confidence (run_worker_first pattern)
- [Enabling Cloudflare Web Analytics — Cloudflare Official Docs](https://developers.cloudflare.com/web-analytics/get-started/) — HIGH confidence
- [Enable Web Analytics — Cloudflare Pages Docs (Official)](https://developers.cloudflare.com/pages/how-to/web-analytics/) — HIGH confidence
- [Social Proof in 2025 — Marketing Rewired / Medium](https://medium.com/marketing-rewired/social-proof-in-2025-its-not-just-testimonials-anymore-715f315bc238) — MEDIUM confidence (practitioner analysis)
- [The 15 Best "Meet the Team" Pages — HubSpot](https://blog.hubspot.com/marketing/creative-agency-team-pages) — MEDIUM confidence (practitioner analysis)
- [Best Practices for "Meet the Team" Pages — Bryq](https://www.bryq.com/blog/meet-the-team) — MEDIUM confidence
- [Meet the Team Page Best Practices — Crocoblock](https://crocoblock.com/blog/meet-the-team-page-best-practices-examples/) — MEDIUM confidence
- [Astro Images Guide — Official Astro Docs](https://docs.astro.build/en/guides/images/) — HIGH confidence (Image component for team photos)

---

*Feature research for: Rally Trivia Marketing Site — v1.1 Production Polish (form backend, analytics, social proof, team section)*
*Researched: 2026-02-22*
