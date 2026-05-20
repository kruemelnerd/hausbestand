# Phase 1 UI-SPEC: App-Skeleton

**Phase:** 1  
**Status:** Ready for planning

## Zielbild

Eine mobile-first Startseite, die sofort erkennbar macht, dass die Anwendung laeuft und als HeizInventur-Projekt initialisiert ist.

## Layout Contract

- Viewport-first fuer Smartphone (Basisbreite 360-430px), sauber skalierbar bis Desktop.
- Seitenstruktur:
  1. Header mit Titel `HeizInventur`
  2. Hauptbereich mit kurzer Einfuehrung
  3. Navigationsplatzhalter als klar getrennte Kacheln/Buttons (noch ohne Zielrouten)

## Content Contract

- Pflichttext: `HeizInventur`
- Pflichttext: `Startseite`
- Platzhalterlabels:
  - `Haeuser (demnaechst)`
  - `Grundrisse (demnaechst)`
  - `Reports (demnaechst)`

## Interaction Contract

- Platzhalter sind visuell als Navigation erkennbar, aber deaktiviert (`aria-disabled="true"`).
- Kein toter Link auf nicht existierende Seiten.

## Accessibility Contract

- Semantische Landmarken (`header`, `main`, `nav`).
- Kontrast mindestens WCAG AA fuer Text auf Hintergrund.
- Tastaturfokus fuer interaktive Elemente sichtbar.

## Test Hooks

- `data-testid="app-title"` am Seitentitel.
- `data-testid="home-shell"` am Hauptcontainer.
- `data-testid="nav-placeholder-*"` pro Platzhalterkarte.

## UI-SPEC COMPLETE
