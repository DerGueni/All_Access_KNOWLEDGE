# Workflow (Stück-für-Stück, ohne Rückfragen)

## A – Analyse (Arbeitsset bauen)
- Passenden JSON-Export des Formulars finden
- RecordSource/RowSource/Filter, Events, Subforms identifizieren
- Abhängigkeiten aus DependencyLinks/Objects (falls vorhanden) ableiten

## B – UI Scaffold
- HTML Struktur 1:1 nachbauen (Tabs/Frames/GroupBoxes)
- Controls als Platzhalter rendern (IDs stabil nach Access-Namen)

## C – Datenbindung (Bridge)
- loadRecord → UI befüllen
- collect → saveRecord
- validate → Fehlermeldungen UI-seitig anzeigen
- navigate → first/prev/next/last

## D – Event Mapping
- Access-Events auf Browser-Events abbilden:
  - OnCurrent, BeforeUpdate, AfterUpdate, Click, DblClick, KeyDown
- Reentrancy verhindern (doppelte Events)

## E – Tests
- Playwright Smoke (wenn MCP aktiv)
- Optional Snapshot/Regression (nur bei Bedarf)

## F – Wissen sichern
- Pattern nach PATTERNS.md
- Entscheidungen nach DECISIONS.md
- Nächster Schritt nach TODO_NEXT.md
