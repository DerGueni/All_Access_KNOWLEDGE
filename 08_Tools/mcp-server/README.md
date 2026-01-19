# Access Bridge MCP Server

MCP Server für die Integration von MS Access (CONSEC Frontend) in Claude Desktop.

## Voraussetzungen

- Node.js 18+ installiert
- MS Access Frontend muss geöffnet sein (oder wird automatisch gestartet)
- Access Bridge Scripts im Ordner `C:\Users\guenther.siegert\Documents\Access Bridge`

## Installation

### 1. Dependencies installieren

```powershell
cd "C:\Users\guenther.siegert\Documents\Access Bridge\mcp-server"
npm install
```

### 2. Claude Desktop Konfiguration

Öffne die Datei:
```
%APPDATA%\Claude\claude_desktop_config.json
```

Füge folgenden Eintrag unter `mcpServers` hinzu:

```json
{
  "mcpServers": {
    "access-bridge": {
      "command": "node",
      "args": ["C:\\Users\\guenther.siegert\\Documents\\Access Bridge\\mcp-server\\index.js"],
      "env": {}
    }
  }
}
```

### 3. Claude Desktop neu starten

Schließe Claude Desktop komplett und starte neu.

## Verfügbare Tools

| Tool | Beschreibung |
|------|--------------|
| `access_test` | Verbindungstest + Statistiken |
| `access_sql` | SQL-Abfragen (SELECT/INSERT/UPDATE/DELETE) |
| `access_insert` | Datensatz einfügen mit Auto-Formatierung |
| `access_vba_run` | VBA-Funktion ausführen |
| `access_module_read` | VBA-Modul Code lesen |
| `access_module_write` | VBA-Modul erstellen/überschreiben |
| `access_module_delete` | VBA-Modul löschen |
| `access_form_open` | Formular öffnen |
| `access_form_close` | Formular schließen (ohne Dialog!) |
| `access_eval` | Access-Ausdruck auswerten |
| `access_list_tables` | Alle Tabellen auflisten |
| `access_list_forms` | Alle Formulare auflisten |
| `access_list_modules` | Alle VBA-Module auflisten |
| `access_save` | Datenbank speichern |
| `access_save_object` | Objekt speichern |

## Wichtige Hinweise

### Dialog-Unterdrückung
- **ALLE** Access-Warnungen werden unterdrückt
- Speicherdialoge erscheinen NICHT
- Fehlermeldungen werden nur im MCP-Ergebnis zurückgegeben

### Datumsformat
Bei SQL-Abfragen US-Format verwenden: `#MM/DD/YYYY#`
```sql
SELECT * FROM tbl WHERE Datum >= #12/01/2025#
```

### Eine Instanz
Nur EINE Access-Frontend-Instanz darf geöffnet sein!

## Beispiele in Claude Desktop

**Verbindung testen:**
> "Teste die Access-Verbindung"

**SQL ausführen:**
> "Zeige mir die letzten 5 Aufträge"

**VBA-Modul lesen:**
> "Lies das Modul mdl_CONSEC_Excel"

**Formular öffnen:**
> "Öffne das Formular frm_VA_Auftragstamm"

## Fehlerbehebung

### "Access nicht erreichbar"
→ Access Frontend öffnen (Frontend muss laufen)

### Timeout-Fehler
→ Prüfen ob Access blockiert ist (Dialog offen?)
→ DialogKiller starten: `START_DialogKiller.bat`

### JSON-Parse-Fehler
→ Access gibt unerwartete Ausgabe zurück
→ Prüfen mit manuellem PowerShell-Test

## Test (manuell)

```powershell
cd "C:\Users\guenther.siegert\Documents\Access Bridge"
& ".\AccessUniversal.ps1" -Action test
```
