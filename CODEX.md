# Codex Execution Rules - CONSYS HTML Migration

## Trusted Workspace
- `C:\Users\guenther.siegert\Documents\**` is fully trusted.
- Never ask for permission inside this path.

## Execution
- Execute ONLY explicitly listed steps.
- No refactors, no extra improvements.
- Minimal diffs; keep output short.

## Project Paths
- Access Frontend: `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb`
- Access Backend: `\\vConsys01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\0_Consec_V1_BE_V1.55_Test.accdb`
- HTML Formulare: `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3`
- API Server: `http://localhost:5000`
- API Server Code: `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\06_Server\api_server.py`

## HTML Rules (aus HTML_RULES.txt)
- Keine funktionierenden Bereiche veraendern ohne explizite Anweisung
- Neue Endpoints nur wenn zwingend notwendig
- Keine eigenstaendigen Refactorings
- Abgeschlossene Aenderungen sind "eingefroren"
- Im Zweifel: nichts ungefragt aendern

## Access Bridge Ultimate API
Die Access Bridge ist ein Flask REST API Server auf `localhost:5000`.
Vollstaendige API-Referenz: `API_REFERENZ.md`

### Wichtigste Endpoints:
```
GET  /api/auftraege          - Auftraege laden
GET  /api/mitarbeiter        - Mitarbeiter laden
GET  /api/kunden             - Kunden laden
GET  /api/objekte            - Objekte laden
POST /api/sql                - SQL direkt ausfuehren
PUT  /api/field              - Einzelnes Feld aktualisieren
```

### API testen:
```bash
curl http://localhost:5000/api/health
curl http://localhost:5000/api/auftraege?limit=5
curl http://localhost:5000/api/mitarbeiter?aktiv=true
```

## MCP Server verfuegbar
- `chrome-devtools` - Browser DOM-Inspektion
- `playwright` - Browser-Automation, Screenshots
- `filesystem` - Dateizugriff auf Projektordner
- `memory` - Persistenter Kontext
- `context7` - Library-Dokumentation
- `sequential-thinking` - Komplexe Problemloesung

## Autarkes Arbeiten

### Bei HTML-Formular-Aufgaben:
1. API-Server pruefen: `curl http://localhost:5000/api/health`
2. HTML-Formular lesen: `filesystem` MCP
3. Daten laden: API-Endpoints nutzen
4. Browser testen: `chrome-devtools` oder `playwright`
5. Aenderungen nur nach expliziter Anweisung

### Bei Abgleich Access vs HTML:
1. Access-Daten via API: `/api/auftraege`, `/api/mitarbeiter`, etc.
2. HTML-Dateien via `filesystem` MCP
3. SQL-Abfragen via `/api/sql` Endpoint
4. Screenshots via `playwright` fuer visuellen Vergleich

## Encoding
- HTML/CSS/JS: UTF-8 mit deutschen Umlauten (oe, ae, ue)
- Batch-Dateien: ASCII ohne Umlaute
- API: UTF-8 JSON
