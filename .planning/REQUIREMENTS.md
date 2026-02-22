# Requirements: Rally Trivia Marketing Site

**Defined:** 2026-02-22
**Core Value:** Visitors understand what Rally Trivia does and request a demo — every page funnels toward that conversion.

## v1.1 Requirements

Requirements for Production Polish milestone. Each maps to roadmap phases.

### Form Backend

- [ ] **FORM-01**: Contact form submissions are delivered via email to a single configurable recipient
- [ ] **FORM-02**: Worker handles POST `/api/contact` and sends email via Resend API
- [ ] **FORM-03**: Form UI shows loading state during submission and success/error state after
- [ ] **FORM-04**: Resend API key is stored as a Cloudflare Workers secret (not in code)

### Analytics

- [ ] **ANLX-01**: All pages include Cloudflare Web Analytics beacon script
- [ ] **ANLX-02**: Pageviews and referrer data are visible in Cloudflare dashboard

### Team

- [ ] **TEAM-01**: About page team section displays real team member names and titles
- [ ] **TEAM-02**: About page team section displays real team member photos

## Future Requirements

Deferred to a later milestone. Tracked but not in current roadmap.

### Social Proof

- **SOCL-01**: Replace placeholder stats with qualitative highlights or real data
- **SOCL-02**: Remove any fake numbers from all pages

### Security

- **SECR-01**: Honeypot field on contact form to prevent spam
- **SECR-02**: Rate limiting on `/api/contact` endpoint

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Auto-reply confirmation email | User chose no auto-reply — keep it simple |
| SSR / Astro Cloudflare adapter | Standalone Worker handles the one API endpoint; no need to change build model |
| CRM integration | Decide on tooling later |
| Pricing page | Not ready to publish pricing |
| Blog/content marketing | Requires ongoing content production |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| FORM-01 | — | Pending |
| FORM-02 | — | Pending |
| FORM-03 | — | Pending |
| FORM-04 | — | Pending |
| ANLX-01 | — | Pending |
| ANLX-02 | — | Pending |
| TEAM-01 | — | Pending |
| TEAM-02 | — | Pending |

**Coverage:**
- v1.1 requirements: 8 total
- Mapped to phases: 0
- Unmapped: 8 (pending roadmap)

---
*Requirements defined: 2026-02-22*
*Last updated: 2026-02-22 after initial definition*
