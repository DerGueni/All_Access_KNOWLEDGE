'Attribute VB_Name = "mdl_Restore_Subforms"

Public Sub Restore_Subforms()
    On Error GoTo Err_Handler
    
    Dim frm As Form
    Dim ctl As control
    Dim i As Integer
    Dim ctlName As String
    Dim ctlList() As String
    Dim ctlCount As Integer
    
    Debug.Print "=== START ==="
    
    DoCmd.OpenForm "frm_N_MA_Monatsuebersicht", 1, , , , 1
    Set frm = forms("frm_N_MA_Monatsuebersicht")
    
    Debug.Print "Sammle alte Unterformulare..."
    ctlCount = 0
    For i = 0 To frm.Controls.Count - 1
        Set ctl = frm.Controls(i)
        If ctl.ControlType = 112 Then
            If InStr(ctl.Name, "sub_N_MA_Monats_") > 0 Then
                ctlCount = ctlCount + 1
                ReDim Preserve ctlList(1 To ctlCount)
                ctlList(ctlCount) = ctl.Name
                Debug.Print "  - Gefunden: " & ctl.Name
            End If
        End If
    Next i
    
    Debug.Print "Loesche " & ctlCount & " alte Unterformulare..."
    For i = 1 To ctlCount
        ctlName = ctlList(i)
        Debug.Print "  - Loesche: " & ctlName
        DeleteControl frm.Name, ctlName
    Next i
    
    Debug.Print "Erstelle Unterformular 1: sub_N_MA_Monats_Gesamt..."
    Set ctl = Application.CreateControl(frm.Name, 112, , , , 100, 100, 8000, 1500)
    ctl.Name = "sub_N_MA_Monats_Gesamt"
    ctl.SourceObject = "qry_N_MA_Monats_Gesamt"
    ctl.LinkMasterFields = "MA_ID;Monat;Jahr"
    ctl.LinkChildFields = "MA_ID;Monat;Jahr"
    Debug.Print "  OK"
    
    Debug.Print "Erstelle Unterformular 2: sub_N_MA_Monats_Details..."
    Set ctl = Application.CreateControl(frm.Name, 112, , , , 100, 1700, 8000, 2500)
    ctl.Name = "sub_N_MA_Monats_Details"
    ctl.SourceObject = "qry_N_MA_Monats_Details"
    ctl.LinkMasterFields = "MA_ID;Monat;Jahr"
    ctl.LinkChildFields = "MA_ID;Monat;Jahr"
    Debug.Print "  OK"
    
    Debug.Print "Erstelle Unterformular 3: sub_N_MA_Monats_Stunden..."
    Set ctl = Application.CreateControl(frm.Name, 112, , , , 100, 4300, 8000, 1500)
    ctl.Name = "sub_N_MA_Monats_Stunden"
    ctl.SourceObject = "qry_N_MA_Monats_Stunden"
    ctl.LinkMasterFields = "MA_ID;Monat;Jahr"
    ctl.LinkChildFields = "MA_ID;Monat;Jahr"
    Debug.Print "  OK"
    
    Debug.Print "Erstelle Unterformular 4: sub_N_MA_Monats_Betrag..."
    Set ctl = Application.CreateControl(frm.Name, 112, , , , 100, 5900, 8000, 1500)
    ctl.Name = "sub_N_MA_Monats_Betrag"
    ctl.SourceObject = "qry_N_MA_Monats_Betrag"
    ctl.LinkMasterFields = "MA_ID;Monat;Jahr"
    ctl.LinkChildFields = "MA_ID;Monat;Jahr"
    Debug.Print "  OK"
    
    Debug.Print "Speichere und schliesse Formular..."
    DoCmd.Close 2, "frm_N_MA_Monatsuebersicht", 1
    
    Debug.Print "=== ERFOLGREICH ABGESCHLOSSEN ==="
    MsgBox "4 Unterformulare erfolgreich erstellt!" & vbCrLf & vbCrLf & _
           "- sub_N_MA_Monats_Gesamt" & vbCrLf & _
           "- sub_N_MA_Monats_Details" & vbCrLf & _
           "- sub_N_MA_Monats_Stunden" & vbCrLf & _
           "- sub_N_MA_Monats_Betrag", _
           64, "Erfolg"
    
Exit_Handler:
    Exit Sub
    
Err_Handler:
    Debug.Print ""
    Debug.Print "FEHLER: " & Err.Number & " - " & Err.description
    Debug.Print "Zeile: " & Erl
    MsgBox "Fehler beim Erstellen der Unterformulare:" & vbCrLf & vbCrLf & _
           "Nummer: " & Err.Number & vbCrLf & _
           "Beschreibung: " & Err.description, _
           16, "Fehler"
    Resume Exit_Handler
End Sub