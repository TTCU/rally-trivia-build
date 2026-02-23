# Phase 6: Analytics - Research

**Researched:** 2026-02-22
**Domain:** Cloudflare Web Analytics — beacon integration, custom event tracking, Astro component patterns
**Confidence:** HIGH (beacon integration) / MEDIUM (custom events — critical limitation found)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Beacon placement**
- Token hardcoded directly in the HTML (CF Web Analytics tokens are public by nature)
- Beacon loads on all environments including localhost — no dev/prod conditional
- CF Web Analytics site needs to be created in the CF dashboard as part of this phase

**Privacy & consent**
- No cookie/consent banner needed — CF Web Analytics is cookieless and collects no PII
- No privacy policy page or footer disclosure in this phase
- No GDPR/CCPA compliance work — CF's privacy-first approach satisfies requirements

**Custom events**
- Detailed funnel tracking — go beyond pageviews to capture the full user journey
- Track all navigation CTAs: "Book a Demo", "Learn More", and any links driving users toward contact
- Send custom events to Cloudflare dashboard so they're visible alongside pageviews as named events

**Dashboard & verification**
- Automated test that confirms beacon script tag is present in rendered HTML of every page
- Default CF Web Analytics dashboard metrics are sufficient (pageviews, top pages, referrers, countries)
- Custom events should surface in CF dashboard as named events

### Claude's Discretion

- **Beacon architecture**: Whether to inject in base layout directly or create a dedicated `<Analytics />` component — Claude picks the cleanest approach for the existing Astro codebase
- **Scroll depth tracking granularity**: Section-based vs percentage-based — pick what's most useful for a marketing site
- **Form field interaction tracking depth**: Submit-only vs full form funnel — pick what's practical with CF Web Analytics capabilities
- **Test scope**: Whether to also verify custom event hooks are wired up, or keep tests focused on beacon presence

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| ANLX-01 | All pages include Cloudflare Web Analytics beacon script | Beacon is a `<script defer>` tag with `data-cf-beacon` attribute; inject via dedicated `<Analytics />` component in `BaseLayout.astro` so all 4 pages receive it automatically |
| ANLX-02 | Pageviews and referrer data are visible in Cloudflare dashboard | Beacon reports pageviews and referrer data automatically once the token is issued from the CF dashboard; no additional code required beyond beacon placement |
</phase_requirements>

---

## Summary

Cloudflare Web Analytics is a privacy-first, cookieless analytics product that requires a single `<script>` tag with a `data-cf-beacon` attribute containing a JSON config object with a `token` field. Once deployed, pageviews and referrer data flow to the CF dashboard automatically — no additional code is needed for ANLX-01 and ANLX-02. The beacon is safe to hardcode because CF Web Analytics tokens are public by nature (they only identify which CF account to report to, not authenticate anything sensitive).

**CRITICAL LIMITATION — Custom Events:** The official Cloudflare Web Analytics FAQ explicitly states that custom event tracking is **not currently supported** in CF Web Analytics. The dashboard shows only pageviews, top pages, referrers, and country data. The user's requirement to "send custom events to Cloudflare dashboard so they're visible alongside pageviews as named events" cannot be fulfilled with CF Web Analytics alone. The CF product that supports custom event tracking is **Zaraz** (`zaraz.track()`), which is a separate product requiring its own dashboard setup. This gap must be surfaced to the user before planning proceeds.

The cleanest Astro approach for beacon injection is a dedicated `<Analytics />` component inserted in `BaseLayout.astro`. Since all 4 pages (`index`, `about`, `features`, `contact`) already use `BaseLayout`, a single component insertion covers the entire site. Test verification follows the project's existing bash-script pattern: build the site, grep `dist/` HTML files for the beacon token.

**Primary recommendation:** Add a `<Analytics />` Astro component to `BaseLayout.astro`; surface the custom events limitation to the user before scoping event tracking work.

---

## CRITICAL: Custom Events Limitation

**What the user asked for:** Custom events visible in the CF Web Analytics dashboard as named events (CTA clicks, form submissions, scroll depth).

**What CF Web Analytics supports:** Pageviews, referrers, top pages, country data. **No custom event tracking.**

Source: Official CF Web Analytics FAQ — "Custom events: Not currently supported, though the documentation notes 'we may add support for this in the future.'"
Source URL: https://developers.cloudflare.com/web-analytics/faq/

**What CF does offer for custom events:** Cloudflare Zaraz (`zaraz.track()`), a separate product that requires enabling Zaraz in the CF dashboard and configuring event destinations. Zaraz events do appear in a separate Zaraz dashboard, not in Web Analytics.

**Impact on planning:** The planner must choose one of these paths:
1. **Scope custom events out** — implement beacon only (satisfies ANLX-01 and ANLX-02 fully); note limitation in docs
2. **Implement Zaraz** — requires Zaraz product setup, out of originally stated scope but satisfies user's custom event intent
3. **Client-side event wiring only** — wire `data-event` attributes and JS click handlers in code, but accept that events cannot surface in CF dashboard; add a comment noting what would need to change if a custom event destination is added later

Recommendation: Implement beacon for pageviews (satisfies both requirements), add client-side event wiring with `onclick` handlers for future readiness, and document that CF Web Analytics does not support custom event surfacing in the dashboard. This keeps the phase deliverable and honest.

---

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Cloudflare Web Analytics beacon | N/A (CDN script) | Pageview + performance tracking | First-party CF product, no npm package needed, single `<script>` tag |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| No npm packages required | — | Beacon is a CDN-loaded script | This entire phase is HTML/JS, not an npm dependency |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| CF Web Analytics | Plausible, Simple Analytics, Fathom | All are cookieless alternatives; all require separate account/subscription; CF is already paid for and integrated |
| Manual beacon injection | CF Pages automatic injection | Automatic injection (via Metrics tab in CF dashboard) is unreliable with Workers deployment pattern; manual is explicit and verifiable |
| CF Web Analytics (events) | Cloudflare Zaraz | Zaraz supports custom events but is a separate product requiring additional setup |

**Installation:** No npm install required. Beacon is loaded via CDN `<script>` tag.

---

## Architecture Patterns

### Existing Project Structure (Relevant)

```
src/
├── components/
│   ├── BaseHead.astro    # <head> content: meta, OG, canonical
│   ├── Nav.astro         # Navigation (contains CTA links to /contact)
│   ├── Footer.astro
│   ├── ContactForm.astro
│   └── ScrollAnimations.astro
├── layouts/
│   └── BaseLayout.astro  # Root layout — used by ALL 4 pages
└── pages/
    ├── index.astro        # 3 CTA links to /contact
    ├── about.astro        # 1 CTA link to /contact
    ├── features.astro     # 2 CTA links to /contact
    └── contact.astro      # Contact form page
```

All 4 pages use `BaseLayout.astro`. `BaseLayout` renders `BaseHead`, `Nav`, `<slot />`, `Footer`, and `ScrollAnimations`. The `<head>` element is assembled from `BaseHead.astro`.

### Pattern 1: Dedicated Analytics Component (Recommended)

**What:** Create `src/components/Analytics.astro` containing only the beacon script tag. Import and render it in `BaseLayout.astro` inside `<head>`.

**Why this vs injecting directly in BaseLayout:** The component is easier to test in isolation, easier to disable or mock in future if needed, and follows the existing pattern of named components for every concern (BaseHead, Nav, Footer, ScrollAnimations).

**Where to insert:** Inside `<head>` in `BaseLayout.astro`, after `<BaseHead />`. CF documentation says "before the ending body tag" but `<head>` placement also works and is conventional for analytics.

```astro
<!-- src/components/Analytics.astro -->
---
// No props — token is hardcoded (CF Web Analytics tokens are public)
const CF_BEACON_TOKEN = "YOUR_TOKEN_FROM_CF_DASHBOARD";
---
<script
  defer
  src="https://static.cloudflareinsights.com/beacon.min.js"
  data-cf-beacon={`{"token": "${CF_BEACON_TOKEN}"}`}
></script>
```

```astro
<!-- src/layouts/BaseLayout.astro — after BaseHead import, add Analytics import -->
import Analytics from '../components/Analytics.astro';

<!-- In <head> -->
<BaseHead title={title} description={description} image={image} />
<Analytics />
```

### Pattern 2: Beacon Script Tag (Exact Syntax — Verified)

The beacon tag has been confirmed across multiple CF community examples:

```html
<!-- Minimal — all that's required -->
<script
  defer
  src="https://static.cloudflareinsights.com/beacon.min.js"
  data-cf-beacon='{"token": "YOUR_32_CHAR_HEX_TOKEN"}'
></script>
```

The `token` value is a 32-character hex string obtained from the CF dashboard when you create a Web Analytics site. It is **not secret** — it only routes pageview data to your CF account.

**Important Astro note:** In Astro `.astro` files, the `data-cf-beacon` attribute value must use template literals or escaped quotes carefully. The recommended approach is to set the token as a const in the frontmatter and use a template literal in the attribute.

### Pattern 3: Client-Side Event Hooks (Future-Ready, Without CF Dashboard Surface)

Since CF Web Analytics does not support custom events, event tracking code can be wired to log to `console` (development) or fire a `beacon` if a custom endpoint is configured later. For now, the cleanest approach is:

```typescript
// Attach to CTA links with data attributes
document.querySelectorAll('[data-track-event]').forEach((el) => {
  el.addEventListener('click', (e) => {
    const eventName = (e.currentTarget as HTMLElement).dataset.trackEvent;
    // Future: zaraz.track(eventName) or custom endpoint
    // For now: no-op or console.debug in dev
  });
});
```

**Recommendation for this phase:** Add `data-track-event` attributes to CTA links (`Request a Demo`, `Get Started` buttons) in source HTML. Wire a lightweight inline `<script>` that fires on click. Since there is no CF Web Analytics custom event destination, events will not appear in the dashboard — but the attribute markup and hook are in place for when a destination is added.

### CTA Inventory (All links driving toward conversion)

Based on reading the codebase:

| Location | Text | Href | Count |
|----------|------|------|-------|
| `Nav.astro` desktop | "Request a Demo" | `/contact` | 1 |
| `Nav.astro` mobile | "Request a Demo" | `/contact` | 1 |
| `index.astro` hero | "Request a Demo" | `/contact` | 1 |
| `index.astro` nonprofit card | "Get Started" | `/contact` | 1 |
| `index.astro` corporate card | "Get Started" | `/contact` | 1 |
| `index.astro` footer CTA | "Request a Demo" | `/contact` | 1 |
| `about.astro` bottom | "Request a Demo" | `/contact` | 1 |
| `features.astro` mid-page | "Request a Demo" | `/contact` | 1 |
| `features.astro` bottom | "Request a Demo" | `/contact` | 1 |

**Total: 9 CTA links to track** (all link to `/contact`).

### Anti-Patterns to Avoid

- **Injecting beacon in `BaseHead.astro` instead of `BaseLayout.astro`:** `BaseHead` outputs `<head>` content but not the wrapping `<head>` element (that's in `BaseLayout`). Adding a component reference to `BaseHead` would be less clear. Keep `Analytics` as a sibling to `BaseHead` in `BaseLayout`.
- **Using CF Pages automatic injection:** This site deploys as a Cloudflare Worker with static assets (not CF Pages). The "Metrics" tab automatic injection is only available in CF Pages projects. The `wrangler.jsonc` confirms Workers deployment — manual injection is required.
- **Env variable for token:** Not needed. CF Web Analytics tokens are intentionally public. Adding an env var creates false security theater and complicates the build without benefit.
- **Conditional dev/prod rendering:** User explicitly decided beacon loads on all environments including localhost.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Pageview tracking | Custom fetch to analytics endpoint | CF Web Analytics beacon | Handles page load timing, performance API, bot filtering, SPA route changes automatically |
| Privacy-safe analytics | Custom cookieless solution | CF Web Analytics | Already handles GDPR/CCPA, no PII collection, built into CF account |
| Custom event routing | Custom event ingestion worker | Zaraz (if needed) or defer to future phase | Complexity far exceeds scope; CF Web Analytics cannot receive events |

**Key insight:** CF Web Analytics is a zero-config pageview tracker. Do not add complexity to make it do something (custom events) that its own documentation says it does not support.

---

## Common Pitfalls

### Pitfall 1: Assuming CF Web Analytics Supports Custom Events

**What goes wrong:** Planning tasks that send named events to CF dashboard, writing code to call a non-existent CF Web Analytics events API, spending time on event instrumentation that has no visible output.

**Why it happens:** CF marketing pages emphasize "insights" without clarifying that events are not supported. Search results conflate CF Web Analytics with Zaraz.

**How to avoid:** Official FAQ (https://developers.cloudflare.com/web-analytics/faq/) states plainly: "Custom events: Not currently supported."

**Warning signs:** Any code calling `window.__cfBeacon.track()` or similar — this API does not exist.

### Pitfall 2: Workers Deployment vs Pages Deployment

**What goes wrong:** Following documentation that says "enable in Metrics tab" — this only works for CF Pages projects. This project deploys via `wrangler deploy` as a Worker with static assets (confirmed in `wrangler.jsonc`).

**Why it happens:** CF has two deployment products: Pages and Workers. Documentation for automatic beacon injection applies to Pages only.

**How to avoid:** Manual beacon injection via `<script>` tag is required. This is fine and straightforward.

**Warning signs:** Expecting automatic injection after deploying — it will not happen.

### Pitfall 3: Astro Template Literal Attribute Quoting

**What goes wrong:** Writing `data-cf-beacon='{"token": "abc"}'` directly in an Astro `.astro` template causes Astro's HTML parser to choke on nested quotes when the value is not an expression.

**Why it happens:** Astro's template syntax handles attribute values differently than plain HTML.

**How to avoid:** Use a frontmatter const and template literal:

```astro
---
const token = "abc123";
---
<script data-cf-beacon={`{"token": "${token}"}`} ... ></script>
```

**Warning signs:** Build errors or malformed HTML output when adding the beacon tag.

### Pitfall 4: Test Running Against Source, Not Built Output

**What goes wrong:** A test checks `src/components/Analytics.astro` for the beacon string — this passes even if the component is never imported in `BaseLayout`, or if it's imported but Astro strips it during build.

**Why it happens:** Testing source files instead of rendered output.

**How to avoid:** Test must run `astro build` first, then grep `dist/*.html` for the beacon token value. This verifies the token is actually present in every rendered page.

---

## Code Examples

### Complete Analytics Component

```astro
---
// src/components/Analytics.astro
// Source: CF Web Analytics beacon format confirmed via community examples
// https://community.cloudflare.com/t/cloudflare-analytics-beacon-in-amp/226724
// Token is intentionally hardcoded — CF Web Analytics tokens are public identifiers
const token = "REPLACE_WITH_TOKEN_FROM_CF_DASHBOARD";
---
<script
  defer
  src="https://static.cloudflareinsights.com/beacon.min.js"
  data-cf-beacon={`{"token": "${token}"}`}
></script>
```

### BaseLayout Integration

```astro
---
// src/layouts/BaseLayout.astro (modified)
import '@fontsource-variable/plus-jakarta-sans';
import BaseHead from '../components/BaseHead.astro';
import Nav from '../components/Nav.astro';
import Footer from '../components/Footer.astro';
import ScrollAnimations from '../components/ScrollAnimations.astro';
import Analytics from '../components/Analytics.astro';

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
    <Analytics />
  </head>
  <body class="bg-white text-body font-sans min-h-screen flex flex-col">
    <Nav />
    <main class="flex-1">
      <slot />
    </main>
    <Footer />
    <ScrollAnimations />
  </body>
</html>
```

### Verification Test Script (bash — matches project pattern)

```bash
#!/bin/bash
# scripts/test-analytics.sh
# Verifies CF Web Analytics beacon is present in all rendered pages
# Requires: npm run build to have been run

BEACON_TOKEN="REPLACE_WITH_ACTUAL_TOKEN"
DIST_DIR="./dist"
PAGES=("index.html" "about/index.html" "features/index.html" "contact/index.html")
FAILURES=0

echo "--- Verifying CF Web Analytics beacon in built HTML ---"
echo ""

for page in "${PAGES[@]}"; do
  FILE="$DIST_DIR/$page"
  if [ ! -f "$FILE" ]; then
    echo "FAIL: $FILE not found (run npm run build first)"
    FAILURES=$((FAILURES + 1))
    continue
  fi
  if grep -q "static.cloudflareinsights.com/beacon.min.js" "$FILE"; then
    echo "PASS: beacon present in $page"
  else
    echo "FAIL: beacon NOT found in $page"
    FAILURES=$((FAILURES + 1))
  fi
done

echo ""
if [ $FAILURES -eq 0 ]; then
  echo "All pages have CF Web Analytics beacon. ANLX-01 satisfied."
  exit 0
else
  echo "$FAILURES page(s) missing beacon."
  exit 1
fi
```

### Data Attribute Markup for CTA Event Hooks

```html
<!-- Example on a CTA link — add data-track-event to all 9 CTAs -->
<a
  href="/contact"
  data-track-event="cta_click"
  data-track-label="hero_request_demo"
  class="..."
>
  Request a Demo
</a>
```

```typescript
// Inline script block for event hook wiring (in BaseLayout or Analytics component)
// Source: custom — no CF Web Analytics events API exists
// This wires handlers for future use; events do NOT currently surface in CF dashboard
<script>
document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('[data-track-event]').forEach((el) => {
    el.addEventListener('click', () => {
      const eventName = (el as HTMLElement).dataset.trackEvent ?? 'click';
      const label = (el as HTMLElement).dataset.trackLabel ?? '';
      // CF Web Analytics does not support custom events.
      // Future: replace with zaraz.track(eventName, { label }) if Zaraz is enabled.
      // For now: no-op.
    });
  });
});
</script>
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Google Analytics (cookies required) | CF Web Analytics (cookieless) | 2020 (CF launched Web Analytics) | No consent banner needed |
| Manual script placement at `</body>` | `defer` attribute in `<head>` | Standard modern practice | Same load behavior, cleaner placement |
| Custom event tracking via GA events | Cloudflare Zaraz (separate product) | Ongoing — CF Web Analytics still has no custom events as of 2026 | Custom events require Zaraz product, not Web Analytics |

**Deprecated/outdated:**
- Automatic injection documentation: Refers only to CF Pages projects. This project is Workers-based, so automatic injection does not apply.

---

## Open Questions

1. **Custom Events in CF Dashboard**
   - What we know: CF Web Analytics FAQ explicitly says custom events are not supported.
   - What's unclear: Whether the user's intent ("custom events should surface in CF dashboard as named events") means they want Zaraz, or if they'd be satisfied with pageview-only tracking in CF dashboard plus future-ready event hooks in code.
   - Recommendation: Surface this gap explicitly to the user before creating plan tasks for event tracking. Options: (a) scope to pageviews only for this phase, (b) add Zaraz setup as a sub-task.

2. **CF Dashboard Site Token**
   - What we know: Token is obtained by creating a new site in CF Web Analytics dashboard (Web Analytics > Add a site > enter hostname).
   - What's unclear: Whether the CF Web Analytics site for rallytrivia.com has already been created or needs to be created as part of this phase.
   - Recommendation: Plan must include a task to create the CF Web Analytics site and obtain the token. Token is then hardcoded into `Analytics.astro`.

3. **Ad Blocker Impact**
   - What we know: CF official docs confirm the beacon is blocked by common ad blockers. Edge analytics (server-side) cannot be blocked.
   - What's unclear: Whether this matters for this project's audience.
   - Recommendation: Document in implementation notes; not a blocker for this phase. Pageviews from non-blocked browsers will still be tracked.

---

## Sources

### Primary (HIGH confidence)

- https://developers.cloudflare.com/web-analytics/faq/ — **Custom events NOT supported** (authoritative, confirmed negative)
- https://developers.cloudflare.com/web-analytics/get-started/ — Setup steps: dashboard > Add a site > copy JS snippet
- https://developers.cloudflare.com/pages/how-to/web-analytics/ — CF Pages auto-injection (confirms manual required for Workers)
- https://developers.cloudflare.com/web-analytics/changelog/ — No custom events added through June 2024
- https://developers.cloudflare.com/zaraz/web-api/track/ — zaraz.track() API (separate product for custom events)

### Secondary (MEDIUM confidence)

- https://community.cloudflare.com/t/cloudflare-analytics-beacon-in-amp/226724 — Exact beacon script tag syntax with `data-cf-beacon` attribute and token format, confirmed via multiple community examples

### Tertiary (LOW confidence)

- None — all critical claims verified against official sources.

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — beacon script is a single tag, no npm packages, CF docs confirm
- Architecture: HIGH — component approach follows existing project patterns, verified against codebase
- Custom events limitation: HIGH — confirmed by official FAQ, changelog shows no changes
- Pitfalls: HIGH — Workers vs Pages distinction confirmed in `wrangler.jsonc` + official docs
- Test approach: HIGH — bash pattern matches existing `scripts/test-worker.sh` in the project

**Research date:** 2026-02-22
**Valid until:** 2026-05-22 (CF Web Analytics is stable; custom events limitation unlikely to change quickly; check FAQ if timeline extends beyond this)
