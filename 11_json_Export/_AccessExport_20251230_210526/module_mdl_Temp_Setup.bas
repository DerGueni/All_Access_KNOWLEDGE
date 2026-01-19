Option Compare Database
Option Explicit

Sub Temp_Setup()
    Dim frm As Form
    Dim ctl As control
    Dim lngTop As Long, lngLeft As Long
    Dim lngWidth As Long, lngHeight As Long
    Dim bExists As Boolean
    
    ' Formular öffnen
    DoCmd.OpenForm "frm_N_MA_Monatsuebersicht", acDesign
    Set frm = forms("frm_N_MA_Monatsuebersicht")
    
    ' Formular-Größe
    frm.width = 18000
    frm.Section(acDetail).height = 11500
    
    ' Kombinationsfelder Position
    lngLeft = 200
    lngTop = 200
    
    ' === PRÜFEN OB CONTROLS EXISTIEREN ===
    
    ' Jahr-Controls
    bExists = False
    For Each ctl In frm.Controls
        If ctl.Name = "lblJahr" Or ctl.Name = "cboJahr" Then
            bExists = True
            Exit For
        End If
    Next
    
    If Not bExists Then
        ' Label + Combo Jahr erstellen
        Set ctl = Application.CreateControl(frm.Name, acLabel, acDetail, "", "", lngLeft, lngTop, 800, 300)
        ctl.caption = "Jahr:"
        ctl.FontBold = True
        ctl.Name = "lblJahr"
        
        Set ctl = Application.CreateControl(frm.Name, acComboBox, acDetail, "", "", lngLeft + 900, lngTop, 1200, 300)
        ctl.Name = "cboJahr"
        ctl.RowSourceType = "Value List"
        ctl.RowSource = "2025;2024;2023"
    End If
    
    ' Anstellungsart-Controls
    bExists = False
    For Each ctl In frm.Controls
        If ctl.Name = "lblAnstellungsart" Or ctl.Name = "cboAnstellungsart" Then
            bExists = True
            Exit For
        End If
    Next
    
    If Not bExists Then
        lngLeft = 3000
        Set ctl = Application.CreateControl(frm.Name, acLabel, acDetail, "", "", lngLeft, lngTop, 1600, 300)
        ctl.caption = "Anstellungsart:"
        ctl.FontBold = True
        ctl.Name = "lblAnstellungsart"
        
        Set ctl = Application.CreateControl(frm.Name, acComboBox, acDetail, "", "", lngLeft + 1700, lngTop, 2000, 300)
        ctl.Name = "cboAnstellungsart"
        ctl.RowSourceType = "Value List"
        ctl.RowSource = "Alle;Festangestellte;Minijobber"
    End If
    
    ' === UNTERFORMULARE ===
    lngTop = 700
    lngLeft = 200
    lngWidth = 8300
    lngHeight = 5000
    
    ' Stunden
    bExists = False
    For Each ctl In frm.Controls
        If ctl.Name = "subStunden" Then
            bExists = True
            Exit For
        End If
    Next
    If Not bExists Then
        Set ctl = Application.CreateControl(frm.Name, acSubform, acDetail, "", "", lngLeft, lngTop, lngWidth, lngHeight)
        ctl.Name = "subStunden"
        ctl.SourceObject = "Query.qry_KreuzTab_MA_Stunden_2025_Final"
    End If
    
    ' Privat
    bExists = False
    For Each ctl In frm.Controls
        If ctl.Name = "subPrivat" Then
            bExists = True
            Exit For
        End If
    Next
    If Not bExists Then
        Set ctl = Application.CreateControl(frm.Name, acSubform, acDetail, "", "", lngLeft + lngWidth + 200, lngTop, lngWidth, lngHeight)
        ctl.Name = "subPrivat"
        ctl.SourceObject = "Query.qry_KreuzTab_Privat_2025_Final"
    End If
    
    ' Urlaub
    bExists = False
    For Each ctl In frm.Controls
        If ctl.Name = "subUrlaub" Then
            bExists = True
            Exit For
        End If
    Next
    If Not bExists Then
        Set ctl = Application.CreateControl(frm.Name, acSubform, acDetail, "", "", lngLeft, lngTop + lngHeight + 200, lngWidth, lngHeight)
        ctl.Name = "subUrlaub"
        ctl.SourceObject = "Query.qry_KreuzTab_Urlaub_2025_Final"
    End If
    
    ' Krank
    bExists = False
    For Each ctl In frm.Controls
        If ctl.Name = "subKrank" Then
            bExists = True
            Exit For
        End If
    Next
    If Not bExists Then
        Set ctl = Application.CreateControl(frm.Name, acSubform, acDetail, "", "", lngLeft + lngWidth + 200, lngTop + lngHeight + 200, lngWidth, lngHeight)
        ctl.Name = "subKrank"
        ctl.SourceObject = "Query.qry_KreuzTab_Krank_2025_Final"
    End If
    
    ' VBA-Code hinzufügen
    Call Add_VBA_Code(frm)
    
    DoCmd.Save acForm, frm.Name
    DoCmd.Close acForm, frm.Name
    DoCmd.OpenForm "frm_N_MA_Monatsuebersicht"
    
    MsgBox "Setup abgeschlossen!" & vbCrLf & _
           "Fehlende Controls wurden hinzugefügt.", vbInformation
End Sub

Private Sub Add_VBA_Code(frm As Form)
    Dim mdl As Module
    Dim lngLine As Long
    
    Set mdl = frm.Module
    If mdl.CountOfLines > 0 Then mdl.DeleteLines 1, mdl.CountOfLines
    
    lngLine = 1
    mdl.InsertLines lngLine, "Option Compare Database"
    lngLine = lngLine + 1
    mdl.InsertLines lngLine, "Option Explicit"
    lngLine = lngLine + 2
    
    mdl.InsertLines lngLine, "Private Sub Form_Load()"
    lngLine = lngLine + 1
    mdl.InsertLines lngLine, "    Me.cboJahr = 2025"
    lngLine = lngLine + 1
    mdl.InsertLines lngLine, "    Me.cboAnstellungsart = ""Alle"""
    lngLine = lngLine + 1
    mdl.InsertLines lngLine, "    Call Update_Datenquellen"
    lngLine = lngLine + 1
    mdl.InsertLines lngLine, "End Sub"
    lngLine = lngLine + 2
    
    mdl.InsertLines lngLine, "Private Sub cboJahr_AfterUpdate()"
    lngLine = lngLine + 1
    mdl.InsertLines lngLine, "    Call Update_Datenquellen"
    lngLine = lngLine + 1
    mdl.InsertLines lngLine, "End Sub"
    lngLine = lngLine + 2
    
    mdl.InsertLines lngLine, "Private Sub cboAnstellungsart_AfterUpdate()"
    lngLine = lngLine + 1
    mdl.InsertLines lngLine, "    Call Update_Datenquellen"
    lngLine = lngLine + 1
    mdl.InsertLines lngLine, "End Sub"
    lngLine = lngLine + 2
    
    mdl.InsertLines lngLine, "Private Sub Update_Datenquellen()"
    lngLine = lngLine + 1
    mdl.InsertLines lngLine, "    Dim strJahr As String"
    lngLine = lngLine + 1
    mdl.InsertLines lngLine, "    If IsNull(Me.cboJahr) Then Exit Sub"
    lngLine = lngLine + 1
    mdl.InsertLines lngLine, "    strJahr = Me.cboJahr"
    lngLine = lngLine + 1
    mdl.InsertLines lngLine, "    On Error Resume Next"
    lngLine = lngLine + 1
    mdl.InsertLines lngLine, "    Me.subStunden.SourceObject = ""Query.qry_KreuzTab_MA_Stunden_"" & strJahr & ""_Final"""
    lngLine = lngLine + 1
    mdl.InsertLines lngLine, "    Me.subPrivat.SourceObject = ""Query.qry_KreuzTab_Privat_"" & strJahr & ""_Final"""
    lngLine = lngLine + 1
    mdl.InsertLines lngLine, "    Me.subUrlaub.SourceObject = ""Query.qry_KreuzTab_Urlaub_"" & strJahr & ""_Final"""
    lngLine = lngLine + 1
    mdl.InsertLines lngLine, "    Me.subKrank.SourceObject = ""Query.qry_KreuzTab_Krank_"" & strJahr & ""_Final"""
    lngLine = lngLine + 1
    mdl.InsertLines lngLine, "    Me.Requery"
    lngLine = lngLine + 1
    mdl.InsertLines lngLine, "End Sub"
End Sub