---
phase: 3
slug: quality-und-security-pipeline
status: draft
nyquist_compliant: true
wave_0_complete: true
created: 2026-05-22
---

# Phase 3 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Playwright, Spring Boot Test, GitHub Actions config, GitHub CLI |
| **Config file** | `frontend/playwright.config.ts`, `backend/pom.xml`, `.github/workflows/security.yml`, `renovate.json` |
| **Quick run command** | `cd frontend && npm run build && npm run test:e2e && cd ../backend && ./mvnw test` |
| **Full suite command** | `cd frontend && npm run build && npm run test:e2e && cd ../backend && ./mvnw test && gh api repos/kruemelnerd/hausbestand/branches/main/protection --jq '.required_status_checks.contexts'` |
| **Estimated runtime** | ~150 seconds |

---

## Sampling Rate

- **After every task commit:** Run the task-specific automated command from the PLAN.
- **After every plan wave:** Run `cd frontend && npm run build && npm run test:e2e && cd ../backend && ./mvnw test`
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 150 seconds

---

## Per-task Verification Map

| task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 03-01-01 | 01 | 1 | FND-04 | T-03-01 / T-03-02 | Existing app-shell contract remains visible and non-interactive while the regression suite grows | e2e | `cd frontend && npm run test:e2e -- navigation-placeholders.spec.ts` | ✅ | ⬜ pending |
| 03-01-02 | 01 | 1 | FND-04 | T-03-03 / T-03-04 | PRs run dependency review plus high-severity repo security scans that fail closed | config | `test -f .github/workflows/security.yml && test -f .github/dependency-review-config.yml` | ✅ | ⬜ pending |
| 03-02-01 | 02 | 2 | FND-04 | T-03-05 | Renovate delays dependency PRs by 7 days for npm and maven updates | config | `test -f renovate.json && grep -q 'minimumReleaseAge' renovate.json` | ✅ | ⬜ pending |
| 03-02-02 | 02 | 2 | FND-04 | T-03-06 / T-03-07 | `main` blocks merge unless quality + security contexts pass | integration | `gh api repos/kruemelnerd/hausbestand/branches/main/protection --jq '.required_status_checks.contexts'` | ✅ | ⬜ pending |

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
- [x] Feedback latency < 150s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
