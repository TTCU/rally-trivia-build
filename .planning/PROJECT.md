# Rally Trivia Marketing Site

## What This Is

A marketing and landing site for Rally Trivia, a live trivia management platform built for nonprofit fundraisers and corporate events. The site drives demo requests from event organizers — primarily nonprofit fundraiser coordinators (~60%) and corporate event planners (~40%). Built with Astro and deployed to Cloudflare Workers for edge performance.

## Core Value

Visitors understand what Rally Trivia does and request a demo — every page funnels toward that conversion.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Landing page with hero, value props, and CTA to request demo
- [ ] Features page with detailed platform capabilities
- [ ] About/Story page — who's behind Rally Trivia and the mission
- [ ] Contact/demo request form (name, email, org, message)
- [ ] Responsive design across mobile, tablet, desktop
- [ ] Brand-consistent design (navy, deep blue, electric blue accent)
- [ ] Marketing copy generated for all pages
- [ ] Astro static site with Cloudflare Workers deployment
- [ ] Shared navigation and footer across all pages
- [ ] Logo and brand assets integrated throughout

### Out of Scope

- Pricing page — not ready to publish pricing yet
- Blog/content marketing — future addition
- Authentication/login — separate from the app platform
- Form backend integration — build form UI now, wire up delivery later
- CRM integration — decide on tooling later
- Calendly/booking embed — simple form is sufficient for now
- Analytics integration — add after launch

## Context

- Repository already contains brand assets: logo (PNG + SVG), icons in `assets/images/`
- Brand positioning: clean, modern, confident, event-grade, approachable
- Primary audience: nonprofit event organizers planning fundraiser trivia nights
- Secondary audience: corporate event planners running team-building events
- The Rally Trivia app platform exists separately — this site is public-facing marketing only
- Copy needs to be written — user has the vision but no pre-written marketing text
- Polish target: professional with key sections, room to grow — not bare-bones MVP but not over-the-top either

## Constraints

- **Tech stack**: Astro framework, TypeScript, Tailwind CSS, Cloudflare Workers
- **Hosting**: Cloudflare Pages/Workers — edge delivery required
- **Design**: Must use existing brand palette (navy, deep blue, electric blue) and logo assets
- **Node.js**: 20+

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Astro + Cloudflare Workers | Static-first with edge delivery, minimal operational overhead | — Pending |
| Simple contact form (no Calendly) | Lower friction, decide on scheduling tool later | — Pending |
| Form UI without backend | Get the site live fast, wire up form delivery in a follow-up | — Pending |
| Generate marketing copy | No pre-written copy available, create during build | — Pending |

---
*Last updated: 2026-02-22 after initialization*
