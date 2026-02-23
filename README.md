<p align="center">
  <img src="assets/images/RallyTrivia_logo_primary_transparent.png" alt="Rally Trivia Logo" width="300" />
</p>

<p align="center">
  <strong>The platform behind modern trivia nights.</strong>
</p>

---

## Overview

This repository contains the marketing site and public web presence for **Rally Trivia**.

Rally Trivia is a live trivia management platform built for nonprofit fundraisers and corporate events. This site serves as:

- The primary product landing page
- Brand home for Rally Trivia
- Entry point for demos, inquiries, and onboarding

This repository does **not** contain the application backend or event runtime code. It is dedicated to the public-facing website.

---

## Tech Stack

- **Astro 5** — Static-first site generation
- **TypeScript**
- **Tailwind CSS v4** — via `@tailwindcss/vite`
- **Cloudflare Workers** — Edge hosting with static assets + Worker API
- **Resend** — Transactional email delivery
- **Cloudflare Turnstile** — Spam protection on contact form
- **Google Analytics 4** + **Cloudflare Web Analytics** — Dual analytics

---

## Local Development

### Prerequisites

- Node.js 20+
- npm
- Cloudflare Wrangler CLI (for Worker development and deployment)

Install dependencies:

```bash
npm install
```

Run locally (starts both Astro dev server and Wrangler Worker):

```bash
npm run dev
```

The site will be available at `http://localhost:4321` and the Worker API at `http://localhost:8787`.

---

## Project Structure

```
.
├── assets/images/        # Logo and brand images
├── public/               # Static assets
├── src/
│   ├── components/       # Reusable UI components (Nav, Footer, Analytics, ContactForm, etc.)
│   ├── layouts/          # Page layout wrappers
│   ├── pages/            # Astro routes (index, features, about, contact)
│   ├── styles/           # Global styles
│   └── worker/           # Cloudflare Worker (API endpoints)
├── wrangler.jsonc        # Cloudflare Worker configuration
├── astro.config.mjs
├── package.json
└── README.md
```

---

## Deployment

Rally Trivia is deployed via Cloudflare Workers with static assets.

Build the site:

```bash
npm run build
```

Deploy:

```bash
wrangler deploy
```

### Required Secrets

Set these via `wrangler secret put <NAME>`:

| Secret | Purpose |
|--------|---------|
| `RESEND_API_KEY` | Resend API key for email delivery |
| `TURNSTILE_SECRET_KEY` | Cloudflare Turnstile server-side secret |
| `RECIPIENT_EMAIL` | Email address that receives demo requests |

---

## Brand

Rally Trivia is positioned as:

- Clean and modern
- Event-grade
- Confident
- Nonprofit and corporate ready
- Infrastructure-backed but approachable

Primary colors:

- Navy (`#0a1628`)
- Deep blue (`#1a3a6b`)
- Electric blue (`#2563eb`)
- Gold (`#f59e0b`)
- Coral (`#f97316`)

Logo assets live in `assets/images/`.

---

## License

Proprietary — Rally Trivia
All rights reserved.
