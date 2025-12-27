Attribute VB_Name = "mdl_Prepare_Hauptformular"

Public Sub Prepare_Hauptformular_Monatsuebersicht()
    On Error GoTo Err_Handler
    
    Dim frm As Form
    Dim ctl As control
    
    Debug.Print "=== PREPARE HAUPTFORMULAR ==="
    
    ' Formular in Design-Ansicht öffnen
    DoCmd.OpenForm "frm_N_MA_Monatsuebersicht", 1, , , , 1
    Set frm = Forms("frm_N_MA_Monatsuebersicht")
    
    Debug.Print "Formular geöffnet: " & frm.Name
    Debug.Print "RecordSource: " & frm.recordSource
    Debug.Print ""
    
    ' Prüfe ob Controls existieren
    Debug.Print "1. Prüfe vorhandene Controls..."
    Dim hasMA As Boolean, hasMonat As Boolean, hasJahr As Boolean
    Dim i As Integer
    
    For i = 0 To frm.Controls.Count - 1
        Set ctl = frm.Controls(i)
        If ctl.Name = "cboMA" Or ctl.Name = "MA_ID" Then hasMA = True
        If ctl.Name = "cboMonat" Or ctl.Name = "Monat" Then hasMonat = True
        If ctl.Name = "cboJahr" Or ctl.Name = "Jahr" Then hasJahr = True
    Next i
    
    Debug.Print "   MA-Control vorhanden: " & hasMA
    Debug.Print "   Monat-Control vorhanden: " & hasMonat
    Debug.Print "   Jahr-Control vorhanden: " & hasJahr
    Debug.Print ""
    
    ' Erstelle fehlende Controls
    If Not hasMA Then
        Debug.Print "2. Erstelle MA_ID ComboBox..."
        Set ctl = Application.CreateControl(frm.Name, 111, , , , 100, 50, 2000, 300)
        ctl.Name = "MA_ID"
        ctl.RowSourceType = "Table/Query"
        ctl.RowSource = "SELECT MA_ID, Nachname, Vorname FROM tbl_MA_Mitarbeiterstamm ORDER BY Nachname"
        ctl.ColumnCount = 3
        ctl.ColumnWidths = "0;1500;1500"
        ctl.BoundColumn = 1
        Debug.Print "   OK"
    End If
    
    If Not hasMonat Then
        Debug.Print "3. Erstelle Monat ComboBox..."
        Set ctl = Application.CreateControl(frm.Name, 111, , , , 2200, 50, 1000, 300)
        ctl.Name = "Monat"
        ctl.RowSourceType = "Value List"
        ctl.RowSource = "1;2;3;4;5;6;7;8;9;10;11;12"
        Debug.Print "   OK"
    End If
    
    If Not hasJahr Then
        Debug.Print "4. Erstelle Jahr ComboBox..."
        Set ctl = Application.CreateControl(frm.Name, 111, , , , 3300, 50, 800, 300)
        ctl.Name = "Jahr"
        ctl.RowSourceType = "Value List"
        ctl.RowSource = "2023;2024;2025;2026"
        ctl.defaultValue = "Year(Date())"
        Debug.Print "   OK"
    End If
    
    ' Labels erstellen
    Debug.Print "5. Erstelle Labels..."
    If Not hasMA Then
        Set ctl = Application.CreateControl(frm.Name, 100, , , , 100, 20, 2000, 200)
        ctl.Name = "lbl_MA_ID"
        ctl.caption = "Mitarbeiter:"
    End If
    
    If Not hasMonat Then
        Set ctl = Application.CreateControl(frm.Name, 100, , , , 2200, 20, 1000, 200)
        ctl.Name = "lbl_Monat"
        ctl.caption = "Monat:"
    End If
    
    If Not hasJahr Then
        Set ctl = Application.CreateControl(frm.Name, 100, , , , 3300, 20, 800, 200)
        ctl.Name = "lbl_Jahr"
        ctl.caption = "Jahr:"
    End If
    Debug.Print "   OK"
    
    ' Speichern
    Debug.Print ""
    Debug.Print "6. Speichere Formular..."
    DoCmd.Close 2, "frm_N_MA_Monatsuebersicht", 1
    
    Debug.Print ""
    Debug.Print "=== HAUPTFORMULAR VORBEREITET ==="
    Debug.Print ""
    Debug.Print "Jetzt kann Sub Restore_Subforms ausgefuehrt werden!"
    
    MsgBox "Hauptformular vorbereitet!" & vbCrLf & vbCrLf & _
           "Fehlende Controls erstellt:" & vbCrLf & _
           "- MA_ID (ComboBox)" & vbCrLf & _
           "- Monat (ComboBox)" & vbCrLf & _
           "- Jahr (ComboBox)" & vbCrLf & vbCrLf & _
           "Naechster Schritt: Sub Restore_Subforms ausfuehren", _
           64, "Vorbereitung"
    
Exit_Handler:
    Exit Sub
    
Err_Handler:
    Debug.Print ""
    Debug.Print "FEHLER: " & Err.Number & " - " & Err.description
    MsgBox "Fehler: " & Err.description, 16, "Fehler"
    Resume Exit_Handler
End Sub
