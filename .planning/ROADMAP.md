# Roadmap: Rally Trivia Marketing Site

## Overview

Three phases deliver a conversion-focused marketing site from zero to live. Phase 1 locks in the Astro + Cloudflare Workers scaffold with correct configuration before any content is built — the critical pitfalls are all infrastructure decisions. Phase 2 builds all content pages (landing, features, about) on top of the verified foundation. Phase 3 delivers the demo request form, the conversion endpoint the entire site exists to drive visitors toward.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Infrastructure** - Astro scaffold + Cloudflare Workers deploy with brand system locked in
- [ ] **Phase 2: Content Pages** - Landing page, features page, and about page with full marketing copy
- [ ] **Phase 3: Contact Form** - Demo request form page — the conversion endpoint of the site

## Phase Details

### Phase 1: Infrastructure
**Goal**: A working Astro static site deploys successfully to Cloudflare Workers with brand styles, shared navigation, footer, and SEO baseline in place
**Depends on**: Nothing (first phase)
**Requirements**: INFR-01, INFR-02, INFR-03, INFR-04, INFR-05, INFR-06, INFR-07, INFR-08, INFR-09, INFR-10
**Success Criteria** (what must be TRUE):
  1. Running `wrangler deploy` produces a live URL with no 404s and no `_worker.js` in the build output
  2. Every page displays the shared navigation with logo and CTA button, and the shared footer
  3. Brand color tokens (navy, deep blue, electric blue) apply correctly in Tailwind utility classes on any page
  4. The sitemap XML is accessible at `/sitemap-index.xml` on the deployed site
  5. The site renders correctly and is usable on mobile (375px), tablet (768px), and desktop (1280px)
**Plans**: TBD

Plans:
- [ ] 01-01: Astro project scaffold with Cloudflare Workers config, Tailwind v4, fonts, and sitemap
- [ ] 01-02: BaseLayout, Nav, Footer, and brand system components

### Phase 2: Content Pages
**Goal**: Visitors can navigate the landing page, features page, and about page — each with conversion-oriented marketing copy, scroll animations, and CTAs pointing toward the demo form
**Depends on**: Phase 1
**Requirements**: LAND-01, LAND-02, LAND-03, LAND-04, LAND-05, FEAT-01, FEAT-02, ABOU-01, ABOU-02
**Success Criteria** (what must be TRUE):
  1. The landing page opens with an outcome-focused hero headline and a visible "Request a Demo" CTA above the fold
  2. The landing page contains distinct sections for "For Nonprofits" and "For Corporate Events" with tailored messaging
  3. The features page shows platform capabilities broken down with icons or illustrations
  4. The about page tells the Rally Trivia story with founder/team background
  5. Scroll-triggered animations activate as sections enter the viewport on all content pages
**Plans**: TBD

Plans:
- [ ] 02-01: Landing page — hero, value props, dual audience, how it works, social proof, CTA sections
- [ ] 02-02: Features page and About page

### Phase 3: Contact Form
**Goal**: A visitor who is ready to request a demo can complete and submit the form and receive a confirmation — the site's primary conversion action is functional
**Depends on**: Phase 2
**Requirements**: CONT-01, CONT-02
**Success Criteria** (what must be TRUE):
  1. The contact page is reachable from CTA buttons on the landing, features, and about pages
  2. The form accepts name, email, organization, event type, and message and visually validates required fields
  3. After submitting the form, the visitor sees a thank-you confirmation state (no backend required — UI only)
**Plans**: TBD

Plans:
- [ ] 03-01: Demo request form page with ContactForm component, validation, and post-submit confirmation

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Infrastructure | 0/2 | Not started | - |
| 2. Content Pages | 0/2 | Not started | - |
| 3. Contact Form | 0/1 | Not started | - |
