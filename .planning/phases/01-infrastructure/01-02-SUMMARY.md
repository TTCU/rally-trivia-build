---
phase: 01-infrastructure
plan: 02
subsystem: ui
tags: [astro, tailwind-v4, layout, nav, footer, seo, motion, responsive, static-site]

requires:
  - phase: 01-01
    provides: [static-astro-build, tailwind-v4-brand-tokens, placeholder-pages, fontsource]
provides:
  - BaseLayout wrapping every page with shared Nav, Footer, SEO meta tags, and scroll animations
  - Responsive Nav with sticky glass effect, desktop links, hamburger mobile menu
  - Footer with logo, tagline, page links, copyright
  - BaseHead with canonical URL, OG tags, Twitter card, title format
  - ScrollAnimations using Motion inView + animate for scroll-triggered fade-in
  - All 4 placeholder pages wired to BaseLayout
affects: [all-phase-2-content-pages]

tech-stack:
  added: []
  patterns:
    - "BaseLayout as single page wrapper: all pages import BaseLayout, no direct html/head/body"
    - "BaseHead receives title/description/image props; generates canonical from Astro.site + pathname"
    - "Nav uses vanilla JS script block for hamburger toggle (no framework dependency)"
    - "animate-on-scroll class pattern: add class to any section, Motion animates it on viewport entry"
    - "Logo served from public/images/ for static asset referencing (not Astro Image component)"
    - "Sticky nav with bg-navy/90 + backdrop-blur-md for glass effect"

key-files:
  created:
    - src/layouts/BaseLayout.astro
    - src/components/Nav.astro
    - src/components/ScrollAnimations.astro
    - public/images/RallyTrivia_logo_primary_transparent.svg
    - public/images/RallyTrivia_logo_primary_transparent.png
  modified:
    - src/components/BaseHead.astro
    - src/components/Footer.astro
    - src/pages/index.astro
    - src/pages/features.astro
    - src/pages/about.astro
    - src/pages/contact.astro
  deleted:
    - src/components/Header.astro
    - src/components/HeaderLink.astro
    - src/layouts/BlogPost.astro

key-decisions:
  - "Logo served from public/images/ (static serving) rather than using Astro Image component — simpler for SVG, no optimization overhead"
  - "Nav uses vanilla JS hamburger toggle with aria-expanded for accessibility — no Alpine or framework JS needed"
  - "Sticky nav with bg-navy/90 + backdrop-blur-md chosen for glass effect — clean and modern per brand"
  - "ScrollAnimations uses inView callback pattern (not inView return-based) for correct Motion API usage"

patterns-established:
  - "All pages use BaseLayout — no page imports html/head/body directly"
  - "animate-on-scroll class on any section triggers Motion fade-in + slide-up"
  - "Nav and Footer both reference /images/RallyTrivia_logo_primary_transparent.svg"

requirements-completed: [INFR-03, INFR-04, INFR-05, INFR-07, INFR-08, INFR-10]

duration: 2m 4s
completed: 2026-02-22
---

# Phase 01 Plan 02: Layout System Summary

**Responsive BaseLayout shell with sticky nav (hamburger on mobile), SEO BaseHead (canonical + OG + Twitter card), dark navy footer, and Motion scroll animations — all 4 pages wired to shared layout and building as static HTML.**

## Performance

- **Duration:** ~2 min 4s
- **Started:** 2026-02-22T09:57:52Z
- **Completed:** 2026-02-22T10:00:00Z
- **Tasks:** 2
- **Files modified:** 11 (5 created, 3 deleted)

## Accomplishments

- BaseLayout wraps all 4 pages with Nav, Footer, SEO, and ScrollAnimations in a single html/head/body structure
- Responsive Nav with sticky glass effect (`bg-navy/90 backdrop-blur-md`), desktop links hidden on mobile (`hidden md:flex`), hamburger menu (`md:hidden`) with vanilla JS toggle and aria-expanded
- BaseHead generates canonical URLs from `Astro.site + pathname`, OG tags with title format `{title} | Rally Trivia`, Twitter card, and favicon fallback
- Footer with Rally Trivia logo, tagline, page links, and `© 2026 Rally Trivia. All rights reserved.`
- ScrollAnimations imports Motion `inView + animate`, applies `opacity: [0,1], y: [30,0]` fade-in to all `animate-on-scroll` elements
- Build verified: 4 HTML files, sitemap-index.xml, no `_worker.js`

## Task Commits

Each task was committed atomically:

1. **Task 1: Create BaseHead, Nav, Footer, ScrollAnimations** - `a8d90a5` (feat)
2. **Task 2: Create BaseLayout and wire all pages** - `3592bd5` (feat)

**Plan metadata:** (committed with final docs commit)

## Files Created/Modified

- `src/layouts/BaseLayout.astro` - Page wrapper: imports BaseHead, Nav, Footer, ScrollAnimations; flex-col layout with flex-1 main
- `src/components/BaseHead.astro` - SEO meta tags: canonical, og:title/description/image, Twitter card, title format
- `src/components/Nav.astro` - Sticky responsive nav with logo, desktop links, CTA button, hamburger menu
- `src/components/Footer.astro` - Dark navy footer with logo, tagline, links, copyright
- `src/components/ScrollAnimations.astro` - Motion inView/animate scroll-triggered fade-in
- `src/pages/index.astro` - Wired to BaseLayout with title/description and animate-on-scroll section
- `src/pages/features.astro` - Wired to BaseLayout
- `src/pages/about.astro` - Wired to BaseLayout
- `src/pages/contact.astro` - Wired to BaseLayout
- `public/images/RallyTrivia_logo_primary_transparent.svg` - Logo copied from assets/ for static serving
- `public/images/RallyTrivia_logo_primary_transparent.png` - PNG variant copied alongside

## Decisions Made

1. **Logo in public/images/** — Logo files from `assets/images/` copied to `public/images/` so they're served as static assets via `/images/` URL path. Avoids Astro Image component complexity for SVG logo.
2. **Vanilla JS hamburger toggle** — No Alpine.js or Preact needed. 8 lines of vanilla JS handles aria-expanded + hidden class toggle with accessibility attributes.
3. **Motion inView callback pattern** — Used `inView(selector, (element) => { animate(element, ...) })` callback form, which is correct for per-element animation triggering (not the return/cleanup form).
4. **Sticky glass nav** — `sticky top-0 z-50 bg-navy/90 backdrop-blur-md` gives the modern frosted glass effect on scroll, keeping nav visible without covering content.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Copied logo to public/images/ for static serving**
- **Found during:** Task 1 (Nav + Footer component creation)
- **Issue:** Plan referenced logo from `assets/images/` but Nav/Footer used `/images/` URL paths. The `public/images/` directory didn't exist, so logo would 404 at runtime.
- **Fix:** Created `public/images/` directory and copied `RallyTrivia_logo_primary_transparent.svg` and `.png` from `assets/images/` into it.
- **Files modified:** `public/images/RallyTrivia_logo_primary_transparent.svg`, `public/images/RallyTrivia_logo_primary_transparent.png` (created)
- **Verification:** Build succeeds; HTML references `/images/RallyTrivia_logo_primary_transparent.svg` which resolves to the copied file in `public/`
- **Committed in:** a8d90a5 (Task 1 commit)

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** Required for correct logo rendering. No scope creep.

## Issues Encountered

None beyond the logo path fix documented above.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Layout shell is complete and production-ready
- Phase 2 content pages can drop into `<BaseLayout title="..." description="...">` and immediately inherit Nav, Footer, SEO, responsiveness, and scroll animations
- Add `class="animate-on-scroll"` to any section for automatic Motion fade-in
- Brand colors (`text-navy`, `text-deep-blue`, `text-electric-blue`, `text-gold`, `bg-gold`) available via Tailwind v4 theme tokens
- Active link highlighting in Nav works automatically from `Astro.url.pathname`

---
*Phase: 01-infrastructure*
*Completed: 2026-02-22*

## Self-Check: PASSED

All files confirmed present:
- src/layouts/BaseLayout.astro — FOUND
- src/components/Nav.astro — FOUND
- src/components/Footer.astro — FOUND
- src/components/BaseHead.astro — FOUND
- src/components/ScrollAnimations.astro — FOUND
- public/images/RallyTrivia_logo_primary_transparent.svg — FOUND
- .planning/phases/01-infrastructure/01-02-SUMMARY.md — FOUND

All commits confirmed:
- a8d90a5 feat(01-02): create BaseHead, Nav, Footer, and ScrollAnimations components — FOUND
- 3592bd5 feat(01-02): create BaseLayout and wire all pages to shared layout — FOUND
