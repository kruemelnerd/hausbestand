---
phase: 2
slug: basis-ci
status: draft
nyquist_compliant: true
wave_0_complete: true
created: 2026-05-22
---

# Phase 2 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | JUnit 5 + Spring Boot Test, Playwright |
| **Config file** | `backend/pom.xml`, `frontend/playwright.config.ts` |
| **Quick run command** | `cd backend && ./mvnw test && cd ../frontend && npm run build && npm run test:e2e` |
| **Full suite command** | `cd backend && ./mvnw verify && cd ../frontend && npm run build && npm run test:e2e` |
| **Estimated runtime** | ~120 seconds |

---

## Sampling Rate

- **After every task commit:** Run `cd backend && ./mvnw test` or the task-specific frontend check.
- **After every plan wave:** Run `cd backend && ./mvnw verify && cd ../frontend && npm run build && npm run test:e2e`
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 120 seconds

---

## Per-task Verification Map

| task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 02-01-01 | 01 | 1 | FND-03 | T-02-01 / T-02-02 | Backend build inputs are pinned to Maven wrapper + Java 21 | integration | `cd backend && ./mvnw test` | ✅ | ⬜ pending |
| 02-01-02 | 01 | 1 | FND-03 | T-02-01 | Backend package step succeeds without extra services | build | `cd backend && ./mvnw package -DskipTests` | ✅ | ⬜ pending |
| 02-02-01 | 02 | 2 | FND-03 | T-02-03 | Playwright runs in CI mode without leaking local-only assumptions | e2e | `cd frontend && npm run test:e2e` | ✅ | ⬜ pending |
| 02-02-02 | 02 | 2 | FND-03 | T-02-04 / T-02-05 | CI workflow executes frontend, backend and E2E jobs with caches and artifacts | config | `node "$HOME/.config/opencode/get-shit-done/bin/gsd-tools.cjs" verify plan-structure .planning/phases/02-basis-ci/02-02-PLAN.md` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Existing infrastructure covers all phase requirements.

---

## Manual-Only Verifications

All phase behaviors have automated verification.

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 120s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
