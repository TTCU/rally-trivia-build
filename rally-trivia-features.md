# Rally Trivia - Platform Features

## Live Game Experience

### Real-Time Team Play
Participants join events instantly using a short event code — no app download required. Teams submit answers from any device (phone, tablet, laptop) with real-time feedback on submission status.

### Host-Controlled Show Flow
Hosts manage the entire event from a dedicated console: start/stop rounds, control answer reveals, trigger breaks, and manage the pace of the show in real time.

### Live Scoreboard Display
A dedicated stage display shows live leaderboard rankings, team scores, and sponsor branding. Designed for projection on large screens with auto-updating scores and smooth animations.

### Answer Reveal Mode
Hosts reveal correct answers one question at a time with dramatic progression — perfect for building suspense and audience engagement during live events.

### Countdown Timers
Accessible, real-time countdown timers keep teams on track during timed rounds with visual and screen-reader-friendly announcements.

## Team Management

### Instant Join via QR Code
Teams scan a QR code or visit a short URL to join an event — no account creation needed. Credential sheets with team PINs can be printed and distributed at tables.

### Captain & Participant Roles
Each team has a captain PIN for submitting final answers and participant PINs for collaboration. Role-based access ensures only captains can lock in answers.

### Team Presence Tracking
See which teams are active, idle, or offline in real time. Helps hosts identify teams that may need assistance during the event.

## Judging & Scoring

### Judge Dashboard
Judges review and score submissions through a dedicated portal with keyboard shortcuts for rapid adjudication. Submissions are grouped by question for efficient batch scoring.

### Five Tie-Breaking Strategies
Configurable tie-breaking rules ensure fair outcomes: shared rank, speed-based, registration order, round-by-round comparison, or combined strategies with fallback chains.

### Immutable Scoring
Once a submission is locked and adjudicated, scores are final — no appeals, no exceptions. Every scoring decision is logged to an immutable audit trail for complete transparency.

### Partial Credit Support
Questions can be scored as correct, incorrect, or partial credit, giving judges flexibility for nuanced answers.

## Event Creation & Content

### AI Question Generation
Generate trivia questions using AI (GPT-4 and Claude) with customizable topics, difficulty levels, and question counts. AI-generated questions go through a review workflow before use.

### Fact-Check Verification
AI-generated questions pass through a Chain-of-Verification (CoVe) pipeline that checks answers for accuracy with supporting evidence before they enter your question bank.

### Reusable Question Bank
Build a library of vetted questions with full-text search, tags, difficulty ratings, and usage tracking. Import questions via CSV or create them manually.

### Event Templates
Save any event configuration as a reusable template. Clone events with pre-configured rounds, questions, scoring rules, and theme settings for recurring trivia nights.

### Multiple Question Types
Support for text-entry and multiple-choice questions with configurable point values per question.

## Branding & Customization

### Theme Studio
Customize the look of your event with color pickers, logo uploads, and five built-in presets. WCAG contrast checking ensures readability on stage displays.

### Sponsor Management
Showcase event sponsors with tiered display (Platinum, Gold, Silver, Bronze, Community). Sponsors appear in a weighted carousel on the scoreboard display.

### Sponsor Ticker
A scrolling chyron-style ticker displays sponsor names and messages on the scoreboard — configurable by the host in real time.

### Custom Domain Support
Run your trivia platform on your own domain with HTTPS, custom subdomains for each portal, and automatic SSL certificate provisioning.

## Administration

### Event Lifecycle Management
Full control over event states: draft, open for registration, in progress, completed, or cancelled. Round-level controls for opening, closing, and revealing answers.

### Analytics Dashboard
Post-event analytics including question difficulty analysis, round averages, judging latency metrics, and team performance breakdowns.

### Report Export
Export event results, analytics, and audit trails as CSV or formatted HTML reports for stakeholders and record-keeping.

### Audit Trail
Every action — team joins, answer submissions, judge decisions, score changes, admin actions — is recorded in an immutable audit log with timestamps and actor identification. Export audit data as CSV with date and action filters.

### Anti-Cheating Detection
Automated integrity monitoring using text similarity analysis (Jaccard), typing pattern detection, and device fingerprinting. Security alerts surface suspicious activity for judge review.

## Technical Platform

### Cross-Platform Access
Participants play from any device with a web browser. Native iOS and Android apps available for an enhanced mobile experience with deep linking support.

### Adaptive Polling
Clients automatically adjust their polling frequency based on game state — faster during active rounds, slower during breaks — reducing server load while keeping data fresh.

### Real-Time Performance Monitoring
Built-in observability dashboard showing P50/P95 response times, cold start metrics, and resource utilization for production reliability.

### Scalable Cloud Infrastructure
Built on Azure with serverless compute, managed database, and global CDN. Designed to handle hundreds of concurrent participants without performance degradation.

### Role-Based Authentication
Microsoft Entra ID (Azure AD) authentication for admins, judges, and hosts with granular role-based access control. Participant authentication via short-lived JWT tokens.
