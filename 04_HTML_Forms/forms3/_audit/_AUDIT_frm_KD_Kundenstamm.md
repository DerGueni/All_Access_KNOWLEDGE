# AUDIT: frm_KD_Kundenstamm - HTML vs Access Original

**Erstellt:** 2026-01-05
**Quellen:**
- Access VBA: `exports/vba/forms/Form_frm_KD_Kundenstamm.bas`
- Access JSON: `11_json_Export/000_Consys_Eport_11_25/30_forms/FRM_frm_KD_Kundenstamm.json`
- HTML: `04_HTML_Forms/forms3/frm_KD_Kundenstamm.html`
- Logic: `04_HTML_Forms/forms3/logic/frm_KD_Kundenstamm.logic.js`

---

## 1. CONTROL-MAPPING TABELLE

### 1.1 Stammdaten-Felder (pgMain Tab)

| Access Control | Access Type | HTML ID | HTML Type | Status |
|---------------|-------------|---------|-----------|--------|
| kun_ID | TextBox | kdNr / kun_Id | input (readonly) | OK |
| kun_firma | TextBox | kun_Firma | input | OK |
| kun_bezeichnung | TextBox | kun_bezeichnung | input | OK |
| kun_Matchcode | TextBox | kun_Matchcode | input | OK |
| kun_strasse | TextBox | kun_Strasse | input | OK |
| kun_plz | TextBox | kun_PLZ | input | OK |
| kun_ort | TextBox | kun_Ort | input | OK |
| kun_LKZ | ComboBox | kun_LKZ | select | OK |
| kun_telefon | TextBox | kun_telefon | input | OK |
| kun_mobil | TextBox | kun_mobil | input | OK |
| kun_telefax | TextBox | kun_telefax | input | OK |
| kun_email | TextBox | kun_email | input | OK |
| kun_URL | TextBox | kun_URL | input | OK |
| kun_IstAktiv | CheckBox | kun_IstAktiv | checkbox | OK |
| kun_IstSammelRechnung | CheckBox | kun_IstSammelRechnung | checkbox | OK |
| kun_ans_manuell | CheckBox | kun_ans_manuell | checkbox | OK |
| kun_AdressArt | ComboBox | - | - | FEHLT |
| kun_land_vorwahl | TextBox | - | - | FEHLT |
| kun_geloescht | TextBox | - | - | FEHLT |
| kun_IDF_PersonID | ComboBox | - | - | FEHLT - Wichtig! |

### 1.2 Bankdaten

| Access Control | Access Type | HTML ID | HTML Type | Status |
|---------------|-------------|---------|-----------|--------|
| kun_kreditinstitut | TextBox | kun_kreditinstitut | input | OK |
| kun_blz | TextBox | kun_blz | input | OK |
| kun_kontonummer | TextBox | kun_kontonummer | input | OK |
| kun_iban | TextBox | kun_iban | input | OK |
| kun_bic | TextBox | kun_bic | input | OK |
| kun_ustidnr | TextBox | kun_ustidnr | input | OK |
| kun_Zahlbed | ComboBox | kun_Zahlbed | select | OK |

### 1.3 Kontaktdaten (aus Ansprechpartner)

| Access Control | Access Type | HTML ID | HTML Type | Status |
|---------------|-------------|---------|-----------|--------|
| adr_telefon | TextBox | adr_Tel | input | NAMENSABWEICHUNG |
| adr_mobil | TextBox | adr_Handy | input | NAMENSABWEICHUNG |
| adr_eMail | TextBox | adr_eMail | input | OK |
| Anschreiben | TextBox | kun_Anschreiben | textarea | OK |

### 1.4 Tabs (RegStammKunde)

| Access Tab | Access Name | HTML Tab | Status |
|-----------|-------------|----------|--------|
| pgMain | Stammdaten | tab-stammdaten | OK |
| pgPreise | Kundenpreise | - | FEHLT - sub_KD_Standardpreise |
| Auftragsübersicht | Aufträge | tab-auftragübersicht | OK |
| pg_Rch_Kopf | Rechnungskopf | - | FEHLT |
| pg_Ang | Angebote | tab-angebote | OK (leer) |
| pgAttach | Zusatzdateien | tab-zusatzdateien | OK |
| pgAnsprech | Ansprechpartner | tab-ansprechpartner | OK |
| pgBemerk | Bemerkungen | tab-bemerkungen | OK |
| - | - | tab-objekte | NEU (nicht in Access) |
| - | - | tab-konditionen | NEU (nicht in Access) |

### 1.5 Navigation/Such-Controls

| Access Control | Access Type | HTML ID | Status |
|---------------|-------------|---------|--------|
| lst_KD | ListBox | kundenTable/kundenBody | OK - als Tabelle |
| Textschnell | ComboBox | searchInput | TEILWEISE - nur Textsuche |
| cboKDNrSuche | ComboBox | - | FEHLT |
| cboSuchPLZ | ComboBox | cboSuchPLZ | OK |
| cboSuchOrt | ComboBox | cboSuchOrt | OK |
| cbo_Auswahl | ComboBox | - | FEHLT |
| cboSuchSuchF | ComboBox (Sortfeld) | - | FEHLT |
| NurAktiveKD | CheckBox | chkNurAktive | OK |

### 1.6 Buttons

| Access Control | Access Type | HTML ID/onclick | Status |
|---------------|-------------|-----------------|--------|
| Befehl39 | CommandButton | gotoFirstRecord() | OK |
| Befehl40 | CommandButton | gotoPrevRecord() | OK |
| Befehl41 | CommandButton | gotoNextRecord() | OK |
| Befehl43 | CommandButton | gotoLastRecord() | OK |
| Befehl46 | CommandButton | neuerKunde() | OK |
| mcobtnDelete | CommandButton | kundeLöschen() | OK (anderer Name) |
| Befehl38 | CommandButton (Close) | closeForm() | OK |
| btnAlle | CommandButton | resetAuswahlfilter() | OK |
| btnAuswertung | CommandButton | openVerrechnungssaetze() | OK (anderer Name) |
| btnUmsAuswert | CommandButton | openUmsatzauswertung() | OK |
| btnOutlook | CommandButton | openOutlook() | OK |
| btnWord | CommandButton | openWord() | OK |
| btnNeuAttach | CommandButton | dateiHinzufuegen() | OK |
| btnAufRchPDF | CommandButton | openRechnungPDF() | OK |
| btnAufRchPosPDF | CommandButton | openBerechnungslistePDF() | OK |
| btnAufEinsPDF | CommandButton | openEinsatzlistePDF() | OK |
| btnDate | CommandButton | activateDatumsfilter() | OK |
| btnAuftrag | CommandButton | openNeuerAuftrag() | OK |
| btnRibbonAus | CommandButton | - | FEHLT |
| btnRibbonEin | CommandButton | - | FEHLT |
| btnDaBaEin | CommandButton | - | FEHLT |
| btnDaBaAus | CommandButton | - | FEHLT |
| btnPersonUebernehmen | CommandButton | personUebernehmen() | OK |

### 1.7 Subformulare

| Access Subform | Source | HTML Implementation | Status |
|---------------|--------|---------------------|--------|
| sub_KD_Standardpreise | qry_KD_Standardpreise | - | FEHLT |
| sub_KD_Auftragskopf | qry_KD_Auftragskopf | auftraegeTable | TEILWEISE |
| sub_KD_Rch_Auftragspos | - | - | FEHLT |
| sub_ZusatzDateien | - | dateienTable | TEILWEISE |
| sub_Ansprechpartner | tbl_KD_Ansprechpartner | ansprechpartnerTable | OK |
| sub_Rch_Kopf_Ang | - | - | FEHLT |
| Menü | - | - | ENTFERNT (Sidebar stattdessen) |

### 1.8 Statistik-Felder (pg_Rch_Kopf)

| Access Control | HTML ID | Status |
|---------------|---------|--------|
| KD_Ges | KD_Ges | OK |
| KD_VJ | KD_VJ | OK |
| KD_LJ | KD_LJ | OK |
| KD_LM | KD_LM | OK |
| AufAnz1/2/3 | - | FEHLT |
| PersGes1/2/3 | - | FEHLT |
| StdGes1/2/3 | - | FEHLT |
| UmsGes1/2/3 | - | FEHLT |
| UmsNGes1/2/3 | - | FEHLT |
| Std51/52/53 bis Std71/72/73 | - | FEHLT |
| Pers51/52/53 bis Pers71/72/73 | - | FEHLT |
| PosGesamtsumme | - | FEHLT |

### 1.9 Audit-Felder

| Access Control | HTML ID | Status |
|---------------|---------|--------|
| Erst_am | erstelltAm | OK |
| Erst_von | erstelltVon | OK |
| Aend_am | geaendertAm | OK |
| Aend_von | geaendertVon | OK |

---

## 2. EVENT-HANDLER MAPPING

### 2.1 Form Events

| VBA Event | HTML Implementation | Status |
|-----------|---------------------|--------|
| Form_Load | DOMContentLoaded + init | OK |
| Form_Current | showRecord() + loadKundeData() | OK |
| Form_BeforeUpdate | setÄnderungsdaten() | TEILWEISE |
| Form_AfterUpdate | - | FEHLT |
| Form_Close | closeForm() | OK |

### 2.2 Control Events

| VBA Event | HTML Implementation | Status |
|-----------|---------------------|--------|
| lst_KD_Click | kundenBody tr.onclick | OK |
| Textschnell_AfterUpdate | searchInput.oninput + renderKundenList | TEILWEISE |
| cboKDNrSuche_AfterUpdate | - | FEHLT |
| cboSuchOrt_AfterUpdate | filterByOrt() | OK |
| cboSuchPLZ_AfterUpdate | filterByPLZ() | OK |
| cboSuchSuchF_AfterUpdate | - | FEHLT |
| cbo_Auswahl_AfterUpdate | - | FEHLT |
| NurAktiveKD_AfterUpdate | chkNurAktive.onchange -> loadKunden() | OK |
| IstAlle_AfterUpdate | toggleAlleAnzeigen() | OK |
| kun_IstAktiv_AfterUpdate | onKunIstAktivChange() -> speichern() | OK |
| kun_IDF_PersonID_AfterUpdate | - | FEHLT |
| kun_AdressArt_DblClick | openAdressartDialog() | OK |
| RegStammKunde_Change | switchTab() | OK |
| IstAuftragsrt_AfterUpdate | filterAuftragsart() | OK |
| AuftrBemerk_Exit | - | FEHLT |
| BrfBemerk_Exit | - | FEHLT |

### 2.3 Button Events

| VBA Event | HTML Implementation | Status |
|-----------|---------------------|--------|
| Befehl38_Click (Close) | closeForm() | OK |
| Befehl46_Click (Neu) | neuerKunde() | OK |
| btnAlle_Click | resetAuswahlfilter() | OK |
| btnAuftrag_Click | openNeuerAuftrag() | OK |
| btnOutlook_Click | openOutlook() | OK |
| btnWord_Click | openWord() | OK |
| btnAuswertung_Click | openVerrechnungssaetze() | OK |
| btnUmsAuswert_Click | openUmsatzauswertung() | OK |
| btnNeuAttach_Click | dateiHinzufuegen() | OK |
| btnAufRchPDF_Click | openRechnungPDF() | OK |
| btnAufRchPosPDF_Click | openBerechnungslistePDF() | OK |
| btnAufEinsPDF_Click | openEinsatzlistePDF() | OK |
| btnDate_Click | activateDatumsfilter() | OK |
| btnPersonUebernehmen_Click | personUebernehmen() | OK |
| btnRibbonAus_Click | - | FEHLT (Nicht relevant) |
| btnRibbonEin_Click | - | FEHLT (Nicht relevant) |
| btnDaBaAus_Click | - | FEHLT (Nicht relevant) |
| btnDaBaEin_Click | - | FEHLT (Nicht relevant) |

### 2.4 Spezielle Funktionen

| VBA Funktion | HTML Implementation | Status |
|-------------|---------------------|--------|
| Standardleistungen_anlegen | standardleistungenAnlegen() | STUB vorhanden |
| fReadDoc | openRechnungPDF/openBerechnungslistePDF/openEinsatzlistePDF | OK |
| Kopf_Berech | loadKundenStatistik() | STUB vorhanden |

---

## 3. FEHLENDE FUNKTIONEN

### 3.1 Kritisch (Business-Logik)

1. **sub_KD_Standardpreise / Kundenpreise-Tab (pgPreise)**
   - Fehlt komplett
   - Access verwendet Subform `sub_KD_Standardpreise`
   - VBA: `Standardleistungen_anlegen()` legt automatisch Standard-Preisarten an
   - Tabelle: `tbl_KD_Preise` mit Preisart_ID (1=Sicherheit, 3=Leitung, 4=Fahrt, 5=Sonstiges, 11-13=Zuschläge)

2. **kun_IDF_PersonID (Hauptansprechpartner ComboBox)**
   - Fehlt komplett
   - Access: Dropdown zur Auswahl des Hauptansprechpartners
   - AfterUpdate füllt adr_telefon, adr_mobil, adr_eMail, Anschreiben

3. **pg_Rch_Kopf Tab (Rechnungsstatistik)**
   - Alle Statistik-Felder fehlen (AufAnz, PersGes, StdGes, UmsGes, etc.)
   - VBA: `Kopf_Berech()` berechnet umfangreiche Statistiken

4. **sub_KD_Auftragskopf / sub_KD_Rch_Auftragspos**
   - Auftragsübersicht nur als einfache Tabelle
   - Detailansicht (Positionen) fehlt

5. **cboSuchSuchF (Sortfeld-Filter)**
   - Filter nach kun_Sortfeld fehlt

### 3.2 Mittel (Komfort-Funktionen)

6. **cboKDNrSuche (Direktsuche nach Kundennummer)**
   - Schnellsuche nach kun_ID fehlt

7. **cbo_Auswahl (Anzeigeoptionen)**
   - Spaltenauswahl für Kundenliste (Telefon, Email, Umsatz) fehlt

8. **kun_AdressArt**
   - ComboBox für Adressart (Haupt-/Neben-/Lieferadresse) fehlt

9. **Anschreiben / Briefkopf Automatik**
   - kun_ans_manuell=False -> automatische Briefkopf-Generierung
   - Funktion AdrUpd() ist in Access auskommentiert

### 3.3 Niedrig (Access-spezifisch)

10. **Ribbon/Datenbank Ein/Aus Buttons**
    - Access-spezifische UI-Kontrolle
    - Nicht relevant für HTML

11. **AuftrBemerk_Exit / BrfBemerk_Exit**
    - Synchronisierung mit Subform
    - Bei Subform-Implementierung nachzuziehen

---

## 4. KORREKTURVORSCHLÄGE

### 4.1 Priorität HOCH

#### A) Kundenpreise-Tab hinzufügen
```html
<!-- Neuer Tab nach "Stammdaten" -->
<button class="tab-btn" data-tab="kundenpreise">Kundenpreise</button>

<!-- Tab Content -->
<div class="tab-page" id="tab-kundenpreise">
    <table class="data-grid" id="kundenpreiseTable">
        <thead>
            <tr>
                <th>Preisart</th>
                <th>Preis/Std</th>
                <th>Min. Stunden</th>
                <th>Pauschale</th>
            </tr>
        </thead>
        <tbody id="kundenpreiseBody"></tbody>
    </table>
</div>
```

#### B) Hauptansprechpartner-ComboBox
```html
<!-- Im Stammdaten-Tab hinzufügen -->
<div class="form-row">
    <span class="form-label">Hauptansprechpartner:</span>
    <select class="form-select" id="kun_IDF_PersonID" data-field="kun_IDF_PersonID" style="width: 200px;">
        <option value="">-- Bitte wählen --</option>
    </select>
</div>
```

```javascript
// Nach Ansprechpartner-Laden die ComboBox füllen
function fillHauptansprechpartnerCombo(ansprechpartner) {
    const combo = document.getElementById('kun_IDF_PersonID');
    combo.innerHTML = '<option value="">-- Bitte wählen --</option>';
    ansprechpartner.forEach(ap => {
        const opt = document.createElement('option');
        opt.value = ap.adr_ID;
        opt.textContent = `${ap.adr_Nachname || ''}, ${ap.adr_Vorname || ''}`;
        combo.appendChild(opt);
    });
}

// AfterUpdate Event
document.getElementById('kun_IDF_PersonID').addEventListener('change', function() {
    const selectedId = this.value;
    const ap = ansprechpartnerList.find(a => a.adr_ID == selectedId);
    if (ap) {
        // Kontaktfelder füllen wie in VBA
        document.getElementById('adr_Tel').value = ap.adr_Tel || '';
        document.getElementById('adr_Handy').value = ap.adr_Handy || '';
        document.getElementById('adr_eMail').value = ap.adr_eMail || '';
        document.getElementById('kun_Anschreiben').value = ap.adr_Anschreiben || '';
    }
});
```

#### C) kun_AdressArt ComboBox
```html
<div class="form-row">
    <span class="form-label">Adressart:</span>
    <select class="form-select" id="kun_AdressArt" data-field="kun_AdressArt"
            ondblclick="openAdressartDialog()" style="width: 150px;">
        <option value="1">Hauptadresse</option>
        <option value="2">Lieferadresse</option>
        <option value="3">Rechnungsadresse</option>
    </select>
</div>
```

### 4.2 Priorität MITTEL

#### D) Statistik-Felder im Auftragsübersicht-Tab erweitern
```html
<!-- Erweiterte Statistik-Box -->
<div style="display: flex; gap: 15px; margin-bottom: 10px; padding: 5px; background: #a0a0c0;">
    <div><span style="font-size: 9px;">Gesamt:</span><br>
        <span id="KD_Ges" style="font-weight: bold;">0,00 EUR</span></div>
    <div><span style="font-size: 9px;">Vorjahr:</span><br>
        <span id="KD_VJ" style="font-weight: bold;">0,00 EUR</span></div>
    <div><span style="font-size: 9px;">Lfd. Jahr:</span><br>
        <span id="KD_LJ" style="font-weight: bold;">0,00 EUR</span></div>
    <div><span style="font-size: 9px;">Akt. Monat:</span><br>
        <span id="KD_LM" style="font-weight: bold;">0,00 EUR</span></div>
    <div><span style="font-size: 9px;">Aufträge:</span><br>
        <span id="AufAnz" style="font-weight: bold;">0</span></div>
    <div><span style="font-size: 9px;">Personaltage:</span><br>
        <span id="PersGes" style="font-weight: bold;">0</span></div>
    <div><span style="font-size: 9px;">Stunden gesamt:</span><br>
        <span id="StdGes" style="font-weight: bold;">0</span></div>
</div>
```

#### E) cboKDNrSuche hinzufügen
```html
<!-- Im Search-Header -->
<div class="search-box">
    <label>Kd-Nr:</label>
    <input type="number" id="cboKDNrSuche" style="width: 70px;"
           onchange="searchByKdNr(this.value)">
</div>
```

```javascript
function searchByKdNr(kdNr) {
    if (!kdNr) return;
    const index = state.kundenList.findIndex(k => k.kun_Id == kdNr);
    if (index >= 0) {
        showRecord(index);
    } else {
        showToast('Kunde nicht gefunden', 'warning');
    }
}
```

### 4.3 Priorität NIEDRIG

#### F) cbo_Auswahl für Spaltenauswahl
```html
<select id="cbo_Auswahl" onchange="changeListColumns(this.value)">
    <option value="1">Standard (Telefon)</option>
    <option value="2">E-Mail</option>
    <option value="3">Umsatz</option>
</select>
```

---

## 5. ZUSAMMENFASSUNG

### Vollständigkeit: ca. 75%

| Bereich | Vorhanden | Fehlt | Prozent |
|---------|-----------|-------|---------|
| Stammdaten-Felder | 28 | 3 | 90% |
| Bankdaten | 7 | 0 | 100% |
| Tabs | 6 | 2 | 75% |
| Buttons | 18 | 4 | 82% |
| Event-Handler | 25 | 6 | 81% |
| Subformulare | 2 | 4 | 33% |
| Statistik-Felder | 4 | 28 | 13% |

### Kritische Lücken:
1. **Kundenpreise-Verwaltung** - Business-kritisch
2. **Hauptansprechpartner-Auswahl** - Wichtig für Workflow
3. **Rechnungsstatistik (pg_Rch_Kopf)** - Wichtig für Controlling

### Empfehlung:
Die HTML-Implementation deckt die Kernfunktionalität gut ab. Für eine vollständige Nachbildung sollten die Kundenpreise-Verwaltung und die Hauptansprechpartner-ComboBox prioritär implementiert werden.

---

*Audit durchgeführt am 2026-01-05*
