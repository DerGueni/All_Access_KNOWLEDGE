# REPORT: API-Endpoints implementiert

**Erstellt:** 2026-01-08
**Status:** ABGESCHLOSSEN

---

## Implementierte Endpoints

### 1. Excel-Export (`exportAuftragExcel`)

**Endpoint:** `POST /api/auftraege/{id}/excel-export`

**Funktion:** Erstellt Excel-Datei mit Auftragsdaten und MA-Zuordnungen (wie Access btnDruckZusage_Click)

**Request:**
```json
{
    "va_id": 123,
    "vadatum": "2026-01-08"
}
```

**Response:**
```json
{
    "success": true,
    "data": {
        "download_url": "/api/download/08-01-26 Auftrag Objekt.xlsx",
        "filename": "08-01-26 Auftrag Objekt.xlsx",
        "ma_count": 5
    }
}
```

**Datei:** `04_HTML_Forms/api/api_server.py:472-591`

---

### 2. Status setzen (`setAuftragStatus`)

**Endpoint:** `PUT /api/auftraege/{id}/status`

**Funktion:** Setzt den Auftragsstatus (wie Access Me!Veranst_Status_ID = 2)

**Request:**
```json
{
    "status_id": 2
}
```

**Response:**
```json
{
    "success": true,
    "message": "Status auf 2 gesetzt"
}
```

**Datei:** `04_HTML_Forms/api/api_server.py:444-469`

---

### 3. Folgetag kopieren (`copyToNextDay`)

**Endpoint:** `POST /api/auftraege/{id}/copy-to-next-day`

**Funktion:** Kopiert Schichten und MA-Zuordnungen zum naechsten Tag (wie Access btnPlan_Kopie_Click)

**Request:**
```json
{
    "va_id": 123,
    "current_datum": "2026-01-08",
    "current_datum_id": 456
}
```

**Response:**
```json
{
    "success": true,
    "data": {
        "schichten_count": 3,
        "zuordnungen_count": 12,
        "next_datum": "2026-01-09",
        "next_datum_id": 457
    },
    "message": "3 Schichten und 12 MA-Zuordnungen in Folgetag kopiert"
}
```

**Datei:** `04_HTML_Forms/api/api_server.py:602-718`

---

### 4. BWN senden (`sendBWN`)

**Endpoint:** `POST /api/bwn/send`

**Funktion:** Sendet Bewachungsnachweise per E-Mail (wie Access cmd_BWN_send_Click)

**Request:**
```json
{
    "va_id": 123,
    "vadatum": "2026-01-08",
    "vadatum_id": 456,
    "nur_markierte": true
}
```

**Response:**
```json
{
    "success": true,
    "data": {
        "sent_count": 8,
        "total": 12,
        "errors": null,
        "nur_markierte": true,
        "reset_markierungen": true
    },
    "message": "BWN an 8 von 12 Mitarbeiter gesendet"
}
```

**Datei:** `04_HTML_Forms/api/api_server.py:721-805`

---

### 5. Download-Route

**Endpoint:** `GET /api/download/{filename}`

**Funktion:** Download fuer exportierte Dateien

**Datei:** `04_HTML_Forms/api/api_server.py:594-599`

---

## Bridge-Mappings

Die Mappings in `webview2-bridge.js` wurden hinzugefuegt:

```javascript
// FIX 1: Excel-Export
case 'exportAuftragExcel':
    return await apiFetch(`/auftraege/${params.va_id}/excel-export`, { method: 'POST', body: JSON.stringify(params) });

// FIX 1 (Teil 2): Status setzen
case 'setAuftragStatus':
    return await apiFetch(`/auftraege/${params.va_id}/status`, { method: 'PUT', body: JSON.stringify(params) });

// FIX 2: Folgetag kopieren
case 'copyToNextDay':
    return await apiFetch(`/auftraege/${params.va_id}/copy-to-next-day`, { method: 'POST', body: JSON.stringify(params) });

// FIX 3: BWN senden
case 'sendBWN':
    return await apiFetch('/bwn/send', { method: 'POST', body: JSON.stringify(params) });
```

**Datei:** `04_HTML_Forms/forms3/js/webview2-bridge.js:908-942`

---

## Abhaengigkeiten

### Fuer Excel-Export:
```bash
pip install openpyxl
```

### Export-Verzeichnis:
Das Verzeichnis `04_HTML_Forms/api/exports/` wird automatisch erstellt.

---

## Test-Kommandos

```bash
# Health-Check
curl http://localhost:5000/api/health

# Excel-Export
curl -X POST http://localhost:5000/api/auftraege/123/excel-export \
    -H "Content-Type: application/json" \
    -d '{"vadatum": "2026-01-08"}'

# Status setzen
curl -X PUT http://localhost:5000/api/auftraege/123/status \
    -H "Content-Type: application/json" \
    -d '{"status_id": 2}'

# Folgetag kopieren
curl -X POST http://localhost:5000/api/auftraege/123/copy-to-next-day \
    -H "Content-Type: application/json" \
    -d '{"current_datum": "2026-01-08"}'

# BWN senden
curl -X POST http://localhost:5000/api/bwn/send \
    -H "Content-Type: application/json" \
    -d '{"va_id": 123, "nur_markierte": false}'
```

---

## Geaenderte Dateien

| Datei | Aenderung |
|-------|-----------|
| `04_HTML_Forms/api/api_server.py` | 4 neue Endpoints + Download-Route |
| `04_HTML_Forms/forms3/js/webview2-bridge.js` | 4 neue Bridge-Mappings |
| `04_HTML_Forms/forms3/logic/frm_va_Auftragstamm.logic.js` | 3 Frontend-Funktionen angepasst |
| `04_HTML_Forms/forms3/frm_va_Auftragstamm.html` | 1 neuer Button |

---

*Erstellt von Claude Code*
