<!-- GSD:project-start source:PROJECT.md -->
## Project

**HeizInventur**

HeizInventur ist eine mobile-first Webanwendung zur strukturierten Erfassung von Heizkoerpern und Fenstern auf Grundrissen in Mehrfamilienhaeusern. Admins bereiten Gebaeudestruktur und Grundrisse vor, Nutzer erfassen vor Ort Inventurdaten inkl. Pflichtfotos direkt am Marker. Ergebnis ist ein nachvollziehbarer Report- und Export-Output fuer einen Energieeffizienz-Experten.

**Core Value:** Technisch unerfahrene Nutzer koennen vor Ort schnell und verlaesslich vollstaendige Heizkoerper- und Fenster-Inventurdaten (inklusive Fotos und Markerposition) erfassen, sodass ein belastbarer Report ohne Nacharbeit entsteht.

### Constraints

- **Tech stack**: Frontend Vue 3/TypeScript, Backend Spring Boot Java 21, DB PostgreSQL - laut Technical Spec.
- **Execution model**: Phasenweise Umsetzung gemaess fachlichem Phasenplan, keine Vorwegnahme spaeterer Phasen.
- **Testing**: Pro Phase mindestens ein neuer E2E-Test plus gruen bleibende bestehende Unit/Integration/E2E-Tests.
- **Security**: Backend ist Source of Truth fuer Auth, Autorisierung, Validierung und Statusberechnung.
- **Storage**: Upload-Dateien im lokalen Dateisystem, DB speichert Metadaten statt BLOBs.
- **Operations**: Lokale Ausfuehrbarkeit ohne externe Cloud-Dienste ist Pflicht fuer v1.
<!-- GSD:project-end -->

<!-- GSD:stack-start source:research/STACK.md -->
## Technology Stack

## Recommended Stack
### Core Technologies
| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| Vue 3 + TypeScript + Vite | Vue 3.x, TS 5.x, Vite 7.x | Mobile-first SPA for guided onsite inventory capture | Practical DX, strong typing for form-heavy domain logic, fast iteration. Vue 2 is EOL; Vue 3 is the maintainable baseline. |
| Java 21 + Spring Boot | Java 21 LTS, Spring Boot 3.5.x | Secure backend API, auth, validation, file access control, report generation | Most maintainable path for strict backend source-of-truth rules (authz, status computation, upload validation). Spring Boot requires Java 17+, and Java 21 gives current LTS runway. |
| PostgreSQL | 17.x now, plan upgrade path to 18.x | Relational system of record for users, structure, markers, status, metadata | Best fit for hierarchical + transactional domain data; stable local Docker use now and straightforward production hardening later. |
| Local filesystem object storage (behind API) | Start local (`./data/uploads`), later S3-compatible (MinIO/S3) | Store floorplans/photos/reports as files; DB keeps metadata only | Matches local-first constraints while keeping the same logical storage contract for later deployment hardening. |
### Supporting Libraries
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Spring Security (session + HttpOnly cookies) | via Boot 3.5.x BOM | Authentication/authorization with server sessions | Use from day 1; do **not** defer. Required for approval workflow and secure file/report access. |
| Flyway | 10.x (via Boot-managed compatible version) | Versioned DB migrations | Mandatory from first persistent schema; guarantees reproducible environments and safe evolution. |
| Testcontainers | 1.20+ | Real PostgreSQL integration tests in CI/local | Use for all repository/integration tests where SQL behavior matters. |
| Playwright | 1.58.x | E2E tests for real user flows incl. mobile viewports | Required each phase (per spec); use device emulation and viewport assertions for marker stability. |
| Pinia | 3.x/4.x line compatible with Vue 3 | Client state management | Use for app/session/UI state; keep business truth in backend. |
| Vue Router | 4.x | Route orchestration for user/admin flows | Use for guided navigation and protected UX routes (comfort layer only). |
| Zod (frontend DTO validation mirror) | 3.x/4.x | Typed client-side input shaping before API calls | Use for UX feedback; backend Bean Validation remains authoritative. |
| Tailwind CSS + `@tailwindcss/vite` | Tailwind 4.x | Fast, consistent mobile-first UI styling | Use to keep form-heavy UI consistent and accessible with low CSS maintenance. |
| Mailpit (local SMTP sink) | latest stable | Local email confirmation testing | Use in local/dev CI profile; later swap SMTP transport config only. |
### Development Tools
| Tool | Purpose | Notes |
|------|---------|-------|
| Docker Compose | Local infra parity (Postgres + Mailpit + optional app services) | Keep local bootstrap one-command; mirror production service boundaries early. |
| GitHub Actions | CI gates for build/test/security | Enforce phase gate quality with backend tests + Playwright + dependency/security checks. |
| Renovate | Controlled dependency updates | Keep `minimumReleaseAge: 7 days`; security fixes can bypass normal delay policy. |
## Installation
# Frontend core
# Frontend dev
# Backend (Maven)
# Use Spring Initializr dependencies:
# spring-boot-starter-web
# spring-boot-starter-security
# spring-boot-starter-validation
# spring-boot-starter-data-jpa
# spring-boot-starter-mail
# postgresql
# flyway-core
# spring-boot-starter-test
# testcontainers-postgresql
## Alternatives Considered
| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| Vue 3 + Vite | React + Next.js | Use if SSR/SEO/public marketing pages are first-class product requirements. For this authenticated workflow app, Vue SPA is simpler and lower-ops. |
| Spring Boot (session auth) | Node/NestJS | Use only if team is predominantly TS backend and accepts rebuilding security/reporting conventions. Current specs and maintainability favor Spring. |
| PostgreSQL + file metadata | Full BLOB storage in DB | Use BLOB-in-DB only for strict single-backup simplicity in very small datasets; here photo-heavy scale and export/report workload favor file/object storage. |
| Local filesystem first | Immediate cloud object storage | Use immediate cloud only if local-only operation is not required. Here local-first is explicit requirement. |
## What NOT to Use
| Avoid | Why | Use Instead |
|-------|-----|-------------|
| Vue 2 / Vue CLI legacy stack | Vue 2 is EOL; long-term security/maintenance risk | Vue 3 + Vite |
| JWT in LocalStorage for this app | Higher XSS blast radius and unnecessary complexity for same-origin web app | Server sessions + HttpOnly cookies |
| Direct browser access to upload folders | Breaks authorization boundary and auditability | Backend-gated file delivery endpoints |
| Storing original photos/reports as DB BLOBs initially | Expensive DB growth, slower maintenance/backups for media-heavy flows | Filesystem now, S3-compatible object storage later |
| Early microservices split | Adds ops complexity before domain stabilizes | Modular monolith (Spring modules + clear bounded packages) |
## Stack Patterns by Variant
- Use Postgres + Mailpit + local upload directory via Docker Compose.
- Because this gives full offline/local reproducibility and fastest iteration with realistic architecture boundaries.
- Keep API and DB model stable; replace storage adapter (local FS -> S3-compatible), tighten cookie/security settings, add observability and backups.
- Because this preserves domain code while hardening infra and operations incrementally.
## Version Compatibility
| Package A | Compatible With | Notes |
|-----------|-----------------|-------|
| Spring Boot 3.5.x | Java 17+ (recommend Java 21 LTS) | Prefer 3.5.x stable line now; evaluate Boot 4.x only after plugin/library readiness audit. |
| Vue 3.x | Vite 7.x, Vue Router 4.x, Pinia (Vue 3-compatible line) | Standard modern Vue stack; avoid mixing legacy Vue 2 ecosystem packages. |
| Tailwind 4.x | Vite via `@tailwindcss/vite` | Prefer official Vite plugin path for simpler config/perf. |
| Playwright 1.58.x | GitHub Actions Linux runners | Use device profiles + viewport assertions for marker rendering reliability. |
## Security and Testing Implications
- **Security baseline from phase 1:** backend-enforced authz, server-side validation, allowlist-based upload checks, randomized filenames, and non-public upload storage.
- **Session strategy:** HttpOnly cookies now; `Secure` + strict cookie attributes in production profile.
- **Testing strategy:** growing Playwright suite per phase + backend integration tests with Testcontainers + CI security gates (dependency, secret, vuln scans).
- **Hardening path:** keep same business interfaces; add object storage, backup/restore drills, centralized logging/metrics, and stricter transport/security headers.
## Migration Path (Local-First -> Production)
## Sources
- Context7 `/spring-projects/spring-boot` — system requirements (Java 17+), current version lines (incl. 3.5.x/4.x availability). **Confidence: HIGH**
- Context7 `/vuejs/core` and `/vuejs/vue` — Vue 3 as maintained line, Vue 2 EOL notice. **Confidence: HIGH**
- Context7 `/vitejs/vite` — current scaffolding and Node requirement guidance for modern Vite. **Confidence: HIGH**
- Context7 `/websites/postgresql_current` — current PostgreSQL docs stream and supported/stable version references (18 current, 17/16 stable). **Confidence: HIGH**
- Context7 `/microsoft/playwright.dev` — CI and mobile viewport testing practices. **Confidence: HIGH**
- Context7 `/tailwindlabs/tailwindcss.com` — Tailwind v4 + Vite plugin integration guidance. **Confidence: HIGH**
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

Conventions not yet established. Will populate as patterns emerge during development.
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

Architecture not yet mapped. Follow existing patterns found in the codebase.
<!-- GSD:architecture-end -->

<!-- GSD:skills-start source:skills/ -->
## Project Skills

No project skills found. Add skills to any of: `.OpenCode/skills/`, `.agents/skills/`, `.cursor/skills/`, or `.github/skills/` with a `SKILL.md` index file.
<!-- GSD:skills-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using edit, write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd-quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd-debug` for investigation and bug fixing
- `/gsd-execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->



<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd-profile-user` to generate your developer profile.
> This section is managed by `generate-OpenCode-profile` -- do not edit manually.
<!-- GSD:profile-end -->
