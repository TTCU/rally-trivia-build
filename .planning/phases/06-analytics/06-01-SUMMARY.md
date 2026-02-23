# Phase 6, Plan 01: CF Web Analytics Beacon + CTA Event Tracking Hooks

**Status:** Complete
**Completed:** 2026-02-22
**Requirements satisfied:** ANLX-01 (beacon on all pages), ANLX-02 (pageviews visible after deployment + token replacement)

## What Was Done

### 1. Created `src/components/Analytics.astro`
- Single-purpose component containing the Cloudflare Web Analytics beacon `<script defer>` tag
- Token hardcoded as a frontmatter const (CF Web Analytics tokens are public identifiers)
- Uses `JSON.stringify({ token })` for the `data-cf-beacon` attribute to avoid Astro quoting issues
- No dev/prod conditional -- beacon loads on all environments including localhost
- **ACTION REQUIRED:** Replace placeholder token `REPLACE_WITH_TOKEN_FROM_CF_DASHBOARD` with actual 32-char hex token from CF Dashboard > Web Analytics > Add a site > rallytrivia.com

### 2. Created `src/components/EventTracking.astro`
- Client-side event hook wiring for all elements with `data-track-event` attributes
- DOMContentLoaded listener queries `[data-track-event]` elements and attaches click handlers
- Handlers are no-ops because CF Web Analytics does NOT support custom events (confirmed by official FAQ)
- Code comments explain how to enable a future event destination (Zaraz or custom endpoint)

### 3. Updated `src/layouts/BaseLayout.astro`
- Imported `Analytics` and `EventTracking` components
- `<Analytics />` rendered in `<head>` after `<BaseHead />`
- `<EventTracking />` rendered in `<body>` before `</body>` (after `<ScrollAnimations />`)
- All 4 pages automatically receive both components via BaseLayout

### 4. Added `data-track-event` attributes to all 9 CTA links

| Location | Label | Attribute Values |
|----------|-------|-----------------|
| Nav.astro (desktop) | Request a Demo | `cta_click` / `nav_desktop_request_demo` |
| Nav.astro (mobile) | Request a Demo | `cta_click` / `nav_mobile_request_demo` |
| index.astro (hero) | Request a Demo | `cta_click` / `hero_request_demo` |
| index.astro (nonprofit) | Get Started | `cta_click` / `nonprofit_get_started` |
| index.astro (corporate) | Get Started | `cta_click` / `corporate_get_started` |
| index.astro (footer CTA) | Request a Demo | `cta_click` / `footer_cta_request_demo` |
| about.astro (bottom) | Request a Demo | `cta_click` / `about_bottom_request_demo` |
| features.astro (hero) | Request a Demo | `cta_click` / `features_mid_request_demo` |
| features.astro (bottom) | Request a Demo | `cta_click` / `features_bottom_request_demo` |

### 5. Created `scripts/test-analytics.sh`
- Builds the site with `npm run build`
- Verifies beacon script (`static.cloudflareinsights.com/beacon.min.js`) present in all 4 HTML pages
- Verifies `data-track-event` attributes present in index, about, and features pages
- All checks pass

## Verification Results

```
PASS: beacon present in index.html
PASS: beacon present in about/index.html
PASS: beacon present in features/index.html
PASS: beacon present in contact/index.html
PASS: CTA tracking attributes present in index.html
PASS: CTA tracking attributes present in about/index.html
PASS: CTA tracking attributes present in features/index.html
All checks passed. ANLX-01 satisfied.
```

## Important Notes

- **CF Web Analytics does NOT support custom events.** The `EventTracking.astro` hooks are future-ready wiring only. Events will NOT appear in the CF Web Analytics dashboard. To enable custom event tracking, set up Cloudflare Zaraz and replace the no-op handler with `zaraz.track(eventName, { label })`.
- **Token must be replaced** before deployment. The placeholder `REPLACE_WITH_TOKEN_FROM_CF_DASHBOARD` will cause the beacon to not report data. Get the real token from the CF dashboard.
- **ANLX-02 cannot be fully verified** until the real token is set and the site is deployed to production. A real browser visit to rallytrivia.com with the beacon loaded will cause pageview data to appear in the CF Web Analytics dashboard within 2-5 minutes.

## Files Modified

- `src/components/Analytics.astro` (new)
- `src/components/EventTracking.astro` (new)
- `src/layouts/BaseLayout.astro` (modified -- 2 imports + 2 component renders)
- `src/components/Nav.astro` (modified -- 2 CTA links)
- `src/pages/index.astro` (modified -- 4 CTA links)
- `src/pages/about.astro` (modified -- 1 CTA link)
- `src/pages/features.astro` (modified -- 2 CTA links)
- `scripts/test-analytics.sh` (new)

## Decisions Made (Claude's Discretion)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Beacon architecture | Dedicated `<Analytics />` component | Follows existing pattern of named components (BaseHead, Nav, Footer, ScrollAnimations); easier to test, disable, or mock |
| Event tracking scope | No-op handlers with data attributes | CF Web Analytics cannot receive custom events; markup + hooks are in place for future Zaraz integration |
| Test scope | Beacon presence + CTA attribute presence | Verifying event handler wiring in built output would require runtime testing; beacon presence is sufficient for ANLX-01 |
