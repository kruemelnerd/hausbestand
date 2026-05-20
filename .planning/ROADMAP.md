# Roadmap: HeizInventur

## Overview

Diese Roadmap folgt strikt dem fachlich vorgegebenen Phasenplan 1–14 aus `heiz-inventur-inspec.md`. Die technischen Leitplanken aus `heiz-inventur-technical-spec.md` und die Arbeitsregeln aus `AGENTS(1).md` sind als verpflichtende Gates in die jeweiligen Phasen integriert, ohne die Reihenfolge zu veraendern.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: App-Skeleton** - Sichtbare Startseite und lauffaehige Anwendungshuelle.
- [ ] **Phase 2: Basis-CI** - Automatisierte Grundpruefung von Build und Basistests im PR.
- [ ] **Phase 3: Quality- und Security-Pipeline** - Verbindliche Quality/Security-Gates blockieren fehlerhafte PRs.
- [ ] **Phase 4: Datenbasis und Migrationen** - Reproduzierbare Persistenz mit PostgreSQL, Flyway und lokalem Lauf.
- [ ] **Phase 5: Gebaeudestruktur** - Admin verwaltet Haus-zu-Raum-Struktur, User lesen freigegebene Struktur.
- [ ] **Phase 6: Authentifizierung, E-Mail-Bestaetigung und Freigabe** - Nur bestaetigte und freigegebene Nutzer erhalten Zugriff.
- [ ] **Phase 7: Grundriss-Upload** - Sichere Grundriss-Uploads pro Stockwerk inkl. Austausch und Anzeige.
- [ ] **Phase 8: Marker-Anzeige** - Typisierte Marker mit stabiler relativer Position und Statusfarben.
- [ ] **Phase 9: Marker setzen und verschieben** - Admin bereitet Marker fachlich vor, User sehen sie read-only.
- [ ] **Phase 10: Marker-Detailansicht** - User sehen Standort, Status, Luecken und moegliche Aktionen am Marker.
- [ ] **Phase 11: Heizkoerperdaten erfassen** - Vollstaendige Heizkoerperinventur inkl. Pflichtfoto und Statuslogik.
- [ ] **Phase 12: Fensterdaten erfassen** - Vollstaendige Fensterinventur inkl. Pflichtfoto und Statuslogik.
- [ ] **Phase 13: User-Marker und Deaktivierung** - User ergaenzen fehlende Marker und markieren nicht vorhandene Objekte.
- [ ] **Phase 14: Report und Export** - PDF/Tabellenexport als verwertbares Handover fuer Experten.

## Phase Details

### Phase 1: App-Skeleton
**Goal**: Nutzer koennen die Anwendung oeffnen und eine klare Startseite sehen.
**Depends on**: Nothing (first phase)
**Requirements**: FND-01
**Success Criteria** (what must be TRUE):
  1. User kann die Webanwendung im Browser oeffnen und sieht eine sichtbare Startseite.
  2. User sieht auf der Startseite den Arbeitsnamen und ein grundlegendes Layout mit Navigationsplatzhaltern.
  3. Ein E2E-Basistest prueft den Startseitenaufruf erfolgreich.
**Plans**: TBD
**UI hint**: yes

### Phase 2: Basis-CI
**Goal**: Jede Aenderung wird automatisiert gegen Build- und Testbasis geprueft.
**Depends on**: Phase 1
**Requirements**: FND-03
**Success Criteria** (what must be TRUE):
  1. Bei Pull Requests laufen Frontend-/Backend-Build und vorhandene Tests automatisch.
  2. Der Startseiten-E2E-Test laeuft in CI reproduzierbar erfolgreich.
  3. Ohne gruene CI ist kein fachlicher Fortschritt freigegeben.
**Plans**: TBD

### Phase 3: Quality- und Security-Pipeline
**Goal**: Qualitaet und Sicherheit sind als verpflichtende Merge-Gates aktiv.
**Depends on**: Phase 2
**Requirements**: FND-04
**Success Criteria** (what must be TRUE):
  1. Pull Requests werden blockiert, wenn Quality- oder Security-Checks fehlschlagen.
  2. Dependency-/Secret-/Vulnerability-Checks laufen automatisch im PR-Kontext.
  3. Renovate-Regel mit Mindestalter fuer Dependency-Updates ist wirksam konfiguriert.
**Plans**: TBD

### Phase 4: Datenbasis und Migrationen
**Goal**: Die Anwendung hat eine reproduzierbare, dauerhaft nutzbare lokale Datenbasis.
**Depends on**: Phase 3
**Requirements**: FND-02, FND-05
**Success Criteria** (what must be TRUE):
  1. Team kann Frontend, Backend, PostgreSQL und Mail-Stub lokal starten.
  2. Datenbankschema wird ueber versionierte Migrationen reproduzierbar aufgebaut.
  3. Ein E2E-Flow bestaetigt, dass Anwendung, Backend und Datenbasis gemeinsam erreichbar sind.
**Plans**: TBD

### Phase 5: Gebaeudestruktur
**Goal**: Admin kann die fachliche Struktur Haus → Stockwerk → Wohnung → Raum pflegen, User koennen sie lesen.
**Depends on**: Phase 4
**Requirements**: BLD-01, BLD-02, BLD-03, BLD-04, BLD-05
**Success Criteria** (what must be TRUE):
  1. Admin kann Haus, Stockwerke, Wohnungen und Raeume anlegen und bearbeiten.
  2. User kann freigegebene Gebaeudestruktur lesen, aber nicht veraendern.
  3. Backend erzwingt Rollenrechte fuer Struktur-Aenderungen serverseitig.
  4. Ein E2E-Test deckt den End-to-End-Flow von Strukturanlage bis User-Sicht ab.
**Plans**: TBD
**UI hint**: yes

### Phase 6: Authentifizierung, E-Mail-Bestaetigung und Freigabe
**Goal**: Nur fachlich gueltig bestaetigte und freigegebene Nutzer erhalten Zugriff auf geschuetzte Funktionen.
**Depends on**: Phase 5
**Requirements**: AUTH-01, AUTH-02, AUTH-03, AUTH-04, AUTH-05, AUTH-06
**Success Criteria** (what must be TRUE):
  1. User kann sich mit E-Mail registrieren und muss die E-Mail bestaetigen.
  2. Vorab freigegebene E-Mails werden nach Bestaetigung automatisch aktiv.
  3. Nicht vorab freigegebene User landen nach Bestaetigung im Admin-Wartezustand.
  4. Admin kann wartende User freigeben, ablehnen oder spaeter deaktivieren.
  5. Nur `ACTIVE` User koennen geschuetzte Fachfunktionen nutzen.
**Plans**: TBD
**UI hint**: yes

### Phase 7: Grundriss-Upload
**Goal**: Grundrisse koennen pro Stockwerk sicher hochgeladen, ausgetauscht und autorisiert angezeigt werden.
**Depends on**: Phase 6
**Requirements**: FLR-01, FLR-02, FLR-03, FLR-04
**Success Criteria** (what must be TRUE):
  1. Admin kann pro Stockwerk einen Grundriss hochladen und spaeter austauschen.
  2. User kann den Grundriss des ausgewaehlten Stockwerks anzeigen.
  3. Uploads werden serverseitig auf Typ, Groesse und Zugriffsschutz validiert.
  4. Dateien werden nur ueber autorisierte Backend-Endpunkte ausgeliefert.
**Plans**: TBD
**UI hint**: yes

### Phase 8: Marker-Anzeige
**Goal**: User sehen typisierte Marker mit stabiler Position und klarer Statusdarstellung auf dem Grundriss.
**Depends on**: Phase 7
**Requirements**: MRK-01, MRK-02, MRK-03
**Success Criteria** (what must be TRUE):
  1. Marker sind als `HEIZKOERPER` oder `FENSTER` typisiert sichtbar.
  2. Marker bleiben bei Zoom/Pan/Viewport-Wechseln stabil an ihrer relativen Grundrissposition.
  3. Markerstatus ist visuell fuer offen, teilweise, vollstaendig und deaktiviert unterscheidbar.
  4. Ein E2E-Test bestaetigt die Positionsstabilitaet fuer unterschiedliche Ansichten.
**Plans**: TBD
**UI hint**: yes

### Phase 9: Marker setzen und verschieben
**Goal**: Admin kann Marker fachlich vorbereiten, waehrend User sie nur lesend nutzen.
**Depends on**: Phase 8
**Requirements**: MRK-04, MRK-06
**Success Criteria** (what must be TRUE):
  1. Admin kann Marker setzen, verschieben, benennen und Raumkontext zuordnen.
  2. User sieht vorbereitete Marker sofort, kann sie aber nicht verschieben.
  3. Backend erzwingt Bearbeitungsrechte fuer Marker-Aenderungen serverseitig.
**Plans**: TBD
**UI hint**: yes

### Phase 10: Marker-Detailansicht
**Goal**: User koennen Marker oeffnen und fehlende Inventurdaten gezielt erkennen.
**Depends on**: Phase 9
**Requirements**: MRK-05
**Success Criteria** (what must be TRUE):
  1. User kann Marker antippen und eine Detailansicht oeffnen.
  2. Detailansicht zeigt Standortdaten, Status und fehlende Daten.
  3. Detailansicht zeigt fuer den Marker zulaessige Folgeaktionen.
**Plans**: TBD
**UI hint**: yes

### Phase 11: Heizkoerperdaten erfassen
**Goal**: User koennen Heizkoerper fachlich vollstaendig erfassen, inklusive Pflichtfoto und valider Statusberechnung.
**Depends on**: Phase 10
**Requirements**: INV-01, INV-02, INV-05, INV-09, INV-10
**Success Criteria** (what must be TRUE):
  1. User kann fuer Heizkoerper mindestens ein Foto erfassen oder hochladen.
  2. User kann Heizkoerpertyp, Breite, Hoehe und optionale Zusatzdaten speichern.
  3. Formulare erlauben fuer unklare Angaben den expliziten Wert `unbekannt`.
  4. Backend berechnet Markerstatus nach jeder Aenderung neu.
  5. Marker wird nur bei vollstaendigen Pflichtdaten inklusive Foto als vollstaendig angezeigt.
**Plans**: TBD
**UI hint**: yes

### Phase 12: Fensterdaten erfassen
**Goal**: User koennen Fenster fachlich vollstaendig erfassen, inklusive Pflichtfoto und validen Pflichtfeldern.
**Depends on**: Phase 11
**Requirements**: INV-03, INV-04
**Success Criteria** (what must be TRUE):
  1. User kann fuer Fenster mindestens ein Foto erfassen oder hochladen.
  2. User kann Fensterbreite, Fensterhoehe, Verglasung und Rahmenmaterial erfassen.
  3. Nach dem Speichern sind Fensterdaten im Markerkontext nachvollziehbar verfuegbar.
**Plans**: TBD
**UI hint**: yes

### Phase 13: User-Marker und Deaktivierung
**Goal**: User koennen fehlende Objekte vor Ort ergaenzen und nicht vorhandene Marker mit Nachweis deaktivieren.
**Depends on**: Phase 12
**Requirements**: INV-06, INV-07, INV-08
**Success Criteria** (what must be TRUE):
  1. User kann neue Heizkoerper-/Fenster-Marker direkt auf dem Grundriss hinzufuegen.
  2. Neu hinzugefuegte Marker sind sofort fuer andere User sichtbar und gekennzeichnet.
  3. User kann Marker als nicht vorhanden markieren, nur mit Grund und Foto-Nachweis.
  4. Deaktivierte Marker erscheinen im Status als deaktiviert/grau.
**Plans**: TBD
**UI hint**: yes

### Phase 14: Report und Export
**Goal**: Inventurdaten koennen als verwertbarer Report/Export fuer den Energieeffizienz-Experten uebergeben werden.
**Depends on**: Phase 13
**Requirements**: RPT-01, RPT-02, RPT-03, RPT-04, RPT-05, RPT-06
**Success Criteria** (what must be TRUE):
  1. User oder Admin kann Reports fuer Projekt, Haus, Stockwerk oder Wohnung erzeugen.
  2. Report sortiert strikt nach Haus → Stockwerk → Wohnung → Raum → Marker.
  3. Report markiert fehlende, teilweise und vollstaendige Daten klar unterscheidbar.
  4. Report kennzeichnet User-Marker sowie deaktivierte Marker mit Begruendung.
  5. Anwendung liefert mindestens PDF und tabellarischen Export mit fachlich nutzbar komprimierten Fotos.
**Plans**: TBD
**UI hint**: yes

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → 11 → 12 → 13 → 14

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. App-Skeleton | 0/0 | Not started | - |
| 2. Basis-CI | 0/0 | Not started | - |
| 3. Quality- und Security-Pipeline | 0/0 | Not started | - |
| 4. Datenbasis und Migrationen | 0/0 | Not started | - |
| 5. Gebaeudestruktur | 0/0 | Not started | - |
| 6. Authentifizierung, E-Mail-Bestaetigung und Freigabe | 0/0 | Not started | - |
| 7. Grundriss-Upload | 0/0 | Not started | - |
| 8. Marker-Anzeige | 0/0 | Not started | - |
| 9. Marker setzen und verschieben | 0/0 | Not started | - |
| 10. Marker-Detailansicht | 0/0 | Not started | - |
| 11. Heizkoerperdaten erfassen | 0/0 | Not started | - |
| 12. Fensterdaten erfassen | 0/0 | Not started | - |
| 13. User-Marker und Deaktivierung | 0/0 | Not started | - |
| 14. Report und Export | 0/0 | Not started | - |
