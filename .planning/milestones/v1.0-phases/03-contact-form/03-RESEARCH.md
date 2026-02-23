# Phase 3: Contact Form - Research

**Researched:** 2026-02-22
**Domain:** Client-side form UI in Astro static site
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- Page layout is Claude's discretion — pick what fits the existing site style (centered single-column or split layout)
- Action-oriented headline tone: "Request a Demo" style, direct and clear
- Minimal surrounding content — just the form with a brief intro line, no trust signals or extra marketing copy
- Use the same scroll-triggered animations as the other content pages (Motion library)
- Fields: name, email, organization, event type (dropdown select), message (textarea)
- Only name and email are required; organization, event type, and message are optional
- Event type dropdown with granular options: "Gala/Fundraiser", "Team Building", "Conference", "School/Education", "Holiday Party", "Other"
- Labels above inputs (standard accessible pattern, always visible)
- Validate on blur (when user leaves a field)
- Error display: summary banner at top of form listing all issues, plus inline red text below each invalid field with red border
- Email validation with format check plus common typo suggestions (e.g. "gmial.com" -> "gmail.com")
- Submit button shows brief loading/disabled state (1-2 seconds) before transitioning to confirmation — simulates real submission feel
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

### Deferred Ideas (OUT OF SCOPE)
- None — discussion stayed within phase scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| CONT-01 | Demo request form with name, email, organization, event type, and message fields | Vanilla JS form handling in Astro `<script>` tags; Tailwind form styling patterns |
| CONT-02 | Post-submit confirmation/thank you state | Client-side state toggle — hide form, show thank-you view via DOM manipulation |
</phase_requirements>

## Summary

Phase 3 builds a demo request contact form as the site's primary conversion endpoint. This is a UI-only implementation — no backend submission is wired (deferred to v2 per FORM-01). The form collects name, email, organization, event type, and message, validates on blur, simulates a brief submission loading state, then transitions to a full-page thank-you confirmation.

The existing codebase uses Astro 5.16 with Tailwind CSS v4, Motion library for scroll animations, and vanilla JS in `<script>` tags for interactivity (see Nav.astro hamburger toggle pattern). No additional npm dependencies are needed. The form logic uses the same vanilla JS pattern already established in the project.

**Primary recommendation:** Build the form as a single `ContactForm` component using Astro's `<script>` tag for client-side validation and state management, following the same vanilla JS patterns already used in Nav.astro and ScrollAnimations.astro.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Astro | 5.16.2 | Static page generation | Already in project |
| Tailwind CSS | 4.2.0 | Form styling, validation states | Already in project |
| Motion | 12.34.3 | Scroll animations, thank-you transition | Already in project |

### Supporting
No additional libraries needed. The form is pure HTML + vanilla JS.

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Vanilla JS validation | React/Preact island | Overkill for a single form; adds framework JS to a static site |
| Custom email typo check | mailcheck.js | 5KB dependency for a small feature; hand-rolled is fine for 5-6 common domains |
| Native HTML validation | Constraint Validation API | Native is less controllable for the summary banner + inline error UX requirement |

**Installation:**
```bash
# No new packages needed
```

## Architecture Patterns

### Recommended Project Structure
```
src/
├── pages/
│   └── contact.astro          # Page shell (imports ContactForm)
├── components/
│   └── ContactForm.astro      # Form component with all logic
└── (existing files unchanged)
```

### Pattern 1: Astro Component with Client-Side Script
**What:** All form HTML in an Astro component, all interactivity in a `<script>` tag
**When to use:** Interactive UI in a static Astro site without framework islands
**Example:**
```astro
---
// ContactForm.astro — no props needed, self-contained
---

<form id="contact-form" novalidate>
  <!-- Form fields -->
</form>

<div id="thank-you" class="hidden">
  <!-- Thank-you view -->
</div>

<script>
  const form = document.getElementById('contact-form') as HTMLFormElement;
  const thankYou = document.getElementById('thank-you')!;

  // Validation on blur
  form.querySelectorAll('input, select, textarea').forEach(field => {
    field.addEventListener('blur', () => validateField(field));
  });

  // Submit handler
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    if (!validateAll()) return;
    await simulateSubmit();
    form.classList.add('hidden');
    thankYou.classList.remove('hidden');
  });
</script>
```

### Pattern 2: Blur Validation with Error Summary
**What:** Validate individual fields on blur; on submit, validate all and show summary banner
**When to use:** When the design calls for both inline errors and a summary
**Example:**
```typescript
function validateField(field: HTMLElement): boolean {
  const errorEl = document.getElementById(`${field.id}-error`);
  let message = '';

  if (field instanceof HTMLInputElement) {
    if (field.required && !field.value.trim()) {
      message = `${field.name} is required`;
    } else if (field.type === 'email' && field.value && !isValidEmail(field.value)) {
      message = 'Please enter a valid email address';
      const typoSuggestion = checkEmailTypo(field.value);
      if (typoSuggestion) message += `. Did you mean ${typoSuggestion}?`;
    }
  }

  if (errorEl) {
    errorEl.textContent = message;
    errorEl.classList.toggle('hidden', !message);
  }
  field.classList.toggle('border-red-500', !!message);
  field.classList.toggle('border-navy/20', !message);

  return !message;
}
```

### Pattern 3: Email Typo Detection
**What:** Check email domain against common misspellings
**When to use:** After email format validation passes
**Example:**
```typescript
const TYPO_MAP: Record<string, string> = {
  'gmial.com': 'gmail.com',
  'gmai.com': 'gmail.com',
  'gamil.com': 'gmail.com',
  'gnail.com': 'gmail.com',
  'yahooo.com': 'yahoo.com',
  'yaho.com': 'yahoo.com',
  'hotmal.com': 'hotmail.com',
  'outlok.com': 'outlook.com',
};

function checkEmailTypo(email: string): string | null {
  const domain = email.split('@')[1]?.toLowerCase();
  if (domain && TYPO_MAP[domain]) {
    return email.replace(domain, TYPO_MAP[domain]);
  }
  return null;
}
```

### Anti-Patterns to Avoid
- **Framework island for a form:** Adding React/Preact/Svelte just for form validation adds unnecessary client JS and complexity
- **Native HTML validation (without novalidate):** Browser-default validation bubbles conflict with the custom summary banner + inline error design
- **Storing form state in a framework:** Vanilla DOM manipulation is simpler and already the project pattern

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Scroll animations | Custom IntersectionObserver | Motion library `inView` + `animate` | Already in project, consistent with other pages |
| CSS styling | Custom CSS | Tailwind utility classes | Project standard |

**Key insight:** This form is simple enough that vanilla JS is the right choice. The project has no framework islands — introducing one for a contact form would be architecturally inconsistent.

## Common Pitfalls

### Pitfall 1: Form Not Accessible
**What goes wrong:** Missing labels, missing aria attributes, no keyboard navigation
**Why it happens:** Focus on visual design over semantic HTML
**How to avoid:** Use `<label for="...">` on every field, `aria-describedby` linking to error messages, `aria-invalid="true"` on invalid fields, `role="alert"` on error summary
**Warning signs:** Form works with mouse but not keyboard; screen reader can't identify errors

### Pitfall 2: Email Regex Too Strict or Too Loose
**What goes wrong:** Rejecting valid emails or accepting clearly invalid ones
**Why it happens:** Rolling custom regex
**How to avoid:** Use a simple pattern that catches obvious issues: check for `@` and a `.` after it. The real validation happens server-side (in v2). Client-side just prevents obvious typos.
**Warning signs:** Users with `+` in their email get rejected; bare strings like "test" pass validation

### Pitfall 3: Submit Button Not Disabled During "Loading"
**What goes wrong:** User double-clicks, sees flickering or duplicate behavior
**Why it happens:** Forgetting to disable the button during the simulated submission
**How to avoid:** Set `disabled` attribute on submit button immediately, re-enable on error only
**Warning signs:** Button is clickable during the loading animation

### Pitfall 4: Thank-You View Scroll Position
**What goes wrong:** After form hides and thank-you shows, user is scrolled to middle of page
**Why it happens:** DOM height changes when form is replaced
**How to avoid:** `window.scrollTo({ top: 0, behavior: 'smooth' })` when transitioning to thank-you
**Warning signs:** Thank-you heading is not visible after submission

### Pitfall 5: CTA Buttons on Other Pages Not Linking to Contact
**What goes wrong:** Phase requirement says CTAs on landing, features, and about pages link to contact — but they don't get updated
**Why it happens:** Treating the contact form as isolated from the rest of the site
**How to avoid:** Verify existing CTA buttons already point to `/contact`. Check Nav CTA button too.
**Warning signs:** Success criteria #1 fails: "contact page is reachable from CTA buttons"

## Code Examples

### Tailwind Form Input Styling
```html
<div class="mb-6">
  <label for="name" class="block text-sm font-semibold text-navy mb-2">
    Name <span class="text-coral">*</span>
  </label>
  <input
    type="text"
    id="name"
    name="name"
    required
    class="w-full px-4 py-3 rounded-lg border border-navy/20 bg-white text-navy
           placeholder:text-navy/40 focus:outline-none focus:ring-2 focus:ring-electric-blue
           focus:border-transparent transition-colors"
    placeholder="Your full name"
    aria-describedby="name-error"
  />
  <p id="name-error" class="hidden mt-1 text-sm text-red-500" role="alert"></p>
</div>
```

### Simulated Submit with Loading State
```typescript
async function simulateSubmit(): Promise<void> {
  const btn = document.getElementById('submit-btn') as HTMLButtonElement;
  const btnText = btn.querySelector('.btn-text')!;
  const btnSpinner = btn.querySelector('.btn-spinner')!;

  btn.disabled = true;
  btnText.classList.add('hidden');
  btnSpinner.classList.remove('hidden');

  // Simulate network delay (1-2 seconds per user decision)
  await new Promise(resolve => setTimeout(resolve, 1500));
}
```

### Thank-You Transition with Motion
```typescript
import { animate } from 'motion';

function showThankYou() {
  const form = document.getElementById('contact-form')!;
  const thankYou = document.getElementById('thank-you')!;

  // Fade out form
  animate(form, { opacity: [1, 0] }, { duration: 0.3 }).finished.then(() => {
    form.classList.add('hidden');
    thankYou.classList.remove('hidden');
    window.scrollTo({ top: 0, behavior: 'smooth' });

    // Fade in thank-you
    animate(thankYou, { opacity: [0, 1], y: [20, 0] }, { duration: 0.5 });
  });
}
```

### Dropdown Select Styling
```html
<div class="mb-6">
  <label for="event-type" class="block text-sm font-semibold text-navy mb-2">
    Event Type
  </label>
  <select
    id="event-type"
    name="event-type"
    class="w-full px-4 py-3 rounded-lg border border-navy/20 bg-white text-navy
           focus:outline-none focus:ring-2 focus:ring-electric-blue
           focus:border-transparent transition-colors appearance-none
           bg-[url('data:image/svg+xml,...')] bg-no-repeat bg-[right_1rem_center]"
  >
    <option value="">Select event type...</option>
    <option value="gala">Gala/Fundraiser</option>
    <option value="team-building">Team Building</option>
    <option value="conference">Conference</option>
    <option value="education">School/Education</option>
    <option value="holiday">Holiday Party</option>
    <option value="other">Other</option>
  </select>
</div>
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| jQuery form validation | Native JS + Constraint Validation API | 2020+ | No dependency needed |
| CSS-only validation (`:invalid`) | JS-controlled validation with `novalidate` | Always for custom UX | Full control over error display timing and format |
| Full SPA for forms | Static page + script tag | Astro pattern | Minimal client JS, fast load |

**Deprecated/outdated:**
- jQuery Validate plugin: unnecessary with modern vanilla JS
- FormData polyfills: not needed (browser support is universal)

## Open Questions

1. **CTA button linking**
   - What we know: Landing, features, and about pages have CTA buttons. Nav has a CTA.
   - What's unclear: Whether existing CTAs already point to `/contact` or need updating
   - Recommendation: Verify during implementation; update if needed (likely already correct from Phase 2)

## Sources

### Primary (HIGH confidence)
- Project codebase analysis: Nav.astro (vanilla JS pattern), ScrollAnimations.astro (Motion pattern), package.json (dependencies)
- Astro documentation: Script tags in components for client-side interactivity
- Motion library: `animate` and `inView` APIs already used in project

### Secondary (MEDIUM confidence)
- Tailwind CSS v4 form styling patterns (utility-class approach consistent with project)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - no new dependencies, using existing project patterns
- Architecture: HIGH - follows established Astro component + script tag pattern
- Pitfalls: HIGH - common form UX issues well-documented

**Research date:** 2026-02-22
**Valid until:** 2026-03-22 (stable domain, no fast-moving dependencies)
