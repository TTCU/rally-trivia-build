# Phase 2: Content Pages - Context

**Gathered:** 2026-02-22
**Status:** Ready for planning

<domain>
## Phase Boundary

Landing page, features page, and about page — each with conversion-oriented marketing copy, scroll animations, and CTAs pointing toward the demo request form (Phase 3). All pages use the BaseLayout, Nav, Footer, and SEO infrastructure from Phase 1.

</domain>

<decisions>
## Implementation Decisions

### Landing page structure
- Full-screen immersive hero — dark background fills the viewport, headline and CTA float over it
- Section order after hero: Value props → Dual-audience cards → How it works → Social proof → Final CTA
- Dual-audience sections presented as side-by-side cards — "For Nonprofits" and "For Corporate Events", each with tailored benefits and CTA
- Social proof uses stats only (e.g., "500+ events hosted") — no fake testimonials or quotes, use plausible-but-impressive numbers until real data is available

### Visual style & tone
- Dark hero section, light body sections, dark footer — classic contrast approach
- Icons and simple illustrations for visuals — no stock photos, clean and branded feel
- Subtle fade-in animations only — smooth and understated, consistent with Phase 1's ScrollAnimations setup. No staggered reveals or counting animations
- CTA button color: Claude's discretion — pick what works best for contrast on both dark and light backgrounds

### Marketing copy direction
- Tone: Warm and approachable — friendly, conversational, like talking to a trusted event planning partner
- Hero headline: Outcome-focused framing — lead with what the audience gets (engagement, fundraising results, memorable events)
- Copy density: Scannable and punchy — short headlines, 1-2 sentence descriptions, bullet points. Visitors skim quickly
- Emphasis: Fun/engagement first, results/fundraising second — "Your guests will have a blast" → "and you'll raise more doing it"
- All copy generated fresh by Claude — no pre-written messaging provided. User will review and adjust

### Features page
- Icon grid layout — grid of feature cards, each with an icon, title, and short description
- Features generated from context — Claude infers likely capabilities of a live trivia management platform (customizable games, real-time scoring, audience participation, branding, analytics, etc.)

### About page
- Mission-driven personality — focus on WHY Rally Trivia exists, making fundraising fun and events memorable
- Include a placeholder team/founder section — names and photos to be filled in later with real info

### Claude's Discretion
- CTA button accent color (gold vs electric blue vs contextual)
- Exact icon choices for feature cards
- Specific stat numbers for social proof section
- How it works step count and descriptions
- Typography sizing and spacing within sections

</decisions>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches. User wants warm, approachable copy that leads with fun and engagement, positions Rally Trivia as a trusted partner for event organizers.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 02-content-pages*
*Context gathered: 2026-02-22*
