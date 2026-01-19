# Event-Daten Web-Scraper - README

## Übersicht
Automatischer Web-Scraper für Event-Informationen (Einlass, Beginn, Ende) basierend auf Auftragsdaten aus der Access-Datenbank.

## Erstellte Dateien

### 1. JavaScript Client
**Pfad:** `04_HTML_Forms\forms\frm_va_Auftragstamm_eventdaten.logic.js`

Wiederverwendbarer JavaScript-Client mit:
- Request-Caching
- Loading-States
- Automatisches Formular-Füllen
- Fehler-Handling
- Reload-Funktion

### 2. Python API Endpoint
**Pfad:** `api_server_eventdaten_endpoint.py`

Kompletter Python-Code für api_server.py mit:
- Endpoint: `GET /api/eventdaten/<va_id>`
- Datenbank-Abfrage (Auftrag, Objekt, Kunde, Ort, Datum)
- Web-Scraping (Google, Eventim, Stadionwelt)
- Pattern-Matching für Einlass/Beginn/Ende
- Fallback bei fehlenden Daten

### 3. Integration Guide
**Pfad:** `EVENTDATEN_SCRAPER_INTEGRATION.md`

Vollständige Dokumentation mit:
- Installation Schritt-für-Schritt
- API Dokumentation
- Code-Beispiele
- Troubleshooting
- Erweiterungsmöglichkeiten

### 4. Test-Seite
**Pfad:** `04_HTML_Forms\forms\eventdaten_test.html`

Standalone Test-Formular zum Testen des Scrapers:
- VA_ID eingeben
- Event-Daten automatisch laden
- Cache-Management
- Meta-Informationen anzeigen

### 5. Installation Script
**Pfad:** `install_eventdaten_scraper.bat`

Automatisches Setup-Script:
- Installiert Python-Pakete
- Prüft Dateien
- Zeigt nächste Schritte

## Quick Start

### Installation (5 Minuten)

1. **Python-Pakete installieren:**
   ```bash
   cd "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE"
   install_eventdaten_scraper.bat
   ```

2. **api_server.py erweitern:**

   a) Öffne: `C:\Users\guenther.siegert\Documents\Access Bridge\api_server.py`

   b) Füge am Anfang (nach anderen Imports) hinzu:
   ```python
   import requests
   from bs4 import BeautifulSoup
   from urllib.parse import quote_plus
   import re
   ```

   c) Kopiere kompletten Code aus `api_server_eventdaten_endpoint.py`

   d) Füge Code in api_server.py ein (Position: nach anderen API-Routen, vor Server-Start)

3. **Server neu starten:**
   ```bash
   cd "C:\Users\guenther.siegert\Documents\Access Bridge"
   python api_server.py
   ```

4. **Testen:**
   - Öffne: `file:///C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/04_HTML_Forms/forms/eventdaten_test.html`
   - Gib eine VA_ID ein
   - Klicke "Event-Daten laden"

### Verwendung im Formular

#### Methode 1: Auto-Load
```html
<script src="frm_va_Auftragstamm_eventdaten.logic.js"></script>
<script>
    // Automatisch beim Laden
    const va_id = 12345;
    await eventDatenLoader.autoLoad(va_id);
</script>
```

#### Methode 2: Custom Fields
```javascript
const va_id = 12345;
const customMap = {
    einlass: 'mein_einlass_feld',
    beginn: 'mein_beginn_feld',
    ende: 'mein_ende_feld',
    infos: 'mein_info_feld',
    weblink: 'mein_link_feld'
};
await eventDatenLoader.autoLoad(va_id, customMap);
```

#### Methode 3: Nur Daten (ohne Formular)
```javascript
const data = await eventDatenLoader.ladeEventDaten(va_id);
console.log(data);
// {
//   einlass: "18:00",
//   beginn: "20:00",
//   ende: "23:00",
//   infos: "Einlass: 18:00 | Beginn: 20:00",
//   weblink: "https://...",
//   suchbegriffe: "...",
//   timestamp: "2025-01-15T10:30:00"
// }
```

## Wie es funktioniert

### 1. Datenbank-Abfrage
```
Auftragstamm → Kunde → Objekt
↓
Auftrag: "FC Bayern vs. Dortmund"
Objekt: "Allianz Arena"
Ort: "München"
Datum: "15.01.2025"
Kunde: "FC Bayern München GmbH"
```

### 2. Suchbegriffe
```
"FC Bayern vs. Dortmund Allianz Arena München 15.01.2025 FC Bayern München GmbH"
```

### 3. Web-Scraping
- **Google:** Generelle Suche
- **Eventim:** Konzerte/Shows
- **Stadionwelt:** Fußball

### 4. Pattern-Matching
```
Einlass: 18:00 Uhr   → "18:00"
Beginn: 20:00 Uhr    → "20:00"
Ende: 23:00 Uhr      → "23:00"
```

### 5. Ergebnis
```json
{
  "einlass": "18:00",
  "beginn": "20:00",
  "ende": "23:00",
  "infos": "Einlass: 18:00 | Beginn: 20:00 | Ende: 23:00",
  "weblink": "https://www.eventim.de/..."
}
```

## API Endpoint

### Request
```
GET http://localhost:5000/api/eventdaten/<va_id>
```

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
    "suchbegriffe": "Konzert Arena München 15.01.2025",
    "timestamp": "2025-01-15T10:30:00.000Z"
  }
}
```

### Response (No Data)
```json
{
  "success": true,
  "data": {
    "einlass": "Keine Infos verfügbar",
    "beginn": "Keine Infos verfügbar",
    "ende": "Keine Infos verfügbar",
    "infos": "Keine Event-Informationen gefunden für: ...",
    "weblink": ""
  }
}
```

## Features

### JavaScript Client
✅ Request-Caching (verhindert doppelte API-Calls)
✅ Loading-States (verhindert parallele Requests)
✅ Automatisches Formular-Füllen
✅ Custom Field Mapping
✅ Reload-Funktion (Cache umgehen)
✅ Cache-Management
✅ Error-Handling mit Fallback

### Python Server
✅ Multi-Source Scraping (Google, Eventim, Stadionwelt)
✅ Pattern-Matching für Zeit-Formate
✅ Datenbank-Integration
✅ Logging
✅ Error-Handling
✅ Timeout-Management

## Einschränkungen

1. **Web-Scraping ist fragil**
   - HTML kann sich ändern
   - Websites können blockieren
   - Nicht 100% zuverlässig

2. **Performance**
   - 1-5 Sekunden pro Request
   - Abhängig von Web-Response

3. **Datenverfügbarkeit**
   - Nicht alle Events öffentlich
   - Manche Infos Login-geschützt

## Erweiterungen

### Weitere Datenquellen
```python
def search_ticketmaster(query):
    # Ticketmaster API
    pass

def search_bundesliga_de(query):
    # Bundesliga.de
    pass
```

### Datenbank-Speicherung
```python
# Event-Daten in Access schreiben
cursor.execute("""
    UPDATE tbl_VA_Auftragstamm
    SET VA_Einlass = ?, VA_Beginn = ?, VA_Ende = ?
    WHERE ID = ?
""", (einlass, beginn, ende, va_id))
```

### Erweiterte Daten
- Preise
- Kategorie/Genre
- Altersfreigabe
- Kapazität

## Troubleshooting

### "Module not found: requests"
```bash
pip install requests beautifulsoup4
```

### "Connection refused"
```bash
# Server starten
cd "C:\Users\guenther.siegert\Documents\Access Bridge"
python api_server.py
```

### "Keine Infos verfügbar"
- Suchbegriffe prüfen (siehe `suchbegriffe` in Response)
- Event nicht öffentlich bekannt
- Website blockiert Scraping

## Support

Bei Problemen:
1. Logs prüfen: `C:\Users\guenther.siegert\Documents\Access Bridge\logs\api_server.log`
2. Browser Console prüfen (F12)
3. Test-Seite nutzen: `eventdaten_test.html`
4. Integration Guide lesen: `EVENTDATEN_SCRAPER_INTEGRATION.md`

## Dateien-Übersicht

```
0006_All_Access_KNOWLEDGE/
├── api_server_eventdaten_endpoint.py         # Python Endpoint-Code
├── EVENTDATEN_SCRAPER_INTEGRATION.md         # Vollständige Doku
├── EVENTDATEN_SCRAPER_README.md              # Diese Datei
├── install_eventdaten_scraper.bat            # Setup-Script
└── 04_HTML_Forms/forms/
    ├── frm_va_Auftragstamm_eventdaten.logic.js  # JS Client
    └── eventdaten_test.html                      # Test-Seite
```

## Nächste Schritte

1. ✅ Installation durchführen (siehe Quick Start)
2. ✅ Test-Seite testen
3. ✅ In echtes Formular integrieren
4. ⬜ Weitere Datenquellen hinzufügen (optional)
5. ⬜ Datenbank-Speicherung implementieren (optional)

## Version

**Version:** 1.0
**Datum:** 2025-01-15
**Autor:** Claude
**Projekt:** Access Bridge - Event-Daten Scraper
