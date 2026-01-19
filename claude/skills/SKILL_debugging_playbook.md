# SKILL: Debug Playbook (WebForm in Access)

## 1) Bridge
- Prüfen: `window.chrome.webview` vorhanden (Host abhängig)
- Prüfen: `window.Bridge` existiert

## 2) Daten
- Datentypen normalisieren (Null/Datum/Zahl)
- RecordSource/Filter/Sort nachvollziehen

## 3) Events
- Doppel-Trigger vermeiden (OnCurrent vs load)
- Reentrancy-Schutz

## 4) UI
- TabIndex / Fokusreihenfolge
- Subform-Lifecycle (load child after parent)
