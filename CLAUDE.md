# Claude Code Project Rules - KOMPAKT

## 📂 ACCESS EXPORT DATEN (IMMER ZUERST LESEN!)

**Pfad:** `exports/`

### 🚀 SCHNELLZUGRIFF - Index-Dateien
| Datei | Zweck |
|-------|-------|
| `MASTER_INDEX.json` | Alle Formulare mit Button-Liste |
| `BUTTON_LOOKUP.json` | Button-Name → Formular + VBA |
| `VBA_EVENT_MAP.json` | Events nach Typ gruppiert |
| `FORM_DETAIL_INDEX.json` | Formular → alle Dateipfade |

### 🔍 Button-Workflow
1. `BUTTON_LOOKUP.json` → Button suchen → VBA-Datei finden
2. `exports/vba/forms/Form_[NAME].bas` → Funktion `[btn]_Click` lesen
3. JavaScript implementieren → Browser testen

### 📁 Detail-Daten
- `exports/forms/[NAME]/controls.json` - Controls + Events
- `exports/forms/[NAME]/subforms.json` - Unterformulare
- `exports/vba/forms/Form_[NAME].bas` - VBA-Code

---

## 🚨 MASTER-REGEL: ACCESS-PARITÄT

**Trigger:** "wie in Access", "teste Buttons", "funktioniert wie"

### ⚠️ NIE RATEN! Bei Unklarheit:
1. VBA-Module lesen (`exports/vba/...`)
2. Access-Frontend prüfen
3. Benutzer fragen

### VBA → JS Mapping
| VBA | JS |
|-----|-----|
| `_Click` | `onclick` |
| `_DblClick` | `dblclick` |
| `_AfterUpdate` | `change` |
| `Me.Requery` | `loadData()` |
| `Me.[X].Visible` | `element.style.display` |

### FERTIG-Meldung Format
```
✅ VBA gelesen: [Datei]
✅ Browser getestet: [Aktion]
✅ Console: Keine Fehler
✅ Regression: OK
```

---

## 🛑 GESCHÜTZTE BEREICHE - ABSOLUTE SPERRZONE

### ⛔ KRITISCHE WARNUNG - LIES DAS ZUERST!
**Eingefrorene Bereiche wurden MEHRFACH kaputt gemacht!**
**Jede Verletzung wirft das Projekt um TAGE zurück!**

### 🔒 FREEZE-PROTOKOLL (VERPFLICHTEND)
**VOR JEDER Code-Änderung diese Checkliste durchgehen:**

1. **FREEZE-CHECK:** Ist die Datei/Funktion in der Freeze-Liste unten?
   - JA → **SOFORT STOPP! KEINE Änderung ohne explizite User-Freigabe!**
   - NEIN → Weiter zu Schritt 2

2. **SCOPE-CHECK:** Könnte meine Änderung indirekt einen eingefrorenen Bereich betreffen?
   - CSS-Änderung? → Header-Styles sind eingefroren!
   - JS-Änderung? → Button-Bindings prüfen!
   - Layout-Änderung? → Alle Positionen sind eingefroren!
   - JA → **STOPP + User fragen!**

3. **MINIMAL-PRINZIP:** Nur das ABSOLUTE MINIMUM ändern!
   - Keine "Verbesserungen"
   - Keine "Aufräumarbeiten"
   - Keine "Refactorings"
   - Keine "Optimierungen"

### ❌ ABSOLUT VERBOTEN (ohne explizite Freigabe):
- Änderung von CSS-Werten (font-size, color, padding, margin, position)
- Änderung von Layout-Strukturen (Reihenfolge, Container, Grid)
- Änderung von funktionierenden Event-Handlern
- Änderung von API-Routen die funktionieren
- Entfernen von "auskommentierten" Code (oft absichtlich!)
- "Aufräumen" von Code
- "Vereinheitlichen" von Styles
- "Verbessern" von irgendetwas das funktioniert

### 🚨 BEI VERSTOSS:
Du hast gerade einen eingefrorenen Bereich geändert!
1. SOFORT rückgängig machen
2. User informieren was passiert ist
3. Auf Anweisung warten

### Access-Instanzen (NUR diese!)
- Frontend: `0_Consys_FE_Test.accdb`
- Backend: `\\vConSYS01-NBG\...\0_Consec_V1_BE_V1.55_Test.accdb`

### Geschützte Code-Stellen
- `sub_MA_VA_Zuordnung.logic.js` → `isBrowserMode = true`
- `frm_va_Auftragstamm.logic.js` → bindButtons auskommentiert
- `shell.html` → console.warn statt alert()

### Geschützte VBA-Buttons (mod_N_HTML_Buttons.bas)
`btn_ListeStd, btnDruckZusage, btnMailEins, btnMailBOS, btnMailSub, cmdAuftragKopieren, cmdAuftragLoeschen, btn_BWN_Druck, cmd_BWN_send`

### Geschützte API-Endpoints
`/api/auftraege/<va_id>/schichten`, `/api/auftraege/<va_id>/zuordnungen`, `/api/auftraege/<va_id>/absagen`

---

## ⚡ SKILLS AUTO-TRIGGER

| Trigger | Skill |
|---------|-------|
| Button, onclick, klick | `consys-button-fixer` |
| API, Endpoint, fetch | `consys-api-endpoint` |
| Layout, CSS, Design | `html-form-design-expert` |
| HTML ändern | `html-change-tracker` |

---

## 🔴 ÄNDERUNGS-TRACKING (PFLICHT!)

### VOR jeder Änderung - PFLICHT-FRAGEN:
1. **Hat der User diese Änderung EXPLIZIT angefordert?**
   - NEIN → **STOPP! Nicht ändern!**
   - "Könnte man verbessern" ist KEINE Anforderung!
   - "Wäre besser wenn" ist KEINE Anforderung!

2. **Ist der Bereich eingefroren?**
   - Siehe FREEZE-Liste oben → **STOPP wenn ja!**

3. **Ist es das MINIMUM für die Aufgabe?**
   - Nur genau das ändern was angefordert wurde
   - NICHTS "nebenbei" verbessern

### Bei JEDER HTML/CSS/JS-Änderung:
1. Explizite Anweisung vorhanden? Sonst STOPP!
2. Freeze-Check durchgeführt? Sonst STOPP!
3. In `CLAUDE2.md` dokumentieren
4. Kritisch? → Einfrieren

---

## 📁 WICHTIGE PFADE

| Pfad | Inhalt |
|------|--------|
| `04_HTML_Forms/forms3/` | HTML-Formulare |
| `04_HTML_Forms/forms3/logic/` | Logic-Dateien |
| `06_Server/api_server.py` | API Server (Port 5000) |
| `04_HTML_Forms/forms3/_scripts/mini_api.py` | VBA-API |
| `exports/vba/forms/` | VBA-Exports |

**🚨 mini_api.py + api_server.py MÜSSEN identische Routen haben!**

---

---

## 🔒 EINGEFRORENE ÄNDERUNGEN - ABSOLUTE SPERRZONE

### ⛔⛔⛔ WARNUNG: DIESE LISTE IST HEILIG! ⛔⛔⛔
**Alles hier wurde GETESTET und FUNKTIONIERT!**
**NIEMALS ändern ohne EXPLIZITE Freigabe vom User!**
**"Verbesserungen" sind KEINE Freigabe!**

### Datum: 2026-01-16 (und fortlaufend)

### 🔒 CSS Header (15px, schwarz) - EINGEFROREN!
- `css/form-titles.css` → **KEINE Änderung!**
- `css/unified-header.css` → **KEINE Änderung!**
- Font-size: 15px → **NICHT ändern!**
- Color: schwarz → **NICHT ändern!**

### 🔒 Header-korrigierte Formulare (27 Stück) - EINGEFROREN!
**Diese Formulare NICHT anfassen (Header, Layout, Styles):**
frm_MA_VA_Schnellauswahl, frm_DP_Dienstplan_MA, frm_DP_Dienstplan_Objekt, frm_Einsatzuebersicht, frm_MA_Abwesenheit, frm_MA_Zeitkonten, frm_Rechnung, frm_Angebot, frm_N_Bewerber, frm_Rueckmeldestatistik, frm_Systeminfo, frm_Abwesenheiten, frm_Ausweis_Create, frm_Kundenpreise_gueni, frm_MA_Serien_eMail_Auftrag, frm_MA_Serien_eMail_dienstplan, frm_MA_VA_Positionszuordnung, frm_abwesenheitsuebersicht, frm_DP_Einzeldienstplaene, frm_MA_Tabelle, frm_Mahnung, frm_KD_Verrechnungssaetze, frm_MA_Offene_Anfragen, frm_MA_Adressen, frm_KD_Umsatzauswertung, frm_va_Auftragstamm2
*(Ausnahme: frm_Menuefuehrung1 - eigenes Design)*

**Was ist bei diesen Formularen eingefroren:**
- Header-Struktur und -Styling
- Schriftgrößen
- Farben
- Abstände
- Layout-Positionen

### 🔒 Export-System - EINGEFROREN!
`mod_ClaudeExport_Ultimate.bas` → **NICHT ändern!**
Erstellt 4 Index-Dateien → Struktur ist fix!

---

## 🚨 FREEZE-VERLETZUNGS-ERKENNUNG

### Typische Fehler die zum Freeze-Bruch führen:

**1. "Ich räume nur kurz auf"**
→ NEIN! Aufräumen ist VERBOTEN!

**2. "Das macht den Code besser"**
→ NEIN! Verbesserungen sind VERBOTEN!

**3. "Das war eh doppelt"**
→ NEIN! Doppelter Code ist oft ABSICHT!

**4. "Die Styles waren inkonsistent"**
→ NEIN! Inkonsistenz ist manchmal ABSICHT!

**5. "Ich passe nur schnell X an, Y bleibt gleich"**
→ STOPP! Prüfen ob Y eingefroren ist!

**6. "Das hängt zusammen, also ändere ich beides"**
→ STOPP! Nur das Ändern was EXPLIZIT angefordert wurde!

### 📝 Selbst-Test vor JEDER Änderung:
```
❓ Wurde diese spezifische Änderung angefordert? 
❓ Ist die Datei in der Freeze-Liste?
❓ Betrifft es CSS/Layout eines eingefrorenen Formulars?
❓ Ändere ich mehr als das absolute Minimum?
❓ "Verbessere" ich etwas das funktioniert?

Wenn IRGENDEINE Antwort unsicher ist → USER FRAGEN!
```

---

## ⚙️ REGELN

### ENCODING
- **HTML/CSS/JS/Python:** UTF-8 mit echten Umlauten (ö ü ä)
- **BATCH (.bat/.cmd):** KEINE Umlaute! ö→oe, ü→ue, ä→ae, KEIN chcp 65001!

### ALLGEMEIN
- Funktionierende Lösungen NICHT ändern
- Neue VBA-Funktionen: `_N_` Präfix
- Token sparen: Kurze Antworten, max 3 Tool-Calls

### QUALITÄTSSICHERUNG
- VBA kompilieren nach Änderung
- API testen (curl/Browser)
- Feldnamen: `tbl_MA_Mitarbeiterstamm.ID` (nicht MA_ID!), `Kurzname` existiert NICHT

---

## 🏆 ERLEDIGT-REGEL (KRITISCH!)

**NIEMALS "Erledigt" ohne vorher SELBST getestet!**

### Pflicht-Tests vor "Erledigt":
1. API-Test: curl/fetch → Ergebnis zeigen
2. Browser-Test: Playwright → Funktion auslösen
3. Console: Keine Fehler
4. Ergebnis verifizieren

### ❌ VERBOTEN
"Sollte funktionieren", "Müsste klappen", "Code angepasst" ohne Test

### ✅ Format
```
✅ API: POST /api/xyz → {"success": true}
✅ Browser: Aktion → Ergebnis
✅ Console: OK
Erledigt !
```

---

## 🤖 MULTI-AGENT SYSTEM (2026-01-22)

### Ordnerstruktur
| Ordner | Inhalt |
|--------|--------|
| `checkpoints/` | Etappen-Checkpoints (CP0-CP10) |
| `engine/` | Orchestrator, Agenten-Definitionen |
| `validation/` | Gates, Test-Matrix |
| `0_Claude_Skills/` | 17 Skills + Katalog |

### Agenten-Rollen
PLANNER → RESEARCHER → IMPLEMENTER → REVIEWER → TESTER → PUBLISHER

### Validation Gates (6)
PRE-IMPL → POST-IMPL → COMPLIANCE → ACCESS-PARITÄT → BROWSER-TEST → REGRESSION

### Slash-Commands
`/etappe [N]`, `/checkpoint`, `/validate`, `/skills`

### Start-Dateien
- `Start_Claude_Code_MultiAgent.bat`
- `start-codex-multiagent.cmd`

### Definition of Done
✅ Alle Gates ✅ CLAUDE2.md ✅ Browser-Test ✅ Console OK ✅ Regression OK

---

## 🔧 ACCESS BRIDGE vs. OFFICEMCP - ENTSCHEIDUNGSLOGIK (PFLICHT!)

### WICHTIG: Bei JEDER Office/Access-Aufgabe diese Logik anwenden!

### 📊 Entscheidungsmatrix

| Aufgabe | Tool | Grund |
|---------|------|-------|
| VBA-Funktion aufrufen | **Access Bridge** | `run_vba_function()` |
| Query erstellen/ändern | **Access Bridge** | `create_query()` |
| Formular erstellen | **Access Bridge** | `create_form()` |
| VBA-Modul importieren | **Access Bridge** | `import_vba_module()` |
| SQL auf Backend | **Access Bridge** | `execute_sql()` |
| Access-Objekte auflisten | **Access Bridge** | `list_forms()`, `list_queries()` |
| Mail mit Access-Templates | **Access Bridge** | VBA `create_Mail()` nutzt Templates |
| Mail OHNE Access-Daten | **OfficeMCP** | `Officer.Outlook` direkt |
| Excel-Datei erstellen/bearbeiten | **OfficeMCP** | `Officer.Excel` |
| Word-Dokument erstellen | **OfficeMCP** | `Officer.Word` |
| PowerPoint bearbeiten | **OfficeMCP** | `Officer.PowerPoint` |
| Screenshot Office-App | **OfficeMCP** | `ScreenShot()` |
| Office-App starten/prüfen | **OfficeMCP** | `Launch()`, `AvailableApps()` |

### 🚦 Entscheidungsbaum

```
Aufgabe betrifft Access-Datenbank?
├── JA → Braucht VBA-Ausführung oder DB-Zugriff?
│   ├── JA → ACCESS BRIDGE ULTIMATE
│   │   - run_vba_function() für VBA
│   │   - execute_sql() für Daten
│   │   - create_query/form/module() für Objekte
│   └── NEIN → Nur Daten lesen?
│       └── JA → ACCESS BRIDGE (execute_sql)
│
└── NEIN → Betrifft andere Office-App?
    ├── Outlook (Mail ohne Access-Templates) → OFFICEMCP
    ├── Excel → OFFICEMCP
    ├── Word → OFFICEMCP
    └── PowerPoint → OFFICEMCP
```

### 📧 SPEZIALFALL: E-MAIL VERSAND

**Mail MIT Access-Daten/Templates:**
```python
# RICHTIG: Access Bridge → VBA aufrufen
bridge.run_vba_function("create_Mail", MA_ID, VA_ID, VADatum_ID, VAStart_ID, 1)
# → Nutzt Templates von \\vConSYS01-NBG\Database\HTMLBodies\
# → Nutzt Platzhalter-Logik aus VBA
# → Loggt in tbl_Log_eMail_Sent
```

**Mail OHNE Access-Bezug:**
```python
# OfficeMCP direkt (nur wenn KEINE Access-Templates benötigt!)
# Officer.Outlook für einfache Mails
```

### 🔗 Access Bridge Ultimate - Pfad & Verwendung

**Pfad:** `C:\Users\guenther.siegert\Documents\Access Bridge\access_bridge_ultimate.py`

**Import:**
```python
from access_bridge_ultimate import AccessBridge

with AccessBridge() as bridge:
    # VBA ausführen
    result = bridge.run_vba_function("FunktionsName", arg1, arg2)

    # SQL ausführen
    data = bridge.execute_sql("SELECT * FROM tbl_MA_Mitarbeiterstamm", fetch=True)

    # Objekte erstellen
    bridge.create_query("TestQuery", "SELECT * FROM tbl")
```

### 🔗 OfficeMCP - Verfügbare Tools

**Nach Claude Code Neustart verfügbar als `mcp__officemcp__*`:**
- `AvailableApps()` - Installierte Office-Apps
- `Launch(app_name, visible)` - App starten
- `Visible(app_name, visible)` - Sichtbarkeit setzen
- `ScreenShot(save_path)` - Screenshot erstellen
- `RootFolder()` - Arbeitsverzeichnis

**Arbeitsverzeichnis:** `C:\Users\guenther.siegert\Documents\OfficeMCP`

### ⚠️ NIEMALS:
- OfficeMCP für Access-Datenbank-Operationen nutzen
- Access Bridge für Excel/Word/PowerPoint nutzen
- Mail mit Access-Templates über OfficeMCP senden (Templates gehen verloren!)
- Beide Tools für dieselbe Aufgabe mischen

---

## 🐛 VBA DEBUG MCP - ENTSCHEIDUNGSLOGIK

### Wann VBA Debug MCP nutzen:

| Situation | Tool | Grund |
|-----------|------|-------|
| VBA Runtime-Fehler erkennen | **VBA Debug MCP** | Error-Trapping, Call Stack |
| Debug.Print Ausgaben lesen | **VBA Debug MCP** | Echtzeit-Abfangen |
| Syntax vor Import prüfen | **VBA Debug MCP** | Compile-Check |
| VBA-Funktion ausführen | Access Bridge | `run_vba_function()` |
| VBA-Modul importieren | Access Bridge | `import_vba_module()` |

### Entscheidungsbaum bei VBA-Problemen:

```
VBA-Problem?
├── Fehler erkennen/debuggen?
│   └── VBA DEBUG MCP
│
├── Code ausführen?
│   └── ACCESS BRIDGE
│
└── Code importieren/ändern?
    └── ACCESS BRIDGE
```

### Tool-Zusammenspiel (WICHTIG!):

```
[Entwicklung]     → Access Bridge (Module, Queries, Forms)
       ↓
[Debugging]       → VBA Debug MCP (Fehler, Debug.Print)
       ↓
[Ausführung]      → Access Bridge (run_vba_function)
       ↓
[Office-Export]   → OfficeMCP (Excel, Word, Outlook)
```
