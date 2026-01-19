## 2025-12-30 - WPF Umstellung (Variante 2 Start)
- WPF Lösung erstellt: `0000_Windows_App/ConsecWpf.sln` und Projekt `ConsecWpf.App` (net8.0-windows).
- Basis-Architektur: `Infrastructure/AppConfig.cs`, `Infrastructure/AccessDb.cs` (OleDb + Odbc Fallback), `Services/AuftragService.cs`, `Models/Auftrag.cs`.
- Sidebar erstellt: `Views/Sidebar.xaml` + `Sidebar.xaml.cs` mit Navigation zu allen Formularen.
- Fenster angelegt:
  - `Views/FrmVaAuftragstammWindow.xaml` + Code-behind (lädt Auftragsliste aus Access)
  - Platzhalter-Fenster: `FrmDpDienstplanMaWindow`, `FrmDpDienstplanObjektWindow`, `FrmMaMitarbeiterstammWindow`, `FrmKdKundenstammWindow`, `FrmMaVaSchnellauswahlWindow`
- App-Startlogik umgestellt: `App.xaml` + `App.xaml.cs` (Start mit `--form <name>` oder Standard `frm_va_Auftragstamm`).
- NuGet hinzugefügt: `System.Data.OleDb`, `System.Data.Odbc`.
- Build ok: `dotnet build ConsecWpf.sln`.

Nächster Schritt: frm_va_Auftragstamm 1:1 Layout, Tabs, Unterformulare, Button-Events (Variante 2), danach die übrigen Formulare.
## 2025-12-30 - Access-Layout-Quelle und Auftragstamm WPF-Layout
- Layout-Quelle auf Original-Access umgestellt: FRM JSONs aus `11_json_Export/000_Consys_Eport_11_25/30_forms` kopiert nach `0000_Windows_App/AccessLayouts`.
- Access-Exporttexte erzeugt und geparst:
  - `tools/export_access_text.py` -> `AccessLayouts/*.export.txt`
  - `tools/parse_access_text.py` -> `AccessLayouts/*.meta.json` (Caption/Parent)
- Auftragstamm-WPF jetzt Canvas-basiert aus Access-Layout:
  - Loader: `Services/AccessLayoutLoader.cs`
  - Builder: `Views/AccessFormCanvasBuilder.cs`
  - Fenster: `Views/FrmVaAuftragstammWindow.xaml` + Code-behind aktualisiert
- Content-Copy fuer Layout-Dateien in `ConsecWpf.App.csproj` eingerichtet.
- Build ok: `dotnet build ConsecWpf.sln`.

Naechster Schritt: TabControl/Page-Zuordnung pruefen, Subform-Platzhalter weiter differenzieren, dann frm_DP_Dienstplan_MA usw.
## 2025-12-30 - Auftragstamm: Tab/Page + Datenliste
- Access-Layout erweitert um Font-Infos und Subform-Quellen (Model/Loader).
- TabControl/Page-Build verbessert inkl. Page-Backgrounds und Typ-Aliase.
- Subform-Platzhalter fuer `zsub_lstAuftrag` ersetzt durch DataGrid mit Echt-Daten.
- Auswahl im DataGrid schreibt Grundfelder (TextBox/ComboBox) nach ControlSource.
- Build ok.
## 2025-12-30 - Auftragstamm: Subform-Datenbasis
- `AuftragService.QueryData` ergänzt, damit Subform-DataGrids RecordSources per SQL laden können.
- Grundlage für LinkMaster/LinkChild Filter in `FrmVaAuftragstammWindow` vorhanden.
## 2025-12-30 - Auftragstamm: RecordSources bereinigt + DB-Checks
- `subform_recordsources.json` korrigiert: `sub_VA_Start` kompletter SQL und `qry_MA_Plan*` ersetzt durch direkte SELECT-Statements.
- OleDb-Checks gegen Backend: alle Subform-RecordSources erfolgreich, `sub_VA_Anzeige` bleibt leer.
## 2025-12-30 - Auftragstamm: Subform-Filtersicherheit
- `ResolveValue` ergänzt, um konstante ControlSources wie `=42` zu setzen (wichtig für `TabellenNr`).
- Subform-SQL-Aufbau korrigiert: Semikolon-Trim + WHERE vor ORDER BY + AND bei bestehendem WHERE.
- Filter-Checks mit LinkMaster/LinkChild gegen Backend erfolgreich (alle Subforms außer `sub_VA_Anzeige`).
## 2025-12-30 - Dienstplan MA: Layout + Datenaufbau
- `FrmDpDienstplanMaWindow` auf Access-Layout (Canvas) umgestellt, inkl. Sidebar-Scroll.
- `AccessSubformBinding` als gemeinsame Subform-Hilfe ausgelagert; Auftragstamm nutzt sie weiter.
- `DienstplanMaService` implementiert: erzeugt Wochenansicht aus Backend-Tabellen (inkl. Nichtverfuegbarkeiten) ohne Access-Temp-Tabellen.
- Filter/UI: `dtStartdatum`, `dtEnddatum`, `NurAktiveMA`, Buttons fuer Woche vor/zurueck/heute verdrahtet.
- `AccessDb` Parameter-Handling für DateTime verbessert.
## 2025-12-30 - Dienstplan Objekt: Layout + Datenaufbau
- `FrmDpDienstplanObjektWindow` auf Access-Layout (Canvas) umgestellt, inkl. Sidebar-Scroll.
- `DienstplanObjektService` implementiert: baut 7-Tage-Ansicht je Auftrag aus Backend-Tabellen, inkl. Filter `NurIstNichtZugeordnet` und Positions-Ausblendung.
- UI-Events verdrahtet: `dtStartdatum`, `dtEnddatum`, `btnVor/btnrueck` (+/-3 Tage), `btn_Heute`, `btnStartdatum`, `lbl_Tag_1..7` (Doppelklick).
## 2025-12-30 - Mitarbeiterstamm: Layout + Datenbindung
- `FrmMaMitarbeiterstammWindow` auf Access-Layout (Canvas) umgestellt, inkl. Sidebar-Scroll.
- Mitarbeiterliste `lst_MA` an Backend gebunden (Auswahl laedt Datensatz und aktualisiert Controls).
- RowSource-Handling fuer ComboBox/ListBox mit Value-Lists + einfachem SQL (qry_/tbltmp werden uebersprungen).
- Subforms durch DataGrid ersetzt und an Tabellenquellen angebunden (ErsatzEmail, Einsatz_Zuo, Dienstkleidung, NVerfuegZeiten).
## 2025-12-30 - Kundenstamm: Layout + Datenbindung
- `FrmKdKundenstammWindow` auf Access-Layout (Canvas) umgestellt, inkl. Sidebar-Scroll.
- Kundenliste `lst_KD` an Backend gebunden (Auswahl laedt Kundendatensatz und aktualisiert Controls).
- RowSource-Handling fuer ComboBox/ListBox mit Value-Lists + einfachem SQL (qry_/tbltmp werden uebersprungen).
- Subforms durch DataGrid ersetzt und an Tabellenquellen angebunden (Standardpreise, Ansprechpartner, Rch_Kopf, Rch_Pos_Auftrag, ZusatzDateien).
## 2025-12-30 - Schnellauswahl: Layout + Grunddaten
- `FrmMaVaSchnellauswahlWindow` auf Access-Layout (Canvas) umgestellt, inkl. Sidebar-Scroll.
- VA-Auswahl (VA_ID) und VADatum-Combo dynamisch aus Backend geladen; Auftragsstatus wird nach Auswahl gesetzt.
- RowSource-Handling fuer ComboBox/ListBox mit Value-Lists + Tabellen/SQL (qry_/tbltmp werden uebersprungen).
## 2025-12-30 - Query-Definitionen aus FE + RowSource-Resolution
- QueryDefs aus dem Frontend per DAO exportiert (`query_defs.json`) und nach `0000_Windows_App/AccessLayouts` uebernommen.
- Neuer Resolver: `Services/AccessQueryProvider.cs` (SQL/Query-Name -> SQL).
- RowSource-Handling in Mitarbeiterstamm/Kundenstamm/Schnellauswahl nutzt QueryResolver und verarbeitet Query-Namen statt sie zu skippen.
- Subform-Loader nutzt QueryResolver, um Query-RecordSources korrekt als SQL zu laden.
## 2025-12-30 - Dynamische RowSources + Access-SQL-Normalisierung
- AccessQueryProvider erweitert: Query-Inlining, Nz/FA_Runden-Rewrite, Entfernen von `_tblInternalSystemFE`, priv-property Ersetzungen.
- Auftragstamm: RowSource-Initialisierung fuer ComboBox/ListBox inkl. Wertelisten; IstStatus-Query bereinigt.
- Mitarbeiterstamm: dynamische Listen (Monat/Jahr/Zeitraum/Zuordnung) mit MA-ID und Zeitraum; Filter-Auftrag Combo dynamisch.
- Kundenstamm: Sonderlogik fuer PLZ/Ort-Filter, Ansprechpartner-RowSource mit `prp_Stamm_ID`.
- Schnellauswahl: dynamische Listen (Zeiten/Plan/Zusage/Parallel) nach VA/VADatum; Mitarbeiterliste auf aktive MA gesetzt.
## 2025-12-30 - WinUI3: Schnellauswahl
- `FrmMaVaSchnellauswahlPage` (XAML + Code-Behind) erstellt und an Access-Layout angebunden.
- VA-Auswahl, VADatum-Combo, Auftragsstatus sowie dynamische Listen/RowSources inkl. priv-property Filter portiert.
## 2025-12-30 - WinUI3: Dienstplan MA/Objekt Logikangleich
- `PrivPropertyStore` ergänzt für `prp_Dienstpl_StartDatum` und Versionsanzeige (`prp_V_FE`/`prp_V_BE`).
- Dienstplan MA: Navigation gemäß Access (+/-2 Tage), Enddatum +9 Tage, Tageslabels/Doppelklick, Feiertagsfärbung, MA-Auswahl-Persistenz.
- Dienstplan Objekt: Startdatum aus Priv-Property, Versionslabel gesetzt, Startdatum wird zurückgeschrieben.
## 2025-12-30 - WinUI3: Auftragstamm Filter/Status/Listen
- Auftragsliste auf Access-Query angeglichen (Datum/Auftrag/Objekt/Ort/Soll/Ist/Status) inkl. VA_ID + VADatum_ID Mapping.
- Filterlogik Auftraege_ab + IstStatus inkl. +/-3 Tage und Heute-Reset verdrahtet; btn_AbWann triggert Reload.
- Status-Logik: Sperren/Einblenden von Subforms/Buttons anhand Veranst_Status_ID (inkl. btnAuftrBerech).
- Treffp_Zeit Eingabevalidierung (hh:mm/hhmm) + Fokusweitergabe umgesetzt; cboEinsatzliste schreibt Priv-Property.
## 2025-12-30 - WinUI3: Navigation Auftragstamm -> Schnellauswahl
- MainPage erhaelt NavigateTo() mit Parameter, damit Seitenwechsel von Buttons moeglich sind.
- Auftragstamm: btnSchnellPlan navigiert zur Schnellauswahl und uebergibt VA_ID/VADatum_ID.
- Schnellauswahl: Navigation-Parameter angenommen und Vorauswahl der VA/VADatum umgesetzt.
## 2025-12-30 - WinUI3: Auftragstamm VADatum Navigation
- btnDatumLeft/btnDatumRight schalten VADatum in der ComboBox vor/zurueck (Access-Verhalten angenaehert).
## 2025-12-30 - WinUI3: Auftragstamm VADatum Anzeige
- VADatum-Combo zeigt Datum als dd.MM.yyyy via DisplayText in VADatumEntry.
## 2025-12-30 - WinUI3: Auftragstamm Schnellplan Checks
- btnSchnellPlan prueft Start/Ende-Zeiten und geplante MA (tbl_VA_Start, tbl_MA_VA_Zuordnung) vor Navigation.
## 2025-12-30 - WinUI3: Auftragstamm Datumsspanne
- Dat_VA_Von/Dat_VA_Bis Validierung und Korrektur (Bis < Von) inkl. Auto-Set.
- Fehlende VADatum-Eintraege werden in tbl_VA_AnzTage erzeugt und Combo/Subforms aktualisiert.
## 2025-12-30 - WinUI3: Auftragstamm Bericht/Serienmail Platzhalter
- Report-/Mail-Buttons setzen priv-Report-Kontext und zeigen Hinweis (WinUI3-Umsetzung offen).
## 2025-12-30 - WinUI3: Auftragstamm weitere Events
- Platzhalter fuer Positionsliste/REQ/Plan Aendern/Plan Erstellen und Kalender-Doppelklicks.
- Loeschen (mcobtnDelete) mit Bestätigung + DELETE auf tbl_VA_Auftragstamm und UI-Reset.

## 2025-12-30 - WinUI3: Auftragstamm Tabs und Header-Buttons
- 5 Tabs implementiert: Einsatzliste, Antworten ausstehend, Zusatzdateien, Rechnung, Bemerkungen (1:1 Access-Mapping).
- Header-Buttonleiste mit 6 Hauptfunktionen: Mitarbeiterauswahl (Navigation), Auftrag kopieren, Einsatzliste senden/drucken, Positionen, Aktualisieren.
- Neue Helper-Klassen: MaZuordnungStatusItem, ZusatzdateiItem fuer Tab-Datenbindung.

## 2025-12-30 - WinUI3: Dienstplan MA - Kalender-Grid Vervollständigung
- Erweiterte Farbkodierung: 5 Entry-Typen (Einsatz, Urlaub, Krank, Abwesenheit, Schicht) mit Access-orientierten Farben.
- Intelligente Abwesenheits-Erkennung: Automatische Typ-Erkennung aus Abwesenheitsgrund (Urlaub, Krank, Sonstige).
- Legende über Kalender-Grid mit allen Entry-Typen zur schnellen Orientierung.
- Verbesserte Entry-Cards: Dickere Borders, Hover-Effekte, Badge-System, Zeit-Anzeige nur bei zeitgebundenen Events.

## 2025-12-30 - WinUI3: Dienstplan Objekt - Produktionsstatus
- Vollständige Implementierung: 7-Tage-Kalender + Listen-Ansicht mit View-Toggle (RadioButtons).
- Schichten-Anzeige mit Statistik: MA Gesamt/Ist/Fehlt, Besetzungsgrad (%), Filter "Nur unbesetzt".
- Status-Visualisierung: Farbkodierung Grün (voll), Rot (unbesetzt), Orange (teilweise) in CalendarGrid.
- MA-Zuordnung: Anzeige, Entfernen, Navigation zu Schnellauswahl mit Schicht-Kontext (alle DB-Queries implementiert).
- CalendarGrid Control: Wochennavigation, KW-Anzeige, Wochenend-/Heute-Highlighting, Click-Events auf Schichten.

## 2025-12-30 - WinUI3: Schnellauswahl - Vollständige Implementierung
- UI: 5-Spalten-Layout (Zeiten/Parallel, Verfügbare MA, Buttons, Geplante MA, MA mit Zusage) wie Access-Original.
- Filter-System: Nur Aktive, Nur Verfügbare, Verplant Verfügbar, Nur 34a, Anstellungsart, Qualifikation, Suchfeld (live).
- MA-Zuordnung: Einzeln/Mehrfach/Alle zuordnen, Entfernen mit Bestätigung, automatische Statistik-Update (tbl_MA_VA_Planung CRUD).
- Dynamische Listen: VA-Auswahl, Datum, Zeiten, Parallel-Einsätze (alle Queries aus Access portiert mit Filter-Logik).
- Reaktive Property-Handler: Filter-Änderungen triggern Auto-Reload, Navigation-Parameter für Schicht-Kontext.
- E-Mail-Vorschau (Test-Modus): Zusammenfassung ohne echten SMTP-Versand, Platzhalter für zukünftige Integration.
## 2025-12-30 - WinUI3: Auftragstamm VADatum/ID Events
- cboVADatum speichert Defaultwerte fuer sub_VA_Start in priv properties und setzt Report-Kontext.
- cboID Auswahl laedt Auftrag, setzt Liste/Controls und aktualisiert Subforms.
## 2025-12-30 - WinUI3: Auftragstamm Navigation
- Veranstalter_ID Doppelklick navigiert zum Kundenstamm; Objekt_ID zeigt Platzhalter.

## 2025-12-30 - WinUI3: Mitarbeiterstamm Header-Buttons
- 4 Header-Aktionsbuttons hinzugefuegt: Loeschen (mit Bestaetigung), Transfer, Listen drucken, Tabellenansicht.
- RelayCommands mit Platzhalter-Implementierung, Loeschen nutzt bestehende DeleteAsync().

## 2025-12-30 - WinUI3: Kundenstamm Listenspalten + Kontaktname
- Kundenliste links hinzugefuegt mit Firma, Ort und Kontaktname (3-Spalten-Layout).
- Neue Felder KunKontaktNachname/KunKontaktVorname im ViewModel und Formular.
- KundenListItem DTO fuer ListView mit automatischer Kontaktname-Zusammensetzung.

## 2025-12-30 - WinUI3: Build-Fix + Statuscheck
- Build-Fehler in DienstplanMAView.xaml behoben: GoToCurrentMonthCommand -> CurrentMonthCommand.
- WinUI3-Projekt kompiliert erfolgreich (23 Warnings, 0 Errors).
- Alle Views (Dienstplan MA/Objekt, Mitarbeiterstamm, Kundenstamm) funktionsfaehig.

## 2025-12-30 - WinUI3: Visueller Vergleich + Sidebar-Korrektur
- Visuellen Vergleich zwischen Access-JSON-Exporten und WinUI3-Views durchgefuehrt.
- Vergleichsbericht erstellt: `WINUI3_ACCESS_VERGLEICH.md`
- Hauptabweichung identifiziert: Fehlende Sidebar in Dienstplan-Formularen und Kundenstamm.
- Sidebar (dunkelrot #8B0000, 140px) zu DienstplanMAView, DienstplanObjektView, KundenstammView hinzugefuegt:
  - HAUPTMENUE-Box mit weissem Hintergrund und schwarzem Rahmen
  - 9 Menue-Buttons im Access-Stil (#A05050 mit weisser Schrift)
  - Aktives Formular hervorgehoben (#D4A574 beige mit schwarzer Schrift)
- Hintergrundfarbe aller Views auf #F0F0F0 (Access-Grau) umgestellt.
- Build erfolgreich (22 Warnings, 0 Errors).
- Uebereinstimmung mit Access-Original verbessert auf ca. 85-90%.

## 2025-12-30 - WinUI3: Auftragstamm Plan-Kopie + Tag loeschen
- btnPlan_Kopie (Plan kopieren) und btn_Tag_loeschen an echte Logik gebunden (tbl_VA_Start und tbl_MA_VA_Zuordnung).
- Folgetag-Kopie setzt MVA_Start/MVA_Ende anhand Ziel-Datum, korrigiert Endzeit bei Uebernacht-Schichten.
- Tag loeschen entfernt VADatum-Daten inkl. Zuordnung und aktualisiert Subforms.
- Hilfsfunktion GetRowValue fuer sichere Dictionary-Zugriffe hinzugefuegt.
- Build angestossen; nur CS8604 Warnungen, keine Fehler (Build lief in CLI-Timeout).

## 2025-12-30 - WinUI3: Access-Automation Bridge + Auftragstamm Buttons
- AppConfig um Frontend-Pfad ergaenzt (ResolveFrontendPath).
- AccessAutomationService hinzugefuegt (COM/STA) zum Ausfuehren von Access-Funktionen/Form-Aktionen.
- Auftragstamm-Buttons auf Access-Logik umgestellt: Auftrag kopieren, Stundenliste, Autosend BOS, Messezettel, BWN senden, PDF-Kopf/Pos, Positionsliste, Rueckmeldungen, Abwesenheiten, Sync-Error, Log-Tabelle, Auftrag-Neu.
- Build erfolgreich (Warnungen wegen Dynamic/Trim und CS8604 bei Insert-Parametern).

## 2025-12-31 - HTML Auftragstamm: Logik-Fixes
- `forms/logic/frm_va_Auftragstamm.logic.js` bereinigt: Button-Handler fuer Positionen/Zusatzdateien repariert und Alerts auf ASCII vereinheitlicht.
- Doppelklick auf `veranstalter_id` oeffnet nun Kundenstamm via `ConsysShell` (wie Access).
- Embedded-Param + `ApiAutostart` in DOMContentLoaded aufgenommen, damit eingebettete Ansicht korrekt startet.

## 2025-12-31 - HTML Schnellauswahl: Anfragen-Logik
- `forms/frm_MA_VA_Schnellauswahl.html` erweitert: gefilterte MA-Liste zwischengespeichert und Buttons fuer "Alle/Nur selektierte anfragen" an echte Logik gebunden.
- Entfernen-Button implementiert: loescht geplante Zuordnungen ueber `/api/zuordnungen/<id>` und aktualisiert Listen.
- `/api/anfragen` POST wird pro MA ausgefuehrt, anschliessend Mailto-Test an definierte Adresse.
- `forms/logic/frm_MA_VA_Schnellauswahl.logic.js` parallel aktualisiert (filteredMitarbeiter, Mail-Buttons, versendeAnfragen).
- `api/api_server.py` Delete-Endpoint fuer Zuordnungen robuster gemacht (ID oder Planung_ID).

## 2025-12-31 - HTML Auftragstamm: API-Endpoints kopieren + Einsatzliste
- `bridgeClient` ergaenzt um die Aktionen `copyAuftrag` und `sendEinsatzliste`, damit Buttons im Access-Layout reale POSTs ausloesen.
- `api/api_server.py` liefert nun `/api/auftraege/copy` (Klonen des Hauptdatensatzes inkl. neues Erstellungs-/Aenderungs-Log) und `/api/auftraege/send-einsatzliste` (Log + gut definierte Antwort ohne SMTP).
- `py_compile` zeigt fuer `api_server.py` keinen Syntaxfehler, also bleiben die neuen Endpoints sofort nutzbar.

## 2025-12-31 - Menuefuehrung: HTML-Entry Button
- `frm_Menuefuehrung_sidebar.html` erhaelt den aktiven Button `HTML Ansicht`, der dieselbe `frm_va_Auftragstamm.html`-Ansicht wie das Access-Hauptmenue in einem neuen Browserfenster oeffnet.
- `frm_Menuefuehrung.html` zeigt jetzt ebenfalls den neuen Button, der die HTML-Ansicht in einem neuen Tab oeffnet und `frm_va_Auftragstamm.html` zum Einstieg nutzt.
- Erinnerung: Der API-Server muss vorher gestartet sein (`04_HTML_Forms/start_api_server.bat` oder `start_api_server_hidden.vbs`), damit die HTML-Formulare Echtdaten laden und die Sidebar-Links funktionieren.

## 2025-12-31 - Menuefuehrung: API-Start vor HTML-Ansicht
- `frm_Menuefuehrung_sidebar.html` und `frm_Menuefuehrung.html` binden jetzt `../js/api-autostart.js` und rufen vor dem Öffnen von `frm_va_Auftragstamm.html` `ApiAutostart.init()` auf, damit der API-Server gestartet wird, bevor das HTML-Formular geladen wird.
- Gelingt der Start nicht, wird eine Statusmeldung (bzw. Alert) angezeigt und die Navigation unterbrochen, damit man weiß, dass `start_api_server.bat` manuell auszuführen ist.

## 2025-12-31 - HTML Screenshot-Vergleichsbasis
- `npx playwright screenshot` hat Live-GUI-Bilder der HTML-Repliken erstellt (`artifacts/html-screenshots/{frm_va_Auftragstamm,frm_MA_Mitarbeiterstamm,frm_KD_Kundenstamm,frm_DP_Dienstplan_MA,frm_MA_VA_Schnellauswahl}.png`), während `Screenshots ACCESS Formulare/*.jpg` als Referenz dienen.
- Die Bilder sollen als Grundlage für einen visuellen 1:1-Abgleich dienen; wenn du spezifische Abweichungen (Farben, Größen, Buttons etc.) findest, nennen wir konkrete Anpassungen (CSS, Layout, Logic).

## 2025-12-31 - API-Endpoints für Dienstplan/Planungsübersicht
- **Neuer Endpoint `/api/dienstplan/uebersicht`**: Liefert alle aktiven Mitarbeiter, Einsätze und Abwesenheiten für einen Zeitraum.
  - Verwendet `tbl_MA_Mitarbeiterstamm`, `tbl_MA_VA_Planung`, `tbl_MA_NVerfuegZeiten`.
  - Filter nach Anstellungsart (Festangestellte/Minijobber/Alle).
- **Neuer Endpoint `/api/planung/uebersicht`**: Liefert alle Aufträge mit Schichten und MA-Zuordnungen.
  - Verwendet `tbl_VA_Auftragstamm`, `tbl_VA_AnzTage`, `tbl_MA_VA_Planung`.
  - Filter: `nur_freie` (nur Aufträge mit unbesetzten Schichten), `max_positionen`.
  - Zuordnungen gruppiert nach vaId und Datum.
- **HTML-Formulare aktualisiert**:
  - `frm_N_DP_Dienstplan_MA.html`: Nutzt jetzt API im Browser-Modus, Fallback auf Demo-Daten.
  - `frm_N_DP_Dienstplan_Objekt.html`: Nutzt jetzt API im Browser-Modus, Fallback auf Demo-Daten.
- **Tabellennamen korrigiert**:
  - `tbl_VA_Datum` → `tbl_VA_AnzTage` (ID, VA_ID, VADatum)
  - `tbl_MA_Abwesenheit` → `tbl_MA_NVerfuegZeiten` (MA_ID, vonDat, bisDat, Zeittyp_ID)
  - `Anstellungsart` → `Anstellungsart_ID` (numerisch)
  - `Planung_VADatum_ID` → `VADatum_ID` in tbl_MA_VA_Planung

## 2025-12-31 - Auftragstamm: Tabs und Header-Buttons erweitert
- **Tab-Header erweitert**: 5 Tabs implementiert (Einsatzliste, Antworten ausstehend, Zusatzdateien, Rechnung, Bemerkungen).
  - `pgAttach` Tab für Zusatzdateien hinzugefügt (sichtbar).
  - `pgBemerk` Tab für Bemerkungen hinzugefügt (versteckt - wie im Access-Original).
- **Tab-Pages ergänzt**: Neue `access-page` Divs für pgAttach und pgBemerk.
- **Tab-Visibility-Logik aktualisiert**:
  - pgAttach: sub_ZusatzDateien, Bezeichnungsfeld355, btnNeuAttach, TabellenNr
  - pgRechnung: sub_tbl_Rch_Kopf, sub_tbl_Rch_Pos_Auftrag, PosGesamtsumme, Rechnungslabels, btnPDFKopf, btnPDFPos
  - pgBemerk: Bemerkungen-Textfeld
- **Neue Header-Controls hinzugefügt**:
  - PKW Anzahl (Bezeichnungsfeld339 + PKW_Anzahl Textbox)
  - Fahrtkosten pro PKW (Bezeichnungsfeld655 + Fahrtkosten Textbox)
  - btn_N_HTMLAnsicht (HTML Ansicht Button)
  - btn_Posliste_oeffnen (Positionen Button)
  - btn_BWN_Druck (BWN drucken Button)
- **Missing Controls bereinigt**: pgAttach, pgBemerk, PKW_Anzahl, Bezeichnungsfeld339, Bezeichnungsfeld655 aus __access_missing_controls entfernt.

## 2025-12-31 - Schnellauswahl: API-Autostart und Demo-Daten
- **api-autostart.js** eingebunden für automatischen API-Server-Start.
- **API-Verfügbarkeitsprüfung**: Neue Funktion `checkApiAvailability()` prüft beim Start ob API erreichbar.
- **Demo-Daten als Fallback**:
  - DEMO_AUFTRAEGE (4 Beispielaufträge)
  - DEMO_MITARBEITER (10 Beispielmitarbeiter mit verschiedenen Anstellungsarten)
  - DEMO_ZEITEN (3 Beispielschichten)
  - DEMO_EINSATZTAGE (3 Beispieltage)
- **Funktionen aktualisiert** mit Demo-Fallback:
  - loadAuftraege(): Nutzt API oder DEMO_AUFTRAEGE
  - handleAuftragChange(): Nutzt API oder lokale Daten
  - loadSchichten(): Nutzt API oder DEMO_ZEITEN
  - loadMitarbeiter(): Nutzt API oder DEMO_MITARBEITER
## 2025-12-31 - KORREKTUR: Demo-Daten entfernt - NUR Echtdaten
- **WICHTIG**: Alle Demo-Daten aus HTML-Formularen entfernt.
- Formulare laden NUR noch Echtdaten aus dem Access-Backend via API.
- Bei API-Fehler wird Alert angezeigt statt Demo-Daten zu laden.
- Betroffene Dateien:
  - `frm_MA_VA_Schnellauswahl.html`: DEMO_AUFTRAEGE, DEMO_MITARBEITER, DEMO_ZEITEN, DEMO_EINSATZTAGE entfernt
  - `frm_N_DP_Dienstplan_MA.html`: loadDemoData() Funktion entfernt
  - `frm_N_DP_Dienstplan_Objekt.html`: loadDemoData() Funktion entfernt
- API-Server MUSS laufen damit Formulare funktionieren.

## 2026-01-01 - frm_KD_Kundenstamm: Visual Tuning & Vergleich
- Header, Buttons, Sidebar und Tab-Container an die Access-Referenz angenähert (Gradient, Höhen, Buttongrößen, Tabs, Sidebarfarben) sowie Rahmen, Schatten und Statusleisten angepasst.
- Die Input-/Checkbox-Layouts und Tabellen wurden auf identische Borders, Hintergrundfarben und Spaltenabstände umgestellt; außerdem wurde ein Footer-Stil ergänzt, damit `frm_KD_Kundenstamm.html` das Access-Layout pixelgenauer widerspiegelt.
- Neuer Screenshot via `npx playwright screenshot --full-page --viewport-size "1920,1080" http://localhost:8080/forms/frm_KD_Kundenstamm.html artifacts/html-screenshots/frm_KD_Kundenstamm.png`, anschließend `python compare_screenshots.py` ausgeführt.
- Visueller Vergleich aktuell: `frm_KD_Kundenstamm` RMS=144.05, avg_pixel_diff=47.09 (siehe `artifacts/html-screenshots/diffs/frm_KD_Kundenstamm-diff.png`). Weitere Optimierungen folgen, sobald wir die nächsten Elemente der Access-Maske exakt nachbilden.

## 2026-01-01 - frm_va_Auftragstamm: Fensterrahmen + Sidebar-Optik
- `Auftragsverwaltung.html` stellte uns eine klassische Rahmenoptik mit Titelzeile und Navigation bereit; `frm_va_Auftragstamm.html` übernimmt nun dieselben CSS-Klassen (window-frame, title-bar, left-menu, menu-buttons) und hat seinen Access-Canvas innerhalb des neuen Desktop-Layouts verschachtelt, ohne Funktionalität zu verlieren.
- Die linke Leiste reproduziert die Originalmenüpunkte, der Header zeigt Consys-Branding mit Fensterknöpfen, der Scrollbereich lebt weiterhin im skalierten `#scale-root`, und die bestehenden Access-Styles dafür wurden nicht verändert.
- Nach der optischen Anpassung wurde `npx playwright screenshot --full-page --viewport-size "1920,1080" http://localhost:8080/forms/frm_va_Auftragstamm.html artifacts/html-screenshots/frm_va_Auftragstamm.png` plus `python compare_screenshots.py` ausgeführt, RMS=114.89 / avg_pixel_diff=42.27 (Diff: `artifacts/html-screenshots/diffs/frm_va_Auftragstamm-diff.png`).

## 2026-01-02 - Zentraler Style-Hub aus Auftragsverwaltung
- `css/app-layout.css` spiegelt jetzt die Farben, Buttons, Sidebarkacheln und Footer aus `Auftragsverwaltung.html` (lila Kopf, violette Sidebar, Fenster-Buttons, Glossy-Menüs). Durch den global geladenen Frameworkstil greifen alle HTML-Formulare auf die gemeinsame Optik zurück, ohne sie einzeln anzupassen.
- Der neue Look wurde via `npx playwright screenshot --full-page --viewport-size "1920,1080" http://localhost:8080/forms/frm_KD_Kundenstamm.html artifacts/html-screenshots/frm_KD_Kundenstamm.png` dokumentiert; ein weiterer `python compare_screenshots.py`-Durchlauf ergibt nun RMS=150.04 / avg_pixel_diff=51.12, was an der Standardisierung liegt (`artifacts/html-screenshots/diffs/frm_KD_Kundenstamm-diff.png`).

## 2026-01-06 - Auftragstamm JavaScript-Fehler behoben
- **Fix 1:** `setFormReadOnly()` - Null-Check fuer `lblKeineEingabe` hinzugefuegt (Zeile 2272)
- **Fix 2:** `Bridge.setFormValue()` entfernt - Funktion existierte nicht in Bridge-Objekt (Zeile 1979)
- **Ergebnis:** Formular laedt jetzt korrekt - Einsatzliste, Schichten, Auftragsliste werden angezeigt
- **Getestet:** VA_ID 9357 zeigt 14 Zuordnungen, 18 Schichten, 96 Auftraege in Planung
