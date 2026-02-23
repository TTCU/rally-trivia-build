# Phase 3: Contact Form - Context

**Gathered:** 2026-02-22
**Status:** Ready for planning

<domain>
## Phase Boundary

Demo request form page — the conversion endpoint of the entire site. Visitors fill out a form and see a thank-you confirmation. UI-only (no backend wiring). CTA buttons on landing, features, and about pages link here.

</domain>

<decisions>
## Implementation Decisions

### Form layout & presentation
- Page layout is Claude's discretion — pick what fits the existing site style (centered single-column or split layout)
- Action-oriented headline tone: "Request a Demo" style, direct and clear
- Minimal surrounding content — just the form with a brief intro line, no trust signals or extra marketing copy
- Use the same scroll-triggered animations as the other content pages (Motion library)

### Field design & event type options
- Fields: name, email, organization, event type (dropdown select), message (textarea)
- Only name and email are required; organization, event type, and message are optional
- Event type dropdown with granular options: "Gala/Fundraiser", "Team Building", "Conference", "School/Education", "Holiday Party", "Other"
- Labels above inputs (standard accessible pattern, always visible)

### Validation & error feedback
- Validate on blur (when user leaves a field)
- Error display: summary banner at top of form listing all issues, plus inline red text below each invalid field with red border
- Email validation with format check plus common typo suggestions (e.g. "gmial.com" → "gmail.com")
- Submit button shows brief loading/disabled state (1-2 seconds) before transitioning to confirmation — simulates real submission feel

### Thank-you confirmation
- Full page takeover after submission — entire page transitions to a dedicated thank-you view
- Includes expected timeline: "We'll reach out within 24 hours"
- Homepage link to navigate away — no "submit another" option
- One submission per visit is the expected flow

### Claude's Discretion
- Page layout choice (centered vs split)
- Thank-you page visual element (checkmark icon, animated success, etc.)
- Exact spacing, typography, and color usage within brand system
- Loading spinner/animation style during simulated submit
- Specific copy for form intro line and error messages

</decisions>

<specifics>
## Specific Ideas

No specific references — open to standard approaches that match the existing site's brand tone (clean, modern, confident, approachable).

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 03-contact-form*
*Context gathered: 2026-02-22*
