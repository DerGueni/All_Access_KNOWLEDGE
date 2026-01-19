# Gap-Analyse: frm_MA_Mitarbeiterstamm

**Erstellt:** 2026-01-12
**Formular:** Mitarbeiterstamm (größtes Formular mit 290 Controls)
**Status:** ⚠️ Erhebliche Lücken - Kritische Buttons fehlen

---

## Zusammenfassung

| Kategorie | Access | HTML | Implementiert | Gap |
|-----------|--------|------|---------------|-----|
| **Buttons** | 41 | 29 | 71% | 12 fehlen |
| **TextBoxen** | 70 | 54 | 77% | 16 fehlen |
| **ComboBoxen** | 17 | 7 | 41% | 10 fehlen |
| **CheckBoxen** | 12 | 14 | 117% | +2 extra |
| **ListBoxen** | 7 | 1 | 14% | 6 fehlen |
| **Subforms** | 13 | 7 (iframes) | 54% | 6 fehlen |
| **Events** | ~50+ | ~20 | 40% | ~30 fehlen |

**Gesamtbewertung:** 60% Funktionsumfang implementiert

---

## 1. CONTROLS-VERGLEICH

### 1.1 Buttons (41 in Access → 29 in HTML)

#### ✅ Implementiert (29 Buttons)

| Access-Button | HTML-Button | Funktion | Status |
|---------------|-------------|----------|--------|
| **Navigation** ||||
| Befehl39 | btnErste | Erster Datensatz | ✅ onclick="navFirst()" |
| Befehl40 | btnVorige | Vorheriger Datensatz | ✅ onclick="navPrev()" |
| Befehl41 | btnNächste | Nächster Datensatz | ✅ onclick="navNext()" |
| Befehl43 | btnLetzte | Letzter Datensatz | ✅ onclick="navLast()" |
| mcobtnDelete | btnLöschen | MA löschen | ✅ onclick="mitarbeiterLöschen()" |
| **Aktionen** ||||
| btnZeitkonto | btnZeitkonto | Zeitkonto öffnen | ✅ onclick="openZeitkonto()" |
| lbl_Mitarbeitertabelle | btnMATabelle | MA-Tabelle | ✅ onclick="mitarbeiterTabelle()" |
| btnMaps | btnMapsÖffnen | Google Maps | ✅ onclick="openMaps()" |
| btnLstDruck | btnListenDrucken | Listen drucken | ✅ onclick="listenDrucken()" |
| **Zeitkonten** ||||
| btnZKFest | btnZKFest | ZK Festangestellte | ✅ onclick="btnZKFest_Click()" |
| btnZKMini | btnZKMini | ZK Minijobber | ✅ onclick="btnZKMini_Click()" |
| btnZKeinzel | btnZKeinzel | ZK Einzelsatz | ✅ onclick="btnZKeinzel_Click()" |
| **Excel-Export** ||||
| btnXLZeitkto | - | Excel Zeitkonto | ✅ onclick="btnXLZeitkto_Click()" |
| btnXLJahr | - | Excel Jahresübersicht | ✅ onclick="btnXLJahr_Click()" |
| btnXLEinsUeber | - | Excel Einsatzübersicht | ✅ onclick="btnXLEinsUeber_Click()" (hidden) |
| btnXLDiePl | - | Excel Dienstplan | ✅ onclick="btnXLDiePl_Click()" (hidden) |
| btnXLNverfueg | - | Excel Nicht-Verfügbar | ✅ onclick="btnXLNverfueg_Click()" (hidden) |
| btnXLUeberhangStd | - | Excel Überhang-Std | ✅ onclick="btnXLUeberhangStd_Click()" (hidden) |
| **Weitere** ||||
| - | btnNeuMA | Neuer MA | ✅ onclick="neuerMitarbeiter()" |
| - | btnAktualisieren | Daten neu laden | ✅ onclick="refreshData()" |
| - | btnMAAdressen | MA Adressen | ✅ onclick="openMAAdressen()" |
| - | btnEinsaetzeFA | Einsätze FA | ✅ onclick="einsaetzeUebertragen('FA')" |
| - | btnEinsaetzeMJ | Einsätze MJ | ✅ onclick="einsaetzeUebertragen('MJ')" |
| btnDienstplan | btnDienstplan | Dienstplan | ✅ onclick="openDienstplan()" (hidden) |
| - | btnEinsatzÜbersicht | Einsatzübersicht | ✅ onclick="openEinsatzübersicht()" |
| - | fullscreenBtn | Vollbild | ✅ onclick="toggleFullscreen()" |
| btnDateisuch | - | Foto Upload 1 | ✅ onclick="document.getElementById('fotoUploadInput').click()" |
| btnDateisuch2 | - | Foto Upload 2 | ✅ onclick="btnDateisuch2_Click()" |

#### ❌ Fehlende Buttons (12 kritisch)

| Access-Button | Funktion | VBA-Code | Priorität |
|---------------|----------|----------|-----------|
| **btnRibbonAus** | Ribbon ausblenden | `DoCmd.ShowToolbar "Ribbon", acToolbarNo` | 🟡 Niedrig (UI) |
| **btnRibbonEin** | Ribbon einblenden | `DoCmd.ShowToolbar "Ribbon", acToolbarYes` | 🟡 Niedrig (UI) |
| **btnDaBaEin** | Datenbank-Fenster ein | `DoCmd.SelectObject acTable, , True` | 🟡 Niedrig (UI) |
| **btnDaBaAus** | Datenbank-Fenster aus | - | 🟡 Niedrig (UI) |
| **btnMADienstpl** | MA-Dienstplan | `DoCmd.OpenForm "frm_DP_Dienstplan_MA"` | 🔴 Hoch |
| **btnZuAb** | Zu-/Absagen? | Unbekannte Funktion | 🟠 Mittel |
| **btnLesen** | Daten einlesen? | Unbekannte Funktion | 🟠 Mittel |
| **btnUpdJahr** | Jahr aktualisieren | Jahreswechsel-Logik | 🔴 Hoch |
| **btnAU_Lesen** | Arbeitsunfähigkeit lesen | AU-Daten importieren | 🔴 Hoch |
| **btnRch** | Rechnungen? | Rechnung erstellen | 🟠 Mittel |
| **btnCalc** | Berechnung? | Unbekannte Berechnung | 🟠 Mittel |
| **btnau_lesen2** | AU lesen (2. Variante) | AU-Daten importieren | 🟠 Mittel |
| **btnAUPl_Lesen** | AU-Planung lesen | AU in Planung übernehmen | 🔴 Hoch |
| **btn_Diensplan_prnt** | Dienstplan drucken | `DoCmd.OpenReport "rpt_MA_Dienstplan", acViewPreview` | 🔴 Hoch |
| **btn_Dienstplan_send** | Dienstplan versenden | Per E-Mail senden | 🔴 Hoch |
| **btnMehrfachtermine** | Mehrfachtermine | Termine verwalten | 🟠 Mittel |
| **btnReport_Dienstkleidung** | Dienstkleidung Report | `DoCmd.OpenReport "rpt_MA_Dienstkleidung"` | 🟠 Mittel |
| **btn_MA_EinlesVorlageDatei** | Vorlagen-Datei einlesen | Importfunktion | 🟠 Mittel |
| **btnXLVordrucke** | Excel Vordrucke | Excel-Export | 🟠 Mittel |
| **Bericht_drucken** | Bericht drucken | `DoCmd.OpenReport` | 🔴 Hoch |

---

### 1.2 TextBoxen (70 in Access → 54 in HTML)

#### ✅ Vollständig implementiert (54 Felder)

**Stammdaten (Spalte 1):**
- ✅ ID (PersNr) - readonly
- ✅ LEXWare_ID
- ✅ Nachname - required
- ✅ Vorname - required
- ✅ Strasse
- ✅ Nr (Hausnummer)
- ✅ PLZ - pattern validation
- ✅ Ort
- ✅ Land (Dropdown)
- ✅ Bundesland
- ✅ Tel_Mobil - pattern validation
- ✅ Tel_Festnetz
- ✅ Email - pattern validation
- ✅ Geschlecht (Dropdown)
- ✅ Staatsang
- ✅ Geb_Dat (date input)
- ✅ Geb_Ort
- ✅ Geb_Name

**Beschäftigung (Spalte 2):**
- ✅ Eintrittsdatum (date)
- ✅ Austrittsdatum (date)
- ✅ Anstellungsart_ID (Dropdown)
- ✅ Kleidergroesse (Dropdown)
- ✅ DienstausweisNr
- ✅ Ausweis_Endedatum (date)
- ✅ Ausweis_Funktion
- ✅ Letzte_Ueberpr_OA (date)
- ✅ Personalausweis_Nr
- ✅ Epin_DFB
- ✅ Bewacher_ID
- ✅ Zustaendige_Behoerde (Amt_Pruefung)

**Finanzen (Spalte 3):**
- ✅ Kontoinhaber
- ✅ Bankname
- ✅ IBAN - pattern validation
- ✅ BIC - pattern validation
- ✅ Stundenlohn_brutto (Dropdown "Lohngruppe")
- ✅ Kostenstelle
- ✅ Bezuege_gezahlt_als
- ✅ Koordinaten
- ✅ SteuerNr
- ✅ Taetigkeit_Bezeichnung (Dropdown)
- ✅ KV_Kasse
- ✅ Steuerklasse
- ✅ Sozialvers_Nr
- ✅ Arbeitsstd_pro_Arbeitstag (number)
- ✅ Arbeitstage_pro_Woche (number)
- ✅ Resturlaub_Vorjahr (number)
- ✅ Urlaubsanspr_pro_Jahr (number)
- ✅ StundenZahlMax (number)
- ✅ Bemerkungen (textarea)

#### ❌ Fehlende TextBoxen (16)

| Access-Feld | Funktion | Typ | Priorität |
|-------------|----------|-----|-----------|
| **DiDatumAb** | Dienstplan ab Datum | Date (mit Default =Date()) | 🔴 Hoch |
| **lbl_ab** | Label für DiDatumAb | Label/TextBox | 🟡 Niedrig |
| **tblBilddatei** | Bilddatei-Pfad | Text | 🟠 Mittel |
| **tblSignaturdatei** | Signatur-Pfad | Text | 🟠 Mittel |
| **Datum_34a** | §34a Prüfungsdatum | Date | 🔴 Hoch |
| **Amt_Pruefung** | Prüfende Behörde | Text | 🟠 Mittel |
| **Datum_Pruefung** | Prüfungsdatum (allgemein) | Date | 🟠 Mittel |
| **Mon_aktdat** | Aktuelles Monatsdatum | Date (calculated) | 🟠 Mittel |
| **EinsProMon** | Einsätze pro Monat | Number (calculated) | 🟠 Mittel |
| **TagProMon** | Tage pro Monat | Number (calculated) | 🟠 Mittel |
| **txRechSub** | Rechnung-Sub-Filter | Text (mit AfterUpdate) | 🔴 Hoch |
| **txRechCheck** | Rechnung-Prüfung | Text | 🟠 Mittel |
| **txRechBezahlt** | Rechnung bezahlt am | Date | 🟠 Mittel |
| **txDatumDP** | Dienstplan-Datum | Date (Datum_DP field) | 🔴 Hoch |
| **Briefkopf** | Briefkopf-Text | Text/Memo | ✅ Implementiert (textarea) |
| **Anr** | Anrede | Text | 🟠 Mittel |
| **Anr_Brief** | Anrede für Brief | Text | 🟠 Mittel |
| **Anr_eMail** | Anrede für E-Mail | Text | 🟠 Mittel |
| **Text676** | Unbekannt | Date | 🟡 Niedrig |
| **Text678** | Unbekannt | Date | 🟡 Niedrig |
| **AU_von** | Arbeitsunfähig von | Date | 🔴 Hoch |
| **AU_bis** | Arbeitsunfähig bis | Date | 🔴 Hoch |
| **Erst_von** | Erstellt von | Text (readonly) | 🟠 Mittel |
| **Erst_am** | Erstellt am | Date (readonly) | 🟠 Mittel |
| **Aend_von** | Geändert von | Text (readonly) | 🟠 Mittel |
| **Aend_am** | Geändert am | Date (readonly) | 🟠 Mittel |

**Hinweis:** Erst_von, Erst_am, Aend_von, Aend_am sind in HTML als erstelltVon, erstelltAm, geaendertVon, geaendertAm implementiert (siehe elements).

---

### 1.3 ComboBoxen (17 in Access → 7 in HTML)

#### ✅ Implementiert (7)

| Access | HTML | RowSource | Status |
|--------|------|-----------|--------|
| Geschlecht | Geschlecht | tbl_Hlp_MA_Geschlecht | ✅ Hardcoded: männlich/weiblich |
| Anstellungsart | Anstellungsart_ID | tbl_hlp_MA_Anstellungsart | ✅ Hardcoded: 3,4,5 |
| Stundenlohn_brutto | Stundenlohn_brutto | zqry_ZK_Lohnarten_Zuschlag | ✅ Hardcoded: "BY Lohn 2a/b" |
| Fahrerlaubnis | Hat_Fahrerausweis | "ja";"nein" | ✅ Checkbox statt Dropdown |
| Taetigkeit_Bezeichnung | Taetigkeit_Bezeichnung | "Sicherheitspersonal";"Servicepersonal" | ✅ Hardcoded |
| Kleidergroesse | Kleidergroesse | "XS";"S";"M";"L";"XL";"XXL";"XXXL" | ✅ Hardcoded |
| Land | Land | - | ✅ Hardcoded: DE/AT/CH |

#### ❌ Fehlende ComboBoxen (10 kritisch)

| Access-Combo | Funktion | RowSource | AfterUpdate | Priorität |
|--------------|----------|-----------|-------------|-----------|
| **cboMonat** | Monatsfilter | _tblAlleMonate | ✅ JS: cboMonat_AfterUpdate | 🔴 Hoch |
| **cboJahr** | Jahresfilter | _tblAlleJahre | ✅ JS: cboJahr_AfterUpdate | 🔴 Hoch |
| **cboJahrJa** | Jahr Jahresübersicht | _tblAlleJahre | - | 🟠 Mittel |
| **cboFilterAuftrag** | Auftragsfilter | qry_MA_VA_Plan... | ✅ JS: cboFilterAuftrag_AfterUpdate | 🔴 Hoch |
| **pgJahrStdVorMon** | Jahr Std. Vormonat | _tblAlleJahre | - | 🟠 Mittel |
| **cboAuswahl** | Filter-Auswahl | 0-4: Telefon/§34a/Email/... | ✅ JS: cboAuswahl_AfterUpdate | 🔴 Hoch |
| **NurAktiveMA** | MA-Filter | 0-3: Alle/Aktiv/Fest/Mini | ✅ JS: NurAktiveMA_AfterUpdate | 🔴 Hoch |
| **MANameEingabe** | MA-Suche (Name) | SELECT ID, Nachname+Vorname... | ✅ JS: MANameEingabe_AfterUpdate | 🔴 Hoch |
| **cboIDSuche** | MA-Suche (ID) | SELECT ID, Nachname+Vorname... | ✅ JS: cboIDSuche_AfterUpdate | 🔴 Hoch |
| **Kombinationsfeld674** | Zeitraum? | _tblZeitraumAngaben | - | 🟡 Niedrig |
| **cboZeitraum** | Zeitraumfilter | _tblZeitraumAngaben | ✅ JS: cboZeitraum_AfterUpdate | 🟠 Mittel |

**Problem:** HTML nutzt `<input type="text" id="searchInput">` statt ComboBox für MA-Suche!

---

### 1.4 CheckBoxen (12 in Access → 14 in HTML)

#### ✅ Vollständig implementiert + 2 Extra

| Access | HTML | Status |
|--------|------|--------|
| IstAktiv | IstAktiv | ✅ |
| IstSubunternehmer | IstSubunternehmer | ✅ |
| Eigener_PKW | Eigener_PKW | ✅ |
| Ist_RV_Befrantrag | Ist_RV_Befrantrag | ✅ |
| IstNSB | IstNSB | ✅ |
| Hat_keine_34a | Hat_keine_34a | ✅ |
| HatSachkunde | HatSachkunde | ✅ |
| Lex_Aktiv | Lex_Aktiv | ✅ |
| cbMailAbrech | eMail_Abrechnung | ✅ |
| Modul1_DFB | Modul1_DFB | ✅ |
| TermineAbHeute | - | ❌ Fehlt in HTML |
| IstBrfAuto | - | ❌ Fehlt in HTML |
| - | Hat_Fahrerausweis | ✅ Extra (statt Combo) |
| - | Unterweisungs_34a | ✅ Extra |

---

### 1.5 ListBoxen (7 in Access → 1 in HTML)

#### ✅ Implementiert (1)

| Access | HTML | Funktion |
|--------|------|----------|
| lst_MA | maListTable (tbody) | MA-Liste (Nachname, Vorname, Ort) |

#### ❌ Fehlende ListBoxen (6 kritisch)

| Access-ListBox | Funktion | RowSource | Events | Priorität |
|----------------|----------|-----------|--------|-----------|
| **lst_Tl1M** | Jahresbilanz Teil 1 (Monat) | qry_JB_MA_Jahr_tl1A_Ue | - | 🟠 Mittel |
| **lst_Tl2M** | Jahresbilanz Teil 2 (Monat) | qry_JB_MA_Jahr_tl2A_Ue | BeforeUpdate: Macro | 🟠 Mittel |
| **lst_Tl1** | Jahresbilanz Teil 1 (Jahr) | qry_JB_MA_Jahr_tl1A_Ue | - | 🟠 Mittel |
| **lst_Tl2** | Jahresbilanz Teil 2 (Jahr) | qry_JB_MA_Jahr_tl2A_Ue | - | 🟠 Mittel |
| **lst_Zuo** | MA-Zuordnungen | qry_MA_VA_Plan_All_AufUeber2_Zuo | OnDblClick: Auftrag öffnen | 🔴 Hoch |
| **lstPl_Zuo** | Dienstplan-Zuordnungen | qry_Dienstplan | - | 🔴 Hoch |

**Problem:** `lst_Zuo` OnDblClick öffnet Auftragstamm - in HTML als `setupEinsaetzeDblClick()` implementiert!

---

### 1.6 Unterformulare (13 in Access → 7 iframes in HTML)

#### ✅ Implementiert (7)

| Access | HTML | LinkFields | Status |
|--------|------|------------|--------|
| Menü | ❌ Fehlt | - | Linke Sidebar ersetzt Menü |
| frmStundenübersicht | sub_MA_Stundenuebersicht.html | MA_ID | ✅ iframe |
| sub_MA_Dienstplan | sub_MA_Dienstplan.html | MA_ID | ✅ iframe (Tab "Dienstplan") |
| sub_MA_Zeitkonto | sub_MA_Zeitkonto.html | MA_ID | ✅ iframe (Tab "Zeitkonto") |
| sub_MA_Jahresuebersicht | sub_MA_Jahresuebersicht.html | MA_ID | ✅ iframe (Tab "Jahresübersicht") |
| sub_MA_Rechnungen | sub_MA_Rechnungen.html | MA_ID | ✅ iframe (Tab "Sub Rechnungen") |
| sub_MA_Dienstkleidung | ❌ Fehlt | MA_ID | Nur Table im Tab (kein iframe) |
| sub_MA_NVerfuegZeiten | ❌ Fehlt | MA_ID | Nur Table im Tab (kein iframe) |

#### ❌ Fehlende Subforms (6)

| Access | LinkMaster | LinkChild | Priorität |
|--------|------------|-----------|-----------|
| sub_MA_ErsatzEmail | ID | MA_ID | 🟠 Mittel |
| sub_MA_Einsatz_Zuo | ID | MA_ID | 🔴 Hoch (Einsätze!) |
| sub_tbl_MA_Zeitkonto_Aktmon2 | - | - | 🟠 Mittel |
| sub_tbl_MA_Zeitkonto_Aktmon1 | - | - | 🟠 Mittel |
| sub_tbltmp_MA_Ausgef_Vorlagen | - | - | 🟡 Niedrig |
| Untergeordnet360 (sub_tbl_MA_StundenFolgemonat) | ID, pgJahrStdVorMon | MA_ID, AktJahr | 🟠 Mittel |
| ufrm_Maps (sub_Browser) | - | - | 🟡 Niedrig (Button stattdessen) |
| subAuftragRech (sub_Auftrag_Rechnung_Gueni) | ID | MA_ID | 🔴 Hoch |
| subZuoStunden (zfrm_ZUO_Stunden_Sub_lb) | - | - | 🟠 Mittel |

---

## 2. EVENTS-VERGLEICH

### 2.1 Formular-Events

| Access Event | VBA | HTML Equivalent | Status |
|--------------|-----|-----------------|--------|
| OnOpen | Procedure | init() | ✅ |
| OnLoad | Procedure | DOMContentLoaded | ✅ |
| OnClose | Macro | closeForm() | ✅ |
| OnCurrent | Procedure | gotoRecord() | ✅ |
| BeforeUpdate | Procedure | - | ❌ |
| AfterUpdate | Procedure | saveRecord() | ✅ |
| OnError | Macro | try/catch | ✅ |
| OnTimer | Macro | - | ❌ |
| OnApplyFilter | Macro | - | ❌ |
| OnFilter | Macro | - | ❌ |
| OnUnload | Macro | - | ❌ |

---

### 2.2 Control-Events

#### ✅ Implementiert

**Navigation:**
- ✅ btnErster.onClick → navFirst()
- ✅ btnVorheriger.onClick → navPrev()
- ✅ btnNaechster.onClick → navNext()
- ✅ btnLetzter.onClick → navLast()

**Formular-Aktionen:**
- ✅ btnNeuMA.onClick → newRecord()
- ✅ btnSpeichern.onClick → saveRecord()
- ✅ btnLoeschen.onClick → deleteRecord()

**Externe Formulare:**
- ✅ btnZeitkonto.onClick → openZeitkonto()
- ✅ btnMAAdresse.onClick → openMAAdressen()
- ✅ btnDienstplan.onClick → openDienstplan()
- ✅ btnEinsatzuebersicht.onClick → openEinsatzübersicht()
- ✅ btnMATabelle.onClick → mitarbeiterTabelle()

**Excel-Export:**
- ✅ btnXLZeitkto.onClick → btnXLZeitkto_Click()
- ✅ btnXLJahr.onClick → btnXLJahr_Click()
- ✅ btnXLEinsUeber.onClick → btnXLEinsUeber_Click()
- ✅ btnXLDiePl.onClick → btnXLDiePl_Click()
- ✅ btnXLNverfueg.onClick → btnXLNverfueg_Click()
- ✅ btnXLUeberhangStd.onClick → btnXLUeberhangStd_Click()

**Zeitkonten:**
- ✅ btnZKFest.onClick → btnZKFest_Click()
- ✅ btnZKMini.onClick → btnZKMini_Click()
- ✅ btnZKeinzel.onClick → btnZKeinzel_Click()

**Sonstige:**
- ✅ btnMaps.onClick → openMaps()
- ✅ btnKoordinaten.onClick → getKoordinaten() (fehlt in Access-Export!)
- ✅ btnDateisuch.onClick → Foto Upload 1
- ✅ btnDateisuch2.onClick → btnDateisuch2_Click()

**DblClick-Events:**
- ✅ lst_Zuo.OnDblClick → setupEinsaetzeDblClick() (öffnet Auftragstamm)
- ✅ QuickInfo Einsätze DblClick → setupQuickInfoEinsaetzeDblClick()

**AfterUpdate-Events (in logic.js):**
- ✅ cboFilterAuftrag.AfterUpdate → cboFilterAuftrag_AfterUpdate(auftragId)
- ✅ cboIDSuche.AfterUpdate → cboIDSuche_AfterUpdate(maId)
- ✅ MANameEingabe.AfterUpdate → MANameEingabe_AfterUpdate()
- ✅ txRechSub.AfterUpdate → txRechSub_AfterUpdate(rechnungsNr)

#### ❌ Fehlende Events

**ComboBoxen AfterUpdate:**
- ❌ cboMonat_AfterUpdate - Monat gewechselt
- ❌ cboJahr_AfterUpdate - Jahr gewechselt
- ❌ cboAuswahl_AfterUpdate - Filter-Auswahl
- ❌ NurAktiveMA_AfterUpdate - MA-Filter (Alle/Aktiv/Fest/Mini)
- ❌ cboZeitraum_AfterUpdate - Zeitraum-Filter

**TextBoxen DblClick (Access hat 4 DblClick-Events):**
- ❌ DiDatumAb.OnDblClick - Datum auswählen
- ❌ Geb_Dat.OnDblClick - Geburtsdatum auswählen
- ❌ Eintrittsdatum.OnDblClick - Datum auswählen
- ❌ Austrittsdatum.OnDblClick - Datum auswählen

**CheckBoxen AfterUpdate:**
- ❌ IstSubunternehmer.AfterUpdate - Felder ein-/ausblenden
- ❌ TermineAbHeute.AfterUpdate - Terminfilter

**ListBox Events:**
- ❌ lst_MA.OnClick → MA wechseln (HTML nutzt tbody.onClick stattdessen) ✅
- ❌ lst_Tl2M.BeforeUpdate - Makro

---

## 3. FUNKTIONALITÄT-VERGLEICH

### 3.1 Datenanbindung

| Aspekt | Access | HTML | Status |
|--------|--------|------|--------|
| **RecordSource** | tbl_MA_Mitarbeiterstamm (direkt) | Bridge.mitarbeiter.list() API | ✅ |
| **AllowEdits** | True | saveRecord() mit PUT | ✅ |
| **AllowAdditions** | True | newRecord() mit POST | ✅ |
| **AllowDeletions** | True | deleteRecord() mit DELETE | ✅ |
| **Filter** | ID = 437 (SQL) | URL-Parameter ?ma_id=437 | ✅ |
| **OrderBy** | - | state.records.sort() (Nachname) | ✅ |
| **DefaultView** | Other (Einzelformular) | Einzelansicht + Liste | ✅ |
| **DataEntry** | False | - | ✅ |

---

### 3.2 Datenladen

**Access:**
```vba
' Form_Load
Private Sub Form_Load()
    Me.Filter = "ID = " & Forms!frm_Auswahl!MA_ID
    Me.FilterOn = True
End Sub
```

**HTML (logic.js):**
```javascript
async function loadList() {
    const params = { aktiv: state.nurAktive ? 1 : 0 };
    const result = await Bridge.mitarbeiter.list(params);
    state.records = result.data || result || [];
    state.records.sort((a,b) => a.Nachname.localeCompare(b.Nachname, 'de'));
    if (state.records.length > 0) await gotoRecord(0);
}
```

**Status:** ✅ Gleichwertig (API statt SQL)

---

### 3.3 Speichern

**Access:**
```vba
Private Sub Form_BeforeUpdate(Cancel As Integer)
    If IsNull(Me.Nachname) Then
        MsgBox "Nachname ist Pflichtfeld!"
        Cancel = True
    End If
End Sub
```

**HTML (logic.js):**
```javascript
async function saveRecord() {
    if (!validateRequired()) return; // Pflichtfelder prüfen
    const data = { Nachname, Vorname, ... };
    const id = getField('ID')?.value;
    if (id) {
        await Bridge.execute('updateMitarbeiter', { id, ...data });
    } else {
        await Bridge.execute('createMitarbeiter', data);
    }
    await loadList();
}
```

**Status:** ✅ Gleichwertig (Validierung + API-PUT/POST)

---

### 3.4 Kritische fehlende Funktionen

#### 🔴 HOCH-PRIORITÄT

1. **MA-Filter (NurAktiveMA ComboBox)**
   - Access: 0=Alle, 1=Aktiv, 2=Fest, 3=Mini
   - HTML: ❌ Fehlt - nur `filterSelect` Dropdown (hardcoded: standard/fest/mini/alle)
   - **Fix:** ComboBox mit AfterUpdate-Handler hinzufügen

2. **Auftragsfilter (cboFilterAuftrag)**
   - Access: ComboBox mit allen Aufträgen
   - HTML: ✅ Implementiert als `cboFilterAuftrag_AfterUpdate()`
   - **Status:** OK

3. **Monat/Jahr-Filter (cboMonat, cboJahr)**
   - Access: ComboBox für Zeitfilterung
   - HTML: ❌ Fehlt
   - **Auswirkung:** Zeitkonto/Jahresübersicht-Tabs nicht filterbar

4. **Arbeitsunfähigkeit (btnAU_Lesen, AU_von, AU_bis)**
   - Access: AU-Daten aus Datei importieren
   - HTML: ❌ Fehlt komplett
   - **Auswirkung:** Fehlzeiten nicht verwaltbar

5. **Dienstplan-Aktionen (btn_Dienstplan_prnt, btn_Dienstplan_send)**
   - Access: Dienstplan drucken/versenden
   - HTML: ❌ Fehlt
   - **Auswirkung:** Keine Dienstplan-Reports

6. **Jahreswechsel (btnUpdJahr)**
   - Access: Zeitkonten fortschreiben für neues Jahr
   - HTML: ❌ Fehlt
   - **Auswirkung:** Manueller Jahreswechsel nötig

7. **Subrechnungen (subAuftragRech, txRechSub)**
   - Access: Subunternehmer-Rechnungen verwalten
   - HTML: ✅ Logic implementiert (`txRechSub_AfterUpdate`), aber Subform fehlt
   - **Status:** Teilweise

#### 🟠 MITTEL-PRIORITÄT

8. **Foto/Signatur-Pfade (tblBilddatei, tblSignaturdatei)**
   - Access: Felder für Dateipfade
   - HTML: ❌ Felder fehlen (nur Upload-Buttons)
   - **Auswirkung:** Foto-Pfad nicht bearbeitbar

9. **Anreden (Anr, Anr_Brief, Anr_eMail)**
   - Access: 3 separate Anrede-Felder
   - HTML: ❌ Fehlt
   - **Auswirkung:** Serienbriefe nicht personalisierbar

10. **Mehrfachtermine (btnMehrfachtermine)**
    - Access: Serie von Terminen anlegen
    - HTML: ❌ Fehlt
    - **Auswirkung:** Termine einzeln erfassen

11. **Dienstkleidung-Report (btnReport_Dienstkleidung)**
    - Access: Bericht drucken
    - HTML: ❌ Fehlt
    - **Auswirkung:** Keine Ausgabe-Übersicht

12. **Erstellt/Geändert-Timestamps**
    - Access: Erst_von, Erst_am, Aend_von, Aend_am
    - HTML: ✅ Felder vorhanden (erstelltVon, erstelltAm, geaendertVon, geaendertAm)
    - **Status:** OK

---

## 4. SUBFORMS-VERGLEICH

### 4.1 Implementierte Subforms (iframes)

| Subform | HTML | Kommunikation | Status |
|---------|------|---------------|--------|
| frmStundenübersicht | sub_MA_Stundenuebersicht.html | postMessage mit MA_ID | ✅ |
| sub_MA_Dienstplan | sub_MA_Dienstplan.html | postMessage | ✅ |
| sub_MA_Zeitkonto | sub_MA_Zeitkonto.html | postMessage | ✅ |
| sub_MA_Jahresuebersicht | sub_MA_Jahresuebersicht.html | postMessage | ✅ |
| sub_MA_Rechnungen | sub_MA_Rechnungen.html | postMessage | ✅ |

---

### 4.2 Fehlende Subforms

| Subform | Funktion | LinkFields | Priorität |
|---------|----------|------------|-----------|
| **sub_MA_Einsatz_Zuo** | MA-Zuordnungen anzeigen | MA_ID | 🔴 Hoch |
| **subAuftragRech** | Subrechnungen | MA_ID | 🔴 Hoch |
| **sub_MA_ErsatzEmail** | Ersatz-E-Mail-Adressen | MA_ID | 🟠 Mittel |
| **sub_tbl_MA_Zeitkonto_Aktmon1/2** | Zeitkonto aktueller Monat | MA_ID | 🟠 Mittel |
| **sub_MA_StundenFolgemonat** | Stunden Folgemonat | MA_ID, AktJahr | 🟠 Mittel |
| **sub_tbltmp_MA_Ausgef_Vorlagen** | Ausgefüllte Vorlagen | MA_ID | 🟡 Niedrig |
| **ufrm_Maps** | Browser-Control für Maps | - | 🟡 Niedrig (Button) |
| **subZuoStunden** | Zuordnungen Stunden | MA_ID | 🟠 Mittel |

---

## 5. BEDINGTE FORMATIERUNG

### Access: FormatConditions

**lst_MA (MA-Liste):**
- **Regel:** `IstAktiv = False` → Schriftfarbe Rot (#FF0000)
- **HTML:** ✅ Implementiert in `renderList()`:
  ```javascript
  if (!isAktiv) {
      row.style.color = '#cc0000';
      row.title = 'Mitarbeiter inaktiv';
  }
  ```

**Weitere bedingte Formatierungen in Access nicht dokumentiert.**

---

## 6. API-ANBINDUNG

### 6.1 Verwendete Endpoints

**Mitarbeiter:**
- ✅ GET `/api/mitarbeiter` - Liste laden (mit Filter aktiv/anstellung)
- ✅ GET `/api/mitarbeiter/:id` - Details laden
- ✅ POST `/api/mitarbeiter` - Neuer MA anlegen
- ✅ PUT `/api/mitarbeiter/:id` - MA aktualisieren
- ✅ DELETE `/api/mitarbeiter/:id` - MA löschen

**Einsätze:**
- ✅ GET `/api/einsaetze?ma_id=X` - MA-Einsätze laden (cboFilterAuftrag_AfterUpdate)

**Subrechnungen:**
- ✅ GET `/api/subrechnungen?ma_id=X` - Subrechnungen laden (txRechSub_AfterUpdate)

**Geocoding:**
- ✅ GET `https://nominatim.openstreetmap.org/search` - Koordinaten ermitteln (getKoordinaten)

---

### 6.2 Fehlende Endpoints

| Funktion | Benötigter Endpoint | Priorität |
|----------|---------------------|-----------|
| AU-Daten importieren | POST /api/arbeitsunfaehigkeit/import | 🔴 Hoch |
| Dienstplan drucken | GET /api/dienstplan/pdf?ma_id=X | 🔴 Hoch |
| Dienstplan senden | POST /api/dienstplan/email | 🔴 Hoch |
| Jahreswechsel | POST /api/zeitkonto/jahreswechsel | 🔴 Hoch |
| Spiegelrechnung | POST /api/rechnungen/spiegelrechnung | 🟠 Mittel |
| Vorlagen-Import | POST /api/vorlagen/import | 🟠 Mittel |
| Dienstkleidung-Report | GET /api/dienstkleidung/report?ma_id=X | 🟠 Mittel |

---

## 7. TABS-VERGLEICH

### Access: TabControl "reg_MA" mit Pages

**Access hat keine expliziten Tab-Pages im Export - nur pgAdresse, pgMonat, etc.**

### HTML: 14 Tab-Buttons

| Tab | Inhalt | Status |
|-----|--------|--------|
| ✅ Stammdaten | Alle Felder | ✅ Vollständig |
| ✅ Einsatzübersicht | Table mit Einsätzen | ✅ (mit DblClick) |
| ✅ Dienstplan | iframe sub_MA_Dienstplan.html | ✅ |
| ✅ Nicht Verfügbar | Table + CRUD-Buttons | ✅ |
| ✅ Dienstkleidung | Table + Ausgabe/Rückgabe | ✅ |
| ✅ Zeitkonto | iframe sub_MA_Zeitkonto.html | ✅ |
| ✅ Jahresübersicht | iframe sub_MA_Jahresuebersicht.html | ✅ |
| ✅ Stundenübersicht | iframe sub_MA_Stundenuebersicht.html | ✅ |
| ✅ Vordrucke | Buttons für Vordrucke | ✅ |
| ✅ Briefkopf | textarea für Briefkopf | ✅ |
| ✅ Karte | Google Maps Link | ✅ |
| ✅ Sub Rechnungen | iframe sub_MA_Rechnungen.html | ✅ |
| ❌ Ueberhang Stunden | Table (hidden) | 🟠 Struktur da, aber hidden |
| ❌ Qualifikationen | Table (hidden) | 🟠 Struktur da, aber hidden |
| ❌ Dokumente | Table (hidden) | 🟠 Struktur da, aber hidden |
| ❌ Quick Info | Statistik-Karten (hidden) | 🟠 Struktur da, aber hidden |

**4 Tabs sind hidden (data-testid vorhanden, aber `hidden` Attribut):**
- `data-tab="ueberhangstunden"` - hidden
- `data-tab="qualifikationen"` - hidden
- `data-tab="dokumente"` - hidden
- `data-tab="quickinfo"` - hidden

---

## 8. WEBVIEW2-INTEGRATION

### webview2.js (128 Zeilen)

**Funktionen:**
- ✅ WebView2Bridge.onDataReceived() - Empfängt MA_ID von Access
- ✅ WebView2Bridge.setFormDataProvider() - Sendet Daten zurück
- ✅ collectMitarbeiterData() - Sammelt alle Felder
- ✅ hookButtons() - Verbindet Buttons mit VBA-Calls
  - btnSpeichern → WebView2Bridge.save()
  - btnSchliessen → WebView2Bridge.close()
  - btnNeu → sendToAccess('newRecord')
  - btnLoeschen → sendToAccess('delete')
  - btnZeitkonto → sendToAccess('openZeitkonto')
  - btnDienstausweis → sendToAccess('createDienstausweis')

**Status:** ✅ WebView2-Modus voll funktionsfähig

---

## 9. PRIORITÄTEN FÜR UMSETZUNG

### Phase 1: Kritische Lücken (🔴 Hoch)

1. **ComboBoxen mit AfterUpdate** (5 Stück)
   - cboMonat, cboJahr → Zeitfilterung
   - cboAuswahl, NurAktiveMA → MA-Filter
   - cboIDSuche, MANameEingabe → als ComboBox statt Input

2. **Fehlende Buttons** (6 Stück)
   - btnMADienstpl → Dienstplan öffnen
   - btnUpdJahr → Jahreswechsel
   - btnAU_Lesen → AU-Daten importieren
   - btnAUPl_Lesen → AU in Planung
   - btn_Dienstplan_prnt → Dienstplan drucken
   - btn_Dienstplan_send → Dienstplan versenden
   - Bericht_drucken → Berichte drucken

3. **Fehlende TextBoxen** (6 Stück)
   - DiDatumAb → Dienstplan ab Datum
   - Datum_34a → §34a Prüfungsdatum
   - AU_von, AU_bis → Arbeitsunfähigkeit
   - txRechSub → Rechnungs-Filter
   - txDatumDP → Dienstplan-Datum

4. **Fehlende ListBoxen** (2 Stück)
   - lst_Zuo → MA-Zuordnungen (mit DblClick)
   - lstPl_Zuo → Dienstplan-Zuordnungen

5. **Fehlende Subforms** (2 Stück)
   - sub_MA_Einsatz_Zuo → Einsätze-Subform
   - subAuftragRech → Subrechnungen-Subform

---

### Phase 2: Mittlere Priorität (🟠 Mittel)

6. **ComboBoxen** (3 Stück)
   - cboJahrJa, pgJahrStdVorMon, cboZeitraum

7. **Buttons** (8 Stück)
   - btnZuAb, btnLesen, btnRch, btnCalc, btnau_lesen2
   - btnMehrfachtermine, btnReport_Dienstkleidung
   - btn_MA_EinlesVorlageDatei, btnXLVordrucke

8. **TextBoxen** (10 Stück)
   - tblBilddatei, tblSignaturdatei
   - Amt_Pruefung, Datum_Pruefung
   - Mon_aktdat, EinsProMon, TagProMon
   - txRechCheck, txRechBezahlt
   - Anr, Anr_Brief, Anr_eMail

9. **CheckBoxen** (2 Stück)
   - TermineAbHeute, IstBrfAuto

10. **ListBoxen** (4 Stück)
    - lst_Tl1M, lst_Tl2M, lst_Tl1, lst_Tl2

11. **Subforms** (5 Stück)
    - sub_MA_ErsatzEmail
    - sub_tbl_MA_Zeitkonto_Aktmon1/2
    - sub_MA_StundenFolgemonat
    - subZuoStunden

12. **Hidden Tabs aktivieren** (4 Stück)
    - Ueberhang Stunden, Qualifikationen, Dokumente, Quick Info

---

### Phase 3: Niedrige Priorität (🟡 Niedrig)

13. **UI-Buttons** (4 Stück)
    - btnRibbonAus, btnRibbonEin, btnDaBaEin, btnDaBaAus

14. **TextBoxen** (4 Stück)
    - lbl_ab, Text676, Text678

15. **ComboBox** (1 Stück)
    - Kombinationsfeld674

16. **Subforms** (2 Stück)
    - sub_tbltmp_MA_Ausgef_Vorlagen
    - ufrm_Maps

---

## 10. BESONDERE MERKMALE

### 10.1 Access-spezifische Logik

**VBA-Makros (OnClick):**
- Access nutzt eingebettete Makros für Navigation-Buttons (Befehl39-43, Befehl46)
- HTML nutzt onclick="navFirst()" etc. → ✅ Gleichwertig

**AfterUpdate-Ketten:**
- cboFilterAuftrag → Einsätze neu laden
- cboIDSuche → MA wechseln
- IstSubunternehmer → Felder ein-/ausblenden (❌ fehlt in HTML)

**BeforeUpdate-Validierung:**
- Access: VBA-Code in Form_BeforeUpdate
- HTML: validateRequired() vor saveRecord() → ✅ Gleichwertig

---

### 10.2 HTML-spezifische Features

**Performance-Optimierungen:**
- ✅ fieldCache für schnellen DOM-Zugriff
- ✅ debounce() für Suche (300ms)
- ✅ Event Delegation für Tabellen

**Keyboard Shortcuts:**
- ✅ Ctrl+S → Speichern
- ✅ Ctrl+N → Neuer MA
- ✅ Ctrl+↑/↓ → Navigation

**State Management:**
```javascript
const state = {
    records: [],        // Alle geladenen MAs
    currentIndex: -1,   // Aktueller Index
    currentRecord: null, // Aktueller MA
    isDirty: false,     // Änderungen vorhanden
    nurAktive: true     // Filter: nur aktive MAs
};
```

**Auto-Save Feature:**
- Optional bei focusout → Kommentiert, könnte aktiviert werden

---

### 10.3 Quick Info Tab (hidden)

**Statistik-Karten:**
- qiAnzahlEinsaetze → Anzahl Einsätze (lfd. Jahr)
- qiGesamtstunden → Gesamtstunden
- qiZuverlaessigkeit → Zuverlässigkeit (%)
- qiRating → Rating (1-5 Sterne)

**Aktions-Buttons:**
- quickInfoSendEmail() → E-Mail senden
- quickInfoShowEinsatzplan() → Einsatzplan anzeigen
- quickInfoShowDokumente() → Dokumente-Tab aktivieren
- quickInfoShowNotizen() → Notizen-Tab aktivieren

**Status:** ⚠️ Struktur komplett, aber `hidden` → Nur aktivieren nötig!

---

## 11. FAZIT

### Stärken (HTML)

✅ **Modernere UI:**
- Bessere Übersichtlichkeit mit Tabs
- Responsive Layout (bei Bedarf)
- Inline-Foto-Upload
- Google Maps Integration

✅ **Bessere Performance:**
- Client-seitiges Caching
- Debouncing bei Suche
- Event Delegation

✅ **Keyboard-Support:**
- Ctrl+S, Ctrl+N, Ctrl+↑/↓

✅ **API-basiert:**
- REST-API statt SQL
- Einfach testbar
- Entkoppelt von Access

---

### Schwächen (HTML)

❌ **Fehlende Business-Logik:**
- Jahreswechsel (btnUpdJahr)
- AU-Daten-Import (btnAU_Lesen)
- Dienstplan drucken/senden
- Mehrfachtermine

❌ **Fehlende Filter:**
- Monat/Jahr-ComboBoxen (cboMonat, cboJahr)
- Auftrags-Filter (teilweise implementiert)
- MA-Filter als Input statt ComboBox

❌ **Fehlende Subforms:**
- Einsätze-Zuordnungen (sub_MA_Einsatz_Zuo)
- Subrechnungen (subAuftragRech)
- Zeitkonto aktueller Monat

❌ **Fehlende Reports:**
- Bericht_drucken Button
- Dienstkleidung-Report
- Excel-Vordrucke

---

### Empfehlungen

**Sofort umsetzen (Phase 1):**
1. ComboBoxen mit AfterUpdate (cboMonat, cboJahr, NurAktiveMA)
2. AU-Felder (AU_von, AU_bis, btnAU_Lesen)
3. Dienstplan-Buttons (drucken, senden)
4. ListBox lst_Zuo mit DblClick (Einsätze)
5. Subform sub_MA_Einsatz_Zuo

**Mittelfristig (Phase 2):**
6. Jahreswechsel-Logik (btnUpdJahr)
7. Subrechnungen-Subform (subAuftragRech)
8. Anreden-Felder (Anr, Anr_Brief, Anr_eMail)
9. Hidden Tabs aktivieren (QuickInfo, Qualifikationen, Dokumente)

**Optional (Phase 3):**
10. UI-Buttons (Ribbon, DaBa) → Nicht relevant für WebView2
11. Jahresbilanz-ListBoxen (lst_Tl1M/2M/1/2)

---

**Gesamtbewertung:** 60% Parität erreicht
**Fehlende Buttons:** 12 von 41 (29%)
**Fehlende Felder:** 16 von 70 (23%)
**Fehlende ComboBoxen:** 10 von 17 (59%)
**Fehlende ListBoxen:** 6 von 7 (86%)
**Fehlende Subforms:** 6 von 13 (46%)

**Handlungsempfehlung:** Phase 1 umsetzen für kritische Geschäftsprozesse (Zeitkonto, Dienstplan, Einsätze).
