VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form__frmHlp_Excel_Einbinden"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub btnAbbruch_Click()
DoCmd.Close
End Sub

Public Function btnSend()
btnEinbind_Click
End Function


Private Sub btnEinbind_Click()
Dim iMax As Long
Dim i As Long
Dim newdb As String
Dim iRet As Long
Dim fileName As String
fileName = "Lexware Import"

If Me!WahlLinkImport = 1 Then
    newdb = Me!Dateiname

    i = InStrRev(newdb, ".xls")
    If i > 0 Then
        newdb = Left(newdb, i) & fileName & ".xls"
    Else
        newdb = newdb & fileName & ".xls"
    End If
    
    Me!Dateiname = newdb
End If


If Get_Priv_Property("prp_GL_XL_MehrfachTabs") > 0 And Me!WahlLinkImport = 1 Then

    If File_exist(Me!Dateiname) Then
        iRet = MsgBox("Dateiname existiert, überschreiben?", vbQuestion + vbYesNoCancel, Me!Dateiname)
        If iRet = vbYes Then
            Kill Me!Dateiname
        ElseIf iRet = vbCancel Then
            Exit Sub
        End If
    End If

    iMax = UBound(GL_XL_MehrfachTabs)
    For i = 0 To iMax
    
        Me!Tabellenname = Nz(GL_XL_MehrfachTabs(i))
        DoEvents
        Call ExcelTransferspreadsheet(Nz(Me!Dateiname), Nz(Me!Tabellenname), Me!WahlLinkImport, Me!IstMitHeader, Me!IstMitID, Nz(Me!vonTab), Nz(Me!vonZelle), Nz(Me!BisZelle), Me!XLVersion)
        DoEvents
        Sleep 20
        DoEvents
    Next i
        Call Set_Priv_Property("prp_GL_XL_MehrfachTabs", 0)
        DoCmd.Close acForm, "_frmHlp_Excel_Einbinden", acSaveNo
        MsgBox "Daten exportiert"
'        MsgBox "completed"

Else
    If ExcelTransferspreadsheet(Nz(Me!Dateiname), Nz(Me!Tabellenname), Me!WahlLinkImport, Me!IstMitHeader, Me!IstMitID, Nz(Me!vonTab), Nz(Me!vonZelle), Nz(Me!BisZelle), Me!XLVersion) = True Then
        DoCmd.Close acForm, "_frmHlp_Excel_Einbinden", acSaveNo
        MsgBox "Daten exportiert"
'        MsgBox "completed"
    End If
End If
End Sub

Private Sub btnFileSearch_Click()

Dim newdb As String
Dim j As Long
Dim i As Long
Dim strnam As String

If Me!WahlLinkImport <> 1 Then
    newdb = XLSSuch
    If Len(Trim(Nz(newdb))) > 0 Then
        Me!Dateiname = newdb
    Else
        MsgBox "Kein Excel Import/Link Dateiname ausgewählt", vbCritical, "Fehler"
'        MsgBox "No Excel import/link filename selected", vbCritical, "Error"
        Exit Sub
    End If
Else
    newdb = SavefileSuch()
        
    If Len(Trim(Nz(newdb))) = 0 Then
'        MsgBox "No Excel export filename selected", vbCritical, "Error"
        MsgBox "Kein Excel Export Dateiname ausgewählt", vbCritical, "Fehler"
       Exit Sub
    Else
        i = InStrRev(newdb, ".")
        If i > 0 Then
            newdb = Left(newdb, i) & "XSLB"
        Else
            newdb = newdb & ".XLSB"
        End If
        
        Me!Dateiname = newdb
    End If
End If

End Sub


Private Sub btnHelp_Click()
DoCmd.OpenForm "frm_Hilfe_Anzeige", acNormal, , "Formularname = '" & Me.Name & "'"
End Sub

Private Sub Form_Load()
If Me!WahlLinkImport = 1 Then
    Me!Tabellenname = "qryReport1"
End If
WahlLinkImport_AfterUpdate

'Dateiname vorbelegen
Me.Dateiname = PfadPlanungAktuell

'Tabellenname vorbelegen
Me.Tabellenname = "qryReport1"

End Sub

Public Function WahlLI()
WahlLinkImport_AfterUpdate
End Function

Private Sub WahlLinkImport_AfterUpdate()

Me!IstMitID.Visible = False

Select Case Me!WahlLinkImport
    Case 0  '--- Import
      Me!btnEinbind.caption = "Import"
      Me!vonZelle.Visible = True
      Me!BisZelle.Visible = True
      Me!vonTab.Visible = True
      Me!Tabellenname = "Tabelle1"
      Me!IstMitID.Visible = True
    
    Case 1  '--- Export
      Me!btnEinbind.caption = "Export"
      Me!vonZelle = ""
      Me!BisZelle = ""
      Me!vonTab = ""
      Me!vonZelle.Visible = False
      Me!BisZelle.Visible = False
      Me!vonTab.Visible = False
      Me!Tabellenname = "qryReport1"
    
    Case 2  '--- Verknüpfen
      Me!btnEinbind.caption = "Link"
      Me!vonZelle.Visible = True
      Me!BisZelle.Visible = True
      Me!vonTab.Visible = True
      Me!Tabellenname = "Tabelle1"

    Case Else

End Select

End Sub

Private Function XLSSuch(Optional ByVal startdir As String = "C:\", Optional ByVal StBeschriftung As String = "Exceldatei (*.xl*) suchen") As String

Dim fd As New FileDialog

Const OFN_FILEMUSTEXIST = &H1000
Const OFN_PATHMUSTEXIST = &H800
Const OFN_HIDEREADONLY = &H4
Const OFN_READONLY = &H1
Const OFN_OVERWRITEPROMPT = &H2

   With fd  ' CommonDialog aufrufen
    ' Erläuterungen im Code des KlassenModuls FileDialog

      .DialogTitle = StBeschriftung
      .InitDir = startdir

      .DefaultExt = "XLSB"             'Standard-Endung wenn vom Benutzer nix anderes angegeben
'                                      ' Ansonsten wird Filter1 verwendet
'      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_READONLY
      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST

' Hier können bis max. 5 Filter für Datei-Endungen definiert werden

      .Filter1Text = "Excel-Dateien (*.xl*)"
      .Filter1Suffix = "*.xl??"
      .Filter2Text = "Excel-Dateien (*.xls)"
      .Filter2Suffix = "*.xls"
      .Filter3Text = "Alle Dateien (*.*)"
      .Filter3Suffix = "*.*"
'      .Filter4Text = "MDB-Dateien (*.mdb)"
'      .Filter4Suffix = "*.mdb"
'      .Filter5Text = "MD*-Dateien (*.md*)"
'      .Filter5Suffix = "*.md*"

'      ... bis max. Filter5Text/Suffix ...
'
      .ShowOpen                          ' oder .ShowSave
   End With

XLSSuch = fd.fileName

End Function




Private Function SavefileSuch(Optional ByVal startdir As String = "C:\", Optional ByVal StBeschriftung As String = "search filename for output") As String

Dim fd As New FileDialog
 
Const OFN_FILEMUSTEXIST = &H1000
Const OFN_PATHMUSTEXIST = &H800
Const OFN_HIDEREADONLY = &H4
Const OFN_READONLY = &H1
Const OFN_OVERWRITEPROMPT = &H2
 
   With fd  ' CommonDialog aufrufen
    ' Erläuterungen im Code des KlassenModuls FileDialog
      
      .DialogTitle = StBeschriftung
      .InitDir = startdir
      
'      .DefaultExt = "TXT"             'Standard-Endung wenn vom Benutzer nix anderes angegeben
'                                      ' Ansonsten wird Filter1 verwendet
'      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_READONLY
'      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST
      .Flags = OFN_PATHMUSTEXIST
                      
' Hier können bis max. 5 Filter für Datei-Endungen definiert werden
      
      .Filter1Text = "Alle Dateien (*.*)"
      .Filter1Suffix = "*.*"

'      ... bis max. Filter5Text/Suffix ...
'
'      .ShowOpen                          ' oder .ShowSave
      .ShowSave
   End With
   
SavefileSuch = fd.fileName

End Function


Private Sub btnEnde_Click()
On Error GoTo Err_btnEnde_Click


    DoCmd.Close

Exit_btnEnde_Click:
    Exit Sub

Err_btnEnde_Click:
    MsgBox Err.description
    Resume Exit_btnEnde_Click
    
End Sub
