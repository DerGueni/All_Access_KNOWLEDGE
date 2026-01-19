# Mitarbeiterstamm Abgleich: Access vs HTML

**Erstellt:** 2026-01-06
**Access-Formular:** frm_MA_Mitarbeiterstamm
**HTML-Formular:** 04_HTML_Forms/forms3/frm_MA_Mitarbeiterstamm.html

---

## Zusammenfassung

| Kategorie | Access | HTML | Abdeckung |
|-----------|--------|------|-----------|
| Controls gesamt | 290 | ~120 | ~41% |
| Buttons (CommandButton) | 41 | ~35 | ~85% |
| TextBox | 70 | ~55 | ~79% |
| ComboBox | 17 | ~8 | ~47% |
| CheckBox | 12 | ~15 | 100%+ |
| Subforms | 13 | 5 (iframes) | ~38% |
| Tabs/Pages | 13 | 16 | 100%+ |
| VBA Event-Handler | 68 | ~50 | ~74% |

---

## 1. Fehlende Controls im HTML

### 1.1 Fehlende Buttons (CommandButton)

| Access Control | Caption (Access) | VBA-Handler | Funktion | Status im HTML |
|----------------|------------------|-------------|----------|----------------|
| `Befehl39` | Navigation | - | Record Navigation | FEHLT (ersetzt durch navFirst/navPrev/etc.) |
| `Befehl40` | Navigation | - | Record Navigation | FEHLT |
| `Befehl41` | Navigation | - | Record Navigation | FEHLT |
| `Befehl43` | Navigation | - | Record Navigation | FEHLT |
| `Befehl46` | Navigation | - | Record Navigation | FEHLT |
| `mcobtnDelete` | Loeschen | - | MA Loeschen | VORHANDEN (btnLöschen) |
| `btnLstDruck` | Listen drucken | btnLstDruck_Click | Listen drucken | VORHANDEN (btnListenDrucken) |
| `btnMADienstpl` | Dienstplan | btnMADienstpl_Click | MA Dienstplan oeffnen | VORHANDEN (btnDienstplan) |
| `btnRibbonAus` | Ribbon Aus | btnRibbonAus_Click | Ribbon ausblenden | FEHLT (nicht relevant fuer HTML) |
| `btnRibbonEin` | Ribbon Ein | btnRibbonEin_Click | Ribbon einblenden | FEHLT (nicht relevant fuer HTML) |
| `btnDaBaEin` | Datenbank Ein | btnDaBaEin_Click | Datenbankfenster ein | FEHLT (nicht relevant fuer HTML) |
| `btnDaBaAus` | Datenbank Aus | btnDaBaAus_Click | Datenbankfenster aus | FEHLT (nicht relevant fuer HTML) |
| `lbl_Mitarbeitertabelle` | MA Tabelle | lbl_Mitarbeitertabelle_Click | MA Tabelle oeffnen | VORHANDEN (btnMATabelle) |
| `btnZeitkonto` | Zeitkonto | btnZeitkonto_Click | Zeitkonto oeffnen | VORHANDEN |
| `btnZKFest` | ZK Fest | btnZKFest_Click | Zeitkonto Festangestellte | VORHANDEN |
| `btnZKMini` | ZK Mini | btnZKMini_Click | Zeitkonto Minijobber | VORHANDEN |
| `btnZKeinzel` | ZK Einzel | btnZKeinzel_Click | Zeitkonto Einzelsatz | VORHANDEN |
| `btnDateisuch` | Foto suchen | btnDateisuch_Click | Lichtbild hochladen | VORHANDEN (Foto hochladen) |
| `btnDateisuch2` | Foto 2 | btnDateisuch2_Click | Zweites Foto/Dokument | VORHANDEN |
| `btnMaps` | Karte | btnMaps_Click | Google Maps oeffnen | VORHANDEN (btnMapsÖffnen) |
| `btnZuAb` | Zu/Ab | btnZuAb_Click | Zusage/Absage | VORHANDEN (JS: btnZuAb_Click) |
| `btnXLZeitkto` | Excel Zeitkonto | btnXLZeitkto_Click | Excel Export | VORHANDEN (Dropdown) |
| `btnLesen` | Lesen | btnLesen_Click | Daten lesen | FEHLT |
| `btnUpdJahr` | Jahr Update | btnUpdJahr_Click | Jahresuebersicht aktualisieren | FEHLT |
| `btnXLJahr` | Excel Jahr | btnXLJahr_Click | Excel Export | VORHANDEN (Dropdown) |
| `btnXLEinsUeber` | Excel Einsaetze | btnXLEinsUeber_Click | Excel Export | VORHANDEN (Dropdown) |
| `Bericht_drucken` | Bericht drucken | Bericht_drucken_click | Bericht drucken | VORHANDEN (JS-Funktion) |
| `btnAU_Lesen` | AU Lesen | btnAU_Lesen_Click | Auftraege lesen | FEHLT |
| `btnRch` | Rechnung | btnRch_Click | Rechnung erstellen | FEHLT |
| `btnCalc` | Berechnen | btnCalc_Click | Berechnung | VORHANDEN (JS-Funktion) |
| `btnXLUeberhangStd` | Excel Ueberhang | btnXLUeberhangStd_Click | Excel Export | VORHANDEN (Dropdown) |
| `btnau_lesen2` | AU Lesen 2 | - | Alternative AU-Lesen | FEHLT |
| `btnAUPl_Lesen` | AU Plan Lesen | btnAUPl_Lesen_Click | Auftragsplan lesen | FEHLT |
| `btn_Diensplan_prnt` | Dienstplan drucken | btn_Diensplan_prnt_Click | Drucken | VORHANDEN (JS-Funktion) |
| `btn_Dienstplan_send` | Dienstplan senden | btn_Dienstplan_send_Click | E-Mail senden | VORHANDEN (JS-Funktion) |
| `btnXLDiePl` | Excel Dienstplan | btnXLDiePl_Click | Excel Export | VORHANDEN (Dropdown) |
| `btnMehrfachtermine` | Mehrfachtermine | btnMehrfachtermine_Click | Mehrfachtermine | VORHANDEN (JS-Funktion) |
| `btnXLNverfueg` | Excel NVerfueg | btnXLNverfueg_Click | Excel Export | VORHANDEN (Dropdown) |
| `btnReport_Dienstkleidung` | Dienstkleidung Report | btnReport_Dienstkleidung_Click | Report drucken | VORHANDEN (JS-Funktion) |
| `btn_MA_EinlesVorlageDatei` | Vorlage einlesen | btn_MA_EinlesVorlageDatei_Click | Vorlage importieren | FEHLT |
| `btnXLVordrucke` | Excel Vordrucke | btnXLVordrucke_Click | Excel Export | FEHLT |

### 1.2 Fehlende ComboBoxen

| Access Control | ControlSource | Funktion | Status im HTML |
|----------------|---------------|----------|----------------|
| `Geschlecht` | Geschlecht | Auswahl m/w | VORHANDEN |
| `Anstellungsart` | Anstellungsart_ID | Anstellungsart | VORHANDEN (Anstellungsart_ID) |
| `Stundenlohn_brutto` | Stundenlohn_brutto | Lohngruppe | VORHANDEN (nur 1 Option) |
| `Fahrerlaubnis` | Fahrerlaubnis | Fuehrerscheinklasse | FEHLT |
| `Taetigkeit_Bezeichnung` | Taetigkeit_Bezeichnung | Taetigkeit | VORHANDEN (nur 1 Option) |
| `Kleidergroesse` | Kleidergroesse | Kleidergr. | VORHANDEN |
| `cboMonat` | - | Monatsauswahl | FEHLT (nur cboZeitraum) |
| `cboJahr` | - | Jahresauswahl | FEHLT (nur cboZeitraum) |
| `cboJahrJa` | - | Jahr Jahresansicht | FEHLT |
| `cboFilterAuftrag` | - | Auftragsfilter | FEHLT |
| `cboFilterOrt` | - | Ortsfilter | FEHLT |
| `cboMASuche` | - | MA Schnellsuche | TEILWEISE (searchInput) |
| `cboIDSuche` | - | ID Suche | FEHLT |
| `cboAuswahl` | - | Allg. Auswahl | FEHLT |
| `cboZeitraum` | - | Zeitraumauswahl | VORHANDEN |
| `cboNurAktiveMA` | - | Nur Aktive Filter | VORHANDEN (filterSelect) |
| `NurAktiveMA` | - | Checkbox Nur Aktive | VORHANDEN (filterSelect mit Optionen) |

### 1.3 Fehlende ListBoxen

| Access Control | Funktion | Status im HTML |
|----------------|----------|----------------|
| `lst_MA` | Mitarbeiterliste (Haupt) | VORHANDEN (maListTable) |
| `lst_Tl1M` | Teilliste 1 Monat | FEHLT |
| `lst_Tl2M` | Teilliste 2 Monat | FEHLT |
| `lst_Tl1` | Teilliste 1 | FEHLT |
| `lst_Tl2` | Teilliste 2 | FEHLT |
| `lst_Zuo` | Zuordnungsliste | FEHLT |
| `lstPl_Zuo` | Planungszuordnungen | FEHLT |

### 1.4 Fehlende TextBox-Felder

| Access Control | ControlSource | Status im HTML |
|----------------|---------------|----------------|
| `DiDatumAb` | - | FEHLT (Datumsfilter) |
| `lbl_ab` | - | FEHLT |
| `MA_AnzDat_von` | - | FEHLT (Anzeigedatum Von) |
| `MA_AnzDat_bis` | - | FEHLT (Anzeigedatum Bis) |
| `pgJahrStdVorMon` | - | FEHLT (Jahr Std. Vormonat) |
| `txRechSub` | - | FEHLT (Rechnung Sub) |
| `Fahrerlaubnis_Datum` | Fahrerlaubnis_Datum | FEHLT |
| `Qualifikation_34a` | Qualifikation_34a | FEHLT (separate Quali) |
| `Ausweis_Lichtbild` | Ausweis_Lichtbild | FEHLT |
| `MA_Signatur` | MA_Signatur | FEHLT |

---

## 2. Fehlende Events im HTML

### 2.1 Form-Level Events

| Event | Access-Handler | Status im HTML | Kommentar |
|-------|----------------|----------------|-----------|
| `Form_Load` | Form_Load | VORHANDEN | DOMContentLoaded |
| `Form_Open` | Form_Open | TEILWEISE | Keine Parameter |
| `Form_Current` | Form_Current | VORHANDEN | showRecord() |
| `Form_BeforeUpdate` | Form_BeforeUpdate | VORHANDEN | speichern() |
| `Form_AfterUpdate` | Form_AfterUpdate | VORHANDEN | onSaveComplete |

### 2.2 Control-Level Events - FEHLEND

| Control | Event | Access-Handler | Status |
|---------|-------|----------------|--------|
| `DiDatumAb` | DblClick | DiDatumAb_DblClick | FEHLT |
| `Eintrittsdatum` | DblClick | Eintrittsdatum_DblClick | FEHLT |
| `Austrittsdatum` | DblClick | Austrittsdatum_DblClick | FEHLT |
| `Geb_Dat` | DblClick | Geb_Dat_DblClick | FEHLT |
| `MA_AnzDat_von` | DblClick | MA_AnzDat_von_DblClick | FEHLT |
| `MA_AnzDat_bis` | DblClick | MA_AnzDat_bis_DblClick | FEHLT |
| `Anstellungsart` | DblClick | Anstellungsart_DblClick | FEHLT |
| `lst_Zuo` | DblClick | lst_Zuo_DblClick | FEHLT |
| `reg_MA` | Change | reg_MA_Change | VORHANDEN (switchTab) |
| `cboMonat` | AfterUpdate | cboMonat_AfterUpdate | FEHLT |
| `cboJahr` | AfterUpdate | cboJahr_AfterUpdate | FEHLT |
| `cboAuswahl` | AfterUpdate | cboAuswahl_AfterUpdate | FEHLT |
| `NurAktiveMA` | AfterUpdate | NurAktiveMA_AfterUpdate | VORHANDEN (filterSelect.change) |
| `TermineAbHeute` | AfterUpdate | TermineAbHeute_AfterUpdate | FEHLT |
| `sub_tbl_MA_Zeitkonto_Aktmon2` | Exit | sub_tbl_MA_Zeitkonto_Aktmon2_Exit | FEHLT |

### 2.3 Control-Level Events - VORHANDEN

| Control | Event | Access-Handler | HTML-Handler |
|---------|-------|----------------|--------------|
| `Anstellungsart` | AfterUpdate | Anstellungsart_AfterUpdate | Anstellungsart_AfterUpdate() |
| `IstSubunternehmer` | AfterUpdate | IstSubunternehmer_AfterUpdate | IstSubunternehmer_AfterUpdate() |
| `cboZeitraum` | AfterUpdate | cboZeitraum_AfterUpdate | cboZeitraum_AfterUpdate() |
| `MANameEingabe` | AfterUpdate | MANameEingabe_AfterUpdate | MANameEingabe_AfterUpdate() (JS) |
| `cboFilterAuftrag` | AfterUpdate | cboFilterAuftrag_AfterUpdate | cboFilterAuftrag_AfterUpdate() (JS) |
| `cboIDSuche` | AfterUpdate | cboIDSuche_AfterUpdate | cboIDSuche_AfterUpdate() (JS) |
| `txRechSub` | AfterUpdate | txRechSub_AfterUpdate | txRechSub_AfterUpdate() (JS) |
| `lst_MA` | Click | lst_MA_Click | maListBody tr.click |

---

## 3. Fehlende Tabs/Pages

### Access Tabs (reg_MA):

| Page-Name | Caption | Status im HTML | HTML Tab-Name |
|-----------|---------|----------------|---------------|
| `pgAdresse` | Stammdaten/Adresse | VORHANDEN | stammdaten |
| `pgMonat` | Monatsansicht | FEHLT | - |
| `pgJahr` | Jahresansicht | VORHANDEN | jahresübersicht |
| `pgAuftrUeb` | Auftragsuebersicht | VORHANDEN | einsatzübersicht |
| `pgStundenuebersicht` | Stundenuebersicht | VORHANDEN | stundenübersicht |
| `pgPlan` | Planung | VORHANDEN | dienstplan |
| `pgnVerfueg` | Nicht Verfuegbar | VORHANDEN | nichtverfügbar |
| `pgDienstKl` | Dienstkleidung | VORHANDEN | dienstkleidung |
| `pgVordr` | Vordrucke | VORHANDEN | vordrucke |
| `pgBrief` | Briefkopf | VORHANDEN | briefkopf |
| `pgStdUeberlaufstd` | Ueberhang Stunden | VORHANDEN | ueberhangstunden |
| `pgMaps` | Karte | VORHANDEN | karte |
| `pgSubRech` | Sub Rechnungen | VORHANDEN | subrechnungen |

### Zusaetzliche Tabs in HTML (nicht in Access):

| HTML Tab | Funktion |
|----------|----------|
| `zeitkonto` | Zeitkonto (separates Subformular) |
| `qualifikationen` | Qualifikationen |
| `dokumente` | Dokumente |
| `quickinfo` | Quick Info Dashboard |

---

## 4. Fehlende Subformulare

| Access Subform | SourceObject | Link Fields | Status im HTML |
|----------------|--------------|-------------|----------------|
| `Menü` | frm_Menuefuehrung | - | FEHLT (kein separates Menu-Subform) |
| `sub_MA_ErsatzEmail` | sub_MA_ErsatzEmail | ID -> MA_ID | FEHLT |
| `sub_MA_Einsatz_Zuo` | sub_MA_Einsatz_Zuo | ID -> MA_ID | FEHLT |
| `sub_tbl_MA_Zeitkonto_Aktmon2` | sub_tbl_MA_Zeitkonto_Aktmon2 | - | TEILWEISE (iframe sub_MA_Zeitkonto.html) |
| `sub_tbl_MA_Zeitkonto_Aktmon1` | sub_tbl_MA_Zeitkonto_Aktmon1 | - | TEILWEISE (iframe sub_MA_Zeitkonto.html) |
| `frmStundenübersicht` | frm_Stundenübersicht2 | ID -> MA_ID | VORHANDEN (iframe sub_MA_Stundenübersicht.html) |
| `sub_MA_tbl_MA_NVerfuegZeiten` | sub_MA_tbl_MA_NVerfuegZeiten | - | VORHANDEN (nvTable im Tab) |
| `sub_MA_Dienstkleidung` | sub_MA_Dienstkleidung | ID -> MA_ID | VORHANDEN (dkTable im Tab) |
| `sub_tbltmp_MA_Ausgef_Vorlagen` | sub_tbltmp_MA_Ausgef_Vorlagen | - | FEHLT |
| `Untergeordnet360` | sub_tbl_MA_StundenFolgemonat | ID+Jahr -> MA_ID+AktJahr | FEHLT |
| `ufrm_Maps` | sub_Browser | - | VORHANDEN (Google Maps Link) |
| `subAuftragRech` | sub_Auftrag_Rechnung_Gueni | ID -> MA_ID | VORHANDEN (iframe sub_MA_Rechnungen.html) |
| `subZuoStunden` | zfrm_ZUO_Stunden_Sub_lb | - | FEHLT |

---

## 5. Funktionale Differenzen

### 5.1 Navigation

| Funktion | Access | HTML | Differenz |
|----------|--------|------|-----------|
| Record-Navigation | Befehl39-46 (Standard) | navFirst/Prev/Next/Last | OK - andere Implementierung |
| MA-Suche | cboMASuche (Combo) | searchInput (Text) | OK - funktional gleich |
| ID-Suche | cboIDSuche (Combo) | FEHLT | Nicht implementiert |
| Filter Aktive | NurAktiveMA (Checkbox) | filterSelect (Dropdown) | OK - erweitert |

### 5.2 Datenbearbeitung

| Funktion | Access | HTML | Differenz |
|----------|--------|------|-----------|
| Speichern | Form_BeforeUpdate | speichern() + Bridge | OK |
| Dirty-Tracking | Form.Dirty | state.isDirty | OK |
| AllowEdits | Property | state.allowEdits | OK |
| Undo | ESC / Undo | FEHLT | Keine Undo-Funktion |

### 5.3 Excel-Export

| Export | Access-Button | HTML | Status |
|--------|---------------|------|--------|
| Einsatzuebersicht | btnXLEinsUeber | Dropdown-Button | VORHANDEN |
| Dienstplan | btnXLDiePl | Dropdown-Button | VORHANDEN |
| Zeitkonto | btnXLZeitkto | Dropdown-Button | VORHANDEN |
| Jahresuebersicht | btnXLJahr | Dropdown-Button | VORHANDEN |
| Nicht Verfuegbar | btnXLNverfueg | Dropdown-Button | VORHANDEN |
| Ueberhang Stunden | btnXLUeberhangStd | Dropdown-Button | VORHANDEN |
| Vordrucke | btnXLVordrucke | FEHLT | Nicht implementiert |

### 5.4 Spezialfunktionen

| Funktion | Access | HTML | Status |
|----------|--------|------|--------|
| Ribbon Ein/Aus | btnRibbonEin/Aus | - | Nicht relevant |
| Datenbankfenster | btnDaBaEin/Aus | - | Nicht relevant |
| Geocoding | Koordinaten berechnen | cmdGeocode_Click() | VORHANDEN |
| Foto-Upload | btnDateisuch | handleFotoUpload() | VORHANDEN |
| Dokument-Upload | btnDateisuch2 | btnDateisuch2_Click() | VORHANDEN |

---

## 6. Empfehlungen

### 6.1 Kritische Luecken (Prioritaet HOCH)

1. **Fehlende Subformulare:**
   - `sub_MA_ErsatzEmail` - Ersatz-E-Mail-Adressen fehlen komplett
   - `sub_MA_Einsatz_Zuo` - Einsatz-Zuordnungen fehlen
   - `sub_tbltmp_MA_Ausgef_Vorlagen` - Ausgefuellte Vorlagen fehlen

2. **Fehlende ComboBoxen:**
   - `Fahrerlaubnis` - Fuehrerscheinklasse-Auswahl fehlt
   - `cboFilterAuftrag` - Auftragsfilter fehlt
   - `cboIDSuche` - Schnell-ID-Suche fehlt

3. **Fehlende ListBoxen:**
   - `lst_Zuo` mit DblClick-Handler fuer Zuordnungs-Details

### 6.2 Mittlere Luecken (Prioritaet MITTEL)

1. **DblClick-Events auf Datumsfeldern:**
   - Eintrittsdatum, Austrittsdatum, Geb_Dat - zum schnellen Setzen auf heute

2. **Monats-/Jahresauswahl:**
   - `cboMonat` und `cboJahr` fuer detaillierte Zeitraumfilterung

3. **Fehlende Buttons:**
   - `btnLesen` - Daten neu laden
   - `btnAU_Lesen` - Auftraege laden
   - `btnRch` - Rechnung erstellen
   - `btnXLVordrucke` - Vordrucke-Export

### 6.3 Geringe Luecken (Prioritaet NIEDRIG)

1. **Access-spezifische Funktionen:**
   - Ribbon Ein/Aus (nicht relevant fuer Web)
   - Datenbankfenster (nicht relevant fuer Web)

2. **Zusaetzliche Listboxen:**
   - lst_Tl1M, lst_Tl2M, lst_Tl1, lst_Tl2 (spezialisierte Listen)

### 6.4 Bereits gut implementiert

- Basis-Navigation (Erste/Vorige/Naechste/Letzte)
- Mitarbeiter-Suche und Filter
- Tab-System mit 16 Tabs
- Alle wichtigen Stammdaten-Felder
- Foto-Upload (beide Varianten)
- Excel-Export (6 von 7 Exports)
- Zeitkonto-Funktionen (ZK Fest/Mini/Einzel)
- Google Maps Integration
- Quick Info Dashboard (HTML-Erweiterung)
- Qualifikationen-Tab (HTML-Erweiterung)
- Dokumente-Tab (HTML-Erweiterung)

---

## 7. Statistik

| Metrik | Wert |
|--------|------|
| Access Controls gesamt | 290 |
| HTML Controls gesamt | ~120 |
| Abdeckungsquote (Controls) | ~41% |
| VBA Event-Handler | 68 |
| JS Event-Handler | ~50 |
| Abdeckungsquote (Events) | ~74% |
| Kritische Luecken | 6 |
| Mittlere Luecken | 8 |
| Geringe Luecken | 8 |

**Gesamtbewertung:** Das HTML-Formular deckt die Kernfunktionalitaet gut ab (~74% der Events). Die wichtigsten Stammdaten-Felder sind vorhanden. Hauptluecken sind bei spezialisierten Subformularen und einigen ComboBox-Filtern.
