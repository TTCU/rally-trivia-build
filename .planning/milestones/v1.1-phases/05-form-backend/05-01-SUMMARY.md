---
phase: 05-form-backend
plan: 01
subsystem: api
tags: [resend, cloudflare-turnstile, cloudflare-workers, typescript, astro, email]

# Dependency graph
requires:
  - phase: 04-worker-foundation
    provides: "Cloudflare Worker stub at /api/contact, Resend API key in .dev.vars, wrangler bindings, CORS setup foundation"

provides:
  - "Real email delivery via Resend SDK to RECIPIENT_EMAIL on form submission"
  - "Cloudflare Turnstile server-side spam protection on /api/contact"
  - "ContactForm with real fetch POST, 900ms minimum loading time, error/retry UX"
  - "Turnstile widget embedded in form with cf-turnstile-response token flow"
  - ".env.example committed with PUBLIC_TURNSTILE_SITE_KEY placeholder"

affects: [06-polish, 07-about]

# Tech tracking
tech-stack:
  added: [resend@latest]
  patterns:
    - "Promise.all for parallel API call + minimum loading time UX"
    - "Turnstile token read from FormData cf-turnstile-response, sent as JSON to Worker"
    - "Error-preserving form UX: show error, preserve inputs, reset Turnstile, re-enable submit"
    - "CORS headers on all Worker responses for localhost:4321 dev cross-origin"

key-files:
  created:
    - .env.example
  modified:
    - src/worker/index.ts
    - src/components/ContactForm.astro
    - package.json
    - package-lock.json
    - .dev.vars
    - scripts/test-worker.sh

key-decisions:
  - "Turnstile always-passes test key (1x0000000000000000000000000000000AA) in .dev.vars for local dev — no real Cloudflare dashboard setup needed until production"
  - "Error branch preserves all form inputs and resets Turnstile for seamless retry — no separate Try Again button needed"
  - "Thank-you text changed from 'within 24 hours' to 'We'll be in touch soon.' per locked decision"
  - "900ms minimum loading time via Promise.all prevents flash of loading state on fast connections"
  - "Turnstile readiness check before submission prevents empty token errors on slow widget loads"

patterns-established:
  - "Worker: verifyTurnstile() standalone async function before any email sending"
  - "Worker: buildEmailHtml() pure function for styled brand-navy email template"
  - "Worker: corsHeaders object applied to ALL responses from POST /api/contact"
  - "Form: collect FormData, check cf-turnstile-response, then build JSON payload for fetch"

requirements-completed: [FORM-01, FORM-03]

# Metrics
duration: 5min
completed: 2026-02-23
---

# Phase 5 Plan 01: Form Backend Summary

**Resend email delivery with Cloudflare Turnstile spam protection wired end-to-end through Worker to ContactForm**

## Performance

- **Duration:** ~5 min
- **Started:** 2026-02-23T01:00:17Z
- **Completed:** 2026-02-23T01:05:00Z
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments

- Worker upgraded from Phase 4 stub to real Resend SDK email sending with server-side Turnstile verification
- ContactForm connected to real `/api/contact` API with error handling, input preservation, and Turnstile reset on failure
- `.env.example` committed with public Turnstile site key placeholder for developer onboarding

## Task Commits

Each task was committed atomically:

1. **Task 1: Implement Worker email sending with Turnstile verification** - `2b62fe1` (feat)
2. **Task 2: Connect ContactForm to real API with error handling and Turnstile widget** - `ba4dd8d` (feat)

**Plan metadata:** (docs commit — see final commit below)

## Files Created/Modified

- `src/worker/index.ts` - Full Resend + Turnstile implementation replacing Phase 4 stub
- `src/components/ContactForm.astro` - Real fetch POST, Turnstile widget, error/retry UX
- `package.json` / `package-lock.json` - Added resend SDK dependency
- `.env.example` - Public Turnstile site key placeholder (committed)
- `.dev.vars` - Added TURNSTILE_SECRET_KEY and RECIPIENT_EMAIL (gitignored, not committed)
- `scripts/test-worker.sh` - Updated tests: valid payload, GET 405, missing-token rejection

## Decisions Made

- Used Cloudflare's always-passes test key (`1x0000000000000000000000000000000AA`) in `.dev.vars` so local development works without a real Turnstile widget setup
- 900ms minimum loading time chosen via `Promise.all` — consistent with industry UX practice preventing jarring flash when API responds fast
- No separate "Try Again" button added — preserved form inputs + re-enabled submit button serves the same purpose with simpler UI

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

**External services require manual configuration before production deployment.** The following Wrangler secrets must be set in the Cloudflare dashboard before the Worker will send real emails:

1. **Cloudflare Turnstile widget** — Create widget at Cloudflare Dashboard > Turnstile > Add Widget for `rallytrivia.com`. Get Site Key (public) and Secret Key (private).

2. **Set Wrangler secrets for production:**
   ```bash
   npx wrangler secret put TURNSTILE_SECRET_KEY
   npx wrangler secret put RECIPIENT_EMAIL
   ```

3. **Update `.env` (or Cloudflare Pages env var)** with real `PUBLIC_TURNSTILE_SITE_KEY` from Turnstile dashboard (replace test key `1x00000000000000000000AA`).

For local development: test keys in `.dev.vars` already work end-to-end except actual email delivery (requires real RESEND_API_KEY).

## Next Phase Readiness

- Form-to-email pipeline is complete and ready for production once Wrangler secrets are configured
- Phase 6 (polish) can proceed — form UX is production-ready
- Phase 7 (about page) is unblocked — no form dependencies

---
*Phase: 05-form-backend*
*Completed: 2026-02-23*

## Self-Check: PASSED

- FOUND: src/worker/index.ts
- FOUND: src/components/ContactForm.astro
- FOUND: .env.example
- FOUND: .planning/phases/05-form-backend/05-01-SUMMARY.md
- FOUND: commit 2b62fe1 (Task 1)
- FOUND: commit ba4dd8d (Task 2)
