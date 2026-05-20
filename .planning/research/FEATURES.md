# Feature Research

**Domain:** Mobile-first Vor-Ort-Inventur für Heizkörper/Fenster in Bestandsgebäuden
**Researched:** 2026-05-20
**Confidence:** HIGH (projektspezifische fachliche/technische Spezifikationen liegen vor)

## Feature Landscape

### Table Stakes (Users Expect These)

Features, die in diesem Domain-Setup als „Muss“ gelten. Ohne diese ist die App im Feld praktisch nicht nutzbar.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Geführte Gebäudestruktur (Haus→Stockwerk→Wohnung→Raum) | Vor-Ort-Erfassung braucht klaren Navigationskontext je Objekt | MEDIUM | Admin pflegt Struktur, User nur Leserechte; Basis für Sortierung/Export |
| Grundrissanzeige pro Stockwerk mit stabilen Markern | Kern-Arbeitsoberfläche ist „auf Plan tippen, nicht Listen raten“ | HIGH | Relative Koordinaten + gemeinsamer Zoom/Pan-Layer sind nicht verhandelbar |
| Marker-Statussystem (rot/gelb/grün/grau) mit serverseitiger Berechnung | Nicht-technische Nutzer brauchen sofort sichtbaren Erfassungsfortschritt | MEDIUM | Status darf nicht manuell gesetzt werden; Backend als Source of Truth |
| Pflichtfoto pro Marker (inkl. „nicht vorhanden“) | Dokumentationsnachweis ist fachlich zwingend für Report-Übergabe | MEDIUM | Mobile Kamera-Flow priorisieren; ohne Foto kein „vollständig“ |
| Typ-spezifische Erfassungsformulare (Heizkörper/Fenster) mit „unbekannt“-Option | Vor Ort sind Daten nicht immer eindeutig messbar/erkennbar | MEDIUM | Fehlertoleranz statt Nutzer zum Raten zwingen |
| Rollen + Freigabeprozess (E-Mail bestätigen + Admin-Freigabe) | Kleiner berechtigter Nutzerkreis; Daten dürfen nicht offen sein | HIGH | ACTIVE-Status als Zugangsvoraussetzung |
| User darf fehlende Marker ergänzen und falsche deaktivieren | Bestandspläne sind in Realität unvollständig/veraltet | HIGH | Neue Marker sofort sichtbar; Deaktivierung nur mit Grund + Foto |
| Report/Export (PDF + tabellarisch) in fester fachlicher Sortierung | Primäres Ergebnis ist Übergabe an Energieeffizienz-Experten | HIGH | Reihenfolge Haus→Stockwerk→Wohnung→Raum→Marker und Lückenkennzeichnung |

### Differentiators (Competitive Advantage)

Differenzierung für HeizInventur: nicht „mehr Features“, sondern bessere Feldtauglichkeit und Datenqualität für Laien.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Marker-Detail als mobile Bottom-Sheet mit „fehlende Daten“-Checkliste | Reduziert kognitive Last, führt Nutzer schrittweise | MEDIUM | Direkte Ableitung aus mobile-first Leitprinzipien |
| Fortschrittssicht auf Haus-/Stockwerksebene (offen/teilweise/vollständig) | Teams sehen sofort, wo noch Arbeit fehlt | LOW | Hoher Nutzwert bei geringer technischer Komplexität |
| Sofort kollaborative Sichtbarkeit von User-Markern | Vermeidet Doppelarbeit bei Mehrpersonenerfassung vor Ort | MEDIUM | „Gerade hinzugefügt“-Kennzeichnung schafft Nachvollziehbarkeit |
| Strikte Report-Klarheit mit expliziten Hinweisen auf Unsicherheiten | Übergabedaten werden fachlich belastbarer statt „scheinbar vollständig“ | MEDIUM | „Unbekannt“/„teilweise“ sichtbar halten statt wegzuvalidieren |

### Anti-Features (Commonly Requested, Often Problematic)

Explizit nicht für v1 bauen, um Scope, Risiko und Fehlfokus zu vermeiden.

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| In-App-Heizlastberechnung / energetische Bewertung | Klingt nach „End-to-End-Lösung“ | Fachlich ausgeschlossen; hoher Haftungs-/Komplexitätssprung; verlangsamt MVP massiv | Sauberer, vollständiger Export für Experten-Tools |
| CAD-/Zeichenfunktionen, 3D-Grundrisse | Wirkt „professioneller“ | Verfehlt den Erfassungszweck; UX-Komplexität für Nicht-Techniker | Einfache Marker-Interaktion auf statischen Grundrissen |
| Native iOS/Android-App in v1 | Erwartung „mobile = native“ | Doppelte Plattformkomplexität ohne belegten Mehrwert in frühem Stadium | PWA-/mobile-first Web mit stabiler Kamera/Upload-UX |
| Offline-Sync mit Konfliktauflösung in v1 | Feldarbeit impliziert teils schwaches Netz | Sehr hohe Komplexität (Sync, Konflikte, Recovery); hohes Datenrisiko | v1 online-first + klare Retry-/Zwischenspeicher-UX je Eingabe |
| Öffentliche Multi-Tenant-Plattform | Skalierungsfantasie | Sicherheits-/Mandantenaufwand ohne aktuellen Bedarf | Single-Organisation mit Rollenmodell ADMIN/USER |

## Feature Dependencies

```text
Rollen & Freigabe
    └──requires──> Geschützte Erfassungsflows

Gebäudestruktur
    └──requires──> Grundriss-Upload pro Stockwerk
                       └──requires──> Marker-Anzeige (relative Position)
                                          └──requires──> Marker-Detailansicht
                                                         ├──requires──> Heizkörperformular + Pflichtfoto
                                                         ├──requires──> Fensterformular + Pflichtfoto
                                                         └──requires──> Statusberechnung im Backend

Marker ergänzen/deaktivieren
    └──enhances──> Vollständigkeit der Bestandsdaten

Status- und Vollständigkeitslogik
    └──requires──> Report/Export mit Datenlücken-Markierung
```

### Dependency Notes

- **Grundriss/Marker vor Formularen:** Ohne visuelle Objektverortung wird Datenerfassung für Zielgruppe langsam und fehleranfällig.
- **Statusberechnung im Backend vor Reporting:** Report darf keine frontend-lokale „Wunschvollständigkeit“ widerspiegeln.
- **Pflichtfoto ist Querschnitt:** Blockiert „grün“-Status und wirkt direkt auf Reportqualität.

## MVP Definition

### Launch With (v1)

- [x] Rollen, Registrierung, E-Mail-Bestätigung, Admin-Freigabe — kontrollierter Zugriff auf echte Gebäudedaten.
- [x] Gebäudestruktur + Grundriss-Upload + Markeranzeige/-detail — zentraler Vor-Ort-Arbeitsmodus.
- [x] Heizkörper- und Fenstererfassung mit Pflichtfoto + serverseitigem Status — belastbare Datenerfassung statt Teil-Dokumentation.
- [x] User-Marker hinzufügen/deaktivieren mit Nachweisfoto — Realitätstauglichkeit bei unvollständigen Plänen.
- [x] PDF + tabellarischer Export mit Vollständigkeitskennzeichnung — verwertbarer Übergabeoutput.

### Add After Validation (v1.x)

- [ ] Erweiterte Filter/Batch-Ansichten (z. B. „zeige nur offene Marker in Wohnung X“) — wenn Datensatzgröße Bedienung bremst.
- [ ] Verbesserte Medienflows (z. B. Mehrfachfoto-Optimierung, schnellere Vorschau) — wenn Fotoerfassung Hauptzeitfresser ist.
- [ ] Optionaler ZIP-Export der Originalfotos — falls Expertenprozess dies konkret fordert.

### Future Consideration (v2+)

- [ ] Offline-first mit synchroner Konfliktbehandlung — erst nach nachgewiesenem Netzproblem und stabiler Core-Domäne.
- [ ] Externes Produktiv-Deployment/Multiorg-Betrieb — nach validierter Nutzung und Betriebsanforderungen.
- [ ] Integrationen in Spezial-Tools (Energieberatung/ERP) — erst wenn Exportstandard stabil und wiederverwendet ist.

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Grundriss + Marker stabil (Zoom/Pan-resistent) | HIGH | HIGH | P1 |
| Erfassungsformulare + Pflichtfoto + Statuslogik | HIGH | MEDIUM | P1 |
| Rollen/Freigabeprozess | HIGH | HIGH | P1 |
| Report/Export mit Lückenhervorhebung | HIGH | HIGH | P1 |
| Fortschrittsanzeigen pro Haus/Stockwerk | MEDIUM | LOW | P2 |
| Kollaborative User-Marker-Sichtbarkeit | MEDIUM | MEDIUM | P2 |
| Offline-Sync | MEDIUM | HIGH | P3 |
| CAD/3D-Funktionen | LOW | HIGH | P3 |

**Priority key:**
- P1: Muss in v1 enthalten sein (sonst kein brauchbarer Feldprozess)
- P2: Soll nach erstem Nutzungsfeedback folgen
- P3: Bewusst verschieben/vermeiden

## v1 Scope Implications (mobile-first field work)

- **Screen-Ökonomie priorisieren:** wenige Felder pro Schritt, große Touch-Ziele, klare Primäraktion („Foto aufnehmen“, „Speichern“).
- **Fehlervermeidung vor Featurebreite:** harte Pflichtfelder + verständliche Hinweise statt komplexe Freiheiten.
- **Datenqualität vor Geschwindigkeitstricks:** keine „Schnell-grün“-Workarounds ohne Pflichtfoto/Pflichtdaten.
- **Arbeitsfähigkeit vor Plattformexpansion:** erst Webfluss stabilisieren, dann native/offline evaluieren.

## Sources

- /home/philipp/Dokumente/code/hausbestand/.planning/PROJECT.md (HIGH)
- /home/philipp/Dokumente/code/hausbestand/heiz-inventur-inspec.md (HIGH)
- /home/philipp/Dokumente/code/hausbestand/heiz-inventur-technical-spec.md (HIGH)

---
*Feature research for: HeizInventur field inventory domain*
*Researched: 2026-05-20*
