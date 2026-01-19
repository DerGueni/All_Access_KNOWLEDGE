Attribute VB_Name = "mdl_N_MA_Import"
Option Compare Database
Option Explicit

' =========================================================================
' Modul: mdl_N_MA_Import
' Zweck: Import von Bewerberdaten aus Excel-Template
' =========================================================================

Public Function Import_Bewerberdaten_Excel(strExcelPath As String) As Long
    Dim xlApp As Object
    Dim xlWb As Object
    Dim xlWs As Object
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim newID As Long
    Dim i As Integer
    
    On Error GoTo Err_Handler
    
    Set db = CurrentDb
    Set rs = db.OpenRecordset("tbl_N_MA_Bewerberdaten", dbOpenDynaset)
    
    ' Excel öffnen
    Set xlApp = CreateObject("Excel.Application")
    xlApp.Visible = False
    Set xlWb = xlApp.Workbooks.Open(strExcelPath)
    Set xlWs = xlWb.Sheets("Bewerberdaten")
    
    ' Neuer Datensatz
    rs.AddNew
    
    ' Mapping: Excel-Zeile -> Access-Feld
    ' Persönliche Daten
    rs!Nachname = Nz(xlWs.Range("B6").Value, "")
    rs!Vorname = Nz(xlWs.Range("B7").Value, "")
    rs!Strasse = Nz(xlWs.Range("B8").Value, "")
    rs!PLZ = Nz(xlWs.Range("B9").Value, "")
    rs!Ort = Nz(xlWs.Range("B10").Value, "")
    rs!Bundesland = Nz(xlWs.Range("B11").Value, "")
    rs!Tel_Mobil = Nz(xlWs.Range("B12").Value, "")
    rs!Tel_Festnetz = Nz(xlWs.Range("B13").Value, "")
    rs!Email = Nz(xlWs.Range("B14").Value, "")
    rs!Geschlecht = Nz(xlWs.Range("B15").Value, "")
    rs!Staatsangehoerigkeit = Nz(xlWs.Range("B16").Value, "")
    
    ' Datum konvertieren
    If IsDate(xlWs.Range("B17").Value) Then
        rs!Geburtsdatum = CDate(xlWs.Range("B17").Value)
    End If
    
    rs!Geburtsort = Nz(xlWs.Range("B18").Value, "")
    rs!Geburtsname = Nz(xlWs.Range("B19").Value, "")
    
    ' Sozialversicherung
    rs!SozialVersNr = Nz(xlWs.Range("B21").Value, "")
    rs!SteuerID = Nz(xlWs.Range("B22").Value, "")
    rs!Steuerklasse = Nz(xlWs.Range("B23").Value, "")
    rs!IBAN = Nz(xlWs.Range("B24").Value, "")
    rs!BIC = Nz(xlWs.Range("B25").Value, "")
    rs!Kontoinhaber = Nz(xlWs.Range("B26").Value, "")
    rs!Krankenkasse = Nz(xlWs.Range("B27").Value, "")
    
    ' Beschäftigungsart
    If IsNumeric(xlWs.Range("B29").Value) Then
        rs!Lohngruppe = CDbl(xlWs.Range("B29").Value)
    End If
    If IsNumeric(xlWs.Range("B30").Value) Then
        rs!Anstellungsart_ID = CLng(xlWs.Range("B30").Value)
    End If
    If IsDate(xlWs.Range("B31").Value) Then
        rs!Eintrittsdatum = CDate(xlWs.Range("B31").Value)
    End If
    rs!Fahrerlaubnis = Nz(xlWs.Range("B32").Value, "")
    rs!Eigener_PKW = Nz(xlWs.Range("B33").Value, "")
    
    ' Qualifikationen
    rs!Para34a_Unterrichtung = Nz(xlWs.Range("B35").Value, "")
    rs!Para34a_Sachkunde = Nz(xlWs.Range("B36").Value, "")
    
    ' Zusatzinformationen
    If IsNumeric(xlWs.Range("B38").Value) Then
        rs!Arbeitstage_Woche = CLng(xlWs.Range("B38").Value)
    End If
    If IsNumeric(xlWs.Range("B39").Value) Then
        rs!Stundenzahl_Monat = CLng(xlWs.Range("B39").Value)
    End If
    rs!RV_Befreiung = Nz(xlWs.Range("B40").Value, "")
    If IsNumeric(xlWs.Range("B41").Value) Then
        rs!Brutto_Std = CDbl(xlWs.Range("B41").Value)
    End If
    rs!Abzuege = Nz(xlWs.Range("B42").Value, "")
    rs!Abrechnung_eMail = Nz(xlWs.Range("B43").Value, "")
    rs!Lichtbild_Vorhanden = Nz(xlWs.Range("B44").Value, "")
    If IsDate(xlWs.Range("B45").Value) Then
        rs!Signatur_Datum = CDate(xlWs.Range("B45").Value)
    End If
    
    ' Bemerkungen
    rs!Bemerkungen = Nz(xlWs.Range("B47").Value, "")
    
    ' Meta-Daten
    rs!Excel_Datei = strExcelPath
    rs!Import_Datum = Now()
    rs!Import_Von = Environ("USERNAME")
    rs!Verarbeitet = "Nein"
    
    rs.update
    newID = rs!ID
    
    ' Aufräumen
    xlWb.Close False
    xlApp.Quit
    Set xlWs = Nothing
    Set xlWb = Nothing
    Set xlApp = Nothing
    rs.Close
    Set rs = Nothing
    Set db = Nothing
    
    Import_Bewerberdaten_Excel = newID
    MsgBox "Bewerberdaten importiert! ID: " & newID, vbInformation, "Import erfolgreich"
    Exit Function
    
Err_Handler:
    MsgBox "Fehler beim Import: " & Err.description, vbCritical
    If Not xlWb Is Nothing Then xlWb.Close False
    If Not xlApp Is Nothing Then xlApp.Quit
    Import_Bewerberdaten_Excel = 0
End Function

Public Function Waehle_Excel_Datei() As String
    Dim fd As Object
    Set fd = Application.FileDialog(3)
    
    With fd
        .title = "Bewerberdaten-Excel auswählen"
        .Filters.clear
        .Filters.Add "Excel-Dateien", "*.xlsx"
        .AllowMultiSelect = False
        
        If .Show = -1 Then
            Waehle_Excel_Datei = .SelectedItems(1)
        Else
            Waehle_Excel_Datei = ""
        End If
    End With
    
    Set fd = Nothing
End Function

Public Sub Import_Dialog()
    Dim strPath As String
    Dim lngID As Long
    
    strPath = Waehle_Excel_Datei()
    
    If strPath <> "" Then
        lngID = Import_Bewerberdaten_Excel(strPath)
        If lngID > 0 Then
            DoCmd.OpenForm "frm_N_MA_Bewerber_Verarbeitung", , , "ID=" & lngID
        End If
    Else
        MsgBox "Kein Datei ausgewählt", vbInformation
    End If
End Sub
