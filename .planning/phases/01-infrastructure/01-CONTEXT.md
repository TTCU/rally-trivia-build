# Phase 1: Infrastructure - Context

**Gathered:** 2026-02-22
**Status:** Ready for planning

<domain>
## Phase Boundary

A working Astro static site deploys successfully to Cloudflare Workers with brand styles, shared navigation, footer, and SEO baseline in place. This is the foundation — no content pages or forms are built here.

</domain>

<decisions>
## Implementation Decisions

### Brand & typography
- Geometric sans-serif font family (e.g., Inter, Plus Jakarta Sans) — clean, modern, tech-forward
- Warm accent colors alongside the core blues (gold, coral tones) for CTAs and highlights — energy and excitement
- Bold, punchy headings — large, heavy-weight with strong contrast against body text
- Core palette: navy, deep blue, electric blue + warm accents for interactive elements

### Navigation design
- Nav links: Features, About, Contact (no explicit Home link — logo click returns home)
- CTA button text: "Request a Demo"
- Layout and sticky behavior: Claude's discretion (see below)
- Mobile: hamburger menu with standard behavior

### Footer content
- Standard marketing footer: logo, page links, brief tagline, copyright
- No social media icons for now — accounts don't exist yet
- Copyright text only, no legal page links: "© 2026 Rally Trivia. All rights reserved."
- Footer background treatment: Claude's discretion

### Overall visual tone
- Fun and energetic vibe — trivia is fun, the site should reflect that
- Subtle fade animations on scroll — smooth and understated, not distracting
- Generous whitespace between sections — premium, airy feel
- Inspiration: Kahoot / trivia platform aesthetic, but more polished and professional
- Rounded shapes and friendly geometry, not harsh or overly corporate

### Claude's Discretion
- Nav bar layout (logo left + links center + CTA right, or logo left + everything right)
- Sticky nav behavior (always sticky, hide-on-scroll-down, or static)
- Light/dark theme approach (dark hero with light body recommended given the brand)
- Footer background treatment (dark navy or matching page)
- Exact font choice within geometric sans-serif family
- Exact warm accent color values
- Loading states and error handling
- Animation easing and timing details
- Mobile breakpoint behaviors beyond hamburger nav

</decisions>

<specifics>
## Specific Ideas

- Kahoot-inspired visual energy — the trivia/game platform vibe but elevated for a B2B marketing audience
- Bold, punchy headings create visual hierarchy and impact in hero sections
- Warm accent colors (gold, coral) bring energy to CTAs and highlights against the blue palette
- "Request a Demo" is the site-wide CTA language

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 01-infrastructure*
*Context gathered: 2026-02-22*
