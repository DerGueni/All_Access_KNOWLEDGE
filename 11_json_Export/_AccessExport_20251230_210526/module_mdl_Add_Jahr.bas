Option Compare Database
Option Explicit

Sub Add_Jahr_Combo()
    Dim frm As Form
    Dim ctl As control
    Dim bExists As Boolean
    Dim lngLeft As Long, lngTop As Long
    
    ' Formular im Entwurf öffnen
    DoCmd.OpenForm "frm_N_MA_Monatsuebersicht", acDesign
    Set frm = forms("frm_N_MA_Monatsuebersicht")
    
    ' Prüfen ob cboJahr bereits existiert
    bExists = False
    On Error Resume Next
    Set ctl = frm.Controls("cboJahr")
    If Not ctl Is Nothing Then bExists = True
    On Error GoTo 0
    
    If bExists Then
        MsgBox "Kombinationsfeld 'cboJahr' existiert bereits!", vbInformation
        DoCmd.Close acForm, frm.Name, acSaveNo
        DoCmd.OpenForm "frm_N_MA_Monatsuebersicht"
        Exit Sub
    End If
    
    ' Position festlegen (oben rechts neben Hauptmenü)
    lngLeft = 200
    lngTop = 200
    
    ' Label erstellen
    Set ctl = Application.CreateControl(frm.Name, acLabel, acDetail, "", "", lngLeft, lngTop, 800, 300)
    ctl.caption = "Jahr:"
    ctl.FontBold = True
    ctl.FontSize = 11
    ctl.Name = "lblJahr"
    
    ' Kombinationsfeld erstellen
    Set ctl = Application.CreateControl(frm.Name, acComboBox, acDetail, "", "", lngLeft + 900, lngTop, 1200, 300)
    ctl.Name = "cboJahr"
    ctl.RowSourceType = "Value List"
    ctl.RowSource = "2025;2024;2023"
    ctl.FontSize = 11
    
    ' VBA-Code für AfterUpdate Event hinzufügen
    Dim mdl As Module
    Set mdl = frm.Module
    
    ' Prüfen ob Code bereits existiert
    Dim strCode As String
    Dim i As Long
    Dim bCodeExists As Boolean
    bCodeExists = False
    
    For i = 1 To mdl.CountOfLines
        strCode = mdl.lines(i, 1)
        If InStr(strCode, "cboJahr_AfterUpdate") > 0 Then
            bCodeExists = True
            Exit For
        End If
    Next i
    
    If Not bCodeExists Then
        ' Code am Ende hinzufügen
        Dim lngLine As Long
        lngLine = mdl.CountOfLines + 1
        
        If mdl.CountOfLines = 0 Then
            mdl.InsertLines 1, "Option Compare Database"
            mdl.InsertLines 2, "Option Explicit"
            lngLine = 4
        End If
        
        mdl.InsertLines lngLine, "Private Sub cboJahr_AfterUpdate()"
        lngLine = lngLine + 1
        mdl.InsertLines lngLine, "    Dim strJahr As String"
        lngLine = lngLine + 1
        mdl.InsertLines lngLine, "    If IsNull(Me.cboJahr) Then Exit Sub"
        lngLine = lngLine + 1
        mdl.InsertLines lngLine, "    strJahr = Me.cboJahr"
        lngLine = lngLine + 1
        mdl.InsertLines lngLine, "    On Error Resume Next"
        lngLine = lngLine + 1
        mdl.InsertLines lngLine, "    If Not IsNull(Me.subStunden.SourceObject) Then"
        lngLine = lngLine + 1
        mdl.InsertLines lngLine, "        Me.subStunden.SourceObject = ""Query.qry_KreuzTab_MA_Stunden_"" & strJahr & ""_Final"""
        lngLine = lngLine + 1
        mdl.InsertLines lngLine, "    End If"
        lngLine = lngLine + 1
        mdl.InsertLines lngLine, "    If Not IsNull(Me.subPrivat.SourceObject) Then"
        lngLine = lngLine + 1
        mdl.InsertLines lngLine, "        Me.subPrivat.SourceObject = ""Query.qry_KreuzTab_Privat_"" & strJahr & ""_Final"""
        lngLine = lngLine + 1
        mdl.InsertLines lngLine, "    End If"
        lngLine = lngLine + 1
        mdl.InsertLines lngLine, "    If Not IsNull(Me.subUrlaub.SourceObject) Then"
        lngLine = lngLine + 1
        mdl.InsertLines lngLine, "        Me.subUrlaub.SourceObject = ""Query.qry_KreuzTab_Urlaub_"" & strJahr & ""_Final"""
        lngLine = lngLine + 1
        mdl.InsertLines lngLine, "    End If"
        lngLine = lngLine + 1
        mdl.InsertLines lngLine, "    If Not IsNull(Me.subKrank.SourceObject) Then"
        lngLine = lngLine + 1
        mdl.InsertLines lngLine, "        Me.subKrank.SourceObject = ""Query.qry_KreuzTab_Krank_"" & strJahr & ""_Final"""
        lngLine = lngLine + 1
        mdl.InsertLines lngLine, "    End If"
        lngLine = lngLine + 1
        mdl.InsertLines lngLine, "    Me.Requery"
        lngLine = lngLine + 1
        mdl.InsertLines lngLine, "End Sub"
        lngLine = lngLine + 2
        
        mdl.InsertLines lngLine, "Private Sub Form_Load()"
        lngLine = lngLine + 1
        mdl.InsertLines lngLine, "    Me.cboJahr = 2025"
        lngLine = lngLine + 1
        mdl.InsertLines lngLine, "End Sub"
    End If
    
    ' Speichern und öffnen
    DoCmd.Save acForm, frm.Name
    DoCmd.Close acForm, frm.Name
    DoCmd.OpenForm "frm_N_MA_Monatsuebersicht"
    
    MsgBox "Kombinationsfeld für Jahresauswahl hinzugefügt!" & vbCrLf & _
           "Position: Oben links im Formular" & vbCrLf & _
           "Werte: 2025, 2024, 2023", vbInformation
End Sub