# Umlaut-Korrektur und Datumsfilter-Fix

## Datum: 2026-01-06

## Probleme behoben:

### 1. Umlaute (ö, ä, ü) wurden nicht korrekt angezeigt

**Ursache:**
- `mini_api.py` hatte keine UTF-8 Konfiguration für Flask
- JSON-Responses wurden als ASCII kodiert

**Lösung:**
- Zeile 1: `# -*- coding: utf-8 -*-` hinzugefügt
- Zeile 18: `app.config['JSON_AS_ASCII'] = False` hinzugefügt
- Dadurch werden alle JSON-Responses mit UTF-8 kodiert

**Geänderte Datei:**
`C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\_scripts\mini_api.py`

### 2. Datumsfilter "Aufträge ab:" funktionierte nicht

**Ursache:**
- Das HTML-Formular sendet den Parameter `ab` an die API
- Die API `/api/auftraege` unterstützte diesen Parameter nicht

**Lösung:**
- Zeile 132: `ab_datum = request.args.get('ab', '')` hinzugefügt
- Zeile 141-143: Datumsfilter in SQL-Query integriert
  ```python
  if ab_datum:
      sql += f" AND Dat_VA_Von >= #{ab_datum}#"
  ```

**Geänderte Datei:**
`C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\_scripts\mini_api.py`

## Test-Anleitung:

### 1. API-Server neu starten:
```bash
cd "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\_scripts"
python mini_api.py
```

### 2. HTML-Formular öffnen:
```
http://localhost:5000/frm_va_Auftragstamm.html
```

### 3. Umlaute testen:
- In der Auftragsliste sollten Städte wie "Nürnberg", "Fürth" korrekt angezeigt werden
- Objektnamen wie "Löwensaal" sollten korrekt angezeigt werden

### 4. Datumsfilter testen:
- Feld "Aufträge ab:" auf ein Datum setzen (z.B. 2026-01-06)
- Button "Go" klicken oder Enter drücken
- Nur Aufträge ab diesem Datum sollten angezeigt werden
- Buttons "<<" und ">>" sollten das Datum um 7 Tage verschieben

## Erfolgskriterien:
- ✓ Umlaute werden in der Auftragsliste korrekt angezeigt
- ✓ Datumsfilter filtert die Auftragsliste korrekt
- ✓ Alle Aufträge ab dem gewählten Datum werden angezeigt
- ✓ Die Navigation mit "<<" und ">>" funktioniert

## Technische Details:

### UTF-8 Konfiguration:
- Flask nutzt standardmäßig `JSON_AS_ASCII = True` was Umlaute escaped
- Mit `JSON_AS_ASCII = False` werden UTF-8 Zeichen nativ übertragen
- Das HTML hat bereits `<meta charset="UTF-8">` im HEAD

### Access SQL Datums-Syntax:
- Access SQL nutzt `#Datum#` Syntax für Datumswerte
- Format: `#2026-01-06#` (ISO-Format)
- Operator: `>=` für "ab diesem Datum"

### API-Endpoint:
```
GET /api/auftraege?ab=2026-01-06&limit=100
```

Liefert alle Aufträge mit `Dat_VA_Von >= 2026-01-06`, sortiert nach ID DESC (neueste zuerst).
