# Requirements: HeizInventur

**Defined:** 2026-05-20
**Core Value:** Technisch unerfahrene Nutzer koennen vor Ort schnell und verlaesslich vollstaendige Heizkoerper- und Fenster-Inventurdaten (inklusive Fotos und Markerposition) erfassen, sodass ein belastbarer Report ohne Nacharbeit entsteht.

## v1 Requirements

Requirements fuer die initiale Lieferung. Diese Anforderungen folgen der fachlichen Spezifikation und dem dort definierten Phasenplan.

### Foundation and Quality Gates

- [x] **FND-01**: User kann die Anwendung oeffnen und eine sichtbare Startseite sehen.
- [ ] **FND-02**: Team kann Frontend, Backend, PostgreSQL und Mail-Stub lokal starten.
- [ ] **FND-03**: Pull Requests werden durch CI auf Build, Unit-, Integration- und E2E-Tests geprueft.
- [ ] **FND-04**: Pull Requests werden blockiert, wenn Quality- oder Security-Checks fehlschlagen.
- [ ] **FND-05**: Persistente Daten werden ueber versionierte Migrationen reproduzierbar verwaltet.

### Building Structure

- [ ] **BLD-01**: Admin kann ein Haus anlegen und bearbeiten.
- [ ] **BLD-02**: Admin kann Stockwerke pro Haus anlegen und bearbeiten.
- [ ] **BLD-03**: Admin kann Wohnungen pro Stockwerk anlegen und bearbeiten.
- [ ] **BLD-04**: Admin kann Raeume pro Wohnung anlegen und bearbeiten.
- [ ] **BLD-05**: User kann freigegebene Gebaeudestruktur lesen, aber nicht veraendern.

### Access and Approval

- [ ] **AUTH-01**: User kann sich mit E-Mail-Adresse registrieren.
- [ ] **AUTH-02**: User muss E-Mail bestaetigen, bevor Zugriff moeglich ist.
- [ ] **AUTH-03**: Vorab freigegebene E-Mail-Adressen werden nach Bestaetigung automatisch aktiviert.
- [ ] **AUTH-04**: Nicht vorab freigegebene User wechseln nach Bestaetigung in den Wartezustand fuer Admin-Freigabe.
- [ ] **AUTH-05**: Admin kann wartende User freigeben, ablehnen oder spaeter deaktivieren.
- [ ] **AUTH-06**: Nur User mit Status `ACTIVE` koennen geschuetzte Fachfunktionen nutzen.

### Floorplans and File Handling

- [ ] **FLR-01**: Admin kann pro Stockwerk einen Grundriss hochladen.
- [ ] **FLR-02**: User kann den Grundriss des ausgewaehlten Stockwerks anzeigen.
- [ ] **FLR-03**: Admin kann einen vorhandenen Grundriss austauschen.
- [ ] **FLR-04**: Uploads werden serverseitig auf Dateityp, Groesse und Zugriffsschutz geprueft.

### Marker Placement and Visibility

- [ ] **MRK-01**: Marker besitzen einen Typ (`HEIZKOERPER` oder `FENSTER`).
- [ ] **MRK-02**: Marker werden relativ zum Grundriss gespeichert und bleiben bei Zoom/Pan/Viewport stabil.
- [ ] **MRK-03**: Marker zeigen Statusfarben fuer offen, teilweise, vollstaendig und deaktiviert.
- [ ] **MRK-04**: Admin kann Marker setzen, verschieben, benennen und Raumkontext zuordnen.
- [ ] **MRK-05**: User kann Marker oeffnen und Standortdaten, Status und fehlende Daten sehen.
- [ ] **MRK-06**: User kann vorbereitete Marker sehen, aber nicht verschieben.

### Inventory Capture

- [ ] **INV-01**: User kann fuer Heizkoerper mindestens ein Foto aufnehmen oder hochladen.
- [ ] **INV-02**: User kann Heizkoerpertyp, Breite, Hoehe und optionale Zusatzdaten erfassen.
- [ ] **INV-03**: User kann fuer Fenster mindestens ein Foto aufnehmen oder hochladen.
- [ ] **INV-04**: User kann Fensterbreite, Fensterhoehe, Verglasung und Rahmenmaterial erfassen.
- [ ] **INV-05**: Formulare erlauben fuer unklare Angaben einen expliziten Wert `unbekannt`.
- [ ] **INV-06**: User kann neue Heizkoerper- und Fenster-Marker direkt auf dem Grundriss hinzufuegen.
- [ ] **INV-07**: Neu hinzugefuegte Marker sind sofort fuer andere User sichtbar und gekennzeichnet.
- [ ] **INV-08**: User kann Marker als nicht vorhanden markieren und muss einen Grund inkl. Foto angeben.
- [ ] **INV-09**: Backend berechnet Markerstatus nach jeder fachlichen Aenderung serverseitig neu.
- [ ] **INV-10**: Marker wird nur dann vollstaendig angezeigt, wenn alle Pflichtdaten inklusive Foto vorliegen.

### Report and Export

- [ ] **RPT-01**: User oder Admin kann einen Report fuer Projekt, Haus, Stockwerk oder Wohnung erzeugen.
- [ ] **RPT-02**: Report sortiert Daten strikt nach Haus -> Stockwerk -> Wohnung -> Raum -> Marker.
- [ ] **RPT-03**: Report markiert fehlende, teilweise und vollstaendige Daten klar unterscheidbar.
- [ ] **RPT-04**: Report kennzeichnet User-ergaenzte Marker und deaktivierte Marker mit Begruendung.
- [ ] **RPT-05**: Anwendung stellt mindestens PDF und einen tabellarischen Export bereit.
- [ ] **RPT-06**: Report bindet Fotos komprimiert und weiterhin fachlich nutzbar ein.

## v2 Requirements

Bewusst verschoben, nicht Teil des aktuellen Roadmapscopes.

### Deferred Enhancements

- **V2-01**: Offline-Sync mit Konfliktaufloesung fuer laengere Netzunterbrechungen.
- **V2-02**: Native Mobile Apps fuer iOS/Android.
- **V2-03**: Integrationen in externe Fachsysteme ueber standardisierte Schnittstellen.

## Out of Scope

Explizit ausgeschlossen fuer den aktuellen Projektumfang.

| Feature | Reason |
|---------|--------|
| In-App-Heizlastberechnung | Fachlich ausgeschlossen; App dient der Inventur und Uebergabe, nicht der energetischen Bewertung |
| CAD- oder 3D-Grundrisseditor | Erhoeht Komplexitaet stark, ohne Kernnutzen fuer Vor-Ort-Inventur |
| Oeffentliche Multi-Tenant-Plattform | Zielgruppe ist kleiner berechtigter Kreis mit kontrollierter Freigabe |
| Erstes Cloud-Deployment (Vercel/Supabase/Proxmox) | Local-first Basis wird zuerst abgeschlossen; Deployment folgt spaeter |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| FND-01 | Phase 1 | Complete |
| FND-02 | Phase 4 | Pending |
| FND-03 | Phase 2 | Pending |
| FND-04 | Phase 3 | Pending |
| FND-05 | Phase 4 | Pending |
| BLD-01 | Phase 5 | Pending |
| BLD-02 | Phase 5 | Pending |
| BLD-03 | Phase 5 | Pending |
| BLD-04 | Phase 5 | Pending |
| BLD-05 | Phase 5 | Pending |
| AUTH-01 | Phase 6 | Pending |
| AUTH-02 | Phase 6 | Pending |
| AUTH-03 | Phase 6 | Pending |
| AUTH-04 | Phase 6 | Pending |
| AUTH-05 | Phase 6 | Pending |
| AUTH-06 | Phase 6 | Pending |
| FLR-01 | Phase 7 | Pending |
| FLR-02 | Phase 7 | Pending |
| FLR-03 | Phase 7 | Pending |
| FLR-04 | Phase 7 | Pending |
| MRK-01 | Phase 8 | Pending |
| MRK-02 | Phase 8 | Pending |
| MRK-03 | Phase 8 | Pending |
| MRK-04 | Phase 9 | Pending |
| MRK-05 | Phase 10 | Pending |
| MRK-06 | Phase 9 | Pending |
| INV-01 | Phase 11 | Pending |
| INV-02 | Phase 11 | Pending |
| INV-03 | Phase 12 | Pending |
| INV-04 | Phase 12 | Pending |
| INV-05 | Phase 11 | Pending |
| INV-06 | Phase 13 | Pending |
| INV-07 | Phase 13 | Pending |
| INV-08 | Phase 13 | Pending |
| INV-09 | Phase 11 | Pending |
| INV-10 | Phase 11 | Pending |
| RPT-01 | Phase 14 | Pending |
| RPT-02 | Phase 14 | Pending |
| RPT-03 | Phase 14 | Pending |
| RPT-04 | Phase 14 | Pending |
| RPT-05 | Phase 14 | Pending |
| RPT-06 | Phase 14 | Pending |

**Coverage:**
- v1 requirements: 42 total
- Mapped to phases: 42
- Unmapped: 0

---
*Requirements defined: 2026-05-20*
*Last updated: 2026-05-20 after roadmap mapping*
