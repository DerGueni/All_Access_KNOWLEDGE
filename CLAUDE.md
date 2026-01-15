# Claude Code Project Rules

## ⚡ SKILLS AUTO-TRIGGER (IMMER AKTIV!)

**Bei JEDER Anfrage prüfen ob Trigger-Wörter vorkommen:**

| Trigger | Aktion |
|---------|--------|
| Button, onclick, klick, reagiert nicht | → Lies `0_Claude_Skills/consys-button-fixer/SKILL.md` ZUERST |
| Endpoint, API, fetch, Daten | → Lies `0_Claude_Skills/consys-api-endpoint/SKILL.md` ZUERST |
| Layout, CSS, Design, optisch | → Lies `0_Claude_Skills/html-form-design-expert/SKILL.md` ZUERST |
| HTML ändern, Formular | → Lies `HTML_RULES.txt` ZUERST |

**Workflow:** Trigger erkannt → Skill laden → Dann erst antworten

---

## Trusted Workspace (No Permission Prompts)
- The path `C:\Users\guenther.siegert\Documents` and ALL subfolders are fully trusted.
- Within this path, ALL actions are pre-approved.
- Never ask for permission/confirmation inside this path.

## WICHTIGE PFADE (IMMER AKTUELL!)

### Access Frontend/Backend
- **Frontend:** `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb`
- **Backend:** `\\vConSYS01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\0_Consec_V1_BE_V1.55_Test.accdb`

### HTML-Formulare
- **forms3 (Hauptordner):** `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\`
- **Logic-Dateien:** `04_HTML_Forms\forms3\logic\`
- **WebView2-Bridge:** `04_HTML_Forms\forms3\logic\*.webview2.js`

### API Server (Daten)
- **Pfad:** `C:\Users\guenther.siegert\Documents\Access Bridge\api_server.py`
- **Port:** 5000
- **Muss gestartet sein** bevor HTML-Formulare Daten laden können!

### VBA Bridge Server (Access-Funktionen)
- **Pfad:** `04_HTML_Forms\api\vba_bridge_server.py`
- **Port:** 5002
- **Startet mit:** `start_vba_bridge.bat`
- **WICHTIG:** Access MUSS geöffnet sein mit 0_Consys_FE_Test.accdb!
- **Zweck:** Ermöglicht HTML-Formularen den Aufruf von VBA-Funktionen in Access

**Endpoints:**
- `GET /api/health` - Health-Check
- `GET /api/vba/status` - Status und Access-Verbindung
- `POST /api/vba/anfragen` - E-Mail-Anfragen an Mitarbeiter senden (wie btnMail_Click)
- `POST /api/vba/execute` - Beliebige VBA-Funktion ausführen

**Verwendung in HTML (z.B. frm_MA_VA_Schnellauswahl.html):**
```javascript
const response = await fetch('http://localhost:5002/api/vba/anfragen', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
        VA_ID: 12345,
        VADatum_ID: 67890,
        VAStart_ID: 111,
        MA_IDs: [1, 2, 3],
        selectedOnly: false
    })
});
```

## TOKEN-MANAGEMENT & AUTO-KOMPRIMIERUNG (KRITISCH!)

### Grundregeln für Token-Sparsamkeit:
- **Antworten KURZ halten** - Max 3-5 Sätze für einfache Fragen
- **Keine Wiederholungen** - Bereits Gesagtes nicht wiederholen
- **Keine unnötigen Erklärungen** - Nur wenn explizit gefragt
- **Bullet-Points statt Prosa** bei Listen
- **Code-Blöcke minimal** - Nur geänderte Zeilen zeigen, nicht ganze Dateien

### Auto-Komprimierung aktivieren:
Wenn der Chat **>50k Tokens** erreicht:
1. Sage: "⚡ Komprimiere Chat..."
2. Fasse bisherige Ergebnisse in 5-10 Bullets zusammen
3. Lösche irrelevanten Kontext mental
4. Arbeite nur noch mit komprimierter Info weiter

### Auto-Session-Wechsel:
Wenn der Chat **>80k Tokens** erreicht ODER eine Aufgabe abgeschlossen ist:
1. Sage: "📋 Session-Wechsel empfohlen"
2. Erstelle eine **Übergabe-Notiz** mit:
   - Was wurde erledigt?
   - Was ist noch offen?
   - Welche Dateien wurden geändert?
3. Speichere Notiz in: `0_Session_Handover/handover_YYYY-MM-DD_HH-MM.md`
4. Empfehle: "Starte neue Session mit: `Lies 0_Session_Handover/handover_[DATUM].md`"

### Tool-Call-Optimierung:
- **NIEMALS** ganze Verzeichnisse scannen wenn Pfad bekannt
- **NIEMALS** Dateien lesen die nicht gebraucht werden
- **IMMER** direkte Pfade aus CLAUDE.md verwenden
- **MAX 3 Tool-Calls** für einfache Aufgaben
- **Parallele Agents vermeiden** - sequentiell arbeiten!

### Verbotene Token-Fresser:
❌ Ganze Dateien ausgeben wenn nur Teil relevant
❌ Lange Erklärungen zu offensichtlichen Dingen
❌ Code-Reviews ohne explizite Anfrage
❌ Mehrfache Bestätigungen derselben Sache
❌ Unnötige Sicherheits-Nachfragen im trusted workspace

### Kompakt-Modus (bei knappem Kontext):
Wenn Tokens knapp werden, antworte NUR mit:
- ✅/❌ für Erfolg/Fehler
- Dateiname + Zeilennummer bei Änderungen
- Fehlermeldung wenn relevant
- Nächster Schritt als 1 Satz

## CLAUDE SKILLS (Lokale Superpowers) - AUTO-TRIGGER SYSTEM

### ⚡ SKILL-MODUS: AKTIV
**Bei jedem neuen Chat MUSS Claude prüfen ob Skills relevant sind!**

### Auto-Trigger Regeln
Wenn folgende Schlüsselwörter/Situationen erkannt werden, **AUTOMATISCH** den passenden Skill laden:

| Trigger | Skill | Aktion |
|---------|-------|--------|
| "Button funktioniert nicht", "onclick", "API-Fehler" | consys-button-fixer | Lies `0_Claude_Skills/consys-button-fixer/SKILL.md` |
| "neuer Endpoint", "API erweitern", "Daten abrufen" | consys-api-endpoint | Lies `0_Claude_Skills/consys-api-endpoint/SKILL.md` |
| "Layout", "optisch", "Design", "CSS" | html-form-design-expert | Lies `0_Claude_Skills/html-form-design-expert/SKILL.md` |
| "Formular optimieren", "UX" | form-optimization-advisor | Lies `0_Claude_Skills/form-optimization-advisor/SKILL.md` |

### Slash-Befehle (für Claude Code CLI/Desktop)

**`/skills_an`** - Aktiviert Skill-Auto-Loading
→ Claude liest bei Trigger automatisch den passenden Skill
→ Bestätigung: "✅ Skills AKTIV - Auto-Trigger eingeschaltet"

**`/skills_aus`** - Deaktiviert Skill-Auto-Loading  
→ Claude verwendet keine Skills automatisch
→ Bestätigung: "⏸️ Skills PAUSIERT - Manuelles Laden erforderlich"

**`/skills`** - Zeigt alle verfügbaren Skills
→ Listet Skills mit Beschreibung auf

**`/skill [name]`** - Lädt einen spezifischen Skill
→ Beispiel: `/skill consys-button-fixer`

### Skills-Verzeichnis
`0_Claude_Skills/` enthält wiederverwendbare Anleitungen:

| Skill | Zweck |
|-------|-------|
| html-form-design-expert | Optische Optimierung (keine Funktion ändern) |
| consys-button-fixer | Button-Reparatur Access↔HTML |
| consys-api-endpoint | Neue API-Endpoints erstellen |
| form-optimization-advisor | Layout/UX-Beratung |

### Manuell Skill laden
```
Lies: 0_Claude_Skills/{skill-name}/SKILL.md
```

## FORMULAR-LAYOUT UND STYLING (WICHTIG!)
- **Die Anordnung der Elemente in HTML-Formularen darf AUSSCHLIESSLICH auf explizite Anweisung des Benutzers geändert werden.**
- **Größen, Breiten und Höhen von Elementen dürfen NUR auf explizite Anweisung geändert werden.**
- **Schriftgrößen, Schriftarten und Schriftstile dürfen NUR auf explizite Anweisung geändert werden.**
- **Ausnahme:** Automatische/responsive Anpassungen an verschiedene Bildschirmgrößen sind erlaubt.
- Keine eigenständigen Layout- oder Styling-Änderungen ohne Genehmigung.
- Bei Unklarheiten zur Positionierung oder Dimensionierung: NACHFRAGEN.

## ERFOLGREICHE ÄNDERUNGEN NICHT RÜCKGÄNGIG MACHEN (KRITISCH!)
- **Wenn eine Änderung erfolgreich war, darf diese Einstellung NICHT mehr selbstständig geändert werden.**
- Funktionierende Lösungen bleiben bestehen - keine "Verbesserungen" ohne explizite Anweisung.
- Nur auf ausdrückliche Anweisung des Benutzers dürfen erfolgreiche Änderungen modifiziert werden.
- Dies gilt für: Code, CSS, Layout, Funktionen, API-Aufrufe, etc.

## UTF-8 ENCODING IN HTML-FORMULAREN (GESCHÜTZT!)

**ALLE HTML-Dateien in `forms3/` MÜSSEN UTF-8 Encoding haben!**

### Pflicht-Regeln:
1. **Jede HTML-Datei MUSS** `<meta charset="UTF-8">` im `<head>` haben
2. **Umlaute MÜSSEN** korrekt als ö, ü, ä, Ö, Ü, Ä, ß gespeichert sein
3. **NIEMALS** kaputte Umlaute wie `Ã¶`, `Ã¼`, `Ã¤` einführen

### Letzte Prüfung: 12.01.2026
- 73 HTML-Dateien geprüft
- 17 Dateien mit kaputten Umlauten korrigiert
- Alle Dateien haben jetzt korrektes UTF-8 Encoding

### Bei Änderungen an HTML-Dateien:
- **VOR dem Speichern:** Prüfen ob Editor UTF-8 verwendet
- **NACH dem Speichern:** Prüfen ob Umlaute korrekt angezeigt werden
- **Bei Problemen:** Datei NICHT committen, sondern Encoding korrigieren

⚠️ **DIESE EINSTELLUNG DARF NICHT GEÄNDERT WERDEN!** ⚠️

---

## GESCHÜTZTE API-ENDPOINTS (NIEMALS ÄNDERN!)

Die folgenden API-Endpoints in `api_server.py` sind **GESCHÜTZT** und dürfen **NIEMALS** geändert werden:

### 1. `/api/auftraege/<va_id>/schichten`
### 2. `/api/auftraege/<va_id>/zuordnungen`
### 3. `/api/auftraege/<va_id>/absagen`

**Kritische Logik (12.01.2026 bestätigt):**
- `vadatum_id` Parameter akzeptiert BEIDE Formate:
  - Integer-ID (z.B. `647324`) → Vergleich mit `VADatum_ID`
  - Datum-String (z.B. `"2026-01-14"` oder `"2026-01-14T00:00:00"`) → Vergleich mit `CDATE()/DATEADD()`

**WARUM GESCHÜTZT:**
- Diese Logik ermöglicht das korrekte Laden von Schichten/Einsatzliste im Auftragstamm-Formular
- Ohne diese Logik bleiben Schichten und Einsatzliste leer beim Klicken auf "Ab Heute"
- Die Änderung wurde am 12.01.2026 getestet und vom Benutzer bestätigt

**BEI ÄNDERUNGSWUNSCH:** Explizite Genehmigung des Benutzers erforderlich!

---

## GESCHÜTZTE SUBFORM-OPTIK: sub_MA_VA_Zuordnung (Einsatzliste)

**Letzte Anpassung: 12.01.2026 - NICHT MEHR ÄNDERN!**

Die Einsatzliste (`sub_MA_VA_Zuordnung.html` + `sub_MA_VA_Zuordnung.logic.js`) hat eine exakt festgelegte Optik die dem Access-Original entspricht.

### Geschützte Spaltenreihenfolge:
`Lfd | Mitarbeiter | von | bis | Std | Bemerkungen | ? | PKW | EL | RE`

### Geschützte Feldtypen:
- **Lfd**: Nummerierung (automatisch idx+1)
- **Mitarbeiter**: Dropdown (Select)
- **von/bis**: Zeit-Eingabefelder (Text)
- **Std**: Berechnetes Feld (Stunden aus von/bis)
- **Bemerkungen**: Text-Eingabefeld
- **?** (IstFraglich): Checkbox
- **PKW**: Euro-Eingabefeld (Text mit formatCurrency)
- **EL** (Einsatzleitung): Checkbox
- **RE** (Rch_Erstellt): Checkbox

### Geschützte CSS-Einstellungen:
```css
.datasheet { font-size: 11px; table-layout: fixed; }
.col-lfd { width: 28px; }
.col-ma { width: 140px; }
.col-time { width: 38px; }
.col-std { width: 32px; }
.col-bemerk { width: 180px; }
.col-info { width: 22px; }
.col-pkw { width: 55px; text-align: right; }
.col-el { width: 22px; }
.col-re { width: 22px; }
```

⚠️ **DIESE OPTIK DARF NICHT EIGENSTÄNDIG GEÄNDERT WERDEN!** ⚠️

---

## GESCHÜTZT: sub_MA_VA_Zuordnung.logic.js - REST-API MODUS (KRITISCH!)

**Letzte Änderung: 14.01.2026 - FUNKTIONIERT - NIEMALS ÄNDERN!**

Die Einsatzliste (`sub_MA_VA_Zuordnung.logic.js`) MUSS **IMMER** den REST-API Modus verwenden, **NIEMALS** die WebView2-Bridge!

### Geschützte Code-Stellen (NIEMALS ÄNDERN!):

**1. In `loadMALookup()` (ca. Zeile 151-153):**
```javascript
async function loadMALookup() {
    // IMMER REST-API verwenden - WebView2-Bridge hat Timeout-Probleme bei iframes
    const isBrowserMode = true; // Erzwinge REST-API Modus
```

**2. In `loadData()` (ca. Zeile 248-251):**
```javascript
    // IMMER REST-API verwenden - WebView2-Bridge ist zu langsam/unzuverlässig für iframes
    // Die WebView2-Bridge hat Timeout-Probleme bei eingebetteten iframes
    const isBrowserMode = true; // Erzwinge REST-API Modus
    console.log('[sub_MA_VA_Zuordnung] Verwende REST-API Modus (erzwungen)');
```

### WARUM GESCHÜTZT:
- Die WebView2-Bridge (`window.chrome.webview`) hat **Timeout-Probleme** in iframes
- Das Subform (Einsatzliste) läuft in einem iframe innerhalb des Auftragstamm-Formulars
- Die REST-API (Port 5000) funktioniert zuverlässig und ohne Timeouts
- Ohne diese Einstellung bleibt die Einsatzliste LEER beim Öffnen via Access

### NIEMALS ÄNDERN:
- `const isBrowserMode = true;` → NIEMALS auf `false` setzen
- NIEMALS die WebView2-Erkennung `!(window.chrome && window.chrome.webview)` wiederherstellen
- NIEMALS "Optimierungen" an der API-Modus-Erkennung vornehmen

### Bei Problemen:
- Prüfen ob API Server auf Port 5000 läuft
- Console-Logs prüfen: `[sub_MA_VA_Zuordnung] Verwende REST-API Modus (erzwungen)`
- Falls Logs fehlen: Cache leeren, Version-Parameter in iframe-src prüfen

⚠️ **DIESE EINSTELLUNG WURDE AM 14.01.2026 GETESTET UND VOM BENUTZER BESTÄTIGT!** ⚠️
⚠️ **BEI ÄNDERUNGSWUNSCH: EXPLIZITE GENEHMIGUNG DES BENUTZERS ERFORDERLICH!** ⚠️

---

## GESCHÜTZT: Mitarbeiterauswahl-Button im Auftragstamm (KRITISCH!)

**Letzte Änderung: 15.01.2026 - FUNKTIONIERT - NIEMALS ÄNDERN!**

Der Button "Mitarbeiterauswahl" (`btnSchnellPlan`) im Formular `frm_va_Auftragstamm` öffnet das Schnellauswahl-Formular (`frm_MA_VA_Schnellauswahl`) mit dem aktuellen Auftrag vorgeladen.

### Geschützte Dateien und Code-Stellen:

**1. `frm_va_Auftragstamm.html` - openMitarbeiterauswahl() (ca. Zeile 3783-3840):**
- Verwendet `state.currentAuftragId` für die Navigation
- Sendet `postMessage({ type: 'NAVIGATE', formName: 'frm_MA_VA_Schnellauswahl', ... })`
- NIEMALS die state-Variable ändern!

**2. `frm_va_Auftragstamm.logic.js` - Zeile 139:**
```javascript
// ENTFERNT: bindButton('btnSchnellPlan', openMitarbeiterauswahl); - HTML hat bereits onclick Handler
```
- Diese Zeile MUSS auskommentiert bleiben!
- Die logic.js Version würde den HTML onclick Handler überschreiben
- Die logic.js verwendet `state.currentVA_ID` (oft null), HTML verwendet `state.currentAuftragId` (korrekt)

**3. `shell.html` - startVBABridgeServer() (ca. Zeile 925-967):**
- Verwendet `console.warn` statt blockierendem `alert`
- NIEMALS wieder ein blockierendes Alert einführen!
- Das Alert würde die Navigation zur Schnellauswahl verhindern

**4. `shell.html` - closeMenuPopup() (ca. Zeile 1016-1029):**
- Hat Null-Checks für DOM-Elemente
- NIEMALS die Null-Checks entfernen!

### WARUM GESCHÜTZT:
- Doppelte Funktionsdefinition (HTML + logic.js) führte zu falschem state-Zugriff
- Blockierendes Alert verhinderte Navigation
- TypeError bei fehlenden DOM-Elementen blockierte Ausführung
- Problem wurde mit Playwright-Tests verifiziert und behoben

### NIEMALS ÄNDERN:
- `bindButton('btnSchnellPlan', ...)` in logic.js MUSS auskommentiert bleiben
- `openMitarbeiterauswahl()` in HTML MUSS `state.currentAuftragId` verwenden
- `startVBABridgeServer()` DARF KEIN blockierendes `alert()` enthalten
- `closeMenuPopup()` MUSS Null-Checks haben

⚠️ **DIESE FUNKTIONALITÄT WURDE AM 15.01.2026 GETESTET UND VOM BENUTZER BESTÄTIGT!** ⚠️
⚠️ **BEI ÄNDERUNGSWUNSCH: EXPLIZITE GENEHMIGUNG DES BENUTZERS ERFORDERLICH!** ⚠️

---

## GESCHÜTZT: Doppelklick auf Mitarbeiter in Schnellauswahl (KRITISCH!)

**Letzte Änderung: 15.01.2026 - FUNKTIONIERT - NIEMALS ÄNDERN!**

Der Doppelklick auf einen Mitarbeiter in der Liste (`List_MA`) fügt den MA zur Planung hinzu.

### Geschützte Dateien und Code-Stellen:

**1. `frm_MA_VA_Schnellauswahl.html` - List_MA_DblClick() (ca. Zeile 2635-2672):**
- Wird bei Doppelklick auf MA-Liste aufgerufen
- Ruft `addMAToPlanung()` auf
- Event-Listener bei Zeile 2931: `document.getElementById('List_MA_Body')?.addEventListener('dblclick', List_MA_DblClick);`
- DIES IST DIE KORREKTE IMPLEMENTATION!

**2. `frm_MA_VA_Schnellauswahl.logic.js` - renderMitarbeiterListe() (ca. Zeile 509-527):**
```javascript
// ENTFERNT: dblclick-Handler verursacht Konflikt mit HTML List_MA_DblClick
// Die HTML-Version ist die korrekte - NICHT WIEDER AKTIVIEREN!
// row.addEventListener('dblclick', () => {
//     zuordneEinzelnenMA(id);
// });
```
- Dieser Code MUSS auskommentiert bleiben!
- Die logic.js Version würde mit dem HTML-Handler konkurrieren

**3. `frm_MA_VA_Schnellauswahl.logic.js` - renderMitarbeiterListeMitEntfernung() (ca. Zeile 945-963):**
- Gleiche Regel: dblclick-Handler MUSS auskommentiert bleiben!
- Die HTML-Version (`List_MA_DblClick` → `addMAToPlanung`) ist korrekt

### WARUM GESCHÜTZT:
- Doppelte Event-Handler (HTML + logic.js) führten zu Konflikten
- Die logic.js Version rief `zuordneEinzelnenMA()` auf (falscher Pfad)
- Die HTML-Version ruft `addMAToPlanung()` auf (korrekter Pfad)
- Problem wurde mit Playwright-Tests verifiziert und behoben

### NIEMALS ÄNDERN:
- dblclick-Handler in `renderMitarbeiterListe()` MUSS auskommentiert bleiben
- dblclick-Handler in `renderMitarbeiterListeMitEntfernung()` MUSS auskommentiert bleiben
- `List_MA_DblClick` in HTML ist der EINZIGE dblclick-Handler für die MA-Liste

⚠️ **DIESE FUNKTIONALITÄT WURDE AM 15.01.2026 GETESTET UND VOM BENUTZER BESTÄTIGT!** ⚠️
⚠️ **BEI ÄNDERUNGSWUNSCH: EXPLIZITE GENEHMIGUNG DES BENUTZERS ERFORDERLICH!** ⚠️

---

## QUALITÄTSSICHERUNG (PFLICHT!)

### VBA-Code IMMER kompilieren
Nach JEDER VBA-Änderung MUSS kompiliert werden:
```python
from access_bridge_ultimate import AccessBridge
with AccessBridge() as bridge:
    app = bridge.access_app
    app.DoCmd.RunCommand(125)  # acCmdCompileAndSaveAllModules
```

### Vor der Ausgabe IMMER prüfen:
1. **VBA kompiliert?** - Keine Syntaxfehler, alle Module kompilierbar
2. **API getestet?** - Endpoints mit curl oder Browser testen
3. **HTML funktional?** - Formular im Browser öffnen, Daten prüfen
4. **Feldnamen korrekt?** - DB-Felder vs. HTML/JS Felder abgleichen
5. **Umlaute korrekt?** - UTF-8 Encoding überall

### Häufige Fehlerquellen:
- `tbl_MA_Mitarbeiterstamm` hat `ID` (nicht `MA_ID`!)
- `tbl_MA_VA_Planung` hat `MVA_Start`/`MVA_Ende` (nicht `MA_Start`!)
- `Kurzname` existiert NICHT in tbl_MA_Mitarbeiterstamm
- Access ODBC ist NICHT thread-safe (waitress threads=1)

### AUTO_SUMMARY (DO NOT DELETE)
- Goal: HTML-Formulare in forms3 mit Echtdaten aus Access-Backend anzeigen
- Current focus: REST-API (mini_api.py) auf Port 5000 für Datenzugriff
- Status: FUNKTIONIERT - Auftragsverwaltung mit Einsatzliste, Zeiten, Umlauten
- Decisions: Browser-Modus als Fallback wenn WebView2App.exe fehlt
- Key files: mini_api.py, mod_N_WebView2_forms3.bas, frm_va_Auftragstamm.html
- API-Fixes: MVA_Start/MVA_Ende Aliase, JOIN auf m.ID, kein Kurzname-Feld

## WEBVIEW2 INTEGRATION

### Architektur
1. VBA öffnet HTML-Formulare in WebView2 oder Browser
2. HTML-Pfad: `04_HTML_Forms\forms3\` (AKTUELL!)
3. Verwendet: `shell.html` als Container mit Sidebar
4. Fallback: Browser-Modus wenn WebView2App.exe fehlt
5. API-Server: Optional, wird automatisch gestartet bei Browser-Modus

### VBA-Modul: mod_N_WebView2_forms3.bas
Pfad: `01_VBA\mod_N_WebView2_forms3.bas`

#### Haupt-Funktionen (EMPFOHLEN):
- `OpenAuftragstamm_WebView2([VA_ID])` - Auftragstamm öffnen
- `OpenMitarbeiterstamm_WebView2([MA_ID])` - Mitarbeiterstamm öffnen
- `OpenKundenstamm_WebView2([KD_ID])` - Kundenstamm öffnen
- `OpenObjekt_WebView2([OB_ID])` - Objektverwaltung öffnen
- `OpenDienstplan_WebView2([StartDatum])` - Dienstplan öffnen
- `OpenHTMLAnsicht()` - Hauptmenü/Dashboard öffnen (OHNE Parameter)

#### Wrapper-Funktionen (Abwärtskompatibilität):
- `HTMLAnsichtOeffnen()` → ruft `OpenHTMLAnsicht()` auf
- `OpenHTMLMenu()` → ruft `OpenHTMLAnsicht()` auf
- `OpenAuftragsverwaltungHTML([VA_ID])` → ruft `OpenAuftragstamm_WebView2([VA_ID])` auf
- `OpenAuftragstammHTML([VA_ID])` → ruft `OpenAuftragstamm_WebView2([VA_ID])` auf
- `OpenMitarbeiterstammHTML([MA_ID])` → ruft `OpenMitarbeiterstamm_WebView2([MA_ID])` auf
- `OpenKundenstammHTML([KD_ID])` → ruft `OpenKundenstamm_WebView2([KD_ID])` auf

### Button OnClick Einstellungen (in Access)

#### Für Stammdaten-Formulare (MIT ID-Parameter):
```vba
' Auftragstamm
=OpenAuftragstamm_WebView2([ID])

' Mitarbeiterstamm
=OpenMitarbeiterstamm_WebView2([ID])

' Kundenstamm
=OpenKundenstamm_WebView2([kun_Id])

' Objektverwaltung
=OpenObjekt_WebView2([ID])

' Dienstplan
=OpenDienstplan_WebView2([Datum])
```

#### Für Dashboard/Hauptmenü (OHNE Parameter):
```vba
' Hauptmenü öffnen
=OpenHTMLAnsicht()

' Alternative (Wrapper):
=HTMLAnsichtOeffnen()
```

#### Alte Funktionsnamen (funktionieren weiterhin):
```vba
' Diese funktionieren durch Wrapper-Funktionen:
=OpenAuftragsverwaltungHTML([ID])
=OpenMitarbeiterstammHTML([ID])
=OpenKundenstammHTML([kun_Id])
```

### WebView2 COM-Object (wenn vorhanden)
ProgId: `Consys.WebView2Host`
DLL: `ConsysWV2.dll` (muss registriert sein)
Methoden: Initialize(), Navigate(), PostWebMessage(), ExecuteScript(), Show(), Close()

### Letztes Update
- 13.01.2026: Wrapper-Funktionen für Abwärtskompatibilität hinzugefügt
- Alle alten Button-OnClick Aufrufe funktionieren jetzt wieder

## UMLAUTE (KRITISCH!)

### Pflicht-Regeln für UTF-8:
- Alle HTML-Dateien MÜSSEN UTF-8 Encoding haben
- IMMER `<meta charset="UTF-8">` im `<head>` als erstes Meta-Tag
- Umlaute ö, ä, ü, Ö, Ä, Ü, ß müssen ÜBERALL korrekt angezeigt werden
- Bei jedem neuen HTML-File: UTF-8 prüfen!
- KEINE ASCII-Ersetzungen (ue, ae, oe) in Anzeigetexten verwenden

### Prüfung bei Problemen:
1. **Meta-Tag vorhanden?** `<meta charset="UTF-8">`
2. **Datei-Encoding korrekt?** In VS Code unten rechts: muss "UTF-8" zeigen
3. **BOM vorhanden?** UTF-8 mit BOM ist ok, ohne BOM ist besser
4. **API-Response?** JSON muss `Content-Type: application/json; charset=utf-8` haben

### Korrigierte Dateien (2026-01-07):
- shell.html: Alle Anzeigetexte auf echte Umlaute umgestellt
- Button-Labels: Dienstplanübersicht, Planungsübersicht, Aufträge, Einsatzübersicht, Menü
- Tooltips: Aufträge, Einsätze, Menü-Optionen
