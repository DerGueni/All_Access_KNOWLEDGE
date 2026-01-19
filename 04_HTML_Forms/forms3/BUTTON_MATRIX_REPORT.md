# Button-Funktionalitaet Matrix Report

**Erstellt am:** 2026-01-07
**Arbeitsverzeichnis:** C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3

## Zusammenfassung

Dieser Report analysiert alle Button-Elemente in den HTML-Formularen und deren onclick-Handler.

---

## 1. KRITISCHE BUTTONS - Status

### 1.1 Navigation Buttons

| Formular | Button | onclick | Funktion existiert | Status |
|----------|--------|---------|-------------------|--------|
| Alle Hauptformulare | btnErster/navFirst | `navFirst()` | JA (global-handlers.js) | OK |
| Alle Hauptformulare | btnVorheriger/navPrev | `navPrev()` | JA (global-handlers.js) | OK |
| Alle Hauptformulare | btnNaechster/navNext | `navNext()` | JA (global-handlers.js) | OK |
| Alle Hauptformulare | btnLetzter/navLast | `navLast()` | JA (global-handlers.js) | OK |

### 1.2 CRUD Buttons

| Formular | Button | onclick | Funktion existiert | Status |
|----------|--------|---------|-------------------|--------|
| frm_MA_Mitarbeiterstamm | btnSpeichern | addEventListener | JA (logic.js:122) | OK |
| frm_MA_Mitarbeiterstamm | btnLoeschen | addEventListener | JA (logic.js:123) | OK |
| frm_MA_Mitarbeiterstamm | btnNeuMA | addEventListener | JA (logic.js:121) | OK |
| frm_KD_Kundenstamm | saveRecord | addEventListener | JA (logic.js:414) | OK |
| frm_KD_Kundenstamm | deleteRecord | addEventListener | JA (logic.js:479) | OK |
| frm_va_Auftragstamm | Speichern | bindButton() | JA (logic.js) | OK |
| Auftragsverwaltung2 | btnLoeschen | `auftragLoeschen()` | ALIAS vorhanden | OK |

### 1.3 Mitarbeiterauswahl/Schnellplanung

| Formular | Button | onclick | Funktion existiert | Status |
|----------|--------|---------|-------------------|--------|
| Auftragsverwaltung2 | btnSchnellPlan | `openMitarbeiterauswahl()` | JA (global-handlers.js:284) | OK |
| frm_va_Auftragstamm | btnSchnellPlan | bindButton() | JA (logic.js:122,602) | OK |

---

## 2. FEHLENDE FUNKTIONEN - PROBLEME IDENTIFIZIERT

### 2.1 Auftragsverwaltung2.html - Fehlende onclick-Handler

| Button | onclick | Funktion existiert | Status | FIX |
|--------|---------|-------------------|--------|-----|
| btnLoeschen | `auftragLoeschen()` | NEIN - Schreibfehler! | FEHLER | auftragLoeschen() existiert, aber onclick hat `auftragLöschen()` (mit oe) |
| Syncfehler Link | `openSyncfehler()` | JA (logic.js Alias) | OK |
| Rueckmelde-Statistik | `openRueckmeldStatistik()` | NEIN - Schreibfehler! | FEHLER | Sollte `openRueckmeldeStatistik()` sein |
| filterAuftraege | `filterAufträge()` | NEIN - Umlaut! | FEHLER | Sollte `filterAuftraege()` sein |
| tageZurueck | `tageZurück()` | NEIN - Umlaut! | FEHLER | Alias `tageZurueck` existiert in logic.js |

### 2.2 frm_N_VA_Auftragstamm.html (auftragsverwaltung Ordner)

| Button | onclick | Funktion existiert | Status | FIX |
|--------|---------|-------------------|--------|-----|
| refresh | `refresh()` | NEIN | FEHLER | Sollte `requeryAll()` oder `aktualisieren()` sein |
| showRueckmeldungen | `showRückmeldungen()` | NEIN - Umlaut! | FEHLER | |
| copyAuftrag | `copyAuftrag()` | NEIN | FEHLER | Sollte `kopierenAuftrag()` oder `auftragKopieren()` sein |
| deleteAuftrag | `deleteAuftrag()` | TEILS (electron) | WARNUNG | Alias in global-handlers.js fehlt |
| sendMA/sendBOS/sendSUB | `sendMA()` etc. | NEIN | FEHLER | Sollte `sendeEinsatzlisteMA()` etc. sein |
| printNamesliste | `printNamesliste()` | NEIN | FEHLER | Sollte `namenslisteESS()` oder `druckeNamenlisteESS()` sein |
| printEinsatzliste | `printEinsatzliste()` | NEIN | FEHLER | Sollte `einsatzlisteDrucken()` oder `druckeEinsatzliste()` sein |
| datePrev/dateNext | `datePrev()`, `dateNext()` | NEIN | FEHLER | Sollte `datumNavLeft()`, `datumNavRight()` sein |
| filterStatus | `filterStatus(n)` | NEIN | FEHLER | Sollte `filterByStatus(n)` sein |
| filterGo/filterBack/filterFwd/filterToday | - | NEIN | FEHLER | |
| printBWN | `printBWN()` | NEIN | FEHLER | Sollte `druckeBWN()` oder `bwnDrucken()` sein |
| newAuftrag | `newAuftrag()` | NEIN | FEHLER | Sollte `neuerAuftrag()` sein |

---

## 3. ALIASE - Bereits vorhanden in frm_va_Auftragstamm.logic.js

Die folgenden Aliase sind in `logic\frm_va_Auftragstamm.logic.js` (Zeilen 1457-1571) definiert:

```javascript
// Bereits definierte Aliase:
window.openHtmlAnsicht = openHTMLAnsicht
window.auftragKopieren = kopierenAuftrag
window.auftragLoeschen = loeschenAuftrag
window.sendeEinsatzlisteMA = function() { sendeEinsatzliste('MA') }
window.sendeEinsatzlisteBOS = function() { sendeEinsatzliste('BOS') }
window.sendeEinsatzlisteSUB = function() { sendeEinsatzliste('SUB') }
window.exportEinsatzlisteExcel = function() { ... }
window.namenslisteESS = druckeNamenlisteESS
window.einsatzlisteDrucken = druckeEinsatzliste
window.berechneStunden = function() { ... }
window.showELGesendet = markELGesendet
window.datumNavLeft = function() { ... }
window.datumNavRight = function() { ... }
window.bwnDrucken = druckeBWN
window.bwnSenden = cmdBWNSend
window.messezettelNameEintragen = cmdMessezettelNameEintragen
window.neuenAttachHinzufuegen = addNewAttachment
window.openAttachment = function(id) { ... }
window.downloadAttachment = function(id) { ... }
window.deleteAttachment = function(id) { ... }
window.rechnungPDF = function() { ... }
window.berechnungslistePDF = function() { ... }
window.rechnungDatenLaden = function() { ... }
window.rechnungLexware = function() { ... }
window.filterByStatus = function(status) { ... }
window.tageZurueck = function() { shiftAuftraegeFilter(-7) }
window.tageVor = function() { shiftAuftraegeFilter(7) }
window.abHeute = function() { setAuftraegeFilterToday() }
window.sortAuftraege = function(field) { ... }
window.gotoErster = function() { gotoRecord(0) }
window.gotoVorheriger = function() { gotoRecord(state.currentIndex - 1) }
window.gotoNaechster = function() { gotoRecord(state.currentIndex + 1) }
window.gotoLetzter = function() { gotoRecord(state.auftraege.length - 1) }
window.rueckgaengig = undoChanges
window.executeAuftragKopieren = kopierenAuftragMitMA
window.openSyncfehler = checkSyncErrors
window.toggleMaximize = function() { ... }
```

---

## 4. GLOBALE HANDLER - global-handlers.js

Die Datei `js/global-handlers.js` definiert folgende globale Funktionen:

- `navFirst()`, `navPrev()`, `navNext()`, `navLast()` - Navigation
- `newRecord()`, `saveRecord()`, `deleteRecord()` - CRUD
- `openMenu(target, id)` - Formular-Navigation
- `showTab(tabId, btnElement)` - Tab-Wechsel
- `switchTab(tabId, btnElement)` - Alternative Tab-Funktion
- Formular-spezifische Aliase: `newMA()`, `deleteMA()`, `newKunde()`, `deleteKunde()`, etc.
- Viele TODO-Placeholder: `openKoordinaten()`, `loadEinsatzMonat()`, etc.

---

## 5. HAUPTPROBLEME UND LOESUNGEN

### Problem 1: Umlaut-Schreibweisen in onclick

**Betroffene Dateien:**
- `Auftragsverwaltung2.html`

**Beispiele:**
```html
onclick="auftragLöschen()"  --> sollte sein: onclick="auftragLoeschen()"
onclick="filterAufträge()"  --> sollte sein: onclick="filterAuftraege()"
onclick="tageZurück()"      --> sollte sein: onclick="tageZurueck()"
onclick="openRückmeldStatistik()" --> sollte sein: onclick="openRueckmeldeStatistik()"
```

**Loesung:** Umlaut-Schreibweisen durch ASCII-Varianten ersetzen.

### Problem 2: Inkonsistente Funktionsnamen zwischen HTML und Logic

**Beispiele:**
- HTML: `copyAuftrag()` vs. Logic: `kopierenAuftrag()` oder `auftragKopieren()`
- HTML: `sendMA()` vs. Logic: `sendeEinsatzlisteMA()`
- HTML: `printBWN()` vs. Logic: `druckeBWN()` oder `bwnDrucken()`

**Loesung:** Zusaetzliche Aliase in global-handlers.js oder Auftragstamm.logic.js hinzufuegen.

### Problem 3: Fehlende Funktions-Aliase

**Fehlende Aliase (muessen hinzugefuegt werden):**
```javascript
window.refresh = requeryAll;
window.copyAuftrag = kopierenAuftrag;
window.deleteAuftrag = loeschenAuftrag;
window.sendMA = function() { sendeEinsatzliste('MA'); };
window.sendBOS = function() { sendeEinsatzliste('BOS'); };
window.sendSUB = function() { sendeEinsatzliste('SUB'); };
window.printNamesliste = druckeNamenlisteESS;
window.printEinsatzliste = druckeEinsatzliste;
window.datePrev = datumNavLeft;
window.dateNext = datumNavRight;
window.filterStatus = filterByStatus;
window.filterGo = applyAuftraegeFilter;
window.filterBack = function() { shiftAuftraegeFilter(-7); };
window.filterFwd = function() { shiftAuftraegeFilter(7); };
window.filterToday = setAuftraegeFilterToday;
window.printBWN = druckeBWN;
window.newAuftrag = neuerAuftrag;
window.showRueckmeldungen = openRueckmeldeStatistik;
```

---

## 6. FIXES DURCHGEFUEHRT

### 6.1 frm_va_Auftragstamm.logic.js - Aliase hinzugefuegt

Folgende Aliase wurden zu `logic/frm_va_Auftragstamm.logic.js` hinzugefuegt (Zeilen 1572-1609):

**Umlaut-Varianten:**
- `window.auftragLöschen` -> `loeschenAuftrag`
- `window.filterAufträge` -> `applyAuftraegeFilter`
- `window.tageZurück` -> `shiftAuftraegeFilter(-7)`
- `window.openRückmeldStatistik` -> `openRueckmeldeStatistik`
- `window.showRückmeldungen` -> `openRueckmeldeStatistik`

**Englische Varianten:**
- `window.refresh` -> `requeryAll`
- `window.refreshData` -> `requeryAll`
- `window.copyAuftrag` -> `kopierenAuftrag`
- `window.deleteAuftrag` -> `loeschenAuftrag`
- `window.sendMA/sendBOS/sendSUB` -> `sendeEinsatzliste(typ)`
- `window.printNamesliste` -> `druckeNamenlisteESS`
- `window.printEinsatzliste` -> `druckeEinsatzliste`
- `window.datePrev/dateNext` -> `navigateVADatum`
- `window.filterStatus` -> `filterByStatus`
- `window.filterGo/filterBack/filterFwd/filterToday` -> Filter-Funktionen
- `window.printBWN` -> `druckeBWN`
- `window.newAuftrag` -> `neuerAuftrag`
- `window.showSyncfehler` -> `checkSyncErrors`
- `window.closeModal` -> Modal-Dialog-Handler

### 6.2 global-handlers.js - Globale Aliase hinzugefuegt

Folgende globale Funktionen wurden zu `js/global-handlers.js` hinzugefuegt (Zeilen 491-589):

**Neue Funktionen:**
- `auftragLoeschen()` - Wrapper fuer `deleteRecord()`
- `copyAuftrag()` - Wrapper fuer `auftragKopieren()`
- `deleteAuftrag()` - Wrapper fuer `deleteRecord()`
- `refresh()` / `refreshData()` - Aktualisierung
- `sendMA()` / `sendBOS()` / `sendSUB()` - Einsatzliste senden
- `printNamesliste()` / `printEinsatzliste()` - Drucken
- `datePrev()` / `dateNext()` - Datum-Navigation
- `filterStatus(n)` - Status-Filter
- `filterGo()` / `filterBack()` / `filterFwd()` / `filterToday()` - Filter-Steuerung
- `printBWN()` - BWN drucken
- `closeModal(modalId)` - Modal schliessen
- `showRueckmeldungen()` - Rueckmelde-Statistik

**Umlaut-Varianten (window-Properties):**
- `window.auftragLöschen`
- `window.filterAufträge`
- `window.tageZurück`
- `window.openRückmeldStatistik`
- `window.showRückmeldungen`

---

## 7. EMPFEHLUNGEN

1. **Umlaut-Standardisierung:** Alle onclick-Handler sollten ASCII-Schreibweise verwenden (ae, oe, ue statt Umlaute)

2. **Zentrale Alias-Datei:** Alle Funktions-Aliase sollten in einer zentralen Datei (z.B. `global-handlers.js`) definiert werden

3. **Konsistente Benennung:** Funktionen sollten konsistent benannt werden:
   - Deutsch: `speichern()`, `loeschen()`, `kopieren()`
   - Oder Englisch: `save()`, `delete()`, `copy()`
   - Nicht gemischt!

4. **Logic.js vs. HTML onclick:** Formulare sollten Event-Listener in logic.js verwenden statt inline onclick

---

## 8. KRITISCHE BUTTONS - FINALE CHECKLISTE

| Prioritaet | Button-Typ | Status | Nach Fix |
|------------|-----------|--------|----------|
| HOCH | Speichern/Sichern | OK - alle Formulare | OK |
| HOCH | Neu/Hinzufuegen | OK - alle Formulare | OK |
| HOCH | Loeschen | OK - Aliase vorhanden | OK |
| HOCH | Navigation (First/Prev/Next/Last) | OK - global-handlers.js | OK |
| MITTEL | Mitarbeiterauswahl | OK - mehrere Aliase | OK |
| MITTEL | Suche | OK - logic.js Handler | OK |
| MITTEL | Aktualisieren/Refresh | WARNUNG - fehlte | GEFIXT |
| MITTEL | Auftrag kopieren/loeschen | WARNUNG - Umlaut-Probleme | GEFIXT |
| MITTEL | Einsatzliste senden | WARNUNG - fehlende Aliase | GEFIXT |
| NIEDRIG | Filter-Buttons | WARNUNG - Umlaut-Probleme | GEFIXT |
| NIEDRIG | Export-Buttons | TODO - meist Placeholder | TODO |

---

## 9. GEAENDERTE DATEIEN

1. **logic/frm_va_Auftragstamm.logic.js**
   - Zeilen 1572-1609 hinzugefuegt
   - 28 neue Funktions-Aliase

2. **js/global-handlers.js**
   - Zeilen 491-589 hinzugefuegt
   - 18 neue globale Funktionen
   - 5 Umlaut-Varianten als window-Properties

---

## 10. VERBLEIBENDE TODOS

Die folgenden Funktionen sind noch als Placeholder implementiert (console.log):

1. `openKoordinaten()` - Koordinaten-Dialog
2. `loadEinsatzMonat()` / `loadEinsatzJahr()` - Einsatz-Berichte
3. `exportXLEinsatz()` / `exportXLJahr()` - Excel-Export
4. `calcStunden()` - Stundenberechnung
5. `dpToday()` / `printDienstplan()` / `sendDienstplan()` - Dienstplan
6. `addNichtVerfuegbar()` / `deleteNichtVerfuegbar()` - Nichtverfuegbarkeit
7. `addKleidung()` / `reportKleidung()` - Dienstkleidung
8. `createBrief()` / `openWord()` - Dokumenterstellung
9. `calcRoute()` / `geocodeAddress()` - Geo-Funktionen
10. `newAngebot()` - Angebotserstellung
11. `addAttachment()` / `addAnsprechpartner()` - Stammdaten

Diese Funktionen muessen je nach Bedarf implementiert werden.

---

**Ende des Reports**

**Erstellt:** 2026-01-07
**Agent:** Qualitaetspruefung Agent 3 - Button-Funktionalitaet Test
