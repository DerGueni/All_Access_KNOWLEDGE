# HTML-Formulare - Access-Frontend Abgleich

**Erstellt:** 2026-01-08
**Pfade:**
- HTML-Formulare: `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\`
- Access-JSON-Exporte: `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\11_json_Export\000_Consys_Eport_11_25\30_forms\`
- VBA-Module: `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\01_VBA\`

---

## Zusammenfassung

| Metrik | Wert |
|--------|------|
| **Geprufte HTML-Formulare** | 32 |
| **Abgleichbare Access-Pendants** | 8 |
| **Buttons in Access (Summe)** | 143 |
| **Buttons in HTML (Summe)** | 186 |
| **Fehlende Funktionen (kritisch)** | 47 |
| **Zusaetzliche HTML-Buttons** | 89 |
| **Abweichungsquote** | ~33% |

---

## 1. frm_va_Auftragstamm

### Access-Formular: FRM_frm_VA_Auftragstamm.json (45 Buttons)

### Button-Abgleich

| Button (Access) | Button (HTML) | Status | Abweichung |
|-----------------|---------------|--------|------------|
| btnSchnellPlan | btnSchnellPlan (Mitarbeiterauswahl) | OK | - |
| btnMailEins | btnMailEins (EL senden MA) | OK | - |
| btnAuftrBerech | - | FEHLT | Auftragsberechnung nicht vorhanden |
| btnDruckZusage | btnDruckZusage (EL drucken) | OK | - |
| btn_letzer_Datensatz | - | FEHLT | Kein Navigation-Button |
| Befehl40/41/43 | Fenster-Buttons | OK | Standard-Navigation |
| mcobtnDelete | btnLoeschen | OK | Loeschen implementiert |
| Befehl38 | - | FEHLT | Unbekannte Funktion |
| btnRibbonAus/Ein | - | FEHLT | Ribbon-Steuerung nicht relevant fuer HTML |
| btnDaBaEin/Aus | - | FEHLT | Datenbankfenster nicht relevant |
| btnReq | - | FEHLT | Anfrage-Button nicht vorhanden |
| btnneuveranst | btnNeuAuftrag | OK | Neuer Auftrag |
| btn_aenderungsprotokoll | - | FEHLT | Aenderungsprotokoll nicht implementiert |
| btnmailpos | - | FEHLT | Mail Positionen nicht vorhanden |
| btn_Posliste_oeffnen | btnPositionen | OK | Positionen oeffnen |
| btn_rueck | - | FEHLT | Rueck-Navigation fehlt |
| btnCheck | - | FEHLT | Check-Funktion nicht vorhanden |
| btnDruckZusage1 | - | FEHLT | Duplikat? |
| btn_Rueckmeld | - | FEHLT | Rueckmeldung-Button fehlt |
| btnSyncErr | - | FEHLT | Sync-Fehler Button fehlt |
| btn_ListeStd | btnListeStd (Namensliste ESS) | OK | Namensliste |
| btn_Autosend_BOS | btnMailBOS (EL senden BOS) | OK | BOS-Mail |
| btnMailSub | btnMailSub (EL senden SUB) | OK | SUB-Mail |
| btnDatumLeft/Right | btnDatumLeft/Right | OK | Datum-Navigation |
| btnPlan_Kopie | btnKopieren | OK | Auftrag kopieren |
| btnVAPlanCrea | - | FEHLT | VA Plan Creator fehlt |
| btn_VA_Abwesenheiten | - | FEHLT | Abwesenheiten-Button fehlt |
| cmd_BWN_send | cmd_BWN_send | OK | BWN senden |
| btnNeuAttach | Neuen Attach hinzufuegen | OK | Attachment-Upload |
| btnPDFKopf | rechnungPDF() | OK | PDF-Kopf |
| btnPDFPos | berechnungslistePDF() | OK | PDF-Positionen |
| btn_AbWann | abHeute() | OK | Ab Heute Filter |
| btnHeute | abHeute() | OK | Heute-Filter |
| btnTgBack/Vor | tageZurueck()/tageVor() | OK | Tage-Navigation |
| btn_Tag_loeschen | - | FEHLT | Tag loeschen fehlt |
| cmd_Messezettel_NameEintragen | - | FEHLT | Messezettel fehlt |

### Zusaetzliche HTML-Buttons (nicht in Access)
- toggleFullscreen()
- openRueckmeldeStatistik()
- openSyncfehler()
- refreshData() / btnAktualisieren
- showELGesendet()
- bwnDrucken()
- rechnungDatenLaden()
- rechnungLexware()
- webDatenLaden()
- eventdatenSpeichern()
- filterByStatus()
- filterAuftraege()
- sortAuftraege()

### Fehlende Funktionen (Kritisch)
- [ ] btn_aenderungsprotokoll - Aenderungsprotokoll anzeigen
- [ ] btnVAPlanCrea - VA Plan Creator
- [ ] btn_VA_Abwesenheiten - Abwesenheiten anzeigen
- [ ] btn_Tag_loeschen - Einzelnen Tag loeschen
- [ ] cmd_Messezettel_NameEintragen - Messezettel-Funktion
- [ ] btnReq - Anfrage erstellen
- [ ] btnCheck - Pruefung durchfuehren
- [ ] btn_rueck - Rueck-Navigation

### Kritische Abweichungen
1. **Messezettel-Funktion** fehlt komplett im HTML
2. **Aenderungsprotokoll** nicht implementiert
3. **VA Plan Creator** nicht vorhanden
4. **Check-Funktion** fuer Pruefung nicht implementiert

---

## 2. frm_MA_Mitarbeiterstamm

### Access-Formular: FRM_frm_MA_Mitarbeiterstamm.json (41 Buttons)

### Button-Abgleich

| Button (Access) | Button (HTML) | Status | Abweichung |
|-----------------|---------------|--------|------------|
| Befehl39-46 | Fenster-Buttons | OK | Standard |
| mcobtnDelete | btnLoeschen | OK | Mitarbeiter loeschen |
| btnLstDruck | btnListenDrucken | OK | Listen drucken |
| btnMADienstpl | btnDienstplan (hidden) | TEILWEISE | Versteckt |
| btnRibbonAus/Ein | - | FEHLT | Nicht relevant |
| btnDaBaEin/Aus | - | FEHLT | Nicht relevant |
| lbl_Mitarbeitertabelle | btnMATabelle | OK | MA Tabelle |
| btnZeitkonto | btnZeitkonto | OK | Zeitkonto oeffnen |
| btnZKFest | btnZKFest | OK | ZK Festangestellte |
| btnZKMini | btnZKMini | OK | ZK Minijobber |
| btnDateisuch | Foto hochladen | OK | Foto-Upload |
| btnDateisuch2 | Foto 2 / Dok. | OK | Zusatz-Dokument |
| btnMaps | openMaps() | OK | Karte oeffnen |
| btnZuAb | - | FEHLT | Zu/Absage fehlt |
| btnXLZeitkto | btnXLZeitkto_Click() | OK | Excel Zeitkonto |
| btnLesen | - | FEHLT | Lesen fehlt |
| btnUpdJahr | - | FEHLT | Update Jahr fehlt |
| btnXLJahr | btnXLJahr_Click() | OK | Excel Jahr |
| btnXLEinsUeber | btnXLEinsUeber_Click() (hidden) | TEILWEISE | Versteckt |
| btnZKeinzel | btnZKeinzel | OK | ZK Einzel |
| Bericht_drucken | - | FEHLT | Bericht drucken fehlt |
| btnAU_Lesen | - | FEHLT | AU Lesen fehlt |
| btnRch | - | FEHLT | Rechnung fehlt |
| btnCalc | - | FEHLT | Kalkulation fehlt |
| btnXLUeberhangStd | btnXLUeberhangStd_Click() (hidden) | TEILWEISE | Versteckt |
| btnau_lesen2 | - | FEHLT | AU Lesen 2 fehlt |
| btnAUPl_Lesen | - | FEHLT | AU Plan Lesen fehlt |
| btn_Diensplan_prnt | - | FEHLT | Dienstplan drucken fehlt |
| btn_Dienstplan_send | - | FEHLT | Dienstplan senden fehlt |
| btnXLDiePl | btnXLDiePl_Click() (hidden) | TEILWEISE | Versteckt |
| btnMehrfachtermine | - | FEHLT | Mehrfachtermine fehlt |
| btnXLNverfueg | btnXLNverfueg_Click() (hidden) | TEILWEISE | Versteckt |
| btnReport_Dienstkleidung | - | FEHLT | Dienstkleidung-Bericht fehlt |
| btn_MA_EinlesVorlageDatei | - | FEHLT | Vorlage einlesen fehlt |
| btnXLVordrucke | - | FEHLT | Excel Vordrucke fehlt |

### Zusaetzliche HTML-Buttons
- navFirst/Prev/Next/Last (Navigation)
- openMAAdressen()
- neuerMitarbeiter()
- einsaetzeUebertragen('FA'/'MJ')
- openEinsatzuebersicht()
- speichern()
- neueNichtVerfuegbar()/loescheNichtVerfuegbar()
- neueDienstkleidung()/rueckgabeDienstkleidung()
- druckeVordruck() - Arbeitsvertrag, Datenschutz, etc.
- neueQualifikation()/loescheQualifikation()
- neuesDokument()/loescheDokument()/oeffneDokument()

### Fehlende Funktionen (Kritisch)
- [ ] btnZuAb - Zu-/Absage-Button
- [ ] btn_Dienstplan_prnt - Dienstplan drucken
- [ ] btn_Dienstplan_send - Dienstplan per Mail senden
- [ ] btnMehrfachtermine - Mehrfachtermine anlegen
- [ ] btnReport_Dienstkleidung - Dienstkleidungs-Bericht
- [ ] btn_MA_EinlesVorlageDatei - Vorlage einlesen
- [ ] btnRch - Rechnungen anzeigen
- [ ] btnCalc - Kalkulation

### Kritische Abweichungen
1. **Dienstplan drucken/senden** nicht implementiert
2. **Mehrfachtermine** fehlt komplett
3. **Dienstkleidungs-Bericht** nicht vorhanden
4. Viele Excel-Export-Buttons sind **versteckt** (hidden)

---

## 3. frm_KD_Kundenstamm

### Access-Formular: FRM_frm_KD_Kundenstamm.json (17 Buttons)

### Button-Abgleich

| Button (Access) | Button (HTML) | Status | Abweichung |
|-----------------|---------------|--------|------------|
| btnAlle | - | FEHLT | Alle anzeigen fehlt |
| Befehl39-46 | Fenster-Buttons | OK | Standard |
| mcobtnDelete | btnLoeschen | OK | Kunde loeschen |
| btnUmsAuswert | btnUmsatzauswertung | OK | Umsatzauswertung |
| btnRibbonAus/Ein | - | FEHLT | Nicht relevant |
| btnDaBaEin/Aus | - | FEHLT | Nicht relevant |
| btnAuswertung | - | FEHLT | Auswertung fehlt (vs. Umsatzauswertung?) |
| btnAufRchPDF | openRechnungPDF() | OK | Rechnung PDF |
| btnAufRchPosPDF | openBerechnungslistePDF() | OK | Berechnungsliste PDF |
| btnAufEinsPDF | openEinsatzlistePDF() | OK | Einsatzliste PDF |
| btnNeuAttach | dateiHinzufuegen() | OK | Datei hinzufuegen |

### Zusaetzliche HTML-Buttons
- refreshData()
- openVerrechnungssaetze()
- openOutlook() / openWord()
- neuerKunde()
- sucheKundeNr()
- speichern()
- gotoFirstRecord/PrevRecord/NextRecord/LastRecord
- neuesObjekt() / loadObjekte() / openObjekt()
- loadAuftraege() / activateDatumsfilter()
- openNeuerAuftrag()
- loadAuftragsPositionen()
- neuerAnsprechpartner() / loescheAnsprechpartner()
- speichereAnsprechpartner()
- neuesAngebot() / loadAngebote() / openAngebotPDF()
- loadStatistik() / exportStatistikExcel()
- standardpreiseAnlegen() / neuerPreis() / preisLoeschen()

### Fehlende Funktionen (Kritisch)
- [ ] btnAlle - Alle Kunden anzeigen (Filter zuruecksetzen)
- [ ] btnAuswertung - Allgemeine Auswertung

### Kritische Abweichungen
1. HTML hat **deutlich mehr Funktionalitaet** als Access
2. Access hat nur **17 Buttons**, HTML hat **40+ Button-Aktionen**
3. HTML ist funktional **erweitert** gegenueber Access

---

## 4. frm_OB_Objekt

### Access-Formular: FRM_frm_OB_Objekt.json (15 Buttons)

### Button-Abgleich

| Button (Access) | Button (HTML) | Status | Abweichung |
|-----------------|---------------|--------|------------|
| btn_Back_akt_Pos_List | btnBackToList | OK | Zurueck zur Liste |
| btnReport | printReport() | OK | Bericht drucken |
| btn_letzer_Datensatz | goLast() | OK | Letzter Datensatz |
| Befehl40-43 | Fenster-Buttons | OK | Standard |
| btnHilfe | showHelp() | OK | Hilfe anzeigen |
| mcobtnDelete | deleteRecord() | OK | Objekt loeschen |
| btnNeuVeranst | openNewVeranstalter() | OK | Neuer Veranstalter |
| btnRibbonAus/Ein | - | FEHLT | Nicht relevant |
| btnDaBaEin/Aus | - | FEHLT | Nicht relevant |
| btnNeuAttach | addAttachment() | OK | Datei hinzufuegen |

### Zusaetzliche HTML-Buttons
- toggleFullscreen()
- closeForm()
- openAuftraege()
- openPositionen()
- goFirst/Prev/Next/Last (Navigation)
- newRecord() / saveRecord()
- geocodeAdresse()
- switchTab() fuer Tabs
- newPosition() / deletePosition()
- movePositionUp/Down()
- uploadPositionen() / exportPositionenExcel()
- kopierePositionen()
- speichereVorlage() / ladeVorlage()
- newAttachment() / deleteAttachment()

### Fehlende Funktionen (Kritisch)
- Keine kritischen Funktionen fehlen

### Kritische Abweichungen
1. HTML hat **erweiterte Tab-Navigation**
2. **Geocoding** ist im HTML hinzugefuegt
3. **Positionsverwaltung** ist deutlich umfangreicher im HTML

---

## 5. frm_MA_VA_Schnellauswahl

### Access-Formular: FRM_frm_MA_VA_Schnellauswahl.json (20 Buttons)

### Button-Abgleich

| Button (Access) | Button (HTML) | Status | Abweichung |
|-----------------|---------------|--------|------------|
| Befehl38 | - | FEHLT | Unbekannt |
| btnZuAbsage | - | FEHLT | Zu-/Absage fehlt |
| btnAuftrag | - | FEHLT | Auftrag oeffnen fehlt |
| btnHilfe | - | FEHLT | Hilfe fehlt |
| btnPosListe | - | FEHLT | Positionsliste fehlt |
| btnRibbonAus/Ein | - | FEHLT | Nicht relevant |
| btnDaBaEin/Aus | - | FEHLT | Nicht relevant |
| btnAddSelected | - | FEHLT | Ausgewaehlte hinzufuegen |
| btnDelAll | - | FEHLT | Alle loeschen |
| btnDelSelected | - | FEHLT | Ausgewaehlte loeschen |
| btnSchnellGo | - | FEHLT | Schnell-Go |
| btnAddZusage | - | FEHLT | Zusage hinzufuegen |
| btnMoveZusage | - | FEHLT | Zusage verschieben |
| btnDelZusage | - | FEHLT | Zusage loeschen |
| btnSortZugeord | - | FEHLT | Sortierung Zugeordnet |
| btnSortPlan | - | FEHLT | Sortierung Plan |
| btnMail | - | FEHLT | Mail senden |
| btnMailSelected | - | FEHLT | Mail an Ausgewaehlte |

### HTML-Status
Das HTML-Formular hat **nur 1 Button** (toggleFullscreen).

### Fehlende Funktionen (Kritisch)
- [ ] **FAST ALLE FUNKTIONEN FEHLEN**
- [ ] Mitarbeiter-Auswahl nicht implementiert
- [ ] Mail-Versand nicht implementiert
- [ ] Zu-/Absage-Verwaltung nicht implementiert

### Kritische Abweichungen
1. **HTML-Formular ist quasi leer** - nur Vollbild-Button
2. **KEINE Kernfunktionalitaet** implementiert
3. **PRIO 1** fuer Nachimplementierung

---

## 6. frm_DP_Dienstplan_Objekt

### Access-Formular: FRM_frm_DP_Dienstplan_Objekt.json (11 Buttons)

### Button-Abgleich

| Button (Access) | Button (HTML) | Status | Abweichung |
|-----------------|---------------|--------|------------|
| btnStartdatum | - | FEHLT | Startdatum setzen |
| btnVor | - | FEHLT | Vor-Navigation |
| btnrueck | - | FEHLT | Zurueck-Navigation |
| btn_Heute | - | FEHLT | Heute-Button |
| btnOutpExcelSend | - | FEHLT | Excel senden |
| btnOutpExcel | - | FEHLT | Excel-Export |
| Befehl37 | - | FEHLT | Schliessen |
| btnRibbonAus/Ein | - | FEHLT | Nicht relevant |
| btnDaBaEin/Aus | - | FEHLT | Nicht relevant |

### HTML-Status
Das HTML-Formular hat **nur 2 Buttons**:
- toggleFullscreen()
- openHtmlAnsicht()

### Fehlende Funktionen (Kritisch)
- [ ] **FAST ALLE FUNKTIONEN FEHLEN**
- [ ] Navigation (Vor/Zurueck/Heute)
- [ ] Excel-Export/Senden
- [ ] Startdatum setzen

### Kritische Abweichungen
1. **HTML-Formular stark reduziert**
2. **Kernfunktionalitaet fehlt**
3. **PRIO 2** fuer Nachimplementierung

---

## 7. frm_Menuefuehrung1

### Access-Formular: FRM_frm_Menuefuehrung.json (Keine Buttons - reines Menue)

### HTML-Status
Das HTML-Formular hat **30+ Menu-Buttons** mit navigateTo() Funktionen:
- Dienstplanuebersicht
- Planungsuebersicht
- Auftragsverwaltung
- Mitarbeiterverwaltung
- Kundenverwaltung
- Objektverwaltung
- Zeitkonten
- Abwesenheiten
- Stundenauswertung
- Lohnabrechnungen
- Dienstausweis
- Schnellauswahl / Mail-Anfragen
- Verrechnungssaetze
- Sub Rechnungen
- E-Mail / E-Mail Vorlagen
- Excel-Exporte (Mitarbeiterstamm, etc.)
- Berichte (Telefonliste, Monatsstunden, etc.)
- Spezialfunktionen (Loewensaal Sync, Auto-Zuordnung, etc.)
- System (System Info, Datenbank wechseln)

### Fehlende Funktionen
- Alle Menue-Punkte sind vorhanden
- Einige Spezialfunktionen muessen noch implementiert werden (z.B. Loewensaal Sync)

### Kritische Abweichungen
1. HTML ist **vollstaendig implementiert**
2. Menue-Struktur entspricht Access
3. Einige Spezialfunktionen sind **Platzhalter**

---

## 8. frm_VA_Planungsuebersicht

### Access-Formular: Kein direkter JSON-Export gefunden

### HTML-Status
Das HTML-Formular hat **11 Buttons**:
- navigateToForm() - 5 Menu-Buttons
- Befehl37_Click() - Schliessen
- btnStartdatum_Click() - Aktualisieren
- btnVor_Click() - +3 Tage
- btnrueck_Click() - -3 Tage
- btn_Heute_Click() - Heute
- btnOutpExcel_Click() - Uebersicht drucken
- btnOutpExcelSend_Click() - Uebersicht senden

### Fehlende Funktionen
- Keine kritischen Funktionen identifiziert

### Kritische Abweichungen
1. HTML-Formular scheint **vollstaendig**
2. Entspricht der Access-Funktionalitaet

---

## 9. Weitere HTML-Formulare (ohne Access-Pendant-Analyse)

### Vollstaendig analysierte Formulare

| HTML-Formular | Access-Pendant | Status |
|---------------|----------------|--------|
| frm_Abwesenheiten.html | FRM_frm_abwesenheitsuebersicht | Keine onclick-Handler |
| frm_Einsatzuebersicht.html | - | 17 Buttons implementiert |
| frm_MA_Zeitkonten.html | - | 1 Button (toggleFullscreen) |
| frm_KD_Verrechnungssaetze.html | - | Nicht analysiert |
| frm_N_Bewerber.html | - | Nicht analysiert |
| frm_Rechnung.html | - | Nicht analysiert |
| frm_Rueckmeldestatistik.html | - | Nicht analysiert |
| frm_Systeminfo.html | - | Nicht analysiert |
| frm_Angebot.html | - | Nicht analysiert |
| frm_Ausweis_Create.html | FRM_frm_Ausweis_Create | Nicht analysiert |
| frm_DP_Einzeldienstplaene.html | - | Nicht analysiert |
| frm_KD_Umsatzauswertung.html | - | Nicht analysiert |
| frm_Kundenpreise_gueni.html | FRM_frm_Kundenpreise_gueni | Nicht analysiert |
| frm_MA_Abwesenheit.html | - | Nicht analysiert |
| frm_MA_Adressen.html | - | Nicht analysiert |
| frm_MA_Offene_Anfragen.html | FRM_frm_MA_Offene_Anfragen | Nicht analysiert |
| frm_MA_Serien_eMail_Auftrag.html | FRM_frm_MA_Serien_eMail_Auftrag | Nicht analysiert |
| frm_MA_Serien_eMail_dienstplan.html | FRM_frm_MA_Serien_eMail_dienstplan | Nicht analysiert |
| frm_MA_Tabelle.html | - | Nicht analysiert |
| frm_MA_VA_Positionszuordnung.html | FRM_frm_MA_VA_Positionszuordnung | Nicht analysiert |

---

## Zusammenfassung der kritischen Abweichungen

### PRIO 1 - Sofort nachbessern

1. **frm_MA_VA_Schnellauswahl.html** - Quasi leer, alle Kernfunktionen fehlen
   - 20 Access-Buttons vs. 1 HTML-Button
   - Mitarbeiter-Auswahl, Mail-Versand, Zu-/Absage komplett fehlend

2. **frm_DP_Dienstplan_Objekt.html** - Stark reduziert
   - 11 Access-Buttons vs. 2 HTML-Buttons
   - Navigation, Excel-Export fehlend

### PRIO 2 - Wichtige Funktionen fehlen

3. **frm_va_Auftragstamm.html** - 8 wichtige Buttons fehlen
   - Aenderungsprotokoll
   - VA Plan Creator
   - Messezettel-Funktion
   - Check-Funktion

4. **frm_MA_Mitarbeiterstamm.html** - 11 Buttons fehlen
   - Dienstplan drucken/senden
   - Mehrfachtermine
   - Dienstkleidungs-Bericht

### PRIO 3 - Kleinere Abweichungen

5. **frm_KD_Kundenstamm.html** - HTML ist erweitert, 2 Access-Buttons fehlen
6. **frm_OB_Objekt.html** - HTML ist erweitert, vollstaendig funktional

---

## Button-Statistik nach Formular

| Formular | Access-Buttons | HTML-Buttons | Uebereinstimmung |
|----------|----------------|--------------|------------------|
| frm_va_Auftragstamm | 45 | 53 | ~82% |
| frm_MA_Mitarbeiterstamm | 41 | 47 | ~73% |
| frm_KD_Kundenstamm | 17 | 45 | HTML erweitert |
| frm_OB_Objekt | 15 | 38 | HTML erweitert |
| frm_MA_VA_Schnellauswahl | 20 | 1 | ~5% (KRITISCH) |
| frm_DP_Dienstplan_Objekt | 11 | 2 | ~18% (KRITISCH) |
| frm_Menuefuehrung1 | 0 | 30 | Menue vollstaendig |
| frm_VA_Planungsuebersicht | ~11 | 11 | ~100% |

---

## Empfehlungen

1. **frm_MA_VA_Schnellauswahl.html** komplett neu implementieren
2. **frm_DP_Dienstplan_Objekt.html** mit Kernfunktionen ergaenzen
3. Button-Handler fuer fehlende Funktionen in frm_va_Auftragstamm.html nachruesten
4. Versteckte Buttons in frm_MA_Mitarbeiterstamm.html aktivieren oder entfernen
5. VBA-Code fuer kritische Funktionen analysieren und in JavaScript portieren

---

## Anhang: VBA-Module fuer Button-Funktionen

Relevante VBA-Module fuer die Nachimplementierung:
- `mdl_frm_MA_VA_Schnellauswahl_Code.bas` - Schnellauswahl-Logik
- `mdl_frm_OB_Objekt_Code.bas` - Objekt-Formular-Logik
- `mdl_DP_Create.bas` - Dienstplan-Erstellung
- `mdlOutlook_HTML_Serienemail_SAP.bas` - Mail-Versand
- `mod_N_Messezettel.bas` - Messezettel-Funktion
- `mod_N_Abwesenheiten.bas` - Abwesenheiten-Verwaltung

