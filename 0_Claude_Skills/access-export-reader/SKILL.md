# Access Export Reader Skill

## Zweck
Liest exportierte Access-Datenbank-Strukturen für HTML-Formular-Migration.

## 🚀 SCHNELLZUGRIFF (Index-Dateien)

### 1. BUTTON_LOOKUP.json - Button finden
```json
{
  "btnSchnellPlan": {
    "form": "frm_VA_Auftragstamm",
    "caption": "Mitarbeiterauswahl",
    "hasOnClick": true,
    "vbaFile": "exports/vba/forms/Form_frm_VA_Auftragstamm.bas"
  }
}
```
**Nutzen:** Button-Name eingeben → sofort Formular + VBA-Datei finden

### 2. VBA_EVENT_MAP.json - Events finden
```json
{
  "OnClick": [
    {"form": "frm_VA_Auftragstamm", "control": "btnSchnellPlan", "vbaFunc": "btnSchnellPlan_Click"}
  ],
  "AfterUpdate": [...]
}
```
**Nutzen:** "Alle OnClick-Events" oder "Alle AfterUpdate-Events" finden

### 3. MASTER_INDEX.json - Formular-Übersicht
```json
{
  "forms": [
    {"name": "frm_VA_Auftragstamm", "buttons": ["btnSchnellPlan", "btnMailEins", ...], "buttonCount": 45}
  ]
}
```
**Nutzen:** Schnelle Übersicht welche Buttons ein Formular hat

### 4. FORM_DETAIL_INDEX.json - Alle Dateien zu einem Formular
```json
{
  "frm_VA_Auftragstamm": {
    "controls": "exports/forms/frm_VA_Auftragstamm/controls.json",
    "vba": "exports/vba/forms/Form_frm_VA_Auftragstamm.bas"
  }
}
```

## Workflow

### Button reparieren
1. `BUTTON_LOOKUP.json` → Button-Name suchen
2. VBA-Datei öffnen → `[ButtonName]_Click` Funktion finden
3. Logik in JavaScript übertragen

### Neuen API-Endpoint erstellen
1. `VBA_EVENT_MAP.json` → AfterUpdate-Events finden
2. VBA-Code analysieren → welche Tabellen/Queries verwendet
3. `exports/queries/*.sql` → SQL-Syntax prüfen

## Trigger-Keywords
- "button", "onclick", "click-event"
- "vba funktion", "event handler"
- "formular export", "access export"

## Export aktualisieren
```vba
Call ExportUltimate
```
