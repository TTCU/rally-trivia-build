# Stack Research

**Domain:** Marketing/landing page site (Astro + Cloudflare Workers)
**Researched:** 2026-02-22
**Confidence:** HIGH — most choices verified against official Cloudflare and Astro docs, npm registry, and official changelogs

---

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| Astro | 5.17.x (stable) | Static site framework | Industry standard for content-first, high-performance marketing sites. Ships zero JS by default, has built-in image optimization, routing, layouts, and View Transitions. v6 is in beta (requires Node 22+) — use 5.17 stable for now. |
| TypeScript | 5.x (bundled with Astro) | Type safety | Astro ships with full TS support out of the box. No separate install needed. Use `.astro` files with typed frontmatter and `src/env.d.ts` for globals. |
| Tailwind CSS | 4.x (v4.0, Jan 2025) | Utility-first CSS | v4 is now stable. Zero-config via `@tailwindcss/vite` plugin — no `tailwind.config.js` needed. CSS-first `@theme` block replaces JS config. Astro 5.2+ has native support via `npx astro add tailwind`. |
| Cloudflare Workers | (platform) | Hosting + edge delivery | Cloudflare's official recommendation for new projects in 2025+. Replaces Pages. Static assets served from the edge globally. No cold starts for static files. |
| Wrangler | 3.x (latest) | Deploy CLI | Official Cloudflare deployment tool. For purely static Astro sites, just `wrangler.jsonc` + `npx wrangler deploy` — no Node Worker code needed. |

### Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| motion | 12.34.x | Scroll/entrance animations | For hero animations, section reveal on scroll (replaces AOS). Vanilla JS API works in Astro without React. Use `animate()` for one-shot and `inView()` for scroll-triggered effects. Lighter than Framer Motion React variant. |
| astro-seo | 1.1.x | SEO meta tags | Drop-in `<SEO>` component for `<title>`, `<meta description>`, Open Graph, Twitter Card tags. Inspired by Next-SEO API. Use in every page's `<head>`. |
| @astrojs/sitemap | (official Astro package) | XML sitemap generation | Official integration. Auto-discovers all pre-rendered routes at build time. Required: set `site` in `astro.config.mjs`. Outputs `sitemap-index.xml` + `sitemap-0.xml`. |
| astro-seo-schema | latest | JSON-LD structured data | Companion to astro-seo. Add `Organization`, `WebSite`, or `Event` schema blocks for search engine rich snippets. Use on homepage and contact page. |
| resend | latest | Transactional email (form delivery) | Official Cloudflare Developer Spotlight recommendation for Astro + Cloudflare form submissions. Simple API, generous free tier (100 emails/day), works in Workers runtime. Wire up AFTER the static form UI is built. |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| Wrangler CLI | Local dev + deployment | Run `npx wrangler dev` to simulate edge environment locally. Use `wrangler.jsonc` (JSONC format, supports comments). |
| `npx astro add` | Integration installer | `npx astro add tailwind`, `npx astro add sitemap` — auto-configures `astro.config.mjs`. Preferred over manual install. |
| Prettier + `prettier-plugin-astro` | Code formatting | Official Prettier plugin for `.astro` files. Handles mixed HTML/JS/CSS in frontmatter correctly. |

---

## Installation

```bash
# Bootstrap new Astro project
npm create astro@latest rally-trivia-web -- --template minimal --typescript strict

# Add Tailwind CSS v4 (Astro 5.2+ native support)
npx astro add tailwind

# Add sitemap integration
npx astro add sitemap

# Supporting libraries
npm install motion astro-seo astro-seo-schema

# Dev tooling
npm install -D prettier prettier-plugin-astro

# For form email delivery (add in a later phase)
npm install resend
```

**wrangler.jsonc** (static site — no adapter needed):
```jsonc
{
  "name": "rally-trivia-web",
  "compatibility_date": "2026-02-22",
  "assets": {
    "directory": "./dist"
  }
}
```

**astro.config.mjs** (static output, no SSR adapter):
```javascript
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://rallytrivia.com', // Required for sitemap
  output: 'static',               // Purely static, no Worker code
  integrations: [sitemap()],
  vite: {
    plugins: [tailwindcss()],
  },
});
```

**src/styles/global.css** (Tailwind v4):
```css
@import "tailwindcss";

@theme {
  --color-navy: #0a1628;
  --color-deep-blue: #1a3a6b;
  --color-electric-blue: #2563eb;
  /* Rally Trivia brand tokens here */
}
```

---

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| Astro 5.17 (stable) | Astro 6.0-beta | Switch to v6 once stable (expected early 2026). v6 adds first-class Workers dev with workerd runtime — significant DX upgrade. |
| Cloudflare Workers (static assets) | Cloudflare Pages | Only if you have an existing Pages project. New projects should use Workers per Cloudflare's own recommendation. |
| `@tailwindcss/vite` plugin | `@tailwindcss/postcss` + PostCSS | PostCSS approach works but adds config complexity. Vite plugin is the new recommended path for Astro 5.2+. |
| motion (vanilla) | AOS (Animate on Scroll) | AOS is a simpler scroll-trigger library. Use if motion's API feels heavy for simple fade-ins. However, motion's `inView()` is comparably simple and more actively maintained. |
| motion (vanilla) | Framer Motion (React) | Framer Motion requires React. This is a pure Astro project with no React islands — avoid the React dependency. |
| astro-seo | Hand-rolled `<head>` meta tags | Hand-rolling works but astro-seo handles edge cases (OG escaping, title truncation, canonical URLs) that are easy to miss. |
| Resend | Formspree / Netlify Forms | Formspree/Netlify Forms are third-party services. Resend is a direct API, works in Workers runtime, and Cloudflare officially documents it. Use Resend when wiring up form backend. |
| Resend | SendGrid / Mailgun | Heavier SDKs with more legacy API surface. Resend's SDK is lighter and designed for modern edge runtimes. |

---

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| `@astrojs/cloudflare` adapter | Not needed for purely static sites. Only required if using SSR/on-demand rendering (form API routes, etc.). Adds unnecessary complexity and Sharp incompatibility on Cloudflare runtime. | Static output + `wrangler.jsonc` with `assets.directory`. |
| Sharp image service on Cloudflare | Cloudflare Workers runtime does not support Sharp's native binaries. Using Sharp with the Cloudflare adapter causes build/runtime errors. | Use `passthroughImageService()` from `astro/config` for static Cloudflare deploys, or Cloudflare's Image Resizing service if you need runtime transforms. |
| Tailwind CSS v3 | v3 is now legacy. The `tailwind.config.js` approach, `@tailwind base/components/utilities` directives, and PostCSS-first setup are all superseded. v4 is faster, simpler, and officially supported. | Tailwind CSS v4 with `@tailwindcss/vite` plugin. |
| `@astrojs/image` (deprecated) | This was the old image integration — it no longer exists. Astro's built-in `<Image>` and `<Picture>` components are the current solution. | Astro's built-in `<Image>` component from `astro:assets`. |
| Calendly embed | Project explicitly out-of-scope. Adds third-party JS, layout shift, and CLS issues. Deferred decision. | Simple HTML form with future Resend backend. |
| React/Vue islands for animations | Adds framework JS overhead for a static marketing site. Motion's vanilla JS API covers all animation needs without framework overhead. | motion (vanilla) with `animate()` and `inView()`. |
| Google Fonts `<link>` in `<head>` | Adds render-blocking external request. Hurts Lighthouse/CWV scores. | Self-host fonts via Fontsource (`npm install @fontsource/[font-name]`) or use `font-display: swap` with preconnect. |

---

## Stack Patterns by Variant

**If the form needs to actually send email now (not deferred):**
- Add `@astrojs/cloudflare` adapter to enable SSR API routes
- Set `output: 'hybrid'` (pre-render all pages, enable SSR only for `/api/contact`)
- Add `export const prerender = false` to the API route file
- Wire Resend SDK in the API route
- Note: This adds the Sharp incompatibility issue — use `passthroughImageService()` in astro.config

**If Astro v6 releases stable before project launch:**
- Upgrade to v6 — it requires Node 22+ and has a migration guide
- v6 dev server runs in workerd (Cloudflare's actual runtime) so local dev matches production exactly
- First-class Cloudflare Workers bindings become available during development

**If scroll animations feel too heavy:**
- Replace motion with native CSS `@keyframes` + `IntersectionObserver` in a plain `<script>` tag in the Astro component
- Astro compiles per-component scripts efficiently — no framework overhead

---

## Version Compatibility

| Package | Compatible With | Notes |
|---------|-----------------|-------|
| Astro 5.17.x | Tailwind CSS v4 (via `@tailwindcss/vite`) | Requires Astro 5.2+ for native Tailwind v4 support |
| Astro 5.17.x | Node.js 18.17.1+ | Node 20+ recommended per PROJECT.md constraint |
| Astro 5.17.x | Wrangler 3.x | Static asset deployment without adapter |
| motion 12.x | Astro (any) | Vanilla JS — no framework dependency |
| `@tailwindcss/vite` | Vite 5+ (bundled with Astro 5) | Do NOT use `postcss` approach alongside vite plugin |
| `astro-seo` 1.1.x | Astro 5.x | Confirmed maintained and Astro 5 compatible |

---

## Image Optimization Strategy

For a static site on Cloudflare Workers:

1. **Pre-build optimization (build time)**: Use Astro's `<Image>` component for local images. With `output: 'static'`, Astro runs Sharp at build time on the build machine (not the Cloudflare runtime), so Sharp compatibility is not an issue for static output.
2. **Format**: Astro auto-converts to WebP/AVIF at build time.
3. **Responsive sizes**: Use `widths` and `sizes` props on `<Image>` for responsive srcset.
4. **Brand assets (SVG)**: Serve SVG logos directly from `public/` — no processing needed.
5. **Do NOT use** `imageService: 'cloudflare'` unless you are on an SSR (server-rendered) route and need runtime image resizing.

---

## Sources

- [Cloudflare Workers + Astro (Official)](https://developers.cloudflare.com/workers/framework-guides/web-apps/astro/) — Confirmed static site = no adapter, just wrangler.jsonc + assets directory. HIGH confidence.
- [Astro Deploy to Cloudflare (Official Astro Docs)](https://docs.astro.build/en/guides/deploy/cloudflare/) — Workers now recommended over Pages for new projects. HIGH confidence.
- [Astro Cloudflare Adapter Docs](https://docs.astro.build/en/guides/integrations-guide/cloudflare/) — v12.6.12 current, adapter only needed for SSR. HIGH confidence.
- [Tailwind CSS v4.0 Release Post](https://tailwindcss.com/blog/tailwindcss-v4) — v4.0 released Jan 22 2025. CSS-first config, Vite plugin preferred. HIGH confidence.
- [Astro + Tailwind v4 Setup Guide](https://tailkits.com/blog/astro-tailwind-setup/) — Confirmed Astro 5.2+ native support via `@tailwindcss/vite`. MEDIUM confidence.
- [motion npm package](https://www.npmjs.com/package/motion) — v12.34.3, vanilla JS API supported, 18M+ monthly downloads. HIGH confidence.
- [Motion with Astro (Netlify Guide)](https://developers.netlify.com/guides/motion-animation-library-with-astro/) — Official integration guide for Motion + Astro. MEDIUM confidence.
- [astro-seo npm](https://www.npmjs.com/package/astro-seo) — v1.1.0, maintained, 4,735 weekly downloads. MEDIUM confidence.
- [astro-seo GitHub](https://github.com/jonasmerlin/astro-seo) — Active, TypeScript, Open Graph + Twitter Card support. MEDIUM confidence.
- [Cloudflare + Astro + Resend tutorial (Official Cloudflare)](https://developers.cloudflare.com/developer-spotlight/tutorials/handle-form-submission-with-astro-resend/) — Official CF docs endorsing Resend for form handling. HIGH confidence.
- [Astro Images Guide (Official)](https://docs.astro.build/en/guides/images/) — `passthroughImageService()` for Cloudflare SSR, Sharp runs fine at build time for static. HIGH confidence.
- [InfoQ: Astro v6 Beta + Cloudflare Workers](https://www.infoq.com/news/2026/02/astro-v6-beta-cloudflare/) — v6 beta requires Node 22+, first-class workerd dev support. MEDIUM confidence (beta, not stable).
- [Astro What's New January 2026](https://astro.build/blog/whats-new-january-2026/) — Astro 5.17 is current stable. MEDIUM confidence.

---

*Stack research for: Rally Trivia marketing/landing page site (Astro + Cloudflare Workers)*
*Researched: 2026-02-22*
