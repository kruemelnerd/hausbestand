---
phase: 03-quality-und-security-pipeline
plan: 02
subsystem: infra
tags: [renovate, github-api, branch-protection, required-checks]

# Dependency graph
requires:
  - phase: 03-quality-und-security-pipeline (plan 01)
    provides: security workflow job names and required check contexts
provides:
  - repo-wide Renovate policy with 7-day release-age delay
  - versioned branch-protection payload for main
  - applied required-status checks on the canonical branch
affects: [main branch merges, dependency automation, future CI gates]

# Tech tracking
tech-stack:
  added: [Renovate config, GitHub branch-protection API payload]
  patterns: [versioned merge gates, minimum-release-age dependency policy]

key-files:
  created:
    - renovate.json
    - .github/branch-protection/main.json
  modified: []

key-decisions:
  - "Renovate stays on config:best-practices with no automerge and a single 7-day minimum release age rule for npm and Maven."
  - "Branch protection is stored as JSON in the repo and applied via gh api so the merge gate is reproducible."

patterns-established:
  - "Pattern 1: Canonical branch policy is versioned alongside workflow config, not only documented."
  - "Pattern 2: Required checks for main mirror the stable CI/security job names exactly."

requirements-completed: [FND-04]

# Metrics
duration: 4m
completed: 2026-05-22
---

# Phase 03: Quality- und Security-Pipeline Summary

**Renovate age-gated dependency updates and versioned main-branch protection now make the phase-3 quality/security checks enforceable**

## Performance

- **Duration:** 4m
- **Started:** 2026-05-22T07:35:44Z
- **Completed:** 2026-05-22T07:39:35Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments
- Added a repo-local Renovate policy that slows npm and Maven updates until they are at least 7 days old.
- Stored the `main` branch-protection payload in the repo and applied it through the GitHub API.
- Locked the required checks to the stable CI/security contexts so merges cannot bypass failing gates.

## task Commits

1. **task 1: Renovate-Policy mit 7-Tage-Mindestalter fuer npm und Maven anlegen** - `4d859a3` (chore)
2. **task 2: Deklarative Branch-Protection fuer `main` versionieren und per GitHub CLI anwenden** - `c251dcd` (chore)

**Plan metadata:** `c251dcd` (docs: complete plan)

## Files Created/Modified
- `renovate.json` - Renovate base policy with a 7-day release-age rule.
- `.github/branch-protection/main.json` - Versioned protection payload for `main`.

## Decisions Made
- Kept Renovate intentionally small and policy-only: no automerge, no scheduling extras, no phase-4-specific rules.
- Used required status checks that match the stable CI and security job names exactly.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
- GitHub accepted the branch-protection payload and enforced the required checks, but normalized `allow_fork_syncing` to `false` for the unlocked branch.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- `main` now blocks merges unless quality and security checks pass.
- Dependency updates are slowed by a repo-owned Renovate rule, reducing update noise for future phases.

---
*Phase: 03-quality-und-security-pipeline*
*Completed: 2026-05-22*

## Self-Check: PASSED

- Found `renovate.json`
- Found `.github/branch-protection/main.json`
- Found commit `4d859a3`
- Found commit `c251dcd`
