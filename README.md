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
- Future marketing and documentation hub
- Entry point for demos, inquiries, and onboarding

This repository does **not** contain the application backend or event runtime code. It is dedicated to the public-facing website.

---

## Tech Stack

The Rally Trivia website is built with:

- **Astro** — Static-first site generation
- **TypeScript**
- **Tailwind CSS**
- **Cloudflare Workers** — Deployment and edge delivery
- **Cloudflare Pages / Workers Runtime** — Production hosting

The architecture prioritizes:

- Performance
- Edge delivery
- Static-first rendering
- Minimal operational overhead

---

## Local Development

### Prerequisites

- Node.js 20+
- pnpm / npm / yarn
- Cloudflare Wrangler CLI (for deployment)

Install dependencies:

```bash
npm install
```

Run locally:

```bash
npm run dev
```

The site will be available at:

```
http://localhost:4321
```

---

## Project Structure

```
.
├── assets/
│   └── images/          # Logo and brand images
├── public/              # Static assets
├── src/
│   ├── components/      # Reusable UI components
│   ├── layouts/         # Page layouts
│   ├── pages/           # Astro routes
│   └── styles/          # Global styles
├── astro.config.mjs
├── package.json
└── README.md
```

---

## Deployment

Rally Trivia is deployed via Cloudflare.

### Option 1: Cloudflare Pages (Recommended)

1. Connect this repository to Cloudflare Pages.
2. Set build command:

```
npm run build
```

3. Set output directory:

```
dist
```

Cloudflare will handle edge deployment automatically.

---

### Option 2: Cloudflare Workers (Wrangler)

If deploying via Workers:

Install Wrangler:

```bash
npm install -g wrangler
```

Authenticate:

```bash
wrangler login
```

Build site:

```bash
npm run build
```

Deploy:

```bash
wrangler deploy
```

---

## Environment Variables

If needed, configure environment variables in:

- Cloudflare Pages dashboard
- Wrangler `wrangler.toml`

Example:

```
PUBLIC_SITE_URL=https://rallytrivia.com
```

---

## Roadmap

Future additions to this repository may include:

- Pricing pages
- Product feature deep dives
- Case studies
- Demo scheduling integration
- Analytics integration
- Blog / content marketing
- Authentication entry for event hosts
- API documentation surface

---

## Brand

Rally Trivia is positioned as:

- Clean and modern
- Event-grade
- Confident
- Nonprofit and corporate ready
- Infrastructure-backed but approachable

Primary colors:

- Navy
- Deep blue
- Electric blue accent

Logo assets live in:

```
/assets/images/
```

---

## License

Proprietary — Rally Trivia
All rights reserved.
