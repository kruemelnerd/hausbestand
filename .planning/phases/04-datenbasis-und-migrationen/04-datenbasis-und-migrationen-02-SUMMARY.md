---
phase: 04-datenbasis-und-migrationen
plan: 02
subsystem: ui
tags: [vue, vite, playwright, proxy, docker-compose, spring-boot, e2e]

# Dependency graph
requires:
  - phase: 04-datenbasis-und-migrationen-01
    provides: backend status contract, compose baseline, verified PostgreSQL startup
  - phase: 02-basis-ci
    provides: Vue/Vite shell and the mobile Playwright baseline
provides:
  - Frontend reachability UI for backend/database status
  - Local Vite `/api` proxy to Spring Boot
  - Playwright bootstrapper for compose + backend + frontend
  - Mobile E2E proof of the full stack path
affects: [frontend, testing, phase-05]

# Tech tracking
tech-stack:
  added: [typed fetch helper, Vite dev proxy, Playwright webServer orchestration, Docker Compose bootstrapper]
  patterns: [loading/error/success UI states, self-starting multi-process E2E harness, narrow status contract consumption]

key-files:
  created: [frontend/src/system-status.ts, frontend/tests/e2e/system-status.spec.ts, frontend/tests/e2e/start-system-status-stack.mjs]
  modified: [frontend/src/App.vue, frontend/vite.config.ts, frontend/playwright.config.ts]

key-decisions:
  - "Fetch the backend readiness contract through a typed helper so the UI stays aligned with the narrow API shape."
  - "Keep the Vite proxy limited to `/api` on `127.0.0.1:8080` instead of embedding cross-origin workarounds in the Vue code."
  - "Let Playwright bootstrap the local stack itself so the phase-4 E2E proof remains reproducible from one command."

patterns-established:
  - "Pattern 1: Start pages show explicit loading, error and success states for backend reachability checks."
  - "Pattern 2: E2E runs own the local stack bootstrap instead of assuming a manual pre-started backend."

requirements-completed: [FND-02]

# Metrics
duration: 6min
completed: 2026-05-22
---

# Phase 04 Plan 02: Reachability UI and E2E Summary

**Home page reachability badge with a self-starting Playwright stack that proves frontend, backend and database connectivity**

## Performance

- **Duration:** 6 min
- **Started:** 2026-05-22T10:15:57Z
- **Completed:** 2026-05-22T10:22:10Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments
- Vue home screen now surfaces real backend/database reachability with loading and error states
- Vite proxies `/api` to the Spring Boot backend in local development
- Playwright boots compose + backend + frontend and verifies the visible reachability path on mobile

## task Commits

Each task was committed atomically:

1. **task 1: Startseite um echte Backend-/Datenbank-Reachability erweitern** - `5e36717` (feat)
2. **task 2: Phase-4-E2E fuer den Gesamtstack automatisieren** - `e429253` (feat)

**Plan metadata:** pending final docs commit

## Files Created/Modified
- `frontend/src/system-status.ts` - typed status fetch helper
- `frontend/src/App.vue` - visible loading/error/success reachability UI
- `frontend/vite.config.ts` - local `/api` proxy to Spring Boot
- `frontend/playwright.config.ts` - webServer orchestration for full-stack E2E
- `frontend/tests/e2e/system-status.spec.ts` - phase-4 reachability regression
- `frontend/tests/e2e/start-system-status-stack.mjs` - compose/backend/frontend bootstrapper

## Decisions Made
- Used a small typed client helper instead of inlining fetch logic in the view.
- Let the Playwright config own the stack bootstrap so the test can run end-to-end without manual preconditions.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Phase-4 E2E needed a self-starting local stack**
- **Found during:** task 2 (Phase-4-E2E fuer den Gesamtstack automatisieren)
- **Issue:** The new Playwright regression could not prove reachability without PostgreSQL/Mailpit and backend startup being orchestrated locally.
- **Fix:** Added a Playwright webServer bootstrapper that brings up Compose, Spring Boot and Vite before the test runs.
- **Files modified:** `frontend/playwright.config.ts`, `frontend/tests/e2e/start-system-status-stack.mjs`
- **Verification:** `CI=true npm run test:e2e -- system-status.spec.ts`
- **Committed in:** `e429253` (task 2 commit)

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** The fix was required for correctness and reproducible execution; no scope creep beyond the phase contract.

## Issues Encountered
- A stale Vite process briefly held port 4173 during local verification; it was stopped before the fresh E2E run.

## Known Stubs
- `frontend/src/App.vue:87-96` - navigation buttons still intentionally read as future placeholders (`demnaechst`); they remain by design and do not block the system-status goal.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- The browser-facing readiness path is now verified end-to-end.
- Later feature phases can build on a stable status contract and stack bootstrap pattern.

## Self-Check: PASSED

---
*Phase: 04-datenbasis-und-migrationen*
*Completed: 2026-05-22*
