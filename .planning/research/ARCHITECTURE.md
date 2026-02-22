# Architecture Research

**Domain:** Astro marketing/landing site on Cloudflare Workers
**Researched:** 2026-02-22
**Confidence:** HIGH

## Standard Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Browser / CDN Edge                        │
│  Visitor requests page → Cloudflare serves from edge cache  │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│             Cloudflare Workers (Static Asset Host)           │
│                                                              │
│  assets.directory: ./dist                                    │
│  URL matching → serve pre-built HTML/CSS/JS/images           │
│  No worker script needed (pure static delivery)              │
└──────────────────────────────┬──────────────────────────────┘
                               │ built from
┌──────────────────────────────▼──────────────────────────────┐
│                   Astro Build Process                        │
│                                                              │
│  src/pages/           → HTML routes (file-based routing)     │
│  src/layouts/         → Page shell with shared nav/footer    │
│  src/components/      → Reusable UI sections                 │
│  src/styles/          → Tailwind global CSS                  │
│  public/              → Static pass-through assets           │
└──────────────────────────────┬──────────────────────────────┘
                               │ source
┌──────────────────────────────▼──────────────────────────────┐
│                        Source Files                          │
│                                                              │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐             │
│  │  Pages     │  │ Components │  │  Layouts   │             │
│  │ index.astro│  │ Hero.astro │  │ Base.astro │             │
│  │ features   │  │ Features   │  │            │             │
│  │ about      │  │ Nav/Footer │  │            │             │
│  │ contact    │  │ CTASection │  │            │             │
│  └────────────┘  └────────────┘  └────────────┘             │
└─────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Typical Implementation |
|-----------|----------------|------------------------|
| `src/layouts/BaseLayout.astro` | Full HTML shell, meta tags, global styles, nav, footer | Single layout wrapping all pages |
| `src/pages/index.astro` | Landing page composition — assembles hero, features, CTA sections | Uses BaseLayout, imports section components |
| `src/pages/features.astro` | Features page — detailed platform capabilities | Uses BaseLayout, FeatureGrid component |
| `src/pages/about.astro` | About/story page — mission and team | Uses BaseLayout, prose + image sections |
| `src/pages/contact.astro` | Demo request form | Uses BaseLayout, ContactForm component |
| `src/components/Nav.astro` | Site navigation — logo, links, mobile menu | Renders inside BaseLayout |
| `src/components/Footer.astro` | Footer — links, copyright, brand | Renders inside BaseLayout |
| `src/components/Hero.astro` | Hero section — headline, subhead, primary CTA | Used only on index page |
| `src/components/FeatureCard.astro` | Single feature block — icon, title, description | Used in grid on features page |
| `src/components/CTASection.astro` | Call-to-action band — links to contact/demo | Used at bottom of multiple pages |
| `src/components/ContactForm.astro` | Demo request form — name, email, org, message | Static form, no backend yet |
| `public/` | Logo, images, favicon — served as-is | No Astro processing |

## Recommended Project Structure

```
rally-trivia-web/
├── src/
│   ├── pages/
│   │   ├── index.astro          # Landing page (hero + value props + CTA)
│   │   ├── features.astro       # Platform capabilities detail
│   │   ├── about.astro          # Story and mission page
│   │   └── contact.astro        # Demo request form
│   ├── layouts/
│   │   └── BaseLayout.astro     # HTML shell, nav, footer, meta
│   ├── components/
│   │   ├── Nav.astro            # Site navigation
│   │   ├── Footer.astro         # Site footer
│   │   ├── Hero.astro           # Landing hero section
│   │   ├── ValueProp.astro      # Single value proposition block
│   │   ├── FeatureCard.astro    # Feature item (icon + text)
│   │   ├── CTASection.astro     # Conversion banner (demo CTA)
│   │   └── ContactForm.astro    # Demo request form fields
│   └── styles/
│       └── global.css           # Tailwind @import, custom tokens
├── public/
│   ├── favicon.svg
│   └── images/                  # Any public images (processed separately)
├── assets/
│   └── images/                  # Brand assets (existing — logo, icons)
├── wrangler.jsonc               # Cloudflare Workers static config
├── astro.config.mjs             # Astro config + Tailwind integration
├── tailwind.config.mjs          # Tailwind theme (brand colors)
├── tsconfig.json
└── package.json
```

### Structure Rationale

- **`src/pages/`:** Each file = one route. Astro's file-based router requires this. Four pages: index, features, about, contact.
- **`src/layouts/`:** One `BaseLayout.astro` contains the full HTML document shell, `<head>` with meta tags, global nav, and footer. All pages use this to ensure consistency.
- **`src/components/`:** Flat (no subfolders) because the site is small — four pages with a handful of section components each. No feature-folder organization needed until the project grows significantly.
- **`src/styles/`:** One `global.css` file. Tailwind v4 uses `@import "tailwindcss"` rather than directives; this file also holds CSS custom properties for brand color tokens.
- **`public/`:** Static pass-through. Logo SVG/PNG referenced with absolute paths. Brand assets in `assets/images/` should be moved or symlinked here so Astro can reference them.
- **`wrangler.jsonc`:** Minimal config pointing `assets.directory` at `./dist`. No `main` field needed — pure static delivery with no Worker script.

## Architectural Patterns

### Pattern 1: Static-First with No Adapter

**What:** Deploy Astro with default `output: 'static'` (no adapter). Build generates a `dist/` folder of plain HTML, CSS, and JS files. Cloudflare Workers serves this directory directly.

**When to use:** Any marketing site with no server-side logic. This includes all pages for Rally Trivia — content is pre-known at build time.

**Trade-offs:** Build is simple and fast; no runtime complexity; perfect Lighthouse scores; Cloudflare edge cache is free and automatic. Con: form submission requires a third-party service or a future upgrade to server mode.

**Example:**
```jsonc
// wrangler.jsonc — pure static, no Worker script needed
{
  "name": "rally-trivia-web",
  "compatibility_date": "2026-02-22",
  "assets": {
    "directory": "./dist"
  }
}
```

### Pattern 2: BaseLayout Slot Composition

**What:** All pages render inside a single `BaseLayout.astro` that owns the full HTML document shell. Pages pass their unique content into the layout's `<slot />`. Title and meta tags pass via props.

**When to use:** Every page on the site. This ensures nav and footer never drift out of sync.

**Trade-offs:** Simple and consistent. Downside: only one layout variant needed for a 4-page marketing site, so no complexity here.

**Example:**
```astro
---
// src/layouts/BaseLayout.astro
interface Props {
  title: string;
  description?: string;
}
const { title, description = "Rally Trivia — Live trivia for nonprofit fundraisers and corporate events" } = Astro.props;
---
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width" />
    <meta name="description" content={description} />
    <title>{title} | Rally Trivia</title>
    <link rel="stylesheet" href="/styles/global.css" />
  </head>
  <body>
    <Nav />
    <main>
      <slot />
    </main>
    <Footer />
  </body>
</html>
```

### Pattern 3: Section-Based Page Composition

**What:** Pages are composed by importing and stacking section components. The page file itself contains minimal logic — it's a composition layer, not an implementation layer.

**When to use:** Landing page and features page. Each "section" (Hero, ValueProps, CTA, etc.) is a self-contained component with its own markup and styles.

**Trade-offs:** Enables reuse (CTASection appears on multiple pages) and makes the page intent obvious. Each section component can be swapped, reordered, or hidden without touching others.

**Example:**
```astro
---
// src/pages/index.astro
import BaseLayout from '../layouts/BaseLayout.astro';
import Hero from '../components/Hero.astro';
import ValuePropsSection from '../components/ValuePropsSection.astro';
import CTASection from '../components/CTASection.astro';
---
<BaseLayout title="Live Trivia for Your Next Event">
  <Hero />
  <ValuePropsSection />
  <CTASection />
</BaseLayout>
```

## Data Flow

### Request Flow (Static Delivery)

```
Visitor requests https://rallytrivia.com/
    |
    v
Cloudflare Edge (nearest data center)
    |
    v
Static Asset Match: /dist/index.html exists?
    |     YES → serve from edge cache (0ms origin fetch on cache hit)
    |     NO  → 404 (shouldn't happen after build)
    v
Browser renders pre-built HTML
    |
    v
Browser fetches referenced CSS/JS/images (also edge-cached)
    |
    v
Page is interactive (no client JS except what Astro emits,
which is zero for a pure .astro site)
```

### Build-Time Data Flow

```
astro build
    |
    v
Astro reads src/pages/*.astro
    |
    v
Each page imports layout + components
    |
    v
Component scripts run (frontmatter JS executes at BUILD time)
    |
    v
HTML rendered to string, Tailwind CSS purged and emitted
    |
    v
dist/ written: index.html, features/index.html, about/index.html, contact/index.html
    + _astro/ (hashed CSS/JS assets)
    |
    v
wrangler deploy uploads dist/ to Cloudflare
```

### Key Data Flows

1. **Brand assets into pages:** SVG/PNG logo lives in `public/images/`. `Nav.astro` references it via absolute URL `/images/logo.svg`. Astro copies `public/` to `dist/` untouched.
2. **Props from page to layout:** Pages pass `title` and `description` strings as props to `BaseLayout.astro`, which injects them into `<head>` meta tags.
3. **Form submission (deferred):** `ContactForm.astro` renders static HTML form fields. No action URL yet — wired up in a follow-on phase once backend/email delivery is decided.

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| 0-10k visits/mo | Static files on Cloudflare Workers — no changes needed, costs essentially zero |
| 10k-1M visits/mo | Still pure static — Cloudflare edge caching absorbs all traffic; no origin server to scale |
| 1M+ visits/mo | Still static files, still no changes needed; Cloudflare's global CDN handles this trivially |
| Form backend needed | Add Cloudflare Workers function for form POST, or connect to Resend/SendGrid; minimal architecture change |

### Scaling Priorities

1. **First bottleneck:** Not performance — it's content. The marketing site's constraint is copy quality and conversion rate, not infrastructure. Static Cloudflare delivery doesn't have scaling limits at this site's traffic level.
2. **Second bottleneck:** Form handling. The static form has no backend. This is an intentional deferral, not a scaling concern. When addressed, add a Workers function or external service endpoint.

## Anti-Patterns

### Anti-Pattern 1: Installing the Cloudflare Adapter for a Static Site

**What people do:** Run `npx astro add cloudflare` because the project deploys to Cloudflare, then set `output: 'server'`.

**Why it's wrong:** The adapter switches Astro to on-demand (server-side) rendering, which means a Worker runs on every request. For a marketing site with no dynamic content, this wastes compute, adds latency, and introduces complexity with no benefit.

**Do this instead:** Use `output: 'static'` (Astro default). No adapter needed. `wrangler.jsonc` with just `assets.directory: "./dist"`. Cloudflare serves HTML directly from edge cache.

### Anti-Pattern 2: Putting Brand Assets in `src/` Instead of `public/`

**What people do:** Reference the existing `assets/images/` logo directly from component code with relative imports.

**Why it's wrong:** Astro processes files in `src/` through its build pipeline. If assets live outside `src/` and `public/`, they won't be included in the build output unless explicitly imported. Inconsistent referencing leads to broken images in production.

**Do this instead:** Move brand images to `public/images/` (or configure Astro to reference them from `assets/` using image imports). Reference via absolute paths: `<img src="/images/RallyTrivia_logo_primary_transparent.svg" />`.

### Anti-Pattern 3: Inline Styles Instead of Tailwind Classes

**What people do:** Add `style="color: #1e3a5f"` or a `<style>` block inside component files instead of using Tailwind utility classes.

**Why it's wrong:** Bypasses the design system. Brand colors should be configured as Tailwind tokens (`navy`, `electric-blue`) in `tailwind.config.mjs`. Using inline styles or magic hex values creates inconsistency and makes global theming changes difficult.

**Do this instead:** Define brand palette in Tailwind config as named colors. Use `class="text-navy bg-electric-blue"` throughout.

### Anti-Pattern 4: Monolithic Page Files

**What people do:** Write the entire landing page as a single 400-line `index.astro` with all sections inlined.

**Why it's wrong:** Sections become impossible to reuse (CTASection appears on multiple pages), hard to scan, and difficult to hand off or iterate on.

**Do this instead:** Each named section (Hero, ValueProps, CTASection, FeatureGrid) is its own component file. The page file is a clean composition of imports — 20 lines maximum.

## Integration Points

### External Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| Cloudflare Workers (hosting) | `wrangler deploy` uploads `dist/` | Static assets only; no Worker script needed for this site |
| Form backend (deferred) | POST to a Workers function endpoint or third-party (Resend, Formspree) | Out of scope for initial build; form UI ships without action |
| Analytics (deferred) | Script tag in BaseLayout head or Cloudflare Web Analytics | Out of scope for initial launch per PROJECT.md |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| Page → Layout | Astro props (title, description strings) | One-way: page passes metadata up |
| Layout → Components (Nav, Footer) | No props needed at this scale | Nav and Footer are self-contained |
| Page → Section Components | Astro props for any customizable text | Most section components can be hardcoded; props useful for reusable CTASection |
| Build → Cloudflare | Wrangler CLI reads `dist/` from filesystem | No runtime communication |

## Build Order Implications

Components have a clear dependency hierarchy that determines build order during project setup:

```
1. Global styles (tailwind.config.mjs, src/styles/global.css)
        |
        v
2. Shared components (Nav.astro, Footer.astro)
        |
        v
3. BaseLayout.astro (depends on Nav, Footer, global styles)
        |
        v
4. Section components (Hero, FeatureCard, CTASection, ContactForm)
        |
        v
5. Pages (index, features, about, contact) — depend on layout + sections
        |
        v
6. wrangler.jsonc + astro.config.mjs (infrastructure config)
        |
        v
7. Deploy (wrangler deploy) — requires all above
```

**Recommended implementation sequence for phases:**
- Build BaseLayout + Nav + Footer first — every subsequent page depends on them
- Then build pages in priority order: index (highest conversion value) → contact → features → about
- Deploy configuration should be verified with a skeleton page before full content is built, to catch Cloudflare config issues early

## Sources

- [Astro Project Structure — official docs](https://docs.astro.build/en/basics/project-structure/) — HIGH confidence
- [Astro Layouts — official docs](https://docs.astro.build/en/basics/layouts/) — HIGH confidence
- [Astro Components — official docs](https://docs.astro.build/en/basics/astro-components/) — HIGH confidence
- [Deploy Astro to Cloudflare — official docs](https://docs.astro.build/en/guides/deploy/cloudflare/) — HIGH confidence
- [Cloudflare Workers: Astro guide](https://developers.cloudflare.com/workers/framework-guides/web-apps/astro/) — HIGH confidence
- [Cloudflare Workers Static Assets](https://developers.cloudflare.com/workers/static-assets/) — HIGH confidence
- [astrojs/cloudflare adapter docs](https://docs.astro.build/en/guides/integrations-guide/cloudflare/) — HIGH confidence
- [Astro joins Cloudflare announcement](https://blog.cloudflare.com/astro-joins-cloudflare/) — HIGH confidence
- [Astro file organization best practices](https://tillitsdone.com/blogs/astro-js-file-organization-guide/) — MEDIUM confidence
- [Astro v6 Beta + Cloudflare Workers runtime — InfoQ](https://www.infoq.com/news/2026/02/astro-v6-beta-cloudflare/) — MEDIUM confidence

---
*Architecture research for: Astro marketing site on Cloudflare Workers*
*Researched: 2026-02-22*
