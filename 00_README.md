# CONSYS Knowledge Base

## Übersicht für Claude Code

Diese Wissensbasis enthält alle relevanten Dateien für das CONSYS-Projekt (CONSEC Security Nürnberg).

---

## Ordnerstruktur

### 01_VBA/ (217 Dateien)
**VBA-Quellcode für Microsoft Access**
- `modules/` - 213 VBA Module (.bas)
- `classes/` - 4 Klassenmodule (.cls)
- `forms/` - Formular-Code
- `macros/` - Access Makros

**Wann hier nachsehen:** Bei VBA-Entwicklung, Access-Makros, Formular-Events, Datenbank-Operationen

### 02_SQL/ (663 Dateien)
**SQL-Abfragen**
- `queries/` - 663 SQL-Dateien für alle CONSYS-Abfragen

**Wann hier nachsehen:** Bei Datenbankabfragen, Tabellenstrukturen, JOIN-Logik

### 03_PowerShell/ (24 Dateien)
**PowerShell-Skripte**
- Access Bridge Skripte
- Export-/Import-Tools
- Automatisierungs-Skripte
- DialogKiller und Diagnose-Tools

**Wann hier nachsehen:** Bei Windows-Automatisierung, Access-Bridge-Integration, Systemskripten

### 04_HTML_Forms/ (103 Dateien)
**HTML-Formulare für CONSYS Web-Interface**
- `forms/` - HTML & JS Formulare
- `js/` - JavaScript-Module
- `css/` - Stylesheets
- `api/` - API-Definitionen
- `theme/` - CONSYS Theme (consys_theme.css)
- `index.html`, `shell.html` - Haupt-Entry-Points

**Wann hier nachsehen:** Bei Web-Frontend, Formular-Konvertierung, UI-Entwicklung

### 05_Dokumentation/ (20 Dateien)
**Technische Dokumentation**
- `specs/` - Spezifikationen (JSON)
- `mappings/` - Feld-Mappings
- `guides/` - Anleitungen und README-Dateien
- Bereinigungsempfehlungen
- Formular-/Berichts-Listen

**Wann hier nachsehen:** Bei Projektdokumentation, Mapping-Informationen, Bereinigung

### 06_Server/ (10 Dateien)
**Node.js Backend-Server**
- `src/config/` - Datenbankverbindung
- `src/controllers/` - Controller-Logik
- `src/models/` - Datenmodelle (Mitarbeiter, MockData)
- `src/routes/` - API-Routen (kunden, mitarbeiter)

**Wann hier nachsehen:** Bei Backend-Entwicklung, API-Endpoints, Server-Logik

### 07_Web_Client/ (18 Dateien)
**React Web-Client**
- `src/App.jsx` - Hauptkomponente
- `src/components/` - React-Komponenten
- `src/lib/` - Hilfsbibliotheken (twipsConverter)
- `src/styles/` - CSS-Styles

**Wann hier nachsehen:** Bei Frontend-Entwicklung, React-Komponenten

### 08_Tools/ (197 Dateien)
**Hilfs-Tools und Skripte**
- `python/` - 151 Python-Skripte (Analyse, Fixes, Import)
- `batch/` - 8 Batch-Dateien (Start-Skripte)
- `vbs/` - 29 VBScript-Dateien
- `mcp-server/` - MCP Server für Claude Desktop
  - `access_bridge_mcp.py` - Haupt-Bridge
  - `index.js` - Node.js Server
  - Installation & Konfig

**Wann hier nachsehen:** Bei Werkzeugen, Automatisierung, MCP-Integration

### 09_Schema/ (5 Dateien)
**Datenbank-Schema**
- `tables_schema.json` - Vollständiges Tabellen-Schema (276KB)
- `SUBFORM_HIERARCHY.json` - Unterformular-Hierarchie
- `references.json` - Tabellenreferenzen
- `Beziehungen.txt` - Tabellenbeziehungen
- `Tabellen.txt` - Tabellenliste

**Wann hier nachsehen:** Bei Datenbankstruktur, Tabellenfeldern, Beziehungen

### 10_Logs_Reports/ (2 Dateien)
**Berichte und Logs**
- `VALIDATION_REPORT.md` - Validierungsbericht
- `report.json` - Export-Bericht

**Wann hier nachsehen:** Bei Fehlersuche, Validierung

---

## Schnell-Navigation

| Aufgabe | Ordner |
|---------|--------|
| VBA-Code bearbeiten | `01_VBA/modules/` |
| SQL-Abfrage finden | `02_SQL/queries/` |
| PowerShell-Skript | `03_PowerShell/` |
| HTML-Formular | `04_HTML_Forms/forms/` |
| Tabellen-Schema | `09_Schema/tables_schema.json` |
| Python-Tool | `08_Tools/python/` |
| MCP-Server | `08_Tools/mcp-server/` |
| Server-API | `06_Server/src/routes/` |
| React-Komponente | `07_Web_Client/src/components/` |

---

## Wichtige Dateien

- **Tabellen-Schema:** `09_Schema/tables_schema.json`
- **Unterformular-Hierarchie:** `09_Schema/SUBFORM_HIERARCHY.json`
- **MCP-Server Config:** `08_Tools/mcp-server/claude_desktop_config.example.json`
- **CONSYS Theme:** `04_HTML_Forms/theme/consys_theme.css`

---

*Letzte Aktualisierung: Dezember 2024*
