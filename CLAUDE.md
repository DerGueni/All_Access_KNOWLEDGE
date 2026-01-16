# Claude Code Project Rules

## 🛑 ABSOLUTES ÄNDERUNGSVERBOT FÜR GESCHÜTZTE FUNKTIONEN (HÖCHSTE PRIORITÄT!)

**BEVOR ich IRGENDETWAS ändere, MUSS ich prüfen:**

### PFLICHT-CHECK VOR JEDER ÄNDERUNG:
1. **SUCHEN:** Suche in CLAUDE.md nach "GESCHÜTZT" + Dateiname/Funktionsname
2. **PRÜFEN:** Ist die Funktion/Datei als "GESCHÜTZT" oder "EINGEFROREN" markiert?
3. **STOPPEN:** Falls JA → **KEINE ÄNDERUNG DURCHFÜHREN!**
4. **NUR MIT EXPLIZITER ANWEISUNG:** "Ändere die geschützte Funktion XY..." nötig

### WAS PASSIERT WENN ICH GESCHÜTZTES ÄNDERE:
- ❌ Produktionscode geht kaputt
- ❌ E-Mail-Versand funktioniert nicht mehr
- ❌ VBA Bridge Aufrufe schlagen fehl
- ❌ Benutzer verliert Vertrauen

### GESCHÜTZTE BEREICHE (NIEMALS OHNE EXPLIZITE ANWEISUNG):
- Alle Funktionen mit Kommentar `// GESCHÜTZT` im Code
- Alle Funktionen in Abschnitt "GESCHÜTZTE VBA BUTTON FUNKTIONEN"
- Alle Funktionen in Abschnitt "GESCHÜTZTE SUBFORM-OPTIK"
- Alle Dateien in Abschnitt "Geschützte Dateien"
- REST API Endpoints (Port 5000)
- VBA Bridge Endpoints (Port 5002)

### MEIN WORKFLOW BEI ÄNDERUNGSANFRAGEN:
```
1. Benutzer fragt nach Änderung
2. ICH SUCHE in CLAUDE.md nach "GESCHÜTZT" + betroffene Datei
3. Falls gefunden → STOPPEN und Benutzer informieren
4. Falls nicht gefunden → Änderung durchführen
```

⚠️ **DIESES VERBOT HAT HÖHERE PRIORITÄT ALS ALLE ANDEREN REGELN!** ⚠️

---

## 🛑 ACCESS-INSTANZEN SCHUTZ (KRITISCH!)

**NIEMALS auf andere Access-Instanzen zugreifen als die explizit erlaubten!**

### Erlaubte Datenbanken:
- **Frontend:** `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb`
- **Backend:** `\\vConSYS01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\0_Consec_V1_BE_V1.55_Test.accdb`

### VERBOTEN:
- ❌ Zugriff auf andere .accdb/.mdb Dateien
- ❌ Öffnen/Schließen anderer Access-Instanzen
- ❌ Änderungen an Produktions-Datenbanken
- ❌ Zugriff auf Datenbanken ohne `_Test` im Namen

### Bei anderen Access-Instanzen die laufen:
- **NICHT SCHLIESSEN** - Benutzer arbeitet möglicherweise darin
- **NICHT ANSPRECHEN** - Nur das Test-Frontend verwenden
- **IGNORIEREN** - Andere Instanzen sind tabu

⚠️ **VERSTOSS = DATENVERLUST MÖGLICH!** ⚠️

---

## 🛑 VBA-FUNKTIONEN SCHUTZ (KRITISCH!)

**NIEMALS VBA-Funktionen ändern, die bestehende Access-Funktionalität kaputt machen könnten!**

### VOR jeder VBA-Änderung prüfen:
1. Wird diese Funktion von Access-Formularen verwendet?
2. Wird diese Funktion von anderen VBA-Modulen aufgerufen?
3. Gibt es Abhängigkeiten zu bestehenden Workflows?

### VERBOTEN:
- ❌ Signatur (Parameter) bestehender Funktionen ändern
- ❌ Rückgabewerte bestehender Funktionen ändern
- ❌ Funktionen löschen die noch verwendet werden
- ❌ Funktionsnamen umbenennen ohne alle Aufrufer anzupassen

### ERLAUBT:
- ✅ NEUE Funktionen mit `_N_` Präfix hinzufügen
- ✅ Wrapper-Funktionen erstellen die Originale aufrufen
- ✅ Bestehende Funktionen erweitern OHNE Breaking Changes
- ✅ Bug-Fixes die das Original-Verhalten wiederherstellen

### Bei Unsicherheit:
- **STOPPEN** und Benutzer fragen
- **NIEMALS** "auf Verdacht" ändern
- **DOKUMENTIEREN** was geändert werden soll, BEVOR es geändert wird

⚠️ **VERSTOSS = ACCESS-FORMULARE FUNKTIONIEREN NICHT MEHR!** ⚠️

---

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

## 🔴 GOLDENE REGEL: ACCESS-PARITÄT (KRITISCH!)

**JEDES Feld und JEDES Control in HTML-Formularen MUSS die GLEICHEN Eigenschaften und Funktionen haben wie das Access-Original!**

### Was das bedeutet:
- **Events:** Click, DblClick, AfterUpdate, BeforeUpdate → ALLE implementieren
- **Filter:** Exakt gleiche Filter-Logik wie in Access
- **Validierung:** Gleiche Prüfungen und Fehlermeldungen
- **Verhalten:** Identisches Verhalten bei Benutzerinteraktion
- **Daten:** Gleiche Datenquellen und Feldnamen

### Ausnahmen NUR wenn:
- Benutzer hat **explizit** etwas anderes angewiesen
- Es ist in CLAUDE.md als Ausnahme dokumentiert

### Bei Unklarheit:
1. Access-VBA-Code in `exports/vba/forms/` prüfen
2. Original-Events und Funktionen analysieren
3. 1:1 in JavaScript/HTML nachbilden

### Beispiel:
```
Access: List_MA_DblClick → btnAddSelected_Click → MA zur Planung
HTML:   List_MA_DblClick → btnAddSelected_Click → addMAToPlanung()
→ MUSS identisch funktionieren!
```

⚠️ **DIESE REGEL HAT HÖCHSTE PRIORITÄT!** ⚠️

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
- **Startet mit:** `start_vba_bridge.bat` ODER automatisch bei "HTML Ansicht" Button
- **WICHTIG:** Access MUSS geöffnet sein mit 0_Consys_FE_Test.accdb!
- **Zweck:** Ermöglicht HTML-Formularen den Aufruf von VBA-Funktionen in Access

**AUTO-START (16.01.2026):**
- VBA Bridge wird AUTOMATISCH gestartet beim Klick auf "HTML Ansicht" Button
- Implementiert in: `mod_N_WebView2_forms3.bas` → `StartVBABridgeServerIfNeeded()`
- Startet minimiert im Hintergrund (kein Fenster-Fokus)
- Prüft vorher ob Server bereits läuft (verhindert Duplikate)

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

### Multi-Agent Arbeit (PFLICHT):
- **IMMER** mehrere Sub-Agents parallel starten für komplexe Aufgaben
- Aufgaben aufteilen in: Analyse, Implementierung, Dokumentation
- Parallele Agents sparen Token und Zeit
- Mindestens 2-3 Agents bei jeder nicht-trivialen Aufgabe

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

## GESCHÜTZT: Auftragstamm E-Mail/Export Buttons (KRITISCH!)

**Letzte Änderung: 15.01.2026 - FUNKTIONIERT - NIEMALS ÄNDERN!**

Die folgenden Buttons im Auftragstamm-Formular rufen VBA-Funktionen via VBA Bridge Server (Port 5002) auf.

### Geschützte Buttons und ihre VBA-Funktionen:

**1. "Namensliste ESS" (btn_ListeStd):**
- HTML-Handler: `frm_va_Auftragstamm.html` → `onclick="btn_ListeStd_Click()"`
- VBA-Wrapper: `mod_N_HTML_Buttons.HTML_btn_ListeStd_Click(VA_ID, Veranstalter_ID)`
- Original: `zmd_Listen.Stundenliste_erstellen(VA_ID, , Veranstalter_ID)`
- Funktion: Erstellt ESS Namensliste/Stundenliste

**2. "EL drucken" (btnDruckZusage):**
- HTML-Handler: `frm_va_Auftragstamm.html` → `onclick="einsatzlisteDrucken()"`
- JS-Funktion: `einsatzlisteDrucken()` → `callVBAFunction('HTML_btnDruckZusage_Click', VA_ID, Auftrag, Objekt, Dat_VA_Von)`
- VBA-Wrapper: `mod_N_HTML_Buttons.HTML_btnDruckZusage_Click(VA_ID, Auftrag, Objekt, Dat_VA_Von)`
- Original: `fXL_Export_Auftrag(VA_ID, strPfad, strDatei)` + Status auf "Beendet"
- Funktion: Excel-Export der Einsatzliste + setzt Veranst_Status_ID = 2

**3. "EL senden MA" (btnMailEins):**
- HTML-Handler: `frm_va_Auftragstamm.html` → `onclick="sendeEinsatzlisteMA()"`
- JS-Funktion: `sendeEinsatzlisteMA()` → `callVBAFunction('HTML_btnMailEins_Click', VA_ID, VADatum_ID)`
- VBA-Wrapper: `mod_N_HTML_Buttons.HTML_btnMailEins_Click(VA_ID, VADatum_ID)`
- Original: `Form_frm_MA_Serien_eMail_Auftrag.Autosend(2, VA_ID, VADatum_ID)`
- Funktion: Sendet Einsatzliste per E-Mail an alle zugeordneten Mitarbeiter

**4. "EL senden BOS" (btnMailBOS) - 16.01.2026 korrigiert:**
- HTML-Handler: `frm_va_Auftragstamm.html` → `onclick="sendeEinsatzlisteBOS()"`
- JS-Funktion: `sendeEinsatzlisteBOS()` → `callVBAFunction('HTML_btn_Autosend_BOS_Click', VA_ID, VADatum_ID, Veranstalter_ID)`
- VBA-Wrapper: `mod_N_HTML_Buttons.HTML_btn_Autosend_BOS_Click(VA_ID, VADatum_ID, Veranstalter_ID)`
- NUR aktiv für Veranstalter_ID: 10720, 20770, 20771

**5. "EL senden SUB" (btnMailSub) - 16.01.2026 korrigiert:**
- HTML-Handler: `frm_va_Auftragstamm.html` → `onclick="sendeEinsatzlisteSUB()"`
- JS-Funktion: `sendeEinsatzlisteSUB()` → `callVBAFunction('HTML_btnMailSub_Click', VA_ID, VADatum_ID)`
- VBA-Wrapper: `mod_N_HTML_Buttons.HTML_btnMailSub_Click(VA_ID, VADatum_ID)`

### Geschützte Dateien:

**1. `01_VBA\modules\mod_N_HTML_Buttons.bas`:**
- Enthält alle VBA-Wrapper-Funktionen für HTML-Button-Aufrufe
- NIEMALS umbenennen oder duplizieren (führt zu "mehrdeutiger Name" Fehler)

**2. `04_HTML_Forms\api\vba_bridge_server.py`:**
- Endpoint: `POST /api/vba/execute` mit `{"function": "HTML_...", "args": [...]}`
- NIEMALS die Signatur der execute-Route ändern

**3. `04_HTML_Forms\forms3\frm_va_Auftragstamm.html`:**
- onclick-Handler für die Buttons (ca. Zeile 3665-3780)
- NIEMALS die Button-IDs oder onclick-Handler ändern

**4. `04_HTML_Forms\forms3\logic\frm_va_Auftragstamm.logic.js`:**
- Funktionen: `btn_ListeStd_Click()`, `btnDruckZusage_Click()`, `btnMailEins_Click()` (ca. Zeile 1230-1320)
- NIEMALS die VBA Bridge Aufrufe ändern

### WARUM GESCHÜTZT:
- Diese Buttons triggern echte Access/Outlook E-Mail-Versendung
- VBA Bridge Server muss laufen (Port 5002)
- Access muss mit 0_Consys_FE_Test.accdb geöffnet sein
- Getestet mit Playwright am 15.01.2026

### NIEMALS ÄNDERN:
- VBA-Funktionsnamen in `mod_N_HTML_Buttons.bas`
- onclick-Handler in `frm_va_Auftragstamm.html`
- VBA Bridge Endpoints in `vba_bridge_server.py`
- Die Reihenfolge der Parameter in den VBA-Aufrufen

⚠️ **DIESE FUNKTIONALITÄT WURDE AM 15.01.2026 GETESTET UND VOM BENUTZER BESTÄTIGT!** ⚠️
⚠️ **BEI ÄNDERUNGSWUNSCH: EXPLIZITE GENEHMIGUNG DES BENUTZERS ERFORDERLICH!** ⚠️

---

## GESCHÜTZT: Auftragstamm CRUD-Buttons (KRITISCH!)

**Letzte Änderung: 16.01.2026 - JETZT MIT VBA BRIDGE - NIEMALS ÄNDERN!**

Die folgenden Buttons im Auftragstamm-Formular nutzen VBA Bridge (Port 5002) für volle Access-Parität.

### Geschützte Buttons:

**1. "Neuer Auftrag" (cmdNeuerAuftrag):**
- HTML-Handler: `frm_va_Auftragstamm.html` → `onclick="createNewAuftrag()"`
- API-Endpoint: `POST /api/auftraege`
- Funktion: Erstellt einen neuen leeren Auftrag in der Datenbank

**2. "Positionen" (cmdPositionen):**
- HTML-Handler: `frm_va_Auftragstamm.html` → `onclick="openPositionen()"`
- Funktion: Öffnet das Positionen-Subformular für den aktuellen Auftrag
- Navigation via Shell postMessage

**3. "Auftrag kopieren" (cmdAuftragKopieren) - VBA BRIDGE:**
- JS-Funktion: `frm_va_Auftragstamm.logic.js` → `kopierenAuftrag()`
- VBA Bridge: `POST /api/vba/execute` → `HTML_AuftragKopieren(VA_ID, NeuesStartdatum)`
- VBA-Wrapper: `mod_N_HTML_Buttons.HTML_AuftragKopieren(VA_ID, NeuesStartdatum)`
- Funktion: Kopiert Auftrag mit ALLEN Tabellen (tbl_VA_Auftragstamm, tbl_VA_Start, tbl_VA_AnzTage)
- Fragt Startdatum via prompt() ab (wie Access InputBox)
- Rückgabe: `"OK:12345"` mit neuer VA_ID

**4. "Auftrag löschen" (cmdAuftragLoeschen) - VBA BRIDGE:**
- JS-Funktion: `frm_va_Auftragstamm.logic.js` → `loeschenAuftrag()`
- VBA Bridge: `POST /api/vba/execute` → `HTML_AuftragLoeschen(VA_ID)`
- VBA-Wrapper: `mod_N_HTML_Buttons.HTML_AuftragLoeschen(VA_ID)`
- Funktion: **ECHTES DELETE** (kein Soft-Delete!) - exakt wie in Access!
- Rückgabe: `"OK - Auftrag geloescht"`

### Geschützte VBA-Wrapper in mod_N_HTML_Buttons.bas:

**`HTML_AuftragKopieren(VA_ID, NeuesStartdatum)` - Zeile 298-559:**
- Kopiert tbl_VA_Auftragstamm, tbl_VA_Start, tbl_VA_AnzTage
- Setzt neues Startdatum und berechnet Enddatum
- Aktualisiert VADatum_ID Verknüpfungen
- Prüft auf "Dauerläufer" (Aufträge mit Lücken)

**`HTML_AuftragLoeschen(VA_ID)` - Zeile 567-588:**
- ECHTES DELETE mit `CurrentDb.Execute "DELETE FROM tbl_VA_Auftragstamm WHERE ID = ..."`
- KEIN Soft-Delete mehr!

### WARUM VBA BRIDGE:
- Volle Access-Parität bei komplexen Operationen
- Kopieren erfordert Datums-Berechnungen und Multi-Tabellen-Operationen
- Löschen muss ECHT sein (nicht nur Status ändern)

### NIEMALS ÄNDERN:
- `kopierenAuftrag()` MUSS VBA Bridge mit `HTML_AuftragKopieren` verwenden
- `loeschenAuftrag()` MUSS VBA Bridge mit `HTML_AuftragLoeschen` verwenden
- Die VBA-Wrapper in `mod_N_HTML_Buttons.bas` NICHT ändern
- Startdatum-Abfrage via prompt() NICHT entfernen

⚠️ **DIESE FUNKTIONALITÄT WURDE AM 16.01.2026 AUF VBA BRIDGE UMGESTELLT!** ⚠️
⚠️ **BEI ÄNDERUNGSWUNSCH: EXPLIZITE GENEHMIGUNG DES BENUTZERS ERFORDERLICH!** ⚠️

---

## GESCHÜTZT: btn_BWN_Druck (BWN drucken) - VBA BRIDGE

**Letzte Änderung: 16.01.2026 - KORRIGIERT - NIEMALS ÄNDERN!**

Der Button "BWN drucken" (`btn_BWN_Druck`) im Auftragstamm-Formular nutzt VBA Bridge (Port 5002).

### Geschützte Code-Stellen:

**1. `frm_va_Auftragstamm.html` - bwnDrucken() (ca. Zeile 3874-3907):**
- onclick-Handler: `onclick="bwnDrucken()"`
- VBA Bridge: `POST http://localhost:5002/api/vba/execute`
- Funktion: `HTML_btn_BWN_Druck_Click`
- Parameter: `[state.currentAuftragId, veranstalterId]`

**2. `frm_va_Auftragstamm.logic.js` - Zeile 148-150:**
```javascript
// ENTFERNT: bindButton ueberschrieb korrekten HTML onclick Handler (VBA Bridge)
// HTML hat bereits onclick="bwnDrucken()" der VBA Bridge korrekt aufruft
// bindButton('btn_BWN_Druck', druckeBWN);
```
- Diese Zeile MUSS auskommentiert bleiben!
- Die logic.js Version `druckeBWN()` nutzt falschen Endpoint
- Der HTML onclick Handler `bwnDrucken()` ist korrekt

**3. `mod_N_HTML_Buttons.bas` - HTML_btn_BWN_Druck_Click (Zeile 226-238):**
- VBA-Wrapper für BWN Druck
- HINWEIS: Im Original Access ist diese Funktion deaktiviert

### WARUM KORRIGIERT:
- Die `bindButton()` Zeile in logic.js überschrieb den korrekten HTML onclick Handler
- Der falsche Handler rief `Bridge.execute('druckeBWN', ...)` auf (HTTP 405)
- Der korrekte Handler ruft VBA Bridge auf Port 5002 auf

### NIEMALS ÄNDERN:
- `bindButton('btn_BWN_Druck', druckeBWN)` MUSS auskommentiert bleiben
- `bwnDrucken()` in HTML ist der EINZIGE Handler für diesen Button
- onclick-Attribut im HTML NICHT entfernen

⚠️ **DIESE KORREKTUR WURDE AM 16.01.2026 DURCHGEFÜHRT!** ⚠️
⚠️ **BEI ÄNDERUNGSWUNSCH: EXPLIZITE GENEHMIGUNG DES BENUTZERS ERFORDERLICH!** ⚠️

---

## GESCHÜTZT: cmd_BWN_send (BWN senden) - VBA BRIDGE

**Letzte Änderung: 16.01.2026 - KORRIGIERT - NIEMALS ÄNDERN!**

Der Button "BWN senden" (`cmd_BWN_send`) im Auftragstamm-Formular nutzt VBA Bridge (Port 5002).

### Geschützte Code-Stellen:

**1. `frm_va_Auftragstamm.html` - bwnSenden() (ca. Zeile 3909-3940):**
- onclick-Handler: `onclick="bwnSenden()"`
- VBA Bridge: `POST http://localhost:5002/api/vba/execute`
- Funktion: `HTML_cmd_BWN_send_Click`
- Parameter: `[state.currentAuftragId, veranstalterId]`

**2. `frm_va_Auftragstamm.logic.js` - Zeile 147-149:**
```javascript
// ENTFERNT: bindButton ueberschrieb korrekten HTML onclick Handler (VBA Bridge)
// HTML hat bereits onclick="bwnSenden()" der VBA Bridge korrekt aufruft
// bindButton('cmd_BWN_send', cmdBWNSend);
```
- Diese Zeile MUSS auskommentiert bleiben!
- Die logic.js Version `cmdBWNSend()` nutzt falschen Endpoint (`Bridge.execute('sendBWN')`)
- Der HTML onclick Handler `bwnSenden()` ist korrekt

**3. `frm_va_Auftragstamm.logic.js` - Zeile 2189-2192 + 2436-2439:**
```javascript
// BWN-Varianten - ENTFERNT: Diese ueberschrieben die korrekten HTML onclick Handler
// window.bwnDrucken = ... // AUSKOMMENTIERT
// window.bwnSenden = ...  // AUSKOMMENTIERT
// function bwnDrucken() { ... } // AUSKOMMENTIERT
// function bwnSenden() { ... }  // AUSKOMMENTIERT
```
- Diese Zeilen MÜSSEN auskommentiert bleiben!
- Sie überschrieben die korrekten HTML-Funktionen mit falschen Versionen

### WARUM KORRIGIERT:
- `bindButton()` in logic.js überschrieb den korrekten HTML onclick Handler
- `window.bwnSenden = cmdBWNSend` überschrieb die globale Funktion
- `function bwnSenden() { return cmdBWNSend(); }` leitete an falsche Funktion weiter
- Der falsche Handler rief `Bridge.execute('sendBWN', ...)` auf (falscher Endpoint)
- Der korrekte Handler ruft VBA Bridge auf Port 5002 auf

### NIEMALS ÄNDERN:
- `bindButton('cmd_BWN_send', cmdBWNSend)` MUSS auskommentiert bleiben
- `window.bwnSenden = ...` MUSS auskommentiert bleiben
- `function bwnSenden() { ... }` in logic.js MUSS auskommentiert bleiben
- `bwnSenden()` in HTML ist der EINZIGE Handler für diesen Button
- onclick-Attribut im HTML NICHT entfernen

⚠️ **DIESE KORREKTUR WURDE AM 16.01.2026 DURCHGEFÜHRT!** ⚠️
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
