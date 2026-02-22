# Feature Research

**Domain:** SaaS marketing/landing site — live event trivia platform targeting nonprofit fundraisers and corporate events
**Researched:** 2026-02-22
**Confidence:** MEDIUM-HIGH (multiple sources verified; no A/B test data specific to trivia event niche)

---

## Feature Landscape

### Table Stakes (Users Expect These)

Features visitors assume exist on any credible SaaS product site. Missing these makes the site feel unfinished or untrustworthy.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Hero section with value proposition headline | Every SaaS site leads with a clear outcome-focused headline. Visitors leave within 10 seconds if they can't parse what the product does. | LOW | Headline must be outcome-driven ("Run a flawless trivia fundraiser") not feature-driven. Subheadline clarifies audience and mechanism. |
| Primary CTA — demo request | Nonprofit and corporate buyers don't self-serve; they need a sales touchpoint. "Request a Demo" is the expected conversion action. | LOW | CTA must appear above the fold and repeat at logical intervals. Button label matters — "Request a Demo" outperforms "Contact Us" for software. |
| Product/platform visuals | 30% of SaaS sites don't show the product — this is a conversion killer. Visitors need confidence before booking a demo. | MEDIUM | Screenshots, interface preview, or a short video clip. Does not need to be a full interactive demo at MVP. |
| Features page with platform capabilities | Buyers research before contacting sales. A dedicated features page is expected for any non-trivial SaaS product. | MEDIUM | Should address both nonprofit and corporate use cases. Tie features to outcomes, not technical specs. |
| Social proof — testimonials | 92% of buyers trust peer recommendations over advertising. Absence of testimonials reads as "no customers yet." | LOW | Even 2-3 quotes from real event organizers are enough at launch. Logos from recognizable orgs amplify trust. |
| About/story page | Buyers for nonprofit-sector software particularly want to understand the people and mission behind the product before entrusting events to it. | LOW | Who built this, why, what values drive it. Humanizes the product for relationship-oriented nonprofit buyers. |
| Contact/demo request form | Required to capture inbound interest. Form is the conversion endpoint for the entire site. | LOW | Fields: name, email, organization, role, message. Keep to 5 fields max — more fields = lower conversion. |
| Responsive design (mobile, tablet, desktop) | 83% of web visits are mobile. Non-responsive site signals neglect and directly harms bounce rate. | MEDIUM | Tailwind CSS makes this achievable with good discipline. Test at common breakpoints. |
| Shared navigation and footer | Visitors need to find their way around. Lack of consistent nav erodes professionalism. | LOW | Nav: Home, Features, About, Contact/Demo. Footer: same links + any legal, social links. |
| Brand-consistent design | Inconsistent branding destroys trust signals and makes product look unfinished. | LOW | Navy/deep blue/electric blue palette applied consistently. Logo present in header. |

### Differentiators (Competitive Advantage)

Features that set Rally Trivia's site apart from generic event platform competitors. Prioritize those that speak directly to nonprofit fundraiser and corporate event planner needs.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Dual audience messaging — nonprofit vs. corporate | Competitors pick one segment; Rally serves both. Showing clear use cases for each audience reduces bounce and improves relevance. | MEDIUM | Can be done on a single landing page via distinct use-case sections or tabs. "Fundraiser nights" framing for nonprofits vs. "team building" framing for corporate. Separate sections, not separate sites, at MVP. |
| Pain-point-first messaging for event organizers | Most event platform sites lead with features; leading with the actual frustrations (chaotic scorekeeping, dead silence between rounds, no way to collect donations mid-game) creates immediate recognition. | LOW | Requires good copy. Research confirms outcome-driven messaging outperforms feature-focused. This is copy/content effort, not engineering. |
| "How it works" section with clear step-by-step flow | Event organizers want to visualize the night before they commit. A simple 3-step visual (Setup → Run Event → Collect Results) dramatically reduces objection anxiety. | LOW | Static illustrated steps are sufficient at MVP. Animated or interactive version is a v1.x upgrade. |
| Specific event type callouts | "Trivia Fundraiser Night," "Corporate Game Night," "Team-Building Trivia" as named use cases. Specificity converts better than generic "events" language because it mirrors how buyers search and think. | LOW | Content/copy effort. Can be accomplished with a use-cases section or cards on the homepage. |
| Quantified social proof | "Raised $12K in one night" or "200 teams played, zero tech issues" lands harder than generic praise. Event organizers are results-focused; numbers build credibility fast. | MEDIUM | Requires real data from existing events. If Rally Trivia has run any events, gather stats. If not, qualitative quotes work at launch — defer quantified stats to v1.x. |
| Nonprofit-specific trust signals | Nonprofit event coordinators are skeptical of vendor churn and want to know the platform understands their constraints (limited budget, volunteer staff, mission alignment). Including language like "built for fundraisers" or mission-aligned copy differentiates from generic corporate event tools. | LOW | Copy effort. Could include a dedicated nonprofit section or callout block. |
| Clear demo value framing | Most "Book a Demo" pages don't explain what the demo includes. Stating "30-minute walkthrough, no sales pressure, see the host dashboard live" reduces booking friction for time-scarce nonprofit staff. | LOW | One paragraph of copy on the contact/demo page explaining what happens after you submit. |

### Anti-Features (Commonly Requested, Often Problematic)

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Pricing page | Users often ask "how much does it cost?" and a pricing page feels like transparency. | Rally Trivia is not ready to publish pricing. Publishing placeholder pricing creates wrong expectations; hiding it with "Contact for pricing" on a dedicated pricing page highlights the absence. | Acknowledge pricing on the demo request page: "Pricing is tailored to your event size — we'll walk you through options on the demo." This deflects without a dedicated page. |
| Blog / content marketing section | Provides SEO value long-term; stakeholders often push for this early. | Requires ongoing content investment to not look dead. A blog with 0–2 posts looks worse than no blog. Distraction from core conversion goal at this stage. | Defer entirely. Add blog infrastructure in v2 once site is validated and content production is resourced. |
| Live chat widget | Feels like a good conversion tool; shows responsiveness. | At launch with an unvalidated audience, adds operational overhead with minimal payoff. Intrusive pop-up chat reduces perceived professionalism on B2B sites targeting nonprofit coordinators. | Demo request form is sufficient. Add chat tool after launch when volume justifies it. |
| Video autoplay in hero | Demos the product immediately; feels engaging. | Autoplaying video with audio is a well-documented conversion killer — users feel ambushed and bounce. Silent autoplay is acceptable but adds complexity. | Embed a click-to-play video thumbnail in the features section, or a short animated screen recording in the hero. Always user-initiated. |
| Complex multi-step demo request form | Feels like better lead qualification — capture company size, event type, budget. | Conversion rates drop sharply past 5 fields. For a small-scale B2B, every lead is precious. Over-qualifying at the form stage loses warm prospects. | 5 fields max (name, email, org, role, message). Qualify leads through the actual demo conversation. |
| Calendly/scheduling embed on contact page | Eliminates back-and-forth scheduling friction. | Forces a decision point on calendar visibility that may not be ready to support. Creates awkward experience if calendar is sparse or if the tool isn't yet configured. Explicitly noted as out of scope in PROJECT.md. | Simple form collects the request; follow-up scheduling handled manually until volume justifies automation. |
| Analytics dashboard / event stats page | Some visitors want to see platform analytics as proof of scale. | Not relevant to a marketing site. Belongs in the app itself. Adding it to the marketing site blurs the boundary and adds scope. | Reference capabilities ("real-time leaderboards," "post-event reports") in features copy; show screenshots. Do not build a live stats component on the marketing site. |

---

## Feature Dependencies

```
[Hero CTA — "Request Demo"]
    └──requires──> [Demo Request Form] (form is the destination of CTA)
                       └──requires──> [Thank-you / confirmation state] (visitor needs feedback after submit)

[Social Proof — Testimonials]
    └──enhances──> [Hero section] (placed immediately below hero for max impact)
    └──enhances──> [Demo Request Form] (near CTA to reduce last-mile anxiety)

[Features Page]
    └──requires──> [Navigation] (must be reachable from nav)
    └──enhances──> [Hero CTA] (features page deepens the case started by hero)

[Dual Audience Messaging]
    └──requires──> [Features Page or Homepage Use-Cases Section] (segmentation needs a content container)

[About Page]
    └──enhances──> [Trust / Credibility] (supports conversion but not gating anything)

[Product Visuals / Screenshots]
    └──enhances──> [Features Page] (makes features tangible)
    └──enhances──> [Hero section] (reduces "what is this?" skepticism)

[Quantified Social Proof (stats)]
    └──requires──> [Real event data exists] (cannot be invented; defer until data available)
    └──enhances──> [Social Proof — Testimonials]
```

### Dependency Notes

- **Demo Request Form requires a post-submit state:** Without a confirmation message or redirect, users don't know if their submission worked. A simple "Thanks, we'll be in touch within 1 business day" is sufficient at MVP.
- **Social proof enhances Hero:** Industry data shows placing testimonials immediately below the hero section lifts conversions versus putting them further down the page. Placement is a design decision that matters.
- **Quantified stats require real data:** Do not fabricate or estimate metrics. If Rally Trivia has hosted events, gather real numbers before launch. If not, qualitative testimonials are sufficient and honest.
- **Dual audience messaging requires a content container:** This can be a homepage section (use-case cards: "For Nonprofits" | "For Corporate Events") rather than a full separate page, which is lower complexity and sufficient at MVP.

---

## MVP Definition

### Launch With (v1)

Minimum needed to convert event organizers into demo requests.

- [ ] **Hero section** — Outcome-focused headline, subheadline, primary "Request a Demo" CTA, product visual or screenshot
- [ ] **Value proposition / pain points section** — 3–4 specific problems Rally Trivia solves for event organizers
- [ ] **Features overview section** — Key platform capabilities tied to outcomes, not just feature names
- [ ] **Dual audience callout** — Brief "For Nonprofits" and "For Corporate Events" framing, even if just 2 cards
- [ ] **Social proof block** — 2–3 testimonials with name, org, role; placed near hero and near demo CTA
- [ ] **"How it works" section** — 3-step visual (Setup → Run Event → See Results / Collect Donations)
- [ ] **Demo request form** — 5 fields: name, email, org, role, message. Post-submit confirmation state.
- [ ] **About/Story page** — Who built Rally Trivia, why it exists, values
- [ ] **Features page** — Detailed breakdown of platform capabilities with nonprofit and corporate context
- [ ] **Shared nav and footer** — Logo, page links, contact link
- [ ] **Responsive design** — Mobile, tablet, desktop

### Add After Validation (v1.x)

Features to add once the site is live and receiving traffic.

- [ ] **Quantified social proof** — Add real stats from events once Rally Trivia has run them ("Teams served," "Funds raised via trivia," etc.)
- [ ] **Analytics integration** — Add GA4 or Cloudflare analytics to understand traffic sources and conversion paths
- [ ] **Form backend wiring** — Connect demo request form to email delivery (currently UI-only per PROJECT.md)
- [ ] **Interactive "how it works" animation** — Upgrade static steps to subtle scroll-triggered animation
- [ ] **Video demo embed** — Click-to-play walkthrough in features section once a quality recording exists

### Future Consideration (v2+)

Defer until product-market fit is established and site is validated.

- [ ] **Blog / content marketing** — SEO long-game; defer until content resources are available and core site is optimized
- [ ] **Calendly or scheduling embed** — Add once scheduling workflow is established and volume justifies it
- [ ] **Pricing page** — Add when Rally Trivia is ready to publish pricing publicly
- [ ] **Case studies with detailed ROI** — Full written case studies with quantified fundraising outcomes; requires relationship with event organizer clients
- [ ] **Audience-specific landing pages** — Dedicated "Nonprofits" and "Corporate" sub-pages for SEO targeting once base site has traction

---

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Hero section with CTA | HIGH | LOW | P1 |
| Demo request form | HIGH | LOW | P1 |
| Features page | HIGH | MEDIUM | P1 |
| Social proof (testimonials) | HIGH | LOW | P1 |
| Responsive design | HIGH | MEDIUM | P1 |
| Shared nav + footer | HIGH | LOW | P1 |
| Product visuals / screenshots | HIGH | LOW | P1 |
| About/Story page | MEDIUM | LOW | P1 |
| Pain-point-first messaging (copy) | HIGH | LOW | P1 |
| Dual audience callout section | MEDIUM | LOW | P1 |
| "How it works" section | MEDIUM | LOW | P1 |
| Post-submit confirmation state | MEDIUM | LOW | P1 |
| Form backend wiring | HIGH | MEDIUM | P2 |
| Analytics integration | MEDIUM | LOW | P2 |
| Quantified social proof (stats) | HIGH | LOW (if data exists) | P2 |
| Click-to-play video demo | MEDIUM | MEDIUM | P2 |
| Animated "how it works" steps | LOW | MEDIUM | P3 |
| Blog / content marketing | MEDIUM | HIGH (ongoing) | P3 |
| Pricing page | MEDIUM | LOW | P3 |
| Calendly integration | LOW | LOW | P3 |
| Audience-specific sub-pages | MEDIUM | HIGH | P3 |

**Priority key:**
- P1: Must have for launch
- P2: Should have, add when possible
- P3: Nice to have, future consideration

---

## Competitor Feature Analysis

| Feature | Crowdpurr | SocialPoint | Rally Trivia Approach |
|---------|-----------|-------------|----------------------|
| Hero with value prop | "Add fun to your events" — clear but generic | "Audience Engagement Platform" — abstract | Be specific: "Live Trivia for Fundraisers and Team Events" — names the use case immediately |
| Product visuals | Strong — shows 3 interface views (host, projector, participant) | Moderate — describes features | Show real interface: host dashboard, leaderboard display, participant view |
| Social proof placement | Strong — Fortune 500 logos, G2 rating badge, testimonials | Moderate — client logos, case studies | Prioritize nonprofit org names + quotes over Fortune 500 since audience is nonprofits |
| Dual audience targeting | Weak — positions as general events, not specific nonprofit/corporate | Weak — trade show and events focus | Explicit sections: "For Fundraisers" and "For Corporate Events" |
| Demo request | "Book a Demo" CTA present | Demo request present | Keep it simple; add copy explaining what happens on the demo ("30-minute walkthrough") |
| Pricing transparency | Present (freemium model visible) | Present | Defer pricing page; acknowledge pricing in demo context |
| How it works | Not prominent | Not prominently featured | Make it prominent — event organizers need to visualize the night |
| About/story | Minimal | Minimal | Differentiator opportunity — mission-aligned story resonates with nonprofit buyers |

---

## Sources

- [SaaS Landing Pages Best Practices 2026 — Storylane](https://www.storylane.io/blog/saas-landing-pages-best-practices) (MEDIUM confidence — industry blog, well-sourced)
- [10 SaaS Landing Page Trends for 2026 — SaaSFrame](https://www.saasframe.io/blog/10-saas-landing-page-trends-for-2026-with-real-examples) (MEDIUM confidence)
- [51 High-Converting SaaS Landing Pages — KlientBoost](https://www.klientboost.com/landing-pages/saas-landing-page/) (MEDIUM confidence — practitioner analysis)
- [7 Ways to Add Social Proof to B2B SaaS Landing Pages — LandingRabbit](https://landingrabbit.com/blog/social-proof) (MEDIUM confidence)
- [Demo Form Conversion Rate Benchmark Report 2025 — Chili Piper](https://www.chilipiper.com/post/form-conversion-rate-benchmark-report) (MEDIUM confidence — vendor data, directionally reliable)
- [B2B SaaS Demo Form Best Practices — Metaforms AI](https://metaforms.ai/blog/b2b-saas-demo-form) (LOW confidence — single practitioner source)
- [Crowdpurr Live Trivia Platform](https://www.crowdpurr.com/) — direct competitor analysis (HIGH confidence — primary source)
- [SocialPoint Audience Engagement Platform](https://www.socialpoint.io/) — adjacent competitor analysis (HIGH confidence — primary source)
- [Trivia Night Fundraisers Ultimate Guide — Donorbox](https://donorbox.org/nonprofit-blog/trivia-night-fundraisers) (MEDIUM confidence — nonprofit practitioner source)
- [SaaS Product Demo Video Examples — Supademo](https://supademo.com/blog/marketing/demo-video-examples/) (MEDIUM confidence)
- [20 Best B2B SaaS Landing Page Examples — Caffeine Marketing](https://www.caffeinemarketing.com/blog/20-best-b2b-saas-landing-page-examples) (MEDIUM confidence)

---
*Feature research for: Rally Trivia Marketing Site — SaaS landing page, live event trivia platform*
*Researched: 2026-02-22*
