# Phase 1: Infrastructure - Research

**Researched:** 2026-02-22
**Domain:** Astro 5 + Tailwind v4 + Cloudflare Workers static deployment + Motion animations + Fontsource fonts
**Confidence:** HIGH

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Brand & typography**
- Geometric sans-serif font family (e.g., Inter, Plus Jakarta Sans) — clean, modern, tech-forward
- Warm accent colors alongside the core blues (gold, coral tones) for CTAs and highlights — energy and excitement
- Bold, punchy headings — large, heavy-weight with strong contrast against body text
- Core palette: navy, deep blue, electric blue + warm accents for interactive elements

**Navigation design**
- Nav links: Features, About, Contact (no explicit Home link — logo click returns home)
- CTA button text: "Request a Demo"
- Layout and sticky behavior: Claude's discretion (see below)
- Mobile: hamburger menu with standard behavior

**Footer content**
- Standard marketing footer: logo, page links, brief tagline, copyright
- No social media icons for now — accounts don't exist yet
- Copyright text only, no legal page links: "© 2026 Rally Trivia. All rights reserved."
- Footer background treatment: Claude's discretion

**Overall visual tone**
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

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| INFR-01 | Astro project with static output deployed to Cloudflare Workers | Cloudflare Workers static assets config; remove adapter; no `main` in wrangler.json |
| INFR-02 | Tailwind CSS v4 with brand color tokens (navy, deep blue, electric blue) | @tailwindcss/vite plugin; `@theme` directive in global.css for custom color tokens |
| INFR-03 | Shared navigation with logo, page links, and CTA button | Rebuild Header.astro; hamburger via vanilla JS `<script>` in Astro component |
| INFR-04 | Shared footer with links and brand info | Rebuild Footer.astro; dark navy background; copyright text; logo |
| INFR-05 | BaseLayout with SEO meta tags on every page | Replace BlogPost layout with new BaseLayout; canonical URL + OG tags pattern |
| INFR-06 | Sitemap generation via @astrojs/sitemap | Already installed; set `site` in astro.config.mjs; outputs sitemap-index.xml |
| INFR-07 | Responsive design across mobile, tablet, and desktop | Tailwind responsive prefixes (sm:, md:, lg:); hamburger nav for mobile |
| INFR-08 | Scroll-triggered animations using Motion library | `npm install motion`; `import { animate, inView } from "motion"` in `<script>` tags |
| INFR-09 | Self-hosted fonts via Fontsource | `npm install @fontsource-variable/plus-jakarta-sans`; import in BaseLayout |
| INFR-10 | Brand logo and assets integrated throughout | Logo SVG already in `assets/images/`; use in nav and footer |
</phase_requirements>

---

## Summary

The project starts from an Astro 5 blog starter template (the default Cloudflare-scaffolded template). Nearly all existing components and configuration need to be replaced or significantly rewritten — the current `Header.astro`, `Footer.astro`, `BlogPost.astro` layout, global CSS, and `wrangler.json` all target a blog use case rather than a marketing site. This is effectively a clean-build within an existing Astro 5 project shell.

The most critical infrastructure task is the Cloudflare Workers deployment configuration. The current `wrangler.json` is set up for SSR with `@astrojs/cloudflare` adapter (has `main`, `ASSETS` binding, `nodejs_compat`). For a purely static Astro site, the adapter must be removed and `wrangler.json` simplified to assets-only (no `main` field, no `binding`). Cloudflare Workers now fully supports static-asset-only deploys without a worker script entry point.

The tech stack for this phase is well-proven and all pieces integrate cleanly: Tailwind v4 via `@tailwindcss/vite` (CSS-first config via `@theme`), Motion via npm for scroll animations in Astro `<script>` tags, and Fontsource variable fonts imported in the BaseLayout. The brand logo SVG already exists at `assets/images/`. The biggest "watch out" is the Tailwind v4 API change — there is no `tailwind.config.js` for the primary configuration path; all design tokens live in the CSS `@theme` block.

**Primary recommendation:** Strip the SSR adapter and wrangler config down to static-assets-only, install Tailwind v4 via Vite plugin, rebuild Navigation/Footer/BaseLayout from scratch for the marketing site, install Motion and Fontsource, then verify `wrangler deploy` produces a live URL with no adapter artifacts.

---

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| astro | 5.x (installed: 5.16.2) | Static site framework | Already in project; Astro 5 is current stable |
| @tailwindcss/vite | 4.x | Tailwind v4 Vite plugin | Official Tailwind v4 integration path for Astro; replaces deprecated @astrojs/tailwind |
| tailwindcss | 4.x | Utility CSS framework | Required peer for @tailwindcss/vite |
| motion | 12.x (latest: ~12.34.3) | Scroll-triggered animations | Specified in INFR-08; vanilla JS API, no framework dep |
| @fontsource-variable/plus-jakarta-sans | 5.x | Self-hosted variable font | Geometric sans-serif; matches brand direction; variable = single import |
| @astrojs/sitemap | 3.x (installed: 3.6.0) | Sitemap XML generation | Already installed; outputs sitemap-index.xml + sitemap-0.xml |
| wrangler | 4.x (installed: 4.56.0) | Deploy to Cloudflare Workers | Already installed |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| @fontsource-variable/inter | 5.x | Alternative geometric font | If Plus Jakarta Sans feels too distinctive; Inter is more neutral |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| @fontsource-variable/plus-jakarta-sans | @fontsource-variable/inter | Inter is neutral/ubiquitous; Plus Jakarta has more personality — better for brand |
| motion (npm) | Motion via CDN ESM | CDN avoids bundling but loses tree-shaking and version control |
| Tailwind v4 @theme | tailwind.config.js (v3 style) | v3 config file works in v4 but is the compatibility path; @theme is idiomatic v4 |

**Installation:**

```bash
# Tailwind v4
npm install tailwindcss @tailwindcss/vite

# Scroll animations
npm install motion

# Font (variable)
npm install @fontsource-variable/plus-jakarta-sans
```

---

## Architecture Patterns

### Recommended Project Structure

```
src/
├── components/
│   ├── BaseHead.astro       # SEO meta tags (title, description, OG, canonical)
│   ├── Nav.astro            # Site-wide navigation (logo + links + CTA + hamburger)
│   └── Footer.astro         # Site-wide footer (logo, links, tagline, copyright)
├── layouts/
│   └── BaseLayout.astro     # Wraps html/head/body; imports BaseHead + Nav + Footer
├── pages/
│   ├── index.astro          # Placeholder home (Phase 2 fills content)
│   ├── features.astro       # Placeholder (Phase 2)
│   ├── about.astro          # Placeholder (Phase 2)
│   └── contact.astro        # Placeholder (Phase 3)
├── styles/
│   └── global.css           # @import "tailwindcss"; @theme { brand tokens }
└── consts.ts                # SITE_TITLE, SITE_DESCRIPTION, SITE_URL
assets/
└── images/                  # Brand logos already present (SVG + PNG)
public/
└── favicon.svg              # Replace with brand favicon
```

### Pattern 1: Tailwind v4 with @theme Brand Tokens

**What:** Define all brand design tokens in CSS `@theme` block inside `global.css`. No JS config file needed.
**When to use:** Always — this is the v4 idiomatic approach. All `@theme` variables become Tailwind utilities automatically.

```css
/* src/styles/global.css */
/* Source: https://tailwindcss.com/docs/theme */

@import "tailwindcss";

@theme {
  /* Brand color palette */
  --color-navy: #0a1628;
  --color-deep-blue: #1a3a6b;
  --color-electric-blue: #2563eb;

  /* Warm accents for CTAs and highlights */
  --color-gold: #f59e0b;
  --color-coral: #f97316;

  /* Typography */
  --font-sans: 'Plus Jakarta Sans Variable', system-ui, sans-serif;

  /* Rounded geometry for friendly brand feel */
  --radius-brand: 0.75rem;
}
```

This generates utilities like `bg-navy`, `text-electric-blue`, `bg-gold`, `border-coral` automatically.

### Pattern 2: BaseLayout wrapping every page

**What:** A single layout component that every page imports. Contains `<html>`, `<head>` (via BaseHead), Nav, `<slot />`, and Footer.
**When to use:** Every page — ensures nav, footer, and SEO are always present.

```astro
---
// src/layouts/BaseLayout.astro
// Source: https://docs.astro.build/en/basics/layouts/
import '@fontsource-variable/plus-jakarta-sans';
import BaseHead from '../components/BaseHead.astro';
import Nav from '../components/Nav.astro';
import Footer from '../components/Footer.astro';

interface Props {
  title: string;
  description: string;
  image?: string;
}

const { title, description, image } = Astro.props;
---

<!doctype html>
<html lang="en">
  <head>
    <BaseHead title={title} description={description} image={image} />
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

### Pattern 3: Motion Scroll Animations in Astro `<script>` Tags

**What:** Import Motion functions inside Astro component `<script>` blocks. Astro automatically bundles these.
**When to use:** Any component that needs scroll-triggered fade-in animations.

```astro
<!-- Source: https://developers.netlify.com/guides/motion-animation-library-with-astro/ -->
<script>
  import { animate, inView } from "motion";

  // Fade in sections as they enter the viewport
  inView(".animate-on-scroll", (element) => {
    animate(
      element,
      { opacity: [0, 1], y: [30, 0] },
      { ease: [0.39, 0.24, 0.3, 1], duration: 0.6 }
    );
  }, { amount: 0.25 });
</script>
```

### Pattern 4: Hamburger Nav with Vanilla JS

**What:** Toggle mobile menu open/closed with a `<script>` block in the Nav component.
**When to use:** Mobile viewport where the full nav is hidden.

```astro
<!-- In Nav.astro -->
<script>
  const hamburger = document.getElementById('hamburger');
  const mobileMenu = document.getElementById('mobile-menu');

  hamburger?.addEventListener('click', () => {
    const isOpen = mobileMenu?.classList.toggle('hidden');
    hamburger.setAttribute('aria-expanded', String(!isOpen));
  });
</script>
```

When using Astro View Transitions (if added later), hook into `astro:page-load` instead of `DOMContentLoaded`.

### Pattern 5: SEO BaseHead with Canonical URL and OG Tags

**What:** Centralized SEO component with all required meta tags.

```astro
---
// src/components/BaseHead.astro
// Source: https://docs.astro.build/en/basics/layouts/
const canonicalURL = new URL(Astro.url.pathname, Astro.site);
const { title, description, image = '/og-default.png' } = Astro.props;
const ogImage = new URL(image, Astro.url);
---

<meta charset="utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1" />
<link rel="canonical" href={canonicalURL} />
<title>{title} | Rally Trivia</title>
<meta name="description" content={description} />
<meta property="og:type" content="website" />
<meta property="og:url" content={Astro.url} />
<meta property="og:title" content={title} />
<meta property="og:description" content={description} />
<meta property="og:image" content={ogImage} />
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:title" content={title} />
<meta name="twitter:description" content={description} />
<meta name="twitter:image" content={ogImage} />
```

### Pattern 6: Astro config for static + Tailwind v4 + Sitemap

```javascript
// astro.config.mjs
// Source: https://tailwindcss.com/docs/installation/framework-guides/astro
import { defineConfig } from "astro/config";
import sitemap from "@astrojs/sitemap";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  site: "https://rallytrivia.com",  // REQUIRED for sitemap and canonical URLs
  integrations: [sitemap()],
  vite: {
    plugins: [tailwindcss()],
  },
  // No adapter = static output (default Astro 5 behavior)
});
```

### Pattern 7: Wrangler config for static-only Workers deploy

```json
{
  "name": "rally-trivia-web",
  "compatibility_date": "2025-10-08",
  "assets": {
    "directory": "./dist"
  }
}
```

**Critical:** Remove `main`, `binding: "ASSETS"`, `nodejs_compat` from current config. These are SSR artifacts. Static-only workers have no `main` entry point.

### Anti-Patterns to Avoid

- **Using `@astrojs/tailwind` integration:** This is deprecated for Tailwind v4. Use `@tailwindcss/vite` Vite plugin instead.
- **Keeping the `@astrojs/cloudflare` adapter:** Unnecessary for static output; will produce `_worker.js` in the build — conflicts with success criterion #1.
- **`tailwind.config.js` for primary config:** In v4, use `@theme` in CSS. JS config is a compatibility shim, not idiomatic.
- **Importing fonts in `<style>` with `@font-face`:** Use Fontsource npm imports instead — they handle font-face declarations automatically.
- **Writing motion animations outside `<script>` tags:** Astro processes `<script>` blocks through Vite; bare inline scripts cannot import npm modules.
- **Using `output: "static"` explicitly in astro.config:** In Astro 5, static is the default — no explicit setting needed. Setting it explicitly is fine but redundant.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Font self-hosting | Manual `@font-face` in CSS | `@fontsource-variable/*` npm package | Fontsource handles all font-face declarations, subsetting, and preload correctly |
| Sitemap XML | Manual sitemap.xml.js | `@astrojs/sitemap` | Already installed; handles index + child sitemaps, changefreq, priority |
| Scroll detection | IntersectionObserver + requestAnimationFrame | `motion` `inView()` | `inView` wraps Intersection Observer with correct defaults; 0.5kb minified |
| CSS custom properties for theming | Hand-crafted `:root {}` variables | Tailwind v4 `@theme` | `@theme` auto-generates utility classes from tokens; `:root` vars don't |
| OG image URL construction | String concatenation | `new URL(image, Astro.url)` | Handles relative/absolute paths correctly with site base |

**Key insight:** The hardest part of this phase is not building anything new — it's correctly stripping the SSR adapter and its wrangler.json artifacts, then replacing the blog scaffold components with marketing site components. The libraries do the heavy lifting once wired up.

---

## Common Pitfalls

### Pitfall 1: wrangler.json Has SSR Artifacts After Removing Adapter

**What goes wrong:** Build succeeds but `dist/_worker.js` still exists, causing `wrangler deploy` to register a Worker script rather than serving pure static assets. The success criterion explicitly says "no `_worker.js` in the build output."
**Why it happens:** The `@astrojs/cloudflare` adapter generates `_worker.js` in the dist folder. Even after removing the adapter from `astro.config.mjs`, the `wrangler.json` still points to it with `"main": "./dist/_worker.js/index.js"`.
**How to avoid:** Remove `@astrojs/cloudflare` from integrations AND from wrangler.json (`main`, `binding: "ASSETS"`, `compatibility_flags: ["nodejs_compat"]`). Simplify wrangler.json to assets-only form.
**Warning signs:** Build output contains `dist/_worker.js/` directory. `wrangler deploy` output mentions "Worker" rather than "Static assets".

### Pitfall 2: Tailwind v4 `@theme` Not Applying

**What goes wrong:** Custom color utilities like `bg-navy` don't work; Tailwind generates no custom utilities.
**Why it happens:** `global.css` is not imported in the layout, or the `@tailwindcss/vite` plugin is not in `vite.plugins` in `astro.config.mjs`. Also: if the old `@astrojs/tailwind` integration was used, its config is ignored by v4.
**How to avoid:** Ensure (1) `@tailwindcss/vite` is in vite.plugins, (2) `global.css` is imported in BaseLayout.astro, (3) `@import "tailwindcss"` is the first line of global.css before `@theme`.
**Warning signs:** Dev server shows unstyled content; browser DevTools shows no Tailwind-generated CSS.

### Pitfall 3: `site` Not Set in astro.config.mjs

**What goes wrong:** Canonical URLs are broken, sitemap.xml uses wrong base URL, OG image URLs fail.
**Why it happens:** `Astro.site` is undefined when `site` is not configured — canonical URL construction throws.
**How to avoid:** Set `site: "https://rallytrivia.com"` in `astro.config.mjs` before building. (Note from STATE.md: confirm actual production domain before finalizing — `rallytrivia.com` assumed.)
**Warning signs:** `Astro.site` is undefined in component code; sitemap-index.xml shows relative URLs or errors.

### Pitfall 4: Motion `inView` Fires Only Once Per Element (Correct Behavior)

**What goes wrong:** Developer expects animation to re-trigger on scroll back into view; it only fires once.
**Why it happens:** `inView` by default triggers the callback once and disconnects the observer. This is intentional for performance.
**How to avoid:** For "animate in once" (fade on scroll), this is correct behavior — do not fight it. If replay is needed, return a cleanup function from the callback.
**Warning signs:** N/A for Phase 1 — single-fire is correct for the subtle fade-on-scroll requirement.

### Pitfall 5: Hamburger Menu Breaks After Client-Side Navigation

**What goes wrong:** Hamburger menu click handler stops working after navigating between pages.
**Why it happens:** If Astro View Transitions are added later, scripts run once at initial load. The `DOMContentLoaded` approach doesn't re-fire on navigation.
**How to avoid:** Phase 1 has no View Transitions, so `DOMContentLoaded` or direct `addEventListener` on `document.getElementById` is fine. Flag this for Phase 2 if View Transitions are added.
**Warning signs:** Menu works on first page load, fails on subsequent navigation.

### Pitfall 6: Font Not Loading (404 on Font File)

**What goes wrong:** Font doesn't display; network tab shows 404 on font files.
**Why it happens:** Fontsource imports must happen in a JS-executed context (Astro `<script>` tag or layout import). If imported only in `.astro` frontmatter without Vite processing the import, the font files don't get emitted.
**How to avoid:** Import Fontsource in the layout's frontmatter `---` block: `import '@fontsource-variable/plus-jakarta-sans'`. Astro + Vite will correctly copy font files to `dist/`.
**Warning signs:** Font name shows in CSS but falls back to system-ui; network tab shows font 404s.

---

## Code Examples

Verified patterns from official and high-confidence sources:

### Tailwind v4 Brand Color Setup

```css
/* src/styles/global.css */
/* Source: https://tailwindcss.com/docs/theme */
@import "tailwindcss";

@theme {
  /* Core brand blues */
  --color-navy: #0a1628;
  --color-deep-blue: #1a3a6b;
  --color-electric-blue: #2563eb;

  /* Warm accents */
  --color-gold: #f59e0b;
  --color-coral: #f97316;

  /* Typography token */
  --font-sans: 'Plus Jakarta Sans Variable', system-ui, sans-serif;
}

/* Global resets */
body {
  font-family: var(--font-sans);
}
```

### astro.config.mjs (static + Tailwind v4 + sitemap)

```javascript
// Source: https://tailwindcss.com/docs/installation/framework-guides/astro
// Source: https://docs.astro.build/en/guides/deploy/cloudflare/
import { defineConfig } from "astro/config";
import sitemap from "@astrojs/sitemap";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  site: "https://rallytrivia.com",
  integrations: [sitemap()],
  vite: {
    plugins: [tailwindcss()],
  },
});
```

### wrangler.json (static assets only)

```json
{
  "name": "rally-trivia-web",
  "compatibility_date": "2025-10-08",
  "assets": {
    "directory": "./dist"
  }
}
```

### Fontsource import in BaseLayout

```astro
---
// src/layouts/BaseLayout.astro
// Source: https://fontsource.org/fonts/plus-jakarta-sans/install
import '@fontsource-variable/plus-jakarta-sans';
import '../styles/global.css';
import BaseHead from '../components/BaseHead.astro';
import Nav from '../components/Nav.astro';
import Footer from '../components/Footer.astro';
---
```

### Motion scroll-triggered fade-in

```javascript
// Source: https://developers.netlify.com/guides/motion-animation-library-with-astro/
import { animate, inView } from "motion";

inView(".animate-on-scroll", (element) => {
  animate(
    element,
    { opacity: [0, 1], y: [30, 0] },
    { ease: [0.39, 0.24, 0.3, 1], duration: 0.6 }
  );
}, { amount: 0.25 });
```

### Sitemap integration requirement

```javascript
// @astrojs/sitemap outputs:
// /sitemap-index.xml  (index file — success criterion checks this)
// /sitemap-0.xml      (individual sitemap)
// Requires: site must be set in astro.config.mjs
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `@astrojs/tailwind` integration | `@tailwindcss/vite` Vite plugin | Tailwind v4 (early 2025) | @astrojs/tailwind is deprecated for v4; remove it |
| `tailwind.config.js` for tokens | `@theme {}` in CSS | Tailwind v4 | JS config still works as compat, but CSS-first is idiomatic |
| `output: 'hybrid'` in Astro | Removed — all pages static unless opted out | Astro 5 | Hybrid deprecated; default is static |
| Cloudflare Pages | Cloudflare Workers for new projects | 2024-2025 | Pages still works; Workers is recommended for new projects |
| `@astrojs/cloudflare` adapter for SSR | Not needed for static sites | Always | Adapter = SSR; remove it for static-only build |

**Deprecated/outdated in this project's current scaffold:**
- `@astrojs/cloudflare` adapter: Currently in `astro.config.mjs` and `package.json`. Must be removed for static output. Produces `_worker.js` that conflicts with success criterion.
- `@astrojs/mdx`: Blog integration, not needed for marketing site. Can be removed.
- `@astrojs/rss`: Blog RSS feed, not needed. Can be removed.
- Atkinson fonts in `public/fonts/`: Pre-existing blog scaffold fonts. Replace with Fontsource.
- Blog content in `src/content/blog/`: Remove blog content collections.
- `content.config.ts`: Blog content config. Remove.

---

## Open Questions

1. **Production domain confirmation**
   - What we know: STATE.md flags `https://rallytrivia.com` as assumed
   - What's unclear: Whether the domain is actually registered/live before deploy
   - Recommendation: Use `https://rallytrivia.com` in `astro.config.mjs`; if domain isn't live yet, the Workers `.workers.dev` subdomain URL will be used for the deployed preview. Sitemap and canonical URLs will reference the final domain regardless — this is correct behavior.

2. **Exact warm accent color values**
   - What we know: CONTEXT.md says "gold, coral tones" — specific hex not decided
   - What's unclear: Exact hue/saturation of the accent colors
   - Recommendation: Use `#f59e0b` (Tailwind amber-500) for gold and `#f97316` (Tailwind orange-500) for coral as starting point — both are proven against dark navy backgrounds for contrast. Planner should treat these as Claude's discretion values, easy to adjust later.

3. **OG default image**
   - What we know: BaseHead references an OG image; no brand OG image exists yet
   - What's unclear: Whether to create a placeholder or skip
   - Recommendation: Create a minimal placeholder OG image (or reference `favicon.svg` as fallback). Real OG image is Phase 2 content work.

---

## Sources

### Primary (HIGH confidence)
- [Tailwind CSS v4 Theme Variables](https://tailwindcss.com/docs/theme) — `@theme` directive, custom tokens
- [Tailwind CSS v4 Astro Installation](https://tailwindcss.com/docs/installation/framework-guides/astro) — `@tailwindcss/vite` plugin setup
- [Astro Deploy to Cloudflare](https://docs.astro.build/en/guides/deploy/cloudflare/) — static vs SSR deployment, adapter requirement
- [Cloudflare Workers Static Assets](https://developers.cloudflare.com/workers/static-assets/) — assets-only wrangler config
- [Cloudflare Workers Astro Guide](https://developers.cloudflare.com/workers/framework-guides/web-apps/astro/) — no-main wrangler config for static

### Secondary (MEDIUM confidence)
- [Motion with Astro — Netlify Guide](https://developers.netlify.com/guides/motion-animation-library-with-astro/) — verified against motion.dev inView docs; inView + animate patterns
- [Fontsource Plus Jakarta Sans Install](https://fontsource.org/fonts/plus-jakarta-sans/install) — install command and import verified from official Fontsource site
- [Motion npm package](https://motion.dev) — confirmed package name is `motion`; version 12.34.3 as of 2026-02-20

### Tertiary (LOW confidence)
- Community blog posts on Astro + Cloudflare migration — general guidance confirmed against official docs; details may vary

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all packages verified from official sources; versions confirmed from current package.json + npm
- Architecture: HIGH — patterns drawn from official Astro docs and Tailwind v4 docs
- Pitfalls: HIGH (SSR adapter pitfall) / MEDIUM (font/motion pitfalls) — SSR artifact pitfall is directly confirmed by reading current wrangler.json; others are informed by official docs

**Research date:** 2026-02-22
**Valid until:** 2026-03-22 (stable ecosystem; Tailwind v4 and Astro 5 are not moving fast on these APIs)
