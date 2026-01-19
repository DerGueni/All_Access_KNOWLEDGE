# AUDIT: frm_MA_Mitarbeiterstamm
## HTML-Formular-Pruefung gegen Access-Original

**Datum:** 2026-01-05
**Geprueft:** HTML-Formular, Logic-Datei, Access VBA, Access JSON-Export

---

## 1. ZUSAMMENFASSUNG

| Kategorie | Access | HTML | Status |
|-----------|--------|------|--------|
| Buttons (CommandButton) | 41 | ~25 | TEILWEISE |
| Textfelder (TextBox) | 70 | ~35 | TEILWEISE |
| Checkboxen | 12 | ~15 | OK |
| Comboboxen | 17 | ~8 | LUECKENHAFT |
| Listboxen | 7 | 1 | LUECKENHAFT |
| Subformulare | 13 | 6 (iframes) | TEILWEISE |
| Tabs/Seiten | 13 | 15 | OK |
| Event-Handler | 54 | ~20 | LUECKENHAFT |

**Gesamtstatus:** Ca. 60-70% Abdeckung - Kernfunktionalitaet vorhanden, Details fehlen

---

## 2. BUTTONS - Detailvergleich

### Access Buttons (aus JSON)

| Access-Name | Sichtbar | HTML vorhanden | HTML-ID | Status |
|-------------|----------|----------------|---------|--------|
| Befehl39 | Ja | Ja | btnErste | OK - Navigation |
| Befehl40 | Ja | Ja | btnVorige | OK - Navigation |
| Befehl41 | Ja | Ja | btnNaechste | OK - Navigation |
| Befehl43 | Ja | Ja | btnLetzte | OK - Navigation |
| Befehl46 | Ja | Ja | btnSpeichern | OK |
| mcobtnDelete | Ja | Ja | btnLoeschen | OK |
| btnLstDruck | Ja | Ja | btnListenDrucken | OK |
| btnMADienstpl | Nein | Nein | - | OK (unsichtbar) |
| btnRibbonAus | Ja | Nein | - | FEHLT |
| btnRibbonEin | Ja | Nein | - | FEHLT |
| btnDaBaEin | Ja | Nein | - | FEHLT |
| btnDaBaAus | Ja | Nein | - | FEHLT |
| lbl_Mitarbeitertabelle | Ja | Ja | btnMATabelle | OK |
| btnZeitkonto | Ja | Ja | btnZeitkonto | OK |
| btnZKFest | Ja | Ja | btnEinsaetzeFA | OK |
| btnZKMini | Ja | Ja | btnEinsaetzeMJ | OK |
| btnDateisuch | Ja | Nein | - | FEHLT - Foto-Suche |
| btnDateisuch2 | Ja | Nein | - | FEHLT - Signatur-Suche |
| btnMaps | Ja | Ja | btnMapsOeffnen | OK |
| btnZuAb | Ja | Nein | - | FEHLT - Zu-/Abschlaege |
| btnXLZeitkto | Ja | Nein | - | FEHLT - Excel Export |
| btnLesen | Ja | Ja | btnAktualisieren | OK |
| btnUpdJahr | Ja | Nein | - | FEHLT |
| btnXLJahr | Ja | Nein | - | FEHLT - Excel Export |
| btnXLEinsUeber | Nein | Nein | - | OK (unsichtbar) |
| btnZKeinzel | Ja | Nein | - | FEHLT |
| Bericht_drucken | Ja | Nein | - | FEHLT |
| btnAU_Lesen | Ja | Ja (implizit) | - | OK - via Tab-Wechsel |
| btnRch | Nein | Nein | - | OK (unsichtbar) |
| btnCalc | Ja | Nein | - | FEHLT - Stundenberechnung |
| btnXLUeberhangStd | Nein | Nein | - | OK (unsichtbar) |
| btnau_lesen2 | Ja | Nein | - | FEHLT |
| btnAUPl_Lesen | Ja | Nein | - | FEHLT |
| btn_Diensplan_prnt | Ja | Nein | - | FEHLT - Dienstplan drucken |
| btn_Dienstplan_send | Ja | Nein | - | FEHLT - Dienstplan senden |
| btnXLDiePl | Nein | Nein | - | OK (unsichtbar) |
| btnMehrfachtermine | Ja | Nein | - | FEHLT |
| btnXLNverfueg | Nein | Nein | - | OK (unsichtbar) |
| btnReport_Dienstkleidung | Ja | Nein | - | FEHLT |
| btn_MA_EinlesVorlageDatei | Ja | Nein | - | FEHLT |
| btnXLVordrucke | Ja | Nein | - | FEHLT |

### Zusaetzliche HTML-Buttons (nicht in Access)

| HTML-ID | Funktion | Status |
|---------|----------|--------|
| btnMAAdressen | MA Adressen oeffnen | ZUSATZ |
| btnDienstplan | Dienstplan oeffnen | ZUSATZ |
| btnEinsatzuebersicht | Einsatzuebersicht | ZUSATZ |
| fullscreenBtn | Vollbild-Toggle | ZUSATZ |

---

## 3. FELDER (TextBox) - Detailvergleich

### Personalien

| Access-Feld | HTML-ID | data-field | Status |
|-------------|---------|------------|--------|
| PersNr | ID | ID | OK |
| LEXWare_ID | LEXWare_ID | LEXWare_ID | OK |
| Nachname | Nachname | Nachname | OK |
| Vorname | Vorname | Vorname | OK |
| Strasse | Strasse | Strasse | OK |
| Nr | Nr | Nr | OK |
| PLZ | PLZ | PLZ | OK |
| Ort | Ort | Ort | OK |
| Land | Land | Land | OK |
| Bundesland | Bundesland | Bundesland | OK |
| Tel_Mobil | Tel_Mobil | Tel_Mobil | OK |
| Tel_Festnetz | Tel_Festnetz | Tel_Festnetz | OK |
| Email | Email | Email | OK |
| Geschlecht | Geschlecht | Geschlecht | OK |
| Staatsang | Staatsang | Staatsang | OK |
| Geb_Dat | Geb_Dat | Geb_Dat | OK |
| Geb_Ort | Geb_Ort | Geb_Ort | OK |
| Geb_Name | Geb_Name | Geb_Name | OK |

### Beschaeftigung

| Access-Feld | HTML-ID | data-field | Status |
|-------------|---------|------------|--------|
| Eintrittsdatum | Eintrittsdatum | Eintrittsdatum | OK |
| Austrittsdatum | Austrittsdatum | Austrittsdatum | OK |
| Anstellungsart (Combo) | Anstellungsart_ID | Anstellungsart_ID | OK |
| Kostenstelle | - | - | FEHLT |
| DienstausweisNr | DienstausweisNr | DienstausweisNr | OK |
| Ausweis_Endedatum | - | - | FEHLT |
| Ausweis_Funktion | - | - | FEHLT |
| Epin_DFB | Epin_DFB | Epin_DFB | OK |
| Bewacher_ID | Bewacher_ID | Bewacher_ID | OK |

### Bankdaten

| Access-Feld | HTML-ID | data-field | Status |
|-------------|---------|------------|--------|
| Kontoinhaber | Kontoinhaber | Kontoinhaber | OK |
| BIC | BIC | BIC | OK |
| IBAN | IBAN | IBAN | OK |
| Bankname | - | - | FEHLT |
| Bankleitzahl | - | - | FEHLT |
| Kontonummer | - | - | FEHLT |
| Auszahlungsart | - | - | FEHLT |

### Steuern/Soziales

| Access-Feld | HTML-ID | data-field | Status |
|-------------|---------|------------|--------|
| SteuerNr | SteuerNr | SteuerNr | OK |
| Steuerklasse | Steuerklasse | Steuerklasse | OK |
| KV_Kasse | KV_Kasse | KV_Kasse | OK |
| Sozialvers_Nr | - | - | FEHLT |

### Arbeitszeit

| Access-Feld | HTML-ID | data-field | Status |
|-------------|---------|------------|--------|
| Arbst_pro_Arbeitstag | - | - | FEHLT |
| Arbeitstage_pro_Woche | - | - | FEHLT |
| Resturl_Vorjahr | - | - | FEHLT |
| Urlaubsanspr_pro_Jahr | Urlaubsanspr_pro_Jahr | Urlaubsanspr_pro_Jahr | OK |
| StundenZahlMax | StundenZahlMax | StundenZahlMax | OK |
| Kosten_pro_MAStunde | - | - | FEHLT |

### Sonstige fehlende Felder

| Access-Feld | Beschreibung | Status |
|-------------|--------------|--------|
| tblBilddatei | Foto-Dateiname | FEHLT - nur Anzeige |
| tblSignaturdatei | Signatur-Dateiname | FEHLT |
| Bemerkungen | Bemerkungsfeld | FEHLT |
| Amt_Pruefung | Behoerde | FEHLT |
| Datum_Pruefung | Pruefungsdatum | FEHLT |
| Datum_34a | 34a Datum | FEHLT |
| Briefkopf | Briefkopf-Text | OK (Tab) |
| Anr | Anrede | FEHLT |
| Anr_Brief | Brief-Anrede | FEHLT |
| Anr_eMail | Email-Anrede | FEHLT |

---

## 4. CHECKBOXEN

| Access-Feld | HTML-ID | Status |
|-------------|---------|--------|
| IstAktiv | IstAktiv | OK |
| IstSubunternehmer | Subunternehmer | OK |
| Eigener_PKW | Hat_EigenerPKW | OK |
| Ist_RV_Befrantrag | Ist_RV_Befrantrag | OK |
| IstNSB | IstNSB | OK |
| Hat_keine_34a | - | FEHLT |
| HatSachkunde | Sachkunde_34a | OK |
| Lex_Aktiv | Lex_Aktiv | OK |
| cbMailAbrech | eMail_Abrechnung | OK |
| Modul1_DFB | DFB_Modul_1 | OK |
| TermineAbHeute | - | FEHLT |
| IstBrfAuto | - | FEHLT |

### Zusaetzliche HTML-Checkboxen

| HTML-ID | Funktion | Status |
|---------|----------|--------|
| Hat_Fahrerausweis | Fahrerausweis | ZUSATZ |
| Unterweisungs_34a | Unterweisung 34a | ZUSATZ |

---

## 5. TABS/REGISTERKARTEN

### Access-Tabs (reg_MA)

| Access-Page | HTML-Tab | Status |
|-------------|----------|--------|
| pgAdresse | tab-stammdaten | OK |
| pgMonat | tab-zeitkonto | TEILWEISE |
| pgJahr | tab-jahresuebersicht | OK |
| pgAuftrUeb | tab-einsatzuebersicht | OK |
| pgStundenuebersicht | tab-stundenuebersicht | OK |
| pgPlan | tab-dienstplan | OK |
| pgnVerfueg | tab-nichtverfuegbar | OK |
| pgDienstKl | tab-dienstkleidung | OK |
| pgVordr | tab-vordrucke | OK |
| pgBrief | tab-briefkopf | OK |
| pgStdUeberlaufstd | tab-ueberhangstunden | OK |
| pgMaps | tab-karte | OK |
| pgSubRech | tab-subrechnungen | OK |

### Zusaetzliche HTML-Tabs

| HTML-Tab | Funktion | Status |
|----------|----------|--------|
| tab-qualifikationen | Qualifikationen | ZUSATZ |
| tab-dokumente | Dokumente | ZUSATZ |

---

## 6. SUBFORMULARE

| Access-Subform | HTML-Umsetzung | Status |
|----------------|----------------|--------|
| Menu | Sidebar-Navigation | ANDERS |
| sub_MA_ErsatzEmail | - | FEHLT |
| sub_MA_Einsatz_Zuo | Tabelle in Tab | TEILWEISE |
| sub_tbl_MA_Zeitkonto_Aktmon1 | iframe sub_MA_Zeitkonto.html | OK |
| sub_tbl_MA_Zeitkonto_Aktmon2 | iframe sub_MA_Zeitkonto.html | OK |
| frmStundenübersicht | iframe sub_MA_Stundenuebersicht.html | OK |
| sub_MA_tbl_MA_NVerfuegZeiten | Tabelle in Tab | OK |
| sub_MA_Dienstkleidung | Tabelle in Tab | OK |
| sub_tbltmp_MA_Ausgef_Vorlagen | - | FEHLT |
| Untergeordnet360 | - | FEHLT |
| ufrm_Maps | Google Maps Link | ANDERS |
| subAuftragRech | iframe sub_MA_Rechnungen.html | OK |
| subZuoStunden | - | FEHLT |

---

## 7. EVENT-HANDLER

### VBA-Events vs. HTML/JS

| VBA-Event | HTML-Implementierung | Status |
|-----------|---------------------|--------|
| Form_Load | DOMContentLoaded | OK |
| Form_Open | init() | OK |
| Form_Current | showRecord() | OK |
| Form_BeforeUpdate | Form_BeforeUpdate() | OK |
| Form_AfterUpdate | Form_AfterUpdate() | OK |
| lst_MA_Click | renderMitarbeiterList() onClick | OK |
| Anstellungsart_AfterUpdate | Anstellungsart_AfterUpdate() | OK |
| IstSubunternehmer_AfterUpdate | IstSubunternehmer_AfterUpdate() | OK |
| cboZeitraum_AfterUpdate | StdZeitraum_Von_Bis() | TEILWEISE |
| reg_MA_Change | switchTab() | OK |

### Fehlende Event-Handler

| VBA-Event | Beschreibung | Status |
|-----------|--------------|--------|
| btnZeitkonto_Click | Excel-Zeitkonto oeffnen | TEILWEISE |
| btnZKFest_Click | Zeitkonten Festangestellte | FEHLT |
| btnZKMini_Click | Zeitkonten Minijobber | FEHLT |
| btnZKeinzel_Click | Einzelnes Zeitkonto | FEHLT |
| btnCalc_Click | Stundenberechnung | FEHLT |
| btnMaps_Click | Google Maps oeffnen | OK |
| btnDateisuch_Click | Foto-Datei suchen | FEHLT |
| btnDateisuch2_Click | Signatur suchen | FEHLT |
| cboFilterAuftrag_AfterUpdate | Auftragsfilter | FEHLT |
| Mon_Ausw | Monatsauswahl | FEHLT |
| calc_brutto_std | Bruttostunden | FEHLT |
| calc_netto_std | Nettostunden | FEHLT |
| Adresse_Upd | Adresse aktualisieren | FEHLT |
| TermineAbHeute_AfterUpdate | NVerfueg-Filter | FEHLT |

---

## 8. BERECHNUNGEN & BUSINESS-LOGIK

### Implementiert

- Anstellungsart-Logik (IstNSB, IstSubunternehmer, StundenZahlMax)
- Zeitraum-Berechnung (StdZeitraum_Von_Bis)
- Form_BeforeUpdate (Aend_am, Aend_von)

### Fehlend

| Funktion | VBA-Code | Status |
|----------|----------|--------|
| calc_brutto_std() | Bruttostunden berechnen | FEHLT |
| calc_netto_std() | Nettostunden berechnen | FEHLT |
| calc_DienstKL() | Dienstkleidung Gesamtwert | FEHLT |
| Ueberlaufstd_Berech_Neu() | Ueberhangstunden | FEHLT |
| ZK_Daten_uebertragen() | Zeitkonto-Transfer | FEHLT |
| Dienstplan_senden() | Email-Versand | FEHLT |

---

## 9. FOTO-UPLOAD FUNKTION

### Access
- btnDateisuch - Oeffnet FileDialog fuer Foto
- btnDateisuch2 - Oeffnet FileDialog fuer Signatur
- Bild wird in MA_Bild.Picture geladen
- Pfad: prp_CONSYS_GrundPfad + tblEigeneFirma_Pfade(7)

### HTML
- Foto wird in photo-frame angezeigt
- Kein Upload-Dialog
- Kein Signatur-Upload
- **Status: LUECKENHAFT**

---

## 10. KORREKTURVORSCHLAEGE

### Prioritaet 1 (Kritisch)

1. **Foto-Upload hinzufuegen**
   - Button "btnDateisuch" mit FileDialog-Funktion
   - Signatur-Upload ebenfalls
   - Bridge.sendEvent('uploadPhoto', { ma_id, type: 'foto' })

2. **Fehlende Felder ergaenzen**
   - Bankname, Bankleitzahl, Kontonummer
   - Kostenstelle
   - Sozialvers_Nr
   - Bemerkungen (grosses Textfeld)

3. **Excel-Export-Buttons**
   - btnXLZeitkto - Zeitkonto exportieren
   - btnXLJahr - Jahresuebersicht exportieren
   - Bridge.sendEvent('export', { type: 'excel', query: '...' })

### Prioritaet 2 (Wichtig)

4. **Berechnungsfunktionen**
   - calc_brutto_std() in JS implementieren
   - calc_netto_std() in JS implementieren
   - Anzeige im Tab "Einsatzuebersicht"

5. **Comboboxen vervollstaendigen**
   - cboMonat, cboJahr fuer Zeitkonto-Tab
   - cboFilterAuftrag fuer Auftragsfilter
   - cboAuswahl fuer Listenansicht

6. **Dienstplan-Funktionen**
   - btn_Diensplan_prnt - Drucken
   - btn_Dienstplan_send - Email senden

### Prioritaet 3 (Optional)

7. **Ribbon/Database-Buttons**
   - btnRibbonAus/Ein - Access-spezifisch, ggf. weglassen
   - btnDaBaAus/Ein - Access-spezifisch, ggf. weglassen

8. **Mehrfachtermine**
   - btnMehrfachtermine - Formular frmTop_MA_Abwesenheitsplanung

9. **Reports**
   - btnReport_Dienstkleidung
   - Bericht_drucken

---

## 11. FEHLENDE SUBFORMULARE

| Subform | Empfehlung |
|---------|------------|
| sub_MA_ErsatzEmail | Als Modal-Dialog implementieren |
| sub_tbltmp_MA_Ausgef_Vorlagen | In Vordrucke-Tab integrieren |
| subZuoStunden | In Stundenuebersicht integrieren |

---

## 12. JAVASCRIPT-LOGIC BEWERTUNG

Die Datei `frm_MA_Mitarbeiterstamm.logic.js` ist vorhanden und enthaelt:

**Vorhanden:**
- State-Management (records, currentIndex, isDirty)
- Navigation (gotoRecord, navFirst, navPrev, navNext, navLast)
- CRUD-Operationen (loadList, saveRecord, deleteRecord)
- Suche (searchRecords)
- API-Anbindung (Bridge.mitarbeiter.*)

**Fehlend:**
- Zeitraum-Logik (cboZeitraum_AfterUpdate vollstaendig)
- Berechnungen (calc_brutto_std, calc_netto_std)
- Excel-Export-Funktionen
- Foto-Upload-Logik
- Subformular-Kommunikation fuer alle Tabs

---

## 13. GESAMTBEWERTUNG

| Aspekt | Bewertung | Anmerkung |
|--------|-----------|-----------|
| Grundstruktur | 85% | Tabs, Layout, Navigation gut |
| Stammdaten-Felder | 70% | Wichtigste vorhanden |
| Buttons | 55% | Viele Excel/Report-Buttons fehlen |
| Event-Handler | 50% | Basis vorhanden, Details fehlen |
| Berechnungen | 30% | Nur Anstellungsart-Logik |
| Subformulare | 60% | iframes vorhanden, Inhalt variiert |
| Foto-Funktion | 40% | Anzeige ja, Upload nein |

**Gesamt: ca. 60%** - Formular ist funktional fuer Basis-Operationen, aber fuer vollstaendigen Betrieb muessen noch erhebliche Funktionen ergaenzt werden.

---

## 14. NAECHSTE SCHRITTE

1. [ ] Foto-Upload implementieren
2. [ ] Fehlende Stammdaten-Felder ergaenzen
3. [ ] Berechnungsfunktionen portieren
4. [ ] Excel-Export via Bridge implementieren
5. [ ] Monats-/Jahresauswahl fuer Zeitkonto-Tab
6. [ ] Subformular-Dateien pruefen (sub_MA_*.html)
7. [ ] Report-Funktionen via Bridge anbinden
