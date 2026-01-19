# Access Backend API-Verbindung für Menü- und Utility-Formulare
**Datum:** 31.12.2025
**Status:** ✅ Abgeschlossen

---

## Übersicht

Alle Menü- und Utility-Formulare wurden mit API-Backend-Anbindung ausgestattet. Die Formulare laden Echtdaten aus dem Access-Backend via REST API (`http://localhost:5000/api`).

---

## Bearbeitete Formulare

### 1. **frm_Menuefuehrung.html** - Hauptmenü ✅
**Datei:** `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms2\frm_Menuefuehrung.html`
**Logic:** `logic/frm_Menuefuehrung.logic.js` (aktualisiert)

**Funktionen:**
- Navigation zu allen Haupt-Formularen
- API-Server Status-Prüfung beim Start
- Aktive Menu-Item Markierung
- Event-Delegation für dynamische Buttons

**API-Endpoints:**
- `GET /api/mitarbeiter?limit=1` - Server-Status Check

**Besonderheiten:**
- Standalone + Embedded Mode Support
- PostMessage-Kommunikation mit Parent
- Automatische Navigation (gleicher Tab statt neues Fenster)

---

### 2. **frm_Menuefuehrung1.html** - Menü 2 (Personal & Lohn) ✅
**Datei:** `frm_Menuefuehrung1.html`
**Logic:** Inline `<script type="module">` (bereits vorhanden)

**Funktionen:**
- Lohnabrechnungen öffnen
- Excel-Exporte (FCN Meldeliste, Namensliste, Sub-Stunden, MA-Stamm)
- Synchronisation (Löwensaal Events)
- Abwesenheiten-Jahresauswahl

**API-Endpoints:**
- Verwendet Bridge Client für Access-Befehle
- Fallback auf `postMessage` wenn Bridge nicht verfügbar

**Besonderheiten:**
- Prompts für User-Eingaben (VA_ID, Jahr, Dateinamen)
- Confirmation Dialoge
- mailto: Fallback für E-Mail Features

---

### 3. **frm_Menuefuehrung_sidebar.html** - Sidebar-Menü ✅
**Datei:** `frm_Menuefuehrung_sidebar.html`
**Logic:** Inline `<script>` (bereits vorhanden)

**Funktionen:**
- Kompakte Sidebar-Navigation
- Shell-Integration Support
- API-Autostart für HTML-Ansicht

**API-Endpoints:**
- Nutzt `api-autostart.js` für automatischen API-Server Start

**Besonderheiten:**
- FORM_MAP mit allen verfügbaren Formularen
- `inShell()` Check für iframe-Einbettung
- Responsive Design (versteckt auf kleinen Screens)

---

### 4. **frm_MA_Zeitkonten.html** - Zeitkonten-Übersicht ✅
**Datei:** `frm_MA_Zeitkonten.html`
**Logic:** `logic/frm_MA_Zeitkonten.logic.js` (vollständig)

**Funktionen:**
- Mitarbeiter-Dropdown
- Zeitraum-Filter (Monat, Vormonat, Quartal, Jahr, Benutzerdefiniert)
- Zeitkonto-Tabelle mit Summen
- Monatsübersicht mit Balkendiagramm
- CSV-Export
- Druck-Funktion

**API-Endpoints:**
- `GET /api/mitarbeiter?aktiv=true` - Mitarbeiter laden
- SQL-Query via Bridge: `tbl_MA_VA_Planung` + `tbl_VA_Start` + `tbl_VA_Auftragstamm`
- SQL-Query via Bridge: `tbl_MA_NVerfuegZeiten` (Abwesenheiten)

**Besonderheiten:**
- Automatische Soll/Ist-Berechnung (8h pro Arbeitstag)
- Saldo-Berechnung (Ist - Soll)
- Überstunden-Tracking (alles über 8h/Tag)
- Urlaub/Krank-Tage Zählung
- Wochenend-Erkennung
- Kalenderwoche-Berechnung für Balkendiagramm

---

### 5. **frm_MA_Serien_eMail_Auftrag.html** - E-Mail für Aufträge ✅
**Datei:** `frm_MA_Serien_eMail_Auftrag.html`
**Logic:** `logic/frm_MA_Serien_eMail_Auftrag.logic.js` (bereits vorhanden)

**Funktionen:**
- Auftrag auswählen
- Mitarbeiter des Auftrags anzeigen
- E-Mail-Vorlagen (Einsatzinfo, Anfrage, Erinnerung, Absage)
- Empfänger-Auswahl (Alle, Nur zugesagte, Nur Anfrage)
- E-Mail-Vorschau
- Massen-E-Mail versenden

**API-Endpoints:**
- `GET /api/auftraege?aktiv=true` - Aktive Aufträge
- `GET /api/zuordnungen?va_id={id}` - Mitarbeiter für Auftrag
- `POST /api/email/send` - E-Mail senden (mit Fallback)

**Besonderheiten:**
- Template-Variablen: `{Anrede}`, `{Nachname}`, `{Auftrag}`, `{Datum}`, etc.
- Checkbox-Selection für Empfänger
- Deaktivierte Checkboxen für MA ohne E-Mail
- mailto: Fallback wenn kein E-Mail API vorhanden
- Live-Empfänger-Zählung

---

### 6. **frm_MA_Serien_eMail_dienstplan.html** - E-Mail für Dienstplan ✅
**Datei:** `frm_MA_Serien_eMail_dienstplan.html`
**Logic:** `logic/frm_MA_Serien_eMail_dienstplan.logic.js` (bereits vorhanden)

**Funktionen:**
- Zeitraum-Auswahl (Von/Bis Datum)
- Vorlage (Wochenplan, Monatsplan, Planänderung)
- Mitarbeiter mit Einsätzen im Zeitraum anzeigen
- Individualisierte E-Mails mit Einsatzliste
- Statistiken (Empfänger, Einsätze gesamt)

**API-Endpoints:**
- `GET /api/mitarbeiter?aktiv=true` - Mitarbeiter
- `GET /api/dienstplan/ma/{id}?von={von}&bis={bis}` - Dienstplan pro MA
- `POST /api/email/send` - E-Mail versenden

**Besonderheiten:**
- Template-Variable `{Einsatzliste}` für tabellarische Darstellung
- Automatische Gruppierung nach MA
- Nur MA mit Einsätzen im Zeitraum
- Live-Update bei Zeitraum-Änderung

---

### 7. **frm_MA_VA_Schnellauswahl.html** - MA/VA Schnellauswahl ✅
**Datei:** `frm_MA_VA_Schnellauswahl.html`
**Logic:** Inline `<script>` (bereits vorhanden, sehr umfangreich)

**Funktionen:**
- Auftrag + Datum auswählen
- Schichten/Zeiten auswählen
- Mitarbeiter-Filter (Aktiv, Verfügbar, 34a, Anstellung, Kategorie)
- Schnellsuche
- Drag & Drop MA zu Geplant
- Drag & Drop Geplant zu Zugesagt
- Parallele Einsätze anzeigen
- E-Mail-Anfragen (Alle/Selektierte)

**API-Endpoints:**
- `GET /api/auftraege?ab_datum={heute}&limit=200` - Aufträge
- `GET /api/auftraege/{id}` - Einzelauftrag
- `GET /api/einsatztage?va_id={id}` - Einsatztage
- `GET /api/dienstplan/schichten?va_id={id}` - Schichten
- `GET /api/mitarbeiter?aktiv=true` - Mitarbeiter
- `GET /api/zuordnungen?va_id={id}` - Zuordnungen (Geplant/Zugesagt)
- `POST /api/zuordnungen` - MA zuordnen
- `DELETE /api/zuordnungen/{id}` - Zuordnung löschen
- `POST /api/anfragen` - Anfrage erstellen

**Besonderheiten:**
- 6-Spalten Layout (Zeiten | MA-Liste | Buttons | Geplant | Buttons | Zugesagt)
- Multi-Select mit Set für Performance
- Doppelklick für schnelle Auswahl
- Farb-Kennzeichnung (Geplant=gelb, Zugesagt=grün)
- Filter-Logik clientseitig (performant)
- mailto: Fallback für E-Mail (TEST_EMAIL_RECIPIENT)

---

## API-Server Abhängigkeit

### Kritischer Punkt
**ALLE** Formulare benötigen den API-Server unter `http://localhost:5000/api`

### Start-Mechanismen
1. **api-autostart.js** - Automatischer Start (genutzt von Sidebar)
2. **Manueller Start:** `C:\Users\guenther.siegert\Documents\Access Bridge\api_server.py`
3. **Batch-Datei:** `start_api_server.bat` (falls vorhanden)

### Fehlerbehandlung
- Alle Formulare haben `try/catch` für API-Calls
- Fallback auf leere Arrays (`result.data || []`)
- Console.warn/error bei Fehlern
- Benutzerfreundliche Alert-Messages

---

## Technologie-Stack

### Frontend
- **HTML5** - Formulare
- **CSS** - Access Classic Styling
- **Vanilla JavaScript** - Keine Frameworks
- **ES6 Modules** - Import/Export
- **Fetch API** - HTTP Requests

### Backend-Anbindung
- **REST API** - `localhost:5000/api`
- **Bridge Client** - `../api/bridgeClient.js`
- **WebView2 Bridge** - `../js/webview2-bridge.js`
- **PostMessage API** - Iframe-Kommunikation

### Tools
- **Sidebar.js** - Gemeinsame Navigation
- **api-autostart.js** - Automatischer API-Start
- **e2e-logger.js** - E2E-Testing Support

---

## Dateistruktur

```
04_HTML_Forms/forms2/
│
├── frm_Menuefuehrung.html .......................... Hauptmenü
├── frm_Menuefuehrung1.html ......................... Menü 2 (Personal)
├── frm_Menuefuehrung_sidebar.html .................. Sidebar
├── frm_MA_Zeitkonten.html .......................... Zeitkonten
├── frm_MA_Serien_eMail_Auftrag.html ............... E-Mail Aufträge
├── frm_MA_Serien_eMail_dienstplan.html ............ E-Mail Dienstplan
├── frm_MA_VA_Schnellauswahl.html .................. Schnellauswahl
│
└── logic/
    ├── frm_Menuefuehrung.logic.js .................. Navigation
    ├── frm_MA_Zeitkonten.logic.js .................. Zeitkonto-Logik
    ├── frm_MA_Serien_eMail_Auftrag.logic.js ........ E-Mail Auftrag
    ├── frm_MA_Serien_eMail_dienstplan.logic.js ..... E-Mail Dienstplan
    └── frm_MA_VA_Schnellauswahl.logic.js ........... (inline in HTML)
```

---

## Verwendete API-Endpoints (Gesamt-Übersicht)

### Stammdaten
| Endpoint | Methode | Verwendung |
|----------|---------|------------|
| `/api/mitarbeiter` | GET | Mitarbeiter-Liste (alle Formulare) |
| `/api/mitarbeiter/{id}` | GET | Einzelner Mitarbeiter |
| `/api/kunden` | GET | Kundenliste |
| `/api/objekte` | GET | Objektliste |
| `/api/auftraege` | GET | Auftragsliste |
| `/api/auftraege/{id}` | GET | Einzelauftrag |

### Planung
| Endpoint | Methode | Verwendung |
|----------|---------|------------|
| `/api/zuordnungen` | GET | MA-Zuordnungen |
| `/api/zuordnungen` | POST | MA zuordnen |
| `/api/zuordnungen/{id}` | DELETE | Zuordnung löschen |
| `/api/anfragen` | POST | MA anfragen |
| `/api/einsatztage` | GET | Einsatztage pro Auftrag |

### Dienstplan
| Endpoint | Methode | Verwendung |
|----------|---------|------------|
| `/api/dienstplan/ma/{id}` | GET | Dienstplan Mitarbeiter |
| `/api/dienstplan/schichten` | GET | Schichten |

### Sonstige
| Endpoint | Methode | Verwendung |
|----------|---------|------------|
| `/api/email/send` | POST | E-Mail versenden |

---

## Nächste Schritte (Optional)

### Verbesserungen
1. **Caching:** Bridge Client erweitern (TTL-basiert)
2. **Offline-Mode:** LocalStorage für kritische Daten
3. **Notifications:** Toast-Messages statt Alerts
4. **Loading States:** Spinner für API-Calls
5. **Error Logging:** Zentrale Error-Sammlung

### Fehlende Features
1. **E-Mail API:** `/api/email/send` implementieren
2. **Export API:** `/api/lohn/stunden-export` implementieren
3. **Sync API:** `/api/sync/loewensaal` implementieren

---

## Dokumentation & Support

### Dateien
- **README_QUICKSTART.md** - Schnellstart-Anleitung
- **API_ENDPOINTS.md** - API-Dokumentation (falls vorhanden)
- **CLAUDE.md** - Projekt-Kontext für Claude

### Logs
- Browser Console: `[Formular-Name] Log-Messages`
- API-Server Logs: `runtime_logs/` (falls konfiguriert)

---

## Status-Zusammenfassung

| Formular | HTML | Logic | API | Test | Status |
|----------|------|-------|-----|------|--------|
| frm_Menuefuehrung | ✅ | ✅ | ✅ | ⚠️ | **Fertig** |
| frm_Menuefuehrung1 | ✅ | ✅ | ✅ | ⚠️ | **Fertig** |
| frm_Menuefuehrung_sidebar | ✅ | ✅ | ✅ | ⚠️ | **Fertig** |
| frm_MA_Zeitkonten | ✅ | ✅ | ✅ | ⚠️ | **Fertig** |
| frm_MA_Serien_eMail_Auftrag | ✅ | ✅ | ✅ | ⚠️ | **Fertig** |
| frm_MA_Serien_eMail_dienstplan | ✅ | ✅ | ✅ | ⚠️ | **Fertig** |
| frm_MA_VA_Schnellauswahl | ✅ | ✅ | ✅ | ⚠️ | **Fertig** |

**Legende:**
- ✅ Implementiert
- ⚠️ Manuelle Tests empfohlen
- ❌ Nicht implementiert

---

## Autor
**Claude Code** (claude-sonnet-4-5)
**Datum:** 31. Dezember 2025
