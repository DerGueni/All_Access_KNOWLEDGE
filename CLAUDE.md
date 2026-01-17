# Claude Code Project Rules - KOMPAKT

## 📂 ACCESS EXPORT DATEN (IMMER ZUERST LESEN!)

**Pfad:** `exports/`

### 🚀 SCHNELLZUGRIFF - Index-Dateien (DIESE ZUERST!)

| Datei | Zweck | Beispiel-Suche |
|-------|-------|----------------|
| **`MASTER_INDEX.json`** | Alle Formulare mit Button-Liste | "Welche Buttons hat frm_VA_Auftragstamm?" |
| **`BUTTON_LOOKUP.json`** | Button-Name → Formular + VBA | "Wo ist btnSchnellPlan definiert?" |
| **`VBA_EVENT_MAP.json`** | Events nach Typ gruppiert | "Alle OnClick-Events finden" |
| **`FORM_DETAIL_INDEX.json`** | Formular → alle Dateipfade | "Welche Dateien gehören zu frm_MA_Mitarbeiterstamm?" |

### 🔍 Workflow für Button-Arbeit
```
1. BUTTON_LOOKUP.json öffnen
2. Button-Name suchen (z.B. "btnSchnellPlan")
3. Ergebnis: {"form":"frm_VA_Auftragstamm", "vbaFile":"exports/vba/forms/Form_frm_VA_Auftragstamm.bas"}
4. VBA-Datei öffnen → Funktion "btnSchnellPlan_Click" finden
```

### 📁 Detail-Daten (bei Bedarf)
| Pfad | Inhalt |
|------|--------|
| `exports/forms/[NAME]/controls.json` | Alle Controls mit Properties + Events |
| `exports/forms/[NAME]/subforms.json` | Unterformular-Hierarchie |
| `exports/vba/forms/Form_[NAME].bas` | VBA-Code mit Event-Handlern |
| `exports/queries/*.sql` | SQL-Abfragen |

### ⚡ Export aktualisieren
```vba
Call ExportUltimate   ' Erstellt alle 4 Index-Dateien neu
```

---

## 🚨 MASTER-REGEL: ACCESS-PARITÄT

**Trigger-Wörter:** "wie in Access", "teste Buttons", "funktioniert wie", "Filter wie Access"

### PFLICHT-WORKFLOW:
1. **LESEN:** `exports/vba/forms/Form_frm_[NAME].bas` + `exports/forms/frm_[NAME]/controls.json`
2. **ANALYSIEREN:** Events finden (`_Click`, `_AfterUpdate`, `_DblClick`)
3. **IMPLEMENTIEREN:** Exakt gleiche Logik in JavaScript
4. **TESTEN:** Browser öffnen, klicken, Console prüfen
5. **REGRESSION:** 3 andere Buttons testen

### VBA → JavaScript Mapping:
| VBA | JS |
|-----|-----|
| `_Click` | `onclick` |
| `_DblClick` | `dblclick` |
| `_AfterUpdate` | `change` |
| `Me.Requery` | `loadData()` |
| `Me.[X].Visible` | `element.style.display` |
| `Me.[X].Enabled` | `element.disabled` |

### FERTIG-MELDUNG muss enthalten:
```
✅ VBA gelesen: [Datei]
✅ Browser getestet: [was passiert]
✅ Console: Keine Fehler
✅ Regression: [Buttons] funktionieren
```

**VERBOTEN:** "Sollte funktionieren", "Code angepasst", "Müsste klappen"

---

## 🛑 GESCHÜTZTE BEREICHE (NIEMALS ÄNDERN!)

**VOR jeder Änderung:** Suche "GESCHÜTZT" in dieser Datei!

### Geschützte Funktionen mit `// GESCHÜTZT` im Code
### Geschützte API-Endpoints (Port 5000 + 5002)
### Geschützte Dateien (siehe unten)

**Workflow:** GESCHÜTZT gefunden → STOPPEN → Benutzer fragen

---

## 🛑 ACCESS-INSTANZEN

**Erlaubt NUR:**
- Frontend: `0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb`
- Backend: `\\vConSYS01-NBG\...\0_Consec_V1_BE_V1.55_Test.accdb`

**VERBOTEN:** Andere .accdb, Produktions-DBs, Instanzen schließen

---

## ⚡ SKILLS AUTO-TRIGGER

| Trigger | Skill-Pfad |
|---------|------------|
| Button, onclick, klick | `0_Claude_Skills/consys-button-fixer/SKILL.md` |
| API, Endpoint, fetch | `0_Claude_Skills/consys-api-endpoint/SKILL.md` |
| Layout, CSS, Design | `0_Claude_Skills/html-form-design-expert/SKILL.md` |
| HTML ändern, Element, style | `0_Claude_Skills/html-change-tracker/SKILL.md` |

---

## 🔴 ÄNDERUNGS-TRACKING (PFLICHT!)

**Bei JEDER HTML/CSS/JS-Änderung:**
1. Prüfe: Explizite Benutzeranweisung vorhanden? → Sonst STOPP!
2. Dokumentiere in `CLAUDE2.md` (Vorher/Nachher)
3. Kritische Elemente → Einfrieren in CLAUDE2.md Tabelle

**Ohne Dokumentation = Änderung verboten!**

---

## 📁 WICHTIGE PFADE

- **HTML-Formulare:** `04_HTML_Forms\forms3\`
- **Logic-Dateien:** `04_HTML_Forms\forms3\logic\`
- **API Server:** Port 5000 (`Access Bridge\api_server.py`)
- **VBA Bridge:** Port 5002 (`04_HTML_Forms\api\vba_bridge_server.py`)
- **VBA-Exports:** `exports\vba\forms\` + `exports\forms\`

---

## 🔒 GESCHÜTZTE CODE-STELLEN

### sub_MA_VA_Zuordnung.logic.js - REST-API MODUS
```javascript
// IMMER REST-API verwenden - NIEMALS ändern!
const isBrowserMode = true; // Erzwinge REST-API Modus
```

### frm_va_Auftragstamm.logic.js - Auskommentierte bindButtons
```javascript
// ENTFERNT - HTML hat onclick Handler:
// bindButton('btnSchnellPlan', openMitarbeiterauswahl);
// bindButton('btn_BWN_Druck', druckeBWN);
// bindButton('cmd_BWN_send', cmdBWNSend);
```

### frm_MA_VA_Schnellauswahl.logic.js - dblclick-Handler
```javascript
// ENTFERNT - HTML List_MA_DblClick ist korrekt:
// row.addEventListener('dblclick', () => { zuordneEinzelnenMA(id); });
```

### shell.html - Kein blockierendes Alert
```javascript
// console.warn statt alert() - NIEMALS alert() verwenden!
```

---

## 🔒 GESCHÜTZTE VBA-BUTTONS (mod_N_HTML_Buttons.bas)

| Button | VBA-Funktion |
|--------|-------------|
| btn_ListeStd | `HTML_btn_ListeStd_Click` |
| btnDruckZusage | `HTML_btnDruckZusage_Click` |
| btnMailEins | `HTML_btnMailEins_Click` |
| btnMailBOS | `HTML_btn_Autosend_BOS_Click` |
| btnMailSub | `HTML_btnMailSub_Click` |
| cmdAuftragKopieren | `HTML_AuftragKopieren` |
| cmdAuftragLoeschen | `HTML_AuftragLoeschen` |
| btn_BWN_Druck | `HTML_btn_BWN_Druck_Click` |
| cmd_BWN_send | `HTML_cmd_BWN_send_Click` |

---

## 🔒 GESCHÜTZTE API-ENDPOINTS (api_server.py)

- `/api/auftraege/<va_id>/schichten`
- `/api/auftraege/<va_id>/zuordnungen`
- `/api/auftraege/<va_id>/absagen`

**Kritisch:** `vadatum_id` akzeptiert Integer-ID ODER Datum-String

---

## 🔒 GESCHÜTZTE SUBFORM-OPTIK (sub_MA_VA_Zuordnung)

Spalten: `Lfd | MA | von | bis | Std | Bemerk | ? | PKW | EL | RE`
CSS: font-size: 11px, table-layout: fixed

---

## 🔒 EINGEFRORENE ÄNDERUNGEN (2026-01-16) - NICHT ÄNDERN!

**Regel:** Alle abgeschlossenen Änderungen gelten als funktionell eingefroren.
Änderungen NUR auf explizite, direkte Anweisung des Benutzers!

### CSS Header-Vereinheitlichung (15px, schwarz)
- `css/form-titles.css` - `--title-font-size: 15px`, `color: #000000`
- `css/unified-header.css` - `--title-font-size: 15px`

### Batch 1 - Header korrigiert
- frm_MA_VA_Schnellauswahl.html ✅
- frm_DP_Dienstplan_MA.html ✅
- frm_DP_Dienstplan_Objekt.html ✅
- frm_Einsatzuebersicht.html ✅
- frm_MA_Abwesenheit.html ✅

### Batch 2 - Header korrigiert
- frm_MA_Zeitkonten.html ✅
- frm_Rechnung.html ✅
- frm_Angebot.html ✅
- frm_N_Bewerber.html ✅
- frm_Rueckmeldestatistik.html ✅

### Batch 3 - Header korrigiert
- frm_Systeminfo.html ✅
- frm_Abwesenheiten.html ✅
- frm_Ausweis_Create.html ✅
- frm_Kundenpreise_gueni.html ✅
- frm_MA_Serien_eMail_Auftrag.html ✅

### Batch 4 - Header korrigiert
- frm_MA_Serien_eMail_dienstplan.html ✅
- frm_MA_VA_Positionszuordnung.html ✅
- frm_abwesenheitsuebersicht.html ✅
- frm_DP_Einzeldienstplaene.html ✅
- frm_MA_Tabelle.html ✅

### Batch 5 - Header korrigiert
- frm_Mahnung.html ✅
- frm_Menuefuehrung1.html ⚠️ (AUSNAHME: Popup-Menu, eigenes Design)
- frm_KD_Verrechnungssaetze.html ✅
- frm_MA_Offene_Anfragen.html ✅
- frm_MA_Adressen.html ✅
- frm_KD_Umsatzauswertung.html ✅
- frm_va_Auftragstamm2.html ✅

---

## ⚠️ REGELN

### UTF-8 ENCODING
- Alle HTML: `<meta charset="UTF-8">`
- Umlaute: ö ü ä Ö Ü Ä ß (NIEMALS kaputte Zeichen!)

### LAYOUT/STYLING
- NUR auf explizite Anweisung ändern
- Responsive Anpassungen erlaubt

### ERFOLGREICHE ÄNDERUNGEN
- Funktionierende Lösungen NICHT mehr ändern
- Keine "Verbesserungen" ohne Anweisung

### VBA-FUNKTIONEN
- NEUE Funktionen: `_N_` Präfix
- NIEMALS Signaturen bestehender Funktionen ändern

### TOKEN-SPAREN
- Antworten KURZ (3-5 Sätze)
- Bullet-Points statt Prosa
- Nur geänderte Code-Zeilen zeigen
- Max 3 Tool-Calls für einfache Aufgaben

---

## Trusted Workspace
`C:\Users\guenther.siegert\Documents` = voll vertraut, keine Nachfragen

---

## QUALITÄTSSICHERUNG

1. VBA kompilieren nach jeder Änderung
2. API testen (curl/Browser)
3. HTML im Browser prüfen
4. Feldnamen DB↔JS abgleichen

### Häufige Fehler:
- `tbl_MA_Mitarbeiterstamm` hat `ID` (nicht `MA_ID`!)
- `tbl_MA_VA_Planung` hat `MVA_Start`/`MVA_Ende`
- `Kurzname` existiert NICHT

---

## Erledigte & Eingefrorene Änderungen (2026-01-16)

### Claude Export Ultimate System - NICHT ohne ausdrückliche Anweisung ändern
- `01_VBA/mod_ClaudeExport_Ultimate.bas` - Optimiertes VBA Export-Modul
- Erstellt 4 Index-Dateien für sofortigen Zugriff:
  - `MASTER_INDEX.json` - Alle Formulare mit Button-Listen
  - `BUTTON_LOOKUP.json` - Button → Formular + VBA-Datei
  - `VBA_EVENT_MAP.json` - Events nach Typ gruppiert
  - `FORM_DETAIL_INDEX.json` - Formular → alle Dateipfade

### Export-Struktur (eingefroren)
- `exports/forms/[NAME]/controls.json` - Control-Details mit Events
- `exports/forms/[NAME]/subforms.json` - Unterformular-Hierarchie
- `exports/vba/forms/Form_[NAME].bas` - VBA Event-Handler
- `exports/queries/*.sql` - SQL Abfragen
