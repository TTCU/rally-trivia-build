# Phase 4: Worker Foundation - Context

**Gathered:** 2026-02-22
**Status:** Ready for planning

<domain>
## Phase Boundary

Set up the Cloudflare Worker infrastructure — routing, secrets, and a stub endpoint — so the live API pattern is validated before any email complexity is introduced. Static pages must continue to serve correctly. Resend domain DNS must be verified.

</domain>

<decisions>
## Implementation Decisions

### API response conventions
- Simple JSON shape: `{ ok: true/false, message: "...", data: {...} }`
- RESTful HTTP status codes (200, 201, 400, 401, 404, 422, 500)
- Stub endpoint returns `{ ok: true }` for any POST to `/api/contact` — no input validation in this phase

### Wrangler config approach
- Single Worker with assets binding — Worker handles `/api/*`, static assets served alongside
- Existing `wrangler.jsonc` needs restructuring (already exists in repo root)
- Worker source code lives in `src/worker/` with `src/worker/index.ts` as entry point
- Single environment config (no dev/staging split) — keep it simple

### DNS / Resend setup
- Sending domain: `rallytrivia.com` (main domain, not a subdomain)
- From address: `contact@rallytrivia.com`
- DNS managed through Cloudflare (same account as Workers)
- DNS verification steps documented directly in the phase plan (no separate runbook)

### Dev workflow & testing
- Combined dev command — single `npm run dev` runs both Astro and Worker together
- Automated test script to verify the stub endpoint works
- Add `npm test` script as part of this phase
- Resend API key stored as Wrangler secret (`wrangler secret put RESEND_API_KEY`)

### Claude's Discretion
- CORS header approach (same-origin vs cross-origin)
- Testing framework choice (Vitest, Jest, or other)
- Exact wrangler.jsonc structure for assets + Worker coexistence

</decisions>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 04-worker-foundation*
*Context gathered: 2026-02-22*
