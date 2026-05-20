# Phase 1 Research: App-Skeleton

**Phase:** 1 (App-Skeleton)  
**Date:** 2026-05-20  
**Requirements:** FND-01

## Research Summary

- Empfohlener Start fuer Phase 1: **nur Frontend-App-Shell + Startseite + E2E-Basistest**.
- Stack-Vorgabe aus Projektkontext: Vue 3 + TypeScript + Vite, Playwright fuer E2E.
- Keine Auth-, Backend- oder DB-Funktionalitaet in dieser Phase vorziehen (Roadmap-Treue).

## Implementation Guidance for Planning

1. Erzeuge ein lauffaehiges Vue-3/TS/Vite-Frontend mit mobiler Startseite.
2. Startseite zeigt klar den Arbeitsnamen **HeizInventur** und Navigationsplatzhalter.
3. Integriere Playwright-Basistest fuer Startseitenaufruf.
4. Halte Verifikation schlank und automatisierbar (<60s je Check, soweit moeglich).

## Risks / Pitfalls

- Zu fruehes Einbauen spaeterer Phasen (Auth/Backend/DB) vergroessert Scope unnoetig.
- Fehlende mobile Basis (Viewport) konterkariert Zielgruppe.
- E2E-Test darf nicht auf instabilen Texten beruhen; stabile Locatoren vorsehen.

## Recommendation

Plane eine einzelne, fokussierte PLAN.md fuer Phase 1 mit 2-3 Tasks:
- App-Shell + Startseite
- Playwright-Basistest + Skripte
- Abschliessende automatisierte Verifikation

## RESEARCH COMPLETE
