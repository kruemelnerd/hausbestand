# Phase 2 Research: Basis-CI

**Phase:** 2 (Basis-CI)  
**Date:** 2026-05-22  
**Requirements:** FND-03

## Research Summary

- Kein `CONTEXT.md` vorhanden; Planung stuetzt sich daher auf ROADMAP, REQUIREMENTS, Technical Spec und die real gebauten Artefakte aus Phase 1.
- Phase 2 muss **drei reproduzierbare PR-Checks** liefern: Frontend-Build, Backend-Build/Testbasis und den bestehenden Playwright-Startseitenlauf in GitHub Actions.
- Die Technical Spec fordert bereits fuer Phase 2 einen **Backend-Build**; daher braucht das Repository jetzt ein minimales Spring-Boot/Maven-Grundgeruest, aber **ohne** Datenbank-, Auth-, Mail- oder Fachlogik aus spaeteren Phasen.
- GitHub Actions sollte in getrennte Jobs fuer `frontend`, `backend` und `e2e` aufgeteilt werden, damit Fehler klar isoliert bleiben und spaetere Required Checks stabile Job-Namen erhalten.

## Docs-Grounded Guidance

1. **GitHub Actions PR-Workflow**
   - `pull_request` auf `main` ist Pflicht; `push` auf `main` ist sinnvoll fuer denselben Basisschutz nach Merge.
   - Fuer spaetere Required-Checks-/Merge-Queue-Kompatibilitaet ist `merge_group` bereits jetzt sinnvoll, aber kein Muss fuer diesen ersten Basisschritt.
   - `actions/setup-node` soll `cache: npm` verwenden; `actions/setup-java` soll `cache: maven` verwenden.

2. **Playwright in CI**
   - In GitHub Actions soll `npx playwright install --with-deps chromium` vor dem Testlauf ausgefuehrt werden.
   - HTML-Report bzw. Testreport soll als Artifact hochgeladen werden, mindestens bei Fehlschlag oder `!cancelled()`.
   - CI-spezifischer Reporter (`github`) ist empfehlenswert, damit Fehlstellen direkt im PR annotiert werden.

3. **Backend-Build-Basis**
   - Minimaler Spring-Boot-Start mit Java 21, Maven und einem `contextLoads`-Test reicht fuer diese Phase.
   - Maven Wrapper ist fuer reproduzierbare CI-/Lokal-Laeufe vorzuziehen.
   - Keine Phase-4+-Abhaengigkeiten vorziehen: kein Flyway, keine Datenbank, keine Security-Konfiguration.

## Implementation Guidance for Planning

1. Erzeuge unter `backend/` ein minimales Spring-Boot-3.5.x-/Java-21-/Maven-Geruest mit Wrapper, Main-Klasse und einem grünen Basistest.
2. Halte die Backend-Verifikation schlank: `./mvnw test` fuer die Testbasis, `./mvnw package -DskipTests` oder `verify` fuer den Buildvertrag.
3. Richte in `frontend/` einen CI-tauglichen Playwright-Reportpfad/Reporter ein, ohne den existierenden lokalen Phase-1-Flow zu brechen.
4. Lege `.github/workflows/ci.yml` mit separaten Jobs fuer Frontend, Backend und E2E an.
5. Verschiebe Lint, Dependency Review, Secret Scan, Vulnerability Scan, Renovate, SBOM und Attestations **explizit** in Phase 3; Phase 2 bleibt bei Build-/Testbasis.

## Validation Architecture

- **Quick feedback loop:**
  - `cd backend && ./mvnw test`
  - `cd frontend && npm run build`
  - `cd frontend && npm run test:e2e`
- **CI contract:** dieselben drei Schienen muessen als getrennte Jobs in GitHub Actions grün sein.
- **Artifact expectation:** Playwright-Report wird in CI als Artifact publiziert.

## Risks / Pitfalls

- **Zu viel Scope:** Security-/Quality-Gates aus Phase 3 schon jetzt einzubauen verwischt die Phasengrenze.
- **Kein Backend-Geruest:** Dann bleibt das Success-Criterion „Backend-Build laeuft im PR“ unerfuellt.
- **Playwright ohne Browser-Install in CI:** Fuehrt reproduzierbar zu fehlschlagenden E2E-Jobs.
- **Instabile Check-Namen:** Erschwert spaetere Required-Checks-Konfiguration in Phase 3.
- **Nur lokaler `npm install`-Pfad:** CI muss `npm ci` nutzen, damit Lockfile und Build reproduzierbar bleiben.

## Recommendation

Plane **2 sequenzielle PLANs**:
- **Plan 01:** Minimales Backend-Geruest + Maven-Buildvertrag
- **Plan 02:** Frontend-Playwright-Absicherung + GitHub-Actions-CI-Workflow

## Sources

- GitHub Actions docs (`/websites/github_en_actions`) — Workflow-Syntax, `pull_request`, `setup-node`, npm cache, merge queue / required checks context.
- Playwright docs (`/microsoft/playwright.dev`) — GitHub-Actions-CI, `playwright install --with-deps`, Artifact-Upload, GitHub reporter.
- Spring Boot docs (`/spring-projects/spring-boot` v3.5.9) — Maven-Projektgrundlage und Build-Kommandos fuer minimale Anwendungen.

## RESEARCH COMPLETE
