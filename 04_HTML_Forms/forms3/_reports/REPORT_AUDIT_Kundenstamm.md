# Funktionalitäts-Audit: frm_KD_Kundenstamm.html

**Audit-Datum:** 2026-01-03
**Datei:** `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\frm_KD_Kundenstamm.html`
**Access-Original:** `frm_KD_Kundenstamm`

---

## EXECUTIVE SUMMARY

### Gefundene Probleme: KRITISCH
- **KEINE Subformulare implementiert** - Alle Subforms fehlen komplett
- **Keine API-Integration** - Formulär nutzt nur WebView2 Bridge (keine REST API)
- **Tab "Objekte" zeigt nur statische Tabelle** - Keine iframe-Integration
- **Tab "Zusatzdateien" unvollständig** - File-Upload funktioniert, aber Tabelle fehlt korrekt im DOM
- **PLZ→Ort Autocomplete FEHLT** - Keine Implementierung
- **Fehlende Kaskaden-Updates** bei Tab-Wechsel

---

## 1. KUNDEN-AUSWAHL FUNKTIONALITÄT

### 1.1 Kunden-Liste (Rechtes Panel)
**Status:** ✅ FUNKTIONIERT

**Implementierung:**
```javascript
// Zeile 1127-1146: loadKunden()
async function loadKunden() {
    showLoading();
    const nurAktive = document.getElementById('chkNurAktive').checked;
    Bridge.loadData('kunden', null, { aktiv: nurAktive });

    // Response via onDataReceived
    renderKundenList();
}
```

**Controls:**
- `#chkNurAktive` (Zeile 999) - Checkbox "Nur Aktive"
- `#searchInput` (Zeile 1004) - Such-Feld
- `#kundenTable` (Zeile 1008-1020) - Tabelle mit Spalten: Nr, Firma, Ort, Telefon

**Funktionen:**
- ✅ Lädt Kunden bei Initialisierung (Zeile 1112)
- ✅ Filter "Nur Aktive" funktioniert (Zeile 1000)
- ✅ Live-Suche nach Firmenname (Zeile 1076, 1162-1167)
- ✅ Click auf Zeile lädt Kundendaten (Zeile 1180)
- ✅ Keyboard-Navigation ArrowUp/Down (Zeile 1079-1088)

**VBA-Vergleich:**
```vba
' VBA: Form_frm_KD_Kundenstamm.bas Zeile 193-200
Private Sub NurAktiveKD_AfterUpdate()
    If Me!NurAktiveKD = False Then
        Me!lst_KD.RowSource = "SELECT ... ORDER BY kun_firma;"
    Else
        Me!lst_KD.RowSource = "SELECT ... WHERE kun_IstAktiv = TRUE ..."
    End If
End Sub
```
**HTML entspricht VBA:** ✅ JA

### 1.2 Kunden-Details laden
**Status:** ✅ FUNKTIONIERT

**Implementierung:**
```javascript
// Zeile 1185-1199: showRecord()
async function showRecord(index) {
    Bridge.loadData('kunde', kdId);  // Lädt vollen Datensatz
    loadKundeData(state.currentRecord);  // Befüllt Formularfelder
}
```

**Controls befüllt via data-field Attribut:**
- Zeile 1207-1220: Alle Felder mit `[data-field]` werden automatisch befüllt
- ✅ Checkboxen korrekt behandelt
- ✅ Text-Felder korrekt behandelt

---

## 2. TABS/REITER ANALYSE

### 2.1 Tab-Struktur
**Status:** ⚠️ TEILWEISE IMPLEMENTIERT

**Gefundene Tabs (Zeile 735-743):**
1. **Stammdaten** (active) - ✅ Vollständig
2. **Objekte** - ⚠️ Nur statische Tabelle (KEIN Subformular!)
3. **Konditionen** - ✅ Einfache Felder
4. **Auftragsübersicht** - ⚠️ Nur statische Tabelle (KEIN Subformular!)
5. **Ansprechpartner** - ⚠️ NUR 1 Ansprechpartner (sollte Liste sein!)
6. **Zusatzdateien** - ⚠️ Unvollständig
7. **Bemerkungen** - ✅ Textareas
8. **Angebote** - ❌ LEER (Zeile 989: "Angebote werden geladen...")

### 2.2 Tab-Wechsel Logik
**Status:** ⚠️ UNVOLLSTÄNDIG

**Implementierung:**
```javascript
// Zeile 1524-1542: switchTab()
function switchTab(tabName) {
    // Tabs umschalten
    if (state.currentRecord) {
        if (tabName === 'auftraguebersicht') {
            loadAuftraege();  // ✅ Lädt Daten
        } else if (tabName === 'objekte') {
            loadObjekte();  // ✅ Lädt Daten
        } else if (tabName === 'zusatzdateien') {
            loadZusatzdateien();  // ✅ Lädt Daten
        }
    }
}
```

**PROBLEM:** Tabs "Ansprechpartner" und "Angebote" haben KEINE Lade-Logik!

---

## 3. SUBFORMULARE - KRITISCHER BEFUND

### 3.1 Access-Original Subformulare
**Quelle:** `FRM_frm_KD_Kundenstamm__subcontrols.json`

**Access hat folgende Subformulare:**
1. `sub_KD_Standardpreise` → Link: `kun_ID`
2. `sub_KD_Auftragskopf` → Link: `kun_ID`
3. `sub_KD_Rch_Auftragspos` → Keine Links
4. `sub_Rch_Kopf_Ang` (Angebote) → Link: `kun_ID`
5. `sub_ZusatzDateien` → Link: `kun_ID`, `TabellenNr`
6. `sub_Ansprechpartner` → Link: `kun_Id`
7. `Menü` → `frm_Menuefuehrung`

### 3.2 HTML-Implementierung
**Status:** ❌ KEINE SUBFORMULARE IMPLEMENTIERT!

**KRITISCH:**
- KEINE `<iframe>` Tags im Code
- KEINE Subformular-Integration
- KEINE postMessage-Kommunikation
- Stattdessen: Statische `<table>` Elemente

**Beispiel Tab "Objekte" (Zeile 859-880):**
```html
<div class="tab-page" id="tab-objekte">
    <div style="display: flex; gap: 8px; margin-bottom: 8px;">
        <button class="btn btn-green" onclick="neuesObjekt()">+ Neues Objekt</button>
    </div>
    <div class="list-wrapper" style="height: 320px;">
        <table class="data-grid" id="objekteTable">
            <!-- Statische Tabelle statt iframe! -->
        </table>
    </div>
</div>
```

**FEHLT KOMPLETT:**
```html
<!-- SOLLTE SEIN: -->
<iframe id="sub_KD_Objekte"
        src="sub_KD_Objekte.html"
        data-link-master="kun_ID"
        style="width: 100%; height: 320px; border: none;">
</iframe>
```

### 3.3 Erforderliche Subformulare für HTML
**Status:** ❌ ALLE FEHLEN

| Access-Subform | Sollte sein in HTML | Implementiert? |
|---|---|---|
| `sub_KD_Standardpreise` | Tab "Konditionen" als iframe | ❌ NEIN |
| `sub_KD_Auftragskopf` | Tab "Auftragsübersicht" als iframe | ❌ NEIN |
| `sub_Rch_Kopf_Ang` | Tab "Angebote" als iframe | ❌ NEIN |
| `sub_ZusatzDateien` | Tab "Zusatzdateien" als iframe | ❌ NEIN |
| `sub_Ansprechpartner` | Tab "Ansprechpartner" als iframe | ❌ NEIN |

---

## 4. BUTTONS UND AKTIONEN

### 4.1 Header-Buttons (Zeile 708-720)
**Status:** ✅ ALLE VORHANDEN

| Button | onclick | Zeile Code | Status |
|---|---|---|---|
| Aktualisieren | `refreshData()` | 1295-1298 | ✅ Funktioniert |
| Verrechnungssätze | `openVerrechnungssaetze()` | 1335-1339 | ✅ Navigation |
| Umsatzauswertung | `openUmsatzauswertung()` | 1341-1345 | ✅ Navigation |
| Neuer Kunde | `neuerKunde()` | 1245-1255 | ✅ CREATE |
| Kunde löschen | `kundeLoeschen()` | 1257-1269 | ✅ DELETE |
| Speichern | `speichern()` | 1271-1293 | ✅ UPDATE |

### 4.2 Tab-spezifische Buttons

**Tab "Objekte" (Zeile 862-864):**
- `+ Neues Objekt` → `neuesObjekt()` (1386-1393) ✅
- `Aktualisieren` → `loadObjekte()` (1350-1353) ✅
- `Objekt öffnen` → `openObjekt()` (1395-1401) ✅

**Tab "Zusatzdateien" (Zeile 951):**
- `Datei hinzufügen` → `dateiHinzufuegen()` (1406-1450) ✅

**VBA-Vergleich:**
```vba
' VBA Zeile 74-85: btnNeuAttach_Click()
Private Sub btnNeuAttach_Click()
    iID = Me!kun_ID
    iTable = Me!TabellenNr
    Call f_btnNeuAttach(iID, iTable)
    Me!sub_ZusatzDateien.Form.Requery
End Sub
```
**HTML hat ähnliche Implementierung:** ✅ JA (Zeile 1406-1450)

### 4.3 VBA Events im Original
**Quelle:** `Form_frm_KD_Kundenstamm.bas`

**Wichtige Events:**
1. `lst_KD_Click()` (Zeile 169) - ✅ HTML hat `showRecord()` (Zeile 1185)
2. `NurAktiveKD_AfterUpdate()` (Zeile 193) - ✅ HTML hat `loadKunden()` mit Filter
3. `Form_Load()` (Zeile 122) - ✅ HTML hat `DOMContentLoaded` (Zeile 1058)
4. `kun_IstAktiv_AfterUpdate()` (Zeile 164) - ❌ HTML hat KEIN Auto-Save bei Checkbox

**FEHLT in HTML:**
- Auto-Save bei Änderung von `kun_IstAktiv` Checkbox
- `Standardleistungen_anlegen()` Call (VBA Zeile 179)

---

## 5. SPEZIELLE FELDER UND VALIDIERUNGEN

### 5.1 PLZ → Ort Autocomplete
**Status:** ❌ NICHT IMPLEMENTIERT

**Feld vorhanden (Zeile 782-788):**
```html
<input type="text" class="form-input medium" id="kun_PLZ" data-field="kun_PLZ">
<input type="text" class="form-input wide" id="kun_Ort" data-field="kun_Ort">
```

**FEHLT:**
- Kein Event-Listener auf `kun_PLZ` blur/change
- Keine PLZ-Lookup Funktion
- Keine API-Anbindung für Ort-Abruf

**SOLLTE SEIN:**
```javascript
document.getElementById('kun_PLZ').addEventListener('blur', async function() {
    const plz = this.value;
    if (plz.length === 5) {
        const ort = await Bridge.plzLookup(plz);
        if (ort) document.getElementById('kun_Ort').value = ort;
    }
});
```

### 5.2 E-Mail Validierung
**Status:** ⚠️ NUR HTML5 VALIDATION

```html
<!-- Zeile 812 -->
<input type="email" class="form-input wide" id="kun_email" data-field="kun_email">
```
- ✅ HTML5 `type="email"` vorhanden
- ❌ Keine JavaScript-Validierung
- ❌ Keine Fehler-Anzeige

### 5.3 Telefon-Felder
**Status:** ❌ KEINE VALIDIERUNG

```html
<!-- Zeile 800, 804, 808 -->
<input type="text" class="form-input wide" id="kun_telefon" data-field="kun_telefon">
<input type="text" class="form-input wide" id="kun_mobil" data-field="kun_mobil">
<input type="text" class="form-input wide" id="kun_telefax" data-field="kun_telefax">
```

**FEHLT:**
- Format-Validierung (z.B. +49...)
- Auto-Formatierung

### 5.4 IBAN/BIC
**Status:** ❌ KEINE VALIDIERUNG

```html
<!-- Zeile 836, 840 -->
<input type="text" class="form-input wide" id="kun_iban" data-field="kun_iban">
<input type="text" class="form-input wide" id="kun_bic" data-field="kun_bic">
```

**FEHLT:**
- IBAN Prüfziffer-Validierung
- BIC Format-Prüfung
- Auto-Formatierung (Leerzeichen)

---

## 6. DATEN-KASKADE

### 6.1 Kunde-Wechsel Ablauf
**Status:** ⚠️ UNVOLLSTÄNDIG

**Implementiert (Zeile 1185-1199):**
```javascript
async function showRecord(index) {
    1. Bridge.loadData('kunde', kdId)  // ✅ Stammdaten laden
    2. loadKundeData(state.currentRecord)  // ✅ Formular befüllen
    3. markSelectedRow(index)  // ✅ Zeile markieren
}
```

**FEHLT:**
- ❌ Ansprechpartner automatisch laden
- ❌ Objekte automatisch laden
- ❌ Aufträge automatisch laden
- ❌ Zusatzdateien automatisch laden
- ❌ Konditionen/Preise automatisch laden

**SOLLTE SEIN (vollständige Kaskade):**
```javascript
async function showRecord(index) {
    // 1. Stammdaten
    Bridge.loadData('kunde', kdId);

    // 2. ALLE verknüpften Daten parallel laden
    await Promise.all([
        loadAnsprechpartner(),
        loadObjekte(),
        loadStandardpreise(),
        loadZusatzdateien()
    ]);

    // 3. Aktuelles Tab refreshen
    const activeTab = document.querySelector('.tab-btn.active').dataset.tab;
    refreshActiveTab(activeTab);
}
```

### 6.2 Tab-Wechsel Kaskade
**Status:** ⚠️ NUR FÜR 3 TABS

**Implementiert:**
- ✅ `auftraguebersicht` → `loadAuftraege()` (Zeile 1534)
- ✅ `objekte` → `loadObjekte()` (Zeile 1536)
- ✅ `zusatzdateien` → `loadZusatzdateien()` (Zeile 1538)

**FEHLT:**
- ❌ `ansprechpartner` → Keine Lade-Logik
- ❌ `angebote` → Keine Lade-Logik
- ❌ `konditionen` → Keine Lade-Logik

---

## 7. API-INTEGRATION

### 7.1 Verwendete API
**Status:** ⚠️ NUR WEBVIEW2 BRIDGE

**Implementiert:**
- ✅ `Bridge.loadData('kunden', ...)` (Zeile 1131)
- ✅ `Bridge.loadData('kunde', ...)` (Zeile 1191)
- ✅ `Bridge.sendEvent('save', ...)` (Zeile 1287)
- ✅ `Bridge.sendEvent('delete', ...)` (Zeile 1265)

**NICHT verwendet:**
- ❌ Kein direkter `fetch('http://localhost:5000/api/kunden')`
- ❌ Keine bridgeClient.js Integration
- ❌ Kein Request-Caching

**PROBLEM:**
- Formulär funktioniert NUR in WebView2 Umgebung
- Kein Standalone-Browser Support
- Keine Performance-Optimierungen via Cache

### 7.2 Zusatzdateien Upload
**Status:** ✅ VERWENDET REST API

**Einzige direkte API-Nutzung (Zeile 1428-1431):**
```javascript
const response = await fetch('http://localhost:5000/api/attachments/upload', {
    method: 'POST',
    body: formData
});
```

---

## 8. FUNKTIONALITÄTS-MATRIX

### 8.1 Stammdaten-Tab
| Feld | Vorhanden | Validierung | Auto-Fill | Status |
|---|---|---|---|---|
| Firma | ✅ | ❌ | - | ✅ OK |
| Bezeichnung | ✅ | ❌ | - | ✅ OK |
| Kunden-Kurzel | ✅ | ❌ | - | ✅ OK |
| Straße | ✅ | ❌ | - | ✅ OK |
| PLZ | ✅ | ❌ | ❌ Keine Ort-Suche | ⚠️ UNVOLLSTÄNDIG |
| Ort | ✅ | ❌ | ❌ | ⚠️ UNVOLLSTÄNDIG |
| Land | ✅ Dropdown | ✅ Vordefiniert | - | ✅ OK |
| Telefon | ✅ | ❌ | - | ⚠️ KEINE VALIDIERUNG |
| Mobil | ✅ | ❌ | - | ⚠️ KEINE VALIDIERUNG |
| Telefax | ✅ | ❌ | - | ⚠️ KEINE VALIDIERUNG |
| E-Mail | ✅ type="email" | ⚠️ Nur HTML5 | - | ⚠️ MINIMAL |
| Homepage | ✅ | ❌ | - | ✅ OK |
| IBAN | ✅ | ❌ | - | ⚠️ KEINE VALIDIERUNG |
| BIC | ✅ | ❌ | - | ⚠️ KEINE VALIDIERUNG |
| USt-ID | ✅ | ❌ | - | ⚠️ KEINE VALIDIERUNG |
| Zahlungsbedingungen | ✅ Dropdown | ✅ Vordefiniert | - | ✅ OK |

### 8.2 Tabs Übersicht
| Tab | Felder/Subform | Daten laden | Status |
|---|---|---|---|
| Stammdaten | ✅ Alle Felder | ✅ Auto | ✅ OK |
| Objekte | ❌ Tabelle statt Subform | ✅ Bei Tab-Wechsel | ⚠️ KEIN SUBFORM |
| Konditionen | ✅ 3 Felder | ❌ KEINE Lade-Logik | ⚠️ UNVOLLSTÄNDIG |
| Auftragsübersicht | ❌ Tabelle statt Subform | ✅ Bei Tab-Wechsel | ⚠️ KEIN SUBFORM |
| Ansprechpartner | ⚠️ NUR 1 Kontakt | ❌ KEINE Lade-Logik | ❌ FALSCH |
| Zusatzdateien | ❌ Tabelle statt Subform | ✅ Bei Tab-Wechsel | ⚠️ KEIN SUBFORM |
| Bemerkungen | ✅ 3 Textareas | ✅ Auto | ✅ OK |
| Angebote | ❌ LEER | ❌ KEINE Lade-Logik | ❌ NICHT IMPLEMENTIERT |

---

## 9. KRITISCHE FEHLENDE FEATURES

### 9.1 Subformulare
**PRIORITÄT: KRITISCH**

**Fehlen komplett:**
1. `sub_KD_Standardpreise` - Kundenspezifische Preise
2. `sub_KD_Auftragskopf` - Auftrags-Historie
3. `sub_Rch_Kopf_Ang` - Angebote
4. `sub_ZusatzDateien` - Dokumente/Anhänge
5. `sub_Ansprechpartner` - Kontaktpersonen-Liste

**Auswirkung:**
- Benutzer kann KEINE Ansprechpartner-Liste sehen
- Benutzer kann KEINE Auftrags-Details sehen
- Benutzer kann KEINE Angebote verwalten
- Drastisch reduzierte Funktionalität vs. Access

### 9.2 Daten-Kaskade
**PRIORITÄT: HOCH**

**Problem:**
- Beim Kunden-Wechsel werden NUR Stammdaten geladen
- Tabs bleiben leer bis manueller Wechsel
- Keine Pre-Loading von verknüpften Daten

**Erwartetes Verhalten:**
- Bei Kunden-Auswahl ALLE Daten laden (wie Access)
- Tabs zeigen sofort Daten wenn gewechselt wird

### 9.3 Validierungen
**PRIORITÄT: MITTEL**

**Fehlen:**
- PLZ → Ort Autocomplete
- IBAN Prüfziffer
- Telefon-Format
- E-Mail Format (nur HTML5)
- USt-ID Format

### 9.4 VBA-Event Äquivalente
**PRIORITÄT: NIEDRIG**

**Fehlen:**
- Auto-Save bei `kun_IstAktiv` Checkbox
- `Standardleistungen_anlegen()` bei Kunden-Wechsel
- Diverse Doppelklick-Events

---

## 10. PERFORMANCE-ANALYSE

### 10.1 Initialisierung
**Status:** ⚠️ KÖNNTE OPTIMIERT WERDEN

**Aktuell (Zeile 1058-1122):**
```javascript
document.addEventListener('DOMContentLoaded', async function() {
    // 1. Tab-Listener hinzufügen (ca. 8 Tabs)
    // 2. Menu-Navigation (falls vorhanden)
    // 3. Search-Listener
    // 4. Keyboard-Listener
    // 5. Bridge-Events registrieren
    // 6. loadKunden() - Kann langsam sein
    // 7. URL-Parameter prüfen
});
```

**Problem:**
- Alles sequenziell
- loadKunden() blockiert

**Besser:**
```javascript
// Parallel laden
await Promise.all([
    setupEventListeners(),
    loadKunden(),
    checkUrlParams()
]);
```

### 10.2 Kunden-Liste Rendering
**Status:** ✅ EFFIZIENT

**Implementierung (Zeile 1160-1183):**
- ✅ Verwendet `innerHTML` für Batch-Update
- ✅ Event-Delegation möglich (nicht genutzt)
- ⚠️ Keine Virtualisierung (bei >1000 Kunden langsam)

### 10.3 Caching
**Status:** ❌ KEIN CACHING

**Problem:**
- Jeder Kunden-Wechsel lädt ALLE Daten neu
- Keine lokale Speicherung
- Bridge-Calls nicht dedupliziert

**Lösung:**
```javascript
const cache = new Map();

async function loadKundeById(kdId) {
    if (cache.has(kdId)) {
        return cache.get(kdId);
    }
    const kunde = await Bridge.loadData('kunde', kdId);
    cache.set(kdId, kunde);
    return kunde;
}
```

---

## 11. VERGLEICH MIT ACCESS VBA

### 11.1 Funktionale Parität
| Feature | Access VBA | HTML | Match? |
|---|---|---|---|
| Kunden-Liste | ✅ lst_KD | ✅ kundenTable | ✅ |
| Nur Aktive Filter | ✅ NurAktiveKD | ✅ chkNurAktive | ✅ |
| Stammdaten Felder | ✅ Alle | ✅ Alle | ✅ |
| Subformulare | ✅ 7 Stück | ❌ 0 Stück | ❌ |
| Tab-Navigation | ✅ TabControl | ✅ Custom Tabs | ✅ |
| Speichern | ✅ Auto | ✅ Button | ⚠️ |
| Neuer Kunde | ✅ Button | ✅ Button | ✅ |
| Löschen | ✅ Button | ✅ Button | ✅ |
| Objekte öffnen | ✅ Subform | ⚠️ Navigation | ⚠️ |
| Ansprechpartner | ✅ Liste | ❌ 1 Kontakt | ❌ |

**Parität:** ~60%

### 11.2 VBA Events → HTML Mapping

| VBA Event | HTML Äquivalent | Implementiert? |
|---|---|---|
| `Form_Load()` | `DOMContentLoaded` | ✅ Zeile 1058 |
| `lst_KD_Click()` | `tr.addEventListener('click')` | ✅ Zeile 1180 |
| `NurAktiveKD_AfterUpdate()` | `chkNurAktive change` | ✅ Zeile 1000 |
| `kun_IstAktiv_AfterUpdate()` | - | ❌ FEHLT |
| `btnNeuAttach_Click()` | `dateiHinzufuegen()` | ✅ Zeile 1406 |
| `Standardleistungen_anlegen()` | - | ❌ FEHLT |

---

## 12. CODE-QUALITÄT

### 12.1 JavaScript
**Status:** ⚠️ GUT ABER VERBESSERBAR

**Positiv:**
- ✅ Strict Mode aktiviert (Zeile 1046)
- ✅ Saubere Funktions-Trennung
- ✅ Async/Await korrekt verwendet
- ✅ Error-Handling vorhanden
- ✅ Kommentare vorhanden

**Negativ:**
- ⚠️ Keine Modularisierung (alles in einem `<script>`)
- ⚠️ Globale `state` Variable (sollte gekapselt sein)
- ❌ Keine TypeScript/JSDoc
- ❌ Keine Tests

### 12.2 HTML-Struktur
**Status:** ✅ SEHR GUT

**Positiv:**
- ✅ Semantisch korrekt
- ✅ Accessibility (Labels, ARIA könnte besser sein)
- ✅ Responsive Layout (Flexbox)
- ✅ Konsistente Namenskonventionen

### 12.3 CSS
**Status:** ✅ GUT

**Positiv:**
- ✅ Inline im `<head>` (schnelles First Paint)
- ✅ Konsistentes Design-System
- ✅ Access-ähnliches Styling
- ✅ Scrollbar-Styling

**Negativ:**
- ⚠️ Keine CSS-Variablen für Farben
- ⚠️ Könnte ausgelagert werden

---

## 13. EMPFOHLENE FIXES

### PRIORITÄT 1 - KRITISCH (Sofort)

#### 13.1 Subformulare implementieren
**Aufwand:** HOCH (3-5 Tage)

**Schritte:**
1. Erstelle `sub_KD_Ansprechpartner.html`
2. Erstelle `sub_KD_Objekte.html` (oder nutze vorhandene Tabelle als Basis)
3. Erstelle `sub_KD_Auftraege.html`
4. Erstelle `sub_KD_Zusatzdateien.html`
5. Erstelle `sub_KD_Angebote.html`
6. Implementiere postMessage-Kommunikation
7. Integriere in Tabs via `<iframe>`

**Code-Beispiel:**
```html
<!-- Tab Ansprechpartner -->
<div class="tab-page" id="tab-ansprechpartner">
    <iframe id="sub_Ansprechpartner"
            src="sub_KD_Ansprechpartner.html"
            style="width: 100%; height: 400px; border: none;">
    </iframe>
</div>
```

```javascript
// Parent → Subform Kommunikation
function loadAnsprechpartner() {
    const iframe = document.getElementById('sub_Ansprechpartner');
    iframe.contentWindow.postMessage({
        type: 'LOAD_DATA',
        kun_Id: state.currentRecord.kun_Id
    }, '*');
}
```

#### 13.2 Vollständige Daten-Kaskade
**Aufwand:** MITTEL (1-2 Tage)

**Code:**
```javascript
async function showRecord(index) {
    if (index < 0 || index >= state.kundenList.length) return;
    state.currentIndex = index;
    const kdId = state.kundenList[index].kun_Id;

    // 1. Stammdaten laden
    Bridge.loadData('kunde', kdId);
    state.currentRecord = state.kundenList[index];
    loadKundeData(state.currentRecord);

    // 2. ALLE Subformulare parallel laden
    await Promise.all([
        loadAnsprechpartner(),
        loadObjekte(),
        loadStandardpreise(),
        loadAuftraege(),
        loadZusatzdateien(),
        loadAngebote()
    ]);

    markSelectedRow(index);
}
```

### PRIORITÄT 2 - HOCH (Diese Woche)

#### 13.3 PLZ → Ort Autocomplete
**Aufwand:** NIEDRIG (2 Stunden)

**Code:**
```javascript
document.getElementById('kun_PLZ').addEventListener('blur', async function() {
    const plz = this.value.trim();
    if (plz.length === 5 && /^\d+$/.test(plz)) {
        showLoading();
        try {
            const result = await Bridge.plzLookup(plz);
            if (result?.ort) {
                document.getElementById('kun_Ort').value = result.ort;
            }
        } catch (e) {
            console.error('PLZ-Lookup fehlgeschlagen:', e);
        } finally {
            hideLoading();
        }
    }
});
```

#### 13.4 IBAN/BIC Validierung
**Aufwand:** NIEDRIG (3 Stunden)

**Code:**
```javascript
function validateIBAN(iban) {
    iban = iban.replace(/\s/g, '').toUpperCase();
    if (!/^[A-Z]{2}\d{2}[A-Z0-9]+$/.test(iban)) return false;

    // IBAN Prüfziffer-Algorithmus
    const rearranged = iban.slice(4) + iban.slice(0, 4);
    const numeric = rearranged.replace(/[A-Z]/g, (c) => c.charCodeAt(0) - 55);
    const mod97 = BigInt(numeric) % 97n;
    return mod97 === 1n;
}

document.getElementById('kun_iban').addEventListener('blur', function() {
    if (this.value && !validateIBAN(this.value)) {
        showToast('Ungültige IBAN', 'error');
        this.classList.add('error');
    } else {
        this.classList.remove('error');
    }
});
```

### PRIORITÄT 3 - MITTEL (Nächste Woche)

#### 13.5 REST API Integration
**Aufwand:** MITTEL (2 Tage)

**Ziel:**
- Formulär auch standalone im Browser lauffähig
- Performance-Optimierungen via Caching

**Code:**
```javascript
// Hybrid: Bridge ODER REST API
async function loadKunden() {
    showLoading();
    const nurAktive = document.getElementById('chkNurAktive').checked;

    let result;
    if (window.Bridge && Bridge.isAvailable) {
        // WebView2 Umgebung
        result = await Bridge.loadData('kunden', null, { aktiv: nurAktive });
    } else {
        // Standalone Browser
        const url = `http://localhost:5000/api/kunden?aktiv=${nurAktive}`;
        const response = await fetch(url);
        result = await response.json();
    }

    state.kundenList = result.data || result;
    renderKundenList();
    hideLoading();
}
```

#### 13.6 Request-Caching
**Aufwand:** NIEDRIG (1 Tag)

**Code:**
```javascript
class DataCache {
    constructor(ttl = 60000) {
        this.cache = new Map();
        this.ttl = ttl;
    }

    set(key, value) {
        this.cache.set(key, {
            value,
            timestamp: Date.now()
        });
    }

    get(key) {
        const entry = this.cache.get(key);
        if (!entry) return null;
        if (Date.now() - entry.timestamp > this.ttl) {
            this.cache.delete(key);
            return null;
        }
        return entry.value;
    }

    clear() {
        this.cache.clear();
    }
}

const kundenCache = new DataCache(60000);

async function loadKundeById(kdId) {
    const cached = kundenCache.get(`kunde_${kdId}`);
    if (cached) return cached;

    const kunde = await Bridge.loadData('kunde', kdId);
    kundenCache.set(`kunde_${kdId}`, kunde);
    return kunde;
}
```

### PRIORITÄT 4 - NIEDRIG (Später)

#### 13.7 Virtual Scrolling für Kunden-Liste
**Aufwand:** MITTEL (1-2 Tage)

**Nur nötig bei >1000 Kunden**

#### 13.8 Keyboard-Shortcuts
**Aufwand:** NIEDRIG (4 Stunden)

**Code:**
```javascript
document.addEventListener('keydown', (e) => {
    // Ctrl+S = Speichern
    if (e.ctrlKey && e.key === 's') {
        e.preventDefault();
        speichern();
    }

    // Ctrl+N = Neuer Kunde
    if (e.ctrlKey && e.key === 'n') {
        e.preventDefault();
        neuerKunde();
    }

    // F5 = Aktualisieren
    if (e.key === 'F5') {
        e.preventDefault();
        refreshData();
    }
});
```

---

## 14. ZUSAMMENFASSUNG

### 14.1 Funktionalität
**Gesamt-Score:** 6/10

**✅ Funktioniert gut:**
- Kunden-Auswahl und Navigation
- Stammdaten-Felder
- Basis-CRUD Operationen
- Tab-Navigation
- Filter und Suche

**⚠️ Funktioniert teilweise:**
- Objekte-Tab (nur Tabelle)
- Aufträge-Tab (nur Tabelle)
- Zusatzdateien (Upload OK, Anzeige unvollständig)

**❌ Funktioniert nicht:**
- Alle Subformulare
- Ansprechpartner-Liste
- Angebote-Tab
- PLZ-Autocomplete
- Feld-Validierungen
- Daten-Kaskade vollständig

### 14.2 Code-Qualität
**Score:** 7/10

- ✅ Sauberer, lesbarer Code
- ✅ Moderne JavaScript-Syntax
- ⚠️ Keine Modularisierung
- ⚠️ Kein Caching
- ❌ Keine Tests

### 14.3 Access-Parität
**Score:** 6/10

- ✅ UI-Design sehr ähnlich
- ✅ Basis-Funktionen vorhanden
- ❌ Subformulare fehlen komplett
- ❌ Erweiterte Features fehlen

### 14.4 Empfehlung
**DRINGEND ERFORDERLICH:**
1. Subformulare implementieren (KRITISCH)
2. Daten-Kaskade vervollständigen (HOCH)
3. PLZ-Autocomplete (MITTEL)
4. Validierungen hinzufügen (MITTEL)

**Geschätzter Gesamt-Aufwand:** 10-15 Arbeitstage

---

## 15. ANHANG

### 15.1 Alle Controls im Formular

**Header:**
- `btnAktualisieren` - Daten neu laden
- `btnVerrechnungssaetze` - Navigation
- `btnUmsatzauswertung` - Navigation
- `btnNeuKunde` - Neuen Kunden anlegen
- `btnLoeschen` - Kunde löschen
- `btnSpeichern` - Änderungen speichern
- `kdNr` - Kunden-Nummer (readonly)

**Rechtes Panel:**
- `chkNurAktive` - Filter Checkbox
- `searchInput` - Suchfeld
- `kundenTable` - Kunden-Liste

**Tab "Stammdaten":**
- `kun_IstAktiv` - Checkbox
- `kun_IstSammelRechnung` - Checkbox
- `kun_ans_manuell` - Checkbox
- `kun_Firma` - Text
- `kun_bezeichnung` - Text
- `kun_Matchcode` - Text
- `kun_Strasse` - Text
- `kun_PLZ` - Text
- `kun_Ort` - Text
- `kun_LKZ` - Dropdown
- `kun_telefon` - Text
- `kun_mobil` - Text
- `kun_telefax` - Text
- `kun_email` - Email
- `kun_URL` - Text
- `kun_kreditinstitut` - Text
- `kun_blz` - Text
- `kun_kontonummer` - Text
- `kun_iban` - Text
- `kun_bic` - Text
- `kun_ustidnr` - Text
- `kun_Zahlbed` - Dropdown

**Tab "Konditionen":**
- `kun_rabatt` - Number
- `kun_skonto` - Number
- `kun_skonto_tage` - Number

**Tab "Ansprechpartner":**
- `kun_AP_Name` - Text
- `kun_AP_Position` - Text
- `kun_AP_Telefon` - Text
- `kun_AP_Email` - Email

**Tab "Bemerkungen":**
- `kun_Anschreiben` - Textarea
- `kun_BriefKopf` - Textarea
- `kun_memo` - Textarea

**Status Bar:**
- `lblRecordInfo` - Datensatz-Info
- `lblStatus` - Status-Text
- `erstelltAm` - Erstellt-Datum
- `erstelltVon` - Erstellt-Von
- `geaendertAm` - Geändert-Datum
- `geaendertVon` - Geändert-Von

### 15.2 Verwendete Bridge-Events

**Bridge.loadData():**
- `('kunden', null, { aktiv: bool })` - Liste laden
- `('kunde', kdId)` - Einzelner Kunde
- `('objekte', null, { kunde_id })` - Objekte
- `('auftraege', null, { kunde_id, von, bis })` - Aufträge

**Bridge.sendEvent():**
- `('save', { type, id, data })` - Speichern
- `('delete', { type, id })` - Löschen
- `('minimize')` - Fenster minimieren

**Bridge.navigate():**
- `(formName, id)` - Zu anderem Formular
- `(formName, params)` - Mit Parametern

**Bridge.on():**
- `('onDataReceived', callback)` - Daten empfangen
- `('onAuftraegeReceived', callback)` - Aufträge empfangen
- `('onObjekteReceived', callback)` - Objekte empfangen

### 15.3 Datei-Referenzen

**Externe Dateien:**
- `consys-common.css` (Zeile 670) - Gemeinsame Styles
- `../js/webview2-bridge.js` (Zeile 1041) - Bridge-API
- `../js/global-handlers.js` (Zeile 1043) - Globale Handler

**Verwandte Formulare:**
- `frm_KD_Verrechnungssaetze` - Verrechnungssätze
- `frm_KD_Umsatzauswertung` - Umsatzauswertung
- `frm_OB_Objekt` - Objekt-Formular
- `frm_va_Auftragstamm` - Auftrags-Formular

---

**Report Ende**
**Erstellt:** 2026-01-03
**Nächste Prüfung:** Nach Implementierung der Subformulare
