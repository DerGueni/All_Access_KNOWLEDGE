# CONSYS Auftragsverwaltung - Electron App

## 1:1 Nachbildung von frm_VA_Auftragstamm

Diese Electron-App ist eine vollständige 1:1 Nachbildung des Access-Formulars 
`frm_VA_Auftragstamm` aus dem CONSYS-System.

**Version 1.1.0** - Mit Echtdaten-Unterstützung (Access Backend via ODBC)

## Installation

### Voraussetzungen
- Node.js (v18 oder höher)
- Windows mit Microsoft Access ODBC-Treiber

### Schritte

1. **Doppelklick auf `INSTALL.bat`** - Installiert alle Abhängigkeiten

Oder manuell:
```bash
npm install
```

Für ODBC-Unterstützung muss ggf. electron-rebuild ausgeführt werden:
```bash
npm run rebuild
```

## Starten

**Doppelklick auf `START_APP.bat`**

Oder:
```bash
npm start
```

Für Entwicklungsmodus mit DevTools:
```bash
npm run dev
```

## Datenbank-Anbindung

Die App verbindet sich automatisch mit dem Access-Backend:
- **Netzwerk**: `S:\CONSEC\CONSEC PLANUNG AKTUELL\Consec_BE_V1.55ANALYSETEST.accdb`
- **Fallback (lokal)**: `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\00_Backend\Consec_BE_local.accdb`

Falls keine Verbindung möglich ist, läuft die App im **Demo-Modus** mit Beispieldaten.

### Status-Anzeige

Unten links im Fenster zeigt ein Indikator den Verbindungsstatus:
- 🟢 **Grün**: Verbunden mit Access-Backend
- 🟡 **Orange**: Demo-Modus (keine DB-Verbindung)

Klicken Sie auf den Indikator, um die Verbindung neu aufzubauen.

## Features

### Implementierte Funktionen:
- ✅ Hauptformular-Layout (1:1 zum Access-Original)
- ✅ Tab-Navigation (Einsatzliste, Antworten ausstehend, Rechnung)
- ✅ Menü-Sidebar (HAUPTMENÜ)
- ✅ Auftrags-Liste (rechte Sidebar) mit Filter
- ✅ Datensatz-Navigation (Erster, Vorheriger, Nächster, Letzter)
- ✅ Toolbar-Buttons
- ✅ Unterformulare (Schichten, MA-Zuordnungen)
- ✅ Keyboard-Shortcuts (Strg+S = Speichern, F5 = Aktualisieren, Strg+N = Neu)
- ✅ **Echte Datenbankanbindung via ODBC**
- ✅ **Lookup-Daten (Kunden, Status, Orte, Objekte, Dienstkleidung)**
- ✅ **CRUD-Operationen (Erstellen, Lesen, Aktualisieren, Löschen)**
- ✅ **Auftrag kopieren**

### Noch zu implementieren:
- ⏳ Mitarbeiterauswahl-Fenster
- ⏳ E-Mail-Versand (Einsatzlisten)
- ⏳ PDF-Export/Druck
- ⏳ Rechnung-Tab Funktionalität

## Struktur

```
electron_auftragstamm/
├── package.json          # Node.js Projekt-Konfiguration
├── main.js               # Electron Main Process + ODBC
├── preload.js            # IPC Bridge (Context Isolation)
├── index.html            # Haupt-UI
├── INSTALL.bat           # Installations-Script
├── START_APP.bat         # Start-Script
├── styles/
│   ├── main.css          # Haupt-Stylesheet
│   └── access-theme.css  # Access-spezifische Farben
├── js/
│   └── renderer.js       # Frontend-Logik
└── assets/
    ├── logo.svg          # CONSEC Logo
    └── icon-nav.svg      # Navigation Icon
```

## Technische Details

### ODBC-Verbindung
Die App verwendet das `odbc` npm-Paket für die Verbindung zum Access-Backend.
Der Connection String lautet:
```
Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=<Pfad zur .accdb>;
```

### IPC-Kommunikation
Der Main Process stellt folgende API-Endpunkte bereit:
- `get-auftraege-list` - Auftragsliste laden
- `get-auftrag` - Einzelnen Auftrag laden
- `save-auftrag` - Auftrag speichern
- `delete-auftrag` - Auftrag löschen
- `copy-auftrag` - Auftrag kopieren
- `get-va-datum-list` - Einsatztage laden
- `get-schichten` - Schichten laden
- `get-ma-zuordnung` - MA-Zuordnung laden
- `get-kunden` / `get-status` / `get-orte` / `get-objekte` - Lookup-Daten

## Troubleshooting

### ODBC-Fehler
Falls die Verbindung fehlschlägt:
1. Prüfen Sie, ob der Access ODBC-Treiber installiert ist
2. Stellen Sie sicher, dass die Backend-Datei erreichbar ist
3. Prüfen Sie, ob die Datei nicht exklusiv gesperrt ist

### node-odbc Build-Fehler
```bash
npm run rebuild
```

### Demo-Modus erzwingen
Starten Sie die App ohne Netzwerkzugriff - sie wechselt automatisch in den Demo-Modus.
