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

## 🛑 GESCHÜTZTE BEREICHE

**VOR Änderung:** Suche "GESCHÜTZT" → Gefunden? STOPP + User fragen!

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

Bei JEDER HTML/CSS/JS-Änderung:
1. Explizite Anweisung vorhanden? Sonst STOPP!
2. In `CLAUDE2.md` dokumentieren
3. Kritisch? → Einfrieren

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

## 🔒 EINGEFRORENE ÄNDERUNGEN (2026-01-16)

### CSS Header (15px, schwarz)
- `css/form-titles.css`, `css/unified-header.css`

### Header-korrigierte Formulare (27 Stück) ✅
frm_MA_VA_Schnellauswahl, frm_DP_Dienstplan_MA, frm_DP_Dienstplan_Objekt, frm_Einsatzuebersicht, frm_MA_Abwesenheit, frm_MA_Zeitkonten, frm_Rechnung, frm_Angebot, frm_N_Bewerber, frm_Rueckmeldestatistik, frm_Systeminfo, frm_Abwesenheiten, frm_Ausweis_Create, frm_Kundenpreise_gueni, frm_MA_Serien_eMail_Auftrag, frm_MA_Serien_eMail_dienstplan, frm_MA_VA_Positionszuordnung, frm_abwesenheitsuebersicht, frm_DP_Einzeldienstplaene, frm_MA_Tabelle, frm_Mahnung, frm_KD_Verrechnungssaetze, frm_MA_Offene_Anfragen, frm_MA_Adressen, frm_KD_Umsatzauswertung, frm_va_Auftragstamm2
*(Ausnahme: frm_Menuefuehrung1 - eigenes Design)*

### Export-System (eingefroren)
`mod_ClaudeExport_Ultimate.bas` → erstellt 4 Index-Dateien

---

## ⚠️ REGELN

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
