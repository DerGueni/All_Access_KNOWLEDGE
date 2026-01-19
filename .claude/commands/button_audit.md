# Button-Funktionalitäts-Audit: frm_va_Auftragstamm.html

## Auftrag
Teste ALLE Buttons in `04_HTML_Forms/forms3/frm_va_Auftragstamm.html` auf tatsächliche Funktionalität.

## Vorgehen

### 1. Skills laden
```
Lies: 0_Claude_Skills/consys-button-fixer/SKILL.md
Lies: HTML_RULES.txt
```

### 2. Button-Inventar erstellen
Finde alle Buttons in der HTML-Datei:
- `<button>` Elemente
- `<input type="button">`
- Elemente mit `onclick`
- Elemente mit `@click` oder Event-Listener

### 3. Pro Button prüfen

| Prüfpunkt | Wie testen |
|-----------|------------|
| onclick vorhanden? | Grep nach `id` + `onclick` |
| JS-Funktion existiert? | Suche in `logic/frm_va_Auftragstamm.logic.js` |
| API-Endpoint existiert? | Prüfe `06_Server/api_server.py` |
| Funktion ausführbar? | Trace den Code-Pfad |

### 4. Ausgabe-Format

Erstelle Tabelle:

```markdown
| Button-ID | Label | onclick | JS-Funktion | API-Endpoint | Status |
|-----------|-------|---------|-------------|--------------|--------|
| btnSave | Speichern | saveData() | ✅ vorhanden | /api/save | ✅ OK |
| btnDelete | Löschen | - | ❌ fehlt | - | ❌ DEFEKT |
```

### 5. Detailbericht pro defektem Button

Für jeden Button mit Status ❌:
- Was fehlt genau?
- Wo müsste es sein?
- Vorgeschlagener Fix (ohne auszuführen!)

## Einschränkungen
- KEINE Änderungen vornehmen
- NUR analysieren und dokumentieren
- Ergebnis als `BUTTON_AUDIT_frm_va_Auftragstamm.md` speichern

## Start
Beginne mit: `cat 04_HTML_Forms/forms3/frm_va_Auftragstamm.html | grep -i "button\|onclick\|btn"`
