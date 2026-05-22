---
phase: 04-datenbasis-und-migrationen
plan: 01
subsystem: database
tags: [postgres, flyway, spring-boot, testcontainers, docker-compose, actuator, mailpit]

# Dependency graph
requires:
  - phase: 02-basis-ci
    provides: backend build/test plumbing and the existing app baseline
  - phase: 03-quality-und-security-pipeline
    provides: CI/security conventions that keep database work reproducible
provides:
  - Local PostgreSQL + Mailpit compose baseline
  - Versioned Flyway technical schema migration
  - Narrow `/api/system/status` backend readiness contract
  - Spring Boot integration proof against a real PostgreSQL container
affects: [phase-04-02, backend, database, testing]

# Tech tracking
tech-stack:
  added: [spring-boot-starter-data-jpa, spring-boot-starter-actuator, spring-boot-starter-mail, flyway-core, flyway-database-postgresql, org.postgresql:postgresql, org.testcontainers:junit-jupiter, org.testcontainers:postgresql, Docker Compose]
  patterns: [local-first infra via compose, narrow readiness DTO, Testcontainers-backed Spring smoke tests, versioned Flyway baseline migrations]

key-files:
  created: [docker-compose.yml, backend/src/main/resources/application.yml, backend/src/main/resources/db/migration/V1__baseline.sql, backend/src/main/java/de/heizinventur/backend/system/SystemStatusController.java, backend/src/main/java/de/heizinventur/backend/system/SystemStatusResponse.java, backend/src/test/java/de/heizinventur/backend/system/SystemStatusIntegrationTest.java]
  modified: [backend/pom.xml, backend/src/test/java/de/heizinventur/backend/HeizInventurApplicationTests.java]

key-decisions:
  - "Use Docker Compose for local PostgreSQL and Mailpit so the phase stays offline-first and reproducible."
  - "Keep the Flyway baseline purely technical with an installation probe table, leaving user/building domain tables for later phases."
  - "Expose `/api/system/status` as a narrow DTO with only application and database readiness, not raw actuator details."
  - "Run the Spring smoke test against PostgreSQL via Testcontainers so the new datasource contract is verified in every build."

patterns-established:
  - "Pattern 1: Spring Boot defaults come from env-overridable local values that match compose ports."
  - "Pattern 2: Database readiness is proven via a real integration test, not mocked startup assumptions."
  - "Pattern 3: Backend-facing status endpoints stay read-only and intentionally narrow."

requirements-completed: [FND-02, FND-05]

# Metrics
duration: 6min
completed: 2026-05-22
---

# Phase 04 Plan 01: Local Persistence Foundation Summary

**Local PostgreSQL/Mailpit baseline with Flyway schema and a real backend readiness contract**

## Performance

- **Duration:** 6 min
- **Started:** 2026-05-22T10:09:35Z
- **Completed:** 2026-05-22T10:15:57Z
- **Tasks:** 2
- **Files modified:** 8

## Accomplishments
- Local Docker Compose stack for PostgreSQL and Mailpit with persistent database volume
- Spring Boot persistence config, Flyway baseline migration, and a narrow `/api/system/status` endpoint
- Backend smoke and integration tests now prove both migration execution and live PostgreSQL startup

## task Commits

Each task was committed atomically:

1. **task 1: Lokale PostgreSQL-/Mailpit-Infrastruktur und Flyway-Basis aufsetzen** - `6e1dc42` (feat)
2. **task 2: Backend-Statusvertrag gegen echte PostgreSQL-Instanz absichern** - `bd835ba` → `4fc4192` (test → feat)

_Note: TDD task 2 used a RED commit followed by the GREEN implementation commit._

## Files Created/Modified
- `docker-compose.yml` - local PostgreSQL/Mailpit stack
- `backend/pom.xml` - persistence, Flyway, actuator, mail and Testcontainers dependencies
- `backend/src/main/resources/application.yml` - env-driven datasource, Flyway and mail defaults
- `backend/src/main/resources/db/migration/V1__baseline.sql` - technical baseline schema
- `backend/src/main/java/de/heizinventur/backend/system/SystemStatusController.java` - readiness endpoint
- `backend/src/main/java/de/heizinventur/backend/system/SystemStatusResponse.java` - narrow response DTO
- `backend/src/test/java/de/heizinventur/backend/system/SystemStatusIntegrationTest.java` - real PostgreSQL integration proof
- `backend/src/test/java/de/heizinventur/backend/HeizInventurApplicationTests.java` - context smoke test on Testcontainers PostgreSQL

## Decisions Made
- Kept the migration technical-only to avoid pre-creating later domain tables.
- Used Testcontainers for backend tests so the phase verifies actual PostgreSQL behavior.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Application smoke test needed the new PostgreSQL contract**
- **Found during:** task 2 (Backend-Statusvertrag gegen echte PostgreSQL-Instanz absichern)
- **Issue:** The existing `HeizInventurApplicationTests` still expected an in-memory/default datasource and failed once Spring was configured for PostgreSQL.
- **Fix:** Switched the smoke test to a PostgreSQL Testcontainers setup with matching datasource properties.
- **Files modified:** `backend/src/test/java/de/heizinventur/backend/HeizInventurApplicationTests.java`
- **Verification:** `./mvnw -Dtest=HeizInventurApplicationTests test`
- **Committed in:** `4fc4192` (task 2 commit)

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** The fix was required for correctness and verifiable execution; no scope creep beyond the phase contract.

## Issues Encountered
- None beyond the expected switch to a real PostgreSQL-backed smoke test.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- The local persistence contract is now in place for later domain tables and reports.
- Phase 4 task 2 can safely consume the new backend readiness endpoint.

## Self-Check: PASSED

---
*Phase: 04-datenbasis-und-migrationen*
*Completed: 2026-05-22*
