# Event-Daten Web-Scraper - Integration Guide

## Übersicht
Automatischer Web-Scraper für Event-Informationen (Einlass, Beginn, Ende) basierend auf Auftragsdaten.

## Komponenten

### 1. JavaScript Client
**Datei:** `04_HTML_Forms/forms/frm_va_Auftragstamm_eventdaten.logic.js`

**Features:**
- Request-Caching (verhindert doppelte API-Calls)
- Loading-States (verhindert parallele Requests)
- Automatisches Formular-Füllen
- Fallback bei Fehlern
- Reload-Funktion (Cache umgehen)

**Verwendung:**
```javascript
// 1. Script einbinden
<script src="frm_va_Auftragstamm_eventdaten.logic.js"></script>

// 2. Event-Daten laden
const va_id = 12345;
await eventDatenLoader.autoLoad(va_id);

// 3. Custom Field Mapping
const customMap = {
    einlass: 'mein_einlass_feld',
    beginn: 'mein_beginn_feld',
    ende: 'mein_ende_feld',
    infos: 'mein_info_feld',
    weblink: 'mein_link_feld'
};
await eventDatenLoader.autoLoad(va_id, customMap);

// 4. Nur Daten laden (ohne Formular)
const data = await eventDatenLoader.ladeEventDaten(va_id);
console.log(data);
// {
//   einlass: "18:00",
//   beginn: "20:00",
//   ende: "23:00",
//   infos: "Einlass: 18:00 | Beginn: 20:00 | Ende: 23:00",
//   weblink: "https://...",
//   suchbegriffe: "Konzert Arena München 15.01.2025",
//   timestamp: "2025-01-15T10:30:00.000Z"
// }

// 5. Reload (Cache umgehen)
await eventDatenLoader.reload(va_id);

// 6. Cache leeren
eventDatenLoader.clearCache();
```

### 2. Python API Endpoint
**Datei:** `api_server_eventdaten_endpoint.py`

## Installation

### Schritt 1: Python-Pakete installieren
```bash
cd "C:\Users\guenther.siegert\Documents\Access Bridge"
pip install requests beautifulsoup4
```

### Schritt 2: Imports in api_server.py hinzufügen
Füge am Anfang der Datei (nach den anderen Imports) hinzu:
```python
import requests
from bs4 import BeautifulSoup
from urllib.parse import quote_plus
import re
```

### Schritt 3: Endpoint-Code in api_server.py einfügen
Kopiere den kompletten Code aus `api_server_eventdaten_endpoint.py` und füge ihn in `api_server.py` ein.

**Empfohlene Position:**
- Nach den anderen API-Routen (z.B. nach `/api/auftraege/...`)
- Vor dem Server-Start (`if __name__ == '__main__':`)
- Etwa bei Zeile 2900-3000

### Schritt 4: Server neu starten
```bash
# 1. Alten Server stoppen (falls läuft)
# Ctrl+C im Terminal oder:
taskkill /F /IM python.exe /FI "WINDOWTITLE eq api_server.py"

# 2. Server starten
cd "C:\Users\guenther.siegert\Documents\Access Bridge"
python api_server.py
```

### Schritt 5: Testen
```bash
# Test-Request (ersetze 12345 mit echter VA_ID)
curl http://localhost:5000/api/eventdaten/12345

# Oder im Browser:
http://localhost:5000/api/eventdaten/12345
```

## API Endpoint Dokumentation

### Request
```
GET /api/eventdaten/<va_id>
```

**Parameter:**
- `va_id` (int, required): Auftrags-ID aus `tbl_VA_Auftragstamm`

### Response (Success)
```json
{
  "success": true,
  "data": {
    "einlass": "18:00",
    "beginn": "20:00",
    "ende": "23:00",
    "infos": "Einlass: 18:00 | Beginn: 20:00 | Ende: 23:00",
    "weblink": "https://www.eventim.de/event/...",
    "suchbegriffe": "Konzert Arena München 15.01.2025 Veranstalter GmbH",
    "timestamp": "2025-01-15T10:30:00.000Z"
  }
}
```

### Response (Not Found)
```json
{
  "success": false,
  "error": "Auftrag mit ID 12345 nicht gefunden"
}
```

### Response (No Data Found)
```json
{
  "success": true,
  "data": {
    "einlass": "Keine Infos verfügbar",
    "beginn": "Keine Infos verfügbar",
    "ende": "Keine Infos verfügbar",
    "infos": "Keine Event-Informationen gefunden für: Konzert...",
    "weblink": "",
    "suchbegriffe": "Konzert Arena München 15.01.2025",
    "timestamp": "2025-01-15T10:30:00.000Z"
  }
}
```

## Scraping-Strategie

### 1. Datenbank-Abfrage
```sql
SELECT
    a.Auftrag,           -- Event-Name
    a.Objekt,            -- Veranstaltungsort
    a.Dat_VA_Von,        -- Datum
    k.kun_Firma,         -- Kunde/Veranstalter
    o.Ob_Ort,            -- Stadt/Ort
    o.Ob_PLZ,
    o.Ob_Stadt
FROM tbl_VA_Auftragstamm a
LEFT JOIN tbl_KD_Kundenstamm k ON a.Veranstalter_ID = k.kun_Id
LEFT JOIN tbl_OB_Objekt o ON a.Objekt_ID = o.ID
WHERE a.ID = ?
```

### 2. Suchbegriffe zusammenbauen
```
"{Auftrag} {Objekt} {Ort} {Datum} {Kunde}"
Beispiel: "FC Bayern Allianz Arena München 15.01.2025 FC Bayern GmbH"
```

### 3. Web-Suche (Priorität)
1. **Google** - Generelle Suche nach Event-Infos
2. **Eventim.de** - Ticket-Plattform (Konzerte, Shows)
3. **Stadionwelt.de** - Fußball-Events (falls "bundesliga" oder "fußball" im Namen)

### 4. Pattern-Matching
```python
# Einlass
r'(?:Einlass|Einlasszeit|Doors)[:\s]+(\d{1,2}[:.\s]?\d{2})'

# Beginn
r'(?:Beginn|Start|Anpfiff|Kickoff)[:\s]+(\d{1,2}[:.\s]?\d{2})'

# Ende
r'(?:Ende|bis)[:\s]+(\d{1,2}[:.\s]?\d{2})'
```

## Formular-Integration

### HTML-Struktur (Beispiel)
```html
<div class="event-info">
    <div class="form-group">
        <label>Einlass:</label>
        <input type="text" id="txt_einlass" readonly>
    </div>

    <div class="form-group">
        <label>Beginn:</label>
        <input type="text" id="txt_beginn" readonly>
    </div>

    <div class="form-group">
        <label>Ende:</label>
        <input type="text" id="txt_ende" readonly>
    </div>

    <div class="form-group">
        <label>Infos:</label>
        <textarea id="txt_event_infos" rows="3" readonly></textarea>
    </div>

    <div class="form-group">
        <label>Link:</label>
        <a id="txt_weblink" href="#" target="_blank">Event-Website</a>
    </div>

    <button onclick="ladeEventDatenManual()">Event-Daten aktualisieren</button>
</div>

<script src="frm_va_Auftragstamm_eventdaten.logic.js"></script>
<script>
    // Automatisch beim Laden
    document.addEventListener('DOMContentLoaded', async () => {
        const va_id = new URLSearchParams(window.location.search).get('va_id');
        if (va_id) {
            await eventDatenLoader.autoLoad(va_id);
        }
    });

    // Manueller Reload-Button
    async function ladeEventDatenManual() {
        const va_id = new URLSearchParams(window.location.search).get('va_id');
        if (va_id) {
            await eventDatenLoader.reload(va_id);
            alert('Event-Daten aktualisiert!');
        }
    }
</script>
```

## Performance-Optimierung

### JavaScript Client
- **Caching:** Verhindert doppelte API-Requests
- **Loading-States:** Verhindert parallele Requests für gleiche VA_ID
- **Async/Await:** Non-blocking UI

### Python Server
- **Timeout:** 5 Sekunden pro Web-Request
- **Error-Handling:** Fallback bei fehlgeschlagenen Requests
- **Logging:** Alle Requests werden geloggt

## Bekannte Einschränkungen

1. **Web-Scraping ist fragil:**
   - HTML-Struktur kann sich ändern
   - Websites können Scraping blockieren
   - Rate-Limiting möglich

2. **Keine Garantie für Vollständigkeit:**
   - Nicht alle Events haben öffentliche Infos
   - Manche Infos sind nur nach Login verfügbar

3. **Performance:**
   - Web-Requests dauern 1-5 Sekunden
   - Bei vielen Aufträgen kann es langsam werden

4. **Rechtliches:**
   - Beachte robots.txt der Websites
   - Nur für interne Nutzung gedacht

## Erweiterungsmöglichkeiten

### Weitere Datenquellen
```python
def search_ticketmaster(query):
    # Ticketmaster API
    pass

def search_facebook_events(query):
    # Facebook Events
    pass

def search_venue_website(objekt_name):
    # Direkt auf Location-Website
    pass
```

### Erweiterte Pattern
```python
# Preise
r'(?:ab|Preis)[:\s]+(\d+[,.]?\d*)\s*€'

# Kategorie
r'(?:Kategorie|Genre)[:\s]+([A-Za-z\s]+)'

# Altersfreigabe
r'(?:FSK|ab)[:\s]+(\d+)'
```

### Datenbank-Speicherung
```python
# Event-Daten in Access speichern
cursor.execute("""
    UPDATE tbl_VA_Auftragstamm
    SET
        VA_Einlass = ?,
        VA_Beginn = ?,
        VA_Ende = ?,
        VA_Weblink = ?
    WHERE ID = ?
""", (einlass, beginn, ende, weblink, va_id))
```

## Troubleshooting

### Problem: "Module not found: requests"
**Lösung:**
```bash
pip install requests beautifulsoup4
```

### Problem: "Connection refused"
**Lösung:**
```bash
# Server läuft nicht - starten:
cd "C:\Users\guenther.siegert\Documents\Access Bridge"
python api_server.py
```

### Problem: "Keine Infos verfügbar"
**Mögliche Ursachen:**
1. Event ist nicht öffentlich bekannt
2. Suchbegriffe zu unspezifisch
3. Website blockiert Scraping

**Lösung:**
- Suchbegriffe prüfen (siehe `suchbegriffe` in Response)
- Manuell auf Website suchen
- Andere Datenquellen hinzufügen

### Problem: "Scraping dauert zu lange"
**Lösung:**
```python
# Timeout anpassen in scraping-Funktionen
response = requests.get(url, timeout=3)  # Von 5 auf 3 reduzieren
```

## Testing

### Manueller Test
```bash
# Terminal 1: Server starten
cd "C:\Users\guenther.siegert\Documents\Access Bridge"
python api_server.py

# Terminal 2: Test-Request
curl http://localhost:5000/api/eventdaten/123
```

### Browser-Test
```javascript
// Browser Console
fetch('http://localhost:5000/api/eventdaten/123')
    .then(r => r.json())
    .then(data => console.log(data));
```

### Formular-Test
1. HTML-Formular öffnen
2. VA_ID eingeben/auswählen
3. "Event-Daten laden" Button klicken
4. Felder sollten gefüllt werden

## Support

Bei Problemen prüfen:
1. Ist API-Server aktiv? (`netstat -ano | findstr :5000`)
2. Sind Python-Pakete installiert? (`pip list | findstr requests`)
3. Sind Logs vorhanden? (`C:\Users\guenther.siegert\Documents\Access Bridge\logs\api_server.log`)
4. Browser Console auf Fehler prüfen (F12)

## Changelog

### Version 1.0 (2025-01-15)
- Initiales Release
- Google, Eventim, Stadionwelt Scraping
- JavaScript Client mit Caching
- API Endpoint mit Fallback
