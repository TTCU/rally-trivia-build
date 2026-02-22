# Phase 2: Content Pages - Research

**Researched:** 2026-02-22
**Domain:** Astro 5 marketing page composition — section architecture, Tailwind v4 utility patterns, Motion scroll animations, conversion-oriented copy structure
**Confidence:** HIGH

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Landing page structure**
- Full-screen immersive hero — dark background fills the viewport, headline and CTA float over it
- Section order after hero: Value props → Dual-audience cards → How it works → Social proof → Final CTA
- Dual-audience sections presented as side-by-side cards — "For Nonprofits" and "For Corporate Events", each with tailored benefits and CTA
- Social proof uses stats only (e.g., "500+ events hosted") — no fake testimonials or quotes, use plausible-but-impressive numbers until real data is available

**Visual style & tone**
- Dark hero section, light body sections, dark footer — classic contrast approach
- Icons and simple illustrations for visuals — no stock photos, clean and branded feel
- Subtle fade-in animations only — smooth and understated, consistent with Phase 1's ScrollAnimations setup. No staggered reveals or counting animations
- CTA button color: Claude's discretion — pick what works best for contrast on both dark and light backgrounds

**Marketing copy direction**
- Tone: Warm and approachable — friendly, conversational, like talking to a trusted event planning partner
- Hero headline: Outcome-focused framing — lead with what the audience gets (engagement, fundraising results, memorable events)
- Copy density: Scannable and punchy — short headlines, 1-2 sentence descriptions, bullet points. Visitors skim quickly
- Emphasis: Fun/engagement first, results/fundraising second — "Your guests will have a blast" → "and you'll raise more doing it"
- All copy generated fresh by Claude — no pre-written messaging provided. User will review and adjust

**Features page**
- Icon grid layout — grid of feature cards, each with an icon, title, and short description
- Features generated from context — Claude infers likely capabilities of a live trivia management platform (customizable games, real-time scoring, audience participation, branding, analytics, etc.)

**About page**
- Mission-driven personality — focus on WHY Rally Trivia exists, making fundraising fun and events memorable
- Include a placeholder team/founder section — names and photos to be filled in later with real info

### Claude's Discretion
- CTA button accent color (gold vs electric blue vs contextual)
- Exact icon choices for feature cards
- Specific stat numbers for social proof section
- How it works step count and descriptions
- Typography sizing and spacing within sections

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| LAND-01 | Hero section with outcome-focused headline, subheadline, and demo request CTA button | Full-viewport dark hero section pattern; gold CTA button on dark background; anchor to /contact |
| LAND-02 | Value proposition sections explaining why Rally Trivia | 3-column icon + headline + description card grid; animate-on-scroll class per element |
| LAND-03 | Dual-audience sections — "For Nonprofits" and "For Corporate Events" with tailored messaging | Side-by-side card layout with md:grid-cols-2; each card with heading, benefit list, and CTA link |
| LAND-04 | Social proof section with testimonials or stats (placeholder if no real data) | Stats-only approach confirmed; 3–4 stat numbers in bold large type; centered layout on dark bg |
| LAND-05 | "How it works" step-by-step overview section | 3–4 numbered steps; horizontal on desktop, vertical stack on mobile; numbered circles or step indicators |
| FEAT-01 | Dedicated features page with platform capabilities breakdown | Feature card grid (3–4 cols desktop, 1–2 mobile); inferred capabilities from trivia platform context |
| FEAT-02 | Visual feature showcases with icons or illustrations | Inline SVG icons preferred (no external icon lib needed); brand icon assets in assets/images/ available |
| ABOU-01 | About/story page with mission and background | Mission statement hero + story paragraphs; warm tone; WHY framing |
| ABOU-02 | Team or founder section | Placeholder grid with gray avatar circles + name/title placeholders; ready for real photos later |
</phase_requirements>

---

## Summary

Phase 2 is pure content authoring within the already-built Astro infrastructure. All infrastructure exists and works: BaseLayout, Nav, Footer, ScrollAnimations (Motion `inView`), Tailwind v4 with brand tokens, responsive breakpoints. The three pages (`index.astro`, `features.astro`, `about.astro`) are already wired to `BaseLayout` but contain only one-line placeholders. This phase fills them with marketing content sections.

The primary pattern for every page is sequential `<section>` blocks inside `BaseLayout`. Each section gets `class="animate-on-scroll"` to inherit the Phase 1 fade-in behavior at no additional cost. Section backgrounds alternate between white (body sections) and navy (hero, social proof, final CTA) to create the dark/light contrast rhythm the user wants. All Tailwind utilities are already defined — brand colors (`bg-navy`, `bg-deep-blue`, `text-electric-blue`, `bg-gold`, `text-gold`), font weights, spacing, and the `rounded-brand` radius token.

No new npm packages are required. Icons for feature cards can be inline SVG (Heroicons-style paths written directly in Astro) or the existing brand icons from `assets/images/` (icon1.svg, icon2.svg are available). The key implementation challenge is copywriting quality and section layout composition — not infrastructure. Every section must be responsive-first: single column on mobile, 2–3 column grids on `md:` and `lg:` breakpoints.

**Primary recommendation:** Build each page as a series of `<section>` elements within BaseLayout, each with `animate-on-scroll`, alternating dark/light backgrounds, and responsive Tailwind grid layouts. No new libraries needed.

---

## Standard Stack

### Core (all already installed)

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| astro | 5.16.2 | Static site generation; pages are `.astro` files | Already in project; Phase 1 complete |
| tailwindcss | ^4.2.0 | Utility CSS — all layout, typography, color, spacing | Brand tokens already in `@theme`; no config changes needed |
| motion | ^12.34.3 | Scroll-triggered fade animations via `inView` | Already wired in `ScrollAnimations.astro`; just add `animate-on-scroll` class |

### Supporting (no installation needed)

| Tool | Purpose | When to Use |
|------|---------|-------------|
| Inline SVG | Feature card icons | Write paths directly in `.astro` markup; zero bundle cost |
| assets/images/icon1.svg, icon2.svg | Brand decoration | Available as static assets; copy to `public/images/` if needed as `<img>` src |
| Tailwind `@layer components` | Reusable section patterns | Optional — if section cards repeat, define once in `global.css` |

### No New Packages Required

Phase 2 requires zero additional `npm install` commands. All dependencies from Phase 1 are sufficient.

---

## Architecture Patterns

### Recommended Page Structure

```
src/pages/
├── index.astro       # Landing page — 6 sections: Hero, Value Props, Dual Audience, How It Works, Social Proof, Final CTA
├── features.astro    # Features page — Hero + Feature Grid (8–12 cards)
└── about.astro       # About page — Hero, Mission/Story, Team/Founder section
```

Every page follows this template:

```astro
---
import BaseLayout from '../layouts/BaseLayout.astro';
---

<BaseLayout title="[Page Title]" description="[SEO description]">
  <section class="[bg] [padding] animate-on-scroll">
    <!-- section content -->
  </section>
  <!-- repeat for each section -->
</BaseLayout>
```

### Pattern 1: Full-Viewport Dark Hero Section

**What:** `min-h-screen` dark navy background, white headline text, gold CTA button, centered content
**When to use:** Every page hero — landing, features, about

```astro
<section class="min-h-screen bg-navy flex items-center justify-center px-4 animate-on-scroll">
  <div class="max-w-4xl mx-auto text-center">
    <h1 class="text-5xl md:text-7xl font-bold text-white leading-tight mb-6">
      Make Every Event <span class="text-gold">Unforgettable</span>
    </h1>
    <p class="text-xl md:text-2xl text-white/70 max-w-2xl mx-auto mb-10">
      Live trivia experiences that raise more money and leave guests raving.
    </p>
    <a
      href="/contact"
      class="inline-block px-8 py-4 text-lg font-bold rounded-brand bg-gold text-navy hover:bg-gold/90 transition-colors duration-200"
    >
      Request a Demo
    </a>
  </div>
</section>
```

**Note:** `min-h-screen` fills the viewport. Nav is sticky on top (z-50 from Phase 1), so the hero visually fills below the nav. No padding-top offset needed — `items-center` vertically centers regardless.

### Pattern 2: Light Body Section with Card Grid

**What:** White background section with responsive grid of cards; 1 col mobile, 2–3 col desktop
**When to use:** Value props, feature grid, how-it-works steps

```astro
<section class="py-24 px-4 bg-white animate-on-scroll">
  <div class="max-w-7xl mx-auto">
    <h2 class="text-4xl font-bold text-navy text-center mb-4">Why Rally Trivia?</h2>
    <p class="text-lg text-navy/60 text-center max-w-2xl mx-auto mb-16">
      One-liner supporting the headline.
    </p>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
      <!-- cards -->
    </div>
  </div>
</section>
```

### Pattern 3: Dual-Audience Side-by-Side Cards

**What:** Two equal-width cards at `md:` and above, stacked on mobile. Each card has its own background, heading, bullet list, and CTA.
**When to use:** "For Nonprofits" / "For Corporate Events" section (LAND-03)

```astro
<section class="py-24 px-4 bg-slate-50 animate-on-scroll">
  <div class="max-w-7xl mx-auto">
    <h2 class="text-4xl font-bold text-navy text-center mb-16">Built for Your Event</h2>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-8">

      <!-- Card: Nonprofits -->
      <div class="bg-white rounded-brand p-8 shadow-sm border border-navy/10">
        <div class="text-gold mb-4"><!-- icon --></div>
        <h3 class="text-2xl font-bold text-navy mb-3">For Nonprofits</h3>
        <ul class="space-y-2 text-navy/70 mb-6">
          <li class="flex gap-2"><span class="text-gold">✓</span> Raise more at your gala</li>
          <!-- more bullets -->
        </ul>
        <a href="/contact" class="inline-block px-6 py-3 font-bold rounded-brand bg-deep-blue text-white hover:bg-deep-blue/90 transition-colors">
          Get Started
        </a>
      </div>

      <!-- Card: Corporate Events -->
      <div class="bg-navy rounded-brand p-8 shadow-sm">
        <div class="text-gold mb-4"><!-- icon --></div>
        <h3 class="text-2xl font-bold text-white mb-3">For Corporate Events</h3>
        <ul class="space-y-2 text-white/70 mb-6">
          <li class="flex gap-2"><span class="text-gold">✓</span> Team building that actually works</li>
          <!-- more bullets -->
        </ul>
        <a href="/contact" class="inline-block px-6 py-3 font-bold rounded-brand bg-gold text-navy hover:bg-gold/90 transition-colors">
          Get Started
        </a>
      </div>

    </div>
  </div>
</section>
```

### Pattern 4: Stats-Only Social Proof (Dark Background)

**What:** Dark navy section with 3–4 large stat numbers + labels, centered. No testimonials.
**When to use:** LAND-04 social proof

```astro
<section class="py-24 px-4 bg-deep-blue animate-on-scroll">
  <div class="max-w-5xl mx-auto text-center">
    <h2 class="text-3xl font-bold text-white mb-16">Trusted by Event Organizers</h2>
    <div class="grid grid-cols-2 md:grid-cols-4 gap-12">
      <div>
        <div class="text-5xl font-bold text-gold mb-2">500+</div>
        <div class="text-white/60 text-sm uppercase tracking-wide">Events Hosted</div>
      </div>
      <!-- repeat for other stats -->
    </div>
  </div>
</section>
```

**Discretion note:** Stat numbers are Claude's discretion. Suggested plausible-but-impressive values: 500+ events, $2M+ raised, 98% satisfaction, 50+ cities. Adjust when real data is available.

### Pattern 5: How It Works — Numbered Steps

**What:** 3–4 numbered steps with title + description. Horizontal on desktop, vertical on mobile.
**When to use:** LAND-05

```astro
<section class="py-24 px-4 bg-white animate-on-scroll">
  <div class="max-w-7xl mx-auto">
    <h2 class="text-4xl font-bold text-navy text-center mb-16">How It Works</h2>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-12">
      {[
        { num: '01', title: 'Choose Your Format', desc: 'Pick from dozens of trivia formats...' },
        { num: '02', title: 'We Set Everything Up', desc: 'Your dedicated host configures...' },
        { num: '03', title: 'Guests Have a Blast', desc: 'Real-time competition, live...' },
      ].map(({ num, title, desc }) => (
        <div class="flex flex-col items-center text-center md:items-start md:text-left">
          <div class="text-6xl font-bold text-gold/20 mb-4 select-none">{num}</div>
          <h3 class="text-xl font-bold text-navy mb-2">{title}</h3>
          <p class="text-navy/60">{desc}</p>
        </div>
      ))}
    </div>
  </div>
</section>
```

**Note:** Astro supports array `.map()` in JSX-style template expressions directly in `.astro` files.

### Pattern 6: Feature Card Grid (Features Page)

**What:** 8–12 feature cards in responsive grid with icon, title, short description
**When to use:** FEAT-01 / FEAT-02

```astro
<section class="py-24 px-4 bg-white animate-on-scroll">
  <div class="max-w-7xl mx-auto">
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
      {features.map(({ icon, title, desc }) => (
        <div class="bg-slate-50 rounded-brand p-6 border border-navy/5 hover:border-electric-blue/30 transition-colors">
          <div class="text-electric-blue mb-4 w-8 h-8">{icon}</div>
          <h3 class="text-lg font-bold text-navy mb-2">{title}</h3>
          <p class="text-navy/60 text-sm">{desc}</p>
        </div>
      ))}
    </div>
  </div>
</section>
```

**Icon approach:** Use inline SVG strings or SVG elements in the `icon` property of each feature object. Heroicons (MIT licensed, no npm install needed) — just paste the path. Alternatively, use Unicode emoji for placeholders, then replace with SVG later.

### Pattern 7: Inline SVG Icons (No External Library)

**What:** Write SVG paths inline or as Astro components. Zero bundle overhead.
**When to use:** Feature icons, section accent icons, how-it-works indicators

```astro
<!-- Example: checkmark icon -->
<svg class="w-6 h-6 text-electric-blue" fill="none" viewBox="0 0 24 24" stroke="currentColor">
  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
</svg>
```

**Note:** `stroke="currentColor"` means icon color is controlled by Tailwind `text-*` class on parent. This is the standard pattern for inline SVG icons in Tailwind projects.

### Pattern 8: About Page — Team Placeholder Grid

**What:** Grid of placeholder team cards, each with a gray circle avatar + name + title
**When to use:** ABOU-02

```astro
<section class="py-24 px-4 bg-slate-50 animate-on-scroll">
  <div class="max-w-5xl mx-auto">
    <h2 class="text-4xl font-bold text-navy text-center mb-4">Meet the Team</h2>
    <p class="text-navy/60 text-center mb-16">More to come — we're just getting started.</p>
    <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-10">
      {team.map(({ name, title }) => (
        <div class="flex flex-col items-center text-center">
          <!-- Placeholder avatar circle -->
          <div class="w-28 h-28 rounded-full bg-deep-blue/20 mb-4 flex items-center justify-center">
            <span class="text-4xl text-deep-blue/40">👤</span>
          </div>
          <div class="font-bold text-navy">{name}</div>
          <div class="text-navy/60 text-sm">{title}</div>
        </div>
      ))}
    </div>
  </div>
</section>
```

**Note:** Real photos drop in by replacing the avatar `<div>` with an `<img>` — no structural change needed.

### Pattern 9: Animate-on-Scroll Usage

**What:** Add `animate-on-scroll` class to any element to get the Motion fade-in from Phase 1
**When to use:** Every section element — the `ScrollAnimations.astro` component handles all elements globally

```astro
<!-- On the section itself (whole section fades in) -->
<section class="py-24 px-4 bg-white animate-on-scroll">

<!-- OR on individual child elements for more granular control -->
<div class="grid grid-cols-3 gap-8">
  <div class="animate-on-scroll">Card 1</div>
  <div class="animate-on-scroll">Card 2</div>
  <div class="animate-on-scroll">Card 3</div>
</div>
```

**Critical:** The user specified "subtle fade-in animations only — no staggered reveals." Do NOT add delay timings between child cards. Apply `animate-on-scroll` at the section level or apply it to all child cards simultaneously (same trigger point). The existing `inView` callback fires per-element as each enters the viewport, which creates a natural stagger as users scroll — no additional delay needed.

### Anti-Patterns to Avoid

- **Stock photo `<img>` tags:** User explicitly said no stock photos. Use SVG icons, illustrations, and plain colored shapes.
- **Adding staggered animation delays:** User said "no staggered reveals." Don't add CSS animation delays or multiple `inView` calls with offsets.
- **Counting number animations on stats:** User said "no counting animations." Stats are static large numbers, not animated counters.
- **Fake testimonials with attributed quotes:** User said stats only for social proof — no names, no fake quotes.
- **Adding new npm packages for icons:** Don't install `@heroicons/react`, `lucide-react`, etc. Use inline SVG paths — zero dependency cost.
- **New JS framework components:** This is an Astro static site. All interactivity stays in `<script>` tags. No React, Vue, or Svelte components.
- **`min-h-screen` on body sections:** Only the hero should be full viewport height. Body sections use `py-24` for generous vertical padding.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Scroll animations | Custom `IntersectionObserver` code | `animate-on-scroll` class + existing `ScrollAnimations.astro` | Already implemented and working in Phase 1 |
| Icon components | Custom SVG component system | Inline SVG path strings | Zero overhead; `currentColor` for theming; copy paths from Heroicons |
| Responsive grid | Custom CSS grid/flexbox | Tailwind `grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3` | Already configured; all breakpoints available |
| Section-level data | External CMS or JSON files | Data arrays defined in `.astro` frontmatter | For 8–12 feature cards, inline arrays are the simplest correct approach |
| Section backgrounds | Custom CSS variables | Tailwind `bg-navy`, `bg-deep-blue`, `bg-white`, `bg-slate-50` | Brand tokens already in `@theme`; all utilities available |
| CTA button variants | Custom button components | Repeated Tailwind class string per variant | Two button styles maximum (dark-bg: `bg-gold text-navy`; light-bg: `bg-deep-blue text-white`) |

**Key insight:** Phase 2 has zero infrastructure problems to solve. Every challenge is content and layout composition — which classes to combine, what copy to write, how many sections to use.

---

## Common Pitfalls

### Pitfall 1: Hero Nav Overlap

**What goes wrong:** Full-viewport hero (`min-h-screen`) has content obscured behind the sticky nav bar (64px tall).
**Why it happens:** `min-h-screen` fills 100vh but nav is positioned `sticky top-0` above the content flow. The hero content starts from the very top.
**How to avoid:** Two safe approaches:
1. `flex items-center justify-center` on the hero — vertical centering naturally accounts for the nav visually
2. Add `pt-16` (64px) padding-top to the hero's inner content `<div>` if above-fold content must clear the nav exactly
**Warning signs:** Hero headline appears to be cut off at top on first load.

### Pitfall 2: animate-on-scroll Not Triggering on Hero

**What goes wrong:** The hero section (visible on page load) doesn't animate because it's already in the viewport when `inView` is initialized.
**Why it happens:** Motion `inView` fires the callback when the element enters the viewport. If the element is already visible at initialization time, `inView` fires immediately on page load — so the animation still runs, but very quickly. For elements below the fold, it fires when they scroll into view.
**How to avoid:** This is actually correct behavior — the hero will fade in on page load (good), and all other sections fade in on scroll (also good). No special handling needed.
**Warning signs:** None. This is expected behavior.

### Pitfall 3: Astro Data Arrays in Frontmatter

**What goes wrong:** TypeScript errors when using typed data arrays in frontmatter for feature cards or team members.
**Why it happens:** Astro requires TypeScript-valid frontmatter. Arrays of objects need consistent shape or type annotation.
**How to avoid:** Define arrays with explicit type or use `satisfies` — or just use `const` with object literal arrays (TypeScript infers shape automatically):

```astro
---
const features = [
  { title: 'Real-Time Scoring', desc: 'Live leaderboard updates...', icon: '...' },
  // TypeScript infers the shape from first element
];
---
```

No separate interface definition needed for small data arrays.
**Warning signs:** Build errors mentioning `any` types or property mismatch in template expressions.

### Pitfall 4: Section Color Contrast on Mixed Backgrounds

**What goes wrong:** Text is illegible — e.g., `text-navy` on `bg-navy`, or `text-white/70` on `bg-white`.
**Why it happens:** Copy-paste errors when switching between dark and light sections.
**How to avoid:** Firm rule — on dark sections (`bg-navy`, `bg-deep-blue`): use `text-white` and `text-white/70` for body. On light sections (`bg-white`, `bg-slate-50`): use `text-navy` and `text-navy/60` for body. Headings: `text-white` on dark, `text-navy` on light.
**Warning signs:** Any text that looks invisible or very low contrast in browser preview.

### Pitfall 5: CTA Button Contrast on Both Backgrounds

**What goes wrong:** Single button style looks wrong on both dark and light sections.
**Why it happens:** Gold button works on dark navy but gold on white is low contrast. Electric blue button works on white but disappears on deep-blue.
**How to avoid:** Two button variants:
- Dark section CTA: `bg-gold text-navy hover:bg-gold/90` — gold on dark is high contrast
- Light section CTA: `bg-deep-blue text-white hover:bg-deep-blue/90` — deep blue on white is high contrast
**Warning signs:** Button is hard to see, or hover state changes color dramatically.

### Pitfall 6: Image/Asset Paths for Icons

**What goes wrong:** `<img src="../../assets/images/icon1.svg">` returns 404 in build output.
**Why it happens:** Files in `assets/` are NOT automatically served by Astro. Only files in `public/` are served as static assets.
**How to avoid:** Either (a) copy needed assets to `public/images/` (already done for logos in Phase 1), or (b) use inline SVG instead of `<img>` for icons. Option (b) is recommended for feature icons since inline SVG is more flexible.
**Warning signs:** 404 errors in browser network tab for `.svg` files.

### Pitfall 7: Missing `max-w-*` on Section Inner Containers

**What goes wrong:** Section content stretches full width on large screens — text lines become unreadably long (80+ chars).
**Why it happens:** Forgetting the inner container `max-w-7xl mx-auto` wrapper.
**How to avoid:** Every section follows: `<section class="py-24 px-4 [bg]"><div class="max-w-7xl mx-auto">...</div></section>`. The outer section handles background color and vertical padding. The inner div constrains content width and centers it.
**Warning signs:** Content stretches edge-to-edge on 1920px+ screens.

---

## Code Examples

Verified patterns from official and current sources:

### Astro frontmatter data array for feature cards

```astro
---
// src/pages/features.astro
// Source: https://docs.astro.build/en/basics/astro-components/
import BaseLayout from '../layouts/BaseLayout.astro';

const features = [
  {
    title: 'Customizable Trivia Rounds',
    desc: 'Mix categories, difficulty levels, and formats to match your event theme.',
    icon: `<svg class="w-7 h-7" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/></svg>`,
  },
  // ... more features
];
---

<BaseLayout title="Features" description="...">
  {features.map(({ title, desc, icon }) => (
    <div class="bg-slate-50 rounded-brand p-6">
      <div class="text-electric-blue mb-3" set:html={icon} />
      <h3 class="font-bold text-navy mb-1">{title}</h3>
      <p class="text-navy/60 text-sm">{desc}</p>
    </div>
  ))}
</BaseLayout>
```

**Note:** Use `set:html={icon}` to render raw SVG strings. This is Astro's built-in equivalent of React's `dangerouslySetInnerHTML`. It is safe for trusted SVG strings defined in the same file.

### Tailwind v4 tokens available (confirmed from global.css)

```css
/* Available brand utilities — all from @theme in global.css */
bg-navy           /* #0a1628 */
bg-deep-blue      /* #1a3a6b */
bg-electric-blue  /* #2563eb */
bg-gold           /* #f59e0b */
bg-coral          /* #f97316 */

text-navy
text-deep-blue
text-electric-blue
text-gold
text-coral

border-navy
border-electric-blue

rounded-brand     /* 0.75rem */

/* Opacity modifiers work automatically */
bg-navy/90       /* 90% opacity */
text-white/70    /* 70% opacity white */
text-navy/60     /* 60% opacity navy */
```

### Motion animate-on-scroll (already wired — no new code needed)

```astro
<!-- Just add class="animate-on-scroll" to any element -->
<!-- ScrollAnimations.astro handles all elements with this class -->
<!-- Source: src/components/ScrollAnimations.astro (Phase 1) -->

<section class="py-24 px-4 bg-white animate-on-scroll">
  <!-- This section fades in (opacity 0→1, y 30→0) when 25% enters viewport -->
</section>
```

### Complete landing page section sequence

```
index.astro sections in order:
1. Hero          — bg-navy,     min-h-screen, headline + subhead + CTA button
2. Value Props   — bg-white,    py-24, 3-col card grid with icons
3. Dual Audience — bg-slate-50, py-24, 2-col side-by-side cards
4. How It Works  — bg-white,    py-24, 3-step numbered list
5. Social Proof  — bg-deep-blue, py-24, 4-stat grid in white/gold text
6. Final CTA     — bg-navy,     py-24, centered headline + CTA button
```

---

## Available Assets

### Brand Assets (confirmed in codebase)

| File | Location | Available As | Notes |
|------|----------|--------------|-------|
| RallyTrivia_logo_primary_transparent.svg | public/images/ | `<img src="/images/...">` | Already in public; used in Nav + Footer |
| RallyTrivia_logo_primary_transparent.png | public/images/ | `<img src="/images/...">` | PNG fallback |
| icon1.svg | assets/images/ | Inline SVG copy only | Complex brand Q-mark icon in brand blues |
| icon2.svg | assets/images/ | Inline SVG copy only | NOT in public/; needs copy to public/images/ if used via img src |
| favicon.svg | public/ | `<img src="/favicon.svg">` | Small brand mark |

**Recommendation:** For Phase 2 content sections, use inline SVG for feature icons (Heroicons-style, brand colored with `text-electric-blue` or `text-gold`). Do NOT try to use icon1/icon2 as section icons — they are complex brand marks, not UI icons. Use simple line icons for feature cards.

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| React component for icons (`<IconCheck />`) | Inline SVG in `.astro` | N/A for this stack | No React; inline SVG is idiomatic for Astro static sites |
| Framer Motion | Motion (`import { animate, inView } from 'motion'`) | ~2024 rebranding | Already installed; `inView` is the correct API for scroll animations |
| Intersection Observer polyfill | Native browser API (Motion handles it) | All modern browsers support it | No polyfill needed |
| CSS `@keyframes` animations | Motion `animate()` | N/A | Motion handles easing curves better; already configured in ScrollAnimations.astro |

---

## Open Questions

1. **Real social proof data**
   - What we know: STATE.md flags "Confirm whether real social proof data is available" as a concern
   - What's unclear: Whether actual event stats (events hosted, amounts raised) exist
   - Recommendation: Use plausible-but-impressive placeholder numbers per user decision. Stat suggestions: "500+ events hosted", "$2M+ raised for nonprofits", "50+ cities", "10,000+ happy guests". Flag in code comments for easy update when real data exists.

2. **About page: founder name/photo**
   - What we know: ABOU-02 requires a team/founder section; user said placeholder with real info to fill in later
   - What's unclear: Whether even a placeholder name exists to use
   - Recommendation: Use "Coming Soon" or "[Founder Name]" placeholder text with a gray circle avatar. Structure ready for real content drop-in.

3. **CTA button accent color consistency**
   - What we know: User said "Claude's discretion" for button accent color
   - What's unclear: Whether to use gold uniformly or contextually (gold on dark, deep-blue on light)
   - Recommendation: Use gold (`bg-gold text-navy`) as the primary accent CTA on dark sections; deep-blue (`bg-deep-blue text-white`) for secondary CTAs on light sections. This maximizes contrast on both backgrounds and creates visual hierarchy.

4. **Features page hero height**
   - What we know: Features and About pages get heroes per user decision (dark hero, light body)
   - What's unclear: Whether features/about heroes should be full-screen (`min-h-screen`) or shorter (`py-40`)
   - Recommendation: Full-screen heroes on features and about feel heavy for secondary pages. Use `py-32 md:py-40` (shorter hero) for features and about — reserve `min-h-screen` for the landing page. The landing page hero is the primary conversion moment.

---

## Sources

### Primary (HIGH confidence)

- Phase 1 RESEARCH.md (`.planning/phases/01-infrastructure/01-RESEARCH.md`) — verified all infrastructure decisions and patterns in place
- Codebase inspection (`src/` directory) — confirmed actual state of all component files, installed packages, and brand tokens
- `src/styles/global.css` — confirmed brand tokens: navy #0a1628, deep-blue #1a3a6b, electric-blue #2563eb, gold #f59e0b, coral #f97316
- `src/components/ScrollAnimations.astro` — confirmed `inView` + `animate` API, `animate-on-scroll` class selector, `amount: 0.25` trigger
- `package.json` — confirmed motion@12.34.3 installed, no additional packages needed
- `public/images/` directory — confirmed logo assets available as static files
- `assets/images/` directory — confirmed icon1.svg, icon2.svg exist but are NOT in public/

### Secondary (MEDIUM confidence)

- [Astro component template expressions](https://docs.astro.build/en/basics/astro-components/#component-template) — `.map()` in JSX expressions, `set:html` for raw HTML/SVG strings
- [Heroicons](https://heroicons.com) — MIT licensed SVG icon paths; can be copied inline with no attribution required; version referenced for correct path format

### Tertiary (LOW confidence)

- Marketing page section ordering — "hero → value props → dual audience → how it works → social proof → final CTA" is a common SaaS marketing pattern but is locked by user decision anyway; no external verification needed

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — no new packages; verified from installed package.json and existing src/ files
- Architecture patterns: HIGH — all patterns derived from Phase 1's working implementation; extend existing patterns, not new ones
- Copy guidance: MEDIUM — copywriting direction from CONTEXT.md is clear, but specific copy is Claude's discretion and user will review
- Pitfalls: HIGH — all pitfalls derived from actual codebase examination and known Astro/Tailwind behaviors

**Research date:** 2026-02-22
**Valid until:** 2026-03-22 (stable ecosystem; no breaking changes expected in Astro 5 / Tailwind v4 / Motion 12 in this window)
