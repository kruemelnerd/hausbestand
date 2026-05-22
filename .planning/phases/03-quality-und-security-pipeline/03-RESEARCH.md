# Phase 3 Research: Quality- und Security-Pipeline

**Phase:** 3 (Quality- und Security-Pipeline)  
**Date:** 2026-05-22  
**Requirements:** FND-04

## Research Summary

- Kein `CONTEXT.md` vorhanden; Planung stuetzt sich daher auf ROADMAP, REQUIREMENTS, AGENTS, vorhandene Phase-1/2-Artefakte und aktuelle Repository-Realitaet.
- Phase 2 liefert bereits stabile Quality-Checks mit festen Job-Namen `frontend`, `backend` und `e2e`; Phase 3 muss diese Checks zu echten Merge-Gates machen, statt neue parallele Quality-Definitionen zu erfinden.
- Fuer die geforderten Security-Gates ist die kleinste lokal nachvollziehbare Kombination: **Dependency Review** fuer neue/veraenderte Dependencies im PR plus **Trivy Filesystem Scan** fuer Vulnerabilities, Secrets und Misconfigurations auf dem Repository-Inhalt.
- Die Merge-Blockierung darf nicht nur implizit ueber Workflows entstehen; sie braucht eine **repo-versionierte Branch-Protection-Konfiguration**, die `main` auf genau diese Status-Checks festnagelt.
- Renovate soll im Repository selbst konfiguriert werden; laut Projekt-Stack gilt `minimumReleaseAge: 7 days` als Standard und muss fuer npm-/Maven-Updates wirksam gesetzt sein.

## Docs-Grounded Guidance

1. **Dependency Review im PR-Kontext**
   - GitHub Docs empfiehlt einen eigenen `pull_request`-Workflow mit `actions/dependency-review-action@v4`.
   - Ein repo-lokales Config-File kann `fail-on-severity` und `fail-on-scopes` festlegen.
   - Damit wird verhindert, dass ein PR neue verwundbare Dependencies einfuehrt, auch wenn die eigentlichen Build-Jobs noch gruen sind.

2. **Vulnerability-/Secret-Checks ohne GitHub-Enterprise-Abhaengigkeit**
   - Trivy kann `fs`-Scans direkt auf dem Repo ausfuehren und dabei `vuln`, `secret` und `misconfig` kombinieren.
   - Fuer Phase 3 ist ein PR-/Push-Workflow mit `scan-type: fs`, `scanners: vuln,secret,misconfig`, `severity: HIGH,CRITICAL` und `exit-code: 1` ausreichend konkret und lokal reproduzierbar.
   - Damit bleibt die Security-Pipeline GitHub-Cloud-unabhaengig und passt zur Local-first-Vorgabe des Projekts.

3. **Required Merge Gates**
   - GitHub Branch Protection blockiert Merges, wenn definierte Status-Checks nicht `successful`, `skipped` oder `neutral` sind.
   - Der REST-Endpunkt `PUT /repos/{owner}/{repo}/branches/{branch}/protection` erlaubt es, `required_status_checks` inklusive konkreter Kontextnamen automatisiert zu setzen.
   - Fuer dieses Repo sind die vorhandenen Quality-Kontexte `frontend`, `backend`, `e2e` plus neue Security-Kontexte die richtigen Required Checks.

4. **Renovate-Konfiguration**
   - Renovate nutzt standardmaessig `renovate.json` als Repo-Konfigurationsdatei.
   - `minimumReleaseAge` kann per `packageRules` fuer `npm` und `maven` gesetzt werden; die Projekt-Stack-Empfehlung verlangt 7 Tage Mindestalter.
   - `config:best-practices` ist ein sinnvoller Basispreset; Automerge muss fuer dieses Projekt nicht eingefuehrt werden.

5. **Phase-Gate-konformer E2E-Zuwachs**
   - AGENTS verlangt pro Phase mindestens einen neuen E2E-Test.
   - Da Phase 3 keine neue Fach-UI liefert, sollte der neue Test den bestehenden App-Shell-Contract absichern: Platzhalter-Navigation sichtbar, deaktiviert und nicht interaktiv.
   - So waechst die Regression-Suite ohne spaetere Phasen fachlich vorwegzunehmen.

## Implementation Guidance for Planning

1. Nutze den bestehenden `CI`-Workflow weiter als Quality-Basis; fuehre keine neue, konkurrierende Quality-Pipeline ein.
2. Lege einen separaten Security-Workflow mit stabilen Job-Namen `dependency-review` und `repo-security` an.
3. Konfiguriere Dependency Review ueber `.github/dependency-review-config.yml` mit mindestens `fail-on-severity: moderate` und Scopes `development`, `runtime`.
4. Fuehre Trivy als Repo-Scan mit `scan-type: fs` und `scanners: vuln,secret,misconfig` aus; blockiere bei HIGH/CRITICAL.
5. Halte die Branch-Protection-Konfiguration als Datei im Repo fest und wende sie mit `gh api` auf `kruemelnerd/hausbestand` / Branch `main` an.
6. Erzeuge eine neue Playwright-E2E-Regression fuer die deaktivierte Platzhalter-Navigation, damit die Phasenregel „1 neuer E2E-Test“ eingehalten wird.
7. Lege `renovate.json` mit `config:best-practices` und `minimumReleaseAge: 7 days` fuer npm und maven an.

## Validation Architecture

- **Quick feedback loop:**
  - `cd frontend && npm run build && npm run test:e2e`
  - `cd backend && ./mvnw test`
- **Config verification:**
  - `test -f .github/workflows/security.yml && test -f .github/dependency-review-config.yml && test -f renovate.json`
  - `gh api repos/kruemelnerd/hausbestand/branches/main/protection --jq '.required_status_checks.contexts'`
- **Expected gate set:** `frontend`, `backend`, `e2e`, `dependency-review`, `repo-security`

## Risks / Pitfalls

- **Nur Workflows ohne Branch Protection:** Dann laufen Checks, blockieren aber Merge nicht verbindlich.
- **Security-Tools mit SaaS-/Lizenzabhaengigkeit:** Verletzen die Local-first-/v1-Leitplanke oder werden in privaten Repos unzuverlaessig.
- **Instabile Job-Namen:** Fuehren zu bruechigen Required-Checks und manuellen Nacharbeiten nach jedem Workflow-Refactor.
- **Renovate ohne Mindestalter:** Widerspricht direkt der Projekt-Stack-Empfehlung und erhoeht Update-Rauschen.
- **Kein neuer E2E-Test:** Verletzt die AGENTS-Regel trotz korrekter Pipeline-Implementierung.

## Recommendation

Plane **2 sequenzielle PLANs**:
- **Plan 01:** Security-Workflow + Dependency-Review-Konfiguration + neuer Playwright-Regressionsfall
- **Plan 02:** Renovate-Mindestalter + repo-versionierte Branch-Protection fuer `main`

## Sources

- Context7 `/github/docs` — Dependency Review Action, Protected Branches / Required Status Checks, REST Branch Protection. **Confidence: HIGH**
- Context7 `/renovatebot/renovate` — `renovate.json`, `minimumReleaseAge`, `packageRules`, `config:best-practices`. **Confidence: HIGH**
- Context7 `/aquasecurity/trivy` — `trivy fs`, kombinierte `vuln,secret,misconfig`-Scanner, Severity-Filter. **Confidence: HIGH**
- Phase-2-Artefakte (`.github/workflows/ci.yml`, Phase-2-SUMMARYs) — bestehende Quality-Checks und stabile Job-Namen. **Confidence: HIGH**

## RESEARCH COMPLETE
