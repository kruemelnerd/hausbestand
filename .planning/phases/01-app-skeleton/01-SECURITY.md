---
phase: 01
slug: app-skeleton
status: verified
threats_open: 0
asvs_level: 1
created: 2026-05-22
---

# Phase 01 - Security

> Per-phase security contract: threat register, accepted risks, and audit trail.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| Browser -> Frontend Runtime | Untrusted client environment renders UI and can manipulate local state. | Static, non-sensitive start-page markup only |

---

## Threat Register

| Threat ID | Category | Component | Disposition | Mitigation | Status |
|-----------|----------|-----------|-------------|------------|--------|
| T-01-01 | T (Tampering) | App shell markup | mitigate | `frontend/src/App.vue:15-24` keeps placeholder navigation non-functional via disabled buttons with `aria-disabled="true"`; no active routes or handlers are present. | closed |
| T-01-02 | I (Information Disclosure) | Start page content | accept | Accepted for phase 01 because `frontend/src/App.vue:1-27` renders only static, non-sensitive placeholder content with no backend integration or user data exposure. | closed |

*Status: open / closed*
*Disposition: mitigate (implementation required) / accept (documented risk) / transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-01 | T-01-02 | Accepted for phase 01 app-skeleton. The start page contains only static, non-sensitive placeholder content, has no backend integration, and exposes no user or operational data. Residual risk is low and will be re-evaluated when dynamic data or API integration is introduced. | Security audit workflow | 2026-05-22 |

Accepted risks do not resurface in future audit runs.

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-05-22 | 2 | 2 | 0 | OpenCode + gsd-security-auditor |

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-05-22
