' DIAGNOSE-CODE für frm_N_MA_Monatsuebersicht
' Diesen Code in ein neues Modul einfügen und ausführen

Sub Diagnose_Formular_Controls()
    Dim frm As Form
    Dim ctrl As control
    Dim output As String
    
    On Error Resume Next
    
    ' Formular öffnen
    DoCmd.OpenForm "frm_N_MA_Monatsuebersicht", acDesign
    Set frm = forms("frm_N_MA_Monatsuebersicht")
    
    output = "FORMULAR: frm_N_MA_Monatsuebersicht" & vbCrLf & vbCrLf
    output = output & "═══════════════════════════════════════════════════════════════" & vbCrLf
    output = output & "KOMBINATIONSFELDER:" & vbCrLf
    output = output & "═══════════════════════════════════════════════════════════════" & vbCrLf
    
    For Each ctrl In frm.Controls
        If ctrl.ControlType = acComboBox Then
            output = output & vbCrLf & "• " & ctrl.Name & vbCrLf
            output = output & "  ControlSource: " & Nz(ctrl.ControlSource, "(keine)") & vbCrLf
            output = output & "  RowSource: " & Left(Nz(ctrl.RowSource, "(keine)"), 100) & vbCrLf
        End If
    Next ctrl
    
    output = output & vbCrLf & "═══════════════════════════════════════════════════════════════" & vbCrLf
    output = output & "UNTERFORMULARE:" & vbCrLf
    output = output & "═══════════════════════════════════════════════════════════════" & vbCrLf
    
    For Each ctrl In frm.Controls
        If ctrl.ControlType = acSubform Then
            output = output & vbCrLf & "• " & ctrl.Name & vbCrLf
            output = output & "  SourceObject: " & Nz(ctrl.SourceObject, "(keine)") & vbCrLf
            output = output & "  LinkMasterFields: " & Nz(ctrl.LinkMasterFields, "(keine)") & vbCrLf
            output = output & "  LinkChildFields: " & Nz(ctrl.LinkChildFields, "(keine)") & vbCrLf
        End If
    Next ctrl
    
    output = output & vbCrLf & "═══════════════════════════════════════════════════════════════" & vbCrLf
    output = output & "VBA-CODE:" & vbCrLf
    output = output & "═══════════════════════════════════════════════════════════════" & vbCrLf
    
    If frm.HasModule Then
        output = output & "Formular hat VBA-Modul: JA" & vbCrLf
        output = output & "Zeilen: " & frm.Module.CountOfLines & vbCrLf
        
        ' Erste 50 Zeilen
        If frm.Module.CountOfLines > 0 Then
            output = output & vbCrLf & "Erste 50 Zeilen:" & vbCrLf
            output = output & frm.Module.lines(1, IIf(frm.Module.CountOfLines > 50, 50, frm.Module.CountOfLines))
        End If
    Else
        output = output & "Formular hat VBA-Modul: NEIN" & vbCrLf
    End If
    
    ' In Datei speichern
    Dim fso As Object
    Dim txtFile As Object
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set txtFile = fso.CreateTextFile("C:\Users\guenther.siegert\Documents\Formular_Diagnose.txt", True)
    txtFile.Write output
    txtFile.Close
    
    ' Formular schließen
    DoCmd.Close acForm, "frm_N_MA_Monatsuebersicht", acSaveNo
    
    MsgBox "Diagnose abgeschlossen!" & vbCrLf & vbCrLf & _
           "Datei: C:\Users\guenther.siegert\Documents\Formular_Diagnose.txt", vbInformation
    
    ' Datei öffnen
    Shell "notepad.exe C:\Users\guenther.siegert\Documents\Formular_Diagnose.txt", vbNormalFocus
    
End Sub