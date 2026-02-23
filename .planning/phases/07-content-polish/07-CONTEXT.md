# Phase 7: Content Polish - Context

**Gathered:** 2026-02-22
**Status:** Ready for planning

<domain>
## Phase Boundary

Replace all placeholder content in the About page team section with real founding team names, titles, and photos. Also review the rest of the About page for any rough edges. The site should no longer signal "unfinished" to visitors.

</domain>

<decisions>
## Implementation Decisions

### Team Members
- 4 team members in this order: Amanda Flaherty, Davis Light, Jenna Davis, Joe Slitzker
- Amanda Flaherty — TTCU Cares Foundation Director
- Davis Light — IT Support Supervisor and Award Winning Trivia Night Host
- Jenna Davis — IT Business Analyst and Chief Justice of the Trivia Judicial Panel
- Joe Slitzker — SVP of Technology & Innovation
- Display order is intentional — Joe last

### Photo Style
- Professional headshots, displayed in rounded circle frames (keep current `rounded-full` treatment)
- Photos already in repo: `assets/images/amanda.jpeg`, `assets/images/davis.jpeg`, `assets/images/jenna.jpeg`, `assets/images/joe.jpeg`
- Use Astro `<Image>` component with explicit dimensions to prevent layout shift

### Card Design
- Name + title + photo only — no bios or fun facts
- Subtle card treatment (light background or shadow to frame each person)
- 4-across grid on desktop, responsive wrapping on smaller screens
- Each card includes a small LinkedIn icon linking to their profile
- LinkedIn URLs to be provided before or during implementation

### Content Tone
- Update the "Meet the Team" subtitle — replace "More to come — we're just getting started" with a mission-driven line (e.g., tying the team to Rally Trivia's purpose)
- Titles may be lightly polished for formatting consistency, but preserve personality (keep "Chief Justice of the Trivia Judicial Panel", "Award Winning Trivia Night Host", etc.)
- Review the entire About page for any remaining placeholder text or rough edges

### Claude's Discretion
- Exact circle photo size (currently w-28/h-28 — adjust if it looks better larger)
- Exact subtitle wording
- Minor title formatting polish
- Card shadow/background intensity
- Responsive breakpoints for the grid

</decisions>

<specifics>
## Specific Ideas

- Titles carry personality and humor — they're a deliberate choice, not placeholders. Preserve the character.
- The rounded circle photo frame from the current template is liked — keep that visual pattern.
- The page should feel complete and credible to any visitor who reaches it.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 07-content-polish*
*Context gathered: 2026-02-22*
