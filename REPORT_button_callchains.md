# REPORT: Button-Aufrufketten (Call Chains)

**Erstellt:** 2026-01-08
**Formular:** frm_va_Auftragstamm
**Status:** DOKUMENTIERT

---

## 1. btnMailEins (E-Mail an Mitarbeiter)

### OnClick-Prozedur
`btnMailEins_Click()` (Zeile 1495-1525 in frm_va_Auftragstamm)

### Aufrufkette
```
btnMailEins_Click()
  |
  +-> Set_Priv_Property("prp_Report1_Auftrag_IstTage", "-1")
  |
  +-> TCount() -> Zaehlt tbl_MA_VA_Zuordnung
  |
  +-> DoCmd.OpenForm "frm_MA_Serien_eMail_Auftrag"
  |
  +-> Form_frm_MA_Serien_eMail_Auftrag.Autosend(2, iVA_ID, iVADatum_ID)
       |
       +-> VAOpen() -> Laedt VA-Daten
       |
       +-> btnPDFCrea_Click()
       |    |
       |    +-> DoCmd.OutputTo acOutputReport, "rpt_Auftrag_Zusage", "PDF", PDF_Datei
       |    |
       |    +-> INSERT INTO tbltmp_Attachfile (Dateiname, ...)
       |
       +-> Outlook.CreateItem(olMailItem)
            |
            +-> .To = Mitarbeiter-E-Mail
            +-> .Subject = "[Auftrag] am [Datum]"
            +-> .HTMLBody = Template aus prp_Std_Versammlungsinfo
            +-> .Attachments.Add(PDF_Datei)
            +-> .Send
```

### Endaktion
E-Mail-Versand mit PDF-Anhang (rpt_Auftrag_Zusage) an alle zugeordneten Mitarbeiter

### Verwendete Templates/Pfade
- Report: `rpt_Auftrag_Zusage`
- PDF-Pfad: `CONSYS\CONSEC\CONSEC PLANUNG AKTUELL\Allgemein\[Auftrag] [Objekt] am [Datum].pdf`
- E-Mail-Vorlage: Property `prp_Std_Versammlungsinfo`

---

## 2. btnDruckZusage (Excel-Export)

### OnClick-Prozedur
`btnDruckZusage_Click()` (Zeile 1398-1430)

### Aufrufkette
```
btnDruckZusage_Click()
  |
  +-> Datum, Auftrag, Objekt von Formular-Controls lesen
  |
  +-> Datum formatieren (TT-MM-JJ)
  |
  +-> fXL_Export_Auftrag(ID, Pfad, Filename)
  |    |
  |    +-> Excel.Application.Workbooks.Open(Template)
  |    +-> Befuellt Zellen mit Auftragsdaten
  |    +-> SaveAs(Pfad & Filename)
  |    +-> Workbook.Close
  |
  +-> Sleep(1000)  // 1 Sekunde warten
  |
  +-> Me!Veranst_Status_ID = 2  // Status "Beendet"
  |
  +-> DoEvents + Cache-Refresh
```

### Endaktion
Excel-Export des Auftrags mit allen Daten, setzt Status auf "Beendet"

### Verwendete Templates/Pfade
- Zielverzeichnis: `CONSYS\CONSEC\CONSEC PLANUNG AKTUELL\`
- Dateiname: `[TT-MM-JJ] [Auftrag] [Objekt].xlsm`
- Excel-Template: Property `prp_XL_DocVorlage`

---

## 3. btn_Autosend_BOS (BOS-Franken Einsatzliste)

### OnClick-Prozedur
`btn_Autosend_BOS_Click()` (Zeile 182-225)

### Aufrufkette
```
btn_Autosend_BOS_Click()
  |
  +-> IF Veranstalter_ID IN (10720, 20770, 20771) THEN  // Nur BOS-Franken
  |
  +-> Set_Priv_Property("prp_Report1_Auftrag_IstTage", "-1")
  |
  +-> TCount() -> Zaehlt Zuordnungen
  |
  +-> strEmpfaenger = "marcus.wuest@bos-franken.de; sb-dispo@bos-franken.de; frank.fischer@bos-franken.de"
  |
  +-> DoCmd.OpenForm "frm_MA_Serien_eMail_Auftrag"
  |
  +-> Form_frm_MA_Serien_eMail_Auftrag.Autosend(4, iVA_ID, iVADatum_ID, strEmpfaenger)
       |
       +-> [Identisch zu btnMailEins, aber mit festem Empfaenger]
```

### Endaktion
E-Mail-Versand an fest hinterlegte BOS-Franken Adressen

### Verwendete Templates/Pfade
- E-Mail-Vorlage: Property `prp_Std_Einsatzliste_KD`
- Empfaenger (hardcoded):
  - marcus.wuest@bos-franken.de
  - sb-dispo@bos-franken.de
  - frank.fischer@bos-franken.de

### Einschraenkung
Nur aktiv fuer Veranstalter_ID: 10720, 20770, 20771 (BOS-Franken)

---

## 4. btn_BWN_Druck (Bewachungsnachweis drucken)

### OnClick-Prozedur
**AUSKOMMENTIERT** (Zeile 228-240)

### Code (deaktiviert)
```vba
'Private Sub btn_BWN_Druck_Click()
'    On Error GoTo Err_Handler
'    Call DruckeBewachungsnachweise(Me)
'Exit_Sub:
'    Exit Sub
'Err_Handler:
'    MsgBox "Fehler im Druck-Button: " & Err.description, vbCritical
'    Resume Exit_Sub
'End Sub
```

### Status
**INAKTIV** - Code ist auskommentiert

### Geplante Funktion
Report-Druck der Bewachungsnachweise via `DruckeBewachungsnachweise(Me)`

---

## 5. cmd_BWN_send (Bewachungsnachweis senden)

### OnClick-Prozedur
`cmd_BWN_send_Click()` (Zeile 642-644)

### Aufrufkette
```
cmd_BWN_send_Click()
  |
  +-> SendeBewachungsnachweise(Me)
       |
       +-> SELECT * FROM tbl_MA_VA_Zuordnung WHERE VA_ID = ...
       |
       +-> MsgBox "Nur markierte Mitarbeiter?" -> Ja/Nein
       |
       +-> FOR EACH Mitarbeiter IN Recordset:
       |    |
       |    +-> ExtrahiereStandnummerAusBemerkungen(Bemerkungen)
       |    |
       |    +-> FindePDF_NachDatumUndStand(Datum, Standnummer)
       |    |    |
       |    |    +-> Sucht PDF-Dateien nach Namenskonvention
       |    |    +-> Collection mit gefundenen PDFs
       |    |
       |    +-> GetMitarbeiterEmail(MA_ID)
       |    |
       |    +-> GetMitarbeiterAnzeigename(MA_ID)
       |    |
       |    +-> Outlook.CreateItem(olMailItem)
       |         |
       |         +-> .To = E-Mail-Adresse
       |         +-> .Subject = "Bewachungsnachweise Messe - [Name] ([Anzahl] Dateien)"
       |         +-> .HTMLBody = ErzeugeMailTextHTML()
       |         +-> FOR EACH pdf IN PDFs: .Attachments.Add(pdf)
       |         +-> .Send
       |
       +-> Optional: UPDATE tbl_MA_VA_Zuordnung SET Rch_Erstellt = False
```

### Endaktion
E-Mail-Versand mit Bewachungsnachweis-PDFs als Anhang an jeden Mitarbeiter

### Verwendete Funktionen
- `GetMitarbeiterAnzeigename(maID)` - Holt Name aus DB
- `FindePDF_NachDatumUndStand(datum, stand)` - Sucht PDF-Dateien
- `IstPDFBereitsVorhanden(col, pfad)` - Duplikat-Pruefung
- `GetMitarbeiterEmail(maID)` - Holt E-Mail aus DB
- `ExtrahiereStandnummerAusBemerkungen(bemerkungen)` - Parst Standnummer
- `ErzeugeMailTextHTML()` - Erstellt HTML-Body

### Verwendete Pfade
PDFs werden dynamisch via `FindePDF_NachDatumUndStand()` gesucht

---

## 6. btnPlan_Kopie (Daten in Folgetag kopieren)

### OnClick-Prozedur
`btnPlan_Kopie_Click()` (Zeile 1829-1901)

### Aufrufkette
```
btnPlan_Kopie_Click()
  |
  +-> MsgBox "Daten in Folgetag kopieren?" -> Ja/Nein/Abbrechen
  |
  +-> IF Ja:
       |
       +-> ArrFill_DAO_Acc(Array, SQL)
       |    |
       |    +-> SELECT VADatum_ID, VADatum FROM tbl_VA_AnzTage WHERE VA_ID = ...
       |
       +-> Finde aktuelles Datum und Folgetag im Array
       |
       +-> DELETE FROM tbl_VA_Start WHERE VA_ID = [ID] AND VADatum_ID = [Folgetag]
       |
       +-> DELETE FROM tbl_MA_VA_Zuordnung WHERE VA_ID = [ID] AND VADatum_ID = [Folgetag]
       |
       +-> INSERT INTO tbl_VA_Start (VA_ID, VADatum, VADatum_ID, VA_Start, VA_Ende, ...)
       |    |
       |    +-> Kopiert alle Schichten vom aktuellen Tag zum Folgetag
       |
       +-> UPDATE tbl_VA_Start SET MVA_Start = ..., MVA_Ende = ...
       |
       +-> Zuord_Fill(va_Folgedat_ID, VA_ID)
       |    |
       |    +-> Befuellt tbl_MA_VA_Zuordnung fuer den Folgetag
       |
       +-> Me.sfm_VA_Start.Form.Requery
       |
       +-> btnDatumRight_Click()  // Navigiert zum Folgetag
```

### Endaktion
Kopiert alle Schichten und MA-Zuordnungen vom aktuellen Tag zum naechsten Planungstag

### Verwendete Tabellen
- `tbl_VA_AnzTage` - Schichten-Termine
- `tbl_VA_Start` - Schichten-Zeiten
- `tbl_MA_VA_Zuordnung` - Mitarbeiter-Zuordnungen

### Verwendete Funktionen
- `ArrFill_DAO_Acc()` - Befuellt Array aus SQL
- `Zuord_Fill()` - Befuellt Zuordnungstabelle
- `btnDatumRight_Click()` - Navigation zum naechsten Tag

---

## Zusammenfassung

| Button | Hauptfunktion | Endaktion | Status |
|--------|--------------|----------|--------|
| btnMailEins | E-Mail Einsatzliste MA | PDF versenden | AKTIV |
| btnDruckZusage | Excel Export | XLSM erstellen + Status | AKTIV |
| btn_Autosend_BOS | E-Mail an BOS | PDF an feste Adressen | AKTIV (begrenzt) |
| btn_BWN_Druck | BWN drucken | (AUSKOMMENTIERT) | INAKTIV |
| cmd_BWN_send | BWN per E-Mail | PDFs an Mitarbeiter | AKTIV |
| btnPlan_Kopie | Daten kopieren | Folgetag befuellen | AKTIV |

---

*Erstellt von Claude Code*
