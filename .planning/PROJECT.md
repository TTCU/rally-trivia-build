# Rally Trivia Marketing Site

## What This Is

A marketing and landing site for Rally Trivia, a live trivia management platform built for nonprofit fundraisers and corporate events. The site drives demo requests from event organizers — primarily nonprofit fundraiser coordinators (~60%) and corporate event planners (~40%). Built with Astro 5, Tailwind CSS v4, and deployed to Cloudflare Workers for edge performance. Features a complete marketing funnel: landing page with hero and social proof, features page, about page with real team profiles, and demo request form with full email delivery backend.

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
- ✓ Form backend delivery (Resend API on Cloudflare Workers) — v1.1
- ✓ Cloudflare Turnstile spam protection on contact form — v1.1
- ✓ Cloudflare Web Analytics on all pages with CTA event tracking — v1.1
- ✓ Real team section with photos, names, titles, and LinkedIn profiles — v1.1

### Active

- [ ] Replace placeholder social proof stats with qualitative highlights (no fake numbers)
- [ ] Honeypot field on contact form to prevent spam
- [ ] Rate limiting on `/api/contact` endpoint

### Out of Scope

- Pricing page — not ready to publish pricing yet
- Blog/content marketing — requires ongoing content production
- Authentication/login — separate from the app platform
- CRM integration — decide on tooling later
- Calendly/booking embed — simple form is sufficient for now
- Mobile app — web-only marketing site
- Auto-reply confirmation email — user chose no auto-reply, keep it simple
- SSR / Astro Cloudflare adapter — standalone Worker handles the one API endpoint

## Context

Shipped v1.1 with 1,487 LOC (Astro/TypeScript/CSS) across 4 pages + Worker API.
Tech stack: Astro 5, Tailwind CSS v4 (with @tailwindcss/vite), Motion library, Fontsource (Plus Jakarta Sans), Resend SDK, Cloudflare Turnstile.
Brand tokens: navy #0a1628, deep-blue #1a3a6b, electric-blue #2563eb, gold #f59e0b, coral #f97316.
Deployed to Cloudflare Workers with static assets + Worker handling /api/* routes.
Contact form delivers emails via Resend with Turnstile spam protection.
Cloudflare Web Analytics beacon on all pages (pending token replacement from CF dashboard).
Team section shows 4 real members with optimized WebP photos via Astro `<Image>`.

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
| Generate marketing copy | No pre-written copy available, create during build | ✓ Good — professional tone achieved |
| Tailwind v4 via @tailwindcss/vite | Correct plugin for Astro 5 (not @tailwindcss/astro) | ✓ Good — clean integration |
| Vanilla JS for interactivity | Hamburger nav, form validation — no framework dependency | ✓ Good — minimal JS bundle |
| Motion library for animations | Scroll-triggered fade-in via inView + animate pattern | ✓ Good — lightweight, smooth |
| Worker-augmented static pattern | Standalone worker/index.ts handles /api/* only; Astro stays static | ✓ Good — clean separation of concerns |
| No auto-reply to form submitters | Single recipient delivery only; thank-you UI sufficient | ✓ Good — simplest solution |
| run_worker_first array form | Worker invoked only for /api/* routes, not static pages | ✓ Good — no interference with static serving |
| Separate src/worker/tsconfig.json | Prevents conflicts with Astro strict tsconfig | ✓ Good — clean type isolation |
| Resend + Turnstile for form backend | Managed email + spam protection, both CF-compatible | ✓ Good — reliable, minimal ops |
| 900ms minimum loading time | Promise.all prevents flash of loading state on fast connections | ✓ Good — polished UX |
| Astro `<Image>` for team photos | Automatic WebP conversion + CLS prevention via explicit dimensions | ✓ Good — ~90% size reduction |

---
*Last updated: 2026-02-23 after v1.1 milestone*
