# Architecture Research

**Domain:** Floorplan-marker Inventarsystem (Heizkoerper/Fenster)
**Researched:** 2026-05-20
**Confidence:** HIGH

## Standard Architecture

### System Overview

```text
┌──────────────────────────────────────────────────────────────────────────────┐
│                          Client Layer (Vue 3 SPA)                           │
├──────────────────────────────────────────────────────────────────────────────┤
│  Route/UI      Marker Canvas       Forms/Uploads       Report Download      │
│  (Router)      (Zoom/Pan Layer)    (guided inputs)      (PDF/CSV trigger)   │
│      │               │                    │                     │            │
│      └───────────────┴──────────────┬─────┴─────────────────────┘            │
│                                      v                                        │
│                              API Client (typed)                              │
├──────────────────────────────────────────────────────────────────────────────┤
│                       Backend Layer (Spring Boot)                            │
├──────────────────────────────────────────────────────────────────────────────┤
│ Auth & Session | Authorization | Marker Domain | Inventory Domain | Reports  │
│ (Security)     | (RBAC + scope)| (position/rules)| (status engine)| (export) │
│                     │                  │                 │             │       │
│                     └──────────────────┴─────────────────┴─────────────┐      │
│                                                                          v     │
│                  File Service (upload validation + controlled delivery)        │
├──────────────────────────────────────────────────────────────────────────────┤
│                      Persistence & Storage Layer                              │
├──────────────────────────────────────────────────────────────────────────────┤
│ PostgreSQL (entities, metadata, status, audit fields)                        │
│ Local file volume (floorplans/photos/reports binaries)                        │
│ Mailpit SMTP sink (email confirmation in local env)                           │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Component Responsibilities + Contracts

| Component | Verantwortung | Vertrag (Input/Output, Grenzen) |
|---|---|---|
| Frontend `floorplan-canvas` | Anzeige von Grundriss + Marker, Zoom/Pan, Marker-Selektion | **Input:** Floorplan URL + Markerliste mit `xPercent/yPercent/status`. **Output:** UI Events (`markerSelected`, `markerMoved` nur fuer Admin). **Grenze:** Keine Sicherheitsentscheidung, keine finale Statuslogik. |
| Frontend `inventory-forms` | Gefuehrte Datenerfassung (Heizkoerper/Fenster, Foto) | **Input:** Markerdetails + Pflichtfeld-Definition. **Output:** Validierte DTO-Requests. **Grenze:** Client-Validierung ist UX, Backend validiert final. |
| Backend `auth` | Registrierung, E-Mail-Bestaetigung, Session-Login, User-Status | **Input:** Credentials/Tokens. **Output:** Session-Cookie + UserState. **Grenze:** Session und Rollen ausschliesslich serverseitig durchsetzen. |
| Backend `marker` | Marker-Lifecycle (create/move/rename/deactivate), Positionsregeln | **Input:** Marker-Kommandos + User-Kontext. **Output:** Persistierter Marker + neu berechneter Status. **Grenze:** Nur Admin darf vorbereitete Struktur veraendern; User darf nur erlaubte Marker-Aktionen. |
| Backend `inventory` | Fachregeln fuer Pflichtfelder, unbekannt-Werte, Statusberechnung | **Input:** Inventurdaten + Fotos + Markerbezug. **Output:** Canonical Markerstatus (`RED/YELLOW/GREEN/GRAY`) + Missing-Fields. |
| Backend `file` | Upload-Validierung, serverseitige Dateinamen, autorisierte Auslieferung | **Input:** Multipart Dateien. **Output:** Datei-Metadaten in DB + Binary im Volume. **Grenze:** Kein direkter Zugriff aufs Upload-Verzeichnis. |
| Backend `report` | Serverseitige PDF/CSV-Erstellung nach Sortierhierarchie | **Input:** Scope (Projekt/Haus/Stockwerk/Wohnung). **Output:** Downloadbare Report-Datei + Metadaten. |
| PostgreSQL | Persistenz fuer Struktur, Marker, Inventur, Datei-Metadaten | **Input:** Transaktionale Writes. **Output:** Konsistente Query-Basis fuer UI/Report. |

## Recommended Project Structure

```text
heiz-inventur/
├── frontend/
│   └── src/
│       ├── app/                  # App bootstrap, router, providers
│       ├── features/
│       │   ├── auth/
│       │   ├── buildings/
│       │   ├── floorplans/
│       │   ├── markers/
│       │   ├── inventory/
│       │   └── reports/
│       ├── api/                  # typed API client + error mapping
│       ├── stores/               # Pinia stores (UI/session/filter state)
│       └── components/           # reusable UI primitives
├── backend/
│   └── src/main/java/.../
│       ├── auth/
│       ├── user/
│       ├── building/
│       ├── floorplan/
│       ├── marker/
│       ├── inventory/
│       ├── file/
│       ├── report/
│       ├── common/
│       └── config/
├── e2e/
│   ├── tests/                    # phase-wise user flows (never delete old)
│   ├── fixtures/                 # seeded users, floorplans, marker data
│   └── playwright.config.ts
├── docs/
│   └── architecture-decisions/   # ADRs for contract/invariant changes
└── docker-compose*.yml
```

### Structure Rationale

- **Feature-first im Frontend:** reduziert Kopplung und erleichtert phasenweise Lieferung (pro Phase ein Feature-Ordner + ein E2E-Flow).
- **Bounded Packages im Backend:** kapselt Fachlogik je Domain; Controller bleiben duerftig, Services tragen Regeln.
- **Separater `file`-Bereich:** scharfe Trennung zwischen Datenmodell und Binary-Handling (wichtig fuer Security und spaeteres Storage-Swapping).
- **Eigenes `e2e/` Workspace:** E2E bleibt produktnah und unabhängig von Unit-Test-Setups.

## Architectural Patterns

### Pattern 1: Thin Controller, Rich Domain Service

**What:** Controller mappt DTOs und delegiert; fachliche Entscheidungen (Status, Rollen-spezifische Aktionen, Invarianten) liegen in Services.
**When to use:** Bei allen Marker-/Inventur-Endpunkten.
**Trade-offs:** Mehr Service-Code, aber deutlich testbarer und stabiler bei UI-Wechseln.

```java
@PostMapping("/api/v1/markers/{id}/radiator")
public MarkerDto saveRadiator(@PathVariable UUID id,
                              @Valid @RequestBody RadiatorInputDto input,
                              Authentication auth) {
  return markerMapper.toDto(inventoryService.saveRadiatorData(id, input, auth));
}
```

### Pattern 2: Canonical Status Engine (Server Source of Truth)

**What:** Ein zentraler Service berechnet Markerstatus nach jeder relevanten Aenderung.
**When to use:** Nach Marker-Update, Inventur-Update, Foto-Upload, Deaktivierung.
**Trade-offs:** Zusätzlicher Recompute-Aufwand, dafuer keine divergierenden Status zwischen UI und Report.

```text
on mutation(marker|inventory|photo|deactivation)
  -> validate required fields by marker type
  -> apply deactivation override (GRAY)
  -> derive missing/uncertain flags
  -> persist status + missingFieldsSnapshot atomar
```

### Pattern 3: Shared Transform Layer for Floorplan + Marker

**What:** Grundriss und Marker liegen im selben transformierbaren Zoom/Pan-Container.
**When to use:** Jede Markeranzeige und Marker-Interaktion.
**Trade-offs:** Rendering-Implementierung etwas anspruchsvoller, verhindert aber Positionsdrift.

```typescript
const markerStyle = {
  left: `${marker.xPercent}%`,
  top: `${marker.yPercent}%`,
  transform: 'translate(-50%, -50%)'
}
// marker element is child of same transformed layer as floorplan image
```

## Data Flow and Invariants

### Request Flow (Marker erfassen)

```text
User tippt Marker
  -> Frontend laedt Markerdetail + missing fields
  -> User erfasst Daten/Foto
  -> POST /api/v1/markers/{id}/radiator|window (+ file upload)
  -> Backend validiert Rolle, Input, Marker scope
  -> Backend speichert Daten + berechnet Status atomar
  -> Frontend rendert neuen Status und fehlende Daten
```

### Marker-Positions-Invarianten (kritisch)

1. `xPercent` und `yPercent` liegen immer im Bereich `0..100`.
2. Position ist relativ zur nativen Grundrissflaeche definiert, nie in Pixeln persistieren.
3. Marker und Grundriss verwenden denselben Transform-Kontext (Zoom/Pan).
4. Bei Floorplan-Austausch bleibt Markerposition semantisch gueltig oder wird explizit neu zugeordnet (kein stilles Drift-Verhalten).

### Marker-Status-Invarianten (kritisch)

1. **Nur Backend** darf finalen Status festlegen.
2. `GREEN` nur wenn alle Pflichtfelder + mindestens ein Foto vorhanden.
3. `GRAY` (deaktiviert/nicht vorhanden) braucht Nachweisfoto + Grund.
4. Status muss bei jeder relevanten Mutation synchron neu berechnet werden.
5. Report verwendet denselben gespeicherten Status wie UI (kein separater Report-Statusalgorithmus).

## Security-Critical Trust Boundaries

| Trust Boundary | Risiko | Muss-Regel |
|---|---|---|
| Browser -> Backend API | Manipulierte Requests, Umgehung von UI-Checks | Jede schreibende Operation serverseitig validieren (AuthN/AuthZ/Schema). |
| Backend -> File Volume | Path traversal, unautorisierter Dateizugriff | Servergenerierte Dateinamen, Allowlist MIME/Format, Auslieferung nur via autorisierte API. |
| Session Cookie Boundary | Session theft/misuse | HttpOnly (und in prod-like Secure), keine Tokens in LocalStorage, serverseitige Sessionkontrolle. |
| Admin vs User Aktionen | Rechteeskalation | Rollenpruefung im Backend; Admin-only Endpunkte getrennt und getestet. |
| Report Export Boundary | Datenabfluss | Report-Scopes (Projekt/Haus/Stockwerk/Wohnung) autorisiert pruefen; keine ungebundenen globalen Exporte. |

## Build Order Implications (for Roadmap)

1. **Foundation zuerst:** Health, CI, Security-Pipeline, DB+Migrationen, Auth-Basis.  
   *Warum:* Alle spaeteren Fachfunktionen brauchen stabile Session-, Test- und Persistenzbasis.
2. **Datei-Subsystem vor Inventur-Feature:** Floorplan/Foto-Upload mit sicheren Regeln frueh liefern.  
   *Warum:* Marker- und Inventur-Flows sind ohne sichere Fileschicht unvollstaendig.
3. **Marker-Engine vor Formular-Details:** erst Positionierung + Marker-Lifecycle stabilisieren, dann Heizkoerper/Fensterformulare.  
   *Warum:* Formularlogik haengt von robustem Marker-Contract und Status-Engine ab.
4. **Status-Engine zentral vor Report-Feinschliff:** Report darf nur konsumieren, nicht neu interpretieren.  
   *Warum:* Verhindert Inkonsistenzen zwischen UI und Export.
5. **E2E pro Phase entlang Kernfluss:** jeder neue Domain-Schritt erzeugt genau einen stabilen Nutzerfluss-Test; alte Tests bleiben.  
   *Warum:* testbare, risikoarme phasenweise Lieferung.

## Anti-Patterns

### Anti-Pattern 1: Statuslogik im Frontend duplizieren und vertrauen

**Was passiert:** UI setzt Marker auf gruen ohne serverseitigen Nachweis (oder mit abweichender Regelmenge).  
**Warum schlecht:** Inkonsistente Daten, fehlerhafte Reports, Sicherheitsluecke via API-Bypass.  
**Stattdessen:** Ein zentraler Backend-Status-Service, UI nur zur Vorschau.

### Anti-Pattern 2: Pixel-Koordinaten persistieren

**Was passiert:** Marker verrutschen auf anderen Geraeten/Zoomstufen.  
**Warum schlecht:** Vor-Ort-Erfassung wird unzuverlaessig, manuelle Korrekturen explodieren.  
**Stattdessen:** Prozentkoordinaten + gemeinsamer Transform-Layer + E2E-Positionstests.

### Anti-Pattern 3: Upload-Verzeichnis direkt exponieren

**Was passiert:** Dateien sind ohne Autorisierung abrufbar oder manipulierbar.  
**Warum schlecht:** Datenschutz- und Sicherheitsproblem (Fotos aus Wohnungen).  
**Stattdessen:** Auslieferung nur ueber autorisierte Backend-Endpunkte.

## Skalierungsbetrachtung

| Scale | Architektur-Anpassung |
|---|---|
| 0-1k Nutzer (Ziel v1) | Monolith + Postgres + lokales Volume ist angemessen; Fokus auf Korrektheit und E2E-Regression. |
| 1k-10k Nutzer | Read-Optimierung (Indizes fuer Hierarchie/Status), Background-Jobs fuer grosse Report-Generierung, optional Object Storage statt lokalem Volume. |
| 10k+ Nutzer | Entkopplung Datei-/Report-Workloads (Queue/Worker), ggf. separates Reporting-Read-Model; erst bei nachgewiesenem Bottleneck. |

## Sources

- `heiz-inventur-inspec.md` (fachliche Regeln, Status/Fotos/Phasen, Markerposition)
- `heiz-inventur-technical-spec.md` (Stack, Security, API, Storage, Teststrategie)
- Spring Security Reference 6.5 (Rollen-/Methodensicherheit, Session Management): https://docs.spring.io/spring-security/reference/6.5/
- Vue Router (Route Meta/Guards fuer UX-Navigation): https://router.vuejs.org/
- Playwright Best Practices (Test Isolation): https://playwright.dev/docs/best-practices

---
*Architecture research for: HeizInventur*
*Researched: 2026-05-20*
