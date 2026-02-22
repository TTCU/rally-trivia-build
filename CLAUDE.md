# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Rally Trivia marketing site and public web presence. This repo is for the public-facing website only — not the application backend or event runtime.

## Tech Stack

- **Astro** — Static-first site generation
- **TypeScript**
- **Tailwind CSS**
- **Cloudflare Pages / Workers** — Hosting and edge delivery

## Development Commands

```bash
npm install          # Install dependencies
npm run dev          # Start dev server (http://localhost:4321)
npm run build        # Production build (output: dist/)
wrangler deploy      # Deploy to Cloudflare Workers
```

## Architecture

This is an Astro static site deployed to Cloudflare's edge network. The planned structure follows Astro conventions:

- `src/pages/` — File-based routing
- `src/components/` — Reusable UI components
- `src/layouts/` — Page layout wrappers
- `src/styles/` — Global styles
- `public/` — Static assets served as-is
- `assets/images/` — Brand logos and icons (PNG + SVG)

## Brand Guidelines

- **Colors**: Navy, deep blue, electric blue accent
- **Tone**: Clean, modern, confident, approachable
- **Audience**: Nonprofit fundraisers and corporate events
- **License**: Proprietary — All rights reserved
