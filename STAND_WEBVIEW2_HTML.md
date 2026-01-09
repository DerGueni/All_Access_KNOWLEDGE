# STAND DER ARBEIT - WebView2 HTML Formulare

**Letztes Update:** 2026-01-09 23:30
**Session:** Veranstalter-Regeln Test + Bugfixes

---

## AKTUELLER STAND

### Veranstalter-Regeln (2026-01-09) - ABGESCHLOSSEN

**Aufgabe:** Veranstalter-Regeln für ID 20760 und 20750 testen.

**Gefundene und behobene Bugs:**

| Bug | Ursache | Fix |
|-----|---------|-----|
| getElementById Case-Sensitivity | `veranstalter_id` statt `Veranstalter_ID` | Zeile 179: `getElementById('Veranstalter_ID')` |
| setFieldValue Case-Sensitivity | Gleiches Problem | Zeile 615: `setFieldValue('Veranstalter_ID', ...)` |

**Test-Ergebnisse:**

| Veranstalter_ID | BWN Buttons | RE Spalte | PKW/EL Spalten |
|-----------------|-------------|-----------|----------------|
| 20760 (isMesse) | ✅ SICHTBAR | ✅ SICHTBAR | ✅ SICHTBAR |
| 10233 (normal) | ✅ VERSTECKT | ✅ VERSTECKT | ✅ SICHTBAR |
| 20750 (isSpecialClient) | ✅ VERSTECKT | ✅ VERSTECKT | ✅ VERSTECKT |

**Geänderte Datei:**
- `logic/frm_va_Auftragstamm.logic.js` - Zeilen 179, 615, 1343

---

### DblClick-Events und Bedingte Formatierung (2026-01-09) - ABGESCHLOSSEN

**Aufgabe:** Fehlende DblClick-Events und bedingte Formatierung aus Access implementieren.

**Implementierte DblClick-Events:**

| Event | Formular | Funktion |
|-------|----------|----------|
| `lst_Zuo_DblClick` | Mitarbeiterstamm | Öffnet Auftragstamm für VA_ID |
| `cboVADatum_DblClick` | Auftragstamm | Öffnet Einsatztage-Popup |
| `Auftraege_ab_DblClick` | Auftragstamm | Öffnet Auftragsliste |
| `cboAnstArt_DblClick` | Auftragstamm | Öffnet Anstellungsarten |
| `lbl_Tag_*_DblClick` | DP Dienstplan MA | Springt zur Tagesübersicht |

**Implementierte Bedingte Formatierung:**

| Bedingung | Formatierung | CSS |
|-----------|--------------|-----|
| IstFraglich = True | Türkisblaue Hintergrundfarbe | `#C0FFFF` |
| MA inaktiv | Rote Schrift | `#cc0000` |
| Unterbuchung (leere Slots) | Gelbe Hintergrundfarbe | `#FFFFCC` |
| Überbuchung (mehr MA als erlaubt) | Rote Hintergrundfarbe | `#FFCCCC` |

**Browser-Test Ergebnisse:**

| Feature | Status | Beweis |
|---------|--------|--------|
| DblClick Auftragsliste | ✅ Verifiziert | Gardetreffen geladen (VA_ID 9365) |
| cboVADatum DblClick | ✅ Verifiziert | Einsatztage-Popup geöffnet |
| Unterbuchung (gelb) | ✅ Verifiziert | Leere Zeilen mit gelbem Hintergrund |
| MA inaktiv (rot) | ✅ Verifiziert | Rote Schrift bei inaktiven MA |

**Geänderte Dateien:**

| Datei | Änderung |
|-------|----------|
| `logic/frm_MA_Mitarbeiterstamm.logic.js` | lst_Zuo_DblClick, MA inaktiv Formatierung |
| `logic/frm_va_Auftragstamm.logic.js` | cboVADatum_DblClick, Auftraege_ab_DblClick |
| `logic/frm_DP_Dienstplan_MA.logic.js` | lbl_Tag_*_DblClick |
| `logic/sub_MA_VA_Zuordnung.logic.js` | IstFraglich CSS-Klasse |
| `css/app-layout.css` | CSS für alle bedingten Formatierungen |
| `frm_va_Auftragstamm.html` | Inline CSS für Unterbuchung/Überbuchung |

**Code-Referenzen:**
- `frm_MA_Mitarbeiterstamm.logic.js:340-347` - MA inaktiv Formatierung
- `frm_va_Auftragstamm.html` - renderZuordnungen() mit Unterbuchung-Klassen
- `sub_MA_VA_Zuordnung.logic.js` - getRowClass() mit IstFraglich

---

### API-Server Stabilität (2026-01-09) - IN ARBEIT

**Problem:** Der API-Server crashte bei parallelen Requests mit:
1. `isinstance() arg 2 must be a type` - Python TypeError
2. `Segmentation fault` - Access ODBC-Treiber Crash

**Behobene Fehler:**

| Problem | Ursache | Lösung |
|---------|---------|--------|
| isinstance-Fehler | `import time` überschrieb `datetime.time` | `import time as _time_module` + `datetime_time` |
| Parallele Requests | ODBC-Treiber nicht thread-safe | Request-Lock + 100ms Mindestabstand |

**Geänderte Dateien:**
- `Access Bridge/api_server.py`:
  - Zeile 12: `from datetime import time as datetime_time`
  - Zeile 54-80: Globaler Request-Lock mit Serialisierung
  - Zeile 217-221: Query-Lock mit 100ms Mindestabstand
  - Zeile 311-356: serialize_value() mit expliziten Try-Except
  - Zeile 4200: Entfernt doppelten `import time`

**Bekannte Limitierung:**
- Access ODBC-Treiber crasht mit Segfault bei sustained load
- Dies ist eine fundamentale Limitierung des Treibers

**Workaround: Auto-Restart Script**
```powershell
# Server mit Auto-Restart starten:
powershell -ExecutionPolicy Bypass -File "C:\Users\guenther.siegert\Documents\Access Bridge\auto_restart_server.ps1"
```
Startet den Server bei Crash automatisch neu (2 Sekunden Wartezeit).

**Test-Ergebnisse:**
| Funktion | Status |
|----------|--------|
| Einzelne API-Requests | ✅ |
| 10 sequentielle Requests | ✅ |
| Schnellauswahl öffnen (parallele Requests) | ⚠️ Crasht nach ~10-15 Requests |
| Formular-Grunddaten laden | ✅ (100 Aufträge, 123 MA) |

### Browser-Test Mitarbeiterauswahl Button (2026-01-09) - ERFOLGREICH

**Test-Ablauf:**
1. Navigiert zu `shell.html?form=frm_va_Auftragstamm`
2. Auftrag "Consec Feier" mit Datum 19.12.2026 geladen
3. Klick auf "Mitarbeiterauswahl" Button

**Ergebnis:**
| Schritt | Status | Details |
|---------|--------|---------|
| Button-Klick | ✅ | `f2e82` (Mitarbeiterauswahl) reagiert korrekt |
| Form-Navigation | ✅ | Neuer Tab öffnet sich mit Schnellauswahl |
| URL-Parameter | ✅ | `va_id=9314` korrekt übergeben |
| Datum Auto-Select | ✅ | `19.12.2026` automatisch ausgewählt |

**API-Fehler während Test:**
| Endpoint | Status | Ursache |
|----------|--------|---------|
| `/api/schichten?va_id=null` | 500 | Null-Wert nicht behandelt |
| `/api/planung?vadatum_id=undefined` | 404 | Endpoint fehlt/Parameter falsch |

**Fazit:** Die URL-Parameter-Korrektur (`state.currentVADatumId` statt `state.currentVADatum`) funktioniert.
Die Button-Navigation ist erfolgreich. API-Endpoints brauchen bessere Null-Behandlung.

---

### Schnellauswahl Access-Abgleich (2026-01-09) - ABGESCHLOSSEN

**Aufgabe:** HTML-Formular `frm_MA_VA_Schnellauswahl.html` mit Access-Original abgleichen.

**Korrigierte Elemente:**

| Element | Problem | Lösung |
|---------|---------|--------|
| btnPosListe | Sichtbar in HTML, Visible=Falsch in Access | `display: none` hinzugefügt |
| btnZuAbsage | Sichtbar in HTML, Visible=Falsch in Access | `display: none` hinzugefügt |
| cboAuftrStatus | Sichtbar in HTML, Visible=Falsch in Access | `display: none` hinzugefügt |
| strSchnellSuche | Sichtbar in HTML, Visible=Falsch in Access | `display: none` hinzugefügt |
| btnSchnellGo | Sichtbar in HTML, Visible=Falsch in Access | `display: none` hinzugefügt |
| btnDelAll | Sichtbar in HTML, Visible=Falsch in Access | `display: none` hinzugefügt |
| btnAddZusage/btnMoveZusage/btnDelZusage | Sichtbar, aber alle Visible=Falsch | Button-Column ausgeblendet |
| btnSortPLan | Sichtbar in HTML, Visible=Falsch in Access | `display: none` hinzugefügt |
| btnSortZugeord | Sichtbar in HTML, Visible=Falsch in Access | `display: none` hinzugefügt |
| lbAuftrag | Sichtbar in HTML, Visible=Falsch in Access | `display: none` hinzugefügt |
| lbl_Datum | FEHLTE in HTML | Hinzugefügt mit Datumsformatierung |
| cboAnstArt | Default=5 (Aushilfe) | Default=13 (Alle aktiven), Optionen 3,5,9,11,13 |

**URL-Parameter Fix:**

| Datei | Problem | Lösung |
|-------|---------|--------|
| frm_va_Auftragstamm.html | `state.currentVADatum` existierte nicht | Korrigiert zu `state.currentVADatumId` |
| frm_va_Auftragstamm.html | Parameter `vadatum` | Korrigiert zu `vadatum_id` |

**Geänderte Dateien:**
- `frm_MA_VA_Schnellauswahl.html` - Sichtbarkeit, lbl_Datum, cboAnstArt
- `frm_va_Auftragstamm.html` - openMitarbeiterauswahl() URL-Parameter

---

### Schnellauswahl Auto-Load (2026-01-09) - ABGESCHLOSSEN

**Aufgabe:** Wenn im Auftragstamm auf "Mitarbeiterauswahl" geklickt wird, soll das Formular `frm_MA_VA_Schnellauswahl.html` öffnen und sofort den entsprechenden Auftrag laden.

**Implementiert (3 Parallel-Agents):**

| Agent | Aufgabe | Status |
|-------|---------|--------|
| Agent 1 | HTML: Async Form_Open/Form_Load, REST API Calls | ✅ |
| Agent 2 | Logic.js: URL-Parameter, loadAuftragById() | ✅ |
| Agent 3 | API-Endpoints verifiziert | ✅ |

**Geänderte Dateien:**
- `04_HTML_Forms/forms3/frm_MA_VA_Schnellauswahl.html` - Async Lade-Funktionen
- `04_HTML_Forms/forms3/logic/frm_MA_VA_Schnellauswahl.logic.js` - URL-Parameter Handling
- `Access Bridge/api_server.py` - Route-Alias `/api/auftraege/{id}/einsatztage`

**URL-Aufruf:**
```
http://localhost:8081/frm_MA_VA_Schnellauswahl.html?va_id=9314
```

**Testergebnis:**
| Funktion | Status |
|----------|--------|
| 100 Aufträge im Dropdown | ✅ |
| Datum auto-selektiert | ✅ (Sa., 19.12.2026) |
| 123 Mitarbeiter geladen | ✅ (alphabetisch) |
| Anstellung "Aushilfe" | ✅ |
| Gesamt-Anzeige | ✅ (123) |

---

### Abgeschlossene Aufgaben vorherige Session:

1. **Auto-Load des ersten Auftrags implementiert:**
   - Beim Oeffnen des Formulars wird automatisch der aktuellste Auftrag geladen
   - VA_ID-Fix: `state.auftraege[0].VA_ID` statt `.ID`
   - Formular-Felder werden automatisch befuellt

2. **SQL Data Type Mismatch behoben:**
   - Endpoint `/api/auftraege/{id}/schichten?vadatum_id=X`
   - Problem: Access ODBC mag keine datetime-Vergleiche aus zwei Queries
   - Loesung: JOIN statt zwei separate Queries

3. **Static File Serving hinzugefuegt:**
   - API-Server serviert jetzt HTML-Dateien unter `/forms3/`
   - URL: `http://127.0.0.1:5000/forms3/frm_va_Auftragstamm.html`
   - Behebt CORS-Probleme bei file:// URLs

4. **Vorherige Session (CORS + Endpoints):**
   - 5 neue Endpoints fuer Subformulare
   - SQL-Fixes fuer zuordnungen/absagen/kunden
   - Waitress Production Server

---

## GEAENDERTE DATEIEN

| Datei | Aenderung |
|-------|-----------|
| `04_HTML_Forms/api/api_server.py` | Static File Serving, schichten JOIN-Fix |
| `04_HTML_Forms/forms3/frm_va_Auftragstamm.html` | VA_ID Fix fuer Auto-Load |

---

## NEUE FEATURES

### Static File Serving
```
http://127.0.0.1:5000/forms3/frm_va_Auftragstamm.html
http://127.0.0.1:5000/forms3/shell.html?form=frm_va_Auftragstamm
```

### Auto-Load
- Beim Oeffnen: Erster Auftrag aus Liste wird automatisch geladen
- Alle Formular-Felder werden befuellt
- Subformulare (Schichten, Zuordnungen, Absagen) werden geladen

---

## TEST-ERGEBNISSE

| Funktion | Status |
|----------|--------|
| Auto-Load erster Auftrag | OK |
| Formular-Felder befuellt | OK |
| Schichten-Subform | OK |
| Zuordnungen-Subform | OK |
| Absagen-Subform | OK |
| VA-Datum Dropdown | OK |
| Static File Serving | OK |
| Row-Click -> Auftrag laden | OK |
| Mitarbeiterstamm Row-Click | OK (2026-01-09) |
| Mitarbeiterstamm Auto-Load | OK (2026-01-09) |
| Kundenstamm Row-Click | OK (2026-01-09) |
| Kundenstamm Auto-Load | OK (2026-01-09) |
| Objekt Row-Click | OK (2026-01-09) |
| Objekt Positionen laden | OK (2026-01-09) |
| **Auftragsliste ASC ab heute** | OK (2026-01-09) |
| **Nächster Auftrag auto-load** | OK (2026-01-09) |
| **Combo-Laden (Datalist-Fix)** | OK (2026-01-09) |
| **Einsatzliste Spaltenbreiten** | OK (2026-01-09) |
| **Schnellauswahl Auto-Load** | OK (2026-01-09) |
| **Schnellauswahl URL-Parameter** | OK (2026-01-09) |
| **DblClick Auftragsliste** | OK (2026-01-09) |
| **cboVADatum DblClick → Einsatztage** | OK (2026-01-09) |
| **Unterbuchung (gelb)** | OK (2026-01-09) |
| **MA inaktiv (rote Schrift)** | OK (2026-01-09) |
| **IstFraglich (türkisblau)** | IMPL (2026-01-09) |
| **Überbuchung (rot)** | IMPL (2026-01-09) |

---

## EINSATZLISTE FIX (2026-01-09)

**Problem:** Inkonsistente Spaltenbreiten zwischen Aufträgen mit/ohne zugewiesenen Mitarbeitern
- Consec Feier (115 MA): Zeilen mit Checkboxen in ?, PKW €, EL, RE
- Gardetreffen (0 MA): Leere Zeilen hatten andere Feldgrößen

**Lösung:**
| Datei | Änderung |
|-------|----------|
| `frm_va_Auftragstamm.html` | `table-layout: fixed;` zu gridZuordnungen hinzugefügt |
| `frm_va_Auftragstamm.logic.js` | `fillCombo()` für Datalist-Inputs erweitert |

**Ergebnis:**
- Spaltenbreiten werden vom Header definiert (unabhängig vom Inhalt)
- Normale Zeilenhöhe bei leeren Zeilen (keine disabled inputs nötig)
- Konsistente Darstellung für alle Aufträge

---

## API-FIXES (2026-01-09)

| Endpoint | Problem | Lösung |
|----------|---------|--------|
| `/api/objekte/{id}/positionen` | Falsche Tabelle/Spalte | `tbl_OB_Objekt_Positionen.OB_Objekt_Kopf_ID` |
| `/api/objekte/{id}/auftraege` | Fehlte komplett | Neuer Endpoint hinzugefügt |
| `/api/auftraege` (GET) | Sortierung falsch | ASC wenn datum_ab gesetzt |

---

## AUFTRAGSLISTE SORTIERUNG (2026-01-09)

**Anforderung:** Liste aufsteigend ab aktuellem Datum, nächster Auftrag zuerst

**Änderungen:**
| Datei | Änderung |
|-------|----------|
| `api_server.py` | Sortierung ASC wenn `ab`-Parameter gesetzt |
| `frm_va_Auftragstamm.html` | `sortDir: 'asc'`, Filter auf heutiges Datum |

**Ergebnis:**
- Filter "Aufträge ab" wird automatisch auf heute gesetzt
- Liste zeigt: Consec Feier (10.01) → Gardetreffen (11.01) → Wintergrillen (14.01)...
- Erster Auftrag (Consec Feier) wird automatisch mit Details geladen

---

## WICHTIGE PFADE

- **HTML-Formulare:** `04_HTML_Forms/forms3/`
- **API-Server:** `04_HTML_Forms/api/api_server.py`
- **Logic-Datei:** `04_HTML_Forms/forms3/logic/frm_va_Auftragstamm.logic.js`
- **Bridge:** `04_HTML_Forms/forms3/js/webview2-bridge.js`

---

## UI-OPTIMIERUNGEN (2026-01-09)

### 5 Parallel-Agents durchgeführt:

| Agent | Aufgabe | Status |
|-------|---------|--------|
| Agent 1 | Einsatzliste: Konstante Zeilenhöhe, kleinere Checkboxen, schmalere Spalten | ✅ |
| Agent 2 | Auftragsliste rechts: Fette Schrift, Ort-Spalte, Spaltenbreiten | ✅ |
| Agent 3 | Sidebar 182px, fette Schrift, Eingabefelder +50px | ✅ |
| Agent 4 | Header Auftragstamm: Titel +8px, title-bar ausgeblendet | ✅ |
| Agent 5 | Header in allen Formularen: +8px Schriftgröße | ✅ |

### Geänderte Dateien:
- `frm_va_Auftragstamm.html` - CSS, HTML, JavaScript
- `frm_va_Auftragstamm.logic.js` - applyGridZuordnungenColumnRules
- `shell.html` - Sidebar-Breite
- `css/app-layout.css` - Media Queries
- 20+ frm_*.html Formulare - Header-Anpassungen

### Bedingte Sichtbarkeit:
- BWN Buttons: Nur bei Veranstalter_ID = 20760
- EL/PKW Spalten: Ausgeblendet bei Veranstalter_ID = 20750
- RE Spalte: Nur bei Veranstalter_ID = 20760

### Umlaut-Fix:
- 47 kaputte Umlaute (�) in frm_va_Auftragstamm.html repariert
- JavaScript-Funktionen: ASCII-Ersatz (ae, oe, ue)
- Anzeigetexte: Echte UTF-8 Umlaute

---

## STABILITAET UND FREEZE (2026-01-09)

### 3 Parallel-Agents fuer Stabilitaetsregeln:

| Agent | Aufgabe | Status |
|-------|---------|--------|
| Agent 1 | Auftragstamm: loadLatestAuftrag() implementiert | ✅ |
| Agent 2 | Mitarbeiterstamm: Filter Anstellungsart_ID IN (3,5) | ✅ |
| Agent 3 | FROZEN_FEATURES.md erstellt | ✅ |

### Neue/Geaenderte Dateien:
- `logic/frm_va_Auftragstamm.logic.js` - loadLatestAuftrag() Funktion
- `Access Bridge/api_server.py` - Anstellungsart-Filter mit Default (3,5)
- `logic/frm_MA_Mitarbeiterstamm.logic.js` - Alphabetische Sortierung, Filter-Logik
- `frm_MA_Mitarbeiterstamm.html` - Neues Filter-Dropdown
- `FROZEN_FEATURES.md` - Dokumentation aller eingefrorenen Features

### Mitarbeiterstamm Standard-Ladelogik:
- Filter: Anstellungsart_ID IN (3, 5) - Fest + Minijobber
- Sortierung: Alphabetisch nach Nachname
- Auto-Load: Erster Mitarbeiter wird automatisch angezeigt
- Dropdown-Optionen: Fest+Mini, Nur Fest, Nur Mini, Alle

### API-Server Fix (Access Bridge/api_server.py):
- Parameter `anstellung`: Expliziter Filter (z.B. "3" oder "3,5")
- Parameter `filter_anstellung`: true = Default-Filter (3,5), false = alle
- Feld `Anstellungsart_ID` wird jetzt im SELECT zurueckgegeben

---

## ABGESCHLOSSENE TESTS (2026-01-09)

### Mitarbeiterstamm Test:
| Funktion | Status | Details |
|----------|--------|---------|
| MA-Liste geladen | ✅ | 123 Mitarbeiter (Fest + Mini) |
| Alphabetisch sortiert | ✅ | Akcay → Zournatzidis |
| Erster MA auto-geladen | ✅ | Akcay, Ediz (ID 852) |
| Filter-Dropdown | ✅ | "Fest + Mini" als Default |

### Auftragstamm Test:
| Funktion | Status | Details |
|----------|--------|---------|
| Auftragsliste ab heute | ✅ | Erster: Sa. 10.01.26 (Consec Feier) |
| Aufsteigend sortiert | ✅ | 10.01. → 11.01. → 14.01. → ... |
| 89 Auftraege "In Planung" | ✅ | Statusanzeige korrekt |
| Auftrag auto-geladen | ✅ | Mit Details, Schichten, Einsatzliste |
| Schichten geladen | ✅ | 3 Schichten (17:30, 18:00, 18:30) |
| Einsatzliste | ✅ | 13 Positionen |
| Umlaute korrekt | ✅ | Loewensaal, Nuernberg, Duesseldorf |

---

## NAECHSTE SESSION

Beim Fortsetzen:
1. Stand dieser Datei lesen
2. ✅ Alle UI-Optimierungen implementiert (2026-01-09)
3. ✅ Umlaute repariert (2026-01-09)
4. ✅ Stabilitaetsregeln implementiert (2026-01-09)
5. ✅ FROZEN_FEATURES.md erstellt (2026-01-09)
6. ✅ Mitarbeiterstamm getestet (2026-01-09)
7. ✅ Auftragstamm getestet (2026-01-09)
8. ✅ Schnellauswahl Auto-Load implementiert (2026-01-09)
9. ✅ DblClick-Events implementiert (2026-01-09)
10. ✅ Bedingte Formatierung implementiert (2026-01-09)
11. ✅ Browser-Tests DblClick + Formatierung (2026-01-09)
12. Optional: IstFraglich mit echten Daten testen
13. Optional: Überbuchung mit echten Daten testen
14. Optional: Veranstalter-Regeln testen (20760, 20750)

---

*Automatisch erstellt von Claude Code*
