Attribute VB_Name = "mdl_FinalRebuild"

Public Sub TotalCleanAndRebuild()
    Dim frm As Form
    Dim ctl As control
    Dim ctlName As String
    Dim ctlList As String
    Dim deleteCount As Integer
    
    deleteCount = 0
    ctlList = ""
    
    Debug.Print "=== TOTALE BEREINIGUNG ==="
    Debug.Print ""
    
    ' Formular im Design-Modus öffnen
    DoCmd.OpenForm "frm_MA_Monatsübersicht", 2
    Set frm = Forms("frm_MA_Monatsübersicht")
    
    Debug.Print "Schritt 1: Liste ALLE Controls..."
    
    ' Sammle alle Control-Namen (rückwärts durchgehen für sicheres Löschen)
    Dim i As Integer
    Dim controlNames() As String
    ReDim controlNames(frm.Controls.Count - 1)
    
    For i = 0 To frm.Controls.Count - 1
        controlNames(i) = frm.Controls(i).Name
        Debug.Print "  Gefunden: " & controlNames(i)
    Next i
    
    Debug.Print ""
    Debug.Print "Schritt 2: Lösche ALLE Controls..."
    
    ' Lösche alle Controls (von hinten nach vorne)
    For i = UBound(controlNames) To 0 Step -1
        On Error Resume Next
        DeleteControl frm.Name, controlNames(i)
        
        If Err.Number = 0 Then
            deleteCount = deleteCount + 1
            Debug.Print "  ? Gelöscht: " & controlNames(i)
        Else
            Debug.Print "  ? Konnte nicht löschen: " & controlNames(i) & " - " & Err.description
        End If
        Err.clear
    Next i
    
    Debug.Print ""
    Debug.Print "Gelöscht: " & deleteCount & " Controls"
    Debug.Print ""
    Debug.Print "Schritt 3: Erstelle NEUE Controls..."
    
    ' Dimensionen
    Dim leftMargin As Long
    Dim subW As Long
    Dim subH As Long
    Dim subT As Long
    Dim formW As Long
    Dim detailH As Long
    
    formW = frm.width
    detailH = frm.Section(0).height
    leftMargin = 567 * 5
    subW = formW - leftMargin - (567 * 1)
    subH = (detailH - 2000) / 3
    
    Debug.Print "  Form Width: " & formW
    Debug.Print "  Detail Height: " & detailH
    Debug.Print "  Subform Width: " & subW
    Debug.Print "  Subform Height: " & subH
    Debug.Print ""
    
    ' === COMBOBOXEN UND LABELS ===
    
    ' cboJahr
    Set ctl = CreateControl(frm.Name, 111, 0, , , 300, 300, 1500, 350)
    ctl.Name = "cboJahr"
    ctl.RowSourceType = "Value List"
    ctl.RowSource = "2023;2024;2025"
    ctl.defaultValue = "2025"
    ctl.AfterUpdate = "[Event Procedure]"
    ctl.FontSize = 10
    Debug.Print "  ? cboJahr erstellt"
    
    ' lblJahr
    Set ctl = CreateControl(frm.Name, 100, 0, , , 1900, 300, 800, 350)
    ctl.Name = "lblJahr"
    ctl.caption = "Jahr"
    ctl.FontSize = 10
    Debug.Print "  ? lblJahr erstellt"
    
    ' cboAnstellungsart
    Set ctl = CreateControl(frm.Name, 111, 0, , , 2900, 300, 2800, 350)
    ctl.Name = "cboAnstellungsart"
    ctl.RowSourceType = "Value List"
    ctl.RowSource = "3;Festangestellte;5;Minijobber"
    ctl.ColumnCount = 2
    ctl.ColumnWidths = "0cm;4cm"
    ctl.BoundColumn = 1
    ctl.defaultValue = "3"
    ctl.AfterUpdate = "[Event Procedure]"
    ctl.FontSize = 10
    Debug.Print "  ? cboAnstellungsart erstellt"
    
    ' lblAnstellungsart
    Set ctl = CreateControl(frm.Name, 100, 0, , , 5800, 300, 2000, 350)
    ctl.Name = "lblAnstellungsart"
    ctl.caption = "Anstellungsart"
    ctl.FontSize = 10
    Debug.Print "  ? lblAnstellungsart erstellt"
    
    Debug.Print ""
    Debug.Print "Schritt 4: Erstelle UNTERFORMULARE..."
    
    ' === UNTERFORMULAR 1: URLAUBSTAGE ===
    subT = 1000
    
    ' Label
    Set ctl = CreateControl(frm.Name, 100, 0, , , leftMargin, subT - 350, 3000, 300)
    ctl.Name = "lblUrlaubstage"
    ctl.caption = "Urlaubstage"
    ctl.FontBold = True
    ctl.FontSize = 11
    ctl.ForeColor = RGB(0, 70, 140)
    Debug.Print "  ? lblUrlaubstage"
    
    ' Subform
    Set ctl = CreateControl(frm.Name, 112, 0, , , leftMargin, subT, subW, subH)
    ctl.Name = "subUrlaubstage"
    ctl.SourceObject = "Form.sub_MA_Monat_Urlaub"
    ctl.BorderStyle = 1
    ctl.LinkMasterFields = ""
    ctl.LinkChildFields = ""
    Debug.Print "  ? subUrlaubstage"
    
    ' === UNTERFORMULAR 2: KRANKHEITSTAGE ===
    subT = subT + subH + 500
    
    ' Label
    Set ctl = CreateControl(frm.Name, 100, 0, , , leftMargin, subT - 350, 3000, 300)
    ctl.Name = "lblKrankheitstage"
    ctl.caption = "Krankheitstage"
    ctl.FontBold = True
    ctl.FontSize = 11
    ctl.ForeColor = RGB(140, 0, 0)
    Debug.Print "  ? lblKrankheitstage"
    
    ' Subform
    Set ctl = CreateControl(frm.Name, 112, 0, , , leftMargin, subT, subW, subH)
    ctl.Name = "subKrankheitstage"
    ctl.SourceObject = "Form.sub_MA_Monat_Krank"
    ctl.BorderStyle = 1
    ctl.LinkMasterFields = ""
    ctl.LinkChildFields = ""
    Debug.Print "  ? subKrankheitstage"
    
    ' === UNTERFORMULAR 3: PRIVAT VERPLANT ===
    subT = subT + subH + 500
    
    ' Label
    Set ctl = CreateControl(frm.Name, 100, 0, , , leftMargin, subT - 350, 3000, 300)
    ctl.Name = "lblPrivatverplant"
    ctl.caption = "Privat verplant"
    ctl.FontBold = True
    ctl.FontSize = 11
    ctl.ForeColor = RGB(0, 100, 0)
    Debug.Print "  ? lblPrivatverplant"
    
    ' Subform
    Set ctl = CreateControl(frm.Name, 112, 0, , , leftMargin, subT, subW, subH)
    ctl.Name = "subPrivatverplant"
    ctl.SourceObject = "Form.sub_MA_Monat_Privat"
    ctl.BorderStyle = 1
    ctl.LinkMasterFields = ""
    ctl.LinkChildFields = ""
    Debug.Print "  ? subPrivatverplant"
    
    ' OnLoad Event setzen
    frm.OnLoad = "[Event Procedure]"
    
    Debug.Print ""
    Debug.Print "Schritt 5: Speichere und schließe..."
    DoCmd.Close 2, "frm_MA_Monatsübersicht", 1
    
    Debug.Print ""
    Debug.Print "=== NEUAUFBAU ABGESCHLOSSEN ==="
    Debug.Print "  - " & deleteCount & " alte Controls gelöscht"
    Debug.Print "  - 10 neue Controls erstellt"
    Debug.Print ""
    
    MsgBox "Formular wurde komplett neu aufgebaut!" & vbCrLf & vbCrLf & _
           "Gelöscht: " & deleteCount & " Controls" & vbCrLf & _
           "Neu erstellt: 10 Controls", 64, "Erfolg"
End Sub

