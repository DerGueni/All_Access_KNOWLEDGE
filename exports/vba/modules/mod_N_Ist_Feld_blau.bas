Attribute VB_Name = "mod_N_Ist_Feld_blau"
Option Compare Database
Option Explicit

' ======================================================================
' Modul: Update_Conditional_Format_Ist_Feld
' Zweck: Erweitert die bedingte Formatierung des "Ist"-Feldes in frm_lst_row_auftrag
'        um eine Prüfung auf offene Mitarbeiteranfragen
'
' Neue Logik:
'   1. Wenn offene Anfragen existieren → Blau
'   2. Wenn keine Anfragen offen UND Ist < Soll → Rot
'   3. Sonst → Normale Darstellung
' ======================================================================

Sub Update_Ist_Conditional_Formatting()
    On Error GoTo Err_Handler
    
    Dim frm As Form
    Dim ctl As control
    Dim fc As FormatCondition
    Dim strExpr1 As String
    Dim strExpr2 As String
    
    ' Formular im Design-Modus öffnen
    DoCmd.OpenForm "frm_lst_row_auftrag", acDesign
    Set frm = Forms("frm_lst_row_auftrag")
    Set ctl = frm.Controls("Ist")
    
    Debug.Print "=== AKTUELLE BEDINGTE FORMATIERUNG ==="
    Debug.Print "Anzahl Bedingungen: " & ctl.FormatConditions.Count
    
    ' Aktuelle Bedingungen anzeigen (zur Info)
    Dim i As Integer
    For i = 0 To ctl.FormatConditions.Count - 1
        Debug.Print "Bedingung " & (i + 1) & ":"
        Debug.Print "  Type: " & ctl.FormatConditions(i).Type
        Debug.Print "  Expression1: " & ctl.FormatConditions(i).Expression1
        Debug.Print "  ForeColor: " & ctl.FormatConditions(i).ForeColor
    Next i
    
    ' Alle alten Bedingungen löschen
    ctl.FormatConditions.Delete
    Debug.Print vbCrLf & "=== NEUE FORMATIERUNG HINZUF�GEN ==="
    
    ' ---------------------------------------------------------------
    ' BEDINGUNG 1: Offene Anfragen vorhanden → BLAU
    ' ---------------------------------------------------------------
    ' Prüft ob für diesen Auftrag (VA_ID) und Datum (VADatum_ID)
    ' Einträge in tbl_MA_VA_Planung existieren, bei denen
    ' Rueckmeldezeitpunkt noch Null ist
    
    strExpr1 = "DCount(""*"",""tbl_MA_VA_Planung""," & _
               """VA_ID="" & [tbl_VA_Auftragstamm].[ID] & " & _
               """ AND VADatum_ID="" & [tbl_VA_AnzTage].[ID] & " & _
               """ AND Rueckmeldezeitpunkt Is Null"") > 0"
    
    Set fc = ctl.FormatConditions.Add(acExpression, , strExpr1)
    fc.ForeColor = RGB(0, 0, 255)      ' Blau
    fc.backColor = RGB(255, 255, 255)  ' Weiß
    
    Debug.Print "✓ Bedingung 1 hinzugefügt: Offene Anfragen → Blau"
    Debug.Print "  Expression: " & strExpr1
    
    ' ---------------------------------------------------------------
    ' BEDINGUNG 2: Keine offenen Anfragen UND Ist < Soll → ROT
    ' ---------------------------------------------------------------
    ' Diese Bedingung greift nur, wenn:
    ' - Der Ist-Wert kleiner als der Soll-Wert ist UND
    ' - Keine offenen Anfragen mehr existieren
    
    strExpr2 = "[Ist] < [Soll] AND " & _
               "DCount(""*"",""tbl_MA_VA_Planung""," & _
               """VA_ID="" & [tbl_VA_Auftragstamm].[ID] & " & _
               """ AND VADatum_ID="" & [tbl_VA_AnzTage].[ID] & " & _
               """ AND Rueckmeldezeitpunkt Is Null"") = 0"
    
    Set fc = ctl.FormatConditions.Add(acExpression, , strExpr2)
    fc.ForeColor = RGB(255, 0, 0)      ' Rot
    fc.backColor = RGB(255, 255, 255)  ' Weiß
    
    Debug.Print "✓ Bedingung 2 hinzugef�t: Keine Anfragen + Ist < Soll → Rot"
    Debug.Print "  Expression: " & strExpr2
    
    ' Formular speichern und schließen
    DoCmd.Close acForm, "frm_lst_row_auftrag", acSaveYes
    
    Debug.Print vbCrLf & "=== �NDERUNGEN ERFOLGREICH GESPEICHERT ==="
    MsgBox "Die bedingte Formatierung wurde erfolgreich aktualisiert!" & vbCrLf & vbCrLf & _
           "Neue Regeln:" & vbCrLf & _
           "• Blau = Offene Mitarbeiteranfragen" & vbCrLf & _
           "• Rot = Keine Anfragen + Ist < Soll" & vbCrLf & _
           "• Schwarz = Alles vollst�ndig", _
           vbInformation, "Bedingte Formatierung aktualisiert"
    
Exit_Handler:
    Exit Sub
    
Err_Handler:
    MsgBox "Fehler " & Err.Number & ": " & Err.description, vbCritical
    Resume Exit_Handler
    
End Sub

' ======================================================================
' Test-Funktion: Zeigt die aktuelle Formatierung an (ohne Änderungen)
' ======================================================================
Sub Show_Current_Formatting()
    On Error GoTo Err_Handler
    
    Dim frm As Form
    Dim ctl As control
    
    DoCmd.OpenForm "frm_lst_row_auftrag", acDesign
    Set frm = Forms("frm_lst_row_auftrag")
    Set ctl = frm.Controls("Ist")
    
    Debug.Print "=== AKTUELLE BEDINGTE FORMATIERUNG ==="
    Debug.Print "Feldname: " & ctl.Name
    Debug.Print "Anzahl Bedingungen: " & ctl.FormatConditions.Count
    
    Dim i As Integer
    For i = 0 To ctl.FormatConditions.Count - 1
        Debug.Print vbCrLf & "--- Bedingung " & (i + 1) & " ---"
        Debug.Print "Type: " & ctl.FormatConditions(i).Type
        On Error Resume Next
        Debug.Print "Operator: " & ctl.FormatConditions(i).Operator
        Debug.Print "Expression1: " & ctl.FormatConditions(i).Expression1
        Debug.Print "Expression2: " & ctl.FormatConditions(i).Expression2
        Debug.Print "ForeColor: " & ctl.FormatConditions(i).ForeColor
        Debug.Print "BackColor: " & ctl.FormatConditions(i).backColor
        On Error GoTo Err_Handler
    Next i
    
    DoCmd.Close acForm, "frm_lst_row_auftrag", acSaveNo
    
    MsgBox "Formatierungs-Details wurden ins Direktfenster ausgegeben.", vbInformation
    
Exit_Handler:
    Exit Sub
    
Err_Handler:
    MsgBox "Fehler " & Err.Number & ": " & Err.description, vbCritical
    DoCmd.Close acForm, "frm_lst_row_auftrag", acSaveNo
    Resume Exit_Handler
    
End Sub

' ======================================================================
' ANLEITUNG ZUR VERWENDUNG
' ======================================================================
'
' 1. Dieses Modul in die Access-Datenbank importieren:
'    - Access öffnen: Consys_FE_N_Test_Claude_GPT.accdb
'    - Alt+F11 für VBA-Editor
'    - Datei > Datei importieren
'    - Diese .bas-Datei auswählen
'
' 2. Funktion ausführen:
'    - Im VBA-Editor: Strg+G für Direktfenster
'    - Eingeben: Update_Ist_Conditional_Formatting
'    - Enter drücken
'
' 3. Testen:
'    - Formular "frm_lst_row_auftrag" öffnen
'    - Aufträge mit offenen Anfragen sollten blau erscheinen
'    - Aufträge ohne Anfragen aber Ist < Soll sollten rot erscheinen
'
' Hinweis: Die Funktion "Show_Current_Formatting" kann verwendet werden,
'          um die aktuellen Formatierungen anzuzeigen ohne sie zu ändern.
' ======================================================================
