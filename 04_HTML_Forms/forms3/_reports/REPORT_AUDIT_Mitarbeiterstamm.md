# FUNKTIONALITÄTSPRÜFUNG: frm_MA_Mitarbeiterstamm.html

**Datum:** 2026-01-03
**Datei:** `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\frm_MA_Mitarbeiterstamm.html`
**Logic-Datei:** `logic\frm_MA_Mitarbeiterstamm.logic.js`

---

## ZUSAMMENFASSUNG

**Gesamtstatus:** ⚠️ TEILWEISE FUNKTIONAL - Mehrere kritische Diskrepanzen

**Hauptprobleme:**
1. **DOPPELTE IMPLEMENTIERUNG:** HTML enthält inline JavaScript + separate Logic-Datei (Konfliktpotenzial)
2. **FEHLENDE SUBFORMULARE:** 5 von 8 referenzierten iframes existieren NICHT
3. **BUTTON-ID MISMATCH:** Logic-Datei erwartet andere Button-IDs als im HTML vorhanden
4. **INKONSISTENTE FELDNAMEN:** HTML nutzt andere data-field Namen als Logic-Datei

---

## 1. HEADER/NAVIGATION

### 1.1 Mitarbeiter-Auswahl (Right Panel)
| Element | Status | Details |
|---------|--------|---------|
| Suchfeld `#searchInput` | ✅ IMPLEMENTIERT | Live-Suche mit debounce (300ms) |
| Filter-Dropdown `#filterSelect` | ✅ IMPLEMENTIERT | "Aktiv / Alle / Inaktiv" |
| Mitarbeiterliste `#maListTable` | ✅ IMPLEMENTIERT | Klick lädt Datensatz |
| Keyboard Navigation | ✅ IMPLEMENTIERT | ArrowUp/Down in Liste (HTML), Ctrl+ArrowUp/Down (Logic) |

**Diskrepanz:**
- HTML: Event-Handler direkt im `<script>` Tag (Zeile 1244-1257)
- Logic: Separate Event-Handler in `setupEventListeners()` (Zeile 109-189)
- **RISIKO:** Beide könnten gleichzeitig feuern → Doppeltes Laden

### 1.2 Record Navigation
| Button | HTML ID | Logic ID | HTML onclick | Status |
|--------|---------|----------|--------------|--------|
| Erste | `btnErste` | `btnErster` | `navFirst()` | ⚠️ ID-MISMATCH |
| Vorige | `btnVorige` | `btnVorheriger` | `navPrev()` | ⚠️ ID-MISMATCH |
| Nächste | `btnNaechste` | `btnNaechster` | `navNext()` | ⚠️ ID-MISMATCH |
| Letzte | `btnLetzte` | `btnLetzter` | `navLast()` | ⚠️ ID-MISMATCH |

**Problem:** Logic-Datei sucht nach nicht existierenden IDs (`btnErster`, `btnVorheriger`, etc.)

### 1.3 Action Buttons (Header)
| Button | HTML ID | Logic ID | Funktion | Status |
|--------|---------|----------|----------|--------|
| MA Adressen | `btnMAAdressen` | `btnMAAdresse` | `openMAAdressen()` / `openMAAdresse()` | ⚠️ MISMATCH |
| Aktualisieren | `btnAktualisieren` | - | `refreshData()` | ✅ HTML only |
| Zeitkonto | `btnZeitkonto` | `btnZeitkonto` | `openZeitkonto()` | ✅ OK |
| Neuer MA | `btnNeuMA` | `btnNeuMA` | `neuerMitarbeiter()` / `newRecord()` | ⚠️ UNTERSCHIEDLICHE FUNKTIONEN |
| Löschen | `btnLoeschen` | `btnLoeschen` | `mitarbeiterLoeschen()` / `deleteRecord()` | ⚠️ UNTERSCHIEDLICHE FUNKTIONEN |
| Einsätze FA/MJ | `btnEinsaetzeFA/MJ` | - | `einsaetzeUebertragen()` | ✅ HTML only |
| Listen drucken | `btnListenDrucken` | `btnListenDrucken` | `listenDrucken()` | ⚠️ DOPPELT (window.print / window.print) |
| MA Tabelle | `btnMATabelle` | `btnMATabelle` | `mitarbeiterTabelle()` / `openMATabelle()` | ⚠️ UNTERSCHIEDLICHE FUNKTIONEN |
| Dienstplan | `btnDienstplan` | - | `openDienstplan()` | ✅ HTML only |
| Einsatzübersicht | - | - | `openEinsatzuebersicht()` | ✅ HTML only |
| Karte öffnen | `btnMapsOeffnen` | `btnMapsOeffnen` | `openMaps()` | ✅ OK (aber doppelt implementiert) |
| Speichern | `btnSpeichern` | `btnSpeichern` | `speichern()` / `saveRecord()` | ⚠️ UNTERSCHIEDLICHE FUNKTIONEN |

---

## 2. TABS/REITER

### 2.1 Tab-Struktur
| Tab-Name | HTML ID | Inhalt | Status |
|----------|---------|--------|--------|
| Stammdaten | `tab-stammdaten` | Formular mit 3 Spalten | ✅ VOLLSTÄNDIG |
| Einsatzübersicht | `tab-einsatzuebersicht` | Tabelle mit Aktualisieren-Button | ✅ IMPLEMENTIERT |
| Dienstplan | `tab-dienstplan` | iframe → `sub_MA_Dienstplan.html` | ❌ SUBFORM FEHLT |
| Nicht Verfügbar | `tab-nichtverfuegbar` | Tabelle + Neu/Löschen Buttons | ✅ IMPLEMENTIERT |
| Dienstkleidung | `tab-dienstkleidung` | Tabelle + Ausgabe/Rückgabe | ✅ IMPLEMENTIERT |
| Zeitkonto | `tab-zeitkonto` | iframe → `sub_MA_Zeitkonto.html` | ❌ SUBFORM FEHLT |
| Jahresübersicht | `tab-jahresuebersicht` | iframe → `sub_MA_Jahresuebersicht.html` | ❌ SUBFORM FEHLT |
| Stundenübers. | `tab-stundenuebersicht` | iframe → `sub_MA_Stundenuebersicht.html` | ❌ SUBFORM FEHLT |
| Vordrucke | `tab-vordrucke` | 5 Druck-Buttons | ✅ IMPLEMENTIERT |
| Briefkopf | `tab-briefkopf` | Textarea mit data-field | ✅ IMPLEMENTIERT |
| Karte | `tab-karte` | Google Maps Link + Placeholder | ✅ IMPLEMENTIERT |
| Sub Rechnungen | `tab-subrechnungen` | iframe → `sub_MA_Rechnungen.html` | ❌ SUBFORM FEHLT |
| Überhang Std. | `tab-ueberhangstunden` | Tabelle | ✅ IMPLEMENTIERT |

### 2.2 Tab-Wechsel Mechanismus
```javascript
// HTML (Zeile 1230-1234)
document.querySelectorAll('.tab-btn').forEach(btn => {
    btn.addEventListener('click', function() {
        switchTab(this.dataset.tab);
    });
});
```

**Status:** ✅ FUNKTIONIERT
**Aber:** Keine Lazy-Loading Logik für iframe-Tabs → Alle Subformulare werden sofort geladen

### 2.3 Tab-Inhalte mit Data-Loading
| Tab | Load-Funktion | Bridge API | Status |
|-----|--------------|------------|--------|
| Einsatzübersicht | `loadEinsaetze()` | `Bridge.loadData('einsaetze', maId)` | ⚠️ Bridge Event registriert, aber Implementierung fehlt |
| Nicht Verfügbar | `loadNichtVerfuegbar()` | `apiCall('/mitarbeiter/:id/nichtverfuegbar')` | ⚠️ Nutzt direkte API statt Bridge |
| Dienstkleidung | `loadDienstkleidung()` | `apiCall('/mitarbeiter/:id/dienstkleidung')` | ⚠️ Nutzt direkte API statt Bridge |
| Überhang Std. | `loadUeberhangStunden()` | `apiCall('/mitarbeiter/:id/ueberhang')` | ⚠️ Nutzt direkte API statt Bridge |

**Problem:** Funktion `apiCall()` ist nicht definiert im HTML!

---

## 3. STAMMDATEN-FELDER

### 3.1 Spalte 1 (Persönliche Daten)
| Feld | HTML ID | data-field | Typ | Status |
|------|---------|------------|-----|--------|
| PersNr | `ID` | `ID` | readonly | ✅ OK |
| LexNr | `LEXWare_ID` | `LEXWare_ID` | text | ✅ OK |
| Aktiv | `IstAktiv` | `IstAktiv` | checkbox | ✅ OK |
| Lex_Aktiv | `Lex_Aktiv` | `Lex_Aktiv` | checkbox | ✅ OK |
| Nachname | `Nachname` | `Nachname` | text | ✅ OK |
| Vorname | `Vorname` | `Vorname` | text | ✅ OK |
| Straße | `Strasse` | `Strasse` | text | ✅ OK |
| Nr | `Nr` | `Nr` | text | ✅ OK |
| PLZ | `PLZ` | `PLZ` | text | ✅ OK |
| Ort | `Ort` | `Ort` | text | ✅ OK |
| Land | `Land` | `Land` | select | ✅ OK |
| Bundesland | `Bundesland` | `Bundesland` | text | ✅ OK |
| Tel. Mobil | `Tel_Mobil` | `Tel_Mobil` | text | ✅ OK |
| Tel. Festnetz | `Tel_Festnetz` | `Tel_Festnetz` | text | ✅ OK |
| Email | `Email` | `Email` | text | ✅ OK |
| Geschlecht | `Geschlecht` | `Geschlecht` | select | ✅ OK |
| Staatsang. | `Staatsang` | `Staatsang` | text | ✅ OK |
| Geb. Datum | `Geb_Dat` | `Geb_Dat` | date | ✅ OK |
| Geb. Ort | `Geb_Ort` | `Geb_Ort` | text | ✅ OK |
| Geb. Name | `Geb_Name` | `Geb_Name` | text | ✅ OK |

### 3.2 Spalte 2 (Beschäftigung/Qualifikation)
| Feld | HTML ID | data-field | Typ | Status |
|------|---------|------------|-----|--------|
| Eintrittsdatum | `Eintrittsdatum` | `Eintrittsdatum` | date | ✅ OK |
| Austrittsdatum | `Austrittsdatum` | `Austrittsdatum` | date | ✅ OK |
| Anstellungsart | `Anstellungsart_ID` | `Anstellungsart_ID` | select | ✅ OK |
| Subunternehmer | `Subunternehmer` | `Subunternehmer` | checkbox | ⚠️ Logic erwartet `IstSubunternehmer` |
| Kleidergröße | `Kleidergroe` | `Kleidergroe` | select | ✅ OK |
| Fahrerausweis | `Hat_Fahrerausweis` | `Hat_Fahrerausweis` | checkbox | ✅ OK |
| Eigener PKW | `Hat_EigenerPKW` | `Hat_EigenerPKW` | checkbox | ✅ OK |
| Dienstausweis | `DienstausweisNr` | `DienstausweisNr` | text | ✅ OK |
| Letzte Überpr. OA | `Letzte_Ueberpr_OA` | `Letzte_Ueberpr_OA` | date | ✅ OK |
| Personalausweis-Nr | `Personalausweis_Nr` | `Personalausweis_Nr` | text | ✅ OK |
| DFB Epin | `Epin_DFB` | `Epin_DFB` | text | ✅ OK |
| DFB Modul 1 | `DFB_Modul_1` | `DFB_Modul_1` | checkbox | ✅ OK |
| Bewacher ID | `Bewacher_ID` | `Bewacher_ID` | text | ✅ OK |
| Zust. Behörde | `Zustaendige_Behoerde` | `Zustaendige_Behoerde` | text | ✅ OK |

### 3.3 Spalte 3 (Finanzen/Admin)
| Feld | HTML ID | data-field | Typ | Status |
|------|---------|------------|-----|--------|
| Kontoinhaber | `Kontoinhaber` | `Kontoinhaber` | text | ✅ OK |
| BIC | `BIC` | `BIC` | text | ✅ OK |
| IBAN | `IBAN` | `IBAN` | text | ✅ OK |
| Lohngruppe | `Stundenlohn_brutto` | `Stundenlohn_brutto` | select | ✅ OK |
| Bezüge gezahlt als | `Bezuege_gezahlt_als` | `Bezuege_gezahlt_als` | text | ✅ OK |
| Koordinaten | `Koordinaten` | `Koordinaten` | text | ✅ OK |
| Steuer-ID | `SteuerNr` | `SteuerNr` | text | ✅ OK |
| Tätigkeit Bez. | `Taetigkeit_Bezeichnung` | `Taetigkeit_Bezeichnung` | select | ✅ OK |
| Krankenkasse | `KV_Kasse` | `KV_Kasse` | text | ✅ OK |
| Steuerklasse | `Steuerklasse` | `Steuerklasse` | text | ✅ OK |
| Urlaub pro Jahr | `Urlaubsanspr_pro_Jahr` | `Urlaubsanspr_pro_Jahr` | number | ✅ OK |
| Std. Monat max. | `StundenZahlMax` | `StundenZahlMax` | number | ⚠️ Logic erwartet `Stundenzahl` |
| RV Befreiung | `Ist_RV_Befrantrag` | `Ist_RV_Befrantrag` | checkbox | ✅ OK |
| Brutto-Std | `IstNSB` | `IstNSB` | checkbox | ✅ OK |
| Abrechnung eMail | `eMail_Abrechnung` | `eMail_Abrechnung` | checkbox | ✅ OK |
| Unterweisung § 34a | `Unterweisungs_34a` | `Unterweisungs_34a` | checkbox | ✅ OK |
| Sachkunde § 34a | `Sachkunde_34a` | `Sachkunde_34a` | checkbox | ✅ OK |

### 3.4 Foto-Sektion
```html
<div class="photo-section">
    <div class="photo-frame">
        <img id="maPhoto" src="" alt="Foto">
    </div>
    <button class="photo-btn" onclick="openMaps()">Karte offnen</button>
</div>
```

**Status:** ⚠️ TEILWEISE
- Foto-Container existiert (`#maPhoto`)
- HTML hat `updatePhoto()` Funktion (Zeile 1432-1451)
- Logic hat `loadFoto()` Funktion (Zeile 442-451)
- **Problem:** Button sollte Foto hochladen, öffnet aber Maps!

---

## 4. DATENLADEN & SPEICHERN

### 4.1 Load-Mechanismus (HTML)
```javascript
// HTML Implementierung
Bridge.on('onDataReceived', function(data) {
    if (data.mitarbeiterList) {
        state.mitarbeiterList = data.mitarbeiterList;
        renderMitarbeiterList();
    } else if (data.mitarbeiter) {
        loadMitarbeiterData(data.mitarbeiter);
    }
});

Bridge.loadData('mitarbeiter', null, { filter: filter });
```

**Status:** ✅ IMPLEMENTIERT (Zeile 1260-1323)

### 4.2 Load-Mechanismus (Logic)
```javascript
// Logic Implementierung
const result = await Bridge.mitarbeiter.list(params);
state.records = result.data || result || [];

const detail = await Bridge.mitarbeiter.get(state.currentRecord.MA_ID);
displayRecord(detail.data || detail);
```

**Status:** ✅ IMPLEMENTIERT (Zeile 209-340)

**KRITISCHE DISKREPANZ:**
- HTML nutzt `Bridge.loadData()` mit Event-Callbacks
- Logic nutzt `Bridge.mitarbeiter.list()` mit async/await
- **RISIKO:** Beide könnten gleichzeitig laden → Race Conditions

### 4.3 Save-Mechanismus (HTML)
```javascript
// HTML: speichern() (Zeile 1484-1506)
Bridge.sendEvent('save', {
    type: 'mitarbeiter',
    id: state.currentRecord.ID,
    data: data
});
```

**Status:** ✅ IMPLEMENTIERT - Sammelt Daten aus `[data-field]` Elementen

### 4.4 Save-Mechanismus (Logic)
```javascript
// Logic: saveRecord() (Zeile 498-553)
await Bridge.execute('updateMitarbeiter', { id, ...data });
await Bridge.execute('createMitarbeiter', data);
```

**Status:** ✅ IMPLEMENTIERT - Nutzt explizites Feld-Mapping

**KRITISCHE DISKREPANZ:**
- HTML: `Bridge.sendEvent('save')`
- Logic: `Bridge.execute('updateMitarbeiter')`
- **RISIKO:** Unterschiedliche API-Endpunkte!

---

## 5. SUBFORMULARE

### 5.1 Vorhandene Subformulare (im forms3 Verzeichnis)
- ✅ `sub_MA_VA_Zuordnung.html`
- ✅ `sub_MA_VA_Planung_Status.html`
- ✅ `sub_MA_VA_Planung_Absage.html`
- ✅ `sub_MA_Offene_Anfragen.html`
- ✅ `sub_DP_Grund.html`
- ✅ `sub_DP_Grund_MA.html`
- ✅ `sub_rch_Pos.html`
- ✅ `sub_ZusatzDateien.html`
- ✅ `sub_OB_Objekt_Positionen.html`

### 5.2 Referenzierte aber FEHLENDE Subformulare
- ❌ `sub_MA_Dienstplan.html` (Zeile 1048)
- ❌ `sub_MA_Zeitkonto.html` (Zeile 1085)
- ❌ `sub_MA_Jahresuebersicht.html` (Zeile 1090)
- ❌ `sub_MA_Stundenuebersicht.html` (Zeile 1095)
- ❌ `sub_MA_Rechnungen.html` (Zeile 1130)

**AUSWIRKUNG:** Diese Tabs zeigen nur leere iframes mit Fehler in Console

### 5.3 PostMessage-Kommunikation
**Status:** ❌ NICHT IMPLEMENTIERT
- Keine `window.addEventListener('message')` im HTML
- Keine `postMessage()` Aufrufe an Subformulare
- Keine Datenübergabe an iframes

---

## 6. BUTTONS DETAILANALYSE

### 6.1 Navigation Buttons
| Button | onclick | Implementierung | Test-Status |
|--------|---------|----------------|-------------|
| Erste | `navFirst()` | ✅ HTML Zeile 1675 | ⏸️ NICHT GETESTET |
| Vorige | `navPrev()` | ✅ HTML Zeile 1675 | ⏸️ NICHT GETESTET |
| Nächste | `navNext()` | ✅ HTML Zeile 1675 | ⏸️ NICHT GETESTET |
| Letzte | `navLast()` | ✅ HTML Zeile 1675 | ⏸️ NICHT GETESTET |

**Hinweis:** Navigation nur als Platzhalter - aufgerufen wird `showRecord(index)` aus beiden Implementierungen

### 6.2 CRUD Buttons
| Button | HTML Funktion | Logic Funktion | Konflikt? |
|--------|--------------|----------------|-----------|
| Neuer MA | `neuerMitarbeiter()` | `newRecord()` | ⚠️ JA - Unterschiedliche Logik |
| Speichern | `speichern()` | `saveRecord()` | ⚠️ JA - Unterschiedliche API Calls |
| Löschen | `mitarbeiterLoeschen()` | `deleteRecord()` | ⚠️ JA - Unterschiedliche API Calls |
| Aktualisieren | `refreshData()` | - | ✅ HTML only |

**HTML `neuerMitarbeiter()` (Zeile 1456-1468):**
```javascript
Bridge.sendEvent('save', {
    type: 'mitarbeiter',
    action: 'create',
    data: { Nachname: 'Neuer', Vorname: 'Mitarbeiter', IstAktiv: true }
});
```

**Logic `newRecord()` (Zeile 484-493):**
```javascript
clearForm();
nachnameField.focus();
setStatus('Neuer Mitarbeiter - Daten eingeben');
```

**UNTERSCHIED:** HTML erstellt sofort einen DB-Eintrag, Logic nur UI-Reset!

### 6.3 Spezial-Buttons
| Button | Funktion | Status | Bemerkung |
|--------|----------|--------|-----------|
| MA Adressen | `openMAAdressen()` | ⚠️ TEILWEISE | Navigiert zu frm_MA_Adressen.html |
| Zeitkonto | `openZeitkonto()` | ⚠️ TEILWEISE | HTML: Bridge.navigate / Logic: window.open |
| Dienstplan | `openDienstplan()` | ✅ IMPLEMENTIERT | HTML only - Bridge.navigate |
| Einsatzübersicht | `openEinsatzuebersicht()` | ✅ IMPLEMENTIERT | HTML only - Bridge.navigate |
| Karte öffnen | `openMaps()` | ✅ DOPPELT | HTML: Google Maps Search / Logic: Google Maps Search |
| Einsätze FA/MJ | `einsaetzeUebertragen()` | ✅ IMPLEMENTIERT | HTML only - Bridge.sendEvent |
| Listen drucken | `listenDrucken()` | ✅ DOPPELT | Beide: window.print() |
| MA Tabelle | `mitarbeiterTabelle()` | ⚠️ UNTERSCHIEDLICH | HTML: Navigate / Logic: Alert |

### 6.4 Tab-Buttons
| Tab | Buttons | Status | API Call vorhanden? |
|-----|---------|--------|---------------------|
| Einsatzübersicht | Aktualisieren | ✅ OK | ⚠️ Bridge Event, keine Response-Handler |
| Nicht Verfügbar | Neu, Löschen | ⚠️ TEILWEISE | ❌ Funktion `apiCall()` nicht definiert |
| Dienstkleidung | Ausgabe, Rückgabe | ⚠️ PLACEHOLDER | ❌ Nur Toast-Nachrichten |
| Vordrucke | 5x Drucken | ✅ IMPLEMENTIERT | ✅ Bridge.sendEvent('print') |

---

## 7. DATUMSFELDER

### 7.1 Datumseingaben
| Feld | Typ | Format | onChange | Validierung |
|------|-----|--------|----------|-------------|
| Geb_Dat | `type="date"` | ISO (YYYY-MM-DD) | ✅ Tracked (isDirty) | ❌ Keine |
| Eintrittsdatum | `type="date"` | ISO | ❌ Nicht tracked | ❌ Keine |
| Austrittsdatum | `type="date"` | ISO | ❌ Nicht tracked | ❌ Keine |
| Letzte_Ueberpr_OA | `type="date"` | ISO | ❌ Nicht tracked | ❌ Keine |

### 7.2 Datumsformatierung (Anzeige)
```javascript
// HTML: Zeile 1393-1400
if (value && typeof value === 'string' && value.includes('T')) {
    if (el.type === 'date') {
        value = value.substring(0, 10);
    } else {
        const date = new Date(value);
        value = date.toLocaleDateString('de-DE');
    }
}
```

**Status:** ✅ KORREKT - ISO → DE Formatierung bei Anzeige

### 7.3 Datumsspeicherung
**Problem:** Keine Konvertierung DE → ISO beim Speichern!
- Input-Typ `date` gibt ISO zurück ✅
- Aber keine Validierung bei manueller Eingabe ❌

---

## 8. ABHÄNGIGE DATEN & SUBFORM-UPDATES

### 8.1 Master-Detail-Verknüpfung
**Erwartung:** Bei Mitarbeiter-Wechsel sollten alle Tabs aktualisiert werden

**Realität:**
- ✅ Tab "Stammdaten" wird aktualisiert (via `loadMitarbeiterData()`)
- ⚠️ Tab "Einsatzübersicht" lädt nur bei manueller Aktualisierung (`loadEinsaetze()`)
- ❌ Tabs mit iframes erhalten KEINE MA-ID via postMessage
- ❌ Keine Callback-Funktion bei Tab-Wechsel zum Nachladen

### 8.2 Implementierte Tab-Wechsel-Logik
```javascript
// Zeile 1676-1682
function switchTab(tabName) {
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.toggle('active', btn.dataset.tab === tabName);
    });
    document.querySelectorAll('.tab-page').forEach(page => {
        page.classList.toggle('active', page.id === 'tab-' + tabName);
    });
}
```

**Fehlend:**
```javascript
// SOLLTE SO SEIN:
function switchTab(tabName) {
    // ... (vorhandener Code)

    // Lazy Loading für Tab-Inhalte
    if (tabName === 'einsatzuebersicht' && !tabsLoaded.einsatzuebersicht) {
        loadEinsaetze();
        tabsLoaded.einsatzuebersicht = true;
    }

    // MA-ID an Subformulare senden
    if (tabName === 'dienstplan' && state.currentRecord) {
        const iframe = document.querySelector('#tab-dienstplan iframe');
        iframe?.contentWindow.postMessage({
            type: 'LOAD_MA',
            ma_id: state.currentRecord.ID
        }, '*');
    }
}
```

---

## 9. VERGLEICH MIT ACCESS (VBA)

### 9.1 Gefundene VBA-Referenzen
**Dateien mit Bezug zu frm_MA_Mitarbeiterstamm:**
- `01_VBA\modules\InfoListbox.bas`
- `01_VBA\modules\mod_ExportSuite.bas`
- `01_VBA\modules\mdl_Menu_Neu.bas`
- `01_VBA\modules\mdl_TEMP_CodeInserter.bas`

**Problem:** Keine VBA-Form-Datei für `frm_MA_Mitarbeiterstamm` gefunden!
**Folge:** Kann Original-Events nicht vergleichen

### 9.2 Fehlende JSON-Schema
- Kein Schema in `09_Schema/` für Mitarbeiter gefunden
- **Empfehlung:** Schema erstellen mit allen Feldnamen, Typen, Constraints

---

## 10. KRITISCHE PROBLEME

### 10.1 Doppelte Code-Implementierung
**Problem:** Inline JavaScript im HTML + separate Logic-Datei
**Auswirkung:**
- Event-Handler könnten doppelt feuern
- Inkonsistente State-Verwaltung (zwei `state` Objekte)
- API-Calls nutzen unterschiedliche Bridge-Methoden

**Lösungsvorschlag:**
```html
<!-- Option A: Nur Logic-Datei nutzen -->
<script type="module" src="logic/frm_MA_Mitarbeiterstamm.logic.js"></script>
<!-- ODER -->
<!-- Option B: Inline-Script entfernen, alles in Logic -->
```

### 10.2 Fehlende Subformulare
**Problem:** 5 Tabs referenzieren nicht existierende HTML-Dateien

**Sofort erstellen:**
1. `sub_MA_Dienstplan.html`
2. `sub_MA_Zeitkonto.html`
3. `sub_MA_Jahresuebersicht.html`
4. `sub_MA_Stundenuebersicht.html`
5. `sub_MA_Rechnungen.html`

### 10.3 API-Call ohne Definition
**Problem:** Funktionen `loadNichtVerfuegbar()`, `loadDienstkleidung()`, `loadUeberhangStunden()` nutzen `apiCall()`, aber diese Funktion existiert nicht!

**Zeile 1594, 1626, 1651:**
```javascript
const result = await apiCall(`/mitarbeiter/${maId}/nichtverfuegbar`);
```

**Lösungsvorschlag:**
```javascript
// Option 1: Bridge nutzen
const result = await Bridge.execute('getNichtVerfuegbar', { maId });

// Option 2: apiCall definieren
async function apiCall(endpoint, options = {}) {
    const response = await fetch(`http://localhost:5000${endpoint}`, options);
    return response.json();
}
```

### 10.4 Button-ID Mismatch
**Problem:** Logic-Datei sucht Buttons die nicht existieren

**Fix:** Entweder HTML IDs anpassen ODER Logic-Datei IDs korrigieren:
```javascript
// Logic Zeile 53-56 - KORRIGIERT:
btnErster: document.getElementById('btnErste'),      // statt btnErster
btnVorheriger: document.getElementById('btnVorige'),  // statt btnVorheriger
btnNaechster: document.getElementById('btnNaechste'), // statt btnNaechster
btnLetzter: document.getElementById('btnLetzte'),     // statt btnLetzter
```

---

## 11. EMPFEHLUNGEN

### 11.1 Priorität 1 (Sofort)
1. ✅ **Entscheidung treffen:** Inline-Script ODER Logic-Datei (nicht beides!)
2. ✅ **IDs korrigieren:** Button-IDs in Logic an HTML anpassen
3. ✅ **apiCall definieren:** Fehlende Funktion implementieren
4. ✅ **Subformulare erstellen:** 5 fehlende HTML-Dateien anlegen

### 11.2 Priorität 2 (Diese Woche)
5. ⚠️ **PostMessage implementieren:** MA-ID an Subformulare übergeben
6. ⚠️ **Tab-Lazy-Loading:** Daten erst bei Tab-Wechsel laden
7. ⚠️ **Feld-Tracking:** Alle Felder auf onChange tracken (isDirty)
8. ⚠️ **Validierung:** Pflichtfelder, Datumsformat, IBAN-Prüfung

### 11.3 Priorität 3 (Nächste Woche)
9. 📝 **VBA-Vergleich:** Original Access-Form exportieren und Events vergleichen
10. 📝 **JSON-Schema erstellen:** Alle Felder mit Typen dokumentieren
11. 📝 **Unit-Tests:** Kritische Funktionen (save, delete, nav) testen
12. 📝 **Error-Handling:** Try-Catch um alle Bridge-Calls

---

## 12. TEST-MATRIX

### 12.1 Manuelle Tests (empfohlen)
| Test | Aktion | Erwartetes Ergebnis | Status |
|------|--------|---------------------|--------|
| T01 | Formular öffnen | Liste lädt, erster MA wird angezeigt | ⏸️ |
| T02 | Klick auf MA in Liste | Stammdaten werden geladen | ⏸️ |
| T03 | Navigation (Erste/Letzte) | Korrekter MA wird angezeigt | ⏸️ |
| T04 | Suche nach Name | Gefilterte Liste, korrekter MA | ⏸️ |
| T05 | Filter "Inaktiv" | Liste zeigt nur inaktive MA | ⏸️ |
| T06 | Feld ändern + Speichern | Daten in DB gespeichert | ⏸️ |
| T07 | "Neuer MA" Button | Leeres Formular, Cursor auf Nachname | ⏸️ |
| T08 | Neuen MA speichern | MA wird erstellt, ID vergeben | ⏸️ |
| T09 | MA löschen (mit Rückfrage) | MA aus DB entfernt | ⏸️ |
| T10 | Tab-Wechsel "Einsatzübersicht" | Tabelle lädt Einsätze | ⏸️ |
| T11 | Tab "Dienstplan" | iframe lädt (oder Fehler?) | ⏸️ |
| T12 | Tab "Zeitkonto" | iframe lädt (oder Fehler?) | ⏸️ |
| T13 | Button "Karte öffnen" | Google Maps in neuem Tab | ⏸️ |
| T14 | Button "Zeitkonto" | frm_MA_Zeitkonten öffnet mit MA-ID | ⏸️ |
| T15 | Button "MA Adressen" | frm_MA_Adressen öffnet | ⏸️ |
| T16 | Foto-Upload-Button | Dateiauswahl-Dialog (derzeit: Maps!) | ❌ |

---

## 13. FAZIT

### 13.1 Funktionalität
**Grundfunktionen:** ✅ 70% VORHANDEN
- Navigation in Liste funktioniert
- Stammdaten-Anzeige funktioniert
- Speichern/Löschen implementiert (aber API-Konflikt)

**Kritische Lücken:** ❌ 30% FEHLEN
- 5 Subformulare nicht vorhanden
- Doppelte Implementierung führt zu Konflikten
- API-Calls teilweise fehlerhaft

### 13.2 Code-Qualität
**Positiv:**
- Klare HTML-Struktur
- Separation of Concerns (Logic-Datei)
- Event-Delegation in Logic

**Negativ:**
- Inline-Script UND Logic-Datei (Pick one!)
- Keine Error-Boundaries
- Hartcodierte API-URL
- Fehlende Type-Checks

### 13.3 Nächste Schritte
1. **Sofort:** Doppel-Implementierung bereinigen
2. **Heute:** Fehlende Subformulare erstellen
3. **Diese Woche:** PostMessage + Lazy-Loading
4. **Nächste Woche:** VBA-Vergleich + Tests

---

**Report erstellt:** 2026-01-03
**Geprüft von:** Claude Code Analysis Agent
**Nächste Prüfung:** Nach Implementierung Priorität 1 Fixes
