# CODEX – Access Frontend ↔ HTML/Web-Forms ↔ Backend (CONSYS)

> **Ziel dieser Datei:** Ein **einziger, kompletter Einstieg** für Codex/AI, um dein Access-Frontend zu verstehen und zuverlässig
> (a) Access-Formulare als HTML/React-Formulare zu erzeugen, (b) bestehende Web-Formulare zu bearbeiten, und (c) die Verbindung zum Backend zu halten.

**Stand:** 2025-12-27  
**Quelle:** Export aus `0006_All_Access_KNOWLEDGE.zip` (VBA, HTML-Forms, Web-Client, Server, Mapping, Tools)

---

## 1) System-Überblick (Architektur)

### Bausteine
1. **Access Frontend (FE)**  
   - Enthält: Formulare, VBA, Queries, UI-Logik.
   - Zweck im Projekt: „Original“/Referenz der UI (Controls, Layout, Events).

2. **Access Backend (BE)**  
   - Enthält: Tabellen + Daten (Business-DB).

3. **Web/HTML-Forms Layer (04_HTML_Forms)**  
   - Enthält: bereits erzeugte HTML-Formulare (teils „precise“, „v2“, „generated“).
   - Jede Form hat meist zusätzlich eine **Logik-Datei** (`forms/logic/*.logic.js`) und nutzt den **Bridge-Client**.

4. **Bridge API (Flask, Port 5000)**  
   - File: `08_Tools\python\api_server.py`
   - Zweck: HTML/JS/React ↔ Access-DB (pyodbc)  
   - Standard-Basis: `http://localhost:5000/api`

5. **Node Server (Express, Port 3000)**  
   - File: `06_Server\src\index.js`
   - Zweck: Alternative/zusätzliche API + Warmup/Preload-Mechanik (ODBC Pools via ENV).

6. **React Web-Client (07_Web_Client)**  
   - File: `07_Web_Client\src\App.jsx`
   - Komponenten: `MitarbeiterstammForm.jsx`, `KundenstammForm.jsx`, `PreloadComponent.jsx`, etc.

7. **Access „WebHost“ Wrapper**  
   - VBA: `mod_N_WebHost_Creator.bas`
   - Zweck: Ein Access-Formular, das HTML-Formulare in einem WebBrowser-Control (oder WebView2) rendert.

---

## 2) Repository-/Ordner-Karte (wichtigste Pfade)

### A) Access/VBA Exporte
- `01_VBA\modules\*.bas` – Standard- & Projektmodule (Business-Logik, Helper, Export/Import, etc.)
- `01_VBA\classes\*.cls` – Klassen (z.B. Excel, Download, Logging)
- `01_VBA\forms\` – Form-spezifische Exporte (Form-Module)
- `exports\` – strukturierte Exporte (Forms, RecordSources, Controls, …)
- `11_json_Export\` – JSON-Exporte (Form-Definitionen, Recordsource, Controls, …)
- `DependencyObjects.txt` / `DependencyLinks.txt` – Objekt-/Abhängigkeits-Mapping (Queries ↔ Tables ↔ Forms ↔ Modules)

### B) HTML-Formulare (Legacy/Standalone)
- `04_HTML_Forms\forms\*.html` – HTML-Formulare (Access-Form-Äquivalente)
- `04_HTML_Forms\forms\logic\*.logic.js` – Form-Logik (Events, Daten laden/speichern, Buttons)
- `04_HTML_Forms\api\bridgeClient.js` – REST-Adapter zur Bridge API (Caching, Dedup, Batch)

### C) React Web Client
- `07_Web_Client\src\App.jsx`
- `07_Web_Client\src\components\...`

### D) Backend/Server
- **Flask API**: `08_Tools\python\api_server.py` + `08_Tools\python\config.json`
- **Express**: `06_Server\src\index.js` + `06_Server\src\config\db.js` + `06_Server\src\routes\...` + `06_Server\src\controllers\...`

### E) Doku/Guides
- `05_Dokumentation\guides\MAPPING.md` – „Access zu Web“-Mapping (Form-/Subform-Hierarchie, Controls, etc.)
- `05_Dokumentation\guides\WEBHOST_INTEGRATION.md` – WebHost/Preload/Integration (Routen, Warmup)
- `04_HTML_Forms\FORM_STATUS.md` – Status/Abdeckung der HTML-Forms

---

## 3) Verbindung: HTML/React ↔ Access Backend (wie es „wirklich“ läuft)

### 3.1 Bridge API (Flask) – Port 5000 (primär)
**Basis:** `http://localhost:5000/api`  
**Konfiguration:** `08_Tools\python\config.json`

Aus `config.json`:
- `database.backend_path`: `S:\CONSEC\CONSEC PLANUNG AKTUELL\Consec_BE_V1.55ANALYSETEST.accdb`
- `database.frontend_path`: `S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT - Kopie (9) - Kopie.accdb`
- `server.port`: `5000`

**HTML/JS nutzt i.d.R.:**
- `04_HTML_Forms\api\bridgeClient.js` (API_BASE = `http://localhost:5000/api`)
- Fetch-Aufrufe direkt im Formular-Script (bei einigen Standalone-Forms)

**Wichtige API-Routen (Flask)**
- `/api/abwesenheiten`
- `/api/abwesenheiten/<int:id>`
- `/api/anfragen`
- `/api/anfragen/<int:id>`
- `/api/auftraege`
- `/api/auftraege/<int:id>`
- `/api/bewerber`
- `/api/bewerber/<int:id>`
- `/api/bewerber/<int:id>/accept`
- `/api/bewerber/<int:id>/reject`
- `/api/dashboard`
- `/api/dienstplan/alle`
- `/api/dienstplan/gruende`
- `/api/dienstplan/ma/<int:ma_id>`
- `/api/dienstplan/objekt/<int:objekt_id>`
- `/api/dienstplan/schichten`
- `/api/dienstplan/uebersicht`
- `/api/einsatztage`
- `/api/field`
- `/api/kunden`
- `/api/kunden/<int:id>`
- `/api/lohn/abrechnungen`
- `/api/mitarbeiter`
- `/api/mitarbeiter/<int:id>`
- `/api/objekte`
- `/api/objekte/<int:id>`
- `/api/objekte/<int:objekt_id>/positionen`
- `/api/planungen`
- `/api/query`
- `/api/record`
- `/api/rueckmeldungen`
- `/api/rueckmeldungen/<int:id>`
- `/api/rueckmeldungen/<int:id>/read`
- `/api/rueckmeldungen/mark-all-read`
- `/api/tables`
- `/api/verfuegbarkeit`
- `/api/verfuegbarkeit/check`
- `/api/zeitkonten/importfehler`
- `/api/zeitkonten/importfehler/<int:id>/fix`
- `/api/zeitkonten/importfehler/<int:id>/ignore`
- ... (weitere Routes in api_server.py)

> Hinweis: Für „Spezialfälle“ gibt es zusätzlich `POST /api/query` (frei definierte Queries/SQL via Server – nur wenn abgesichert).

### 3.2 Express Server – Port 3000 (zusätzlich/Preload)
**Basis:** `http://localhost:3000`  
Mounts in `06_Server\src\index.js`:
- `/api/kunden`
- `/api/mitarbeiter`

**DB-Verbindung (Express)**  
- `06_Server\src\config\db.js` nutzt `process.env.ODBC_FRONTEND` und `process.env.ODBC_BACKEND` (ODBC Connection Strings).

---

## 4) Wie HTML-Formulare aufgebaut sind

### 4.1 Konventionen & Bestand
- HTML-Forms liegen unter: `04_HTML_Forms\forms\`
- Viele haben Varianten:
  - `frm_va_Auftragstamm.html`
  - `frm_va_Auftragstamm_v2.html`
  - `frm_va_Auftragstamm_precise.html`
  - `frm_va_Auftragstamm_generated.html`

### 4.2 Form-Logik getrennt in `forms/logic`
- Logik-Dateien sind typischerweise nach Schema:  
  **`<FormName>.logic.js`**
- Enthalten:
  - Daten laden (GET)
  - Speichern (POST/PUT)
  - Button-Handler
  - Validierung
  - Subform-Handling

### 4.3 Bridge Client (Caching + Dedup)
`04_HTML_Forms\api\bridgeClient.js`:
- zentrales API_BASE (Port 5000)
- Request Cache (TTL)
- Request Deduplication
- Batch-Requests

**Wichtig für Codex:**  
Wenn du Form-Logik änderst, möglichst **über den Bridge Client** gehen (statt überall hardcoded `fetch()`).

---

## 5) Wie Access HTML rendert (WebHost)

### 5.1 WebHost Creator (VBA)
`mod_N_WebHost_Creator.bas`
- erzeugt ein Access-Formular `frm_N_WebHost` mit WebBrowser-Control
- setzt festen HTML-Pfad (Konstante `HTML_PATH`)
- ermöglicht „HTML Ansicht“ Buttons im FE, die auf HTML-Versionen verlinken

### 5.2 Betriebsarten
Es gibt (mind.) zwei Modi:
1. **Embedded (WebBrowser/WebView2 im Access Wrapper)** – HTML wird im Access-Form gerendert.
2. **Extern (Browser + localhost)** – HTML läuft in einem Browserfenster gegen localhost API.

---

## 6) Mapping: Access Form → Web Form/Component

**Primärdatei:** `05_Dokumentation\guides\MAPPING.md`  
Enthält typischerweise:
- Hauptformular (Access) ↔ React Component
- Subforms + LinkMasterFields / LinkChildFields
- Control-Mapping (Textbox/Combobox/Listbox/Button → Web-Input/Select/Grid)
- RecordSource/Query-Pfade (JSON in `exports/forms/.../recordsource.json`)

> Pflege-Regel: Änderungen am Mapping immer in `MAPPING*.md` dokumentieren.

---

## 7) Praktischer Workflow: Form neu erzeugen / bestehende Form bearbeiten

### A) Neue Web-Form aus Access-Form erzeugen (Best-Practice)
1. **Access-Form analysieren/Export prüfen**
   - Form-Name, Subforms, Controls, RecordSource
   - Daten liegen i.d.R. als JSON unter `exports/forms/<FORMNAME>/...`

2. **Ziel definieren**
   - „Standalone HTML“ (04_HTML_Forms) **oder**
   - „React Component“ (07_Web_Client/src/components)

3. **Scaffold erzeugen**
   - HTML: neue Datei unter `04_HTML_Forms\forms\<Form>.html`
   - Logik: `04_HTML_Forms\forms\logic\<Form>.logic.js`
   - Bridge: Import/Nutzung `bridgeClient.js`

4. **Backend-Anbindung**
   - Standard: Flask Bridge API (5000) mit `/api/<resource>`
   - Falls Route fehlt: `api_server.py` erweitern (oder `POST /api/query` nutzen, wenn sicher)

5. **Subforms**
   - Subforms im Web als Tabs/Accordion/Sections rendern
   - Verknüpfung über LinkMaster/LinkChild (aus Mapping/Exports übernehmen)

### B) Bestehende Web-Form anpassen
1. HTML unter `04_HTML_Forms\forms\...` suchen
2. Logik in `04_HTML_Forms\forms\logic\...` prüfen
3. API Calls über `bridgeClient.js` konsolidieren
4. UI/UX: Layout vereinheitlichen (siehe `04_HTML_Forms\STANDARDISIERUNGS_PLAN.md`)

---

## 8) Inventar: vorhandene HTML-Formulare (04_HTML_Forms/forms)

> **Hinweis:** Liste ist aus dem Export generiert.

- `04_HTML_Forms\forms\frmOff_Outlook_aufrufen.html`
- `04_HTML_Forms\forms\frmTop_DP_Auftragseingabe.html`
- `04_HTML_Forms\forms\frmTop_DP_MA_Auftrag_Zuo.html`
- `04_HTML_Forms\forms\frmTop_Geo_Verwaltung.html`
- `04_HTML_Forms\forms\frm_Abwesenheiten.html`
- `04_HTML_Forms\forms\frm_DP_Dienstplan_MA.html`
- `04_HTML_Forms\forms\frm_DP_Dienstplan_Objekt.html`
- `04_HTML_Forms\forms\frm_KD_Kundenstamm.html`
- `04_HTML_Forms\forms\frm_MA_Abwesenheit.html`
- `04_HTML_Forms\forms\frm_MA_Mitarbeiterstamm.html`
- `04_HTML_Forms\forms\frm_MA_Serien_eMail_Auftrag.html`
- `04_HTML_Forms\forms\frm_MA_Serien_eMail_dienstplan.html`
- `04_HTML_Forms\forms\frm_MA_VA_Positionszuordnung.html`
- `04_HTML_Forms\forms\frm_MA_VA_Schnellauswahl.html`
- `04_HTML_Forms\forms\frm_MA_Zeitkonten.html`
- `04_HTML_Forms\forms\frm_Menuefuehrung.html`
- `04_HTML_Forms\forms\frm_Menuefuehrung1.html`
- `04_HTML_Forms\forms\frm_N_Lohnabrechnungen.html`
- `04_HTML_Forms\forms\frm_OB_Objekt.html`
- `04_HTML_Forms\forms\frm_VA_Planungsuebersicht.html`
- `04_HTML_Forms\forms\frm_abwesenheitsuebersicht.html`
- `04_HTML_Forms\forms\frm_lst_row_auftrag.html`
- `04_HTML_Forms\forms\frm_va_Auftragstamm.html`
- `04_HTML_Forms\forms\frm_va_Auftragstamm_generated.html`
- `04_HTML_Forms\forms\frm_va_Auftragstamm_precise.html`
- `04_HTML_Forms\forms\frm_va_Auftragstamm_v2.html`
- `04_HTML_Forms\forms\sub_DP_Grund.html`
- `04_HTML_Forms\forms\sub_DP_Grund_MA.html`
- `04_HTML_Forms\forms\sub_MA_Offene_Anfragen.html`
- `04_HTML_Forms\forms\sub_MA_VA_Planung_Absage.html`
- `04_HTML_Forms\forms\sub_MA_VA_Planung_Status.html`
- `04_HTML_Forms\forms\sub_MA_VA_Zuordnung.html`
- `04_HTML_Forms\forms\sub_OB_Objekt_Positionen.html`
- `04_HTML_Forms\forms\sub_VA_Anzeige.html`
- `04_HTML_Forms\forms\sub_VA_Start.html`
- `04_HTML_Forms\forms\sub_ZusatzDateien.html`
- `04_HTML_Forms\forms\sub_rch_Pos.html`
- `04_HTML_Forms\forms\test_ie.html`
- `04_HTML_Forms\forms\webview2_test.html`
- `generated\forms\frm_ma_Mitarbeiterstamm\sub_MA_ErsatzEmail.html`
- `generated\forms\frm_ma_Mitarbeiterstamm\sub_Menuefuehrung.html`

---

## 9) Inventar: vorhandene Logik-Dateien (04_HTML_Forms/forms/logic)

- `04_HTML_Forms\forms\logic\frmTop_DP_Auftragseingabe.logic.js`
- `04_HTML_Forms\forms\logic\frmTop_DP_MA_Auftrag_Zuo.logic.js`
- `04_HTML_Forms\forms\logic\frmTop_Geo_Verwaltung.logic.js`
- `04_HTML_Forms\forms\logic\frm_Abwesenheiten.logic.js`
- `04_HTML_Forms\forms\logic\frm_DP_Dienstplan_MA.logic.js`
- `04_HTML_Forms\forms\logic\frm_DP_Dienstplan_Objekt.logic.js`
- `04_HTML_Forms\forms\logic\frm_KD_Kundenstamm.logic.js`
- `04_HTML_Forms\forms\logic\frm_MA_Abwesenheit.logic.js`
- `04_HTML_Forms\forms\logic\frm_MA_Mitarbeiterstamm.logic.js`
- `04_HTML_Forms\forms\logic\frm_MA_Serien_eMail_Auftrag.logic.js`
- `04_HTML_Forms\forms\logic\frm_MA_Serien_eMail_dienstplan.logic.js`
- `04_HTML_Forms\forms\logic\frm_MA_VA_Positionszuordnung.logic.js`
- `04_HTML_Forms\forms\logic\frm_MA_VA_Schnellauswahl.logic.js`
- `04_HTML_Forms\forms\logic\frm_MA_Zeitkonten.logic.js`
- `04_HTML_Forms\forms\logic\frm_Menuefuehrung.logic.js`
- `04_HTML_Forms\forms\logic\frm_N_Dienstplanuebersicht.logic.js`
- `04_HTML_Forms\forms\logic\frm_N_Lohnabrechnungen.logic.js`
- `04_HTML_Forms\forms\logic\frm_N_MA_Bewerber_Verarbeitung.logic.js`
- `04_HTML_Forms\forms\logic\frm_N_Optimierung.logic.js`
- `04_HTML_Forms\forms\logic\frm_N_Stundenauswertung.logic.js`
- `04_HTML_Forms\forms\logic\frm_OB_Objekt.logic.js`
- `04_HTML_Forms\forms\logic\frm_VA_Planungsuebersicht.logic.js`
- `04_HTML_Forms\forms\logic\frm_abwesenheitsuebersicht.logic.js`
- `04_HTML_Forms\forms\logic\frm_lst_row_auftrag.logic.js`
- `04_HTML_Forms\forms\logic\frm_va_Auftragstamm.logic.js`
- `04_HTML_Forms\forms\logic\frm_va_Auftragstamm.logicALT.js`
- `04_HTML_Forms\forms\logic\sub_DP_Grund.logic.js`
- `04_HTML_Forms\forms\logic\sub_DP_Grund_MA.logic.js`
- `04_HTML_Forms\forms\logic\sub_MA_Offene_Anfragen.logic.js`
- `04_HTML_Forms\forms\logic\sub_MA_VA_Planung_Absage.logic.js`
- `04_HTML_Forms\forms\logic\sub_MA_VA_Planung_Status.logic.js`
- `04_HTML_Forms\forms\logic\sub_MA_VA_Zuordnung.logic.js`
- `04_HTML_Forms\forms\logic\sub_OB_Objekt_Positionen.logic.js`
- `04_HTML_Forms\forms\logic\sub_VA_Anzeige.logic.js`
- `04_HTML_Forms\forms\logic\sub_VA_Start.logic.js`
- `04_HTML_Forms\forms\logic\sub_ZusatzDateien.logic.js`
- `04_HTML_Forms\forms\logic\sub_rch_Pos.logic.js`
- `04_HTML_Forms\forms\logic\zfrm_Lohnabrechnungen.logic.js`
- `04_HTML_Forms\forms\logic\zfrm_Rueckmeldungen.logic.js`

---

## 10) Quick-Debug: Wenn ein HTML-Form „leer“ bleibt

1. Läuft die Bridge API?
   - Flask: Port 5000 (config.json)  
2. CORS/Fetch-Fehler in DevTools?
3. Stimmt Record-ID/Parameter in Route?
4. Stimmt DB-Pfad (S:\...) auf dem Zielsystem?
5. Subform-Links (Master/Child) richtig?
6. Access Wrapper: richtige URL/Datei im WebBrowser-Control?

---

## 11) Was Codex als „Single Source of Truth“ verwenden soll

- **UI-Truth:** Access Form Exporte + Mapping in `exports/` + `05_Dokumentation/guides/`
- **Web-Truth:** `04_HTML_Forms/` (HTML + Logik + Bridge)
- **API-Truth:** `08_Tools/python/api_server.py` (5000) und `06_Server/src/` (3000)
- **Dependencies:** `DependencyObjects.txt` + `DependencyLinks.txt` (Objektgraph)

---

## 12) TODO / offene Punkte (für spätere Iterationen)
- Vereinheitlichung der API_Basen (3000 vs 5000) – aktuell ist 5000/Flask die „HTML-Forms“-Realität.
- Auto-Generator: definieren, welche Daten aus `exports/` in HTML/React scaffolding einfließen (Controls, Layout, Events).
- E2E-Test/Proof (siehe `Anweisung_HTML.txt`): Button „HTML Ansicht“ muss nachweisbar das korrekte Formular rendern.

---
