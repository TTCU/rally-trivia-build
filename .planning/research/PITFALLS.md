# Pitfalls Research

**Domain:** Astro marketing site on Cloudflare Workers
**Researched:** 2026-02-22
**Confidence:** MEDIUM-HIGH (Cloudflare deployment pitfalls: HIGH from official docs; SEO/performance pitfalls: MEDIUM from multiple verified sources)

---

## Critical Pitfalls

### Pitfall 1: Wrong Output Mode — Deploying SSR When Static Is Correct

**What goes wrong:**
The `@astrojs/cloudflare` adapter defaults to `output: 'server'`, which server-renders every page on-demand as a Cloudflare Worker invocation. A pure marketing site like Rally Trivia has zero dynamic data — every page can (and should) be pre-rendered at build time as static HTML. Defaulting to SSR adds latency, consumes Worker CPU quota, and complicates deployment for zero benefit.

**Why it happens:**
Developers install `@astrojs/cloudflare` and accept defaults, not realizing the adapter default assumes SSR. The Cloudflare adapter documentation focuses heavily on SSR use cases.

**How to avoid:**
For a fully static marketing site, there are two valid paths:
- Option A (simplest): Do NOT install `@astrojs/cloudflare` — use `output: 'static'` (Astro default) and deploy the `dist/` folder directly to Cloudflare Pages as pure static assets.
- Option B (Workers with static assets): Install the adapter, set `output: 'static'` in `astro.config.mjs`, configure `wrangler.jsonc` with `"assets": { "directory": "./dist" }` only — no `main` field needed for static output.

If a contact form will eventually post to a Cloudflare Worker function, use `output: 'hybrid'` and mark static pages with `export const prerender = true`.

**Warning signs:**
- Every page load appearing in Cloudflare Workers analytics (should be zero for static pages)
- Build output includes `_worker.js` when you expected only HTML/CSS/JS files
- Slower TTFB than expected for a "static" site

**Phase to address:** Project setup / Phase 1 (Infrastructure setup)

---

### Pitfall 2: Missing or Misconfigured `wrangler.jsonc` for Static Assets

**What goes wrong:**
Deploying Astro to Cloudflare Workers without the correct `wrangler.jsonc` structure causes deployment failures or assets not being served. The required fields differ significantly between static output (assets-only) and SSR (Worker + assets). Mixing up the config between these modes produces cryptic errors like "Could not resolve XXXX" or 404s on all asset routes.

**Why it happens:**
The Cloudflare Workers and Pages deployment paths are different, and the Workers static assets feature (announced 2025) introduced new configuration patterns. Community tutorials written for Pages don't apply 1:1 to Workers.

**How to avoid:**
For static output on Workers, use this minimal `wrangler.jsonc`:
```jsonc
{
  "name": "rally-trivia-web",
  "compatibility_date": "2025-01-01",
  "assets": {
    "directory": "./dist"
  }
}
```
For SSR/hybrid with Worker function, add:
```jsonc
{
  "main": "dist/_worker.js/index.js",
  "compatibility_flags": ["nodejs_compat"]
}
```
Run `astro add cloudflare` — it scaffolds the correct `wrangler.jsonc` and `public/.assetsignore` automatically.

**Warning signs:**
- `wrangler deploy` succeeds but all routes return 404
- Build output directory mismatch with `assets.directory`
- Missing `.assetsignore` in `public/` folder (causes `_routes.json` to deploy and interfere with routing)

**Phase to address:** Phase 1 (Infrastructure setup)

---

### Pitfall 3: Lazy-Loading the Hero/LCP Image

**What goes wrong:**
Astro's `<Image>` component adds `loading="lazy"` by default. On a marketing site, the hero image is almost always the Largest Contentful Paint (LCP) element. Lazy-loading it tells the browser to defer fetching it — directly hurting the LCP score and causing visitors to perceive the site as slow. Real-world impact: LCP can go from 1.3s (good) to 4.8s+ (poor) from this single mistake.

**Why it happens:**
Developers copy the same `<Image>` usage pattern across all images without distinguishing above-the-fold from below-the-fold content. Lazy loading sounds universally good — it is not.

**How to avoid:**
For the hero image (and any above-the-fold image), explicitly set `loading="eager"` and `fetchpriority="high"`:
```astro
<Image
  src={heroImage}
  alt="Rally Trivia event"
  loading="eager"
  fetchpriority="high"
  width={1200}
  height={600}
/>
```
Use `loading="lazy"` only for images below the fold (features section, testimonials, etc.).

**Warning signs:**
- Lighthouse flags "Largest Contentful Paint image was lazily loaded"
- PageSpeed Insights LCP score is poor despite fast hosting
- Hero image visually appears to "pop in" after the page already looks loaded

**Phase to address:** Phase 2 (Landing page build) — set the pattern correctly from day one

---

### Pitfall 4: Cloudflare Auto Minify Breaking Client-Side Hydration

**What goes wrong:**
Cloudflare's "Auto Minify" feature (HTML/CSS/JS minification via the Cloudflare dashboard) rewrites script and style content in ways that cause Astro's hydration to mismatch the server-rendered HTML. Symptoms: interactive components fail silently, or console shows "Hydration completed but contains mismatches."

**Why it happens:**
Cloudflare modifies the HTML after Astro has rendered it, breaking the checksum Astro uses to match server output with client-side hydration. This is a Cloudflare infrastructure setting that's enabled by default on many accounts.

**How to avoid:**
Disable Cloudflare Auto Minify in the Cloudflare dashboard under Speed > Optimization > Content Optimization. Astro's build already minifies output — double-minification via Cloudflare only causes problems. Do this before any QA testing.

**Warning signs:**
- Interactive Astro islands (client:load, client:visible) fail to initialize
- Browser console shows "Hydration completed but contains mismatches"
- Works in local dev but breaks in production

**Phase to address:** Phase 1 (Infrastructure setup) — disable Auto Minify immediately after DNS/deployment setup

---

### Pitfall 5: Missing `site` Property in `astro.config.mjs` — Breaks Sitemap and Canonical URLs

**What goes wrong:**
The Astro sitemap integration requires the `site` property to be set in `astro.config.mjs`. Without it, `@astrojs/sitemap` either fails silently or generates relative URLs (which are invalid in sitemaps). Canonical tags also require absolute URLs to be meaningful for SEO. A marketing site without a valid sitemap takes much longer to get indexed.

**Why it happens:**
The `site` property is optional for most Astro features, so it's easy to overlook during setup. Developers see the build succeed and assume everything is correct.

**How to avoid:**
Set `site` as the first thing in `astro.config.mjs`:
```js
export default defineConfig({
  site: 'https://rallytrivia.com',  // exact production URL, no trailing slash
  integrations: [sitemap()],
});
```
Also add `robots.txt` in `public/` pointing to the sitemap:
```
User-agent: *
Allow: /
Sitemap: https://rallytrivia.com/sitemap-index.xml
```

**Warning signs:**
- `dist/sitemap-index.xml` is missing after build
- Sitemap contains relative paths (e.g., `/about` instead of `https://rallytrivia.com/about`)
- Google Search Console shows no sitemap submitted or sitemap errors

**Phase to address:** Phase 1 (Infrastructure) — set `site` before any content pages are built

---

## Moderate Pitfalls

### Pitfall 6: Images Without Width/Height Cause CLS (Cumulative Layout Shift)

**What goes wrong:**
Images rendered without explicit `width` and `height` attributes cause the browser to not reserve space before the image loads, resulting in layout shift as the page reflows around the loading image. This tanks the CLS Core Web Vital score.

**How to avoid:**
Always pass `width` and `height` to Astro's `<Image>` component. For local images, Astro infers dimensions automatically — don't override them with CSS-only sizing. For remote images, always specify dimensions. Never use `width: 100%` in CSS as a substitute for proper sizing attributes.

**Warning signs:**
- Lighthouse CLS score above 0.1
- Content visibly shifts as images load
- "Image elements do not have explicit width and height" in Lighthouse

**Phase to address:** Phase 2 (Content pages) — establish pattern in the first component

---

### Pitfall 7: Contact Form Built Without Spam Protection Placeholder

**What goes wrong:**
A contact form with no spam protection, even with a form-UI-only approach (no backend yet), sets up for a spam problem when the backend is wired up. Modern spam bots ignore basic honeypot fields; submitting hundreds of fake leads immediately after going live is a common outcome.

**How to avoid:**
Even in the UI-only phase, include a honeypot field (hidden via CSS, not `display:none` — bots detect that):
```html
<div style="position:absolute;left:-9999px;opacity:0;">
  <label for="website">Leave empty</label>
  <input type="text" id="website" name="website" tabindex="-1" autocomplete="off">
</div>
```
When the backend is wired up, validate server-side that this field is empty before processing. Pair with a JavaScript-generated timestamp token to filter non-browser submissions.

**Warning signs:**
- Form submissions immediately after launch that look like test data or gibberish
- Multiple submissions from same IP within seconds

**Phase to address:** Phase 3 (Contact form) — include honeypot in form HTML from day one

---

### Pitfall 8: Tailwind CSS v4 Integration Confusion (Wrong Integration Method)

**What goes wrong:**
Tailwind CSS v4 (released early 2025) completely changed how it integrates with Astro. The old `@astrojs/tailwind` integration is deprecated for v4. Using the old integration with Tailwind v4 causes styles to not apply, or causes partial/broken styling that's hard to debug. The v3 `@tailwind` directives don't exist in v4.

**How to avoid:**
Use the Vite plugin approach for Tailwind v4 (not the Astro integration):
```js
// astro.config.mjs
import tailwindcss from '@tailwindcss/vite';
export default defineConfig({
  vite: { plugins: [tailwindcss()] },
});
```
Import Tailwind in a global CSS file:
```css
@import "tailwindcss";
```
Do NOT run `astro add tailwind` — it installs the v3-compatible integration. Install `tailwindcss` and `@tailwindcss/vite` manually. Alternatively, if using Tailwind v3 intentionally, use `@astrojs/tailwind` — just don't mix versions.

**Warning signs:**
- Tailwind classes present in HTML but styles not applied in browser
- Build succeeds but no Tailwind output in the CSS bundle
- `Unknown at rule @tailwind` errors in browser console

**Phase to address:** Phase 1 (Project setup) — get this right before writing any component styles

---

### Pitfall 9: Duplicate Meta Descriptions and Title Tags Across Pages

**What goes wrong:**
Using a shared `<head>` layout component that hardcodes the site name as the `<title>` and description — or copying the same tags to every page — produces duplicate metadata. Google devalues duplicate titles, and users see "Rally Trivia | Rally Trivia" in browser tabs.

**How to avoid:**
Create a reusable `<SEO>` or `<Head>` component that accepts `title` and `description` as props with page-specific defaults:
```astro
---
interface Props {
  title: string;
  description: string;
}
const { title, description } = Astro.props;
---
<title>{title} | Rally Trivia</title>
<meta name="description" content={description} />
<meta property="og:title" content={`${title} | Rally Trivia`} />
```
Every page should pass unique, page-specific values. Aim for titles 50-60 characters and descriptions 120-160 characters.

**Warning signs:**
- All pages have identical `<title>` tags in view-source
- Google Search Console shows "Duplicate title tags" or "Duplicate meta descriptions"

**Phase to address:** Phase 1 (Base layout component) — design the `<head>` component correctly before any page content

---

### Pitfall 10: Custom Fonts Causing FOUT and CLS

**What goes wrong:**
Loading custom fonts (Google Fonts or local fonts) without `font-display: swap` and preload hints causes either invisible text during load (FOIT) or layout-shifting text swap (FOUT). On a professional marketing site with brand typography, this looks broken and unprofessional.

**How to avoid:**
Self-host fonts in `public/fonts/` rather than using Google Fonts CDN (eliminates the external DNS lookup, gives full control over caching). Always set `font-display: swap` in the `@font-face` declaration. Preload the most-used font weight in `<head>`:
```html
<link rel="preload" href="/fonts/brand-font-regular.woff2" as="font" type="font/woff2" crossorigin>
```
If using Google Fonts, use the `display=swap` parameter in the URL.

**Warning signs:**
- Text visibly "snaps" to brand font after initial render
- Lighthouse flags "Ensure text remains visible during webfont load"
- Significant CLS score attributed to font loading in WebPageTest

**Phase to address:** Phase 1 (Base layout) — set up fonts correctly before any typography is applied

---

## Minor Pitfalls

### Pitfall 11: `nodejs_compat` Flag Not Set When Using Node Built-ins

**What goes wrong:**
Any library (or custom code) that imports from Node.js built-in modules (`node:crypto`, `node:stream`, etc.) will fail to build or fail at runtime if `nodejs_compat` is not in `compatibility_flags` in `wrangler.jsonc`. Vitest tests pass locally because Vitest automatically injects this flag — masking the production mismatch.

**How to avoid:**
Always include `"nodejs_compat"` in `compatibility_flags` if any SSR or Worker code is present. For pure static output this is irrelevant, but include it preemptively if hybrid mode is used.

**Phase to address:** Phase 1 (Wrangler config setup)

---

### Pitfall 12: Missing Custom 404 Page Configuration

**What goes wrong:**
Cloudflare Workers does not automatically serve custom `404.html` pages from a static assets folder. Without setting `not_found_handling` in `wrangler.jsonc`, invalid URLs show Cloudflare's default error page instead of the branded 404 page Astro generates.

**How to avoid:**
Add to `wrangler.jsonc`:
```jsonc
{
  "assets": {
    "directory": "./dist",
    "not_found_handling": "single-page-application"
  }
}
```
Or create an explicit `404.astro` page and configure `not_found_handling: "404-page"` to serve `404.html` for unmatched routes.

**Phase to address:** Phase 2 (Page structure)

---

### Pitfall 13: Deploying Without Reviewing robots.txt

**What goes wrong:**
Astro generates no `robots.txt` by default. Without one, search engine crawlers still index everything — which is fine — but there's no way to control indexing of staging environments, and you miss the sitemap directive that helps with faster indexing.

**How to avoid:**
Create `public/robots.txt` manually:
```
User-agent: *
Allow: /
Sitemap: https://rallytrivia.com/sitemap-index.xml
```
For staging/preview deployments, add a `robots.txt` that disallows crawling — or add `noindex` headers at the Cloudflare level for non-production environments.

**Phase to address:** Phase 1 (Infrastructure) or Phase 2 (Launch prep)

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Inline all styles in components | Faster initial build | Hard to maintain brand consistency, no design tokens | Never — use Tailwind utilities or shared CSS variables |
| Skip `<Image>` component, use raw `<img>` | Simpler syntax | No WebP conversion, no srcset, CLS from missing dimensions | Never for hero/feature images |
| Hardcode copy in components | Quick initial build | Painful to update, no content management path | Acceptable for MVP, address before scaling copy changes |
| No sitemap/robots.txt at launch | Saves 30 minutes | Slower indexing, no crawl control | Never — these take 10 minutes to add |
| Use Cloudflare Pages instead of Workers | Simpler initial deploy | Pages is deprecated (April 2025), migration required later | Only if timeline is extremely tight; Workers is trivially different |
| Skip environment-specific wrangler configs | Simpler setup | Staging deployments index in Google, mixed preview/prod data | Never — add `wrangler.staging.jsonc` from day one |

---

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| `@astrojs/cloudflare` adapter | Installing it for a fully static site | Skip adapter entirely for `output: 'static'`; use it only for SSR/hybrid |
| `@astrojs/sitemap` | Forgetting `site` property in `astro.config.mjs` | Always set `site: 'https://rallytrivia.com'` before adding sitemap |
| Tailwind CSS v4 | Using deprecated `@astrojs/tailwind` integration | Use `@tailwindcss/vite` Vite plugin directly |
| Cloudflare DNS | Adding custom domain without proxied DNS record | Worker routes require proxied (orange cloud) DNS records or they return `ERR_NAME_NOT_RESOLVED` |
| Cloudflare Auto Minify | Leaving it enabled (dashboard default) | Disable under Speed > Optimization before any testing |
| Google Fonts | Loading from Google CDN at runtime | Self-host in `public/fonts/` for privacy, caching control, and no external DNS round-trip |

---

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| LCP image lazy-loaded | Poor LCP score, hero "pops in" | `loading="eager" fetchpriority="high"` on hero image | Immediately — affects first visitor impression |
| Images without dimensions | High CLS score, layout jumps | Always pass `width`/`height` to `<Image>` | Any image load on slower connections |
| External font CDN (Google Fonts) | FOUT, extra DNS lookup, CLS | Self-host fonts in `public/fonts/` | Visible on slow connections and first-visit |
| Importing JS libraries with heavy side effects into Astro components | Client bundle bloat, slower TTI | Use `client:visible` not `client:load`; avoid libraries with global side effects | At any scale — it's always suboptimal |
| SSR mode for all-static content | Worker CPU quota consumed, latency | Use `output: 'static'` for marketing sites | From day one — unnecessary operational cost |

---

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| No honeypot on contact form | Immediate spam flood when backend wired up | Add honeypot hidden field in form HTML now, validate server-side later |
| Committing Cloudflare API token or Wrangler auth to repo | Account takeover | Use `wrangler secret put` or CI environment variables; never commit `.env` with credentials |
| No CSRF protection on form endpoint | Cross-site form abuse when backend added | Astro 5 Actions handle CSRF automatically; if using custom endpoint, validate `Origin` header matches `site` config |
| Staging site indexed by Google | Confuses SEO, duplicate content | Add `noindex` meta or Cloudflare Access restriction on preview deployments |

---

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Single CTA ("Request Demo") buried below the fold | Visitors leave without converting | CTA visible in hero AND navigation; repeat CTA at bottom of features page |
| Demo form with too many required fields | Friction reduces conversion | Name, email, org (optional), message — 3-4 fields max |
| Mobile nav without proper focus management | Inaccessible on screen readers and keyboard | Use `dialog` element or proper `aria-expanded` toggle for mobile nav |
| No visual confirmation after form submit | User re-submits, gets confused | Show inline success message; disable submit button during submission |
| Navy-on-dark-blue text for body copy | Low contrast ratio, fails WCAG AA | Use high-contrast text colors (white or near-white) on dark backgrounds; test with contrast checker |

---

## "Looks Done But Isn't" Checklist

- [ ] **Sitemap:** Verify `dist/sitemap-index.xml` exists after `npm run build` — if missing, `site` property is not set
- [ ] **Meta tags:** View-source each page to confirm unique `<title>` and `<meta name="description">` values
- [ ] **Mobile nav:** Test hamburger menu on actual 375px iPhone — Tailwind responsive breakpoints sometimes behave differently on real devices
- [ ] **Form honeypot:** Confirm hidden field is present in rendered HTML (`view-source`) but invisible and non-interactive in browser
- [ ] **Robots.txt:** Confirm `public/robots.txt` exists and references sitemap URL
- [ ] **Auto Minify:** Confirm Cloudflare Auto Minify is disabled in dashboard before declaring production "working"
- [ ] **Image dimensions:** Run Lighthouse — confirm CLS is under 0.1 and no LCP lazy-load warning
- [ ] **404 page:** Test a nonexistent URL (e.g., `/not-a-page`) — confirm branded 404 appears, not Cloudflare default
- [ ] **Canonical tags:** Confirm `<link rel="canonical">` points to correct production URL on every page
- [ ] **Open Graph tags:** Share a URL in Slack or iMessage to test OG preview image and title render correctly

---

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Wrong output mode (SSR vs static) | LOW | Change `output` in `astro.config.mjs`, adjust `wrangler.jsonc`, redeploy |
| Tailwind v3/v4 integration mismatch | MEDIUM | Uninstall old integration, install Vite plugin, update CSS imports, test all components |
| LCP image lazy-loading | LOW | Add `loading="eager" fetchpriority="high"` to hero image, rebuild, redeploy |
| Cloudflare Auto Minify breakage | LOW | Toggle off in dashboard — instant effect without redeploy |
| Missing sitemap | LOW | Add `site` property, add `@astrojs/sitemap` integration, rebuild |
| Spam flood on form launch | MEDIUM | Add honeypot + rate limiting at Cloudflare WAF level, deploy backend filter |
| Pages deprecated infrastructure | MEDIUM | Migrate to Workers static assets (different wrangler config, same content) |

---

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Wrong output mode (SSR vs static) | Phase 1: Infrastructure setup | `npm run build` output contains only HTML/CSS/JS files, no `_worker.js` |
| Wrangler misconfiguration | Phase 1: Infrastructure setup | `wrangler deploy` succeeds, all pages return 200, assets load |
| Cloudflare Auto Minify | Phase 1: Infrastructure setup | Check Cloudflare dashboard setting before first QA |
| Missing `site` property / sitemap | Phase 1: Infrastructure setup | `dist/sitemap-index.xml` present after build |
| Tailwind v4 integration method | Phase 1: Project scaffold | All Tailwind utilities apply correctly in `npm run dev` |
| Base layout SEO component | Phase 1: Base layout component | View-source confirms unique titles/descriptions per page |
| Font loading (FOUT/CLS) | Phase 1: Base layout component | WebPageTest shows no font-related CLS |
| LCP image lazy-loading | Phase 2: Landing page build | Lighthouse LCP under 2.5s, no lazy-load warning |
| Image dimensions / CLS | Phase 2: Content pages | Lighthouse CLS under 0.1 |
| Contact form honeypot | Phase 3: Contact form | Honeypot field visible in view-source, hidden visually |
| 404 page config | Phase 2: Page structure | `/not-a-page` shows branded 404, not Cloudflare default |
| Mobile responsiveness | Phase 2: All pages | Manual test on 375px/768px viewports + Lighthouse mobile score |

---

## Sources

- [Astro Cloudflare Adapter Docs](https://docs.astro.build/en/guides/integrations-guide/cloudflare/) — Configuration pitfalls, platformProxy, image service (HIGH confidence)
- [Deploy Astro to Cloudflare — Official Docs](https://docs.astro.build/en/guides/deploy/cloudflare/) — 404 handling, Auto Minify warning, wrangler config (HIGH confidence)
- [Cloudflare Workers Best Practices](https://developers.cloudflare.com/workers/best-practices/workers-best-practices/) — nodejs_compat, DNS routing, global state (HIGH confidence)
- [Cloudflare Workers Framework Guide: Astro](https://developers.cloudflare.com/workers/framework-guides/web-apps/astro/) — Static vs SSR deployment paths (HIGH confidence)
- [Astro Sitemap Integration](https://docs.astro.build/en/guides/integrations-guide/sitemap/) — `site` property requirement (HIGH confidence)
- [Astro Images Guide](https://docs.astro.build/en/guides/images/) — loading, dimensions, CLS (HIGH confidence)
- [Tailwind CSS v4 Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide) — Integration method changes (HIGH confidence)
- [Astro + Tailwind v4 Setup Guide](https://tailkits.com/blog/astro-tailwind-setup/) — Vite plugin approach (MEDIUM confidence)
- [How to Index Astro Site 2025](https://indexplease.com/blog/how-to-index-astro-site/) — sitemap, robots.txt, canonical (MEDIUM confidence)
- [Astro Image Optimization — LCP Guide](https://www.corewebvitals.io/pagespeed/fix-largest-contentful-paint-image-was-lazily-loaded) — LCP lazy-loading impact (MEDIUM confidence)
- [Migrate Astro from Pages to Workers](https://cai.im/blog/migrate-astro-site-from-cloudflare-pages-to-workers/) — Pages deprecation, Workers migration (MEDIUM confidence)
- [Secure Astro 5 Contact Forms](https://farrosfr.com/blog/secure-astro-5-contact-forms-with-resend-and-upstash/) — Honeypot + token spam prevention (MEDIUM confidence)
- [Astro Google Fonts Optimizer](https://github.com/sebholstein/astro-google-fonts-optimizer) — Font loading best practices (MEDIUM confidence)

---

*Pitfalls research for: Astro marketing site on Cloudflare Workers (Rally Trivia)*
*Researched: 2026-02-22*
