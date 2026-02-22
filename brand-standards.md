# Rally Trivia — Brand Standards

Design system derived from the Rally Trivia logo (bright blue speech bubble + dark charcoal text).

## Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `primary` | `#2563eb` | CTAs, links, active states, accent elements |
| `heading` | `#1e293b` | Headings, nav text (slate-800) |
| `body` | `#475569` | Body copy (slate-600) |
| `body-light` | `#64748b` | Secondary/caption text (slate-500) |
| `surface` | `#f8fafc` | Alternate section backgrounds (slate-50) |
| `surface-blue` | `#eff6ff` | Hero sections, highlighted areas (blue-50) |
| `border` | `#e2e8f0` | Borders, dividers (slate-200) |
| `accent-gold` | `#f59e0b` | Highlights and decorative accents only — NOT for CTAs |
| `footer-dark` | `#1e293b` | Footer background (slate-800) |
| White | `#ffffff` | Primary surface |

### Removed Colors

- ~~Navy `#0a1628`~~ — too dark, doesn't match logo
- ~~Deep Blue `#1a3a6b`~~ — replaced by `primary`
- ~~Coral `#f97316`~~ — off-brand, removed

## Typography

- **Family**: Plus Jakarta Sans (variable, weights 400–800)
- **Headings**: weight 700–800, `text-heading`
- **Body**: weight 400–500, `text-body`

## CTA Hierarchy

1. **Primary CTA**: `bg-primary text-white` (blue button)
2. **Secondary CTA**: `bg-heading text-white` (dark button)
3. **Gold is accent only** — decorative highlights, step numbers, NOT buttons

## Surfaces

- Light mode only — no dark theme
- Hero sections: `bg-surface-blue` with dark text
- Alternating sections: `bg-white` / `bg-surface`
- Footer: `bg-footer-dark` with light text
