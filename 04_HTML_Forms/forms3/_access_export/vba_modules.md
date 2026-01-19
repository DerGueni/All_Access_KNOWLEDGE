# VBA MODULE INVENTAR - Access Frontend Export

Exportiert am: 2026-01-08
Quelle: 0_Consys_FE_Test.accdb
Gesamtanzahl Module: ~216

---

## KERN-MODULE (Systemfunktionen)

### mdlAutoexec
- **Funktion:** Autostart beim Oeffnen der Datenbank
- **Wichtige Funktionen:**
  - `fAutoexec()` - Hauptautostart
  - `ftestdbnamen()` - Prueft FE/BE-Versionsnamen
  - `fVAUpd_AllSI()` - Aktualisiert Soll/Ist-Status
- **Ablauf:**
  1. Backend-Verknuepfung pruefen (checkconnectAcc)
  2. Default-Bundesland-Abfrage erstellen
  3. Login pruefen
  4. Excel-Vorlagen schreiben
  5. Hauptformular oeffnen (frm_va_auftragstamm)

### zmd_Funktionen
- **Funktion:** Allgemeine Hilfsfunktionen
- **Wichtige Funktionen:**
  - `ScreenResolution()` - Bildschirmaufloesung ermitteln
  - `Testumgebung_umschalten()` - Wechsel Prod/Test
  - `FE_verteilen()` - Frontend an alle User verteilen
- **API-Deklarationen:** GetDeviceCaps, GetDC, ReleaseDC

### zmd_Const
- **Funktion:** Globale Konstanten und Pfade
- **Wichtige Konstanten:**
  - Server-Pfade
  - Backend-Pfade
  - Tabellennamen

### mdl_CONSEC_Global
- **Funktion:** Globale CONSEC-Funktionen
- **Wichtige Funktionen:**
  - Backend-Verbindungen
  - Globale Variablen

---

## E-MAIL MODULE

### zmd_Mail
- **Funktion:** E-Mail-Versand und Anfragen-Management
- **Wichtige Funktionen:**
  - `Anfragen(MA_ID, VA_ID, VADatum_ID, VAStart_ID)` - MA fuer VA anfragen
  - `setze_Angefragt()` - Status auf "angefragt" setzen
  - `setInfo()` - IstFraglich-Flag setzen
  - `create_Mail()` - E-Mail erstellen
  - `create_PHP()` - PHP-Datei fuer automatische Antwort
- **Status-Codes:**
  - 1 = Geplant
  - 2 = Benachrichtigt/Angefragt
  - 3 = Zusage
  - 4 = Absage

### mdl_CONSEC_eMail_Autoimport
- **Funktion:** Automatischer E-Mail-Import und Verarbeitung
- **Wichtige Funktionen:**
  - `All_eMail_Update()` - Hauptfunktion E-Mail-Verarbeitung
  - `Manuelle_eMail_MA_Zuordnung()` - Manuelle Zuordnung
  - `All_eMail_tbl_MA_VA_Zuordnung_Merge()` - Zuordnungen zusammenfuehren
  - `eMail_Ausles()` - E-Mail-Betreff parsen
- **Workflow:**
  1. Eintraege ohne "Intern:" als Schrott markieren
  2. CONSEC-eigene ignorieren
  3. Alte loeschen
  4. Zu-/Absagen erkennen
  5. MA_ID, VA_ID etc. zuordnen
  6. tbl_MA_VA_Planung updaten
  7. tbl_MA_VA_Zuordnung aktualisieren

### mdlOutlook_HTML_Serienemail_SAP
- **Funktion:** HTML-Serien-E-Mails via Outlook
- **Wichtige Funktionen:**
  - `xSendMessage()` - HTML-E-Mail senden
  - `xTestsend1/2/3()` - Testfunktionen
- **Features:**
  - HTML-Body mit CSS-Styling
  - Attachments als Array
  - Voting-Optionen
  - CC/BCC Unterstuetzung

### mdlOutlookSendMail
- **Funktion:** Standard Outlook-E-Mail-Versand

### mdlOutlookHTMLSendMitBild
- **Funktion:** HTML-E-Mail mit eingebetteten Bildern

---

## MENU-/NAVIGATIONS-MODULE

### mdl_Menu_Neu
- **Funktion:** Menu-Funktionen fuer Navigation
- **Wichtige Funktionen:**
  - `F1_Tag/Woche/Monat()` - Uebersicht oeffnen
  - `F1_Dienstplan_Obj/MA()` - Dienstplaene oeffnen
  - `F2_NeuAuf()` - Neuen Auftrag anlegen
  - `F2_Schnellplan()` - Schnellplanung
  - `F2_Auftragsverwaltung()` - Auftragsverwaltung
  - `F2_frm_Objekt()` - Objektverwaltung
  - `F3_Mitarbeiter()` - Mitarbeiterstamm
  - `F3_MA_Dienstplan/Dienstkleidung/Einsatzuebersicht()` - MA-Tabs
  - `F5_Kundennstammdaten()` - Kundenstamm
  - `F6_Rch_erstellen()` - Rechnung erstellen
  - `F6_Ang_erstellen()` - Angebot erstellen
  - `F7_Firmenstammdaten()` - Eigene Firma
  - `F9_...()` - Hilfsformulare

### mdlNavigationsschaltflaechen
- **Funktion:** Navigationsbuttons in Formularen
- **Wichtige Funktionen:**
  - Navigation zwischen Datensaetzen
  - Formular-Navigation

---

## PLANUNGS-MODULE

### mdl_frm_MA_VA_Schnellauswahl_Code
- **Funktion:** Code fuer Schnellauswahl-Formular
- **Wichtige Funktionen:**
  - `cmdListMA_Standard_Click()` - Standard-MA-Liste
  - `cmdListMA_Entfernung_Click()` - MA nach Entfernung sortiert

### mdl_DP_Create
- **Funktion:** Dienstplan erstellen
- **Wichtige Funktionen:**
  - Dienstplan-Generierung
  - Kreuztabellen-Erstellung

### mdl_frm_OB_Objekt_Code
- **Funktion:** Code fuer Objekt-Formular

---

## RECHNUNGS-MODULE

### mdl_Rechnungsschreibung
- **Funktion:** Rechnungserstellung
- **Wichtige Funktionen:**
  - `fPDF_Datei()` - PDF-Dateipfad ermitteln
  - `fPDF_Pos_Datei()` - PDF-Positionslistenpfad
  - `fMahnDat()` - Mahndatum berechnen
  - `Zahlbed_Zahlbar_Bis()` - Zahlungsziel berechnen
  - `Zahlbed_Zahlbar_BetragNetto()` - Nettobetrag mit Skonto
  - `Zahlbed_Text()` - Zahlungsbedingungstext generieren
  - `Update_Rch_Nr()` - Rechnungsnummer hochzaehlen

---

## EXCEL/IMPORT/EXPORT MODULE

### mdl_CONSEC_Excel
- **Funktion:** Excel-Integration
- **Wichtige Funktionen:**
  - Excel-Export
  - Excel-Import

### mdl_Excel_Export
- **Funktion:** Excel-Export-Funktionen

### mdlExcelExportMAEinzel
- **Funktion:** Einzelner MA-Export nach Excel

### mdl_Exl_Import1/2
- **Funktion:** Excel-Import-Funktionen

### mdl_N_PositionslistenImport/Export
- **Funktion:** Positionslisten importieren/exportieren

### mdl_ObjektlistenImport
- **Funktion:** Objektlisten importieren

### mod_ExportConsys
- **Funktion:** Allgemeiner CONSYS-Export

### mod_ExportForms/Queries/Tables/Reports/Modules
- **Funktion:** Export einzelner Objekttypen

---

## GEO-/DISTANZ-MODULE

### mdl_Geocoding / mdl_Geocoding1/2
- **Funktion:** Adress-Geocodierung
- **Wichtige Funktionen:**
  - Koordinaten aus Adressen ermitteln
  - Google Maps API

### mdl_AutoGeocode / mdl_AutoGeocode1/2/3
- **Funktion:** Automatische Geocodierung

### mdl_BatchGeocode
- **Funktion:** Batch-Geocodierung mehrerer Adressen

### mdl_GeoDistanz / mdl_GeoDistanz1
- **Funktion:** Distanzberechnung
- **Wichtige Funktionen:**
  - Entfernung zwischen zwei Punkten
  - Haversine-Formel

### mdl_Distanzberechnung
- **Funktion:** Distanzberechnungen

### mdl_GeoFormFunctions
- **Funktion:** Geo-Funktionen fuer Formulare

### mdl_GeoAdmin
- **Funktion:** Geo-Administration

### mdl_GeoDistanz_Setup
- **Funktion:** Setup fuer Distanzberechnung

---

## WORD/DOKUMENT-MODULE

### mdl_Word_Bookmark
- **Funktion:** Word-Textmarken-Verarbeitung

### mdl_N_MA_WordTemplates
- **Funktion:** Word-Vorlagen fuer MA

### mdl_Textbaustein
- **Funktion:** Textbaustein-Verwaltung

---

## REPORTING-MODULE

### mdl_CreateReport
- **Funktion:** Berichte erstellen

### mdl_ReportBuilder / mdl_ReportHelper
- **Funktion:** Report-Hilfsfunktionen

### mod_N_rpt_PosListe
- **Funktion:** Positionslisten-Report

---

## HILFSFUNKTIONEN-MODULE

### mdlSonstiges1/2/3/4/5
- **Funktion:** Diverse Hilfsfunktionen
- **Inhalte:**
  - String-Funktionen
  - Datums-Funktionen
  - Datei-Funktionen
  - Konvertierungen

### mdlSonstigesJaNein
- **Funktion:** Ja/Nein-Konvertierungen

### mdlSonstigesRunden
- **Funktion:** Rundungsfunktionen

### mdlSonstigesDatumUhrzeit
- **Funktion:** Datum/Uhrzeit-Funktionen

### mdlClipboard
- **Funktion:** Clipboard-Operationen

### mdlUnitConversion
- **Funktion:** Einheitenumrechnung

### mdlWaehrungsumrechnung
- **Funktion:** Waehrungsumrechnung

---

## SYSTEM-MODULE

### mdl_CONSEC_AutoUpdater
- **Funktion:** Automatische Updates

### mdl_Maintainance
- **Funktion:** Wartungsfunktionen

### mdl_Ribbon_DaBaFenster_EinAus
- **Funktion:** Ribbon/Datenbankfenster ein-/ausblenden

### mdlFensterposition
- **Funktion:** Fensterposition speichern/laden

### mdlPrivProperty
- **Funktion:** Private Properties verwalten

### mdlVerbindenACCESS / mdlVerbindeSQL
- **Funktion:** Backend-Verbindungen

### mdl_Diagnose / mdl_DiagnoseMonats
- **Funktion:** Diagnosefunktionen

### mdlsysinfo
- **Funktion:** Systeminformationen

### mdlRegistryRead / zmd_Registry
- **Funktion:** Registry-Operationen

---

## ZEITKONTEN-MODULE

### zmd_Zeitkonten
- **Funktion:** Zeitkonten-Verwaltung
- **Wichtige Funktionen:**
  - Zeitkonten berechnen
  - Ueberstunden verwalten

### mdl_Setup_Monatsuebersicht
- **Funktion:** Monatsuebersicht einrichten

### mdl_N_ZeitHeader
- **Funktion:** Zeit-Header-Funktionen

---

## SONDER-MODULE

### zmd_archivieren
- **Funktion:** Daten archivieren

### zmd_AuftragKopieren
- **Funktion:** Auftraege kopieren

### zmd_Barcode / zmd_QRCode
- **Funktion:** Barcode/QR-Code-Generierung

### zmd_MD5
- **Funktion:** MD5-Hash-Berechnung (fuer E-Mail-Tracking)

### zmd_Whatsapp
- **Funktion:** WhatsApp-Integration

### zmd_Sync
- **Funktion:** Synchronisationsfunktionen

### zmd_Zuschlagskalkulation
- **Funktion:** Zuschlagskalkulation

### zmd_Listen
- **Funktion:** Listen-Funktionen

### zmd_Ersatzfunktionen
- **Funktion:** Ersatz fuer fehlende Funktionen

---

## AI/AUTOMATISIERUNGS-MODULE

### modAIHelpers / modAIEngine
- **Funktion:** AI-Hilfsfunktionen

### mdl_AI_KnowledgeLoader / mdl_AIRunner
- **Funktion:** AI-Integration

### mod_WorkflowDetector / mod_WorkflowDetector1
- **Funktion:** Workflow-Erkennung

---

## FORMULAR-HILFS-MODULE

### mdl_FormHelper
- **Funktion:** Formular-Hilfsfunktionen

### mdl_FormularErsteller
- **Funktion:** Formulare erstellen

### mdl_N_FormBuilder
- **Funktion:** Formular-Builder

### mdl_FixFormular / mdl_Fix_Final
- **Funktion:** Formular-Reparaturen

### mdl_Prepare_Hauptformular
- **Funktion:** Hauptformular vorbereiten

### mdl_Restore_Subforms
- **Funktion:** Subformulare wiederherstellen

---

## ABFRAGEN-MODULE

### mdl_Query_Creator
- **Funktion:** Abfragen erstellen

### mdl_QueryHelper
- **Funktion:** Abfragen-Hilfsfunktionen

### mdlRecreateDeleteQuery
- **Funktion:** Abfragen neu erstellen/loeschen

---

## MA/ABWESENHEITS-MODULE

### mod_N_Abwesenheiten
- **Funktion:** Abwesenheiten verwalten

### mdl_N_MA_Import
- **Funktion:** MA-Daten importieren

### mdl_N_MA_Verarbeitung
- **Funktion:** MA-Datenverarbeitung

### mdl_CreateMAOverviewFull
- **Funktion:** MA-Komplettuebersicht erstellen

---

## UNIVERSAL/FILTER-MODULE

### mdl_Universal_Filter
- **Funktion:** Universal-Filterung

### mdl_N_ObjektFilter
- **Funktion:** Objekt-Filter

### mod_Auswahl
- **Funktion:** Auswahl-Funktionen

---

## PROTOKOLL-MODULE

### modProtokoll / mdl_modProtokoll
- **Funktion:** Protokollierung
- **Wichtige Funktionen:**
  - Aenderungsprotokoll
  - Fehlerprotokoll

### zmd_Global_ErrorHandler
- **Funktion:** Globale Fehlerbehandlung

---

## MODUL-KATEGORIEN STATISTIK

| Kategorie | Anzahl |
|-----------|--------|
| Kern-/System | ~15 |
| E-Mail | ~8 |
| Menu/Navigation | ~5 |
| Planung | ~5 |
| Rechnung | ~3 |
| Excel/Import/Export | ~15 |
| Geo/Distanz | ~12 |
| Word/Dokument | ~4 |
| Reporting | ~5 |
| Hilfsfunktionen | ~20 |
| Zeitkonten | ~5 |
| AI/Automatisierung | ~6 |
| Formular-Hilfs | ~10 |
| Sonstige/Test | ~100+ |

---

## WICHTIGE FUNKTIONSKETTEN

### E-Mail-Anfrage-Workflow:
1. `Anfragen()` (zmd_Mail) - Startet Anfrage
2. `create_Mail()` - Erstellt E-Mail
3. `setze_Angefragt()` - Setzt Status
4. `create_PHP()` - Erstellt Antwort-PHP
5. `All_eMail_Update()` (mdl_CONSEC_eMail_Autoimport) - Verarbeitet Antworten
6. `All_eMail_tbl_MA_VA_Zuordnung_Merge()` - Aktualisiert Zuordnungen

### Autostart-Workflow:
1. `fAutoexec()` (mdlAutoexec)
2. `checkconnectAcc` - Backend pruefen
3. `CreateQuery` - Abfragen erstellen
4. `Set_Priv_Property` - Properties setzen
5. `fExcel_Vorlagen_Schreiben` - Vorlagen
6. `DoCmd.OpenForm "frm_va_auftragstamm"` - Hauptformular

### Rechnungserstellung:
1. `F6_Rch_erstellen()` (mdl_Menu_Neu)
2. Oeffnet frmTop_Rch_Berechnungsliste
3. `Zahlbed_Text()` - Zahlungsbedingung
4. `Update_Rch_Nr()` - Nummer hochzaehlen
5. Word-Dokument via Textmarken
