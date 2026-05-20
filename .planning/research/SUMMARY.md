# Project Research Summary

**Project:** HeizInventur
**Domain:** Mobile-first, grundrissbasierte Vor-Ort-Inventur (Heizkoerper/Fenster) mit Report-Handoff
**Researched:** 2026-05-20
**Confidence:** HIGH

## Executive Summary

HeizInventur ist kein generisches Property-Tool, sondern ein fokussiertes Feldarbeits-System: nicht-technische Nutzer sollen auf einem Grundriss schnell, korrekt und nachweisbar erfassen koennen. Die Forschung zeigt klar, dass erfolgreiche Loesungen in diesem Bereich eine visuelle Marker-zentrierte UX, strikt serverseitige Fachlogik (Status, Rollen, Pflichtnachweise) und einen frueh mitgedachten Export-Output kombinieren. Der eigentliche Produktwert liegt nicht in „vielen Features“, sondern in belastbarer Datenqualitaet unter realen Vor-Ort-Bedingungen.

Empfohlener Umsetzungsweg: Vue 3 + TypeScript + Vite im Frontend, Spring Boot (Java 21) als fachliche Autoritaet, PostgreSQL als System of Record, lokale Dateiablage hinter autorisierten API-Endpunkten. Architekturseitig ist ein modularer Monolith mit klaren Domänenbereichen (auth, marker, inventory, file, report) der richtige Start, inklusive zentraler Status-Engine und relativer Markerkoordinaten (`xPercent/yPercent`).

Die groessten Risiken sind (1) Marker-Drift durch falsches Render-/Koordinatenmodell, (2) Sicherheits- und Fachbruch durch Frontend-only Logik, (3) unsichere Upload-Pipeline und (4) ein zu spaet gebauter Report. Diese Risiken sind vermeidbar, wenn Security- und Invariantenregeln ab Phase 1-2 durchgesetzt werden, Uploads frueh gehaertet werden und pro Phase E2E-/API-Signale als Gate dienen.

## Key Findings

### Recommended Stack

Die Stack-Entscheidung ist konsistent und gut belegt: ein moderner Vue-SPA-Client fuer mobile Feld-UX plus ein stark typisierter, sicherheitsfokussierter Spring-Backend-Kern als Source of Truth. PostgreSQL + Flyway + Testcontainers + Playwright ergeben eine robuste Lieferkette mit reproduzierbarer Migration und regressionssicherer Phasenentwicklung.

**Core technologies:**
- **Vue 3 + TypeScript + Vite**: Mobile-first SPA fuer gefuehrte Erfassung — schnell in Iteration, gut fuer formularlastige Domänenlogik.
- **Spring Boot 3.5.x auf Java 21 LTS**: API, Auth, Autorisierung, Validierung, Report-Generierung — langfristig wartbar und sicherheitsstark.
- **PostgreSQL 17.x (Upgradepfad zu 18.x)**: Transaktionale Persistenz fuer Struktur, Marker, Status, Metadaten — ideal fuer hierarchische Fachdaten.
- **Lokale Dateiablage hinter API (spaeter S3-kompatibel)**: Fotos/Grundrisse/Reports als Dateien, Metadaten in DB — lokal-first heute, austauschbar fuer spaeteres Hardening.

Kritische Versions-/Policy-Punkte: Vue 2 vermeiden (EOL), Java 21 als LTS-Basis, serverseitige Sessions via HttpOnly-Cookies statt JWT in LocalStorage, Flyway ab erster persistenter Schema-Version verpflichtend.

### Expected Features

v1 ist klar umrissen und fachlich zwingend: gefuehrte Gebaeudestruktur, stabile Grundrissmarker, typ-spezifische Inventur inkl. Pflichtfoto, serverseitige Statusberechnung, Rollen/Freigabe und ein verwertbarer Report/Export. Differenzierung kommt ueber Feldtauglichkeit (Bottom-Sheet-Flow, klare Fortschritte, kollaborative Marker-Sichtbarkeit), nicht ueber komplexe Zusatzmodule.

**Must have (table stakes):**
- Gefuehrte Struktur Haus→Stockwerk→Wohnung→Raum
- Stabile Grundrissanzeige mit relativen Markern
- Backend-Statussystem (rot/gelb/gruen/grau) als Source of Truth
- Typ-spezifische Formulare + Pflichtfoto (inkl. „nicht vorhanden“)
- Rollenmodell mit E-Mail-Bestaetigung + Admin-Freigabe
- User-Marker ergaenzen/deaktivieren mit Nachweis
- PDF + tabellarischer Export in fester fachlicher Sortierung

**Should have (competitive):**
- Mobile Bottom-Sheet mit „fehlende Daten“-Checkliste
- Fortschrittssicht pro Haus/Stockwerk
- Sofortige Sichtbarkeit kollaborativer User-Marker
- Report mit expliziten Unsicherheits-/Lueckenhinweisen

**Defer (v2+):**
- Offline-Sync mit Konfliktaufloesung
- Native Apps
- CAD/3D-Funktionen
- In-App-Heizlastberechnung / energetische Bewertung
- Oeffentliche Multi-Tenant-Plattform

### Architecture Approach

Die Architektur sollte als modularer Monolith umgesetzt werden: Frontend-Feature-Slices + Backend-Bounded-Packages, mit duennen Controllern und starker Domain-Service-Logik. Zentral sind drei Muster: (1) Canonical Status Engine im Backend, (2) gemeinsamer Transform-Layer fuer Grundriss+Marker, (3) strikt autorisierte File-Pipeline ohne direkte Dateiverzeichnis-Exposition.

**Major components:**
1. **Client (Vue SPA mit Canvas + Forms):** Marker-zentrierte Erfassung, mobile Navigation, reine UX-Validierung.
2. **Backend Domains (auth/marker/inventory/file/report):** Fachregeln, Rollen-/Statusdurchsetzung, Upload-Hardening, Export-Erstellung.
3. **Persistence/Storage (PostgreSQL + File Volume):** transaktionale Metadaten + kontrollierte Binary-Ablage.

### Critical Pitfalls

1. **Marker-Drift durch Pixel-/Layer-Fehler** — nur Prozentkoordinaten speichern, gemeinsamer Zoom/Pan-Kontext, Multi-Viewport-E2E mit Zoom/Pan.
2. **Frontend-only Fachlogik (Status/Rollen/Pflichtregeln)** — alle schreibenden Entscheidungen serverseitig, Security-Integrationstests pro Endpunktgruppe.
3. **Unsichere Upload-Pipeline** — MIME+Endung+Magic-Byte-Pruefung, servergenerierte Dateinamen, keine public Upload-Ordner, autorisierte File-Delivery.
4. **Rollen-/Status-Drift im Freigabeworkflow** — explizite Backend-State-Machine mit erlaubten Transitionen + Auditlog.
5. **Report zu spaet als Kernartefakt** — Datenmodell frueh auf Sortierkette ausrichten, Snapshot-Exports bereits vor finalem Report-Layout.

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 1: Foundation & Security Baseline
**Rationale:** Alle spaeteren Flows haengen von Auth, Persistenz und Test-Gates ab.
**Delivers:** Projektgrundgeruest, CI, Docker-Local-Infra (Postgres/Mailpit), Flyway-Basis, Auth-Start (Registrierung/Login), Session-Security-Defaults.
**Addresses:** Rollen/Freigabe-Backbone, sichere Basis fuer alle Table-Stakes.
**Avoids:** Frontend-only Sicherheitslogik, DB-Drift ohne Migrationen.

### Phase 2: Structure + Secure File Subsystem
**Rationale:** Ohne Gebaeudestruktur und gehaertete Upload-Pipeline ist der Feldworkflow nicht real nutzbar.
**Delivers:** Haus→Stockwerk→Wohnung→Raum, Grundriss-Upload/-Austausch, sichere Dateiablage und autorisierte Auslieferung.
**Uses:** Spring Security, Flyway, lokale Files hinter API.
**Implements:** `building`, `floorplan`, `file` Komponenten.

### Phase 3: Marker Engine & Spatial Reliability
**Rationale:** Markerstabilitaet ist das zentrale UX-/Datenqualitaetsfundament vor Formular-Details.
**Delivers:** Marker-Lifecycle, relative Koordinaten, stabiler Zoom/Pan-Layer, Marker-Detail-Entry.
**Addresses:** Grundriss+Marker Table-Stake, Vorbereitung fuer Inventurformulare.
**Avoids:** Marker-Drift, Pixel-Koordinaten-Schulden.

### Phase 4: Inventory Capture + Canonical Status Engine
**Rationale:** Fachwert entsteht erst durch vollstaendige Datenerfassung mit serverseitigem Status.
**Delivers:** Heizkoerper-/Fensterformulare, Pflichtfoto-Regeln, `unbekannt`-Werte, zentrale Statusberechnung (RED/YELLOW/GREEN/GRAY), User-Marker add/deactivate.
**Addresses:** Kern-v1-Table-Stakes zur Vollstaendigkeit.
**Avoids:** „Gruen ohne Nachweis“, divergierende UI/Backend-Statuslogik.

### Phase 5: Report, Export & Operational Hardening
**Rationale:** Report ist das eigentliche Abnahmeprodukt fuer Experten-Handoff.
**Delivers:** PDF+tabellarischer Export in fester Sortierung, Luecken-/Unsicherheitskennzeichnung, Performance-Budgets (Bildkompression), Abschluss-Regression.
**Addresses:** Ergebnisqualitaet und Nutzbarkeit ausserhalb der App.
**Avoids:** Spaetes Report-Desaster, N+1-/Groessenprobleme.

### Phase Ordering Rationale

- Reihenfolge folgt harten Abhaengigkeiten: Auth/Security → Struktur/Files → Marker-Reliability → Inventurregeln → Report.
- Gruppierung entspricht Architekturgrenzen (auth/file/marker/inventory/report) und reduziert Querschnittsrisiken je Phase.
- Kritische Pitfalls werden frueh „abgeschnitten“ statt spaet repariert (insb. Marker-Drift, Upload-Security, Status-Truth).

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 2 (Secure File Subsystem):** Upload-Hardening-Details (Magic-Byte-Detection, AV/Quarantaene-Optionen, image processing pipeline).
- **Phase 3 (Marker Engine):** konkrete Zoom/Pan/Render-Strategie fuer mobile Performance bei hoeherer Markerdichte.
- **Phase 5 (Report/Export):** PDF-Layout/Kompression bei grosser Bildmenge, ggf. Background-Job-Muster.

Phases with standard patterns (skip research-phase):
- **Phase 1 (Foundation/Auth-Basis):** gut dokumentierte Standardpfade in Spring Boot/Security + Flyway + CI.
- **Phase 4 (Form Validation + Status Engine als Muster):** Domänenspezifisch, aber mit klaren vorhandenen Regeln und Invarianten aus den Spezifikationen.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Offizielle Quellen (Context7/Docs) + klare Kompatibilitaetslinien, lokal-first sauber abgebildet. |
| Features | HIGH | Direkt aus projektspezifischen Fach- und Technik-Spezifikationen, Scope klar abgegrenzt. |
| Architecture | HIGH | Konsistent mit Feature-Abhaengigkeiten und Sicherheitsinvarianten, klare Komponentenvertraege. |
| Pitfalls | HIGH/MEDIUM | HIGH fuer projektspezifische Kernfallen, MEDIUM fuer allgemeine Branchenmuster/Skalierungswerte. |

**Overall confidence:** HIGH

### Gaps to Address

- **Offline-/Netzschwache Feldsituationen:** derzeit bewusst out-of-scope; in Planung explizit mit Telemetrie validieren, bevor Offline-Sync gestartet wird.
- **Konkrete Report-Lastprofile (Fotos/Objektanzahl):** frueh Lasttest-Szenarien definieren, um Kompression/Job-Strategie datenbasiert festzulegen.
- **Konfliktstrategie bei Parallelbearbeitung:** Optimistic Locking ist erkannt, aber konkretes UX-Verhalten (merge/reload) muss als Phase-Detail geplant werden.
- **Storage-Migration lokal -> S3-kompatibel:** Vertrag ist klar, aber Cutover-/Backfill-Runbook fuer spaeteren Produktionspfad vorbereiten.

## Sources

### Primary (HIGH confidence)
- `.planning/research/STACK.md` — empfohlener Technologie-Stack, Versionen, Security-/Test-Basis
- `.planning/research/FEATURES.md` — Table Stakes, Differenzierung, Anti-Features, Abhaengigkeiten
- `.planning/research/ARCHITECTURE.md` — Komponentenvertraege, Invarianten, Build-Order, Anti-Patterns
- `.planning/research/PITFALLS.md` — kritische Fehlermuster, Warnsignale, Phase-zu-Pitfall-Mapping
- `.planning/PROJECT.md` — Projektziel, aktive Anforderungen, Constraints

### Secondary (MEDIUM confidence)
- Spring Security Docs 6.5, Vue Router, Playwright Best Practices, OWASP File Upload Cheat Sheet — Best Practices fuer Security/Testing/Delivery-Hardening

---
*Research completed: 2026-05-20*
*Ready for roadmap: yes*
