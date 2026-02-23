# Roadmap: Rally Trivia Marketing Site

## Milestones

- ✅ **v1.0 MVP** — Phases 1-3 (shipped 2026-02-22)
- 🚧 **v1.1 Production Polish** — Phases 4-7 (in progress)

## Phases

<details>
<summary>✅ v1.0 MVP (Phases 1-3) — SHIPPED 2026-02-22</summary>

- [x] Phase 1: Infrastructure (2/2 plans) — completed 2026-02-22
- [x] Phase 2: Content Pages (2/2 plans) — completed 2026-02-22
- [x] Phase 3: Contact Form (1/1 plan) — completed 2026-02-22

</details>

### 🚧 v1.1 Production Polish (In Progress)

**Milestone Goal:** Close v1.0 gaps — wire up the form backend, add analytics, and replace all placeholder content with real data so the site is production-ready for real prospects.

- [x] **Phase 4: Worker Foundation** - Verify Resend domain, restructure wrangler config, confirm API routing with a stub endpoint (completed 2026-02-22)
- [ ] **Phase 5: Form Backend** - Wire Resend SDK into the Worker and connect ContactForm to the real API endpoint
- [ ] **Phase 6: Analytics** - Add Cloudflare Web Analytics beacon to every page
- [ ] **Phase 7: Content Polish** - Replace placeholder team section with real names, titles, and photos

## Phase Details

### Phase 4: Worker Foundation
**Goal**: The deployment infrastructure is ready for a live API endpoint — routing is validated, secrets are secured, and a stub confirms the Worker pattern before any email complexity is introduced.
**Depends on**: Phase 3
**Requirements**: FORM-02, FORM-04
**Success Criteria** (what must be TRUE):
  1. `POST /api/contact` returns a valid JSON response from the Worker (stub `{ ok: true }`)
  2. All static pages (/, /features, /about, /contact) continue to serve correctly after wrangler.jsonc changes
  3. The Resend API key is stored as a Wrangler secret and is not present in any source file or git history
  4. Resend sending domain has verified DNS records (DKIM grey-cloud, SPF, DMARC visible as passing in Resend dashboard)
**Plans:** 2/2 plans complete
Plans:
- [ ] 04-01-PLAN.md — Worker stub, wrangler config, dev scripts, test automation
- [ ] 04-02-PLAN.md — Resend API key secret storage and DNS verification

### Phase 5: Form Backend
**Goal**: The contact form delivers real demo request emails to the configured recipient, and users see accurate success or error feedback based on the actual API response.
**Depends on**: Phase 4
**Requirements**: FORM-01, FORM-03
**Success Criteria** (what must be TRUE):
  1. Submitting the contact form causes an email to arrive in the recipient inbox
  2. The form shows a loading state while the request is in flight
  3. The thank-you animation only plays after a confirmed 2xx response from the Worker
  4. If the Worker returns an error, the form displays an error message without clearing the user's input
**Plans:** 1 plan
Plans:
- [ ] 05-01-PLAN.md — Worker email sending + Turnstile verification + ContactForm real API integration

### Phase 6: Analytics
**Goal**: Every page visit is captured in Cloudflare Web Analytics so traffic, referrers, and conversion paths are visible from day one.
**Depends on**: Phase 4
**Requirements**: ANLX-01, ANLX-02
**Success Criteria** (what must be TRUE):
  1. The Cloudflare Web Analytics beacon script tag is present in the rendered HTML `<head>` on every page
  2. Pageview data is visible in the Cloudflare Web Analytics dashboard within minutes of a site visit
  3. Referrer source data appears in the dashboard for navigations that include a referrer header
**Plans**: TBD

### Phase 7: Content Polish
**Goal**: The About page team section shows the real founding team — real names, real titles, real photos — so the site no longer signals "unfinished" to any visitor who reaches that page.
**Depends on**: Phase 3
**Requirements**: TEAM-01, TEAM-02
**Success Criteria** (what must be TRUE):
  1. The About page team section displays real team member names and titles (no placeholder text)
  2. Each team member card shows an actual photo, not a placeholder avatar or initials block
  3. Team photos load without layout shift (explicit dimensions via Astro `<Image>` component)
**Plans**: TBD

## Progress

| Phase | Milestone | Plans Complete | Status | Completed |
|-------|-----------|----------------|--------|-----------|
| 1. Infrastructure | v1.0 | 2/2 | Complete | 2026-02-22 |
| 2. Content Pages | v1.0 | 2/2 | Complete | 2026-02-22 |
| 3. Contact Form | v1.0 | 1/1 | Complete | 2026-02-22 |
| 4. Worker Foundation | 2/2 | Complete   | 2026-02-22 | - |
| 5. Form Backend | v1.1 | 0/1 | Planning complete | - |
| 6. Analytics | v1.1 | 0/? | Not started | - |
| 7. Content Polish | v1.1 | 0/? | Not started | - |
