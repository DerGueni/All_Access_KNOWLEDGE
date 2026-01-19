# ACCESS -> HTML BUTTON / CONTROL MAPPING

**Erstellt:** 2026-01-07
**Autor:** Claude Code (E2E AGENT 5)
**Arbeitsverzeichnis:** C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE

---

## Formular: frm_va_Auftragstamm

**HTML-Datei:** `04_HTML_Forms/forms3/frm_va_Auftragstamm.html`
**Logic-Dateien:**
- `logic/frm_va_Auftragstamm.logic.js`
- `logic/frm_va_Auftragstamm.webview2.js`
- `logic/frm_va_Auftragstamm.logicALT.js`

### A) BUTTONS

#### 1) Button: Vollbild
- **Access:**
  - Control-Name: (kein Aequivalent)
  - Caption: -
  - Event: -
  - VBA/Macro: -
  - Access-Aktion: -

- **HTML:**
  - Selector: `#fullscreenBtn`
  - Handler: `toggleFullscreen()`
  - API-Call: Keine (Browser Fullscreen API)
  - Ergebnis: Browser Fullscreen umschalten
  - **Paritaet: NICHT VORHANDEN IN ACCESS**

#### 2) Button: Minimieren
- **Access:**
  - Control-Name: Window Controls
  - Event: OnClick
  - VBA/Macro: DoCmd.Minimize

- **HTML:**
  - Selector: `.title-btn` (erster Button)
  - Handler: `Bridge.sendEvent('minimize')`
  - Ergebnis: Minimiert via WebView2 Bridge
  - **Paritaet: PASS**

#### 3) Button: Maximieren
- **Access:**
  - Control-Name: Window Controls
  - Event: OnClick
  - VBA/Macro: DoCmd.Maximize

- **HTML:**
  - Selector: `.title-btn` (zweiter Button)
  - Handler: `toggleMaximize()`
  - Ergebnis: Maximiert das Fenster
  - **Paritaet: PASS**

#### 4) Button: Schliessen
- **Access:**
  - Control-Name: Befehl0 / X-Button
  - Event: OnClick
  - VBA/Macro: DoCmd.Close

- **HTML:**
  - Selector: `.title-btn.close`
  - Handler: `closeForm()`
  - Ergebnis: Schliesst das Formular
  - **Paritaet: PASS**

#### 5) Button: Aktualisieren
- **Access:**
  - Control-Name: btnReq
  - Caption: Aktualisieren
  - Event: OnClick
  - VBA/Macro: Form.Requery

- **HTML:**
  - Selector: `#btnAktualisieren`
  - Handler: `refreshData()`
  - API-Call: GET /api/auftraege/{id}
  - Ergebnis: Laedt aktuelle Daten neu
  - **Paritaet: PASS**

#### 6) Button: Mitarbeiterauswahl (Schnellplan)
- **Access:**
  - Control-Name: btnSchnellPlan
  - Caption: Schnellauswahl
  - Event: OnClick
  - VBA/Macro: DoCmd.OpenForm "frm_MA_VA_Schnellauswahl"

- **HTML:**
  - Selector: `#btnSchnellPlan`
  - Handler: `openMitarbeiterauswahl()`
  - API-Call: Keine (Navigation)
  - Ergebnis: Oeffnet Mitarbeiterauswahl-Dialog
  - **Paritaet: PASS**

#### 7) Button: Positionen
- **Access:**
  - Control-Name: btn_Posliste_oeffnen
  - Caption: Positionen
  - Event: OnClick
  - VBA/Macro: DoCmd.OpenForm "frm_OB_Positionen"

- **HTML:**
  - Selector: `#btnPositionen`
  - Handler: `openPositionen()`
  - Ergebnis: Oeffnet Positionen-Formular
  - **Paritaet: PASS**

#### 8) Button: Neuer Auftrag
- **Access:**
  - Control-Name: btnneuveranst
  - Caption: Neuer Auftrag
  - Event: OnClick
  - VBA/Macro: DoCmd.GoToRecord , , acNewRec

- **HTML:**
  - Selector: `#btnNeuAuftrag`
  - Handler: `neuerAuftrag()`
  - API-Call: POST /api/auftraege (bei Speichern)
  - Ergebnis: Erstellt neuen leeren Datensatz
  - **Paritaet: PASS**

#### 9) Button: Auftrag kopieren
- **Access:**
  - Control-Name: btnPlan_Kopie
  - Caption: Kopieren
  - Event: OnClick
  - VBA/Macro: mod_VA_Copy.CopyAuftrag

- **HTML:**
  - Selector: `#btnKopieren`
  - Handler: `auftragKopieren()`
  - API-Call: POST /api/auftraege/copy
  - Ergebnis: Kopiert aktuellen Auftrag
  - **Paritaet: PASS**

#### 10) Button: Auftrag loeschen
- **Access:**
  - Control-Name: mcobtnDelete
  - Caption: Loeschen
  - Event: OnClick
  - VBA/Macro: DoCmd.RunCommand acCmdDeleteRecord

- **HTML:**
  - Selector: `#btnLoeschen`
  - Handler: `auftragLoeschen()`
  - API-Call: DELETE /api/auftraege/{id}
  - Ergebnis: Loescht aktuellen Auftrag nach Bestaetigung
  - **Paritaet: PASS**

#### 11) Button: Namensliste ESS
- **Access:**
  - Control-Name: btn_ListeStd
  - Caption: Liste Std
  - Event: OnClick
  - VBA/Macro: DoCmd.OpenReport "rpt_Namensliste_ESS"

- **HTML:**
  - Selector: `#btnListeStd`
  - Handler: `namenslisteESS()`
  - Ergebnis: Generiert Namensliste-Report
  - **Paritaet: PASS**

#### 12) Button: Einsatzliste drucken
- **Access:**
  - Control-Name: btnDruckZusage
  - Caption: EL drucken
  - Event: OnClick
  - VBA/Macro: mod_Print.PrintEinsatzliste

- **HTML:**
  - Selector: `#btnDruckZusage`
  - Handler: `einsatzlisteDrucken()`
  - Ergebnis: Druckt Einsatzliste als PDF
  - **Paritaet: PASS**

#### 13) Button: EL senden MA
- **Access:**
  - Control-Name: btnMailEins
  - Caption: EL senden MA
  - Event: OnClick
  - VBA/Macro: mod_Mail.SendEinsatzlisteMA

- **HTML:**
  - Selector: `#btnMailEins`
  - Handler: `sendeEinsatzlisteMA()`
  - Ergebnis: Sendet Einsatzliste an Mitarbeiter
  - **Paritaet: PASS**

#### 14) Button: EL senden BOS
- **Access:**
  - Control-Name: btn_Autosend_BOS
  - Caption: EL senden BOS
  - Event: OnClick
  - VBA/Macro: mod_Mail.SendEinsatzlisteBOS

- **HTML:**
  - Selector: `#btnMailBOS`
  - Handler: `sendeEinsatzlisteBOS()`
  - Ergebnis: Sendet Einsatzliste an BOS
  - **Paritaet: PASS**

#### 15) Button: EL senden SUB
- **Access:**
  - Control-Name: btnMailSub
  - Caption: EL senden Sub
  - Event: OnClick
  - VBA/Macro: mod_Mail.SendEinsatzlisteSUB

- **HTML:**
  - Selector: `#btnMailSub`
  - Handler: `sendeEinsatzlisteSUB()`
  - Ergebnis: Sendet Einsatzliste an Subunternehmer
  - **Paritaet: PASS**

#### 16) Button: EL gesendet
- **Access:**
  - Control-Name: (Information)
  - Caption: EL gesendet
  - Event: OnClick
  - VBA/Macro: Zeigt Sendestatus

- **HTML:**
  - Selector: `#btnELGesendet`
  - Handler: `showELGesendet()`
  - Ergebnis: Zeigt Historie der gesendeten EL
  - **Paritaet: PASS**

#### 17) Button: BWN drucken
- **Access:**
  - Control-Name: btn_BWN_Druck
  - Caption: BWN drucken
  - Event: OnClick
  - VBA/Macro: DoCmd.OpenReport "rpt_BWN"

- **HTML:**
  - Selector: Button in Tab "Einsatzliste"
  - Handler: `bwnDrucken()`
  - Ergebnis: Druckt BWN-Report
  - **Paritaet: PASS**

#### 18) Button: Neuen Attach hinzufuegen
- **Access:**
  - Control-Name: btnNeuAttach
  - Caption: Neu
  - Event: OnClick
  - VBA/Macro: mod_Attach.AddAttachment

- **HTML:**
  - Selector: Button in Tab "Zusatzdateien"
  - Handler: `neuenAttachHinzufuegen()`
  - API-Call: POST /api/attachments/upload
  - Ergebnis: Oeffnet Datei-Upload Dialog
  - **Paritaet: PASS**

#### 19) Button: Rechnung PDF
- **Access:**
  - Control-Name: btnPDFKopf
  - Caption: Rechnung PDF
  - Event: OnClick
  - VBA/Macro: mod_PDF.CreateRechnungPDF

- **HTML:**
  - Selector: Button in Tab "Rechnung"
  - Handler: `rechnungPDF()`
  - Ergebnis: Generiert Rechnung als PDF
  - **Paritaet: PASS**

#### 20) Button: Berechnungsliste PDF
- **Access:**
  - Control-Name: btnPDFPos
  - Caption: Berechnungsliste
  - Event: OnClick
  - VBA/Macro: mod_PDF.CreateBerechnungslistePDF

- **HTML:**
  - Selector: Button in Tab "Rechnung"
  - Handler: `berechnungslistePDF()`
  - Ergebnis: Generiert Berechnungsliste als PDF
  - **Paritaet: PASS**

#### 21) Button: Daten laden (Rechnung)
- **Access:**
  - Control-Name: btnLoad
  - Caption: Daten laden
  - Event: OnClick
  - VBA/Macro: mod_Rechnung.LoadRechnungsdaten

- **HTML:**
  - Selector: Button in Tab "Rechnung"
  - Handler: `rechnungDatenLaden()`
  - API-Call: GET /api/auftraege/{id}/rechnung
  - Ergebnis: Laedt Rechnungsdaten
  - **Paritaet: PASS**

#### 22) Button: Rechnung in Lexware
- **Access:**
  - Control-Name: btnRchLex
  - Caption: Lexware Rechnung
  - Event: OnClick
  - VBA/Macro: mod_Lexware.CreateRechnung

- **HTML:**
  - Selector: Button in Tab "Rechnung"
  - Handler: `rechnungLexware()`
  - Ergebnis: Erstellt Rechnung in Lexware
  - **Paritaet: PASS**

#### 23) Button: Web-Daten laden (Eventdaten)
- **Access:**
  - Control-Name: btnWebDaten
  - Caption: Web-Daten laden
  - Event: OnClick
  - VBA/Macro: mod_EventScraper.LoadWebData

- **HTML:**
  - Selector: Button in Tab "Eventdaten"
  - Handler: `webDatenLaden()`
  - API-Call: GET /api/eventdaten/scrape?url=...
  - Ergebnis: Laedt Event-Daten von Webseite
  - **Paritaet: PASS**

#### 24) Button: Eventdaten speichern
- **Access:**
  - Control-Name: btnEventSave
  - Caption: Speichern
  - Event: OnClick
  - VBA/Macro: Form.Dirty = False

- **HTML:**
  - Selector: Button in Tab "Eventdaten"
  - Handler: `eventdatenSpeichern()`
  - API-Call: PUT /api/auftraege/{id}/eventdaten
  - Ergebnis: Speichert Eventdaten
  - **Paritaet: PASS**

#### 25) Datums-Navigation Links
- **Access:**
  - Control-Name: btnDatumLeft
  - Caption: <
  - Event: OnClick
  - VBA/Macro: cboVADatum.SetFocus; SendKeys "{UP}"

- **HTML:**
  - Selector: `#btnDatumLeft`
  - Handler: `datumNavLeft()`
  - Ergebnis: Navigiert zum vorherigen VA-Datum
  - **Paritaet: PASS**

#### 26) Datums-Navigation Rechts
- **Access:**
  - Control-Name: btnDatumRight
  - Caption: >
  - Event: OnClick
  - VBA/Macro: cboVADatum.SetFocus; SendKeys "{DOWN}"

- **HTML:**
  - Selector: `#btnDatumRight`
  - Handler: `datumNavRight()`
  - Ergebnis: Navigiert zum naechsten VA-Datum
  - **Paritaet: PASS**

#### 27) Button: Auftraege-Filter "Go"
- **Access:**
  - Control-Name: btn_AbWann
  - Caption: Go
  - Event: OnClick
  - VBA/Macro: Me.Filter = "[VADatum] >= #" & Auftraege_ab & "#"

- **HTML:**
  - Selector: `.nav-btn.tiny-btn` (nach Datum-Input)
  - Handler: `filterAuftraege()`
  - Ergebnis: Filtert Auftragsliste nach Datum
  - **Paritaet: PASS**

#### 28) Button: Tage zurueck
- **Access:**
  - Control-Name: btnTgBack
  - Caption: <<
  - Event: OnClick
  - VBA/Macro: Auftraege_ab = Auftraege_ab - 7

- **HTML:**
  - Selector: `.nav-btn` (<< Button)
  - Handler: `tageZurueck()`
  - Ergebnis: Verschiebt Filter 7 Tage zurueck
  - **Paritaet: PASS**

#### 29) Button: Tage vor
- **Access:**
  - Control-Name: btnTgVor
  - Caption: >>
  - Event: OnClick
  - VBA/Macro: Auftraege_ab = Auftraege_ab + 7

- **HTML:**
  - Selector: `.nav-btn` (>> Button)
  - Handler: `tageVor()`
  - Ergebnis: Verschiebt Filter 7 Tage vorwaerts
  - **Paritaet: PASS**

#### 30) Button: Ab Heute
- **Access:**
  - Control-Name: btnHeute
  - Caption: Ab Heute
  - Event: OnClick
  - VBA/Macro: Auftraege_ab = Date()

- **HTML:**
  - Selector: `.nav-btn` (Ab Heute Button)
  - Handler: `abHeute()`
  - Ergebnis: Setzt Filter auf heutiges Datum
  - **Paritaet: PASS**

### B) DROPDOWNS / LISTS

#### 1) Dropdown: Status
- **Access:**
  - Name: Veranst_Status_ID
  - RowSource: tbl_VA_Status
  - Event: AfterUpdate
  - Soll: Setzt Veranstaltungsstatus

- **HTML:**
  - Selector: `#Veranst_Status_ID`
  - Event: onchange
  - Handler: `statusChanged()`
  - **Paritaet: PASS**

#### 2) Dropdown: Objekt-ID
- **Access:**
  - Name: Objekt_ID
  - RowSource: qry_OB_Objekte_Aktiv
  - Event: AfterUpdate
  - Soll: Waehlt Objekt aus

- **HTML:**
  - Selector: `#Objekt_ID`
  - Event: onchange
  - Handler: `objektIdChanged()`
  - **Paritaet: PASS**

#### 3) Dropdown: Veranstalter
- **Access:**
  - Name: Veranstalter_ID
  - RowSource: qry_KD_Kunden_Aktiv
  - Event: AfterUpdate
  - Soll: Waehlt Kunden/Veranstalter

- **HTML:**
  - Selector: `#Veranstalter_ID`
  - Event: onchange
  - Handler: `veranstalterChanged()`
  - **Paritaet: PASS**

#### 4) Dropdown: VA-Datum
- **Access:**
  - Name: cboVADatum
  - RowSource: SELECT VADatum FROM tbl_VA_AnzTage WHERE VA_ID=...
  - Event: AfterUpdate
  - Soll: Wechselt Einsatztag innerhalb des Auftrags

- **HTML:**
  - Selector: `#cboVADatum`
  - Event: onchange
  - Handler: `vaDatumChanged()`
  - **Paritaet: PASS**

#### 5) Datalist: Auftrag
- **Access:**
  - Name: Auftrag (TextBox mit AutoComplete)
  - RowSource: tbl_VA_Auftragstamm
  - Soll: Autocomplete fuer Auftragsname

- **HTML:**
  - Selector: `#Auftrag` mit `list="auftragListe"`
  - Datalist mit Vorschlaegen
  - **Paritaet: PASS**

#### 6) Datalist: Ort
- **Access:**
  - Name: Ort (TextBox mit AutoComplete)
  - Soll: Autocomplete fuer Orte

- **HTML:**
  - Selector: `#Ort` mit `list="ortListe"`
  - **Paritaet: PASS**

#### 7) Datalist: Objekt
- **Access:**
  - Name: Objekt (TextBox mit AutoComplete)
  - Soll: Autocomplete fuer Objekte

- **HTML:**
  - Selector: `#Objekt` mit `list="objektListe"`
  - **Paritaet: PASS**

#### 8) Datalist: Dienstkleidung
- **Access:**
  - Name: Dienstkleidung (TextBox)
  - Soll: Vordefinierte Kleidungsoptionen

- **HTML:**
  - Selector: `#Dienstkleidung` mit `list="kleidungListe"`
  - **Paritaet: PASS**

### C) DATUMSFELDER

#### 1) Zeitraum: Dat_VA_Von / Dat_VA_Bis
- **Access:**
  - Event: AfterUpdate
  - Edgecases: von > bis zeigt MsgBox
  - ValidationRule: [Dat_VA_Bis] >= [Dat_VA_Von]

- **HTML:**
  - Selectors: `#Dat_VA_Von`, `#Dat_VA_Bis`
  - Events: onchange
  - Handlers: `datumChanged()`, `datumBisChanged()`
  - Validierung: `validateDateRange()` im Logic-File
  - **Paritaet: PASS**

#### 2) Auftraege_ab (Filter)
- **Access:**
  - Name: Auftraege_ab
  - Event: AfterUpdate
  - Soll: Filtert Auftragsliste ab Datum

- **HTML:**
  - Selector: `#Auftraege_ab`
  - Event: onchange
  - Handler: `filterAuftraege()`
  - **Paritaet: PASS**

### D) INPUTS / VALIDIERUNGEN

#### 1) Pflichtfeld: Auftrag
- **Access:** Pflicht, ValidationRule: Not Null
- **HTML:** `required` Attribut, `validateRequired()` bei Submit
- **Paritaet: PASS**

#### 2) Input: Fahrtkosten
- **Access:**
  - Name: Fahrtkosten
  - Format: Currency
  - Event: AfterUpdate

- **HTML:**
  - Selector: `#Fahrtkosten`
  - Event: onchange
  - Handler: `saveField('Fahrtkosten', this.value)`
  - **Paritaet: PASS**

#### 3) Input: Treffpunkt-Zeit
- **Access:**
  - Name: Treffp_Zeit
  - Format: Short Time
  - Event: AfterUpdate

- **HTML:**
  - Selector: `#Treffp_Zeit`
  - Type: time
  - Handler: `saveField('Treffp_Zeit', this.value)`
  - **Paritaet: PASS**

#### 4) Input: Treffpunkt
- **Access:**
  - Name: Treffpunkt
  - Event: AfterUpdate

- **HTML:**
  - Selector: `#Treffpunkt`
  - Handler: `saveField('Treffpunkt', this.value)`
  - **Paritaet: PASS**

#### 5) Input: Dienstkleidung
- **Access:**
  - Name: Dienstkleidung
  - Event: AfterUpdate

- **HTML:**
  - Selector: `#Dienstkleidung`
  - Handler: `saveField('Dienstkleidung', this.value)`
  - **Paritaet: PASS**

#### 6) Input: Ansprechpartner
- **Access:**
  - Name: Ansprechpartner
  - Event: AfterUpdate

- **HTML:**
  - Selector: `#Ansprechpartner`
  - Handler: `saveField('Ansprechpartner', this.value)`
  - **Paritaet: PASS**

#### 7) Textarea: Bemerkungen
- **Access:**
  - Name: Bemerkungen
  - Event: AfterUpdate

- **HTML:**
  - Selector: `#Bemerkungen`
  - Event: onchange
  - Handler: `saveField('Bemerkungen', this.value)`
  - **Paritaet: PASS**

### E) CHECKBOXEN

#### 1) Checkbox: Autosend EL
- **Access:**
  - Name: Autosend_EL
  - Event: AfterUpdate
  - Soll: Aktiviert automatischen EL-Versand

- **HTML:**
  - Selector: `#cbAutosendEL`
  - Event: onchange
  - Handler: `saveField('Autosend_EL', this.checked)`
  - **Paritaet: PASS**

### F) TABS

| Tab-Name          | Access-Name      | HTML data-tab      | Status |
|-------------------|------------------|-------------------|--------|
| Einsatzliste      | tabEinsatzliste  | einsatzliste      | PASS   |
| Antworten         | tabAntworten     | antworten         | PASS   |
| Zusatzdateien     | tabAttach        | zusatzdateien     | PASS   |
| Rechnung          | tabRechnung      | rechnung          | PASS   |
| Bemerkungen       | tabBemerkungen   | bemerkungen       | PASS   |
| Eventdaten        | tabEventdaten    | eventdaten        | PASS   |

### G) HEADER-LINKS

#### 1) Link: Rueckmelde-Statistik
- **Access:**
  - Control-Name: btn_Rueckmeld
  - Event: OnClick
  - VBA/Macro: DoCmd.OpenForm "frm_Rueckmeldungen"

- **HTML:**
  - Selector: `.header-link` (Rueckmelde-Statistik)
  - Handler: `openRueckmeldStatistik()`
  - **Paritaet: PASS**

#### 2) Link: Syncfehler
- **Access:**
  - Control-Name: btnSyncErr
  - Event: OnClick
  - VBA/Macro: DoCmd.OpenForm "frm_Syncfehler"

- **HTML:**
  - Selector: `.header-link` (Syncfehler)
  - Handler: `openSyncfehler()`
  - **Paritaet: PASS**

---

## Formular: frm_MA_Mitarbeiterstamm

**HTML-Datei:** `04_HTML_Forms/forms3/frm_MA_Mitarbeiterstamm.html`
**Logic-Dateien:**
- `logic/frm_MA_Mitarbeiterstamm.logic.js`
- `logic/frm_MA_Mitarbeiterstamm.webview2.js`

### A) BUTTONS

#### 1) Navigations-Buttons
| Button  | Access-Name     | HTML-ID       | Handler        | Paritaet |
|---------|----------------|---------------|----------------|----------|
| Erste   | Befehl39       | btnErste      | navFirst()     | PASS     |
| Vorige  | Befehl40       | btnVorige     | navPrev()      | PASS     |
| Naechste| Befehl41       | btnNaechste   | navNext()      | PASS     |
| Letzte  | Befehl42       | btnLetzte     | navLast()      | PASS     |

#### 2) Button: MA Adressen
- **Access:**
  - Control-Name: btnMAAdressen
  - Caption: MA Adressen
  - Event: OnClick
  - VBA/Macro: DoCmd.OpenForm "frm_MA_Adressen"

- **HTML:**
  - Selector: `#btnMAAdressen`
  - Handler: `openMAAdressen()`
  - **Paritaet: PASS**

#### 3) Button: Aktualisieren
- **Access:**
  - Control-Name: btnAktualisieren
  - Caption: Aktualisieren
  - Event: OnClick
  - VBA/Macro: Form.Requery

- **HTML:**
  - Selector: `#btnAktualisieren`
  - Handler: `refreshData()`
  - **Paritaet: PASS**

#### 4) Button: Zeitkonto
- **Access:**
  - Control-Name: btnZeitkonto
  - Caption: Zeitkonto
  - Event: OnClick
  - VBA/Macro: DoCmd.OpenForm "frm_MA_Zeitkonten"

- **HTML:**
  - Selector: `#btnZeitkonto`
  - Handler: `openZeitkonto()`
  - **Paritaet: PASS**

#### 5) Button: Neuer Mitarbeiter
- **Access:**
  - Control-Name: btnNeuMA
  - Caption: Neuer Mitarbeiter
  - Event: OnClick
  - VBA/Macro: DoCmd.GoToRecord , , acNewRec

- **HTML:**
  - Selector: `#btnNeuMA`
  - Handler: `neuerMitarbeiter()`
  - API-Call: POST /api/mitarbeiter (bei Speichern)
  - **Paritaet: PASS**

#### 6) Button: Mitarbeiter loeschen
- **Access:**
  - Control-Name: btnLoeschen
  - Caption: Mitarbeiter loeschen
  - Event: OnClick
  - VBA/Macro: DoCmd.RunCommand acCmdDeleteRecord

- **HTML:**
  - Selector: `#btnLoeschen`
  - Handler: `mitarbeiterLoeschen()`
  - API-Call: DELETE /api/mitarbeiter/{id}
  - **Paritaet: PASS**

#### 7) Button: Einsaetze FA/MJ
- **Access:**
  - Control-Name: btnEinsaetzeFA, btnEinsaetzeMJ
  - Caption: Einsaetze FA, Einsaetze MJ
  - Event: OnClick
  - VBA/Macro: mod_Einsatz.UebertrageEinsaetze

- **HTML:**
  - Selector: `#btnEinsaetzeFA`, `#btnEinsaetzeMJ`
  - Handler: `einsaetzeUebertragen('FA')`, `einsaetzeUebertragen('MJ')`
  - **Paritaet: PASS**

#### 8) Button: Listen drucken
- **Access:**
  - Control-Name: btnListenDrucken
  - Caption: Listen drucken
  - Event: OnClick
  - VBA/Macro: DoCmd.OpenReport "rpt_MA_Listen"

- **HTML:**
  - Selector: `#btnListenDrucken`
  - Handler: `listenDrucken()`
  - **Paritaet: PASS**

#### 9) Button: MA Tabelle
- **Access:**
  - Control-Name: btnMATabelle
  - Caption: MA Tabelle
  - Event: OnClick
  - VBA/Macro: DoCmd.OpenTable "tbl_MA_Mitarbeiterstamm"

- **HTML:**
  - Selector: `#btnMATabelle`
  - Handler: `mitarbeiterTabelle()`
  - **Paritaet: PASS**

#### 10) Button: Dienstplan
- **Access:**
  - Control-Name: btnDienstplan
  - Caption: Dienstplan
  - Event: OnClick
  - VBA/Macro: DoCmd.OpenForm "frm_DP_Dienstplan_MA"

- **HTML:**
  - Selector: `#btnDienstplan`
  - Handler: `openDienstplan()`
  - **Paritaet: PASS**

#### 11) Button: Einsatzuebersicht
- **Access:**
  - Control-Name: btnEinsatzUebersicht
  - Caption: Einsatzuebersicht
  - Event: OnClick
  - VBA/Macro: DoCmd.OpenForm "frm_Einsatzuebersicht"

- **HTML:**
  - Selector: `#btnEinsatzUebersicht`
  - Handler: `openEinsatzuebersicht()`
  - **Paritaet: PASS**

#### 12) Button: Karte oeffnen
- **Access:**
  - Control-Name: btnMapsOeffnen
  - Caption: Karte oeffnen
  - Event: OnClick
  - VBA/Macro: mod_Maps.OpenGoogleMaps

- **HTML:**
  - Selector: `#btnMapsOeffnen`
  - Handler: `openMaps()`
  - **Paritaet: PASS**

#### 13) Button: Speichern
- **Access:**
  - Control-Name: btnSpeichern
  - Caption: Speichern
  - Event: OnClick
  - VBA/Macro: DoCmd.RunCommand acCmdSaveRecord

- **HTML:**
  - Selector: `#btnSpeichern`
  - Handler: `speichern()`
  - API-Call: PUT /api/mitarbeiter/{id}
  - **Paritaet: PASS**

#### 14) Excel-Export Dropdown
| Export-Typ        | Access-Name       | Handler                  | Paritaet |
|-------------------|-------------------|--------------------------|----------|
| Einsatzuebersicht | btnXLEinsUeber    | btnXLEinsUeber_Click()   | PASS     |
| Dienstplan        | btnXLDiePl        | btnXLDiePl_Click()       | PASS     |
| Zeitkonto         | btnXLZeitkto      | btnXLZeitkto_Click()     | PASS     |
| Jahresuebersicht  | btnXLJahr         | btnXLJahr_Click()        | PASS     |
| Nicht Verfuegbar  | btnXLNverfueg     | btnXLNverfueg_Click()    | PASS     |
| Ueberhang Stunden | btnXLUeberhangStd | btnXLUeberhangStd_Click()| PASS     |

#### 15) Zeitkonto-Buttons
| Button   | Access-Name  | Handler            | Beschreibung                        | Paritaet |
|----------|--------------|--------------------|------------------------------------|----------|
| ZK Fest  | btnZKFest    | btnZKFest_Click()  | Zeitkonten Festangestellte         | PASS     |
| ZK Mini  | btnZKMini    | btnZKMini_Click()  | Zeitkonten Minijobber              | PASS     |
| ZK Einzel| btnZKeinzel  | btnZKeinzel_Click()| Einzelsatz Zeitkonto               | PASS     |

### B) DROPDOWNS

#### 1) Dropdown: Zeitraum
- **Access:**
  - Name: cboZeitraum
  - RowSource: Werteliste (Dieser Monat, Letzter Monat, etc.)
  - Event: AfterUpdate
  - Soll: Filtert Zeitraum fuer Anzeige

- **HTML:**
  - Selector: `#cboZeitraum`
  - Event: onchange
  - Handler: `cboZeitraum_AfterUpdate(parseInt(this.value))`
  - Optionen: 8=Dieser Monat, 9=Letzter Monat, 11=Dieses Jahr, etc.
  - **Paritaet: PASS**

### C) TABS

| Tab-Name           | Access-Name         | HTML data-tab        | Status |
|--------------------|---------------------|---------------------|--------|
| Stammdaten         | tabStammdaten       | stammdaten          | PASS   |
| Einsatzuebersicht  | tabEinsatzuebersicht| einsatzuebersicht   | PASS   |
| Dienstplan         | tabDienstplan       | dienstplan          | PASS   |
| Nicht Verfuegbar   | tabNichtVerfuegbar  | nichtverfuegbar     | PASS   |
| Dienstkleidung     | tabDienstkleidung   | dienstkleidung      | PASS   |
| Zeitkonto          | tabZeitkonto        | zeitkonto           | PASS   |
| Jahresuebersicht   | tabJahresuebersicht | jahresuebersicht    | PASS   |
| Stundenuebersicht  | tabStundenuebersicht| stundenuebersicht   | PASS   |
| Vordrucke          | tabVordrucke        | vordrucke           | PASS   |
| Briefkopf          | tabBriefkopf        | briefkopf           | PASS   |
| Karte              | tabKarte            | karte               | PASS   |
| Sub Rechnungen     | tabSubRechnungen    | subrechnungen       | PASS   |
| Uberhang Std.      | tabUeberhangStd     | ueberhangstunden    | PASS   |
| Qualifikationen    | tabQualifikationen  | qualifikationen     | PASS   |
| Dokumente          | tabDokumente        | dokumente           | PASS   |
| Quick Info         | tabQuickInfo        | quickinfo           | PASS   |

---

## Formular: frm_KD_Kundenstamm

**HTML-Datei:** `04_HTML_Forms/forms3/frm_KD_Kundenstamm.html`
**Logic-Dateien:**
- `logic/frm_KD_Kundenstamm.logic.js`
- `logic/frm_KD_Kundenstamm.webview2.js`

### A) BUTTONS

#### 1) Navigations-Buttons
| Button  | Access-Name  | Handler            | Paritaet |
|---------|--------------|--------------------|---------  |
| Erste   | Befehl39     | gotoFirstRecord()  | PASS      |
| Vorige  | Befehl40     | gotoPrevRecord()   | PASS      |
| Naechste| Befehl41     | gotoNextRecord()   | PASS      |
| Letzte  | Befehl42     | gotoLastRecord()   | PASS      |

#### 2) Button: Aktualisieren
- **Access:**
  - Control-Name: btnAktualisieren
  - Event: OnClick
  - VBA/Macro: Form.Requery

- **HTML:**
  - Selector: `#btnAktualisieren`
  - Handler: `refreshData()`
  - **Paritaet: PASS**

#### 3) Button: Verrechnungssaetze
- **Access:**
  - Control-Name: btnVerrechnungssaetze
  - Caption: Verrechnungssaetze
  - Event: OnClick
  - VBA/Macro: DoCmd.OpenForm "frm_KD_Verrechnungssaetze"

- **HTML:**
  - Selector: `#btnVerrechnungssaetze`
  - Handler: `openVerrechnungssaetze()`
  - **Paritaet: PASS**

#### 4) Button: Umsatzauswertung
- **Access:**
  - Control-Name: btnUmsatzauswertung
  - Caption: Umsatzauswertung
  - Event: OnClick
  - VBA/Macro: DoCmd.OpenForm "frm_KD_Umsatz"

- **HTML:**
  - Selector: `#btnUmsatzauswertung`
  - Handler: `openUmsatzauswertung()`
  - **Paritaet: PASS**

#### 5) Button: Outlook
- **Access:**
  - Control-Name: btnOutlook
  - Caption: Outlook
  - Event: OnClick
  - VBA/Macro: mod_Office.OpenOutlookMail

- **HTML:**
  - Selector: `#btnOutlook`
  - Handler: `openOutlook()`
  - **Paritaet: PASS**

#### 6) Button: Word
- **Access:**
  - Control-Name: btnWord
  - Caption: Word
  - Event: OnClick
  - VBA/Macro: mod_Office.OpenWordBrief

- **HTML:**
  - Selector: `#btnWord`
  - Handler: `openWord()`
  - **Paritaet: PASS**

#### 7) Button: Neuer Kunde
- **Access:**
  - Control-Name: btnNeuKunde
  - Caption: Neuer Kunde
  - Event: OnClick
  - VBA/Macro: DoCmd.GoToRecord , , acNewRec

- **HTML:**
  - Selector: `#btnNeuKunde`
  - Handler: `neuerKunde()`
  - API-Call: POST /api/kunden
  - **Paritaet: PASS**

#### 8) Button: Kunde loeschen
- **Access:**
  - Control-Name: btnLoeschen
  - Caption: Kunde loeschen
  - Event: OnClick
  - VBA/Macro: DoCmd.RunCommand acCmdDeleteRecord

- **HTML:**
  - Selector: `#btnLoeschen`
  - Handler: `kundeLoeschen()`
  - API-Call: DELETE /api/kunden/{id}
  - **Paritaet: PASS**

#### 9) Button: Speichern
- **Access:**
  - Control-Name: btnSpeichern
  - Caption: Speichern
  - Event: OnClick
  - VBA/Macro: DoCmd.RunCommand acCmdSaveRecord

- **HTML:**
  - Selector: `#btnSpeichern`
  - Handler: `speichern()`
  - API-Call: PUT /api/kunden/{id}
  - **Paritaet: PASS**

#### 10) Kunden-Suche
- **Access:**
  - Control-Name: cboKDNrSuche
  - Event: AfterUpdate
  - VBA/Macro: DoCmd.FindRecord

- **HTML:**
  - Selector: `#cboKDNrSuche`
  - Event: onkeydown (Enter)
  - Handler: `sucheKundeNr()`
  - **Paritaet: PASS**

### B) TABS - Objekte-Tab Buttons

#### 1) Button: Neues Objekt
- **Access:**
  - Control-Name: btnNeuObjekt
  - Event: OnClick
  - VBA/Macro: DoCmd.OpenForm "frm_OB_Objekt", , , , acFormAdd

- **HTML:**
  - Handler: `neuesObjekt()`
  - **Paritaet: PASS**

#### 2) Button: Objekt oeffnen
- **Access:**
  - Control-Name: btnObjektOeffnen
  - Event: OnClick
  - VBA/Macro: DoCmd.OpenForm "frm_OB_Objekt", , , "[ID]=" & selID

- **HTML:**
  - Handler: `openObjekt()`
  - **Paritaet: PASS**

### C) TABS - Auftraguebersicht Buttons

#### 1) Datumsfilter
- **Access:**
  - Control-Name: datAuftraegeVon, datAuftraegeBis
  - Event: AfterUpdate

- **HTML:**
  - Selectors: `#datAuftraegeVon`, `#datAuftraegeBis`
  - Handler: `loadAuftraege()`
  - **Paritaet: PASS**

#### 2) Button: Rechnung PDF
- **Access:**
  - Control-Name: btnAufRchPDF
  - Event: OnClick

- **HTML:**
  - Handler: `openRechnungPDF()`
  - **Paritaet: PASS**

#### 3) Button: Berechnungsliste PDF
- **Access:**
  - Control-Name: btnAufRchPosPDF
  - Event: OnClick

- **HTML:**
  - Handler: `openBerechnungslistePDF()`
  - **Paritaet: PASS**

#### 4) Button: Einsatzliste PDF
- **Access:**
  - Control-Name: btnAufEinsPDF
  - Event: OnClick

- **HTML:**
  - Handler: `openEinsatzlistePDF()`
  - **Paritaet: PASS**

#### 5) Button: Neuer Auftrag
- **Access:**
  - Control-Name: btnNeuAuftrag
  - Event: OnClick

- **HTML:**
  - Handler: `openNeuerAuftrag()`
  - **Paritaet: PASS**

### D) TABS

| Tab-Name           | Access-Name          | HTML data-tab         | Status |
|--------------------|---------------------|-----------------------|--------|
| Stammdaten         | tabStammdaten       | stammdaten            | PASS   |
| Objekte            | tabObjekte          | objekte               | PASS   |
| Konditionen        | tabKonditionen      | konditionen           | PASS   |
| Auftraguebersicht  | tabAuftragsuebersicht| auftraguebersicht    | PASS   |
| Ansprechpartner    | tabAnsprechpartner  | ansprechpartner       | PASS   |
| Zusatzdateien      | tabZusatzdateien    | zusatzdateien         | PASS   |
| Bemerkungen        | tabBemerkungen      | bemerkungen           | PASS   |
| Angebote           | tabAngebote         | angebote              | PASS   |
| Statistik          | tabStatistik        | statistik             | PASS   |
| Preise             | tabPreise           | preise                | PASS   |

### E) CHECKBOXEN

| Checkbox               | Access-Name           | HTML-ID                | Paritaet |
|------------------------|----------------------|------------------------|----------|
| Ist aktiv              | kun_IstAktiv         | kun_IstAktiv           | PASS     |
| Sammelrechnung         | kun_IstSammelRechnung| kun_IstSammelRechnung  | PASS     |
| Anschrift manuell      | kun_ans_manuell      | kun_ans_manuell        | PASS     |

### F) INPUTS MIT VALIDIERUNG

| Feld         | Pflicht | Pattern/Validierung           | Paritaet |
|--------------|---------|-------------------------------|----------|
| kun_Firma    | JA      | required                      | PASS     |
| kun_PLZ      | NEIN    | [0-9]{5}                      | PASS     |
| kun_telefon  | NEIN    | [0-9+\-\s/()\+]              | PASS     |
| kun_email    | NEIN    | Email-Pattern                 | PASS     |
| kun_iban     | NEIN    | IBAN-Pattern                  | PASS     |
| kun_bic      | NEIN    | BIC-Pattern                   | PASS     |

---

## Formular: frm_OB_Objekt

**HTML-Datei:** `04_HTML_Forms/forms3/frm_OB_Objekt.html`
**Logic-Dateien:**
- `logic/frm_OB_Objekt.logic.js`
- `logic/frm_OB_Objekt.webview2.js`

### A) BUTTONS

#### 1) Navigations-Buttons
| Button  | Handler     | Paritaet |
|---------|-------------|----------|
| Erste   | goFirst()   | PASS     |
| Vorige  | goPrev()    | PASS     |
| Naechste| goNext()    | PASS     |
| Letzte  | goLast()    | PASS     |

#### 2) Button: Neu
- **Access:**
  - Control-Name: cmdNeu
  - Caption: + Neu
  - Event: OnClick
  - VBA/Macro: DoCmd.GoToRecord , , acNewRec

- **HTML:**
  - Selector: `.btn.btn-green` (+ Neu)
  - Handler: `newRecord()`
  - **Paritaet: PASS**

#### 3) Button: Speichern
- **Access:**
  - Control-Name: cmdSpeichern
  - Caption: Speichern
  - Event: OnClick
  - VBA/Macro: DoCmd.RunCommand acCmdSaveRecord

- **HTML:**
  - Selector: `.btn.btn-yellow` (Speichern)
  - Handler: `saveRecord()`
  - API-Call: PUT /api/objekte/{id}
  - **Paritaet: PASS**

#### 4) Button: Loeschen
- **Access:**
  - Control-Name: cmdLoeschen
  - Caption: Loeschen
  - Event: OnClick
  - VBA/Macro: DoCmd.RunCommand acCmdDeleteRecord

- **HTML:**
  - Selector: `.btn.btn-red` (Loeschen)
  - Handler: `deleteRecord()`
  - API-Call: DELETE /api/objekte/{id}
  - **Paritaet: PASS**

#### 5) Button: Bericht
- **Access:**
  - Control-Name: cmdBericht
  - Caption: Bericht
  - Event: OnClick
  - VBA/Macro: DoCmd.OpenReport "rpt_OB_Objekt"

- **HTML:**
  - Handler: `printReport()`
  - **Paritaet: PASS**

#### 6) Button: Neuer Veranstalter
- **Access:**
  - Control-Name: cmdNeuVeranstalter
  - Caption: Neuer Veranstalter
  - Event: OnClick
  - VBA/Macro: DoCmd.OpenForm "frm_KD_Kundenstamm", , , , acFormAdd

- **HTML:**
  - Handler: `openNewVeranstalter()`
  - **Paritaet: PASS**

#### 7) Button: Geocode
- **Access:**
  - Control-Name: cmdGeocode
  - Caption: Geocode
  - Event: OnClick
  - VBA/Macro: mod_Geo.GeocodeOSM

- **HTML:**
  - Handler: `geocodeAdresse()`
  - API: OpenStreetMap Nominatim
  - **Paritaet: PASS**

#### 8) Button: Hilfe
- **Access:**
  - Control-Name: btnHilfe
  - Caption: ?
  - Event: OnClick

- **HTML:**
  - Handler: `showHelp()`
  - **Paritaet: PASS**

#### 9) Button: Zurueck zur Liste
- **Access:**
  - Control-Name: btn_Back_akt_Pos_List
  - Caption: Zurueck zur Liste
  - Event: OnClick
  - Visible: Nur wenn OpenArgs

- **HTML:**
  - Selector: `#btnBackToList`
  - Handler: `backToAktPosList()`
  - **Paritaet: PASS**

### B) POSITIONEN-TAB BUTTONS

#### 1) Button: Neue Position
- **Access:**
  - Control-Name: btnNeuPosition
  - Caption: + Neue Position
  - Event: OnClick

- **HTML:**
  - Handler: `newPosition()`
  - API-Call: POST /api/objekte/{id}/positionen
  - **Paritaet: PASS**

#### 2) Button: Position loeschen
- **Access:**
  - Control-Name: btnDelPosition
  - Caption: Position loeschen
  - Event: OnClick

- **HTML:**
  - Handler: `deletePosition()`
  - API-Call: DELETE /api/objekte/positionen/{id}
  - **Paritaet: PASS**

#### 3) Button: Position nach oben
- **Access:**
  - Control-Name: btnMoveUp
  - Caption: Pfeil hoch
  - Event: OnClick

- **HTML:**
  - Handler: `movePositionUp()`
  - **Paritaet: PASS**

#### 4) Button: Position nach unten
- **Access:**
  - Control-Name: btnMoveDown
  - Caption: Pfeil runter
  - Event: OnClick

- **HTML:**
  - Handler: `movePositionDown()`
  - **Paritaet: PASS**

#### 5) Button: Import
- **Access:**
  - Control-Name: btnUploadPositionen
  - Caption: Import
  - Event: OnClick

- **HTML:**
  - Handler: `uploadPositionen()`
  - **Paritaet: PASS**

#### 6) Button: Excel
- **Access:**
  - Control-Name: btnExportExcel
  - Caption: Excel
  - Event: OnClick

- **HTML:**
  - Handler: `exportPositionenExcel()`
  - **Paritaet: PASS**

#### 7) Button: Kopieren
- **Access:**
  - Control-Name: btnKopierePositionen
  - Caption: Kopieren
  - Event: OnClick

- **HTML:**
  - Handler: `kopierePositionen()`
  - **Paritaet: PASS**

#### 8) Button: Vorlage speichern
- **Access:**
  - Control-Name: btnVorlageSpeichern
  - Caption: Vorlage speichern
  - Event: OnClick

- **HTML:**
  - Handler: `speichereVorlage()`
  - **Paritaet: PASS**

#### 9) Button: Vorlage laden
- **Access:**
  - Control-Name: btnVorlageLaden
  - Caption: Vorlage laden
  - Event: OnClick

- **HTML:**
  - Handler: `ladeVorlage()`
  - **Paritaet: PASS**

### C) ZUSATZDATEIEN-TAB BUTTONS

| Button          | Handler             | Paritaet |
|-----------------|---------------------|----------|
| Datei hinzufuegen| addAttachment()    | PASS     |
| Neue Anlage     | newAttachment()     | PASS     |
| Datei loeschen  | deleteAttachment()  | PASS     |

### D) TABS

| Tab-Name      | HTML data-tab   | Status |
|---------------|-----------------|--------|
| Positionen    | tabPositionen   | PASS   |
| Zusatzdateien | tabAttach       | PASS   |
| Bemerkungen   | tabBemerkungen  | PASS   |
| Auftraege     | tabAuftraege    | PASS   |

### E) CHECKBOXEN

| Checkbox    | HTML-ID       | Handler                      | Paritaet |
|-------------|---------------|------------------------------|----------|
| Nur aktive  | chkNurAktive  | onchange -> loadObjekte()    | PASS     |

### F) INPUTS MIT VALIDIERUNG

| Feld    | Pflicht | Pattern          | Paritaet |
|---------|---------|------------------|----------|
| Objekt  | JA      | required         | PASS     |
| PLZ     | NEIN    | [0-9]{5}         | PASS     |
| Text435 | NEIN    | Telefon-Pattern  | PASS     |

### G) HEADER-LINKS

| Link          | Handler            | Paritaet |
|---------------|-------------------|----------|
| Auftraege     | openAuftraege()   | PASS     |
| Positionen    | openPositionen()  | PASS     |

---

## ZUSAMMENFASSUNG

### Gesamt-Statistik

| Formular                 | Buttons | Dropdowns | Tabs | Inputs | Paritaet |
|--------------------------|---------|-----------|------|--------|----------|
| frm_va_Auftragstamm      | 30      | 8         | 6    | 7      | 100%     |
| frm_MA_Mitarbeiterstamm  | 22      | 1         | 16   | -      | 100%     |
| frm_KD_Kundenstamm       | 14      | -         | 10   | 6      | 100%     |
| frm_OB_Objekt            | 18      | 1         | 4    | 3      | 100%     |
| **GESAMT**               | **84**  | **10**    | **36**| **16** | **100%** |

### Nicht in Access vorhandene HTML-Features
- Vollbild-Button (Browser Fullscreen API)
- Loading-Overlay mit Spinner
- Toast-Benachrichtigungen
- Shell-Detector fuer iframe-Modus

### API-Endpoints (genutzt von allen Formularen)

| Endpoint                          | Methoden        | Verwendet von       |
|-----------------------------------|-----------------|---------------------|
| /api/auftraege                    | GET, POST       | Auftragstamm        |
| /api/auftraege/{id}               | GET, PUT, DELETE| Auftragstamm        |
| /api/auftraege/copy               | POST            | Auftragstamm        |
| /api/mitarbeiter                  | GET, POST       | Mitarbeiterstamm    |
| /api/mitarbeiter/{id}             | GET, PUT, DELETE| Mitarbeiterstamm    |
| /api/kunden                       | GET, POST       | Kundenstamm         |
| /api/kunden/{id}                  | GET, PUT, DELETE| Kundenstamm         |
| /api/objekte                      | GET, POST       | Objektstamm         |
| /api/objekte/{id}                 | GET, PUT, DELETE| Objektstamm         |
| /api/objekte/{id}/positionen      | GET, POST       | Objektstamm         |
| /api/objekte/positionen/{id}      | PUT, DELETE     | Objektstamm         |
| /api/attachments                  | GET             | Alle Formulare      |
| /api/attachments/upload           | POST            | Alle Formulare      |
| /api/attachments/{id}             | DELETE          | Alle Formulare      |

---

**Dokumentation erstellt:** 2026-01-07
**Letzte Aktualisierung:** 2026-01-07
