# Requirements: Rally Trivia Marketing Site

**Defined:** 2026-02-22
**Core Value:** Visitors understand what Rally Trivia does and request a demo — every page funnels toward that conversion.

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Landing Page

- [ ] **LAND-01**: Hero section with outcome-focused headline, subheadline, and demo request CTA button
- [ ] **LAND-02**: Value proposition sections explaining why Rally Trivia
- [ ] **LAND-03**: Dual-audience sections — "For Nonprofits" and "For Corporate Events" with tailored messaging
- [ ] **LAND-04**: Social proof section with testimonials or stats (placeholder if no real data)
- [ ] **LAND-05**: "How it works" step-by-step overview section

### Features Page

- [ ] **FEAT-01**: Dedicated features page with platform capabilities breakdown
- [ ] **FEAT-02**: Visual feature showcases with icons or illustrations

### About Page

- [ ] **ABOU-01**: About/story page with mission and background
- [ ] **ABOU-02**: Team or founder section

### Contact

- [x] **CONT-01**: Demo request form with name, email, organization, event type, and message fields
- [x] **CONT-02**: Post-submit confirmation/thank you state

### Site Infrastructure

- [x] **INFR-01**: Astro project with static output deployed to Cloudflare Workers
- [x] **INFR-02**: Tailwind CSS v4 with brand color tokens (navy, deep blue, electric blue)
- [x] **INFR-03**: Shared navigation with logo, page links, and CTA button
- [x] **INFR-04**: Shared footer with links and brand info
- [x] **INFR-05**: BaseLayout with SEO meta tags on every page
- [x] **INFR-06**: Sitemap generation via @astrojs/sitemap
- [x] **INFR-07**: Responsive design across mobile, tablet, and desktop
- [x] **INFR-08**: Scroll-triggered animations using Motion library
- [x] **INFR-09**: Self-hosted fonts via Fontsource
- [x] **INFR-10**: Brand logo and assets integrated throughout

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Content & Marketing

- **BLOG-01**: Blog/content marketing section
- **PRIC-01**: Pricing page with plans/tiers
- **CASE-01**: Case studies from real events

### Integrations

- **FORM-01**: Form backend delivery via Resend on Cloudflare Workers
- **CALB-01**: Calendly or scheduling embed for demo booking
- **ANAL-01**: Analytics integration (Plausible, Fathom, or Cloudflare Web Analytics)
- **CRM-01**: CRM integration for lead management

### Authentication

- **AUTH-01**: Login entry point for event hosts (link to app platform)

## Out of Scope

| Feature | Reason |
|---------|--------|
| Pricing page | Not ready to publish pricing yet |
| Blog | Requires ongoing content production, looks worse empty |
| Form backend wiring | Build UI now, decide on delivery mechanism later |
| CRM integration | Decide on tooling later |
| Mobile app | Web-only marketing site |
| Application backend | Separate platform, not this repository |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| INFR-01 | Phase 1 | Complete |
| INFR-02 | Phase 1 | Complete |
| INFR-03 | Phase 1 | Complete |
| INFR-04 | Phase 1 | Complete |
| INFR-05 | Phase 1 | Complete |
| INFR-06 | Phase 1 | Complete |
| INFR-07 | Phase 1 | Complete |
| INFR-08 | Phase 1 | Complete |
| INFR-09 | Phase 1 | Complete |
| INFR-10 | Phase 1 | Complete |
| LAND-01 | Phase 2 | Pending |
| LAND-02 | Phase 2 | Pending |
| LAND-03 | Phase 2 | Pending |
| LAND-04 | Phase 2 | Pending |
| LAND-05 | Phase 2 | Pending |
| FEAT-01 | Phase 2 | Pending |
| FEAT-02 | Phase 2 | Pending |
| ABOU-01 | Phase 2 | Pending |
| ABOU-02 | Phase 2 | Pending |
| CONT-01 | Phase 3 | Complete |
| CONT-02 | Phase 3 | Complete |

**Coverage:**
- v1 requirements: 21 total
- Mapped to phases: 21
- Unmapped: 0 ✓

---
*Requirements defined: 2026-02-22*
*Last updated: 2026-02-22 after roadmap creation*
