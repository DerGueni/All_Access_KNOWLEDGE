# AUDIT: frm_va_Auftragstamm - HTML vs Access

**Datum:** 2026-01-05
**Pruefung durch:** Claude Code
**Access-Quelle:** Form_frm_VA_Auftragstamm.bas + FRM_frm_VA_Auftragstamm.json
**HTML-Ziel:** frm_va_Auftragstamm.html + frm_va_Auftragstamm.logic.js

---

## 1. ZUSAMMENFASSUNG

| Kategorie | Access | HTML | Status |
|-----------|--------|------|--------|
| Buttons (CommandButton) | 45 | 25 | UNVOLLSTAENDIG |
| TextBoxes | 19 | 15 | UNVOLLSTAENDIG |
| ComboBoxes | 13 | 6 | UNVOLLSTAENDIG |
| Subformulare | 10 | 0 (inline) | ANDERS UMGESETZT |
| CheckBoxes | 2 | 1 | UNVOLLSTAENDIG |
| TabPages | 5 | 5 | OK |

---

## 2. BUTTONS - Detailvergleich

### 2.1 Vorhandene Buttons (OK)

| Access-Control | HTML-Control | Event-Handler | Status |
|----------------|--------------|---------------|--------|
| btnSchnellPlan | btnSchnellPlan | OnClick | OK |
| btnMailEins | btnMailEins | OnClick | OK |
| btnMailSub | btnMailSub | OnClick | OK |
| btnDatumLeft | btnDatumLeft | OnClick | OK |
| btnDatumRight | btnDatumRight | OnClick | OK |
| btnDruckZusage | btnDruckZusage | OnClick | OK |
| btnNeuAttach | btnNeuAttach (implizit) | OnClick | OK |
| btnSyncErr | (via Rueckmeldestatistik-Link) | OnClick | UMBENANNT |
| btn_ListeStd | btnListeStd | OnClick | OK |
| mcobtnDelete | btnLoeschen | OnClick | UMBENANNT |
| Befehl640 | btnKopieren | OnClick | UMBENANNT |
| btn_Autosend_BOS | btnMailBOS | OnClick | UMBENANNT |

### 2.2 FEHLENDE Buttons (KRITISCH)

| Access-Control | VBA-Event | Funktion | Prioritaet |
|----------------|-----------|----------|------------|
| **btnAuftrBerech** | OnClick | Auftrag berechnen / Rechnung oeffnen | HOCH |
| **btnDruckZusage1** | OnClick | Zusage drucken (Variante) | MITTEL |
| **btn_Posliste_oeffnen** | OnClick | Objektpositionen oeffnen | HOCH |
| **btnmailpos** | OnClick | Positionen per Mail senden | MITTEL |
| **btn_Rueckmeld** | OnClick | Rueckmeldeauswertung oeffnen | MITTEL |
| **btn_VA_Abwesenheiten** | OnClick | Abwesenheitsuebersicht oeffnen | MITTEL |
| **btnVAPlanCrea** | OnClick | VA-Planung erstellen | HOCH |
| **btnPlan_Kopie** | OnClick | Planung kopieren | MITTEL |
| **btnPDFKopf** | OnClick | Rechnungskopf PDF | NIEDRIG |
| **btnPDFPos** | OnClick | Rechnungspositionen PDF | NIEDRIG |
| **btnHeute** | OnClick | Filter auf heute setzen | MITTEL |
| **btnTgVor** | OnClick | Filter 7 Tage vor | MITTEL |
| **btnTgBack** | OnClick | Filter 7 Tage zurueck | MITTEL |
| **btn_AbWann** | OnClick | Filter anwenden | MITTEL |
| **btnReq** | OnClick | Aktualisieren/Requery | HOCH |
| **btnRibbonAus** | OnClick | Ribbon ausblenden | NIEDRIG |
| **btnRibbonEin** | OnClick | Ribbon einblenden | NIEDRIG |
| **btnDaBaAus** | OnClick | Datenbank-Navigation aus | NIEDRIG |
| **btnDaBaEin** | OnClick | Datenbank-Navigation ein | NIEDRIG |
| **btnneuveranst** | OnClick | Neuer Auftrag | HOCH |
| **btn_rueck** | OnClick | Aenderungen rueckgaengig | MITTEL |
| **cmd_Messezettel_NameEintragen** | OnClick | Messezettel-Namen eintragen | NIEDRIG |
| **cmd_BWN_send** | OnClick | Bewachungsnachweis senden | MITTEL |
| **Befehl709** | OnClick | Log Email Sent oeffnen | NIEDRIG |
| **Befehl38** | - | Formular schliessen | HOCH |
| **Befehl40/41/43** | - | Datensatz-Navigation | HOCH |
| **btn_letzer_Datensatz** | - | Letzter Datensatz | MITTEL |
| **btnCheck** | - | Pruefung (unbekannt) | NIEDRIG |
| **btn_Tag_loeschen** | - | Tag loeschen | NIEDRIG |
| **btn_aenderungsprotokoll** | - | Aenderungsprotokoll | NIEDRIG |
| **btnXLEinsLst** | OnClick | Excel-Einsatzliste exportieren | MITTEL |
| **Befehl658** | OnClick | PDF-Auftrag erstellen | MITTEL |

### 2.3 In Logic.js implementiert, aber HTML-Button fehlt

| Button-ID | Logic.js Funktion | HTML vorhanden |
|-----------|-------------------|----------------|
| Befehl43 | gotoRecord(0) | NEIN |
| Befehl41 | gotoRecord(-1) | NEIN |
| Befehl40 | gotoRecord(+1) | NEIN |
| btn_letzer_Datensatz | gotoRecord(last) | NEIN |
| btn_rueck | undoChanges | NEIN |
| Befehl38 | closeForm | NEIN |
| btnReq | requeryAll | NEIN |
| btn_AbWann | applyAuftraegeFilter | NEIN |
| btnTgBack | shiftAuftraegeFilter(-7) | NEIN |
| btnTgVor | shiftAuftraegeFilter(7) | NEIN |
| btnHeute | setAuftraegeFilterToday | NEIN |
| btn_Posliste_oeffnen | openPositionen | btnPositionen (umbenannt) |
| btnmailpos | openZusatzdateien | NEIN |
| btnneuveranst | neuerAuftrag | btnNeuAuftrag (umbenannt) |
| cmd_Messezettel_NameEintragen | cmdMessezettelNameEintragen | NEIN |
| cmd_BWN_send | cmdBWNSend | NEIN |
| btn_BWN_Druck | druckeBWN | NEIN |
| Befehl709 | markELGesendet | btnELGesendet (umbenannt) |
| btn_Rueckmeld | openRueckmeldeStatistik | NEIN |

---

## 3. TEXTBOXES - Detailvergleich

### 3.1 Vorhandene TextBoxes (OK)

| Access-Control | HTML-Control | Events | Status |
|----------------|--------------|--------|--------|
| ID | ID | - | OK |
| Dat_VA_Von | Dat_VA_Von | OnDblClick | OK (onchange) |
| Dat_VA_Bis | Dat_VA_Bis | OnDblClick, AfterUpdate | OK (onchange) |
| Treffp_Zeit | Treffp_Zeit | BeforeUpdate, GotFocus, KeyDown | TEILWEISE |
| Treffpunkt | Treffpunkt | GotFocus | OK |
| Ansprechpartner | Ansprechpartner | GotFocus | TEILWEISE |
| Bemerkungen | Bemerkungen | - | OK |
| PKW_Anzahl | PKW_Anzahl | - | OK |
| Rech_NR | Rech_NR | - | OK |
| PosGesamtsumme | PosGesamtsumme | - | OK |

### 3.2 FEHLENDE TextBoxes

| Access-Control | VBA-Events | Funktion | Prioritaet |
|----------------|------------|----------|------------|
| **Auftraege_ab** | OnDblClick | Datumsfilter Auftragsliste | HOCH |
| **PLZ** | - | Postleitzahl | NIEDRIG |
| **TabellenNr** | - | Tabellen-Referenz | NIEDRIG |
| **Text416** | BeforeUpdate | Erstellt von (Audit) | NIEDRIG |
| **Text418** | BeforeUpdate | Erstellt am (Audit) | NIEDRIG |
| **Text419** | BeforeUpdate | Geaendert von (Audit) | NIEDRIG |
| **Text422** | BeforeUpdate | Geaendert am (Audit) | NIEDRIG |
| **VerrSatz** | - | Verrechnungssatz | NIEDRIG |
| **lb_Fahrtkosten** | - | Fahrtkosten Anzeige | NIEDRIG |

### 3.3 Fehlende Events bei vorhandenen TextBoxes

| Control | Access-Event | HTML-Event | Status |
|---------|--------------|------------|--------|
| Treffp_Zeit | OnKeyDown | - | FEHLT (Zeitformat-Validierung) |
| Ansprechpartner | OnGotFocus | onfocus | FEHLT (Vorbelegung) |
| Dat_VA_Von | OnDblClick | - | FEHLT (Kalender-Popup) |
| Dat_VA_Bis | OnDblClick | - | FEHLT (Kalender-Popup) |

---

## 4. COMBOBOXES - Detailvergleich

### 4.1 Vorhandene ComboBoxes (OK)

| Access-Control | HTML-Control | Events | Status |
|----------------|--------------|--------|--------|
| Veranst_Status_ID | Veranst_Status_ID | DblClick, BeforeUpdate, AfterUpdate | OK |
| Objekt | Objekt (input+datalist) | DblClick, GotFocus | TEILWEISE |
| Objekt_ID | Objekt_ID | DblClick, AfterUpdate | OK |
| cboVADatum | cboVADatum | DblClick, AfterUpdate | OK |
| veranstalter_id | Veranstalter_ID | DblClick, AfterUpdate, GotFocus, KeyDown | TEILWEISE |
| Ort | Ort (input+datalist) | GotFocus | OK |
| Dienstkleidung | Dienstkleidung (input+datalist) | GotFocus | OK |

### 4.2 FEHLENDE ComboBoxes (KRITISCH)

| Access-Control | VBA-Events | Funktion | Prioritaet |
|----------------|------------|----------|------------|
| **Kombinationsfeld656** | - | Auftragsauswahl | HOCH |
| **cboEinsatzliste** | BeforeUpdate, AfterUpdate | Einsatzlisten-Filter | MITTEL |
| **cboAnstArt** | DblClick, AfterUpdate | Anstellungsart | MITTEL |
| **cboQuali** | - | Qualifikation | NIEDRIG |
| **cboID** | AfterUpdate | ID-Suche | MITTEL |
| **IstStatus** | AfterUpdate | Status-Filter | MITTEL |

### 4.3 Fehlende Events bei vorhandenen ComboBoxes

| Control | Access-Event | HTML-Event | Status |
|---------|--------------|------------|--------|
| veranstalter_id | OnKeyDown | - | FEHLT |
| Objekt | OnDblClick | ondblclick | OK |

---

## 5. SUBFORMULARE - Vergleich

### Access-Subformulare

| Name | Funktion |
|------|----------|
| frm_Menuefuehrung | Hauptmenue/Navigation |
| sub_VA_Start | Schichten/Einsatztage |
| sub_MA_VA_Zuordnung | MA-Zuordnung (Hauptliste) |
| sub_MA_VA_Planung_Absage | Absagen |
| sub_MA_VA_Zuordnung_Status | Planungsstatus |
| sub_ZusatzDateien | Attachments |
| sub_VA_Anzeige | Status-Anzeige |
| sub_tbl_Rch_Kopf | Rechnungskopf |
| sub_tbl_Rch_Pos_Auftrag | Rechnungspositionen |
| zsub_lstAuftrag | Auftragsliste |

### HTML-Umsetzung

Im HTML sind die Subformulare als **inline-Tabellen** umgesetzt:
- `gridSchichten` (entspricht sub_VA_Start)
- `gridZuordnungen` (entspricht sub_MA_VA_Zuordnung)
- `gridAbsagen` (entspricht sub_MA_VA_Planung_Absage)
- `gridStatus` (entspricht sub_MA_VA_Zuordnung_Status)
- `gridAttach` (entspricht sub_ZusatzDateien)
- `gridRechPos` (entspricht sub_tbl_Rch_Pos_Auftrag)
- `gridBerech` (Berechnungsliste)
- `auftraegeTable` (entspricht zsub_lstAuftrag)

**Bewertung:** Die Subformulare sind als HTML-Tabellen umgesetzt, aber die **PostMessage-Kommunikation** aus der Logic.js wird nicht verwendet, da keine separaten iframe-Subforms existieren.

---

## 6. EVENT-HANDLER - Vergleich

### 6.1 Form-Events

| Access-Event | VBA-Handler | HTML/JS-Implementierung | Status |
|--------------|-------------|-------------------------|--------|
| Form_Load | Ja | init() | OK |
| Form_Open | Ja | DOMContentLoaded | OK |
| Form_Current | Ja | loadAuftrag() | OK |
| Form_BeforeUpdate | Ja | - | FEHLT |
| Form_BeforeDelConfirm | Ja | - | FEHLT |

### 6.2 Feld-Events mit Vorbelegungslogik (GotFocus)

Die Access-VBA hat umfangreiche **Vorbelegungslogik** bei GotFocus:
- `Ort_GotFocus`: Vorbelegung aus letztem Auftrag + Fallwerte je nach Auftrag
- `Objekt_GotFocus`: Vorbelegung aus letztem Auftrag
- `Treffpunkt_GotFocus`: Vorbelegung je nach Objekt (z.B. "15 min vor DB")
- `Dienstkleidung_GotFocus`: Vorbelegung je nach Objekt
- `Treffp_Zeit_GotFocus`: Vorbelegung aus letztem Auftrag
- `Ansprechpartner_GotFocus`: Vorbelegung aus letztem Auftrag
- `veranstalter_id_GotFocus`: Vorbelegung aus letztem Auftrag

**Status im HTML:** Diese Logik ist **NICHT implementiert**. Es gibt zwar `onfocus`-Handler, aber die Vorbelegungslogik fehlt komplett.

### 6.3 Spezial-Logik

| Funktion | VBA-Implementierung | HTML-Status |
|----------|---------------------|-------------|
| Status-Herabsetzung bestaetigen | `Veranst_Status_ID_BeforeUpdate` | TEILWEISE (statusBeforeUpdate) |
| Spalten ausblenden bei Messe | `applyVeranstalterRules` | IN LOGIC.JS VORHANDEN |
| Buttons aktivieren/deaktivieren nach Status | `applyStatusRules` | IN LOGIC.JS VORHANDEN |
| MA-Sortierung | `fSort_MA` | FEHLT |
| Auftrag kopieren | `AuftragKopieren` | kopierenAuftrag() |
| Einsatzliste per Mail | `btnMailEins_Click` usw. | sendeEinsatzliste() |

---

## 7. FEHLENDE FUNKTIONEN - Priorisierte Liste

### HOHE Prioritaet

1. **Datensatz-Navigation** (Befehl40/41/43, btn_letzer_Datensatz)
   - Buttons im HTML fehlen
   - Logic.js hat die Funktionen

2. **Neuer Auftrag erstellen** (btnneuveranst)
   - Button existiert als "btnNeuAuftrag", ID stimmt nicht mit Logic.js ueberein

3. **Auftrag berechnen** (btnAuftrBerech)
   - Button und Funktion fehlen komplett

4. **Vorbelegungslogik bei Neueingabe**
   - GotFocus-Handler mit Vorschlaegen aus letztem Auftrag fehlen

5. **Auftraege_ab Filter-Feld**
   - Im Access: TextBox mit DblClick fuer Kalender
   - Im HTML: date-input vorhanden, aber ID ist `Auftraege_ab` (mit Umlaut)

6. **Formular schliessen** (Befehl38)
   - Button fehlt im HTML

### MITTLERE Prioritaet

7. **Absagen-Subform** funktioniert nicht korrekt
   - Daten werden nicht geladen

8. **cboEinsatzliste** (Filter fuer Einsatzlisten-Report)
   - ComboBox fehlt

9. **Rueckmeldung/Statistik** (btn_Rueckmeld)
   - Button fehlt, aber Link vorhanden

10. **BWN drucken/senden** (btn_BWN_Druck, cmd_BWN_send)
    - Buttons fehlen

### NIEDRIGE Prioritaet

11. Ribbon/DaBa-Toggle-Buttons
12. Aenderungsprotokoll
13. Excel-Export (btnXLEinsLst)
14. PDF-Erstellung (Befehl658)

---

## 8. KORREKTURVORSCHLAEGE

### 8.1 Button-IDs korrigieren (HTML)

```html
<!-- AENDERN: ID stimmt nicht mit Logic.js ueberein -->
<button class="btn" id="btnneuveranst" onclick="neuerAuftrag()">Neuer Auftrag</button>
<!-- statt: id="btnNeuAuftrag" -->

<button class="btn" id="btn_Posliste_oeffnen" onclick="openPositionen()">Positionen</button>
<!-- statt: id="btnPositionen" -->

<button class="btn" id="Befehl640" onclick="kopierenAuftrag()">Auftrag kopieren</button>
<!-- statt: id="btnKopieren" -->

<button class="btn" id="mcobtnDelete" onclick="loeschenAuftrag()">Auftrag loeschen</button>
<!-- statt: id="btnLoeschen" -->

<button class="btn" id="btn_Autosend_BOS" onclick="sendeEinsatzlisteBOS()">EL senden BOS</button>
<!-- statt: id="btnMailBOS" -->
```

### 8.2 Fehlende Navigations-Buttons hinzufuegen (HTML)

```html
<!-- Nach Header-Row hinzufuegen -->
<div class="nav-buttons" style="display: flex; gap: 5px;">
    <button class="btn" id="Befehl43" title="Erster Datensatz">|&#60;</button>
    <button class="btn" id="Befehl41" title="Vorheriger Datensatz">&#60;</button>
    <button class="btn" id="Befehl40" title="Naechster Datensatz">&#62;</button>
    <button class="btn" id="btn_letzer_Datensatz" title="Letzter Datensatz">&#62;|</button>
    <button class="btn" id="btn_rueck" title="Rueckgaengig">&#8617;</button>
    <button class="btn" id="Befehl38" title="Schliessen">X</button>
</div>
```

### 8.3 Fehlende Auftragsfilter-Buttons hinzufuegen (HTML)

```html
<!-- Im right-panel, date-nav Bereich -->
<button class="nav-btn" id="btnTgBack" onclick="tageZurueck()">&#60;&#60;</button>
<button class="nav-btn" id="btnTgVor" onclick="tageVor()">&#62;&#62;</button>
<button class="nav-btn" id="btnHeute" onclick="abHeute()">Heute</button>
<button class="nav-btn" id="btn_AbWann" onclick="filterAuftraege()">Go</button>
```

### 8.4 Fehlende Vorbelegungslogik (Logic.js)

```javascript
// Vorbelegung bei GotFocus - Beispiel fuer Ort
async function ortGotFocus() {
    const auftrag = document.getElementById('Auftrag')?.value;
    if (!auftrag || document.getElementById('Ort')?.value) return;

    try {
        const result = await Bridge.execute('getLastAuftragFields', {
            auftrag: auftrag,
            fields: ['Ort']
        });
        if (result.data?.Ort) {
            document.getElementById('Ort').value = result.data.Ort;
        }
    } catch (e) {
        console.warn('Vorbelegung Ort fehlgeschlagen:', e);
    }
}

// Spezial-Vorbelegung je nach Auftrag (aus VBA uebernommen)
function applyAuftragDefaults(auftrag) {
    const el = (id) => document.getElementById(id);
    const isEmpty = (id) => !el(id)?.value;

    if (auftrag?.startsWith('Kaufland')) {
        if (isEmpty('Treffpunkt')) el('Treffpunkt').value = '15 min vor Ort';
        if (isEmpty('Dienstkleidung')) el('Dienstkleidung').value = 'Schwarz neutral';
        if (isEmpty('Veranstalter_ID')) el('Veranstalter_ID').value = '20770';
    }
    else if (auftrag?.startsWith('Greuther ')) {
        if (isEmpty('Treffpunkt')) el('Treffpunkt').value = '15 min vor DB Tor F';
        if (isEmpty('Ort')) el('Ort').value = 'Fuerth';
        if (isEmpty('Objekt')) el('Objekt').value = 'Sportpark am Ronhof';
        if (isEmpty('Dienstkleidung')) el('Dienstkleidung').value = 'Schwarz neutral';
        if (isEmpty('Veranstalter_ID')) el('Veranstalter_ID').value = '20737';
    }
    else if (auftrag?.startsWith('1.FCN ')) {
        if (isEmpty('Ort')) el('Ort').value = 'Nuernberg';
        if (isEmpty('Objekt')) el('Objekt').value = 'Max-Morlock-Stadion';
        if (isEmpty('Treffpunkt')) el('Treffpunkt').value = '15 min vor DB Eingang Nord West';
        if (isEmpty('Dienstkleidung')) el('Dienstkleidung').value = 'Schwarz neutral';
        if (isEmpty('Veranstalter_ID')) el('Veranstalter_ID').value = '20771';
    }
    // ... weitere Faelle aus VBA uebernehmen
}
```

### 8.5 Fehlende Audit-Felder hinzufuegen (HTML)

```html
<!-- Status-Bar erweitern -->
<div class="status-bar">
    <span class="status-section">Erstellt:</span>
    <span class="status-section" id="Text416"></span>
    <span class="status-section" id="Text418"></span>
    <span class="status-section">Geaendert:</span>
    <span class="status-section" id="Text419"></span>
    <span class="status-section" id="Text422"></span>
</div>
```

### 8.6 Fehlende ComboBox cboEinsatzliste (HTML)

```html
<!-- Nach cbAutosendEL -->
<div class="checkbox-group">
    <label for="cboEinsatzliste">Report:</label>
    <select class="form-select" id="cboEinsatzliste" style="width: 120px;"
            onchange="cboEinsatzliste_AfterUpdate()">
        <option value="0">Aktueller Tag</option>
        <option value="-1">Alle Tage</option>
        <option value="1">Ab Heute</option>
        <option value="2">MA-Sortierung</option>
    </select>
</div>
```

---

## 9. SUBFORM-KOMMUNIKATION

Die Logic.js implementiert PostMessage-basierte Subform-Kommunikation, aber das HTML verwendet keine iframes. Die Kommunikation muss angepasst werden:

### Empfehlung: Inline-Handler statt PostMessage

```javascript
// Statt:
sendToSubform('sub_VA_Start', { type: 'requery' });

// Direkt:
async function requerySchichten() {
    const vaId = state.currentVA_ID;
    const result = await Bridge.execute('getSchichten', { VA_ID: vaId });
    renderSchichten(result.data || []);
}
```

---

## 10. ABSCHLIESSENDE BEWERTUNG

| Aspekt | Bewertung | Anmerkung |
|--------|-----------|-----------|
| Grundstruktur | 70% | Hauptbereiche vorhanden |
| Button-Vollstaendigkeit | 55% | 25 von 45 vorhanden |
| Feld-Vollstaendigkeit | 75% | Hauptfelder da, Details fehlen |
| Event-Handler | 40% | Viele GotFocus/Vorbelegung fehlen |
| Subformulare | 60% | Als Tabellen umgesetzt, PostMessage nicht nutzbar |
| Business-Logik | 50% | Grundfunktionen da, Speziallogik fehlt |

**Gesamtbewertung: 60% - UNVOLLSTAENDIG**

Die wichtigsten Nacharbeiten sind:
1. Button-IDs an Logic.js angleichen
2. Navigations-Buttons hinzufuegen
3. Vorbelegungslogik implementieren
4. Fehlende Buttons fuer Auftrag-Berechnung
5. Filter-Buttons fuer Auftragsliste

---

*Erstellt am: 2026-01-05*
*Quelle: Automatische Analyse durch Claude Code*
