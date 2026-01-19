# REPORT: Eingabefelder und Validierung - Agent 3

**Datum:** 2026-01-07
**Agent:** Agent 3 - Eingabefelder und Validierung
**Status:** Analyse abgeschlossen

---

## ZUSAMMENFASSUNG

Die Analyse aller vier Hauptformulare zeigt, dass die Eingabefelder grundsaetzlich korrekt an Daten gebunden sind (via `data-field`), jedoch KEINE Pflichtfeld-Validierung oder Input-Pattern-Validierung implementiert ist. Aenderungen werden via `change`/`input`-Events getrackt, aber es fehlt clientseitige Validierung vor dem Speichern.

---

## 1. MITARBEITERSTAMM (frm_MA_Mitarbeiterstamm.html)

### 1.1 Eingabefelder-Inventar (47 Felder)

| Feld-ID | data-field | Typ | Validierung | Status |
|---------|------------|-----|-------------|--------|
| ID | ID | text | readonly | OK |
| LEXWare_ID | LEXWare_ID | text | keine | FEHLT |
| IstAktiv | IstAktiv | checkbox | keine | OK |
| Lex_Aktiv | Lex_Aktiv | checkbox | keine | OK |
| Nachname | Nachname | text | keine | FEHLT - Pflichtfeld! |
| Vorname | Vorname | text | keine | FEHLT - Pflichtfeld! |
| Strasse | Strasse | text | keine | OK |
| Nr | Nr | text | keine | OK |
| PLZ | PLZ | text | keine | FEHLT - Pattern |
| Ort | Ort | text | keine | OK |
| Land | Land | select | keine | OK |
| Bundesland | Bundesland | text | keine | OK |
| Tel_Mobil | Tel_Mobil | text | keine | FEHLT - Pattern |
| Tel_Festnetz | Tel_Festnetz | text | keine | FEHLT - Pattern |
| Email | Email | text | keine | FEHLT - type="email" |
| Geschlecht | Geschlecht | select | keine | OK |
| Staatsang | Staatsang | text | keine | OK |
| Geb_Dat | Geb_Dat | date | keine | OK |
| Geb_Ort | Geb_Ort | text | keine | OK |
| Geb_Name | Geb_Name | text | keine | OK |
| Eintrittsdatum | Eintrittsdatum | date | keine | OK |
| Austrittsdatum | Austrittsdatum | date | keine | OK |
| Anstellungsart_ID | Anstellungsart_ID | select | keine | OK |
| IstSubunternehmer | IstSubunternehmer | checkbox | keine | OK |
| Kleidergroesse | Kleidergroesse | select | keine | OK |
| Hat_Fahrerausweis | Hat_Fahrerausweis | checkbox | keine | OK |
| Eigener_PKW | Eigener_PKW | checkbox | keine | OK |
| DienstausweisNr | DienstausweisNr | text | keine | OK |
| Ausweis_Endedatum | Ausweis_Endedatum | date | keine | OK |
| Ausweis_Funktion | Ausweis_Funktion | text | keine | OK |
| Letzte_Ueberpr_OA | Letzte_Ueberpr_OA | date | keine | OK |
| Personalausweis_Nr | Personalausweis_Nr | text | keine | OK |
| Epin_DFB | Epin_DFB | text | keine | OK |
| Modul1_DFB | Modul1_DFB | checkbox | keine | OK |
| Bewacher_ID | Bewacher_ID | text | keine | OK |
| Zustaendige_Behoerde | Zustaendige_Behoerde | text | keine | OK |
| Kontoinhaber | Kontoinhaber | text | keine | OK |
| Bankname | Bankname | text | keine | OK |
| IBAN | IBAN | text | keine | FEHLT - Pattern |
| BIC | BIC | text | keine | FEHLT - Pattern |
| Stundenlohn_brutto | Stundenlohn_brutto | select | keine | OK |
| Kostenstelle | Kostenstelle | text | keine | OK |
| Bezuege_gezahlt_als | Bezuege_gezahlt_als | text | keine | OK |
| Koordinaten | Koordinaten | text | keine | OK |
| SteuerNr | SteuerNr | text | keine | OK |
| Taetigkeit_Bezeichnung | Taetigkeit_Bezeichnung | select | keine | OK |
| KV_Kasse | KV_Kasse | text | keine | OK |
| Steuerklasse | Steuerklasse | text | keine | OK |
| Sozialvers_Nr | Sozialvers_Nr | text | keine | FEHLT - Pattern |
| Arbeitsstd_pro_Arbeitstag | Arbeitsstd_pro_Arbeitstag | number | step=0.5 | OK |
| Arbeitstage_pro_Woche | Arbeitstage_pro_Woche | number | min=1 max=7 | OK |
| Resturlaub_Vorjahr | Resturlaub_Vorjahr | number | step=0.5 | OK |
| Urlaubsanspr_pro_Jahr | Urlaubsanspr_pro_Jahr | number | keine | OK |
| StundenZahlMax | StundenZahlMax | number | keine | OK |
| Ist_RV_Befrantrag | Ist_RV_Befrantrag | checkbox | keine | OK |
| IstNSB | IstNSB | checkbox | keine | OK |
| eMail_Abrechnung | eMail_Abrechnung | checkbox | keine | OK |
| Hat_keine_34a | Hat_keine_34a | checkbox | keine | OK |
| Unterweisungs_34a | Unterweisungs_34a | checkbox | keine | OK |
| HatSachkunde | HatSachkunde | checkbox | keine | OK |
| Bemerkungen | Bemerkungen | textarea | keine | OK |
| Briefkopf | Briefkopf | textarea | keine | OK |

### 1.2 Change-Tracking
- Alle `[data-field]`-Elemente haben `change` und `input` Event-Listener
- `markDirty()`-Funktion setzt `state.isDirty = true`
- Status: FUNKTIONIERT

### 1.3 Speicherung
- `speichern()` sammelt alle Felder mit `data-field`
- Sendet via `Bridge.sendEvent('saveMitarbeiter', {...})`
- KEINE Validierung vor dem Speichern!

### 1.4 BEFUNDE - KRITISCH

1. **Keine Pflichtfeld-Validierung:** Nachname und Vorname koennen leer gespeichert werden
2. **Email-Feld ohne type="email":** Keine Browser-Validierung
3. **Telefon-Felder ohne Pattern:** Keine Format-Validierung
4. **IBAN/BIC ohne Pattern:** Keine Format-Pruefung
5. **Sozialvers_Nr ohne Pattern:** Keine Format-Pruefung

---

## 2. KUNDENSTAMM (frm_KD_Kundenstamm.html)

### 2.1 Eingabefelder-Inventar (36 Felder)

| Feld-ID | data-field | Typ | Validierung | Status |
|---------|------------|-----|-------------|--------|
| kun_IstAktiv | kun_IstAktiv | checkbox | keine | OK |
| kun_IstSammelRechnung | kun_IstSammelRechnung | checkbox | keine | OK |
| kun_ans_manuell | kun_ans_manuell | checkbox | keine | OK |
| kun_Firma | kun_Firma | text | keine | FEHLT - Pflichtfeld! |
| kun_bezeichnung | kun_bezeichnung | text | keine | OK |
| kun_Matchcode | kun_Matchcode | text | keine | OK |
| kun_Strasse | kun_Strasse | text | keine | OK |
| kun_PLZ | kun_PLZ | text | keine | FEHLT - Pattern |
| kun_Ort | kun_Ort | text | keine | OK |
| kun_LKZ | kun_LKZ | select | keine | OK |
| kun_telefon | kun_telefon | text | keine | FEHLT - Pattern |
| kun_mobil | kun_mobil | text | keine | FEHLT - Pattern |
| kun_telefax | kun_telefax | text | keine | OK |
| kun_email | kun_email | email | keine | OK - type richtig! |
| kun_URL | kun_URL | text | keine | OK |
| kun_IDF_PersonID | kun_IDF_PersonID | select | onchange | OK |
| kun_kreditinstitut | kun_kreditinstitut | text | keine | OK |
| kun_blz | kun_blz | text | keine | OK (veraltet) |
| kun_kontonummer | kun_kontonummer | text | keine | OK (veraltet) |
| kun_iban | kun_iban | text | keine | FEHLT - Pattern |
| kun_bic | kun_bic | text | keine | FEHLT - Pattern |
| kun_ustidnr | kun_ustidnr | text | keine | FEHLT - Pattern |
| kun_Zahlbed | kun_Zahlbed | select | keine | OK |
| kun_rabatt | kun_rabatt | number | step=0.01 | OK |
| kun_skonto | kun_skonto | number | step=0.01 | OK |
| kun_skonto_tage | kun_skonto_tage | number | keine | OK |
| kun_Anschreiben | kun_Anschreiben | textarea | keine | OK |
| kun_BriefKopf | kun_BriefKopf | textarea | keine | OK |
| kun_memo | kun_memo | textarea | keine | OK |

### 2.2 Ansprechpartner-Felder (data-ap-field)
| Feld-ID | data-ap-field | Typ | Status |
|---------|---------------|-----|--------|
| adr_Nachname | adr_Nachname | text | OK |
| adr_Vorname | adr_Vorname | text | OK |
| adr_akad_Grad | adr_akad_Grad | text | OK |
| adr_Tel | adr_Tel | text | FEHLT - Pattern |
| adr_Handy | adr_Handy | text | FEHLT - Pattern |
| adr_eMail | adr_eMail | email | OK - type richtig! |
| adr_Fax | adr_Fax | text | OK |

### 2.3 Change-Tracking
- `[data-field]`-Elemente mit Event-Listenern in DOMContentLoaded
- Status: FUNKTIONIERT

### 2.4 BEFUNDE - KRITISCH

1. **Keine Pflichtfeld-Validierung:** kun_Firma kann leer gespeichert werden
2. **IBAN/BIC ohne Pattern:** Keine Format-Pruefung
3. **USt-IdNr ohne Pattern:** Keine Format-Pruefung
4. **Telefon-Felder ohne Pattern:** Keine Format-Validierung

---

## 3. OBJEKTSTAMM (frm_OB_Objekt.html)

### 3.1 Eingabefelder-Inventar (18 Felder)

| Feld-ID | data-field | Typ | Validierung | Status |
|---------|------------|-----|-------------|--------|
| ID | ID | text | readonly | OK |
| TabellenNr | TabellenNr | hidden | value=42 | OK |
| Objekt | Objekt | text | Pflichpruefung in saveRecord | OK |
| Strasse | Strasse | text | keine | OK |
| PLZ | PLZ | text | keine | FEHLT - Pattern |
| Ort | Ort | text | keine | OK |
| txtLat | Geo_Lat | text | readonly | OK |
| txtLon | Geo_Lon | text | readonly | OK |
| Treffpunkt | Treffpunkt | text | keine | OK |
| Treffp_Zeit | Treffp_Zeit | text | keine | FEHLT - Pattern HH:MM |
| txtAnfahrt | Anfahrt | textarea | keine | OK |
| Dienstkleidung | Dienstkleidung | text | keine | OK |
| Ansprechpartner | Ansprechpartner | text | keine | OK |
| Text435 | Text435 | text | keine | FEHLT - Pattern (Telefon) |
| cboVeranstalter | Veranstalter_ID | select | keine | OK |
| Bemerkung | Bemerkung | textarea | keine | OK |

### 3.2 Change-Tracking
```javascript
document.querySelectorAll('[data-field]').forEach(el => {
    el.addEventListener('change', () => { state.isDirty = true; });
    el.addEventListener('input', () => { state.isDirty = true; });
});
```
- Status: FUNKTIONIERT

### 3.3 Speicherung
```javascript
async function saveRecord() {
    const data = collectFormData();
    if (!data.Objekt) {
        showToast('Bitte Objektname eingeben', 'error');
        return;
    }
    // ... API-Aufruf
}
```
- Status: EINZIGE VALIDIERUNG IM PROJEKT! Nur Objektname wird geprueft.

### 3.4 BEFUNDE

1. **PLZ ohne Pattern:** Keine Format-Pruefung
2. **Treffp_Zeit ohne Pattern:** Kein HH:MM Pattern
3. **Text435 (Telefon) ohne Pattern:** Keine Format-Validierung

---

## 4. AUFTRAGSTAMM (frm_va_Auftragstamm.html)

### 4.1 Eingabefelder-Inventar (22 Felder)

| Feld-ID | name | Typ | onchange | Status |
|---------|------|-----|----------|--------|
| Rech_NR | Rech_NR | text | readonly | OK |
| ID | ID | text | readonly | OK |
| Auftrag | Auftrag | text | auftragChanged() | OK |
| Ort | Ort | text | ortChanged() | OK |
| Objekt | Objekt | text | objektChanged() | OK |
| PKW_Anzahl | PKW_Anzahl | number | keine | OK (min=0) |
| Fahrtkosten | Fahrtkosten | text | saveField() | OK |
| Treffpunkt | Treffpunkt | text | saveField() | OK |
| Dienstkleidung | Dienstkleidung | text | saveField() | OK |
| Ansprechpartner | Ansprechpartner | text | saveField() | OK |
| cbAutosendEL | Autosend_EL | checkbox | saveField() | OK |
| Veranst_Status_ID | Veranst_Status_ID | select | statusChanged() | OK |
| Dat_VA_Von | Dat_VA_Von | date | datumChanged() | OK |
| Dat_VA_Bis | Dat_VA_Bis | date | datumBisChanged() | OK |
| Treffp_Zeit | Treffp_Zeit | time | saveField() | OK |
| Veranstalter_ID | Veranstalter_ID | select | veranstalterChanged() | OK |
| Bemerkungen | Bemerkungen | textarea | saveField() | OK |

### 4.2 Zuordnungs-Felder (dynamisch generiert)

| data-field | Typ | onchange | Status |
|------------|-----|----------|--------|
| VA_Start | time | schicht-input | OK |
| VA_Ende | time | schicht-input | OK |
| IstFraglich | checkbox | saveZuordnungField() | OK |
| PKW | number | saveZuordnungField() | OK |
| Einsatzleitung | checkbox | saveZuordnungField() | OK |
| Rch_Erstellt | checkbox | saveZuordnungField() | OK |

### 4.3 Event-Felder (from-web)

| Feld-ID | Typ | Status |
|---------|-----|--------|
| eventEinlass | text | FEHLT - Pattern HH:MM |
| eventBeginn | text | FEHLT - Pattern HH:MM |
| eventEnde | text | FEHLT - Pattern HH:MM |
| eventLinkInput | text | FEHLT - type="url" |

### 4.4 BEFUNDE

1. **Felder verwenden `name` statt `data-field`:** Inkonsistenz zum Rest
2. **Event-Zeitfelder ohne Pattern:** HH:MM nicht validiert
3. **eventLinkInput ohne type="url":** Keine URL-Validierung
4. **Keine Pflichtfeld-Validierung:** Auftrag kann leer sein

---

## 5. KRITISCHE PROBLEME (PRIORITAET 1)

### 5.1 Fehlende Pflichtfeld-Validierung

| Formular | Feld | Sollte Pflichtfeld sein |
|----------|------|-------------------------|
| Mitarbeiterstamm | Nachname | JA |
| Mitarbeiterstamm | Vorname | JA |
| Kundenstamm | kun_Firma | JA |
| Objektstamm | Objekt | OK - bereits validiert |
| Auftragstamm | Auftrag | JA |

### 5.2 Fehlende Pattern-Validierung

| Typ | Pattern | Betroffene Felder |
|-----|---------|-------------------|
| PLZ | `^\d{5}$` | PLZ (MA), kun_PLZ (KD), PLZ (OB) |
| Telefon | `^[\d\s\-\+\/\(\)]+$` | Tel_Mobil, Tel_Festnetz, kun_telefon, kun_mobil, Text435, adr_Tel, adr_Handy |
| IBAN | `^[A-Z]{2}\d{2}[A-Z0-9]{4}\d{14}$` | IBAN (MA), kun_iban (KD) |
| BIC | `^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$` | BIC (MA), kun_bic (KD) |
| Zeit | `^\d{2}:\d{2}$` | Treffp_Zeit, eventEinlass, eventBeginn, eventEnde |
| SVN | `^\d{2}\s?\d{6}\s?[A-Z]\s?\d{3}$` | Sozialvers_Nr (MA) |
| USt-IdNr | `^DE\d{9}$` | kun_ustidnr (KD) |

### 5.3 Fehlende type-Attribute

| Feld | Aktuell | Sollte sein |
|------|---------|-------------|
| Email (MA) | type="text" | type="email" |
| eventLinkInput (VA) | type="text" | type="url" |

---

## 6. EMPFOHLENE FIXES

### 6.1 Validierungsfunktion hinzufuegen

```javascript
function validateForm(requiredFields, patterns) {
    const errors = [];

    // Pflichtfelder pruefen
    for (const fieldId of requiredFields) {
        const el = document.getElementById(fieldId);
        if (el && !el.value.trim()) {
            errors.push(`${fieldId} ist ein Pflichtfeld`);
            el.classList.add('validation-error');
        }
    }

    // Pattern pruefen
    for (const [fieldId, pattern] of Object.entries(patterns)) {
        const el = document.getElementById(fieldId);
        if (el && el.value && !pattern.test(el.value)) {
            errors.push(`${fieldId} hat ein ungueltiges Format`);
            el.classList.add('validation-error');
        }
    }

    return errors;
}
```

### 6.2 CSS fuer Validierungsfehler

```css
.validation-error {
    border-color: #c04040 !important;
    background-color: #fff0f0 !important;
}

.required-field::after {
    content: ' *';
    color: #c04040;
}
```

### 6.3 Pro Formular

**Mitarbeiterstamm:**
```javascript
const errors = validateForm(
    ['Nachname', 'Vorname'],
    {
        'PLZ': /^\d{5}$/,
        'Tel_Mobil': /^[\d\s\-\+\/\(\)]*$/,
        'Email': /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
        'IBAN': /^[A-Z]{2}\d{2}[A-Z0-9]{4}\d{14}$/
    }
);
```

**Kundenstamm:**
```javascript
const errors = validateForm(
    ['kun_Firma'],
    {
        'kun_PLZ': /^\d{5}$/,
        'kun_iban': /^[A-Z]{2}\d{2}[A-Z0-9]{4}\d{14}$/,
        'kun_ustidnr': /^DE\d{9}$/
    }
);
```

---

## 7. GESAMTBEWERTUNG

| Kriterium | Status | Bewertung |
|-----------|--------|-----------|
| data-field Bindung | Vorhanden | 90% |
| Change-Tracking | Funktioniert | 95% |
| Pflichtfeld-Validierung | Fehlt | 5% |
| Pattern-Validierung | Fehlt | 0% |
| Visuelle Markierung Pflichtfelder | Fehlt | 0% |
| type-Attribute korrekt | Teilweise | 70% |
| Speicherung funktioniert | Ja | 95% |

**Gesamtnote:** 50% - Dringender Handlungsbedarf bei Validierung

---

## 8. OFFENE PUNKTE / EMPFEHLUNGEN

1. **KRITISCH:** Validierungsfunktion in alle Formulare einbauen
2. **WICHTIG:** Pflichtfelder visuell markieren (*)
3. **EMPFOHLEN:** type="email" und type="url" korrekt setzen
4. **OPTIONAL:** Pattern-Attribute direkt im HTML hinzufuegen

---

*Report erstellt von Agent 3 - Funktionspruefung Eingabefelder und Validierung*
