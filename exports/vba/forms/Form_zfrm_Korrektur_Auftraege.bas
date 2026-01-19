VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_zfrm_Korrektur_Auftraege"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

' Verweis auf Microsoft Scripting Runtime notwendig!

Const NichtGedruckt = "Noch nicht gedruckt"
Const PlanungAktuell = "Planung aktuell"
Const ZuBerechnen = "Zu berechnen"
Const RechnGestellt = "Rechnung gestellt"


Dim heuteSQL            As String
Dim datumSQL            As String
Dim AbfrageAuftragstamm As String
Dim arrDatPlan()        As String 'Dateien im Verzeichnis PlanungAktuell
Dim arrDatBerech()      As String 'Dateien im Verzeichnis ZuBerechnen
Dim arrDatRechn()       As String 'Dateien im Verzeichnis RechnGestellt
Dim arrDNVAS()          As String 'VA_ID / Dateinamen der Veranstaltungen im Auftragstamm / Pfad / Status
Dim rs                  As Recordset


'Vorbelegung Datumsfeld für Auswertezeitraum
Private Sub Form_Open(Cancel As Integer)

Dim d       As Integer
Dim DatumAb As Date

    'Auswertezeitraum in Tagen
    d = 60

    DatumAb = Now() - d
    Me.DatumAb = Format(DatumAb, "DD.MM.YYYY")
   
    'Daten vorbelege
    Call vorbelegen

    Me.cbo_AktStatus = ""
    Me.btnDruck.Enabled = False
    Me.btnRech.Enabled = False
    Me.recordSource = AbfrageAuftragstamm
    Me.Requery

End Sub


'Auswertezeitraum geändert
Private Sub DatumAb_AfterUpdate()

    'Daten vorbelegen
    Call vorbelegen

    Me.cbo_AktStatus = ""
    Me.recordSource = AbfrageAuftragstamm
    Me.Requery

End Sub



'Auftrag drucken
Private Sub btnDruck_Click()

Dim Datum As Date
Dim SDatum As String
Dim Auftrag As String
Dim Objekt As String
Dim ID As Long

    Datum = Me.Controls("Dat_VA_Von")
    SDatum = Format(Datum, "MM-DD-YY")
    Auftrag = Me.Controls("Auftrag")
    Objekt = Me.Controls("Objekt")
    ID = Me.Controls("ID")
    
    
    Call fXL_Export_Auftrag(ID, PfadPlanungAktuell, SDatum & " " & Auftrag & " " & Objekt & ".xlsm")
    
    cbo_AktStatus_AfterUpdate
    
End Sub


'Auftrag berechnen
Private Sub btnRech_Click()

    If Len(Trim(Nz(Me!Veranstalter_ID))) = 0 Or Me!Veranstalter_ID = 0 Then
        MsgBox "Bitte Veranstalter eingeben"
        
    Else
        DoCmd.OpenForm "frmTop_Rch_Berechnungsliste"
        Form_frmTop_Rch_Berechnungsliste.VAOpen Me!ID
        
        Me.Controls("Abschlussdatum") = Format(Now(), "DD.MM.YYYY")

   End If

End Sub


'Auswahl des aktuellen Status
Private Sub cbo_AktStatus_AfterUpdate()

    'Arrays mit Dateinamen der jeweiligen Ordner füttern
    fillArrayDateien PfadPlanungAktuell, arrDatPlan()
    fillArrayDateien PfadZuBerechnen, arrDatBerech()
    fillArrayDateien PfadRechnGestellt, arrDatRechn()

    'Array mit Dateinamen
    Call fillArrayDateinamenAuftragstamm
    
    'Status und Dateinamen im Auftragstamm neu setzen
    Call aktualisiereAuftragstamm


    Set rs = CurrentDb.OpenRecordset(AbfrageAuftragstamm)

    Select Case Me.cbo_AktStatus.Value
        'Auftrag noch nicht gedruckt (keine Datei in keinem der Verzeichnisse)
        Case NichtGedruckt
            
            AbfrageAuftragstamm = AbfrageAuftragstamm & " AND [Veranst_Status_ID] = 1"
            Me.btnDruck.Enabled = True
            Me.btnRech.Enabled = False

        'Auftrag in Ordner "Planung Aktuell"
        Case PlanungAktuell
            AbfrageAuftragstamm = AbfrageAuftragstamm & " AND [Veranst_Status_ID] = 2"
            Me.btnDruck.Enabled = False
            Me.btnRech.Enabled = True
            
        'Auftrag in Ordner "Noch zu berechnen"
        Case ZuBerechnen
            AbfrageAuftragstamm = AbfrageAuftragstamm & " AND [Veranst_Status_ID] = 3"
            Me.btnDruck.Enabled = False
            Me.btnRech.Enabled = True
            
        'Auftrag in Ordner "Rechnung gestellt"
        Case RechnGestellt
            AbfrageAuftragstamm = AbfrageAuftragstamm & " AND [Veranst_Status_ID] = 4"
            Me.btnDruck.Enabled = False
            Me.btnRech.Enabled = False
            
    End Select
    
    Me.recordSource = AbfrageAuftragstamm & " ORDER BY [DAT_VA_Von] ASC"
    Me.Requery
    
Set rs = Nothing

End Sub


'Array mit den jeweilgen Dateien im Verzeichnis füllen
Function fillArrayDateien(pfad As String, arr() As String)

Dim objFso     As Object 'Scripting.FileSystemObject
Dim objOrdner  As Object 'Scripting.Folder
Dim Datei      As Object 'Scripting.file
Dim anzDateien As Long
Dim i          As Integer

On Error GoTo Fehler

    Set objFso = CreateObject("Scripting.FileSystemObject") 'New Scripting.filesystemobject
    Set objOrdner = objFso.GetFolder(pfad)

    'Anzahl Dateien
    anzDateien = objOrdner.files.Count

    'Array dimensionieren
    ReDim arr(anzDateien)

    'Array füllen
    i = 0
    For Each Datei In objOrdner.files
        arr(i) = Datei.Name
        i = i + 1
    Next Datei

    Set objFso = Nothing
    Set objOrdner = Nothing

    Exit Function

Fehler:
  Set objFso = Nothing
  Set objOrdner = Nothing
  MsgBox "FehlerNr.: " & Err.Number & _
          vbNewLine & vbNewLine & _
         "Beschreibung: " & Err.description, _
          vbCritical, "Fehler:"
  End
End Function


'Array mit den jeweilgen Dateinamen der Aufträge im Auftragstamm füllen
Function fillArrayDateinamenAuftragstamm()

Dim anzDateinamen As Long
Dim dDatum        As Date
Dim SDatum        As String
Dim veranst       As String
Dim Location      As String
Dim ID            As Long
Dim i             As Integer


On Error GoTo Fehler
    
    'Werte vorbelegen
     Call vorbelegen
    
    Set rs = CurrentDb.OpenRecordset(AbfrageAuftragstamm)

    'Anzahl Dateinamen (Aufträge im Auftragstamm)
    rs.MoveLast
    rs.MoveFirst
    anzDateinamen = rs.RecordCount

    'Array dimensionieren
    ReDim arrDNVAS(anzDateinamen * 2, 3) 'Einmal xlsm, einmal pdf

    'Array füllen
    i = 0
    Do
        ID = rs.fields("ID")
        veranst = rs.fields("Auftrag")
        If Not rs.fields("Objekt") = "" Then
            Location = rs.fields("Objekt")
        Else
            Location = ""
        End If
        dDatum = rs.fields("DAT_VA_Von")
        SDatum = Format(dDatum, "MM-DD-YY")
        'Dateinamen zusammentackern
        arrDNVAS(i, 0) = ID
        arrDNVAS(i, 1) = SDatum & " " & veranst & " " & Location & ".xlsm"
        arrDNVAS(i, 3) = berechneStatus(arrDNVAS(i, 1))
        arrDNVAS(i, 2) = pfad_aus_status(arrDNVAS(i, 3))
        i = i + 1
        arrDNVAS(i, 0) = ID
        arrDNVAS(i, 1) = SDatum & " " & veranst & " " & Location & ".pdf"
        arrDNVAS(i, 3) = berechneStatus(arrDNVAS(i, 1))
        arrDNVAS(i, 2) = pfad_aus_status(arrDNVAS(i, 3))
        i = i + 1
        rs.MoveNext
        
    Loop Until rs.EOF
    rs.Close

    Set rs = Nothing

    Exit Function

Fehler:
  Set rs = Nothing
  MsgBox "FehlerNr.: " & Err.Number & _
          vbNewLine & vbNewLine & _
         "Beschreibung: " & Err.description, _
          vbCritical, "Fehler:"
          
End Function



'Prüfen, ob bereits eine Datei zur Veranstaltung existiert
Function berechneStatus(Dateiname As String) As Integer

    'Dateiname im Array vorhanden?
    Select Case True
            
        Case Find_Value(arrDatRechn, Dateiname) >= 0
            berechneStatus = 4
             
        Case Find_Value(arrDatBerech, Dateiname) >= 0
            berechneStatus = 3

        Case Find_Value(arrDatPlan, Dateiname) >= 0
            berechneStatus = 2
      
        Case Else
            berechneStatus = 1
            
    End Select
    
End Function


'Wert im Array vorhanden?
Function Find_Value(ByRef SomeArray() As String, SearchTerm As String) As Long
    Dim i As Long
    Find_Value = -1
    For i = LBound(SomeArray) To UBound(SomeArray)
        If SomeArray(i) = SearchTerm Then
            Find_Value = i
            Exit For
        End If
    Next
    
End Function


'Prüfen, ob bereits eine Datei zur Veranstaltung existiert
Function pfad_aus_status(ByVal Status As Integer) As String

    'Dateiname im Array vorhanden?
    Select Case Status
            
        Case 4
            pfad_aus_status = PfadRechnGestellt
             
        Case 3
            pfad_aus_status = PfadZuBerechnen
            
        Case 2
            pfad_aus_status = PfadPlanungAktuell
      
        Case Else
            'kein Pfad
            
    End Select
    
End Function


'Status und Dateiname im Auftragstamm aktualisieren
Function aktualisiereAuftragstamm()

Dim i          As Long
Dim aktStatus  As Integer
Dim ID         As Integer
Dim statusNeu  As Integer
Dim rst        As Recordset

On Error Resume Next

    For i = LBound(arrDNVAS) To UBound(arrDNVAS)
        ID = arrDNVAS(i, 0)
        Set rst = CurrentDb.OpenRecordset("SELECT * FROM " & AUFTRAGSTAMM & " WHERE [ID] = " & ID)
        aktStatus = rst.fields("Veranst_Status_ID")
        statusNeu = arrDNVAS(i, 3)
        
        If statusNeu > aktStatus And aktStatus <> -1 Then
            rst.Edit
            rst.fields("Veranst_Status_ID") = statusNeu
            If statusNeu > 1 Then
                rst.fields("Excel_Dateiname") = arrDNVAS(i, 1) 'Dateiname
                rst.fields("Excel_Path") = arrDNVAS(i, 2)      'Pfad
            End If
            rst.update
        End If
        
        rst.Close
        Set rst = Nothing
        
    Next i

End Function


Function vorbelegen()

On Error Resume Next

    heuteSQL = "#" & Year(Now) & "-" & Month(Now) & "-" & Day(Now) & "#"
    datumSQL = "#" & Year(Me.DatumAb) & "-" & Month(Me.DatumAb) & "-" & Day(Me.DatumAb) & "#"

    'Abfrage zusammentackern
    AbfrageAuftragstamm = "SELECT * FROM " & AUFTRAGSTAMM & " WHERE ([DAT_VA_Bis] BETWEEN " & datumSQL & " AND " & heuteSQL & ") AND [Auftrag] is not Null"
 
End Function



