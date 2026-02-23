# Phase 5: Form Backend - Context

**Gathered:** 2026-02-22
**Status:** Ready for planning

<domain>
## Phase Boundary

Wire the existing contact form to actually send emails via the Resend API through the Cloudflare Worker. Update the form UI to reflect real success/error responses instead of the current simulated delay. Add Cloudflare Turnstile for spam protection. The Worker stub (POST `/api/contact` → `{ ok: true }`) and form UI with validation already exist from Phase 4.

</domain>

<decisions>
## Implementation Decisions

### Email content & recipient
- Single hardcoded recipient address, configured as an environment variable
- Reply-to is NOT set to the submitter's email — their email appears in the email body only
- Subject line format: "Demo Request from [Name]"
- Email body is formatted HTML (styled with sections, brand colors, clean layout)
- Body includes all submitted fields: name, email, organization, event type, message

### Error handling UX
- On Worker error, show generic user-friendly message: "Something went wrong. Please try again."
- Same generic message for network errors, timeouts, and server errors — no distinction
- Error appears in the existing top-of-form error summary banner, scrolled into view
- Include a "Try Again" retry button that resubmits the same form data
- User's input is preserved on error (never cleared)

### Success flow
- Minimum loading time of ~800ms-1s even if API responds instantly (prevent jarring flash)
- Keep the existing thank-you animation (fade out form, fade in checkmark + message)
- Change follow-up promise to vaguer wording: "We'll be in touch soon" (no specific timeframe)
- One submission is enough — thank-you screen shows only "Back to Home" link, no re-submit option

### Spam & abuse protection
- Cloudflare Turnstile in managed mode (invisible for most users, challenge only if suspicious)
- Turnstile token verified server-side in the Worker before sending email
- If Turnstile verification fails, block submission with error message: "Verification failed. Please try again."
- No additional rate limiting — Turnstile is sufficient for a low-traffic marketing form

### Claude's Discretion
- HTML email template design and exact styling
- Turnstile widget placement in the form layout
- Exact retry button styling and placement
- Request timeout duration
- Worker error response format and status codes

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

*Phase: 05-form-backend*
*Context gathered: 2026-02-22*
