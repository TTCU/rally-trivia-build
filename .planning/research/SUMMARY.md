# Project Research Summary

**Project:** Rally Trivia Marketing Site — v1.1 Production Polish
**Domain:** Astro static site with Cloudflare Workers API backend (additions to validated v1.0 stack)
**Researched:** 2026-02-22
**Confidence:** HIGH

## Executive Summary

Rally Trivia v1.1 upgrades a fully-shipped static marketing site with four targeted production-polish features: a working form backend (Resend email via Cloudflare Worker), privacy-first analytics (Cloudflare Web Analytics), honest social proof copy (replacing placeholder stats), and a real team section. The existing v1.0 stack — Astro 5 static output, Tailwind v4, Cloudflare Workers for static asset delivery — is sound and requires no breaking changes. The only new npm dependency is `resend@^6.9.0`, which explicitly supports Cloudflare's V8 isolate runtime as of v6.9.2.

The recommended approach is to keep Astro in `output: 'static'` mode and add a standalone `worker/index.ts` script that handles only the `POST /api/contact` endpoint, with all other traffic falling through to static assets via `env.ASSETS.fetch()`. This avoids the `@astrojs/cloudflare` SSR adapter entirely and keeps all page delivery fully edge-cached. The two content-only changes (social proof rework and real team section) have no engineering dependencies and can proceed in parallel with backend work.

The primary risk in this milestone is the form backend deployment sequence: Resend domain DNS verification must happen before any Worker code is deployed, the Resend API key must be stored as a Wrangler secret (never in source code or client-side JS), and the existing `ContactForm.astro` simulated delay must be replaced with a real `fetch()` call that gates the thank-you state on a confirmed `2xx` response. A secondary risk is Cloudflare Web Analytics auto-inject, which is unreliable on Workers-deployed sites — the manual beacon script in `BaseHead.astro` is the only reliable approach.

---

## Key Findings

### Recommended Stack

The existing stack is locked and validated in production. No breaking changes are needed. The single new dependency is `resend@^6.9.0`, the only Cloudflare Workers-compatible email SDK and the officially recommended provider in Cloudflare's own developer documentation. Cloudflare Web Analytics requires no npm package — just a one-line `<script defer>` tag with a public token.

The `wrangler.jsonc` configuration change is the most significant structural edit: adding `"main": "worker/index.ts"`, `"assets.binding": "ASSETS"`, and `"assets.run_worker_first": ["/api/*"]` enables a mixed static-plus-Worker deployment where only API routes hit the Worker and all page routes are served from the static asset cache at the edge.

**Core technologies:**
- **`resend@^6.9.0`** — Email delivery API; only Workers-compatible SDK; v6.9.2 explicitly added non-Node V8 isolate support; free tier (3,000/month) is more than sufficient for demo request volume
- **`worker/index.ts` (new file)** — Cloudflare Worker script; handles `POST /api/contact` and proxies all other requests to `env.ASSETS`; no `@astrojs/cloudflare` adapter needed
- **Cloudflare Web Analytics beacon** — Privacy-first analytics; cookieless, GDPR-compliant by default; no npm package; no consent banner required; deployed via one `<script defer>` tag
- **Astro `<Image>` component** — Already in the stack; use for team photos to get automatic WebP conversion and CLS prevention via explicit `width`/`height`

### Expected Features

All four v1.1 features are P1 (required for milestone completion). Research establishes a clear dependency ordering and confirms that two features (content rework) can proceed entirely in parallel with backend work.

**Must have — v1.1 (all P1):**
- Working form backend — a form that simulates success destroys trust the moment a real prospect submits and hears nothing; backend wiring is the highest-impact change
- Cloudflare Web Analytics — without analytics the site is flying blind; zero cost, single script tag, no consent banner overhead
- Social proof rework — fake or placeholder stats are detectable by nonprofit buyers and destroy credibility if caught; qualitative capability highlights are the honest replacement
- Real team section — placeholder team members on a live site signal the site is unfinished; real names and headshots establish founders are real people investing in the product

**Should have — v1.x (add post-launch when trigger conditions are met):**
- Honeypot spam prevention — not a real problem yet; add when spam occurs or before promoting the form publicly
- Quantified social proof — add when real event data exists; never estimate or project
- Form auto-reply to submitter — the animated thank-you UI state is sufficient for now
- Genuine customer testimonials — add when real clients can provide verified quotes with name, org, and role

**Defer to v2+:**
- Blog / content marketing — requires ongoing content production investment; empty blog looks worse than no blog
- Pricing page — add when Rally Trivia is ready to publish pricing publicly
- Calendly embed — out of scope per PROJECT.md; premature scheduling automation
- Case studies with ROI data — requires established client relationships and measurement infrastructure

**Anti-features to avoid at any milestone:**
- Auto-reply emails to form submitters before email deliverability reputation is established
- Google Analytics / GA4 on this site (requires cookie consent banner for EU/CA users; CWA is the correct choice)
- CAPTCHA on the contact form (drops conversion rate; honeypot is sufficient at this volume)

### Architecture Approach

The v1.1 architecture uses the "Worker-augmented static site" pattern: Astro builds fully static HTML/CSS/JS into `dist/`, a standalone `worker/index.ts` handles only `/api/*` routes via `run_worker_first`, and all other traffic falls through to the static asset cache via `env.ASSETS.fetch(request)`. This preserves full edge caching for all pages while enabling a server-side API endpoint — without converting the site to SSR mode. The `@astrojs/cloudflare` adapter is explicitly not used.

**Major components:**

| Component | Status | Change |
|-----------|--------|--------|
| `worker/index.ts` | NEW | Entire file; handles `POST /api/contact` via Resend SDK; proxies all other routes to `env.ASSETS` |
| `wrangler.jsonc` | MODIFIED | Add `main`, `assets.binding`, `assets.run_worker_first: ["/api/*"]` |
| `package.json` | MODIFIED | Add `"resend"` to dependencies |
| `src/components/ContactForm.astro` | MODIFIED | Replace `setTimeout` simulation with real `fetch('/api/contact')`; add error state; gate thank-you on `2xx` response |
| `src/components/BaseHead.astro` | MODIFIED | Add CF Web Analytics `<script defer>` beacon tag before `</head>` |
| `src/pages/index.astro` | MODIFIED | Rework social proof section; remove fake stats; add qualitative capability highlights |
| `src/pages/about.astro` | MODIFIED | Replace placeholder team members with real names, photos, titles |
| All other files | UNCHANGED | Layouts, Nav, Footer, features.astro, contact.astro, styles — untouched |

**Key data flow — form submission:**
```
User submits form
  → client validation (existing, unchanged)
  → fetch('/api/contact', POST, JSON)
  → Cloudflare edge: run_worker_first routes /api/* to Worker
  → worker/index.ts: validate fields, call Resend SDK
  → Resend API: deliver email to demo@rallytrivia.com
  → Worker: return { ok: true } or { error } with status 500
  → ContactForm: 2xx → thank-you animation | non-2xx → error banner
```

### Critical Pitfalls

1. **Resend domain not verified before Worker deploy** — Resend rejects sends from unverified domains with a 403. DNS verification (DKIM, SPF, DMARC) must be live in Resend dashboard before any Worker code is deployed. Critical detail: set the DKIM record to "DNS Only" (grey cloud) in Cloudflare — the orange proxy cloud prevents DKIM verification from succeeding.

2. **Resend API key in source code or client-side JS** — Store the key exclusively as a Wrangler secret (`npx wrangler secret put RESEND_API_KEY`). Access via `env.RESEND_API_KEY` in `worker/index.ts`. Never in `.env` committed to git, never in any `<script>` tag. Use `sending_access` scope (not `full_access`) for the production key.

3. **Cloudflare Web Analytics auto-inject is unreliable on Workers** — Auto-inject via the Cloudflare dashboard toggle does not work reliably for Workers-deployed static sites. Always use the manual JS snippet in `BaseHead.astro`. Never attempt auto-inject for this deployment type.

4. **CORS errors masking real Worker failures** — When a Worker throws before reaching the response handler, Cloudflare returns a 500 with no CORS headers. The browser reports a CORS error, hiding the actual root cause. Wrap all endpoint logic in `try/catch` that returns CORS headers even on failure. Use `wrangler tail` for real-time Worker error logs.

5. **Form still shows simulated success after backend is wired** — The existing `ContactForm.astro` uses a `setTimeout` simulation that always succeeds regardless of any network call. The real `fetch()` call must replace it completely, and the thank-you animation must be gated on a confirmed `2xx` response only. Gate success state on actual API success — never on a timer.

6. **Team photos without explicit dimensions cause CLS** — Photos from different sources have unpredictable natural dimensions. Use Astro's `<Image>` component with explicit `width` and `height` for every team photo. Store source photos in `src/assets/team/` (not `public/`) so Astro can optimize them. Standardize to square crop before adding to the repo.

7. **Placeholder stats surviving in multiple locations** — Social proof claims may exist in more than one file (index.astro, about.astro, meta descriptions, OG tags). `grep` the entire `src/` directory for old placeholder strings before making any changes to ensure complete removal.

---

## Implications for Roadmap

Based on the combined research, v1.1 breaks cleanly into four phases ordered by dependency. Phases 3 and 4 are fully independent of each other and of Phases 1-2.

### Phase 1: Foundation — Resend Domain Verification and Wrangler Config

**Rationale:** Domain verification has real-world latency (DNS propagation, 5-15 minutes). Starting here allows verification to happen while other work proceeds. The `wrangler.jsonc` restructuring is a prerequisite for all backend work and should be validated with a stub endpoint before Resend is wired in — this confirms routing works before adding email complexity.
**Delivers:** Verified Resend sending domain (DNS green in dashboard); updated `wrangler.jsonc` with `main`, `assets.binding`, `run_worker_first`; stub Worker returning `{ ok: true }` that confirms `POST /api/contact` routes correctly and static pages still serve correctly
**Avoids:** Pitfall 1 (domain not verified blocks Worker deploy), Pitfall 3 (DNS Only for DKIM), misconfigured asset routing

### Phase 2: Form Backend — Worker and Resend Integration

**Rationale:** With domain verified and routing confirmed via the stub, wire Resend SDK into the Worker and replace the ContactForm simulation with a real fetch call. Isolating this as a discrete phase with end-to-end testing ensures the highest-risk engineering change is fully validated before anything else ships.
**Delivers:** Working `POST /api/contact` endpoint; email delivered to `demo@rallytrivia.com`; ContactForm success and error states properly wired; honeypot field added; API key stored as Wrangler secret
**Uses:** `resend@^6.9.0`, `RESEND_API_KEY` wrangler secret, `worker/index.ts`, updated `ContactForm.astro`
**Avoids:** Pitfall 2 (key security), Pitfall 4 (CORS masking real errors), Pitfall 5 (fake success still running), Pitfall 12 (no error state on form)

### Phase 3: Analytics

**Rationale:** Fully independent of the backend work. One line in `BaseHead.astro`. Shipping before any public promotion ensures traffic data is captured from day one. Zero engineering risk.
**Delivers:** Cloudflare Web Analytics beacon on every page; pageview and referrer data visible in CF dashboard within minutes of deploy; no cookie consent banner needed
**Uses:** Cloudflare Web Analytics manual JS snippet (no npm package); token from CF dashboard
**Avoids:** Pitfall 6 (auto-inject unreliable on Workers); ad blocker deflation documented as known limitation, not a blocker

### Phase 4: Content Polish — Social Proof and Real Team Section

**Rationale:** Pure content changes with no engineering dependencies. Can run entirely in parallel with Phases 1-3 if content (photos, approved copy) is available. Grouped together because both are content-first tasks blocked by asset availability, not code complexity.
**Delivers:** Honest qualitative capability highlights replacing any placeholder stats throughout the site; real team member names, headshots, and titles on the About page; no fake testimonials or fabricated numbers anywhere
**Avoids:** Pitfall 7 (team photo CLS — use Astro `<Image>` with dimensions), Pitfall 8 (surviving placeholder content — grep before changing), trust damage from fake stats

### Phase Ordering Rationale

- **Phase 1 before Phase 2:** Domain verification has mandatory real-world latency. Starting it first means DNS can propagate while the stub Worker is being written and tested. The stub also validates routing in isolation before Resend adds complexity.
- **Phases 3 and 4 are independent:** They can be done in any order, in parallel with each other, or concurrently with Phases 1-2. The ordering shown (3 before 4) is a suggestion based on engineering-vs-content effort, not a hard dependency.
- **Phase 4 is gated by content availability, not engineering:** The markup changes for team section and social proof are trivial (data swaps in component arrays). The real constraint is whether real photos and approved copy are available. If content is ready first, Phase 4 can happen before Phases 1-2.
- **Form backend is last within the backend work** despite being the highest-trust-impact feature: it has the most prerequisites (domain verification, wrangler config, secret setup) and benefits from the routing validation done in Phase 1.

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 2 (Form Backend):** The server-side input validation pattern, CORS headers on error responses, and security hardening (honeypot silent discard, `sending_access` key scope) are implementation details that benefit from careful reference to official Cloudflare and Resend docs during execution. The integration is well-documented but the details matter.

Phases with standard patterns (skip research-phase):
- **Phase 1 (Foundation Setup):** All configuration decisions are definitively documented in official Cloudflare Workers static assets docs. STACK.md and PITFALLS.md provide exact `wrangler.jsonc` snippets. No ambiguity.
- **Phase 3 (Analytics):** Single script tag. Official Cloudflare docs are definitive. Zero implementation risk.
- **Phase 4 (Content Polish):** Pure content changes. Astro `<Image>` component is well-documented. No research needed during planning.

---

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | `resend@6.9.2` verified via npm registry; v6.9.2 Cloudflare Workers compatibility confirmed via GitHub release changelog; all integration patterns sourced from official Cloudflare and Resend docs |
| Features | HIGH | Core features verified against official docs; social proof and team section patterns confirmed via multiple practitioner sources; anti-features based on well-documented conversion research |
| Architecture | HIGH | Worker-augmented static site pattern confirmed against official Cloudflare static assets binding docs; `run_worker_first` routing behavior is documented and verified; component-level change map is explicit |
| Pitfalls | HIGH (technical) / MEDIUM (content) | Technical pitfalls sourced from official docs and community-verified failure reports (DKIM grey cloud, auto-inject failure, CORS masking); content pitfalls from practitioner sources — directionally reliable |

**Overall confidence:** HIGH

### Gaps to Address

- **Resend domain verification current state:** Research confirms the process but cannot check whether `rallytrivia.com` is already added in the Resend dashboard. First action in Phase 1 should be checking whether the domain is already set up or needs to be added from scratch.
- **Real team content availability:** The engineering work for the team section is trivial. The blocker is whether real photos and approved bios are available. Confirm content readiness before scheduling Phase 4 — if photos need to be taken or sourced, that's a separate timeline dependency.
- **Exact form field IDs in ContactForm.astro:** Research assumes `name`, `email`, `organization`, `eventType`, `message` based on the form UI. Verify actual field IDs in `ContactForm.astro` before writing the Worker's field extraction logic to avoid mismatches.
- **Recipient email address for demo requests:** Research examples use `demo@rallytrivia.com`. Confirm the actual destination email address before deploying the Worker. This is a one-character difference that would cause all demo requests to silently go to the wrong inbox.
- **`nodejs_compat` flag requirement:** PITFALLS.md notes the Resend SDK may require `"compatibility_flags": ["nodejs_compat"]` in `wrangler.jsonc`. STACK.md's Worker pattern (using standalone `worker/index.ts` with direct Wrangler bundling rather than the Astro adapter path) may not require this flag — the Wrangler esbuild bundler handles ESM imports natively. Verify during Phase 1 stub testing.

---

## Sources

### Primary (HIGH confidence)
- [Cloudflare Workers: Send Emails with Resend (Official Tutorial)](https://developers.cloudflare.com/workers/tutorials/send-emails-with-resend/) — Worker pattern, secrets, SDK usage
- [Resend: Send with Cloudflare Workers (Official)](https://resend.com/docs/send-with-cloudflare-workers) — SDK API, `env.RESEND_API_KEY` access pattern
- [Cloudflare: Static Assets Binding and Configuration](https://developers.cloudflare.com/workers/static-assets/binding/) — `run_worker_first`, `ASSETS` binding, routing behavior
- [Cloudflare Developer Spotlight: Astro + Resend Form (Official)](https://developers.cloudflare.com/developer-spotlight/tutorials/handle-form-submission-with-astro-resend/) — End-to-end form integration reference implementation
- [Cloudflare Web Analytics: Get Started (Official)](https://developers.cloudflare.com/web-analytics/get-started/) — Manual beacon installation, token setup
- [Cloudflare Web Analytics: FAQ (Official)](https://developers.cloudflare.com/web-analytics/faq/) — Auto-inject limitations, `defer` attribute semantics, ad blocker impact
- [Resend: Domain Verification on Cloudflare (Official)](https://resend.com/docs/dashboard/domains/cloudflare) — DKIM grey cloud requirement, DNS record setup
- [Resend: Account Quotas and Limits (Official)](https://resend.com/docs/knowledge-base/account-quotas-and-limits) — Free tier constraints, rate limits
- [Astro Images Guide (Official)](https://docs.astro.build/en/guides/images/) — `<Image>` component, CLS prevention, width/height requirements
- [npmjs.com / resend package](https://www.npmjs.com/package/resend) — Version `6.9.2` confirmed
- [GitHub: resend/resend-node releases](https://github.com/resend/resend-node/releases) — v6.9.2 changelog confirms Cloudflare Workers + non-Node V8 isolate compatibility

### Secondary (MEDIUM confidence)
- [Cloudflare Community: Web Analytics JS Token Not Injecting](https://community.cloudflare.com/t/web-analytics-not-injecting-the-js-token/860770) — Real-world auto-inject failure reports on Workers sites confirming manual-only approach
- [HubSpot: Best "Meet the Team" Pages](https://blog.hubspot.com/marketing/creative-agency-team-pages) — Team section layout and credibility best practices
- [Bryq: Meet the Team Page Best Practices](https://www.bryq.com/blog/meet-the-team) — Small team handling, photo quality guidelines
- [Social Proof in 2025 — Marketing Rewired / Medium](https://medium.com/marketing-rewired/social-proof-in-2025-its-not-just-testimonials-anymore-715f315bc238) — Qualitative vs. quantitative social proof; nonprofit buyer detection of fake stats
- [Cloudflare Community: Security Considerations for Contact Form](https://community.cloudflare.com/t/security-considerations-for-a-contact-form/415120) — Honeypot patterns, silent discard approach, CORS pitfalls

---

*Research completed: 2026-02-22*
*Ready for roadmap: yes*
