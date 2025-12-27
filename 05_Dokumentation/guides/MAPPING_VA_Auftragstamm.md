# MAPPING: frm_VA_Auftragstamm → Web-Version

## ETAPPE 1: EXPORT-ANALYSE ABGESCHLOSSEN

---

## 1. FORMULAR-ÜBERSICHT

**Access-Name:** `frm_VA_Auftragstamm`
**Web-Name:** `frm_va_Auftragstamm.html`
**RecordSource:** `qry_Auftrag_Sort`

**Formular-Dimensionen:**
- InsideWidth: 23415 Twips → 1561 px
- InsideHeight: 14595 Twips → 973 px

**Formular-Properties:**
- AllowEdits: False
- AllowAdditions: False
- AllowDeletions: False
- DefaultView: Single Form (0)
- RecordLocks: Edited Record (2)

---

## 2. CONTROL-ANALYSE

**Gesamt: 145 Controls**

### 2.1 KOPFBEREICH (Navigation & Status)

| Control Name | Type | Position (L/T/W/H) | ControlSource | Events | Beschreibung |
|-------------|------|---------------------|---------------|--------|--------------|
| Auto_Kopfzeile0 | Label (100) | 1814/396/2928/375 | - | - | "Auftragsverwaltung" |
| lbl_Datum | Label (100) | 26430/390/1365/270 | - | - | Aktuelles Datum |
| lbl_Version | Label (100) | 26362/113/1533/315 | - | - | "GPT | TEST" |
| ID | TextBox (109) | 7117/119/615/329 | ID | - | Auftrags-Nr (read-only) |
| Veranst_Status_ID | ComboBox (111) | 24318/285/1710/330 | Veranst_Status_ID | OnDblClick, BeforeUpdate, AfterUpdate | Status-Dropdown |
| Rech_NR | TextBox (109) | 24318/682/1701/270 | Rech_NR | - | Rechnungsnummer |

### 2.2 NAVIGATIONS-BUTTONS

| Control Name | Type | Position | Caption | Event | Beschreibung |
|-------------|------|----------|---------|-------|--------------|
| Befehl43 | Button (104) | 5299/291/246/276 | btn_erster_Datensatz | - | Erster Datensatz |
| Befehl41 | Button (104) | 5590/291/246/276 | btn_Datensatz_zurueck | - | Vorheriger Datensatz |
| Befehl40 | Button (104) | 5881/291/246/276 | btn_Datensatz_vor | - | Nächster Datensatz |
| btn_letzer_Datensatz | Button (104) | 6172/291/246/276 | btn_letzter_Datensatz | - | Letzter Datensatz |
| btn_rueck | Button (104) | 6463/283/246/276 | Befehl649 | - | Rückgängig |
| btnReq | Button (104) | 5325/795/1236/276 | Aktualisieren | - | Formular neu laden |
| Befehl38 | Button (104) | 28006/113/306/336 | btn_Formular_schliessen | - | Formular schließen |

### 2.3 AUFTRAGSDATEN (Hauptformular)

| Control Name | Type | Position | ControlSource | Events | Beschreibung |
|-------------|------|----------|---------------|--------|--------------|
| Dat_VA_Von | TextBox (109) | 3727/113/1305/335 | Dat_VA_Von | OnDblClick, OnExit | Startdatum |
| Dat_VA_Bis | TextBox (109) | 5260/113/1305/335 | Dat_VA_Bis | OnDblClick, OnExit, BeforeUpdate | Enddatum |
| Kombinationsfeld656 | ComboBox (111) | 3727/477/4020/346 | Auftrag | - | Auftragsname |
| Ort | ComboBox (111) | 3727/875/4020/346 | Ort | OnDblClick, OnExit, BeforeUpdate, AfterUpdate | Ort mit Auto-Complete |
| Objekt | ComboBox (111) | 3727/1260/3717/346 | Objekt | OnDblClick, OnExit, BeforeUpdate, AfterUpdate | Objekt mit Auto-Complete |
| Objekt_ID | ComboBox (111) | 7295/1260/452/346 | Objekt_ID | OnDblClick, AfterUpdate | Objekt-ID (verknüpft) |
| Treffp_Zeit | TextBox (109) | 13575/119/870/329 | Treffp_Zeit | BeforeUpdate | Treffpunkt Zeit |
| Treffpunkt | TextBox (109) | 14485/119/3060/329 | Treffpunkt | - | Treffpunkt Beschreibung |
| Dienstkleidung | ComboBox (111) | 13575/494/3953/329 | Dienstkleidung | - | Dienstkleidung |
| Ansprechpartner | TextBox (109) | 13575/892/3953/329 | Ansprechpartner | - | Ansprechpartner |
| veranstalter_id | ComboBox (111) | 13575/1277/3953/329 | Veranstalter_ID | OnDblClick, AfterUpdate | Auftraggeber (Kunde) |
| PKW_Anzahl | TextBox (109) | 10033/345/1035/346 | Dummy | - | PKW Anzahl |
| Fahrtkosten | TextBox (109) | 10042/737/1021/300 | Fahrtkosten | - | Fahrtkosten pro PKW |

### 2.4 DATUM-NAVIGATION (Multi-Tage-Aufträge)

| Control Name | Type | Position | ControlSource | Events | Beschreibung |
|-------------|------|----------|---------------|--------|--------------|
| cboVADatum | ComboBox (111) | 8657/1260/2178/346 | - | OnDblClick, AfterUpdate | Datum-Auswahl bei Mehrtages-Aufträgen |
| btnDatumLeft | Button (104) | 8317/1260/291/346 | - | - | Vorheriger Tag |
| btnDatumRight | Button (104) | 10869/1260/291/346 | - | Click Event | Nächster Tag |

### 2.5 AKTIONS-BUTTONS (Hauptbereich)

| Control Name | Type | Position | Caption | Event | Beschreibung |
|-------------|------|----------|---------|-------|--------------|
| btnneuveranst | Button (104) | 10545/729/1995/345 | Neuer Auftrag | - | Neuen Auftrag anlegen |
| Befehl640 | Button (104) | 10545/165/1995/345 | Auftrag kopieren | Click | Auftrag duplizieren |
| mcobtnDelete | Button (104) | 12870/165/1995/360 | Auftrag löschen | Click | Auftrag löschen |
| btnSchnellPlan | Button (104) | 7995/450/1935/465 | Mitarbeiterauswahl | - | MA-Schnellauswahl |
| btn_Posliste_oeffnen | Button (104) | 8160/960/1500/340 | Positionen | Click | Öffnet Positionsliste |
| btn_Rueckmeld | Button (104) | 1814/850/1425/225 | Rückmelde-Statistik | Click | Rückmeldungen anzeigen |
| btnSyncErr | Button (104) | 3458/850/1035/225 | Syncfehler checken | Click | Sync-Fehler prüfen |

### 2.6 EMAIL & DRUCK-BUTTONS

| Control Name | Type | Position | Caption | Event | Beschreibung |
|-------------|------|----------|---------|-------|--------------|
| btnMailEins | Button (104) | 15195/165/2295/360 | Einsatzliste senden MA | - | Einsatzliste an MA |
| btn_Autosend_BOS | Button (104) | 17745/165/2610/360 | Einsatzliste senden BOS | Click | Einsatzliste an BOS |
| btnMailSub | Button (104) | 20475/165/1920/510 | Einsatzliste senden SUB | - | Einsatzliste an SUB |
| btnDruckZusage | Button (104) | 15195/735/2295/360 | Einsatzliste drucken | Click | Einsatzliste drucken |
| btn_ListeStd | Button (104) | 12903/735/1995/360 | Namensliste ESS | Click | Namensliste ESS |
| btn_BWN_Druck | Button (104) | 8370/2325/1656/283 | BWN drucken | - | Bewachungsnachweise drucken |

### 2.7 AUTOSEND-CHECKBOX

| Control Name | Type | Position | ControlSource | Beschreibung |
|-------------|------|----------|---------------|--------------|
| cbAutosendEL | CheckBox (106) | 18990/855/260/240 | Autosend_EL | Einsatzliste automatisch senden |
| lbl_EL_Autosend | Label (100) | 17744/798/1095/270 | - | Label "EL Autosend" |
| Befehl709 | Button (104) | 19275/795/1065/270 | EL gesendet | Zeigt gesendete ELs |

### 2.8 RECHNUNG-BUTTONS

| Control Name | Type | Position | Caption | Event | Beschreibung |
|-------------|------|----------|---------|-------|--------------|
| btnPDFKopf | Button (104) | 5514/3045/1984/392 | Rechnung PDF | - | Rechnung als PDF |
| btnPDFPos | Button (104) | 7736/3045/2659/392 | Berechnungsliste PDF | - | Berechnungsliste als PDF |
| btnLoad | Button (104) | 10801/3060/1701/403 | Daten laden | - | Rechnungsdaten laden |
| btnRchLex | Button (104) | 16800/2880/1986/568 | Rechnung in Lexware erstellen | - | Lexware-Integration |
| PosGesamtsumme | TextBox (109) | 15249/5313/2317/315 | =tsum(...) | Berechnet Gesamtsumme |

### 2.9 RIBBON & DB-BEREICH BUTTONS (meist unsichtbar)

| Control Name | Type | Position | Visible | Beschreibung |
|-------------|------|----------|---------|--------------|
| btnRibbonAus | Button (104) | 738/328/283/238 | True | Ribbon ausblenden |
| btnRibbonEin | Button (104) | 738/673/283/223 | True | Ribbon einblenden |
| btnDaBaAus | Button (104) | 453/508/283/223 | True | DB-Bereich ausblenden |
| btnDaBaEin | Button (104) | 1023/508/283/223 | True | DB-Bereich einblenden |

### 2.10 VERSTECKTE/ADMIN-BUTTONS

| Control Name | Type | Position | Visible | Enabled | Beschreibung |
|-------------|------|----------|---------|---------|--------------|
| btnAuftrBerech | Button (104) | 2664/56/180/270 | False | False | Auftrag berechnen |
| btn_aenderungsprotokoll | Button (104) | 2948/56/270/270 | False | False | Änderungsprotokoll |
| btnCheck | Button (104) | 4320/60/300/270 | False | True | Aufträge prüfen |
| btnmailpos | Button (104) | 3628/56/255/270 | True | False | Positionsliste senden |
| IstStatus | ComboBox (111) | 3288/56/311/270 | False | True | Status-Filter |
| cboEinsatzliste | ComboBox (111) | 1530/56/750/330 | False | False | Einsatzlisten-Druck-Option |
| btnDruckZusage1 | Button (104) | 2324/56/285/330 | False | False | Mehrtagesliste drucken |

### 2.11 AUFTRAGSLISTE (Rechter Bereich)

| Control Name | Type | Position | Beschreibung |
|-------------|------|----------|--------------|
| sub_VA_Anzeige | Subform (112) | 19117/170/9425/1232 | Info-Banner oben rechts |
| zsub_lstAuftrag | Subform (112) | 19170/1995/9546/9936 | Auftragsliste (Listbox) |
| Auftraege_ab | TextBox (109) | 20349/1596/1074/286 | Datum-Filter "Aufträge ab" |
| btn_AbWann | Button (104) | 21480/1590/416/286 | Filter anwenden |
| btnHeute | Button (104) | 23045/1596/1055/286 | Ab Heute filtern |
| btnTgBack | Button (104) | 22025/1596/440/286 | Tag zurück |
| btnTgVor | Button (104) | 22478/1596/410/286 | Tag vor |
| cboID | ComboBox (111) | 26366/1596/1505/286 | Auftrag suchen (versteckt) |
| btn_Tag_loeschen | Button (104) | 27786/1757/510/135 | Tag löschen (versteckt) |

### 2.12 AUDIT-FELDER (Erstellt/Geändert)

| Control Name | Type | Position | ControlSource | Beschreibung |
|-------------|------|----------|---------------|--------------|
| Text416 | TextBox (109) | 1077/56/1871/225 | Erst_von | Erstellt von |
| Text418 | TextBox (109) | 3174/56/1871/225 | Erst_am | Erstellt am |
| Text419 | TextBox (109) | 7378/56/1871/225 | Aend_von | Geändert von |
| Text422 | TextBox (109) | 9475/56/1871/225 | Aend_am | Geändert am |

---

## 3. TAB-CONTROL STRUKTUR

**Tab-Control:** `Reg_VA`
**Position:** 2715/1755/16410/10455
**5 Tab-Pages:**

### Page 1: pgMA_Zusage (Einsatzliste)
**Caption:** "Einsatzliste"
**Visible:** True

**Controls:**
- `MA_Selektion` (OptionGroup 107) - Filter-Optionen
- `cboAnstArt` (ComboBox 111) - Anstellungsart-Filter (versteckt)
- `btnPlan_Kopie` (Button 104) - Daten in Folgetag kopieren (versteckt)
- `sub_MA_VA_Zuordnung` (Subform 112) - **HAUPTSUBFORM** - MA-Zuordnung
- `sub_VA_Start` (Subform 112) - Schichten/Startzeiten
- `sub_MA_VA_Planung_Absage` (Subform 112) - Absagen
- `lbl_KeineEingabe` (Label 100) - Warnung "Auftrag bereits berechnet"

### Page 2: pgMA_Plan (Antworten ausstehend)
**Caption:** "Antworten ausstehend"
**Visible:** True

**Controls:**
- `sub_MA_VA_Zuordnung_Status` (Subform 112) - MA mit Status "offen"
- `btn_sortieren` (Button 104) - Sortieren (versteckt)
- `cmd_Messezettel_NameEintragen` (Button 104) - BWN Namen (versteckt)
- `cmd_BWN_send` (Button 104) - BWN senden (versteckt)
- `btn_BWN_Druck` (Button 104) - BWN drucken

### Page 3: pgAttach (Zusatzdateien)
**Caption:** "Zusatzdateien"
**Visible:** False

**Controls:**
- `sub_ZusatzDateien` (Subform 112) - Dateianhänge
- `btnNeuAttach` (Button 104) - Neuen Attach hinzufügen
- `TabellenNr` (TextBox 109) - Konstante =42 (versteckt)

### Page 4: pgRechnung (Rechnung)
**Caption:** "Rechnung"
**Visible:** True

**Controls:**
- `sub_rch_Pos` (Subform 112) - Rechnungspositionen
- `sub_Berechnungsliste` (Subform 112) - Berechnungsliste
- `PosGesamtsumme` (TextBox 109) - Gesamtsumme
- `btnPDFKopf`, `btnPDFPos`, `btnLoad`, `btnRchLex` (siehe 2.8)

### Page 5: pgBemerk (Bemerkungen)
**Caption:** "Bemerkungen"
**Visible:** False

**Controls:**
- `Bemerkungen` (TextBox 109) - Großes Textfeld für Bemerkungen

---

## 4. SUBFORMS

### 4.1 frm_Menuefuehrung (Sidebar)
**Position:** 15/0/2603/11887
**SourceObject:** `frm_Menuefuehrung`
**LinkMaster:** -
**LinkChild:** -
**Beschreibung:** Linke Navigation (wie in MA-Stamm)

### 4.2 sub_MA_VA_Zuordnung (Hauptsubform Einsatzliste)
**Position:** 6825/2805/12159/9251
**SourceObject:** `sub_MA_VA_Zuordnung`
**LinkMaster:** `ID;cboVADatum`
**LinkChild:** `VA_ID;VADatum_ID`
**Beschreibung:** Zeigt zugeordnete Mitarbeiter mit Zeiten

### 4.3 sub_VA_Start (Schichten)
**Position:** 2955/2805/3765/2790
**SourceObject:** `sub_VA_Start`
**LinkMaster:** `ID;cboVADatum`
**LinkChild:** `VA_ID;VADatum_ID`
**Beschreibung:** Zeigt Schichten/Startzeiten des Auftrags

### 4.4 sub_MA_VA_Planung_Absage (Absagen)
**Position:** 2895/6203/3810/5851
**SourceObject:** `sub_MA_VA_Planung_Absage`
**LinkMaster:** `ID;cboVADatum`
**LinkChild:** `VA_ID;VADatum_ID`
**Beschreibung:** Zeigt MA mit Absage-Status

### 4.5 sub_MA_VA_Zuordnung_Status (Status ausstehend)
**Position:** 3185/2537/13794/9086
**SourceObject:** `sub_MA_VA_Planung_Status`
**LinkMaster:** `ID;cboVADatum`
**LinkChild:** `VA_ID;VADatum_ID`
**Beschreibung:** Zeigt MA mit offenen Antworten

### 4.6 sub_ZusatzDateien (Attachments)
**Position:** 3225/3556/13500/8411
**SourceObject:** `sub_ZusatzDateien`
**LinkMaster:** `Objekt_ID;TabellenNr`
**LinkChild:** `Ueberordnung;TabellenID`
**Beschreibung:** Dateianhänge zum Auftrag

### 4.7 sub_rch_Pos (Rechnungspositionen)
**Position:** 3366/3511/14242/1748
**SourceObject:** `Abfrage.zqry_Rch_Pos`
**LinkMaster:** `ID`
**LinkChild:** `VA_ID`
**Beschreibung:** Rechnungspositionen

### 4.8 sub_Berechnungsliste (Berechnungsdetails)
**Position:** 3388/5790/14272/6124
**SourceObject:** `zsub_rch_Berechnungsliste`
**LinkMaster:** `ID`
**LinkChild:** `VA_ID`
**Beschreibung:** Detaillierte Berechnungsliste

### 4.9 sub_VA_Anzeige (Info-Banner)
**Position:** 19117/170/9425/1232
**SourceObject:** `sub_VA_Anzeige`
**LinkMaster:** -
**LinkChild:** -
**Beschreibung:** Info-Banner rechts oben

### 4.10 zsub_lstAuftrag (Auftragsliste)
**Position:** 19170/1995/9546/9936
**SourceObject:** `frm_lst_row_auftrag`
**LinkMaster:** -
**LinkChild:** -
**Beschreibung:** Scrollbare Auftragsliste rechts

---

## 5. VBA-EVENTS (wichtigste)

### 5.1 FORM-EVENTS

| Event | Beschreibung |
|-------|--------------|
| Form_Open | Initialisierung, Property-Settings |
| Form_Current | Wird bei Datensatzwechsel ausgelöst |
| Form_BeforeUpdate | Validierung vor Speicherung |
| Form_BeforeDelConfirm | Bestätigung vor Löschung |

### 5.2 BUTTON-EVENTS

| Button | Event | VBA-Funktion | Beschreibung |
|--------|-------|--------------|--------------|
| Befehl640 | Click | `AuftragKopieren(Me.ID)` | Auftrag duplizieren |
| mcobtnDelete | Click | `DELETE FROM ... WHERE ID = ...` | Auftrag löschen |
| btnSchnellPlan | Click | - | Öffnet MA-Schnellauswahl |
| btn_Posliste_oeffnen | Click | `OpenObjektPositionenFromAuftrag` | Öffnet Objektpositionen |
| btn_ListeStd | Click | `Stundenliste_erstellen` | Erstellt Namensliste ESS |
| btn_Autosend_BOS | Click | `Form_frm_MA_Serien_eMail_Auftrag.Autosend` | Sendet EL an BOS |
| btn_Rueckmeld | Click | Öffnet `zfrm_Rueckmeldungen` | Rückmeldungen anzeigen |
| btnSyncErr | Click | Öffnet `zfrm_SyncError` | Sync-Fehler anzeigen |
| btnDatumRight | Click | `cboVADatum` auf nächsten Tag setzen | Tag vor |
| btnDruckZusage | Click | `btn_std_check_Click` (Status auf 3 setzen) | Einsatzliste drucken |
| btn_sortieren | Click | `sort_zuo_plan` | Zuordnung sortieren |
| btn_BWN_Druck | Click | `DruckeBewachungsnachweise` | BWN drucken |

### 5.3 COMBOBOX-EVENTS

| Control | Event | VBA-Funktion | Beschreibung |
|---------|-------|--------------|--------------|
| Veranst_Status_ID | AfterUpdate | Status-Logik | Status-Änderung verarbeiten |
| Veranst_Status_ID | BeforeUpdate | Validierung | Status-Prüfung |
| cboVADatum | AfterUpdate | `cboVADatum_AfterUpdate` | Datum-Wechsel → Subforms neu laden |
| veranstalter_id | AfterUpdate | - | Kunde gewählt |
| Objekt | AfterUpdate | Ggf. Objekt_ID setzen | Objekt-Verknüpfung |

### 5.4 TEXTBOX-EVENTS (Auto-Complete)

| Control | Event | VBA-Funktion | Beschreibung |
|---------|-------|--------------|--------------|
| Auftrag | GotFocus | - | Vorbelegung aus letztem Auftrag |
| Ort | GotFocus | `Ort_GotFocus` | Vorbelegung + Template-Erkennung |
| Objekt | GotFocus | `Objekt_GotFocus` | Vorbelegung aus letztem Auftrag |
| Dienstkleidung | GotFocus | `Dienstkleidung_GotFocus` | Vorbelegung |
| Ansprechpartner | GotFocus | `Ansprechpartner_GotFocus` | Vorbelegung |
| Treffp_Zeit | GotFocus | `Treffp_Zeit_GotFocus` | Vorbelegung |
| Dat_VA_Von | OnExit | Validierung | Datum-Prüfung |
| Dat_VA_Bis | OnExit | Validierung | Datum-Prüfung |

### 5.5 TEMPLATE-ERKENNUNG (Ort_GotFocus)

Im Event `Ort_GotFocus` werden automatisch Felder vorbefüllt basierend auf dem Auftragsnamen:

| Auftrag-Pattern | Ort | Objekt | Treffpunkt | Kleidung | Veranstalter_ID |
|----------------|-----|--------|------------|----------|------------------|
| `Kaufland*` | - | - | "15 min vor Ort" | "Schwarz neutral" | 20770 |
| `Greuther *` | Fürth | Sportpark am Ronhof | "15 min vor DB Tor F" | "Schwarz neutral" | 20737 |
| `1.FCN *` | Nürnberg | Max-Morlock-Stadion | "15 min vor DB Eingang Nord West" | "Schwarz neutral" | 20771 |
| `Konzert` | Nürnberg | Hirsch | "15 min vor DB vor Ort" | "Consec" | 10233 |
| `clubbing` | Nürnberg | Hirsch | "15 min vor DB vor Ort" | "Consec" | 10337 |
| `HC Erlangen ` | Nürnberg | Arena | "15 min vor DB Arena Ecke Kurt-Leucht" | "Schwarz neutral" | 20761 |

---

## 6. DATENBANK-VERKNÜPFUNG

### 6.1 RECORDSOURCE

**Query:** `qry_Auftrag_Sort`
**Basis-Tabelle:** `tbl_VA_Auftragstamm`

**Filter-Logik:**
- `IstStatus` ComboBox (versteckt) filtert nach Status
- `Auftraege_ab` TextBox filtert nach Datum
- `OrderBy`: `[qry_Auftrag_Sort].[Dienstkleidung]`

### 6.2 FELDER-MAPPING (RecordSource → Controls)

| Feld in DB | Control | Typ | Beschreibung |
|-----------|---------|-----|--------------|
| ID | ID | TextBox | Primary Key |
| Auftrag | Kombinationsfeld656 | ComboBox | Auftragsname |
| Dat_VA_Von | Dat_VA_Von | TextBox | Startdatum |
| Dat_VA_Bis | Dat_VA_Bis | TextBox | Enddatum |
| Ort | Ort | ComboBox | Ort (Auto-Complete) |
| PLZ | PLZ | TextBox | PLZ (versteckt) |
| Objekt | Objekt | ComboBox | Objekt (Auto-Complete) |
| Objekt_ID | Objekt_ID | ComboBox | FK zu tbl_OB_Objekt |
| Treffpunkt | Treffpunkt | TextBox | Treffpunkt |
| Treffp_Zeit | Treffp_Zeit | TextBox | Treffpunkt Zeit |
| Dienstkleidung | Dienstkleidung | ComboBox | Dienstkleidung |
| Ansprechpartner | Ansprechpartner | TextBox | Ansprechpartner |
| Veranstalter_ID | veranstalter_id | ComboBox | FK zu tbl_KD_Kundenstamm |
| Veranst_Status_ID | Veranst_Status_ID | ComboBox | FK zu tbl_VA_Status |
| Fahrtkosten | Fahrtkosten | TextBox | Fahrtkosten pro PKW |
| Dummy | PKW_Anzahl | TextBox | PKW Anzahl (nicht gespeichert!) |
| Rech_NR | Rech_NR | TextBox | Rechnungsnummer |
| Bemerkungen | Bemerkungen | TextBox | Bemerkungen (auf Tab 5) |
| Autosend_EL | cbAutosendEL | CheckBox | Autosend-Flag |
| Erst_von | Text416 | TextBox | Erstellt von |
| Erst_am | Text418 | TextBox | Erstellt am |
| Aend_von | Text419 | TextBox | Geändert von |
| Aend_am | Text422 | TextBox | Geändert am |

### 6.3 ROWSOURCES (ComboBoxen)

| Control | RowSource | Display | Value |
|---------|-----------|---------|-------|
| Veranst_Status_ID | `SELECT ID, Fortschritt FROM tbl_VA_Status ORDER BY ID` | Fortschritt | ID |
| veranstalter_id | `SELECT kun_Id, kun_Firma FROM tbl_KD_Kundenstamm WHERE kun_AdressArt=1 AND kun_IstAktiv=True ORDER BY kun_Firma` | kun_Firma | kun_Id |
| Objekt_ID | `SELECT ID, Objekt, ... FROM tbl_OB_Objekt` | Objekt | ID |
| Ort | `SELECT DISTINCT Ort FROM tbl_VA_Auftragstamm WHERE Len(Trim(Nz(ort)))>0 ORDER BY Ort` | Ort | Ort |
| Objekt | `SELECT DISTINCT Objekt FROM tbl_VA_Auftragstamm WHERE Len(Trim(Nz(Objekt)))>0 ORDER BY Objekt` | Objekt | Objekt |
| Kombinationsfeld656 (Auftrag) | `SELECT DISTINCT Auftrag FROM tbl_VA_Auftragstamm WHERE Len(Trim(Nz(ort)))>0 ORDER BY Auftrag` | Auftrag | Auftrag |
| Dienstkleidung | `SELECT DISTINCT Dienstkleidung FROM tbl_VA_Auftragstamm WHERE Len(Trim(Nz(Dienstkleidung)))>0 ORDER BY Dienstkleidung` | Dienstkleidung | Dienstkleidung |
| cboVADatum | `SELECT ID, VADatum FROM tbl_VA_AnzTage WHERE VA_ID= [ID]` | VADatum | ID |

---

## 7. WEB-IMPLEMENTIERUNGS-PLAN

### 7.1 COMPONENT-STRUKTUR

```
frm_va_Auftragstamm.html
├── Sidebar (frm_Menuefuehrung)
├── Header
│   ├── Navigation Buttons (Datensatz vor/zurück)
│   ├── Formular schließen
│   └── Status-Dropdown + Datum + Version
├── Main Content (2-Spalten)
│   ├── Linke Spalte (Auftragsdetails)
│   │   ├── Basis-Daten (Datum, Auftrag, Ort, Objekt)
│   │   ├── Treffpunkt-Daten
│   │   ├── Auftraggeber
│   │   ├── Aktions-Buttons
│   │   └── Tab-Control (5 Tabs)
│   │       ├── Tab 1: Einsatzliste (Subforms)
│   │       ├── Tab 2: Antworten ausstehend
│   │       ├── Tab 3: Zusatzdateien
│   │       ├── Tab 4: Rechnung
│   │       └── Tab 5: Bemerkungen
│   └── Rechte Spalte (Auftragsliste)
│       ├── Filter-Controls
│       └── zsub_lstAuftrag (Listbox)
└── Logic (.logic.js)
```

### 7.2 API-ENDPOINTS (Backend)

**Benötigt:**

```javascript
// Aufträge
GET /api/auftraege              // Liste aller Aufträge
GET /api/auftraege/:id          // Einzelauftrag
POST /api/auftraege             // Neuer Auftrag
PUT /api/auftraege/:id          // Auftrag bearbeiten
DELETE /api/auftraege/:id       // Auftrag löschen
POST /api/auftraege/:id/kopieren // Auftrag kopieren

// Auftrags-Tage (Multi-Day)
GET /api/auftraege/:id/tage     // Liste der Tage für Mehrtages-Auftrag

// Zuordnungen
GET /api/auftraege/:id/zuordnungen?vadatum_id=X  // MA-Zuordnungen für Tag
POST /api/auftraege/:id/zuordnungen              // Neue Zuordnung
PUT /api/zuordnungen/:id                         // Zuordnung bearbeiten
DELETE /api/zuordnungen/:id                      // Zuordnung löschen

// Status
GET /api/auftraege/:id/status-ausstehend?vadatum_id=X  // MA mit offenen Antworten

// Schichten
GET /api/auftraege/:id/schichten?vadatum_id=X   // Schichten für Tag
POST /api/auftraege/:id/schichten               // Neue Schicht
PUT /api/schichten/:id                          // Schicht bearbeiten
DELETE /api/schichten/:id                       // Schicht löschen

// Rechnung
GET /api/auftraege/:id/rechnung-positionen      // Rechnungspositionen
GET /api/auftraege/:id/berechnungsliste         // Berechnungsliste
POST /api/auftraege/:id/rechnung-laden          // Rechnungsdaten laden

// Emails
POST /api/auftraege/:id/email-einsatzliste      // Einsatzliste senden

// Lookups
GET /api/status                                 // Liste VA-Status
GET /api/kunden?aktiv=true                      // Liste Kunden
GET /api/objekte                                // Liste Objekte
GET /api/auftraege/vorschlaege?feld=ort         // Auto-Complete Vorschläge
```

### 7.3 KRITISCHE FUNKTIONEN (zu portieren)

| Funktion | Priorität | Beschreibung |
|----------|-----------|--------------|
| `AuftragKopieren(ID)` | HOCH | Auftrag duplizieren inkl. Schichten |
| `cboVADatum_AfterUpdate` | HOCH | Datum-Wechsel → Subforms aktualisieren |
| `Ort_GotFocus` (Template-Erkennung) | MITTEL | Auto-Fill bei bekannten Auftragsnamen |
| `sort_zuo_plan` | MITTEL | Zuordnungen sortieren |
| `Stundenliste_erstellen` | MITTEL | ESS Namensliste |
| Email-Funktionen | NIEDRIG | Einsatzliste senden (Backend-Job) |

### 7.4 LAYOUT-STRATEGIE

**Responsive:**
- Desktop (1920x1080): 2-Spalten Layout (70% Auftragsdetails / 30% Liste)
- Tablet (1024x768): Tab-umschaltbar (Auftragsdetails ODER Liste)
- Mobile: Nicht unterstützt (zu komplex)

**Pixelgenaue Konvertierung:**
- Form Width: 23415 Twips → 1561 px
- Form Height: 14595 Twips → 973 px
- Scale-Factor: 0.0667 (1 Twip = 0.0667px)

**CSS-Grid:**
```css
.auftragstamm-layout {
  display: grid;
  grid-template-columns: 180px 1fr 380px; /* Sidebar | Content | Liste */
  grid-template-rows: auto 1fr;
  gap: 0;
}
```

### 7.5 SUBFORM-INTEGRATION

Alle Subforms als iframe laden:

```html
<!-- Tab 1: Einsatzliste -->
<iframe src="sub_VA_Start.html?va_id={ID}&vadatum_id={cboVADatum}"></iframe>
<iframe src="sub_MA_VA_Zuordnung.html?va_id={ID}&vadatum_id={cboVADatum}"></iframe>
<iframe src="sub_MA_VA_Planung_Absage.html?va_id={ID}&vadatum_id={cboVADatum}"></iframe>

<!-- Tab 2: Status -->
<iframe src="sub_MA_VA_Zuordnung_Status.html?va_id={ID}&vadatum_id={cboVADatum}"></iframe>

<!-- Tab 3: Attachments -->
<iframe src="sub_ZusatzDateien.html?objekt_id={Objekt_ID}&tabellen_nr=42"></iframe>

<!-- Tab 4: Rechnung -->
<iframe src="sub_rch_Pos.html?va_id={ID}"></iframe>
<iframe src="sub_Berechnungsliste.html?va_id={ID}"></iframe>
```

**PostMessage-Kommunikation:**
- Parent sendet Datum-Wechsel an Subforms
- Subform sendet `DATA_CHANGED` zurück → Parent reloaded

---

## 8. BESONDERHEITEN & FALLSTRICKE

### 8.1 MEHRTAGES-AUFTRÄGE

- Ein Auftrag kann mehrere Tage haben (tbl_VA_AnzTage)
- `cboVADatum` Dropdown wählt den aktiven Tag
- Alle Subforms reagieren auf Datum-Wechsel
- `btnDatumLeft` / `btnDatumRight` navigieren durch Tage

### 8.2 STATUS-VERWALTUNG

**Status-IDs (tbl_VA_Status):**
- 1 = Planung
- 2 = Bestätigt
- 3 = Abgeschlossen
- 4 = Abgerechnet
- 5 = Storniert

**Besonderheiten:**
- Status 3+ → Formular read-only
- Status 4 → Rechnung erstellt
- `lbl_KeineEingabe` zeigt Warnung bei Status >= 3

### 8.3 PKW_ANZAHL (DUMMY-FELD)

- Control `PKW_Anzahl` hat ControlSource `Dummy`
- Wird NICHT in DB gespeichert
- Nur zur Anzeige/Berechnung
- Wert kommt aus Unterabfrage

### 8.4 AUFTRAG KOPIEREN

**Kopiert werden:**
- Alle Felder außer ID, Datum
- Alle Schichten (tbl_VA_Start)
- Datum +7 Tage als Default

**NICHT kopiert:**
- MA-Zuordnungen
- Rechnung
- Status (wird auf 1 gesetzt)

### 8.5 EMAIL-AUTOSEND

- `cbAutosendEL` CheckBox aktiviert/deaktiviert Autosend
- Nur für BOS-Aufträge (Veranstalter_ID = 10720, 20770, 20771)
- Sendet bei Status-Änderung automatisch Einsatzliste
- Empfänger: `marcus.wuest@bos-franken.de; sb-dispo@bos-franken.de; ...`

### 8.6 TEMPLATE-ERKENNUNG

- Bei Eingabe von bekannten Auftragsnamen (1.FCN, Greuther, Kaufland, ...)
- Werden Felder automatisch vorbefüllt
- Siehe Tabelle in Abschnitt 5.5

### 8.7 RIBBON & DB-BEREICH BUTTONS

- `btnRibbonAus` / `btnRibbonEin` → Im Web nicht relevant (kein Access-Ribbon)
- `btnDaBaAus` / `btnDaBaEin` → Im Web nicht relevant (kein DB-Bereich)
- Können im Web versteckt oder entfernt werden

---

## 9. MOCK-DATEN (für Tests)

### 9.1 TEST-AUFTRAG 1

```json
{
  "ID": 8113,
  "Auftrag": "1.FCN Heimspiel",
  "Dat_VA_Von": "2025-01-15",
  "Dat_VA_Bis": "2025-01-15",
  "Ort": "Nürnberg",
  "Objekt": "Max-Morlock-Stadion",
  "Objekt_ID": 42,
  "Treffpunkt": "15 min vor DB Eingang Nord West",
  "Treffp_Zeit": "17:45",
  "Dienstkleidung": "Schwarz neutral",
  "Ansprechpartner": "Herr Schmidt",
  "Veranstalter_ID": 20771,
  "Veranst_Status_ID": 2,
  "Fahrtkosten": 15.00,
  "PKW_Anzahl": 3,
  "Rech_NR": "R-2025-0042",
  "Autosend_EL": true,
  "Bemerkungen": "Wichtiges Derby-Spiel",
  "Erst_von": "GPT",
  "Erst_am": "2025-01-01 10:00:00",
  "Aend_von": "GPT",
  "Aend_am": "2025-01-10 14:30:00"
}
```

### 9.2 TEST-AUFTRAG 2 (Mehrtägig)

```json
{
  "ID": 8114,
  "Auftrag": "Rock am Ring Festival",
  "Dat_VA_Von": "2025-06-01",
  "Dat_VA_Bis": "2025-06-03",
  "Ort": "Nürburg",
  "Objekt": "Nürburgring",
  "Objekt_ID": 99,
  "Treffpunkt": "Haupteingang",
  "Treffp_Zeit": "08:00",
  "Dienstkleidung": "Consec",
  "Ansprechpartner": "Frau Müller",
  "Veranstalter_ID": 10233,
  "Veranst_Status_ID": 1,
  "Fahrtkosten": 50.00,
  "PKW_Anzahl": 8,
  "Rech_NR": null,
  "Autosend_EL": false,
  "Bemerkungen": "3-Tages Festival, große MA-Anzahl",
  "Erst_von": "GPT",
  "Erst_am": "2025-03-15 09:00:00",
  "Aend_von": null,
  "Aend_am": null
}
```

### 9.3 TEST-TAGE (für Auftrag 8114)

```json
[
  {"ID": 1, "VA_ID": 8114, "VADatum": "2025-06-01"},
  {"ID": 2, "VA_ID": 8114, "VADatum": "2025-06-02"},
  {"ID": 3, "VA_ID": 8114, "VADatum": "2025-06-03"}
]
```

### 9.4 TEST-STATUS

```json
[
  {"ID": 1, "Fortschritt": "Planung"},
  {"ID": 2, "Fortschritt": "Bestätigt"},
  {"ID": 3, "Fortschritt": "Abgeschlossen"},
  {"ID": 4, "Fortschritt": "Abgerechnet"},
  {"ID": 5, "Fortschritt": "Storniert"}
]
```

---

## 10. NÄCHSTE SCHRITTE (ETAPPEN 2-5)

### ETAPPE 2: UI 1:1 Renderer
- ✅ React-Component `AuftragstammForm.jsx` erstellen
- ✅ 145 Controls pixelgenau rendern
- ✅ Tab-Control mit 5 Pages
- ✅ 10 Subforms als iframes
- ✅ Responsive Layout (Grid)
- ✅ Route in App.jsx

### ETAPPE 3: Backend API
- ✅ Model `Auftrag.js` (CRUD)
- ✅ Controller `auftragController.js`
- ✅ Routes `/api/auftraege/*`
- ✅ 3 Mock-Aufträge

### ETAPPE 4: Events & VBA
- ✅ Button-Events portieren
- ✅ Datum-Navigation (btnDatumLeft/Right)
- ✅ Auftrag kopieren
- ✅ Template-Erkennung
- ✅ Validierungen

### ETAPPE 5: Tests & Doku
- ✅ Formular-Test (lädt korrekt?)
- ✅ Navigation-Test
- ✅ CRUD-Test
- ✅ Update README.md

---

## 11. OFFENE FRAGEN

1. **Subform-Details:** Benötigen wir detaillierte Exports der 10 Subforms?
2. **Email-Funktionen:** Backend-Job oder Frontend-Button?
3. **PDF-Export:** Server-seitig oder Client-seitig?
4. **Lexware-Integration:** Wird diese Funktion benötigt?
5. **Responsive-Breakpoints:** Wo genau umschalten von 2-Spalten auf 1-Spalte?

---

**MAPPING ERSTELLT:** 2025-12-23
**ANALYSIERT VON:** Claude Sonnet 4.5 (Instanz 2)
**EXPORT-QUELLE:** `C:\Users\guenther.siegert\Documents\01_ClaudeCode_HTML\exports\`
**STATUS:** ETAPPE 1 ABGESCHLOSSEN ✅
