# HeizInventur

## What This Is

HeizInventur ist eine mobile-first Webanwendung zur strukturierten Erfassung von Heizkoerpern und Fenstern auf Grundrissen in Mehrfamilienhaeusern. Admins bereiten Gebaeudestruktur und Grundrisse vor, Nutzer erfassen vor Ort Inventurdaten inkl. Pflichtfotos direkt am Marker. Ergebnis ist ein nachvollziehbarer Report- und Export-Output fuer einen Energieeffizienz-Experten.

## Core Value

Technisch unerfahrene Nutzer koennen vor Ort schnell und verlaesslich vollstaendige Heizkoerper- und Fenster-Inventurdaten (inklusive Fotos und Markerposition) erfassen, sodass ein belastbarer Report ohne Nacharbeit entsteht.

## Requirements

### Validated

(None yet - ship to validate)

### Active

- [ ] Admin kann die Struktur Haus -> Stockwerk -> Wohnung -> Raum verwalten.
- [ ] User-Registrierung mit verpflichtender E-Mail-Bestaetigung und Admin-Freigabe funktioniert fachlich korrekt.
- [ ] Grundrisse koennen pro Stockwerk hochgeladen, ausgetauscht und fuer User angezeigt werden.
- [ ] Marker fuer Heizkoerper/Fenster werden relativ auf Grundrissen gespeichert und stabil dargestellt (mobil, desktop, zoom, pan).
- [ ] User koennen Marker-Details oeffnen und fehlende Inventurdaten sehen.
- [ ] User koennen Heizkoerper- und Fensterdaten inkl. Pflichtfoto erfassen; Status wird serverseitig berechnet.
- [ ] User koennen neue Marker hinzufuegen und Marker als nicht vorhanden markieren (mit Foto-Nachweis).
- [ ] Reports (PDF + tabellarischer Export) sortieren nach Haus -> Stockwerk -> Wohnung -> Raum -> Marker und markieren fehlende/teilweise/vollstaendige Daten.
- [ ] Jede Phase liefert mindestens einen neuen E2E-Test; bestehende E2E-Tests bleiben erhalten.

### Out of Scope

- Heizlastberechnung in der App - fachlich explizit ausgeschlossen.
- CAD-Funktionen, 3D-Grundrisse und Zeichenwerkzeuge - nicht Ziel der Inventur-App.
- Oeffentliche Multi-Tenant Plattform - Zielgruppe ist kleiner, berechtigter Nutzerkreis.
- Erstes Produktiv-Deployment (Proxmox, Vercel, Supabase, oeffentliche Domain, Reverse Proxy) - spaetere Spezifikation.
- Native Mobile App fuer App Store/Play Store - Web-first Ansatz.

## Context

- Fachliche Leitquelle: `heiz-inventur-inspec.md` inklusive Phasenplan 1-14 und E2E-Leitliste.
- Technische Leitquelle: `heiz-inventur-technical-spec.md` (Vue 3 + TypeScript + Vite, Spring Boot + Java 21 + Maven, PostgreSQL, Mailpit, lokale Dateiablage).
- Arbeitsregeln fuer Agenten: `AGENTS(1).md` (phasenweise Entwicklung, Security, DoD, Ergebnisberichte, keine Scope-Ausweitung).
- Projekt startet greenfield: aktuell keine implementierte App-Struktur im Repository.
- Zielbetrieb der ersten Stufe ist lokal testbar und CI-pruefbar mit wachsender Regression-Suite.

## Constraints

- **Tech stack**: Frontend Vue 3/TypeScript, Backend Spring Boot Java 21, DB PostgreSQL - laut Technical Spec.
- **Execution model**: Phasenweise Umsetzung gemaess fachlichem Phasenplan, keine Vorwegnahme spaeterer Phasen.
- **Testing**: Pro Phase mindestens ein neuer E2E-Test plus gruen bleibende bestehende Unit/Integration/E2E-Tests.
- **Security**: Backend ist Source of Truth fuer Auth, Autorisierung, Validierung und Statusberechnung.
- **Storage**: Upload-Dateien im lokalen Dateisystem, DB speichert Metadaten statt BLOBs.
- **Operations**: Lokale Ausfuehrbarkeit ohne externe Cloud-Dienste ist Pflicht fuer v1.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Build from scratch in local-first mode | Spezifikation trennt bewusst lokale Basis von spaeterem Deployment | - Pending |
| Keep strict phase gates with mandatory E2E growth | Qualitaet und Regression-Schutz sind Kernanforderungen | - Pending |
| Persist marker coordinates as xPercent/yPercent | Marker muessen bei Zoom/Viewport stabil bleiben | - Pending |
| Enforce auth/authorization and status logic in backend | Sicherheits- und Fachregeln duerfen nicht nur im Frontend liegen | - Pending |
| Limit initial scope to inventory + report handoff | Fokus auf Datenerfassung statt energetischer Berechnung | - Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? -> Move to Out of Scope with reason
2. Requirements validated? -> Move to Validated with phase reference
3. New requirements emerged? -> Add to Active
4. Decisions to log? -> Add to Key Decisions
5. "What This Is" still accurate? -> Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check - still the right priority?
3. Audit Out of Scope - reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-05-20 after initialization*
