# Abwesenheiten-Formulare - Quick Start

## Formulare

1. **frm_Abwesenheiten.html** - Abwesenheitsverwaltung (CRUD)
2. **frm_abwesenheitsuebersicht.html** - Kalender-Übersicht
3. **frm_MA_Abwesenheit.html** - Mitarbeiter-Abwesenheitsplanung

## Schnellstart

### 1. API-Server starten
```bash
cd "C:\Users\guenther.siegert\Documents\Access Bridge"
python api_server.py
```

Server läuft auf: `http://localhost:5000`

### 2. Formular öffnen
Einfach HTML-Datei im Browser öffnen oder über Access WebView2.

### 3. Funktionen testen
- **Neu:** Erstellt leeren Datensatz
- **Speichern:** POST (neu) oder PUT (bearbeitet)
- **Löschen:** DELETE mit Bestätigung
- **Filter:** Nach Mitarbeiter und Zeitraum

## API-Endpoints

```javascript
GET    /api/abwesenheiten          // Liste
GET    /api/abwesenheiten/:id      // Einzeln
POST   /api/abwesenheiten          // Erstellen
PUT    /api/abwesenheiten/:id      // Aktualisieren
DELETE /api/abwesenheiten/:id      // Löschen
GET    /api/mitarbeiter            // Mitarbeiter-Liste
GET    /api/dienstplan/gruende     // Abwesenheitsgründe
```

## Datenbankstruktur

**Tabelle:** `tbl_MA_NVerfuegZeiten`

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| NV_ID | AutoNumber | Primärschlüssel |
| MA_ID | Number | Mitarbeiter-ID (FK) |
| vonDat | Date/Time | Von-Datum |
| bisDat | Date/Time | Bis-Datum |
| Grund | Text | Urlaub, Krank, Privat, etc. |
| Ganztaegig | Yes/No | Ganztägig oder stundenweise |
| vonZeit | Text | Von-Zeit (bei stundenweise) |
| bisZeit | Text | Bis-Zeit (bei stundenweise) |
| Bemerkung | Memo | Zusätzliche Info |

## Troubleshooting

### Server nicht erreichbar
```bash
# Test ob Server läuft
curl http://localhost:5000/api/mitarbeiter
```

### Formulare laden nicht
- Browser-Console öffnen (F12)
- Network-Tab prüfen auf 404/500 Fehler
- CORS-Fehler? → api_server.py CORS aktivieren

### Keine Daten sichtbar
- API-Response prüfen (Network-Tab)
- Console-Log checken auf JS-Fehler
- Bridge-Client Cache leeren: `Bridge.cache.clear()`

## Features

✅ **CRUD** - Erstellen, Lesen, Aktualisieren, Löschen
✅ **Filter** - Nach Mitarbeiter, Zeitraum, Grund
✅ **Navigation** - Erster, Vorheriger, Nächster, Letzter
✅ **Caching** - Performance-Optimierung
✅ **Validation** - Pflichtfelder, Datumslogik
✅ **WebView2** - Access-Integration
✅ **Export** - CSV, Drucken
✅ **Responsive** - Modern Layout

## Weitere Infos

Detaillierte Dokumentation: `../ABWESENHEITEN_API_BERICHT.md`
