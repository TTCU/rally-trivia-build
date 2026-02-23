# Phase 7: Content Polish - Research

**Researched:** 2026-02-22
**Domain:** Astro static site content replacement (images, team data, layout)
**Confidence:** HIGH

## Summary

Phase 7 replaces placeholder team content on the About page with real names, titles, and photos. The technical scope is narrow: update a single Astro component file (`src/pages/about.astro`) to use real data and Astro's built-in `<Image>` component for optimized photo delivery.

The team photos already exist in the repo at `assets/images/`. Astro's `<Image>` component can import them via relative paths, automatically inferring dimensions to prevent CLS (Cumulative Layout Shift). No new dependencies are needed -- Astro 5.x includes `astro:assets` natively.

**Primary recommendation:** Import photos as ESM imports in the frontmatter, use Astro's `<Image>` component with `class="rounded-full"` for circular frames, and update the team data array with real names and titles from CONTEXT.md.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- 4 team members in this order: Amanda Flaherty, Davis Light, Jenna Davis, Joe Slitzker
- Amanda Flaherty -- TTCU Cares Foundation Director
- Davis Light -- IT Support Supervisor and Award Winning Trivia Night Host
- Jenna Davis -- IT Business Analyst and Chief Justice of the Trivia Judicial Panel
- Joe Slitzker -- SVP of Technology & Innovation
- Display order is intentional -- Joe last
- Professional headshots, displayed in rounded circle frames (keep current `rounded-full` treatment)
- Photos already in repo: `assets/images/amanda.jpeg`, `assets/images/davis.jpeg`, `assets/images/jenna.jpeg`, `assets/images/joe.jpeg`
- Use Astro `<Image>` component with explicit dimensions to prevent layout shift
- Name + title + photo only -- no bios or fun facts
- Subtle card treatment (light background or shadow to frame each person)
- 4-across grid on desktop, responsive wrapping on smaller screens
- Each card includes a small LinkedIn icon linking to their profile
- LinkedIn URLs to be provided before or during implementation
- Update the "Meet the Team" subtitle -- replace "More to come -- we're just getting started" with a mission-driven line
- Titles may be lightly polished for formatting consistency, but preserve personality
- Review the entire About page for any remaining placeholder text or rough edges

### Claude's Discretion
- Exact circle photo size (currently w-28/h-28 -- adjust if it looks better larger)
- Exact subtitle wording
- Minor title formatting polish
- Card shadow/background intensity
- Responsive breakpoints for the grid

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| TEAM-01 | About page team section displays real team member names and titles | Replace placeholder `team` array with real names/titles from CONTEXT.md decisions |
| TEAM-02 | About page team section displays real team member photos | Import photos from `assets/images/` via Astro `<Image>` component |
</phase_requirements>

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Astro | 5.16.2 | Static site generator (already installed) | Project framework |
| `astro:assets` | Built-in (Astro 5.x) | Image optimization and `<Image>` component | Native to Astro, no install needed |
| Tailwind CSS | (already installed) | Styling (cards, grid, responsive) | Project styling framework |

### Supporting
No additional libraries needed. Everything required is already in the project.

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Astro `<Image>` | Raw `<img>` tag | Loses automatic dimension inference, optimization, and CLS prevention |
| ESM image imports | `public/` folder images | Loses Astro processing pipeline; no auto-dimensions |

**Installation:**
```bash
# No installation needed -- all dependencies already present
```

## Architecture Patterns

### Current About Page Structure
```
src/pages/about.astro
├── Frontmatter (team data array, imports)
├── Hero section
├── "Our Story" section
├── "Meet the Team" section (TARGET for changes)
└── Bottom CTA section
```

### Pattern 1: ESM Image Imports in Frontmatter
**What:** Import local images as ESM modules in the Astro frontmatter. Astro resolves them to processed image objects with width, height, src, and format metadata.
**When to use:** Any time you need optimized local images with automatic dimension inference.
**Example:**
```astro
---
// Source: https://docs.astro.build/en/guides/images/
import { Image } from 'astro:assets';
import amandaPhoto from '../../assets/images/amanda.jpeg';

const team = [
  { name: 'Amanda Flaherty', title: 'TTCU Cares Foundation Director', photo: amandaPhoto },
];
---

<Image src={amandaPhoto} alt="Amanda Flaherty" class="rounded-full" width={160} height={160} />
```

### Pattern 2: Responsive Grid with Tailwind
**What:** 4-column grid on desktop, responsive wrapping on smaller screens.
**When to use:** Team card layouts.
**Example:**
```html
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">
  <!-- cards -->
</div>
```

### Pattern 3: LinkedIn Icon as Inline SVG
**What:** Small LinkedIn icon as inline SVG within each card, linking to the member's profile.
**When to use:** When adding social links without importing an icon library.
**Example:**
```html
<a href="https://linkedin.com/in/profile" target="_blank" rel="noopener noreferrer" aria-label="LinkedIn profile">
  <svg class="w-5 h-5 text-body-light hover:text-primary transition-colors" fill="currentColor" viewBox="0 0 24 24">
    <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/>
  </svg>
</a>
```

### Anti-Patterns to Avoid
- **String paths as Image src:** Astro's `<Image>` requires imported image objects, not string file paths. `src="/assets/images/amanda.jpeg"` will error.
- **Images in public/ when optimization is needed:** Photos in `public/` bypass Astro's processing pipeline. Import from `assets/` instead.
- **Missing alt text:** Every `<Image>` must have descriptive alt text for accessibility.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Image optimization | Manual sharp/imagemin pipeline | Astro `<Image>` component | Handles format conversion, resizing, dimension inference automatically |
| CLS prevention | Manual width/height attributes | Astro `<Image>` auto-inference | Astro reads image metadata at build time and sets dimensions |
| Icon library | npm install react-icons / heroicons | Inline SVG for single LinkedIn icon | One icon doesn't justify a dependency |

**Key insight:** This phase requires zero new dependencies. Astro's built-in image handling and Tailwind's existing utilities cover every need.

## Common Pitfalls

### Pitfall 1: Forgetting to Import Images as ESM
**What goes wrong:** Passing a string path like `"../../assets/images/amanda.jpeg"` to `<Image src=...>` causes a build error.
**Why it happens:** Astro's Image component requires processed image objects, not strings.
**How to avoid:** Always `import amandaPhoto from '../../assets/images/amanda.jpeg'` in frontmatter.
**Warning signs:** Build error: "Local images must be imported."

### Pitfall 2: Grid Column Count Mismatch
**What goes wrong:** Current grid is `md:grid-cols-3` for 3 members. With 4 members, the last one wraps awkwardly.
**Why it happens:** Previous placeholder had 3 team members; Phase 7 adds a 4th.
**How to avoid:** Change to `lg:grid-cols-4` for 4-across on desktop. Use `sm:grid-cols-2` for tablet.
**Warning signs:** Visual inspection shows 3+1 layout instead of 4-across.

### Pitfall 3: Photo Aspect Ratio Distortion
**What goes wrong:** Circle-cropped photos look distorted if aspect ratio isn't constrained.
**Why it happens:** `rounded-full` with unequal width/height creates ovals, not circles.
**How to avoid:** Set equal `width` and `height` on `<Image>`, use `object-cover` for cropping.
**Warning signs:** Oval-shaped frames or stretched faces.

### Pitfall 4: LinkedIn URLs Not Yet Available
**What goes wrong:** CONTEXT.md says "LinkedIn URLs to be provided before or during implementation."
**Why it happens:** URLs weren't captured during discussion.
**How to avoid:** Use placeholder `#` hrefs with a code comment, or prompt for URLs during execution.
**Warning signs:** Dead links in production.

## Code Examples

### Complete Team Card Pattern
```astro
---
import { Image } from 'astro:assets';
import amandaPhoto from '../../assets/images/amanda.jpeg';
import davisPhoto from '../../assets/images/davis.jpeg';
import jennaPhoto from '../../assets/images/jenna.jpeg';
import joePhoto from '../../assets/images/joe.jpeg';

const team = [
  { name: 'Amanda Flaherty', title: 'TTCU Cares Foundation Director', photo: amandaPhoto, linkedin: '#' },
  { name: 'Davis Light', title: 'IT Support Supervisor and Award Winning Trivia Night Host', photo: davisPhoto, linkedin: '#' },
  { name: 'Jenna Davis', title: 'IT Business Analyst and Chief Justice of the Trivia Judicial Panel', photo: jennaPhoto, linkedin: '#' },
  { name: 'Joe Slitzker', title: 'SVP of Technology & Innovation', photo: joePhoto, linkedin: '#' },
];
---

<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">
  {team.map(({ name, title, photo, linkedin }) => (
    <div class="flex flex-col items-center text-center p-6 rounded-xl bg-white shadow-sm">
      <Image
        src={photo}
        alt={name}
        width={160}
        height={160}
        class="rounded-full object-cover mb-4"
      />
      <div class="font-bold text-heading">{name}</div>
      <div class="text-body-light text-sm mb-3">{title}</div>
      <a href={linkedin} target="_blank" rel="noopener noreferrer" aria-label={`${name} on LinkedIn`}>
        <!-- LinkedIn SVG icon -->
      </a>
    </div>
  ))}
</div>
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `@astrojs/image` integration | Built-in `astro:assets` | Astro 3.0 (Aug 2023) | No extra package needed |
| Manual width/height | Auto-inferred from imports | Astro 3.0+ | CLS prevention is automatic for local images |

**Deprecated/outdated:**
- `@astrojs/image`: Replaced by built-in `astro:assets` in Astro 3.0+. Do not install.

## Open Questions

1. **LinkedIn Profile URLs**
   - What we know: Each team card should include a LinkedIn icon/link per CONTEXT.md
   - What's unclear: The actual URLs for each team member
   - Recommendation: Use `#` placeholders during implementation; prompt user for real URLs during execution or mark as a follow-up

## Sources

### Primary (HIGH confidence)
- [Astro Images Guide](https://docs.astro.build/en/guides/images/) - Image component usage, import patterns, CLS prevention
- [Astro Image Assets API Reference](https://docs.astro.build/en/reference/modules/astro-assets/) - Component props and behavior

### Secondary (MEDIUM confidence)
- Existing codebase (`src/pages/about.astro`) - Current placeholder structure and Tailwind classes
- Existing codebase (`assets/images/`) - Confirmed team photo files exist

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Astro's built-in Image component is well-documented and already available
- Architecture: HIGH - Simple data replacement in a single file, patterns confirmed from official docs
- Pitfalls: HIGH - Known issues (ESM imports, grid columns, aspect ratios) are well-understood

**Research date:** 2026-02-22
**Valid until:** 2026-03-22 (stable domain, unlikely to change)
