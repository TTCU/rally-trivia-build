# Phase 6: Analytics - Context

**Gathered:** 2026-02-22
**Status:** Ready for planning

<domain>
## Phase Boundary

Add Cloudflare Web Analytics to every page so traffic, referrers, and conversion paths are visible from day one. This phase covers beacon integration, custom event tracking, and verification. It does NOT include third-party analytics platforms, A/B testing, or marketing automation.

</domain>

<decisions>
## Implementation Decisions

### Beacon placement
- Token hardcoded directly in the HTML (CF Web Analytics tokens are public by nature)
- Beacon loads on all environments including localhost — no dev/prod conditional
- CF Web Analytics site needs to be created in the CF dashboard as part of this phase

### Claude's Discretion: Beacon architecture
- Whether to inject in base layout directly or create a dedicated `<Analytics />` component — Claude picks the cleanest approach for the existing Astro codebase

### Privacy & consent
- No cookie/consent banner needed — CF Web Analytics is cookieless and collects no PII
- No privacy policy page or footer disclosure in this phase
- No GDPR/CCPA compliance work — CF's privacy-first approach satisfies requirements

### Custom events
- **Detailed funnel tracking** — go beyond pageviews to capture the full user journey
- Track all navigation CTAs: "Book a Demo", "Learn More", and any links driving users toward contact
- Send custom events to Cloudflare dashboard so they're visible alongside pageviews as named events

### Claude's Discretion: Event implementation details
- Scroll depth tracking granularity (section-based vs percentage-based — pick what's most useful for a marketing site)
- Form field interaction tracking depth (submit-only vs full form funnel — pick what's practical with CF Web Analytics capabilities)

### Dashboard & verification
- Automated test that confirms beacon script tag is present in rendered HTML of every page
- Default CF Web Analytics dashboard metrics are sufficient (pageviews, top pages, referrers, countries)
- Custom events should surface in CF dashboard as named events

### Claude's Discretion: Test scope
- Whether to also verify custom event hooks are wired up, or keep tests focused on beacon presence — Claude determines the right coverage level

</decisions>

<specifics>
## Specific Ideas

- User wants full funnel visibility: from page visit → section engagement → CTA click → form submission
- All CTA interactions tracked, not just the primary "Book a Demo" — includes secondary navigation links that drive toward conversion
- Events should be visible in the CF Web Analytics dashboard, not just tracked in code

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 06-analytics*
*Context gathered: 2026-02-22*
