# Project Research Summary

**Project:** Rally Trivia Marketing Site
**Domain:** SaaS marketing/landing page — live event trivia platform (nonprofit fundraisers + corporate events)
**Researched:** 2026-02-22
**Confidence:** HIGH (stack + architecture from official docs; features + pitfalls from verified practitioner sources)

## Executive Summary

Rally Trivia's marketing site is a conversion-focused, static marketing site targeting two distinct buyer segments: nonprofit event coordinators running fundraiser trivia nights, and corporate event planners organizing team-building events. The site's sole job is to convert visitors into demo requests. Research confirms this is a well-understood problem domain with clear best practices: static-first Astro on Cloudflare Workers, Tailwind CSS v4 for styling, and outcome-driven copywriting that speaks to each audience segment's specific pain points. The stack is modern but stable — Astro 5.17, Tailwind v4, and Cloudflare Workers static assets are all production-ready with strong official documentation.

The recommended approach is to build in three phases: infrastructure and scaffold first (to get pitfall-prone configuration decisions locked in correctly), followed by the high-conversion landing page and supporting pages, then the contact/demo form as a self-contained deliverable. Every phase decision flows from a core architectural constraint: this is a fully static site — no Cloudflare adapter, no SSR, no Workers compute. All pages are pre-rendered at build time and served from Cloudflare's global edge cache. The form backend (email delivery via Resend) is explicitly deferred; the form ships as a UI-only component in v1.

The main risks are all in Phase 1 (infrastructure setup): using the wrong Astro output mode, misconfiguring Wrangler, using the deprecated Tailwind v3 integration, and missing the `site` property needed for sitemap and canonical URLs. These are well-documented pitfalls with clear prevention steps and low recovery cost if caught early. The single highest-stakes content decision is messaging: competitors (Crowdpurr, SocialPoint) use generic event platform language. Rally Trivia's differentiation comes from being specific — naming the use cases ("fundraiser trivia nights," "corporate game nights") and leading with event organizer pain points rather than feature lists.

## Key Findings

### Recommended Stack

The stack is unified around Astro 5.17 (stable, not v6 beta) with static output deployed to Cloudflare Workers via Wrangler 3.x. No `@astrojs/cloudflare` adapter is needed — pure static delivery via `wrangler.jsonc` with `assets.directory: "./dist"`. Tailwind CSS v4 integrates via the `@tailwindcss/vite` Vite plugin (not the legacy `@astrojs/tailwind` integration). Supporting libraries are minimal: `motion` for scroll animations, `astro-seo` for head meta tags, and `@astrojs/sitemap` for XML sitemap generation. Form email delivery via Resend is deferred to a post-launch phase.

**Core technologies:**
- **Astro 5.17** — Static site framework; ships zero JS by default; built-in image optimization and routing
- **Tailwind CSS v4** — Utility-first CSS via `@tailwindcss/vite`; CSS-first `@theme` config replaces `tailwind.config.js`
- **Cloudflare Workers (static assets)** — Global edge delivery; replaces deprecated Cloudflare Pages; no Worker script needed for static output
- **Wrangler 3.x** — Deploy CLI; `wrangler.jsonc` + `npx wrangler deploy` is the full deployment path
- **TypeScript** — Bundled with Astro; use `.astro` frontmatter typing and `src/env.d.ts`
- **motion (vanilla)** — Scroll/entrance animations without React dependency
- **astro-seo** — Drop-in `<SEO>` component for Open Graph, Twitter Card, and canonical tags
- **Resend** — Transactional email for form delivery (install in a later phase after static form UI ships)

### Expected Features

Research identifies a clear v1 feature set focused on demo conversion. The site needs 11 must-have features for launch, 5 should-have additions after validation, and several features that should be explicitly deferred to avoid scope creep and operational overhead.

**Must have (table stakes):**
- Hero section with outcome-focused headline and "Request a Demo" CTA above the fold
- Demo request form — 5 fields max (name, email, org, role, message) with post-submit confirmation
- Features page with platform capabilities tied to outcomes, not technical specs
- Social proof block — 2-3 testimonials near hero and near demo CTA
- Responsive design — mobile, tablet, desktop (83% of web visits are mobile)
- Shared navigation and footer with consistent branding
- Product/platform visuals — screenshots or interface preview (30% of SaaS sites skip this; conversion killer)
- About/story page — especially important for nonprofit buyers who vet vendor values
- Pain-point-first messaging — leads with event organizer frustrations, not feature bullets
- Dual audience callout — "For Nonprofits" and "For Corporate Events" framing in a homepage section
- "How it works" 3-step visual — lets event organizers visualize the night before booking

**Should have (differentiators, add post-validation):**
- Quantified social proof — real stats from events once data exists ("$12K raised in one night")
- Analytics integration (GA4 or Cloudflare Web Analytics)
- Form backend wiring — connect to Resend for actual email delivery
- Click-to-play video demo embed in features section
- Interactive/animated "how it works" steps (currently static at launch)

**Defer (v2+):**
- Blog / content marketing — requires ongoing content investment; empty blog looks worse than no blog
- Calendly or scheduling embed — explicitly out of scope per PROJECT.md; operational overhead before volume justifies it
- Pricing page — Rally Trivia not ready to publish pricing publicly
- Audience-specific sub-pages for SEO targeting

**Anti-features to avoid:**
- Autoplay video in hero — documented conversion killer; bounce rate increases
- Live chat widget — B2B nonprofit audience finds pop-up chat intrusive; form is sufficient at launch
- Complex multi-step demo form — conversion drops sharply past 5 fields; qualify leads in the actual demo
- Calendly embed — explicitly out of scope; premature scheduling automation

### Architecture Approach

The architecture is deliberately minimal: static Astro pages rendered at build time, served from Cloudflare's edge via `wrangler deploy`. No server-side logic, no Workers compute, no adapter. The build hierarchy is `global styles → shared components (Nav, Footer) → BaseLayout → section components → pages`, and this sequence should drive implementation order. All pages share a single `BaseLayout.astro` that owns the HTML document shell, meta tags, and nav/footer. Pages are composition layers — each page file assembles section components and passes a title/description prop to the layout. Section components are self-contained and reusable (e.g., `CTASection.astro` appears on multiple pages).

**Major components:**
1. `src/layouts/BaseLayout.astro` — Full HTML shell with typed title/description props; renders Nav and Footer; wraps all pages via `<slot />`
2. `src/pages/` (index, features, about, contact) — File-based routes; each is a composition of section components wrapped in BaseLayout
3. `src/components/` — Flat structure: Nav, Footer, Hero, ValueProp, FeatureCard, CTASection, ContactForm — each a self-contained section
4. `src/styles/global.css` — Single file with `@import "tailwindcss"` and `@theme` block for brand color tokens
5. `wrangler.jsonc` — Minimal config pointing `assets.directory` at `./dist`; no `main` field needed

### Critical Pitfalls

Five critical pitfalls must be addressed in Phase 1 (infrastructure setup) before any content is built. All have well-documented prevention steps and low recovery cost if caught during setup, but medium-to-high cost if discovered after significant content has been built on top of a misconfigured foundation.

1. **Wrong output mode (installing Cloudflare adapter + `output: 'server'`)** — Use `output: 'static'` (Astro default) with no adapter; configure only `wrangler.jsonc` assets directory. Warning sign: `_worker.js` appears in build output.
2. **Misconfigured `wrangler.jsonc`** — Static output needs only `name`, `compatibility_date`, and `assets.directory: "./dist"`. No `main` field. Running `wrangler deploy` that succeeds but returns 404s is the symptom.
3. **Missing `site` property in `astro.config.mjs`** — Required for sitemap generation and canonical URLs. Set `site: 'https://rallytrivia.com'` as the first config line before any content pages are built.
4. **Tailwind CSS v4 integration method** — Do NOT use `@astrojs/tailwind` (v3 integration). Use `@tailwindcss/vite` Vite plugin directly. v3 directives (`@tailwind base/components/utilities`) don't exist in v4.
5. **Cloudflare Auto Minify enabled** — Breaks Astro hydration by modifying HTML after Astro renders it. Disable immediately after DNS setup under Speed > Optimization in the Cloudflare dashboard.

**Additional pitfalls for Phase 2 (content pages):**
- Hero image lazy-loaded by default — explicitly set `loading="eager" fetchpriority="high"` on hero image; LCP can go from 1.3s to 4.8s+ from this mistake alone
- Images without width/height — causes Cumulative Layout Shift; always pass explicit dimensions to Astro's `<Image>` component
- Custom fonts from Google CDN — self-host in `public/fonts/` to eliminate external DNS round-trip; set `font-display: swap`

**Phase 3 (contact form):**
- Include a CSS honeypot field in the form HTML from day one, even with no backend — prevents spam flood when email delivery is wired up

## Implications for Roadmap

Based on research, recommended 3-phase structure with a clean dependency chain:

### Phase 1: Infrastructure and Scaffold
**Rationale:** The most dangerous pitfalls are all configuration-level decisions that must be made before any content is built. Getting the Astro output mode, Wrangler config, Tailwind integration, and BaseLayout SEO component wrong creates silent failures that are painful to debug once 4 pages of content are built on top. Locking in correct configuration first means every subsequent phase builds on a solid foundation. Architecture research confirms the build order should start here: global styles → shared components → BaseLayout.
**Delivers:** Working Astro project deployed to Cloudflare Workers; BaseLayout with typed props; Nav and Footer; Tailwind v4 brand tokens configured; sitemap integration active; font loading strategy in place; Cloudflare Auto Minify disabled.
**Addresses:** Site navigation, responsive design foundation, brand-consistent design tokens
**Avoids:** Wrong output mode (Pitfall 1), wrangler misconfiguration (Pitfall 2), missing `site` property (Pitfall 5), Tailwind v4 integration confusion (Pitfall 8), font FOUT/CLS (Pitfall 10), Cloudflare Auto Minify breakage (Pitfall 4)

### Phase 2: Landing Page and Content Pages
**Rationale:** Once the scaffold is verified (Cloudflare deploy working, styles applying, sitemap generating), build the highest-conversion-value content first. The landing page (index) drives the entire business case for the site. Features and About pages support the demo conversion funnel. Architecture research confirms pages should be built in priority order: index → features → about, each as section-component compositions on BaseLayout.
**Delivers:** Full homepage (hero, value props, dual audience callout, how it works, social proof, CTA); Features page; About/story page; 404 page; robots.txt; Open Graph tags on all pages; mobile-responsive layouts.
**Uses:** `Hero.astro`, `ValueProp.astro`, `FeatureCard.astro`, `CTASection.astro`, `motion` for scroll animations, `astro-seo` for head meta, Astro `<Image>` component with proper loading attributes
**Avoids:** LCP image lazy-loading (Pitfall 3), image dimension/CLS issues (Pitfall 6), duplicate meta tags (Pitfall 9), missing 404 config (Pitfall 12)

### Phase 3: Contact / Demo Request Form
**Rationale:** The contact form is the conversion endpoint of the entire site, but it's architecturally self-contained — it does not block Phases 1 or 2. Building it last keeps the form's static-vs-backend decision deferred without holding up the rest of the site. The form ships as a static HTML UI only (no backend action URL); Resend integration is a post-launch addition.
**Delivers:** Demo request form page (`contact.astro`) with ContactForm component; 5-field form (name, email, org, role, message); post-submit success confirmation state; CSS honeypot spam protection; CTA section linking to form from all other pages.
**Avoids:** Over-engineered form (anti-feature), Calendly embed (anti-feature), missing honeypot (Pitfall 7), no confirmation state (UX pitfall)

### Phase Ordering Rationale

- **Infrastructure before content** because the 5 critical pitfalls are all configuration decisions that must be locked in correctly before content is built. Rebuilding on a correct scaffold is cheap; debugging misconfiguration under 4 pages of content is expensive.
- **Landing page before form** because the form depends on the CTA existing on other pages to drive traffic to it, but the form itself doesn't unblock any other page.
- **Form as a discrete deliverable** because it has a clear deferral (backend wiring) that allows the form UI to ship without Resend integration, keeping the v1 scope tight.
- **No separate phase for SEO** because SEO work is distributed: sitemap/site property in Phase 1, meta tags and OG in Phase 2, canonical URLs baked into BaseLayout from the start. Separating it out would create unnecessary sequencing complexity.

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 3 (form backend wiring):** Resend + Cloudflare Workers hybrid mode (`output: 'hybrid'` + `export const prerender = false` on API route) is a distinct configuration from pure static. Needs a targeted research phase before implementation to avoid the Sharp incompatibility issue and confirm CSRF handling with Astro 5 Actions.
- **Phase 2 (motion animations):** Motion v12 vanilla JS API with Astro is well-documented in principle but the specific `inView()` + `animate()` usage for scroll-triggered section reveals may benefit from a quick implementation spike before full page build.

Phases with standard patterns (skip research-phase):
- **Phase 1 (infrastructure):** All configuration decisions are fully documented in official Cloudflare and Astro docs. STACK.md and PITFALLS.md provide exact config snippets. No ambiguity.
- **Phase 2 (Astro pages and components):** Astro file-based routing and component composition are standard, well-documented patterns. ARCHITECTURE.md provides exact file structure and code examples.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Core choices verified against official Cloudflare and Astro docs; Tailwind v4 stable since Jan 2025; Wrangler 3.x documented. Only minor uncertainty on motion v12 Astro integration (MEDIUM for that library). |
| Features | MEDIUM-HIGH | Table stakes and anti-features are well-established SaaS landing page patterns verified across multiple practitioner sources. No A/B test data specific to live trivia event niche — copy framing needs real-world validation after launch. |
| Architecture | HIGH | All patterns sourced from official Astro and Cloudflare documentation. Static-first component composition is a fundamental, stable Astro pattern. Build order implications are clearly documented. |
| Pitfalls | MEDIUM-HIGH | Cloudflare-specific pitfalls (output mode, wrangler config, Auto Minify) are HIGH confidence from official docs. Performance pitfalls (LCP, CLS, fonts) are MEDIUM confidence from verified practitioner sources and Lighthouse documentation. |

**Overall confidence:** HIGH

### Gaps to Address

- **Form backend decision:** PROJECT.md defers form email delivery, but the architecture decision (static form UI only vs. hybrid mode with Workers function) should be made explicit before Phase 3 planning. If Rally Trivia wants Resend wired up at launch rather than post-launch, Phase 3 becomes significantly more complex (requires adapter, `output: 'hybrid'`, Sharp workaround). Recommend confirming this deferral in requirements.
- **Real social proof content:** FEATURES.md flags that quantified stats ("$12K raised in one night") require real event data. If Rally Trivia has hosted events, gather actual numbers before Phase 2 begins. If not, qualitative testimonials are sufficient and honest for launch — but the content gap should be confirmed upfront.
- **Production domain:** `astro.config.mjs` needs the exact production URL for sitemap and canonical tags (`https://rallytrivia.com` assumed from STACK.md). Confirm the canonical domain before Phase 1 scaffold is built.
- **Astro v6 timing:** Astro v6 beta is in progress (requires Node 22+). If v6 goes stable before launch, it adds first-class workerd dev support and improved local/production parity. Monitor; don't block on it.

## Sources

### Primary (HIGH confidence)
- [Cloudflare Workers + Astro (Official)](https://developers.cloudflare.com/workers/framework-guides/web-apps/astro/) — Static site deployment, no adapter required
- [Astro Deploy to Cloudflare (Official Astro Docs)](https://docs.astro.build/en/guides/deploy/cloudflare/) — Workers vs Pages guidance, 404 handling, Auto Minify warning
- [Cloudflare Workers Static Assets](https://developers.cloudflare.com/workers/static-assets/) — `assets.directory` config, wrangler.jsonc structure
- [Astro Project Structure](https://docs.astro.build/en/basics/project-structure/) — Canonical file organization
- [Astro Layouts](https://docs.astro.build/en/basics/layouts/) — BaseLayout slot composition pattern
- [Astro Sitemap Integration](https://docs.astro.build/en/guides/integrations-guide/sitemap/) — `site` property requirement, sitemap generation
- [Astro Images Guide](https://docs.astro.build/en/guides/images/) — loading attributes, CLS prevention, static vs SSR image service
- [Tailwind CSS v4.0 Release Post](https://tailwindcss.com/blog/tailwindcss-v4) — CSS-first config, Vite plugin
- [Cloudflare + Astro + Resend (Official CF Dev Spotlight)](https://developers.cloudflare.com/developer-spotlight/tutorials/handle-form-submission-with-astro-resend/) — Form delivery pattern
- [Cloudflare Workers Best Practices](https://developers.cloudflare.com/workers/best-practices/workers-best-practices/) — nodejs_compat, DNS routing
- [Crowdpurr Live Trivia Platform](https://www.crowdpurr.com/) — Direct competitor, primary source
- [SocialPoint Audience Engagement Platform](https://www.socialpoint.io/) — Adjacent competitor, primary source

### Secondary (MEDIUM confidence)
- [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide) — v3→v4 integration changes
- [motion npm package (v12.34.3)](https://www.npmjs.com/package/motion) — Vanilla JS API, 18M+ monthly downloads
- [astro-seo (npm, v1.1.0)](https://www.npmjs.com/package/astro-seo) — Component API, Astro 5 compatibility
- [InfoQ: Astro v6 Beta + Cloudflare Workers](https://www.infoq.com/news/2026/02/astro-v6-beta-cloudflare/) — v6 beta status, Node 22+ requirement
- [SaaS Landing Pages Best Practices 2026 — Storylane](https://www.storylane.io/blog/saas-landing-pages-best-practices) — Table stakes feature expectations
- [Demo Form Conversion Rate Benchmark — Chili Piper](https://www.chilipiper.com/post/form-conversion-rate-benchmark-report) — 5-field max guidance, directionally reliable
- [Trivia Night Fundraisers Ultimate Guide — Donorbox](https://donorbox.org/nonprofit-blog/trivia-night-fundraisers) — Nonprofit buyer psychology
- [Astro + Tailwind v4 Setup Guide — tailkits.com](https://tailkits.com/blog/astro-tailwind-setup/) — Vite plugin integration walkthrough
- [Migrate Astro from Pages to Workers — cai.im](https://cai.im/blog/migrate-astro-site-from-cloudflare-pages-to-workers/) — Pages deprecation, Workers migration path

### Tertiary (LOW confidence)
- [B2B SaaS Demo Form Best Practices — Metaforms AI](https://metaforms.ai/blog/b2b-saas-demo-form) — Single practitioner source; directional guidance only
- [Secure Astro 5 Contact Forms — farrosfr.com](https://farrosfr.com/blog/secure-astro-5-contact-forms-with-resend-and-upstash/) — Honeypot + spam prevention patterns; validate against official Astro docs during Phase 3

---
*Research completed: 2026-02-22*
*Ready for roadmap: yes*
