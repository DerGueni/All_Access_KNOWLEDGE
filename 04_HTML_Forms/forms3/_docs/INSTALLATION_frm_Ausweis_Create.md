# INSTALLATION: frm_Ausweis_Create - WebView2 Integration

**Status:** HTML-Seite fertig, Access-Integration ausstehend
**Datum:** 2026-01-03

---

## ÜBERSICHT

Dieses Formular ist **vollständig WebView2-konform** umgestellt. Alle Änderungen am HTML/JS sind abgeschlossen.

**Noch zu tun:** Access-Backend erstellen (VBA + Reports)

---

## BEREITS ERLEDIGT ✅

### HTML-Seite
- [x] `webview2-bridge.js` eingebunden
- [x] Mitarbeiter-Laden via `Bridge.loadData('mitarbeiter')`
- [x] Ausweis-Druck via `Bridge.sendEvent('createBadge', ...)`
- [x] Kartendruck via `Bridge.sendEvent('printCard', ...)`
- [x] Event-Handler registriert
- [x] Fallback-Preview implementiert

### Dokumentation
- [x] Audit-Report erstellt (`AUDIT_frm_Ausweis_Create.md`)
- [x] VBA-Module vorbereitet (`01_VBA\mod_N_Ausweis_Create_Bridge.bas`)
- [x] Event-Handler-Template (`01_VBA\frm_N_Ausweis_Create_EventHandlers.bas`)
- [x] SQL für Temp-Tabelle (`02_SQL\CREATE_tbl_TEMP_AusweisListe.sql`)

---

## INSTALLATION (Access-Backend)

### SCHRITT 1: JsonConverter installieren
```
1. Download: https://github.com/VBA-tools/VBA-JSON
2. Datei JsonConverter.bas ins Access-Projekt importieren
3. In VBA-Editor → Tools → References:
   - "Microsoft Scripting Runtime" aktivieren
```

### SCHRITT 2: Temporäre Tabelle erstellen
```sql
-- SQL aus: 02_SQL\CREATE_tbl_TEMP_AusweisListe.sql
CREATE TABLE tbl_TEMP_AusweisListe (
    ID AUTOINCREMENT PRIMARY KEY,
    MA_ID LONG,
    Nachname TEXT(100),
    Vorname TEXT(100),
    AusweisNr TEXT(20),
    GueltBis DATETIME,
    AusweisTyp TEXT(50),
    ErstelltAm DATETIME DEFAULT Now(),
    ErstelltVon TEXT(50)
);
```

### SCHRITT 3: VBA-Module importieren
```
1. mod_N_Ausweis_Create_Bridge.bas importieren
   - Öffnet VBA-Editor
   - File → Import File
   - Pfad: 01_VBA\mod_N_Ausweis_Create_Bridge.bas
```

### SCHRITT 4: Access-Formular erstellen
```
1. Neues Formular erstellen: frm_N_Ausweis_Create
2. WebView2-Control einfügen:
   - Control-Toolbox → ActiveX → "Microsoft Edge WebView2"
   - Name: "webview"
   - Dock: "Fill" (ganzes Formular)
3. Formular-Code einfügen:
   - Kopiere Code aus: 01_VBA\frm_N_Ausweis_Create_EventHandlers.bas
   - Formular öffnen → Design → View Code
   - Code einfügen
```

### SCHRITT 5: Reports erstellen (10 Stück)

**Ausweis-Reports (6):**
1. `rpt_Dienstausweis_Einsatzleitung`
2. `rpt_Dienstausweis_Bereichsleiter`
3. `rpt_Dienstausweis_Security`
4. `rpt_Dienstausweis_Service`
5. `rpt_Dienstausweis_Platzanweiser`
6. `rpt_Dienstausweis_Staff`

**Karten-Reports (4):**
7. `rpt_Karte_Sicherheit`
8. `rpt_Karte_Service`
9. `rpt_Karte_Rueckseite`
10. `rpt_Karte_Sonder`

**Report-Struktur (Beispiel):**
```
RecordSource: SELECT * FROM tbl_TEMP_AusweisListe

Detailbereich:
- Firmenlogo (oben links)
- Foto des Mitarbeiters (falls vorhanden)
- Nachname, Vorname (groß, zentriert)
- Ausweis-Typ (farblich markiert)
- Ausweis-Nr
- Gültig bis: [Datum]
- Unterschrift/Stempel (unten)

Seitenformat:
- 85mm x 54mm (Kartengröße ISO/IEC 7810 ID-1)
```

### SCHRITT 6: Drucker-Setup (optional)
```
Für Kartendruck:
1. Kartendrucker in Windows installieren
2. In Access → File → Print → Drucker-Setup
3. Drucker-Namen merken (z.B. "Evolis Zenius")
4. In frm_Ausweis_Create.html → Dropdown aktualisieren:
   <option value="Evolis Zenius">Kartendrucker 1</option>
```

---

## TESTEN

### TEST 1: Formular öffnen
```vba
DoCmd.OpenForm "frm_N_Ausweis_Create"
```
**Erwartung:** HTML-Formular wird angezeigt, keine Fehler

### TEST 2: Mitarbeiter laden
```
1. Formular öffnet sich
2. Nach 1-2 Sekunden: Liste "Alle Mitarbeiter" wird gefüllt
3. Counter zeigt Anzahl
```
**Erwartung:** Alle aktiven MA sichtbar

### TEST 3: Transfer
```
1. Mitarbeiter in linker Liste auswählen
2. Klick auf ">" Button
3. MA erscheint in rechter Liste
4. Counter wird aktualisiert
```
**Erwartung:** Transfer funktioniert

### TEST 4: Ausweis drucken
```
1. MA auswählen (rechte Liste)
2. Gültigkeitsdatum prüfen/ändern
3. Button "Einsatzleitung" klicken
```
**Erwartung:**
- Report `rpt_Dienstausweis_Einsatzleitung` öffnet sich
- Vorschau zeigt ausgewählte MA
- Daten korrekt befüllt

### TEST 5: Kartendruck
```
1. MA auswählen
2. Kartendrucker auswählen
3. Button "Sicherheit" klicken
```
**Erwartung:**
- Report `rpt_Karte_Sicherheit` druckt direkt
- Auf ausgewähltem Drucker

---

## DATENPFADE

**HTML-Formular:**
```
C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\frm_Ausweis_Create.html
```

**Logic-Datei:**
```
C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\logic\frm_Ausweis_Create.logic.js
```

**Bridge:**
```
C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\js\webview2-bridge.js
```

---

## EVENT-FLOW REFERENZ

### Mitarbeiter laden
```
[Access] Form_Load
    → Me.webview.Navigate "file:///..."
[Browser] DOMContentLoaded
    → Bridge.loadData('mitarbeiter', { aktiv: true })
[Browser] Bridge.sendEvent('loadData', ...)
    → webview.postMessage(...)
[Access] webview_WebMessageReceived
    → data("type") = "loadData"
    → mod_N_Ausweis_Create_Bridge.Ausweis_Create_SendMitarbeiterDaten()
[Access] SQL-Query auf tbl_MA_Mitarbeiterstamm
    → JSON generieren
    → Me.webview.PostWebMessageAsJson(json)
[Browser] Bridge.onDataReceived(json)
    → handleDataReceived({ mitarbeiter: [...] })
    → renderAllEmployees()
```

### Ausweis drucken
```
[Browser] User klickt "Einsatzleitung"
    → printBadge('Einsatzleitung')
    → Bridge.sendEvent('createBadge', { employees: [...], badgeType: '...', validUntil: '...' })
[Access] webview_WebMessageReceived
    → data("type") = "createBadge"
    → mod_N_Ausweis_Create_Bridge.Ausweis_Create_CreateBadge(...)
[Access] tbl_TEMP_AusweisListe füllen
    → DoCmd.OpenReport "rpt_Dienstausweis_Einsatzleitung", acViewPreview
[User] Vorschau → Drucken
```

---

## TROUBLESHOOTING

### Problem: "Keine Mitarbeiter werden geladen"
**Lösung:**
1. Prüfen: `tbl_MA_Mitarbeiterstamm` existiert?
2. Prüfen: Feld `IstAktiv` vorhanden?
3. Debug-Modus: `Debug.Print` in VBA prüfen

### Problem: "Report nicht gefunden"
**Lösung:**
1. Report-Namen exakt prüfen (Groß/Kleinschreibung!)
2. Alle 10 Reports erstellt?
3. RecordSource gesetzt?

### Problem: "JSON-Fehler beim Parsen"
**Lösung:**
1. JsonConverter korrekt installiert?
2. "Microsoft Scripting Runtime" aktiviert?
3. Test: `?JsonConverter.ParseJson("{""test"": 123}")` in VBA Immediate Window

### Problem: "WebView2 zeigt nichts an"
**Lösung:**
1. WebView2 Runtime installiert?
2. HTML-Pfad korrekt? (file:/// Prefix!)
3. Datei existiert? `Dir(htmlPath)` prüfen

---

## FERTIGSTELLUNG

**Checkliste:**
- [ ] JsonConverter importiert
- [ ] Temp-Tabelle erstellt
- [ ] VBA-Modul importiert
- [ ] Formular mit WebView2 erstellt
- [ ] Event-Handler eingefügt
- [ ] 6 Ausweis-Reports erstellt
- [ ] 4 Karten-Reports erstellt
- [ ] Drucker konfiguriert
- [ ] Tests durchgeführt
- [ ] Produktiv einsetzbar

**Bei Abschluss:**
✅ Formular in Menü-Navigation eintragen
✅ Benutzer-Dokumentation erstellen
✅ Schulung durchführen
