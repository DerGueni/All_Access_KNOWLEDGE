# Button-Abweichungsanalyse: HTML vs Access

**Erstellt:** analyze_button_deviations
**Datum:** 2026-01-15

## Zusammenfassung

- **Gesamt:** 397 Button-Einträge
- **[OK] Identisch:** 28 (7%)
- **[MISS] Fehlt in HTML:** 141
- **[NEW] Nur in HTML:** 228

## Legende

- **[OK]** - Button existiert in beiden (HTML und Access) mit gleichem Label
- **[MISS]** - Button existiert nur in Access, fehlt in HTML
- **[NEW]** - Button existiert nur in HTML, nicht in Access

---

## Details nach HTML-Formular

### frm_Abwesenheiten.html

**Buttons:** 7 | OK: 0 | MISS: 0 | NEW: 7

| Status | Label | HTML ID | HTML Action | Access Name | Access OnClick |
|--------|-------|---------|-------------|-------------|----------------|
| ➕ NEW | &#9654; | btnNächster | ... |  | ... |
| ➕ NEW | &#9654;| | btnLetzter | ... |  | ... |
| ➕ NEW | &#9664; | btnVorheriger | ... |  | ... |
| ➕ NEW | + Neu | btnNeu | ... |  | ... |
| ➕ NEW | Löschen | btnLöschen | ... |  | ... |
| ➕ NEW | Speichern | btnSpeichern | ... |  | ... |
| ➕ NEW | |&#9664; | btnErster | ... |  | ... |

### frm_DP_Dienstplan_MA.html

**Buttons:** 23 | OK: 7 | MISS: 7 | NEW: 9

| Status | Label | HTML ID | HTML Action | Access Name | Access OnClick |
|--------|-------|---------|-------------|-------------|----------------|
| ❌ MISS |  |  | ... | btnVor | [Event Procedure]... |
| ❌ MISS |  |  | ... | btnrueck | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnRibbonAus | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnRibbonEin | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnDaBaEin | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnDaBaAus | [Event Procedure]... |
| ❌ MISS | btn_Formular_schliessen |  | ... | Befehl37 | [Eingebettetes Makro]... |
| ➕ NEW | &gt; | btnVor | ... |  | ... |
| ➕ NEW | &lt; | btnrueck | ... |  | ... |
| ➕ NEW | &times; | Befehl37 | ... |  | ... |
| ➕ NEW | + | btnDaBaEin | ... |  | ... |
| ➕ NEW | + | btnRibbonEin | ... |  | ... |
| ➕ NEW | - | btnRibbonAus | ... |  | ... |
| ➕ NEW | - | btnDaBaAus | ... |  | ... |
| ➕ NEW | ⛶ | fullscreenBtn | toggleFullscreen()... |  | ... |
| ➕ NEW | ⛶ | fullscreenBtn | ... |  | ... |
| ✅ OK | Ab Heute | btn_Heute | ... | btn_Heute | [Event Procedure]... |
| ✅ OK | Dienstpläne senden bis | btnDPSenden | ... | btnDPSenden | [Event Procedure]... |
| ✅ OK | Einzeldienstpläne | btnMADienstpl | ... | btnMADienstpl | [Event Procedure]... |
| ✅ OK | Senden | Befehl20 | ... | Befehl20 | [Event Procedure]... |
| ✅ OK | Startdatum Ändern | btnStartdatum | ... | btnStartdatum | [Event Procedure]... |
| ✅ OK | Übersicht drucken | btnOutpExcel | ... | btnOutpExcel | [Event Procedure]... |
| ✅ OK | Übersicht senden | btnOutpExcelSend | ... | btnOutpExcelSend | [Event Procedure]... |

### frm_DP_Dienstplan_Objekt.html

**Buttons:** 16 | OK: 3 | MISS: 8 | NEW: 5

| Status | Label | HTML ID | HTML Action | Access Name | Access OnClick |
|--------|-------|---------|-------------|-------------|----------------|
| ❌ MISS |  |  | ... | btnVor | [Event Procedure]... |
| ❌ MISS |  |  | ... | btnrueck | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnRibbonAus | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnRibbonEin | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnDaBaEin | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnDaBaAus | [Event Procedure]... |
| ❌ MISS | btn_Formular_schliessen |  | ... | Befehl37 | [Eingebettetes Makro]... |
| ❌ MISS | Übersicht senden |  | ... | btnOutpExcelSend | [Event Procedure]... |
| ➕ NEW | &#9974; | fullscreenBtn | toggleFullscreen()... |  | ... |
| ➕ NEW | &#9974; | fullscreenBtn | ... |  | ... |
| ➕ NEW | &gt; | btnVor | ... |  | ... |
| ➕ NEW | &lt; | btnrueck | ... |  | ... |
| ➕ NEW | &times; | Befehl37 | ... |  | ... |
| ✅ OK | Ab Heute | btn_Heute | ... | btn_Heute | [Event Procedure]... |
| ✅ OK | Startdatum Ändern | btnStartdatum | ... | btnStartdatum | [Event Procedure]... |
| ✅ OK | Übersicht drucken | btnOutpExcel | ... | btnOutpExcel | [Event Procedure]... |

### frm_Einsatzuebersicht.html

**Buttons:** 20 | OK: 0 | MISS: 0 | NEW: 20

| Status | Label | HTML ID | HTML Action | Access Name | Access OnClick |
|--------|-------|---------|-------------|-------------|----------------|
| ➕ NEW | &gt;&gt; | btnVor | btnVor_Click()... |  | ... |
| ➕ NEW | &gt;&gt; | btnVor | ... |  | ... |
| ➕ NEW | &lt;&lt; | btnZurueck | btnZurueck_Click()... |  | ... |
| ➕ NEW | &lt;&lt; | btnZurueck | ... |  | ... |
| ➕ NEW | Aktualisieren | btnAktualisieren | btnAktualisieren_Click()... |  | ... |
| ➕ NEW | Aktualisieren | btnAktualisieren | ... |  | ... |
| ➕ NEW | Diese Woche | btnFilterWoche | setQuickFilter(... |  | ... |
| ➕ NEW | Diese Woche | btnFilterWoche | ... |  | ... |
| ➕ NEW | Dieser Monat | btnFilterMonat | setQuickFilter(... |  | ... |
| ➕ NEW | Dieser Monat | btnFilterMonat | ... |  | ... |
| ➕ NEW | Drucken | btnDrucken | btnDrucken_Click()... |  | ... |
| ➕ NEW | Drucken | btnDrucken | ... |  | ... |
| ➕ NEW | Export Excel | btnExportExcel | btnExportExcel_Click()... |  | ... |
| ➕ NEW | Export Excel | btnExportExcel | ... |  | ... |
| ➕ NEW | Heute | btnHeute | btnHeute_Click()... |  | ... |
| ➕ NEW | Heute | btnFilterHeute | setQuickFilter(... |  | ... |
| ➕ NEW | Heute | btnHeute | ... |  | ... |
| ➕ NEW | Heute | btnFilterHeute | ... |  | ... |
| ➕ NEW | X | btnClose | closeForm()... |  | ... |
| ➕ NEW | X | btnClose | ... |  | ... |

### frm_KD_Kundenstamm.html

**Buttons:** 47 | OK: 3 | MISS: 14 | NEW: 30

| Status | Label | HTML ID | HTML Action | Access Name | Access OnClick |
|--------|-------|---------|-------------|-------------|----------------|
| ❌ MISS | Auswahlfilter |  | ... | btnAlle | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnRibbonAus | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnRibbonEin | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnDaBaEin | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnDaBaAus | [Event Procedure]... |
| ❌ MISS | Berechnungsliste |  | ... | btnAufRchPosPDF | [Event Procedure]... |
| ❌ MISS | Einsatzliste |  | ... | btnAufEinsPDF | [Event Procedure]... |
| ❌ MISS | Kunden löschen |  | ... | mcobtnDelete | [Eingebettetes Makro]... |
| ❌ MISS | Neuen Anlage hinzufügen |  | ... | btnNeuAttach | [Event Procedure]... |
| ❌ MISS | Rechnung |  | ... | btnAufRchPDF | [Event Procedure]... |
| ❌ MISS | btn_Datensatz_vor |  | ... | Befehl40 | [Eingebettetes Makro]... |
| ❌ MISS | btn_Datensatz_zurueck |  | ... | Befehl41 | [Eingebettetes Makro]... |
| ❌ MISS | btn_erster_Datensatz |  | ... | Befehl43 | [Eingebettetes Makro]... |
| ❌ MISS | btn_letzter_Datensatz |  | ... | Befehl39 | [Eingebettetes Makro]... |
| ➕ NEW | &gt; | kd-btn-naechste | ... |  | ... |
| ➕ NEW | &gt;| | kd-btn-letzte | ... |  | ... |
| ➕ NEW | &lt; | kd-btn-vorige | ... |  | ... |
| ➕ NEW | Aktualisieren | btnAktualisieren | refreshData()... |  | ... |
| ➕ NEW | Aktualisieren | kd-btn-aktualisieren | ... |  | ... |
| ➕ NEW | Angebote | kd-tab-angebote | ... |  | ... |
| ➕ NEW | Ansprechpartner | kd-tab-ansprechpartner | ... |  | ... |
| ➕ NEW | Auftragsübersicht | kd-tab-auftragsuebersicht | ... |  | ... |
| ➕ NEW | Bemerkungen | kd-tab-bemerkungen | ... |  | ... |
| ➕ NEW | Konditionen | kd-tab-konditionen | ... |  | ... |
| ➕ NEW | Kunde löschen | btnLoeschen | kundeLoeschen()... |  | ... |
| ➕ NEW | Kunde löschen | kd-btn-loeschen | ... |  | ... |
| ➕ NEW | Objekte | kd-tab-objekte | ... |  | ... |
| ➕ NEW | Preise | kd-tab-preise | ... |  | ... |
| ➕ NEW | Speichern | btnSpeichern | speichern()... |  | ... |
| ➕ NEW | Speichern | kd-btn-speichern | ... |  | ... |
| ➕ NEW | Stammdaten | kd-tab-stammdaten | ... |  | ... |
| ➕ NEW | Statistik | kd-tab-statistik | ... |  | ... |
| ➕ NEW | Zusatzdateien | kd-tab-zusatzdateien | ... |  | ... |
| ➕ NEW | _ | kd-btn-minimieren | ... |  | ... |
| ➕ NEW | |&lt; | kd-btn-erste | ... |  | ... |
| ➕ NEW | □ | kd-btn-maximieren | ... |  | ... |
| ➕ NEW | ⛶ | fullscreenBtn | toggleFullscreen()... |  | ... |
| ➕ NEW | ⛶ | kd-btn-vollbild | ... |  | ... |
| ➕ NEW | ✉ Outlook | btnOutlook | openOutlook()... |  | ... |
| ➕ NEW | ✉ Outlook | kd-btn-outlook | ... |  | ... |
| ➕ NEW | ✕ | kd-btn-schliessen | ... |  | ... |
| ➕ NEW | 📄 Word | btnWord | openWord()... |  | ... |
| ➕ NEW | 📄 Word | kd-btn-word | ... |  | ... |
| ➕ NEW | 🔍 | kd-btn-nrsuche | ... |  | ... |
| ✅ OK | Neuer Kunde | kd-btn-neu | ... | Befehl46 | [Event Procedure]... |
| ✅ OK | Umsatzauswertung | kd-btn-umsatzauswertung | ... | btnUmsAuswert | [Event Procedure]... |
| ✅ OK | Verrechnungssätze | kd-btn-verrechnungssaetze | ... | btnAuswertung | [Event Procedure]... |

### frm_MA_Abwesenheit.html

**Buttons:** 6 | OK: 0 | MISS: 0 | NEW: 6

| Status | Label | HTML ID | HTML Action | Access Name | Access OnClick |
|--------|-------|---------|-------------|-------------|----------------|
| ➕ NEW | &#x26F6; | fullscreenBtn | toggleFullscreen()... |  | ... |
| ➕ NEW | &#x26F6; | fullscreenBtn | ... |  | ... |
| ➕ NEW | Alle löschen | btnAllLoesch | ... |  | ... |
| ➕ NEW | Berechnen | btnAbwBerechnen | ... |  | ... |
| ➕ NEW | Markierte löschen | btnMarkLoesch | ... |  | ... |
| ➕ NEW | Uebernehmen | bznUebernehmen | ... |  | ... |

### frm_MA_Mitarbeiterstamm.html

**Buttons:** 84 | OK: 5 | MISS: 36 | NEW: 43

| Status | Label | HTML ID | HTML Action | Access Name | Access OnClick |
|--------|-------|---------|-------------|-------------|----------------|
| ❌ MISS |  Neuer Mitarbeiter |  | ... | Befehl46 | [Eingebettetes Makro]... |
| ❌ MISS | ... |  | ... | btnDateisuch | [Event Procedure]... |
| ❌ MISS | ... |  | ... | btnDateisuch2 | [Event Procedure]... |
| ❌ MISS | Abzüge |  | ... | btnZuAb | [Event Procedure]... |
| ❌ MISS | Ausgabeformular |  | ... | btnReport_Dienstkleidung | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnRibbonAus | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnRibbonEin | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnDaBaEin | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnDaBaAus | [Event Procedure]... |
| ❌ MISS | Drucken |  | ... | Bericht_drucken | [Event Procedure]... |
| ❌ MISS | Drucken |  | ... | btn_Diensplan_prnt | [Event Procedure]... |
| ❌ MISS | Einsätze übertragen FA |  | ... | btnZKFest | [Event Procedure]... |
| ❌ MISS | Einsätze übertragen MJ |  | ... | btnZKMini | [Event Procedure]... |
| ❌ MISS | Einsätze übertragen einzeln |  | ... | btnZKeinzel | [Event Procedure]... |
| ❌ MISS | Excel Export |  | ... | btnXLZeitkto | [Event Procedure]... |
| ❌ MISS | Excel-Export |  | ... | btnXLJahr | [Event Procedure]... |
| ❌ MISS | Excel-Export |  | ... | btnXLEinsUeber | [Event Procedure]... |
| ❌ MISS | Excel-Export |  | ... | btnXLUeberhangStd | [Event Procedure]... |
| ❌ MISS | Excel-Export |  | ... | btnXLDiePl | [Event Procedure]... |
| ❌ MISS | Excel-Export |  | ... | btnXLNverfueg | [Event Procedure]... |
| ❌ MISS | Excel-Export |  | ... | btnXLVordrucke | [Event Procedure]... |
| ❌ MISS | Listen drucken |  | ... | btnLstDruck | [Event Procedure]... |
| ❌ MISS | Maps öffnen |  | ... | btnMaps | [Event Procedure]... |
| ❌ MISS | Mitarbeiter Tabelle |  | ... | lbl_Mitarbeitertabelle | [Event Procedure]... |
| ❌ MISS | Rechnungsdetails |  | ... | btnRch | [Event Procedure]... |
| ❌ MISS | Senden |  | ... | btn_Dienstplan_send | [Event Procedure]... |
| ❌ MISS | Stundennachweis |  | ... | btnCalc | [Event Procedure]... |
| ❌ MISS | Termine  eingeben |  | ... | btnMehrfachtermine | [Event Procedure]... |
| ❌ MISS | Update Jahr |  | ... | btnUpdJahr | [Event Procedure]... |
| ❌ MISS | Vordrucke für MA aktualisieren / einlesen |  | ... | btn_MA_EinlesVorlageDatei | [Event Procedure]... |
| ❌ MISS | Wochen-Dienstplan |  | ... | btnMADienstpl | [Event Procedure]... |
| ❌ MISS | Zeitkonto  |  | ... | btnZeitkonto | [Event Procedure]... |
| ❌ MISS | btn_Datensatz_vor |  | ... | Befehl40 | [Eingebettetes Makro]... |
| ❌ MISS | btn_Datensatz_zurueck |  | ... | Befehl41 | [Eingebettetes Makro]... |
| ❌ MISS | btn_erster_Datensatz |  | ... | Befehl43 | [Eingebettetes Makro]... |
| ❌ MISS | btn_letzter_Datensatz |  | ... | Befehl39 | [Eingebettetes Makro]... |
| ➕ NEW | &#10005; | ma-btn-schliessen | ... |  | ... |
| ➕ NEW | &#9633; | ma-btn-maximieren | ... |  | ... |
| ➕ NEW | Bestand Dienstkleidung | ma-tab-dienstkleidung | ... |  | ... |
| ➕ NEW | Briefkopf | ma-tab-briefkopf | ... |  | ... |
| ➕ NEW | Dienstplan | btnDienstplan | openDienstplan()... |  | ... |
| ➕ NEW | Dienstplan | ma-btn-dienstplan | ... |  | ... |
| ➕ NEW | Dienstplan | ma-tab-dienstplan | ... |  | ... |
| ➕ NEW | Dokumente | ma-tab-dokumente | ... |  | ... |
| ➕ NEW | Einsatzübersicht | btnEinsatzÜbersicht | openEinsatzübersicht()... |  | ... |
| ➕ NEW | Einsatzübersicht | ma-btn-einsatzuebersicht | ... |  | ... |
| ➕ NEW | Einsatzübersicht | ma-tab-einsatzuebersicht | ... |  | ... |
| ➕ NEW | Einsätze FA | btnEinsaetzeFA | einsaetzeUebertragen(... |  | ... |
| ➕ NEW | Einsätze FA | ma-btn-einsaetze-fa | ... |  | ... |
| ➕ NEW | Einsätze MJ | btnEinsaetzeMJ | einsaetzeUebertragen(... |  | ... |
| ➕ NEW | Einsätze MJ | ma-btn-einsaetze-mj | ... |  | ... |
| ➕ NEW | Jahresübersicht | ma-tab-jahresuebersicht | ... |  | ... |
| ➕ NEW | Karte | ma-tab-karte | ... |  | ... |
| ➕ NEW | MA Adressen | btnMAAdressen | openMAAdressen()... |  | ... |
| ➕ NEW | MA Adressen | ma-btn-maadressen | ... |  | ... |
| ➕ NEW | Neuer Mitarbeiter | btnNeuMA | neuerMitarbeiter()... |  | ... |
| ➕ NEW | Neuer Mitarbeiter | ma-btn-neu | ... |  | ... |
| ➕ NEW | Nicht Verfügbar | ma-tab-nichtverfuegbar | ... |  | ... |
| ➕ NEW | Qualifikationen | ma-tab-qualifikationen | ... |  | ... |
| ➕ NEW | Quick Info | ma-tab-quickinfo | ... |  | ... |
| ➕ NEW | Speichern | btnSpeichern | speichern()... |  | ... |
| ➕ NEW | Speichern | ma-btn-speichern | ... |  | ... |
| ➕ NEW | Stammdaten | ma-tab-stammdaten | ... |  | ... |
| ➕ NEW | Stundenübers. | ma-tab-stundenuebersicht | ... |  | ... |
| ➕ NEW | Sub Rechnungen | ma-tab-subrechnungen | ... |  | ... |
| ➕ NEW | Uberhang Std. | ma-tab-ueberhangstunden | ... |  | ... |
| ➕ NEW | Vordrucke | ma-tab-vordrucke | ... |  | ... |
| ➕ NEW | ZK Einzel | btnZKeinzel | btnZKeinzel_Click()... |  | ... |
| ➕ NEW | ZK Einzel | ma-btn-zkeinzel | ... |  | ... |
| ➕ NEW | ZK Fest | btnZKFest | btnZKFest_Click()... |  | ... |
| ➕ NEW | ZK Fest | ma-btn-zkfest | ... |  | ... |
| ➕ NEW | ZK Mini | btnZKMini | btnZKMini_Click()... |  | ... |
| ➕ NEW | ZK Mini | ma-btn-zkmini | ... |  | ... |
| ➕ NEW | Zeitkonto | btnZeitkonto | openZeitkonto()... |  | ... |
| ➕ NEW | Zeitkonto | ma-btn-zeitkonto | ... |  | ... |
| ➕ NEW | Zeitkonto | ma-tab-zeitkonto | ... |  | ... |
| ➕ NEW | _ | ma-btn-minimieren | ... |  | ... |
| ➕ NEW | â›¶ | fullscreenBtn | toggleFullscreen()... |  | ... |
| ➕ NEW | â›¶ | ma-btn-vollbild | ... |  | ... |
| ✅ OK | Aktualisieren | ma-btn-aktualisieren | ... | btnLesen | [Event Procedure]... |
| ✅ OK | Aktualisieren | ma-btn-aktualisieren | ... | btnAU_Lesen | [Event Procedure]... |
| ✅ OK | Aktualisieren | ma-btn-aktualisieren | ... | btnau_lesen2 | ... |
| ✅ OK | Aktualisieren | ma-btn-aktualisieren | ... | btnAUPl_Lesen | [Event Procedure]... |
| ✅ OK | Mitarbeiter löschen | ma-btn-loeschen | ... | mcobtnDelete | [Eingebettetes Makro]... |

### frm_MA_Serien_eMail_Auftrag.html

**Buttons:** 16 | OK: 0 | MISS: 14 | NEW: 2

| Status | Label | HTML ID | HTML Action | Access Name | Access OnClick |
|--------|-------|---------|-------------|-------------|----------------|
| ❌ MISS |  Senden |  | ... | btnSendEmail | [Event Procedure]... |
| ❌ MISS | ... |  | ... | btnAttachSuch | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnRibbonAus | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnRibbonEin | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnDaBaEin | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnDaBaAus | [Event Procedure]... |
| ❌ MISS | Einsatzliste drucken |  | ... | btnPDFCrea | [Event Procedure]... |
| ❌ MISS | Hilfe |  | ... | btnHilfe | [Eingebettetes Makro]... |
| ❌ MISS | Löschen |  | ... | btnAttLoesch | [Event Procedure]... |
| ❌ MISS | Mitarbeiterauswahl |  | ... | btnSchnellPlan | [Event Procedure]... |
| ❌ MISS | Positionsliste hinzufügen |  | ... | btnPosListeAtt | [Event Procedure]... |
| ❌ MISS | Zu / Absagen bearbeiten |  | ... | btnZuAbsage | [Event Procedure]... |
| ❌ MISS | Zurück zum Auftrag |  | ... | btnAuftrag | [Event Procedure]... |
| ❌ MISS | btn_Formular_schliessen |  | ... | Befehl38 | [Eingebettetes Makro]... |
| ➕ NEW | E-Mails senden | btnSenden | ... |  | ... |
| ➕ NEW | Vorschau | btnVorschau | ... |  | ... |

### frm_MA_Serien_eMail_dienstplan.html

**Buttons:** 16 | OK: 0 | MISS: 14 | NEW: 2

| Status | Label | HTML ID | HTML Action | Access Name | Access OnClick |
|--------|-------|---------|-------------|-------------|----------------|
| ❌ MISS |  Senden |  | ... | btnSendEmail | [Event Procedure]... |
| ❌ MISS | ... |  | ... | btnAttachSuch | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnRibbonAus | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnRibbonEin | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnDaBaEin | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnDaBaAus | [Event Procedure]... |
| ❌ MISS | Einsatzliste |  | ... | btnAuftrag | [Event Procedure]... |
| ❌ MISS | Einsatzliste drucken |  | ... | btnPDFCrea | [Event Procedure]... |
| ❌ MISS | Hilfe |  | ... | btnHilfe | [Eingebettetes Makro]... |
| ❌ MISS | Löschen |  | ... | btnAttLoesch | [Event Procedure]... |
| ❌ MISS | Mitarbeiterauswahl |  | ... | btnSchnellPlan | [Event Procedure]... |
| ❌ MISS | Positionsliste hinzufügen |  | ... | btnPosListeAtt | [Event Procedure]... |
| ❌ MISS | Zu / Absagen bearbeiten |  | ... | btnZuAbsage | [Event Procedure]... |
| ❌ MISS | btn_Formular_schliessen |  | ... | Befehl38 | [Eingebettetes Makro]... |
| ➕ NEW | E-Mails senden | btnSenden | ... |  | ... |
| ➕ NEW | Vorschau | btnVorschau | ... |  | ... |

### frm_MA_VA_Schnellauswahl.html

**Buttons:** 32 | OK: 10 | MISS: 12 | NEW: 10

| Status | Label | HTML ID | HTML Action | Access Name | Access OnClick |
|--------|-------|---------|-------------|-------------|----------------|
| ❌ MISS | Alle  |  | ... | btnDelAll | ... |
| ❌ MISS | Auswählen |  | ... | btnAddSelected | [Event Procedure]... |
| ❌ MISS | Auswählen |  | ... | btnAddZusage | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnRibbonAus | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnRibbonEin | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnDaBaEin | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnDaBaAus | [Event Procedure]... |
| ❌ MISS | Entfernen |  | ... | btnDelSelected | [Event Procedure]... |
| ❌ MISS | Hilfe |  | ... | btnHilfe | [Eingebettetes Makro]... |
| ❌ MISS | Löschen |  | ... | btnDelZusage | [Event Procedure]... |
| ❌ MISS | Verschieben |  | ... | btnMoveZusage | [Event Procedure]... |
| ❌ MISS | btn_Formular_schliessen |  | ... | Befehl38 | [Eingebettetes Makro]... |
| ➕ NEW | &larr; | btnDelSelected | ... |  | ... |
| ➕ NEW | &larr; | btnMoveZusage | ... |  | ... |
| ➕ NEW | &rarr; | btnAddSelected | ... |  | ... |
| ➕ NEW | &rarr; | btnAddZusage | ... |  | ... |
| ➕ NEW | &times; | btnDelAll | ... |  | ... |
| ➕ NEW | &times; | btnDelZusage | ... |  | ... |
| ➕ NEW | &times; | anfrageModalCloseX | ... |  | ... |
| ➕ NEW | Schließen | anfrageModalCloseBtn | ... |  | ... |
| ➕ NEW | â›¶ | fullscreenBtn | toggleFullscreen()... |  | ... |
| ➕ NEW | â›¶ | fullscreenBtn | ... |  | ... |
| ✅ OK | Alle Mitarbeiter anfragen | btnMail | ... | btnMail | [Event Procedure]... |
| ✅ OK | Entfernung | cmdListMA_Entfernung | ... | cmdListMA_Entfernung | =cmdListMA_Entfernung_Click()... |
| ✅ OK | GO | btnSchnellGo | ... | btnSchnellGo | [Event Procedure]... |
| ✅ OK | Manuelles Bearbeiten | btnZuAbsage | ... | btnZuAbsage | [Event Procedure]... |
| ✅ OK | Nur Selektierte anfragen | btnMailSelected | ... | btnMailSelected | [Event Procedure]... |
| ✅ OK | Positionsliste | btnPosListe | ... | btnPosListe | [Event Procedure]... |
| ✅ OK | Sortieren | btnSortZugeord | ... | btnSortZugeord | [Event Procedure]... |
| ✅ OK | Sortieren | btnSortZugeord | ... | btnSortPLan | [Event Procedure]... |
| ✅ OK | Standard | cmdListMA_Standard | ... | cmdListMA_Standard | =cmdListMA_Standard_Click()... |
| ✅ OK | Zurück zum Auftrag | btnAuftrag | ... | btnAuftrag | [Event Procedure]... |

### frm_MA_Zeitkonten.html

**Buttons:** 10 | OK: 0 | MISS: 0 | NEW: 10

| Status | Label | HTML ID | HTML Action | Access Name | Access OnClick |
|--------|-------|---------|-------------|-------------|----------------|
| ➕ NEW | &#x26F6; | fullscreenBtn | toggleFullscreen()... |  | ... |
| ➕ NEW | &#x26F6; | fullscreenBtn | ... |  | ... |
| ➕ NEW | Abgleich | btnAbgleich | ... |  | ... |
| ➕ NEW | Export Diff | btnExportDiff | ... |  | ... |
| ➕ NEW | Export Lexware | btnExport | ... |  | ... |
| ➕ NEW | Import Einzel | btnImporteinzel | ... |  | ... |
| ➕ NEW | Import ZK | btnImport | ... |  | ... |
| ➕ NEW | ZK Einzel | btnZKeinzel | ... |  | ... |
| ➕ NEW | ZK Fest | btnZKFest | ... |  | ... |
| ➕ NEW | ZK Mini | btnZKMini | ... |  | ... |

### frm_Menuefuehrung1.html

**Buttons:** 23 | OK: 0 | MISS: 21 | NEW: 2

| Status | Label | HTML ID | HTML Action | Access Name | Access OnClick |
|--------|-------|---------|-------------|-------------|----------------|
| ❌ MISS | Abwesenheiten |  | ... | btn_Abwesenheiten | ... |
| ❌ MISS | Auftrag FA MJ Masterbtn  |  | ... | btn_masterbtn | [Event Procedure]... |
| ❌ MISS | BOS Auftrag anlegen |  | ... | btn_BOS | [Event Procedure]... |
| ❌ MISS | FCN Meldeliste |  | ... | btnFCN_Meldeliste | [Event Procedure]... |
| ❌ MISS | Fürth Namensliste |  | ... | btnNamensliste | [Event Procedure]... |
| ❌ MISS | Hirsch Auftrag erstellen |  | ... | btn_Hirsch | [Event Procedure]... |
| ❌ MISS | Letzter Einsatz MA |  | ... | btnLetzterEinsatz | [Event Procedure]... |
| ❌ MISS | Lex Aktiv |  | ... | Befehl37 | [Event Procedure]... |
| ❌ MISS | Lohnabrechnungen |  | ... | btnLohnabrech | [Event Procedure]... |
| ❌ MISS | Lohnarten |  | ... | btnLohnarten | [Event Procedure]... |
| ❌ MISS | Menü 2 schliessen |  | ... | Befehl40 | [Event Procedure]... |
| ❌ MISS | Menü 2 schliessen |  | ... | btn_menue2_close | ... |
| ❌ MISS | Mitarbeiterstamm Excel |  | ... | btn_MAStamm_Excel | [Event Procedure]... |
| ❌ MISS | Mitarbeiterstatistik |  | ... | Befehl48 | [Event Procedure]... |
| ❌ MISS | Monatsstunden |  | ... | Befehl24 | [Event Procedure]... |
| ❌ MISS | Personalvorlagen |  | ... | Btn_Personalvorlagen | [Event Procedure]... |
| ❌ MISS | Stawa Auftrag anlegen |  | ... | btn_Stawa | [Event Procedure]... |
| ❌ MISS | Stunden Mitarbeiter |  | ... | btnStundenMA | [Event Procedure]... |
| ❌ MISS | Sub Stunden |  | ... | btn_stunden_sub | [Event Procedure]... |
| ❌ MISS | Telefonliste |  | ... | btn_1 | [Event Procedure]... |
| ❌ MISS | Vorlagen |  | ... | Befehl22 | [Event Procedure]... |
| ➕ NEW | Ã¢â€ºÂ¶ | fullscreenBtn | toggleFullscreen()... |  | ... |
| ➕ NEW | Ã¢â€ºÂ¶ | fullscreenBtn | ... |  | ... |

### frm_OB_Objekt.html

**Buttons:** 39 | OK: 0 | MISS: 15 | NEW: 24

| Status | Label | HTML ID | HTML Action | Access Name | Access OnClick |
|--------|-------|---------|-------------|-------------|----------------|
| ❌ MISS | Aktuelle Positionsliste |  | ... | btn_Back_akt_Pos_List | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnRibbonAus | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnRibbonEin | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnDaBaEin | [Event Procedure]... |
| ❌ MISS | Befehl179 |  | ... | btnDaBaAus | [Event Procedure]... |
| ❌ MISS | Drucken |  | ... | Befehl42 | [Eingebettetes Makro]... |
| ❌ MISS | Hilfe |  | ... | btnHilfe | [Eingebettetes Makro]... |
| ❌ MISS | Neue Objektvorlage |  | ... | btnNeuAttach | [Event Procedure]... |
| ❌ MISS | Neues Objekt |  | ... | btnNeuVeranst | ... |
| ❌ MISS | Objektliste drucken |  | ... | btnReport | [Event Procedure]... |
| ❌ MISS | Objektliste löschen |  | ... | mcobtnDelete | [Eingebettetes Makro]... |
| ❌ MISS | btn_Datensatz_vor |  | ... | Befehl40 | [Eingebettetes Makro]... |
| ❌ MISS | btn_Datensatz_zurueck |  | ... | Befehl41 | [Eingebettetes Makro]... |
| ❌ MISS | btn_erster_Datensatz |  | ... | Befehl43 | [Eingebettetes Makro]... |
| ❌ MISS | btn_letzter_Datensatz |  | ... | btn_letzer_Datensatz | [Eingebettetes Makro]... |
| ➕ NEW | &gt; | objekt-btn-naechste | ... |  | ... |
| ➕ NEW | &gt;| | objekt-btn-letzte | ... |  | ... |
| ➕ NEW | &lt; | objekt-btn-vorige | ... |  | ... |
| ➕ NEW | + Neu | objekt-btn-neu | ... |  | ... |
| ➕ NEW | + Neue Position | objekt-btn-neue-position | ... |  | ... |
| ➕ NEW | ? | objekt-btn-hilfe | ... |  | ... |
| ➕ NEW | Aufträge | objekt-tab-auftraege | ... |  | ... |
| ➕ NEW | Bemerkungen | objekt-tab-bemerkungen | ... |  | ... |
| ➕ NEW | Bericht | objekt-btn-bericht | ... |  | ... |
| ➕ NEW | Geocode | objekt-btn-geocode | ... |  | ... |
| ➕ NEW | Löschen | objekt-btn-loeschen | ... |  | ... |
| ➕ NEW | Neuer Veranstalter | objekt-btn-neuer-veranstalter | ... |  | ... |
| ➕ NEW | Position löschen | objekt-btn-position-loeschen | ... |  | ... |
| ➕ NEW | Positionen | objekt-tab-positionen | ... |  | ... |
| ➕ NEW | Speichern | objekt-btn-speichern | ... |  | ... |
| ➕ NEW | X | objekt-btn-schliessen | ... |  | ... |
| ➕ NEW | Zurück zur Liste | btnBackToList | backToAktPosList()... |  | ... |
| ➕ NEW | Zurück zur Liste | objekt-btn-zurueck | ... |  | ... |
| ➕ NEW | Zusatzdateien | objekt-tab-zusatzdateien | ... |  | ... |
| ➕ NEW | [] | objekt-btn-maximieren | ... |  | ... |
| ➕ NEW | _ | objekt-btn-minimieren | ... |  | ... |
| ➕ NEW | |&lt; | objekt-btn-erste | ... |  | ... |
| ➕ NEW | Ã¢â€ºÂ¶ | fullscreenBtn | toggleFullscreen()... |  | ... |
| ➕ NEW | Ã¢â€ºÂ¶ | objekt-btn-vollbild | ... |  | ... |

### frm_va_Auftragstamm.html

**Buttons:** 58 | OK: 0 | MISS: 0 | NEW: 58

| Status | Label | HTML ID | HTML Action | Access Name | Access OnClick |
|--------|-------|---------|-------------|-------------|----------------|
| ➕ NEW | &gt;&gt; | auftrag-btn-tage-vor | ... |  | ... |
| ➕ NEW | &lt;&lt; | auftrag-btn-tage-zurueck | ... |  | ... |
| ➕ NEW | ? | fullscreenBtn | toggleFullscreen()... |  | ... |
| ➕ NEW | ? | auftrag-btn-vollbild | ... |  | ... |
| ➕ NEW | Ab Heute | auftrag-btn-ab-heute | ... |  | ... |
| ➕ NEW | Aktualisieren | btnAktualisieren | refreshData()... |  | ... |
| ➕ NEW | Aktualisieren | auftrag-btn-aktualisieren | ... |  | ... |
| ➕ NEW | Antworten ausstehend | auftrag-tab-antworten | ... |  | ... |
| ➕ NEW | Auftrag kopieren | btnKopieren | auftragKopieren()... |  | ... |
| ➕ NEW | Auftrag kopieren | auftrag-btn-kopieren | ... |  | ... |
| ➕ NEW | Auftrag löschen | btnLoeschen | auftragLoeschen()... |  | ... |
| ➕ NEW | Auftrag löschen | auftrag-btn-loeschen | ... |  | ... |
| ➕ NEW | BWN drucken | btn_BWN_Druck | bwnDrucken()... |  | ... |
| ➕ NEW | BWN drucken | auftrag-btn-bwn-drucken | ... |  | ... |
| ➕ NEW | BWN senden | cmd_BWN_send | bwnSenden()... |  | ... |
| ➕ NEW | BWN senden | auftrag-btn-bwn-senden | ... |  | ... |
| ➕ NEW | Bemerkungen | auftrag-tab-bemerkungen | ... |  | ... |
| ➕ NEW | Berechnungsliste PDF | auftrag-btn-berechnungsliste-pdf | ... |  | ... |
| ➕ NEW | Daten laden | auftrag-btn-rechnung-daten-laden | ... |  | ... |
| ➕ NEW | EL drucken | btnDruckZusage | einsatzlisteDrucken()... |  | ... |
| ➕ NEW | EL drucken | auftrag-btn-einsatzliste-drucken | ... |  | ... |
| ➕ NEW | EL gesendet | btnELGesendet | showELGesendet()... |  | ... |
| ➕ NEW | EL gesendet | auftrag-btn-el-gesendet | ... |  | ... |
| ➕ NEW | EL senden BOS | btnMailBOS | sendeEinsatzlisteBOS()... |  | ... |
| ➕ NEW | EL senden BOS | auftrag-btn-el-senden-bos | ... |  | ... |
| ➕ NEW | EL senden MA | btnMailEins | sendeEinsatzlisteMA()... |  | ... |
| ➕ NEW | EL senden MA | auftrag-btn-el-senden-ma | ... |  | ... |
| ➕ NEW | EL senden SUB | btnMailSub | sendeEinsatzlisteSUB()... |  | ... |
| ➕ NEW | EL senden SUB | auftrag-btn-el-senden-sub | ... |  | ... |
| ➕ NEW | Einsatzliste | auftrag-tab-einsatzliste | ... |  | ... |
| ➕ NEW | Eventdaten | auftrag-tab-eventdaten | ... |  | ... |
| ➕ NEW | Go | auftrag-btn-filter-go | ... |  | ... |
| ➕ NEW | Ja | auftrag-btn-confirm-ja | ... |  | ... |
| ➕ NEW | Mitarbeiterauswahl | btnSchnellPlan | openMitarbeiterauswahl()... |  | ... |
| ➕ NEW | Mitarbeiterauswahl | auftrag-btn-mitarbeiterauswahl | ... |  | ... |
| ➕ NEW | Namensliste ESS | btnListeStd | namenslisteESS()... |  | ... |
| ➕ NEW | Namensliste ESS | auftrag-btn-namenslisteess | ... |  | ... |
| ➕ NEW | Nein | auftrag-btn-confirm-nein | ... |  | ... |
| ➕ NEW | Neuen Attach hinzufugen | auftrag-btn-attach-hinzufuegen | ... |  | ... |
| ➕ NEW | Neuer Auftrag | btnNeuAuftrag | neuerAuftrag()... |  | ... |
| ➕ NEW | Neuer Auftrag | auftrag-btn-neu | ... |  | ... |
| ➕ NEW | Positionen | btnPositionen | openPositionen()... |  | ... |
| ➕ NEW | Positionen | auftrag-btn-positionen | ... |  | ... |
| ➕ NEW | Rechnung | auftrag-tab-rechnung | ... |  | ... |
| ➕ NEW | Rechnung PDF | auftrag-btn-rechnung-pdf | ... |  | ... |
| ➕ NEW | Rechnung in Lexware erstellen | auftrag-btn-rechnung-lexware | ... |  | ... |
| ➕ NEW | Speichern | auftrag-btn-eventdaten-speichern | ... |  | ... |
| ➕ NEW | Web-Daten laden | auftrag-btn-webdaten-laden | ... |  | ... |
| ➕ NEW | Zusatzdateien | auftrag-tab-zusatzdateien | ... |  | ... |
| ➕ NEW | _ | auftrag-btn-minimieren | ... |  | ... |
| ➕ NEW | → Folgetag | btnPlan_Kopie | kopiereInFolgetag()... |  | ... |
| ➕ NEW | → Folgetag | auftrag-btn-folgetag | ... |  | ... |
| ➕ NEW | □ | auftrag-btn-maximieren | ... |  | ... |
| ➕ NEW | ▶ | btnDatumRight | datumNavRight()... |  | ... |
| ➕ NEW | ▶ | auftrag-btn-datum-rechts | ... |  | ... |
| ➕ NEW | ◀ | btnDatumLeft | datumNavLeft()... |  | ... |
| ➕ NEW | ◀ | auftrag-btn-datum-links | ... |  | ... |
| ➕ NEW | ✕ | auftrag-btn-schliessen | ... |  | ... |

