# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Rally Trivia marketing site and public web presence. This repo is for the public-facing website only — not the application backend or event runtime.

## Tech Stack

- **Astro 5** — Static-first site generation
- **TypeScript**
- **Tailwind CSS v4** — via `@tailwindcss/vite` plugin
- **Cloudflare Workers** — Edge hosting with static assets + Worker API
- **Resend** — Transactional email (contact form delivery)
- **Cloudflare Turnstile** — Spam protection
- **Google Analytics 4** + **Cloudflare Web Analytics** — Dual analytics
- **Motion** — Scroll-triggered animations

## Development Commands

```bash
npm install          # Install dependencies
npm run dev          # Start Astro + Wrangler concurrently (site: 4321, worker: 8787)
npm run build        # Production build (output: dist/)
wrangler deploy      # Deploy to Cloudflare Workers
```

## Architecture

Astro static site deployed to Cloudflare Workers. Static pages are built at compile time; a standalone Worker handles `/api/*` routes (contact form submission via Resend + Turnstile verification).

- `src/pages/` — File-based routing (index, features, about, contact)
- `src/components/` — UI components (Nav, Footer, ContactForm, Analytics, EventTracking, etc.)
- `src/layouts/` — BaseLayout with shared head, nav, footer, analytics
- `src/styles/` — Global CSS with Tailwind v4
- `src/worker/` — Cloudflare Worker entry point (`/api/contact` endpoint)
- `public/` — Static assets served as-is
- `assets/images/` — Brand logos and icons (PNG + SVG)

## Brand Guidelines

- **Colors**: Navy `#0a1628`, deep blue `#1a3a6b`, electric blue `#2563eb`, gold `#f59e0b`, coral `#f97316`
- **Tone**: Clean, modern, confident, approachable
- **Audience**: Nonprofit fundraisers and corporate events
- **License**: Proprietary — All rights reserved
