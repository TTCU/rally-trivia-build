# Rally Trivia Marketing Site

## What This Is

A marketing and landing site for Rally Trivia, a live trivia management platform built for nonprofit fundraisers and corporate events. The site drives demo requests from event organizers — primarily nonprofit fundraiser coordinators (~60%) and corporate event planners (~40%). Built with Astro 5, Tailwind CSS v4, and deployed to Cloudflare Workers for edge performance. Features a complete marketing funnel: landing page with hero and social proof, features page, about page, and demo request form.

## Core Value

Visitors understand what Rally Trivia does and request a demo — every page funnels toward that conversion.

## Requirements

### Validated

- ✓ Landing page with hero, value props, dual-audience cards, and CTA — v1.0
- ✓ Features page with 12-card icon grid of platform capabilities — v1.0
- ✓ About/Story page with mission narrative and team placeholder — v1.0
- ✓ Contact/demo request form with validation and thank-you state — v1.0
- ✓ Responsive design across mobile, tablet, desktop — v1.0
- ✓ Brand-consistent design (navy, deep blue, electric blue, gold, coral) — v1.0
- ✓ Marketing copy generated for all pages — v1.0
- ✓ Astro static site with Cloudflare Workers deployment — v1.0
- ✓ Shared navigation and footer across all pages — v1.0
- ✓ Logo and brand assets integrated throughout — v1.0

### Active

- [ ] Form backend delivery (Resend on Cloudflare Workers)
- [ ] Replace placeholder social proof stats with real data
- [ ] Replace placeholder team member names/photos on About page
- [ ] Analytics integration (Plausible, Fathom, or Cloudflare Web Analytics)

### Out of Scope

- Pricing page — not ready to publish pricing yet
- Blog/content marketing — requires ongoing content production
- Authentication/login — separate from the app platform
- CRM integration — decide on tooling later
- Calendly/booking embed — simple form is sufficient for now
- Mobile app — web-only marketing site

## Context

Shipped v1.0 with 1,196 LOC (Astro/TypeScript/CSS) across 4 pages.
Tech stack: Astro 5, Tailwind CSS v4 (with @tailwindcss/vite), Motion library, Fontsource (Plus Jakarta Sans).
Brand tokens: navy #0a1628, deep-blue #1a3a6b, electric-blue #2563eb, gold #f59e0b, coral #f97316.
Deployed to Cloudflare Workers as static assets (no SSR, no _worker.js).
Contact form is UI-only — backend wiring deferred. Social proof uses placeholder stats.

## Constraints

- **Tech stack**: Astro framework, TypeScript, Tailwind CSS, Cloudflare Workers
- **Hosting**: Cloudflare Pages/Workers — edge delivery required
- **Design**: Must use existing brand palette (navy, deep blue, electric blue) and logo assets
- **Node.js**: 20+

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Astro + Cloudflare Workers | Static-first with edge delivery, minimal operational overhead | ✓ Good — fast builds, simple deploys |
| Simple contact form (no Calendly) | Lower friction, decide on scheduling tool later | ✓ Good — clean UX, easy to extend |
| Form UI without backend | Get the site live fast, wire up form delivery in a follow-up | ✓ Good — shipped fast, backend is v2 |
| Generate marketing copy | No pre-written copy available, create during build | ✓ Good — professional tone achieved |
| Tailwind v4 via @tailwindcss/vite | Correct plugin for Astro 5 (not @tailwindcss/astro) | ✓ Good — clean integration |
| Vanilla JS for interactivity | Hamburger nav, form validation — no framework dependency | ✓ Good — minimal JS bundle |
| Motion library for animations | Scroll-triggered fade-in via inView + animate pattern | ✓ Good — lightweight, smooth |
| Static assets only (no SSR) | wrangler.jsonc with assets.directory, no worker bindings | ✓ Good — simplest possible deploy |

---
*Last updated: 2026-02-22 after v1.0 milestone*
