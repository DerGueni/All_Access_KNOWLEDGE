# AUDIT-REPORT: frm_va_Auftragstamm

**Datum:** 2026-01-16
**Auditor:** Claude Code

---

## 1. ACCESS-ANALYSE

### 1.1 Formular-Struktur
- **Name:** frm_VA_Auftragstamm
- **VBA-Modul:** Form_frm_VA_Auftragstamm
- **Zeilen:** ca. 2800+ Zeilen VBA-Code

### 1.2 Erkannte Button-Events (Private Sub xxx_Click)

| Access Button | VBA-Funktion | Beschreibung |
|---------------|--------------|--------------|
| btnXLEinsLst | btnXLEinsLst_Click | Excel-Export Einsatzliste |
| Befehl658 | Befehl658_Click | PDF/Excel Zusage erstellen |
| Befehl640 | Befehl640_Click | Auftrag kopieren (AuftragKopieren) |
| btn_Neuer_Auftrag2 | btn_Neuer_Auftrag2_Click | Neuen Auftrag anlegen |
| Befehl709 | Befehl709_Click | Log-Tabelle oeffnen |
| btn_Autosend_BOS | btn_Autosend_BOS_Click | Autosend an BOS (Veranstalter 10720, 20770, 20771) |
| btn_ListeStd | btn_ListeStd_Click | Stundenliste erstellen |
| btn_Posliste_oeffnen | btn_Posliste_oeffnen_Click | Objekt-Positionen oeffnen |
| btn_rueck | btn_rueck_Click | Rueckgaengig (leer) |
| btn_rueckgaengig | btn_rueckgaengig_Click | Undo + Close |
| btn_Rueckmeld | btn_Rueckmeld_Click | Rueckmeldeauswertung oeffnen |
| btn_std_check | btn_std_check_Click | Status=3 + Druckzusage |
| btn_sortieren | btn_sortieren_Click | Zuordnung sortieren |
| btn_VA_Abwesenheiten | btn_VA_Abwesenheiten_Click | Abwesenheitsuebersicht oeffnen |
| btnDatumRight | btnDatumRight_Click | Datum +1 navigieren |
| btnDatumLeft | btnDatumLeft_Click | Datum -1 navigieren |
| btnreq | btnreq_Click | Requery |
| btn_VA_Neu_Aus_Vorlage | btn_VA_Neu_Aus_Vorlage_Click | VA aus Vorlage erstellen |
| btnMAErz | btnMAErz_Click | (leer) |
| btnAuftrBerech | btnAuftrBerech_Click | Rechnungsformular oeffnen |
| btnDruck | btnDruck_Click | PDF Auftrag drucken |
| btnStdBerech | btnStdBerech_Click | Stundenberechnung (leer) |
| btnDruckZusage | btnDruckZusage_Click | Excel Export + Status setzen |
| btnDruckZusage1 | btnDruckZusage1_Click | Report-Preview |
| btnMailEins | btnMailEins_Click | Serienmail Einsatzliste MA |
| btnMailPos | btnMailPos_Click | Serienmail Positionen |
| btnMailSub | btnMailSub_Click | Serienmail SUB-Unternehmer |
| btnNeuAttach | btnNeuAttach_Click | Attachment hinzufuegen |
| btnNeuVeranst | btnNeuVeranst_Click | Neuer Auftrag + Autosend_EL |
| btnPDFKopf | btnPDFKopf_Click | Rechnungs-PDF oeffnen |
| btnPDFPos | btnPDFPos_Click | Berechnungsliste PDF |
| btnSchnellPlan | btnSchnellPlan_Click | Mitarbeiterauswahl oeffnen |
| btnVAPlanAendern | btnVAPlanAendern_Click | Loeschen erlauben |
| btnVAPlanCrea | btnVAPlanCrea_Click | Zuordnungs-Saetze erzeugen |
| btnPlan_Kopie | btnPlan_Kopie_Click | Daten in Folgetag kopieren |
| btnSyncErr | btnSyncErr_Click | Sync-Fehler Formular |
| btn_AbWann | btn_AbWann_Click | Auftragsliste Filter |
| btnTgVor | btnTgVor_Click | +3 Tage Filter |
| btnTgBack | btnTgBack_Click | -3 Tage Filter |
| btnHeute | btnHeute_Click | Ab Heute Filter |
| mcobtnDelete | mcobtnDelete_Click | Auftrag loeschen |
| cmd_BWN_send | cmd_BWN_send_Click | BWN versenden |
| cmd_Messezettel_NameEintragen | cmd_Messezettel_NameEintragen_Click | Messezettel fuellen |
| btnDaBaAus | btnDaBaAus_Click | Datenbank ausblenden |
| btnDaBaEin | btnDaBaEin_Click | Datenbank einblenden |
| btnRibbonAus | btnRibbonAus_Click | Ribbon ausblenden |
| btnRibbonEin | btnRibbonEin_Click | Ribbon einblenden |

### 1.3 Erkannte Field-Events

| Feld | Event | Beschreibung |
|------|-------|--------------|
| cboVADatum | AfterUpdate | DefaultValue fuer Sub-VA_Start setzen |
| cboVADatum | DblClick | Einsatztage-Dialog oeffnen |
| cboAnstArt | DblClick | Anstellungsarten-Formular |
| cboEinsatzliste | BeforeUpdate/AfterUpdate | Property setzen |
| Veranstalter_ID | AfterUpdate | Fokus auf sub_VA_Start |
| Veranstalter_ID | DblClick | Kundenstamm oeffnen |
| Veranstalter_ID | KeyDown | Tab/Enter -> sub_VA_Start |
| Veranst_Status_ID | AfterUpdate | Status-Regeln, Sichtbarkeiten |
| Veranst_Status_ID | BeforeUpdate | Herabsetzen-Warnung |
| Veranst_Status_ID | DblClick | Status-Formular |
| Objekt_ID | AfterUpdate | BackColor, Sichtbarkeiten |
| Objekt_ID | DblClick | OB_Objekt Formular |
| Objekt | DblClick | Akt_Objekt_Kopf oeffnen |
| Objekt | Exit | Auto-Zuordnung Objekt_ID |
| Dat_VA_Von | DblClick | Kalender oeffnen |
| Dat_VA_Von | Exit | Dat_VA_Bis kopieren |
| Dat_VA_Bis | DblClick | Kalender oeffnen |
| Dat_VA_Bis | AfterUpdate | Einsatztage generieren |
| Auftraege_ab | DblClick | Kalender oeffnen |
| Treffp_Zeit | KeyDown | Zeitformat validieren |
| Treffp_Zeit | BeforeUpdate | Zeitformat korrigieren |
| Ort/Objekt/Treffpunkt/etc. | GotFocus | Vorschlag aus letztem Auftrag |

### 1.4 Form-Events

| Event | Beschreibung |
|-------|--------------|
| Form_Load | Maximize, Version-Label, Datum |
| Form_Open | Erster Datensatz laden, Filter setzen |
| Form_Current | Haupt-Formular Aktualisierung |
| Form_BeforeUpdate | Aend_am/Aend_von setzen |
| Form_BeforeDelConfirm | Loeschen verhindern fuer ID<=10 |

### 1.5 Wichtige Public Functions

| Funktion | Beschreibung |
|----------|--------------|
| VAOpen(iVA_ID, iVADatum_ID) | Auftrag laden mit Datum |
| VAOpen_New() | Neuer Datensatz |
| VAOpen_LastDS() | Letzter Datensatz |
| VADateSet(iVADatum_ID) | Datum setzen |
| req_rq() | Requery |
| f_AbWann() | Filter anwenden |
| lstRowAuftrag_Click(Auftrag, anzTage) | Auftrag aus Liste laden |

---

## 2. HTML-ANALYSE

### 2.1 Formular-Struktur
- **HTML-Datei:** frm_va_Auftragstamm.html (ca. 4800+ Zeilen)
- **Logic-Datei:** frm_va_Auftragstamm.logic.js (ca. 2800+ Zeilen)
- **Loader-Datei:** auftragstamm-loader.js (geschuetzt)

### 2.2 HTML onclick-Handler (frm_va_Auftragstamm.html)

| HTML-Element | onclick-Funktion | data-testid |
|--------------|------------------|-------------|
| fullscreenBtn | toggleFullscreen() | auftrag-btn-vollbild |
| (Titelleiste) | Bridge.sendEvent('minimize') | auftrag-btn-minimieren |
| (Titelleiste) | toggleMaximize() | auftrag-btn-maximieren |
| (Titelleiste) | closeForm() | auftrag-btn-schliessen |
| btnAktualisieren | refreshData() | auftrag-btn-aktualisieren |
| btnNeuAuftrag | neuerAuftrag() | auftrag-btn-neu |
| btnKopieren | auftragKopieren() | auftrag-btn-kopieren |
| btnLoeschen | auftragLoeschen() | auftrag-btn-loeschen |
| btnListeStd | namenslisteESS() | auftrag-btn-namenslisteess |
| btnDruckZusage | einsatzlisteDrucken() | auftrag-btn-einsatzliste-drucken |
| btnMailEins | sendeEinsatzlisteMA() | auftrag-btn-el-senden-ma |
| btnMailBOS | sendeEinsatzlisteBOS() | auftrag-btn-el-senden-bos |
| btnMailSub | sendeEinsatzlisteSUB() | auftrag-btn-el-senden-sub |
| btnELGesendet | showELGesendet() | auftrag-btn-el-gesendet |
| (Header-Link) | openRueckmeldStatistik() | auftrag-link-rueckmeldestatistik |
| (Header-Link) | openSyncfehler() | auftrag-link-syncfehler |
| btnDatumLeft | datumNavLeft() | auftrag-btn-datum-links |
| btnDatumRight | datumNavRight() | auftrag-btn-datum-rechts |
| btnPositionen | openPositionen() | auftrag-btn-positionen |
| btnPlan_Kopie | kopiereInFolgetag() | auftrag-btn-folgetag |
| btnSchnellPlan | openMitarbeiterauswahl() | auftrag-btn-mitarbeiterauswahl |
| btn_BWN_Druck | bwnDrucken() | auftrag-btn-bwn-drucken |
| cmd_BWN_send | bwnSenden() | auftrag-btn-bwn-senden |
| (Attach-Tab) | neuenAttachHinzufuegen() | auftrag-btn-attach-hinzufuegen |
| (Rechnung-Tab) | rechnungPDF() | auftrag-btn-rechnung-pdf |
| (Rechnung-Tab) | berechnungslistePDF() | auftrag-btn-berechnungsliste-pdf |
| (Rechnung-Tab) | rechnungDatenLaden() | auftrag-btn-rechnung-daten-laden |
| (Rechnung-Tab) | rechnungLexware() | auftrag-btn-rechnung-lexware |
| (Eventdaten-Tab) | webDatenLaden() | auftrag-btn-webdaten-laden |
| (Eventdaten-Tab) | eventdatenSpeichern() | auftrag-btn-eventdaten-speichern |
| (Filter-Bereich) | filterAuftraege() | auftrag-btn-filter-go |
| (Filter-Bereich) | tageZurueck() | auftrag-btn-tage-zurueck |
| (Filter-Bereich) | tageVor() | auftrag-btn-tage-vor |
| (Filter-Bereich) | abHeute() | auftrag-btn-ab-heute |

### 2.3 Logic.js Button-Bindings (initButtons)

| bindButton() ID | Handler-Funktion |
|-----------------|------------------|
| Befehl43 | gotoRecord(0) |
| Befehl41 | gotoRecord(index-1) |
| Befehl40 | gotoRecord(index+1) |
| btn_letzer_Datensatz | gotoRecord(last) |
| btn_rueck | undoChanges |
| Befehl38 | closeForm |
| btnDatumLeft | navigateVADatum(-1) |
| btnDatumRight | navigateVADatum(1) |
| btnReq | requeryAll |
| btn_AbWann | applyAuftraegeFilter |
| btnTgBack | shiftAuftraegeFilter(-7) |
| btnTgVor | shiftAuftraegeFilter(7) |
| btnHeute | setAuftraegeFilterToday |
| btn_Posliste_oeffnen | openPositionen |
| btnmailpos | openZusatzdateien |
| Befehl640 | kopierenAuftrag |
| btnPlan_Kopie | kopiereInFolgetag |
| btnneuveranst | neuerAuftrag |
| mcobtnDelete | loeschenAuftrag |
| cmd_Messezettel_NameEintragen | cmdMessezettelNameEintragen |
| cmd_BWN_send | cmdBWNSend |
| btn_BWN_Druck | druckeBWN |
| btnRibbonAus | toggleRibbonAus |
| btnRibbonEin | toggleRibbonEin |
| btnDaBaAus | toggleDaBaAus |
| btnDaBaEin | toggleDaBaEin |
| btn_N_HTMLAnsicht | openHTMLAnsicht |
| Befehl709 | markELGesendet |
| btn_Rueckmeld | openRueckmeldeStatistik |
| btnSyncErr | checkSyncErrors |
| btnNeuAttach | addNewAttachment |
| btnMailEins | sendeEinsatzliste('MA') |
| btn_Autosend_BOS | sendeEinsatzliste('BOS') |
| btnMailSub | sendeEinsatzliste('SUB') |
| btnDruckZusage | druckeEinsatzliste |
| btn_ListeStd | druckeNamenlisteESS |

---

## 3. VERGLEICHSMATRIX

### 3.1 Button-Paritaet

| Access Button | Access Funktion | HTML Button | HTML Funktion | Status |
|---------------|-----------------|-------------|---------------|--------|
| btnSchnellPlan | btnSchnellPlan_Click | btnSchnellPlan | openMitarbeiterauswahl() | ✅ GESCHUETZT |
| btn_Posliste_oeffnen | btn_Posliste_oeffnen_Click | btnPositionen | openPositionen() | ✅ |
| btnDatumLeft | btnDatumLeft_Click | btnDatumLeft | datumNavLeft() | ✅ |
| btnDatumRight | btnDatumRight_Click | btnDatumRight | datumNavRight() | ✅ |
| Befehl640 | Befehl640_Click (AuftragKopieren) | btnKopieren | auftragKopieren() | ✅ |
| btnPlan_Kopie | btnPlan_Kopie_Click | btnPlan_Kopie | kopiereInFolgetag() | ✅ |
| mcobtnDelete | mcobtnDelete_Click | btnLoeschen | auftragLoeschen() | ✅ |
| btnNeuVeranst | btnNeuVeranst_Click | btnNeuAuftrag | neuerAuftrag() | ✅ |
| btnMailEins | btnMailEins_Click | btnMailEins | sendeEinsatzlisteMA() | ✅ |
| btn_Autosend_BOS | btn_Autosend_BOS_Click | btnMailBOS | sendeEinsatzlisteBOS() | ✅ |
| btnMailSub | btnMailSub_Click | btnMailSub | sendeEinsatzlisteSUB() | ✅ |
| btn_ListeStd | btn_ListeStd_Click | btnListeStd | namenslisteESS() | ✅ |
| btnDruckZusage | btnDruckZusage_Click | btnDruckZusage | einsatzlisteDrucken() | ✅ |
| btnSyncErr | btnSyncErr_Click | (Header-Link) | openSyncfehler() | ✅ |
| btn_Rueckmeld | btn_Rueckmeld_Click | (Header-Link) | openRueckmeldStatistik() | ✅ |
| btn_AbWann | btn_AbWann_Click | (Go-Button) | filterAuftraege() | ✅ |
| btnTgBack | btnTgBack_Click | (<<-Button) | tageZurueck() | ⚠️ -7 statt -3 |
| btnTgVor | btnTgVor_Click | (>>-Button) | tageVor() | ⚠️ +7 statt +3 |
| btnHeute | btnHeute_Click | (Ab Heute) | abHeute() | ✅ |
| btnNeuAttach | btnNeuAttach_Click | (Attach-Tab) | neuenAttachHinzufuegen() | ✅ |
| btnAuftrBerech | btnAuftrBerech_Click | - | - | ❌ FEHLT |
| btnDruck | btnDruck_Click | - | - | ❌ FEHLT |
| btnDruckZusage1 | btnDruckZusage1_Click | - | - | ❌ FEHLT |
| btn_VA_Neu_Aus_Vorlage | btn_VA_Neu_Aus_Vorlage_Click | - | - | ❌ FEHLT |
| btn_VA_Abwesenheiten | btn_VA_Abwesenheiten_Click | - | - | ❌ FEHLT |
| btn_std_check | btn_std_check_Click | - | - | ❌ FEHLT |
| btn_sortieren | btn_sortieren_Click | - | - | ❌ FEHLT |
| btnVAPlanCrea | btnVAPlanCrea_Click | - | - | ❌ FEHLT |
| btnVAPlanAendern | btnVAPlanAendern_Click | - | - | ❌ FEHLT |
| btn_rueckgaengig | btn_rueckgaengig_Click | - | - | ❌ FEHLT |
| btnXLEinsLst | btnXLEinsLst_Click | - | - | ❌ FEHLT |
| Befehl658 | Befehl658_Click | - | - | ❌ FEHLT |
| btnMailPos | btnMailPos_Click | - | - | ❌ FEHLT (Positionen-Mail) |
| cmd_BWN_send | cmd_BWN_send_Click | cmd_BWN_send | bwnSenden() | ✅ |
| btn_BWN_Druck | btn_BWN_Druck_Click | btn_BWN_Druck | bwnDrucken() | ✅ |
| cmd_Messezettel_NameEintragen | cmd_Messezettel_NameEintragen_Click | cmd_Messezettel_NameEintragen | - | ⚠️ Nur Binding, keine Impl. |
| Befehl709 | Befehl709_Click | Befehl709 | markELGesendet() | ⚠️ Andere Funktion |

### 3.2 Field-Events Paritaet

| Access Feld | Access Event | HTML Feld | HTML Event | Status |
|-------------|--------------|-----------|------------|--------|
| cboVADatum | AfterUpdate | cboVADatum | change | ✅ |
| cboVADatum | DblClick | cboVADatum | dblclick | ✅ |
| Veranstalter_ID | DblClick | Veranstalter_ID | dblclick | ✅ |
| Veranst_Status_ID | AfterUpdate | Veranst_Status_ID | change | ✅ |
| Veranst_Status_ID | BeforeUpdate | - | - | ⚠️ Nur confirm() |
| Objekt_ID | AfterUpdate | Objekt_ID | change | ✅ |
| Objekt_ID | DblClick | Objekt_ID | dblclick | ✅ |
| Dat_VA_Bis | AfterUpdate | - | - | ❌ FEHLT (Einsatztage gen.) |
| Dat_VA_Von | DblClick | Auftraege_ab | dblclick | ✅ |
| Treffp_Zeit | KeyDown | Treffp_Zeit | keydown | ✅ |
| Ort/Objekt/etc. | GotFocus | - | - | ❌ FEHLT (Vorschlaege) |
| cboAnstArt | DblClick | cboAnstArt | dblclick | ✅ |

### 3.3 Form-Events Paritaet

| Access Event | HTML Equivalent | Status |
|--------------|-----------------|--------|
| Form_Load | DOMContentLoaded | ✅ |
| Form_Open | loadInitialData() | ✅ |
| Form_Current | loadAuftrag() | ✅ |
| Form_BeforeUpdate | saveField() | ⚠️ Nur einzelne Felder |
| Form_BeforeDelConfirm | confirm() | ⚠️ Keine ID<=10 Pruefung |

---

## 4. KRITISCHE LUECKEN

### 4.1 Hohe Prioritaet (Kernfunktionen)

| Nr | Luecke | Access-Funktion | Auswirkung |
|----|--------|-----------------|------------|
| L1 | **Einsatztage automatisch generieren** | Dat_VA_Bis_AfterUpdate | Mehrtaegige Auftraege funktionieren nicht korrekt |
| L2 | **Zuordnungs-Saetze erzeugen** | btnVAPlanCrea_Click | MA-Planung kann nicht initialisiert werden |
| L3 | **Status-Check mit Druck** | btn_std_check_Click | Workflow "Beenden" unvollstaendig |
| L4 | **Excel-Export Einsatzliste** | btnXLEinsLst_Click | Wichtige Reporting-Funktion fehlt |
| L5 | **Rechnungsbereich** | btnAuftrBerech_Click | Rechnungserstellung nicht moeglich |

### 4.2 Mittlere Prioritaet (Komfort)

| Nr | Luecke | Access-Funktion | Auswirkung |
|----|--------|-----------------|------------|
| M1 | **Vorschlagswerte aus letztem Auftrag** | Ort_GotFocus etc. | Keine Auto-Vervollstaendigung |
| M2 | **Sortierung Zuordnung** | btn_sortieren_Click | MA-Liste manuell sortieren |
| M3 | **VA aus Vorlage erstellen** | btn_VA_Neu_Aus_Vorlage_Click | Schnelles Anlegen fehlt |
| M4 | **Abwesenheitsuebersicht** | btn_VA_Abwesenheiten_Click | Link zu Abwesenheiten fehlt |
| M5 | **PDF-Ausdruck** | btnDruck_Click | Direkter PDF-Druck fehlt |

### 4.3 Niedrige Prioritaet (Spezial)

| Nr | Luecke | Access-Funktion | Auswirkung |
|----|--------|-----------------|------------|
| N1 | **Ribbon Toggle** | btnRibbonAus/Ein_Click | Nur Access-UI relevant |
| N2 | **Datenbank Toggle** | btnDaBaAus/Ein_Click | Nur Access-UI relevant |
| N3 | **Loeschen erlauben** | btnVAPlanAendern_Click | Temporaerer Modus |
| N4 | **Mail an Positionen** | btnMailPos_Click | Selten verwendet |

### 4.4 Abweichungen

| Nr | Abweichung | Access | HTML | Empfehlung |
|----|------------|--------|------|------------|
| A1 | Tage-Navigation | +/- 3 Tage | +/- 7 Tage | HTML anpassen auf 3 |
| A2 | Befehl709 | Log-Tabelle oeffnen | markELGesendet() | Funktion pruefen |

---

## 5. EMPFOHLENE KORREKTUREN

### 5.1 Sofort umsetzen (Kritisch)

#### L1: Einsatztage automatisch generieren
**Access-Logik (Dat_VA_Bis_AfterUpdate):**
```vba
' Generiert Eintraege in tbl_VA_AnzTage fuer jeden Tag zwischen Von und Bis
' Aktualisiert cboVADatum.RowSource
```

**HTML-Korrektur:**
- Event-Listener auf `Dat_VA_Bis` change
- API-Call: `POST /api/auftraege/{id}/generate_days`
- Backend muss tbl_VA_AnzTage fuellen

#### L2: Zuordnungs-Saetze erzeugen (btnVAPlanCrea)
**Access-Logik:**
```vba
Zuord_Fill Me!cboVADatum.Column(0), Me!ID
fTag_Schicht_Update_Tag Me!cboVADatum.Column(0), Me!ID
```

**HTML-Korrektur:**
- Button hinzufuegen oder automatisch bei Schicht-Erstellung
- API-Call: `POST /api/auftraege/{id}/init_zuordnungen`

### 5.2 Mittelfristig (Komfort)

#### A1: Tage-Navigation korrigieren
**Datei:** `frm_va_Auftragstamm.logic.js`
**Zeilen:** 134-135

**Aenderung:**
```javascript
// ALT:
bindButton('btnTgBack', () => shiftAuftraegeFilter(-7));
bindButton('btnTgVor', () => shiftAuftraegeFilter(7));

// NEU:
bindButton('btnTgBack', () => shiftAuftraegeFilter(-3));
bindButton('btnTgVor', () => shiftAuftraegeFilter(3));
```

### 5.3 GESCHUETZTE BEREICHE (NICHT AENDERN!)

Die folgenden Funktionen sind in CLAUDE.md als GESCHUETZT markiert und duerfen NUR mit expliziter Genehmigung geaendert werden:

1. **openMitarbeiterauswahl()** - btnSchnellPlan
2. **sub_MA_VA_Zuordnung REST-API Modus**
3. **List_MA_DblClick** in Schnellauswahl

---

## 6. API-ENDPOINT STATUS

### 6.1 Vorhandene Endpoints (api_server.py Port 5000)

| Endpoint | Methode | Verwendet von | Status |
|----------|---------|---------------|--------|
| /api/auftraege | GET | loadAuftraegeListe() | ✅ |
| /api/auftraege/{id} | GET | loadAuftrag() | ✅ |
| /api/auftraege/{id}/schichten | GET | loadSubformData() | ✅ GESCHUETZT |
| /api/auftraege/{id}/zuordnungen | GET | loadSubformData() | ✅ GESCHUETZT |
| /api/auftraege/{id}/absagen | GET | loadSubformData() | ✅ GESCHUETZT |
| /api/auftraege | POST | neuerAuftrag() | ✅ |
| /api/auftraege/{id} | PUT | saveField() | ✅ |
| /api/auftraege/{id} | DELETE | auftragLoeschen() | ✅ |
| /api/auftraege/{id}/copy | POST | auftragKopieren() | ✅ |

### 6.2 Fehlende Endpoints

| Endpoint | Methode | Benoetigt fuer |
|----------|---------|----------------|
| /api/auftraege/{id}/generate_days | POST | L1: Einsatztage generieren |
| /api/auftraege/{id}/init_zuordnungen | POST | L2: Zuordnungen initialisieren |
| /api/auftraege/{id}/copy_to_next_day | POST | kopiereInFolgetag() (teilweise) |
| /api/auftraege/{id}/excel_export | GET | btnXLEinsLst |

### 6.3 VBA Bridge Endpoints (Port 5002)

| Endpoint | Methode | Verwendet von | Status |
|----------|---------|---------------|--------|
| /api/vba/anfragen | POST | sendeEinsatzliste() | ✅ |
| /api/vba/execute | POST | callVBAFunction() | ✅ |

---

## 7. ZUSAMMENFASSUNG

### Gesamtstatus
- **Buttons implementiert:** 25 von 40 (~63%)
- **Field-Events implementiert:** 8 von 15 (~53%)
- **Form-Events implementiert:** 3 von 5 (~60%)

### Naechste Schritte
1. **KRITISCH:** Einsatztage-Generierung implementieren (L1)
2. **KRITISCH:** Zuordnungs-Initialisierung implementieren (L2)
3. **WICHTIG:** Tage-Navigation korrigieren (A1: 7 -> 3)
4. **KOMFORT:** Vorschlagswerte implementieren (M1)

### Hinweise
- Alle Aenderungen an GESCHUETZTEN Bereichen erfordern explizite Genehmigung
- API-Endpoints muessen fuer fehlende Funktionen erweitert werden
- VBA-Bridge wird fuer E-Mail-Funktionen benoetigt

---

*Audit erstellt am 2026-01-16 durch Claude Code*
