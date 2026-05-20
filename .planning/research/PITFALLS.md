# Pitfalls Research

**Domain:** Floorplan-basierte Inventur-App mit Uploads und rollenbasierten Workflows (HeizInventur)
**Researched:** 2026-05-20
**Confidence:** HIGH (projektinterne Specs) / MEDIUM (branchenweite Vergleichsquellen)

## Critical Pitfalls

### Pitfall 1: Marker-Drift durch falsches Koordinaten-/Render-Modell

**What goes wrong:**
Marker verrutschen bei Zoom, Pan, Viewport-Wechsel oder Bildaustausch. Vor-Ort erfasste Daten hängen damit am falschen Objekt.

**Why it happens:**
Teams speichern Pixel statt relativer Koordinaten oder rendern Marker außerhalb des transformierten Layers.

**How to avoid:**
- Nur `xPercent/yPercent` speichern (0–100) und serverseitig validieren.
- Grundriss + Marker immer im selben Zoom/Pan-Layer rendern.
- Beim Grundriss-Austausch explizite Re-Anker-Strategie definieren (Versionierung + Recheck).
- Akzeptanzkriterium: Marker `(50,50)` bleibt visuell mittig auf allen Ziel-Viewports.

**Warning signs:**
- Bugreports wie „auf Handy sitzt Marker falsch“.
- E2E nur auf einer Auflösung, keine Zoom/Pan-Assertions.
- Marker-Abweichungen nach Upload eines neuen Plans.

**Phase to address:**
Phase 8 (Marker-Anzeige) + Phase 9 (Setzen/Verschieben) + Regression in allen Folgephasen.

---

### Pitfall 2: Fachlogik im Frontend statt Backend-Source-of-Truth

**What goes wrong:**
Status (rot/gelb/grün/grau), Rollenrechte oder Pflichtfoto-Regeln werden clientseitig „simuliert“ und können umgangen werden.

**Why it happens:**
Schnelle UI-Prototypen werden später nicht gehärtet; API validiert unvollständig.

**How to avoid:**
- Statusberechnung ausschließlich im Backend nach jeder relevanten Änderung.
- Backend erzwingt Rollen- und Objektberechtigungen bei jedem Write-Endpunkt.
- Frontend nutzt Status nur zur Anzeige, nie als Autorisierungsentscheidung.
- Security-Integrationstests pro Endpunktgruppe (`auth`, `markers`, `files`, `reports`).

**Warning signs:**
- API akzeptiert direkte Statusupdates vom Client.
- „Versteckte“ Admin-Funktionen sind nur per UI-Guard geschützt.
- Unterschiedliche Statuswerte zwischen zwei Clients.

**Phase to address:**
Phase 6 (Auth/Freigabe), Phase 11–13 (Inventurdaten + User-Marker), hart zu verifizieren in jeder Phase per E2E + API-Tests.

---

### Pitfall 3: Unsichere Upload-Pipeline (Type-Spoofing, Pfadprobleme, offene Datei-URLs)

**What goes wrong:**
Schadhafte oder falsche Dateien landen im Storage; Dateien sind ohne Berechtigung abrufbar; Reports referenzieren unberechtigte Medien.

**Why it happens:**
Nur Dateiendung/MIME aus Request wird geprüft; Originaldateinamen werden übernommen; Download-Endpunkte prüfen Ownership/Rolle nicht sauber.

**How to avoid:**
- Upload-Policy: Größenlimit + MIME + Endung + Magic-Byte-Prüfung.
- Servergenerierte Dateinamen, keine Originalnamen im Pfad.
- Upload-Verzeichnis nie statisch/public mounten.
- Auslieferung nur via autorisierte Backend-Endpunkte mit Audit-Logging.
- Pflichtfoto-Regel serverseitig für „vollständig“ und „deaktiviert“ erzwingen.

**Warning signs:**
- Dateien sind direkt via URL-Verzeichnislisting erreichbar.
- Unterschied zwischen UI-Validierung und API-Akzeptanz.
- Incident: „falsches Foto am falschen Marker“.

**Phase to address:**
Phase 7 (Dateiablage) als Sicherheitsfundament; zusätzlich Phase 11–14 (Foto-Pflicht, Report-Einbettung).

---

### Pitfall 4: Rollenmodell driftet von fachlicher Realität (Admin/User + Zustände)

**What goes wrong:**
Nicht freigegebene User sehen Daten oder aktive User bleiben fälschlich blockiert; Admin-Freigabeprozess ist inkonsistent.

**Why it happens:**
Statusmaschine (`EMAIL_CONFIRMATION_PENDING`, `ADMIN_APPROVAL_PENDING`, `ACTIVE`, `REJECTED`, `DISABLED`) wird nicht als harter Workflow umgesetzt.

**How to avoid:**
- Explizite State-Machine im Backend mit erlaubten Transitionen.
- Jede Transition mit Ereignis-Log (wer, wann, warum).
- Bootstrap-Admin sicher und idempotent (nur wenn kein Admin existiert).
- E2E-Matrix für alle Statuspfade inkl. Pre-Approved-E-Mail.

**Warning signs:**
- „Sonderfälle“ werden manuell in DB gefixt.
- Mehrdeutige UI-Meldungen zum Account-Status.
- Freigabe-/Ablehnungsaktionen ohne nachvollziehbares Audit.

**Phase to address:**
Phase 6 primär; Regression in Phasen 7–14 (jeder fachliche Flow muss Status korrekt respektieren).

---

### Pitfall 5: Datenvollständigkeit wird mit „schönem UI“ verwechselt

**What goes wrong:**
Marker erscheinen „fertig“, obwohl Pflichtfelder fehlen oder „unbekannt“ nicht sauber dokumentiert ist. Report ist dann fachlich unbrauchbar.

**Why it happens:**
Validierungen sind inkonsistent zwischen Heizkörper/Fenster; „unbekannt“ wird nicht als legitimer Pflichtwert modelliert; fehlende Daten werden im Report nicht klar markiert.

**How to avoid:**
- Einheitliche Pflichtfeldregeln als zentrale Backend-Policy.
- „Unbekannt“ als explizit erlaubter Wert statt Workaround/Freitext.
- Report-Generator markiert fehlend (rot), teilweise/unklar (gelb), vollständig klar.
- Contract-Tests für Statusberechnung je Markertyp + Datenkonstellation.

**Warning signs:**
- Hohe Quote später Korrekturen im Export.
- Nutzer raten Werte statt „unbekannt“ zu wählen.
- Unterschiedliche Vollständigkeitsbewertung zwischen UI und PDF.

**Phase to address:**
Phase 11/12 (Erfassungslogik), Phase 14 (Report als Wahrheitsprüfung).

---

### Pitfall 6: Fehlende Konfliktstrategie bei paralleler Vor-Ort-Erfassung

**What goes wrong:**
Zwei Nutzer bearbeiten denselben Marker; letzter Schreibvorgang überschreibt still den ersten (Lost Update).

**Why it happens:**
Kein Optimistic Locking/Versionsfeld; keine UI-Hinweise bei zwischenzeitlicher Änderung.

**How to avoid:**
- Versionierung (`version`/ETag) auf Marker- und Inventurdatensätzen.
- Konfliktantwort (409) mit Merge-/Reload-UX.
- Änderungs-Feed „zuletzt geändert von/um“ in Marker-Detailansicht.

**Warning signs:**
- Nutzer melden „meine Eingaben sind verschwunden“.
- Auffällig viele schnelle Folgeupdates am selben Marker.

**Phase to address:**
Phase 10–13 (Detail + Erfassung + User-Marker).

---

### Pitfall 7: Report wird zu spät als Produktkern behandelt

**What goes wrong:**
Datenschema/Flows sind fertig, aber Export unvollständig: falsche Sortierung, fehlende Kennzeichnung von User-Markern/Deaktivierungen, zu große PDFs wegen Bildern.

**Why it happens:**
Report erst am Ende „draufgesetzt“ statt früh als Abnahmekriterium mitgeführt.

**How to avoid:**
- Bereits ab Phase 5 Datenmodell strikt auf Sortierkette ausrichten: Haus→Stockwerk→Wohnung→Raum→Marker.
- Ab Phase 11 Snapshot-Exports als technische Trockenübung (auch wenn Layout noch roh).
- Bildkompression + Größenbudgets vor Phase 14 festlegen.

**Warning signs:**
- „CSV/PDF später“ bleibt lange offen.
- Report-Tests fehlen bis kurz vor Abschluss.

**Phase to address:**
Vorbereitung ab Phase 5, technische Vorstufe in 11–13, fachlicher Abschluss in Phase 14.

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Markerposition in Pixeln speichern | Schnellster MVP | Migration + Drift-Bugs auf allen Geräten | Nie |
| Uploads ohne Magic-Byte-Prüfung | Weniger Backend-Code | Sicherheitsrisiko + Datenmüll | Nie |
| Status im Frontend „hardcoden“ | Schnelle UI-Demo | Fachinkonsistenz, Manipulationsrisiko | Nur als sehr kurzer Mock vor echter API |
| Keine Optimistic-Locking-Strategie | Einfachere CRUD-Implementierung | Verlorene Vor-Ort-Daten, Vertrauensverlust | Nur bis erste Multi-User-Tests starten |

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| Mailpit/SMTP | Tests prüfen nur „Mail gesendet“, nicht Token-Flow | E2E prüft kompletten Confirm-Link und Statusübergang |
| PostgreSQL + Flyway | Hotfix direkt in DB statt Migration | Jede Schemaänderung nur über versionierte Migration |
| Playwright E2E | Nur Happy Path, keine Rollen-/Fehlerfälle | Pro Phase mindestens 1 Hauptfluss + 1 Negativfall für kritische Regeln |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Unkomprimierte Fotos in Report | Sehr große PDFs, Timeouts | Serverseitige Kompression + Thumbnail-Pipeline | Spürbar ab ~200–400 Fotos/Report |
| Marker-Render ohne Virtualisierung/Clustering | Ruckeln auf mobilen Geräten | Lightweight Marker-Layer, selektives Re-Rendern | Ab ~500+ Markern pro Plan |
| N+1-Queries bei Report-Datenaufbau | Langsame Exporte | Gezielt joinen/projizieren, Report-Read-Model | Ab mittleren Datenbeständen (mehrere Häuser) |

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| Dateiabruf nur über „kennt URL“ | Datenabfluss zwischen Wohnungen/Häusern | Autorisierung pro Datei gegen Marker-/Gebäudekontext prüfen |
| Admin-Rechte nur in UI verstecken | Privilege Escalation über direkte API-Aufrufe | Backend `deny-by-default` + rollenbasierte Endpunkt-Policies |
| Tokens/Passwörter in Logs | Account-Übernahme | Redaction-Policy + Security-Log-Tests |

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Zu viele Felder in einem Schritt | Abbrüche bei Vor-Ort-Erfassung | Geführte, kurze Form-Schritte mit klarer Fortschrittsanzeige |
| Statusfarben ohne Textkontext | Missverständnisse (rot = „Fehler“) | Farbe + Klartext + „was fehlt“-Liste |
| Kleine Touch-Targets auf Grundriss | Fehlklicks, Frust | Mobile-first Marker-Hitboxen + Bottom-Sheet-Interaktion |

## "Looks Done But Isn't" Checklist

- [ ] **Marker-Positionierung:** Sieht auf Desktop richtig aus — verifiziere Zoom/Pan + Smartphone + Tablet.
- [ ] **Auth/Freigabe:** Login klappt — verifiziere alle User-Statuspfade inkl. REJECTED/DISABLED.
- [ ] **Foto-Pflicht:** Upload-Button vorhanden — verifiziere, dass ohne Foto niemals `GREEN` entsteht.
- [ ] **Report:** PDF erzeugt — verifiziere Sortierung, fehlende Daten-Markierung, User-Marker-Flag, Deaktivierungsgrund.

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Marker-Drift im Bestand | HIGH | Migrationsskript für Koordinaten + manuelle Stichproben-Rekalibrierung + Regressions-E2E auf mehrere Viewports |
| Upload-Sicherheitslücke | HIGH | Upload-Endpunkte sofort sperren/härten, kompromittierte Dateien quarantänen, Zugriffsaudits auswerten |
| Status-Logik inkonsistent | MEDIUM | Zentrale Regelengine einführen, Backfill-Job für Status-Neuberechnung, Contract-Tests ergänzen |
| Lost Updates | MEDIUM | Optimistic Locking nachrüsten, Konfliktdialog einführen, kritische Marker via Audit revalidieren |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Marker-Drift | 8–9 | E2E: feste Markerposition über Geräteklassen + Zoom/Pan |
| Frontend-Only Fachlogik | 6, 11–13 | API-/Security-Tests: unerlaubte Status- und Rollenaktionen scheitern |
| Unsichere Uploads | 7, 11–14 | Integrationstests für Typ/Größe/Magic Bytes + Auth-Download-Checks |
| Rollen-/Status-Drift | 6 | E2E-Matrix für alle Statusübergänge und Admin-Aktionen |
| Unvollständige Inventurdaten | 11–12, 14 | Contract-Tests Statusregeln + Report-Assertions fehlender Daten |
| Lost Updates | 10–13 | Konkurrenztest: parallele Updates erzeugen 409 + kein stilles Überschreiben |
| Report als Spätfeature | 5, 11–14 | Frühzeitige Snapshot-Exports, finale E2E-Reportprüfungen |

## Phase-Specific Warnings & Tests

| Phase Topic | Likely Pitfall | Mitigation | Required Test Signal |
|-------------|---------------|------------|----------------------|
| Phase 6 Auth/Freigabe | falsche Statusübergänge | harte State-Machine + Auditlog | E2E: pre-approved auto-activation + pending flow + reject/disable |
| Phase 7 Upload | unautorisierter Dateizugriff | secure file service, no public dir | API-Test: Fremduser kann Datei nicht laden (403/404) |
| Phase 8–9 Marker | Koordinaten-Drift | relativer Layer + Transform-Tests | E2E: gleiche Position auf mobile/desktop + zoom |
| Phase 11–12 Inventur | „grün ohne Pflichtfoto“ | backend policy engine | Contract-Test: ohne Foto bleibt rot/gelb |
| Phase 13 User-Marker | Datenchaos durch Duplikate | Kennzeichnung + Konfliktregeln + Deaktivierungsnachweis | E2E: User-Marker sichtbar, deaktivieren nur mit Foto |
| Phase 14 Report | fachlich unbrauchbarer Export | früh gestartete Report-Read-Model-Tests | E2E: Sortierung + Kennzeichnungen + fehlende Daten farblich |

## Sources

- Projektspezifikation: `/home/philipp/Dokumente/code/hausbestand/heiz-inventur-inspec.md` (HIGH)
- Technische Spezifikation: `/home/philipp/Dokumente/code/hausbestand/heiz-inventur-technical-spec.md` (HIGH)
- Projektkontext: `/home/philipp/Dokumente/code/hausbestand/.planning/PROJECT.md` (HIGH)
- OWASP File Upload Cheat Sheet (MEDIUM, domänenübergreifende Absicherung): https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html
- Playwright Best Practices (MEDIUM, E2E-Stabilität): https://playwright.dev/docs/best-practices

---
*Pitfalls research for: HeizInventur*
*Researched: 2026-05-20*
