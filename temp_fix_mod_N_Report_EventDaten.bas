' =====================================================
' mod_N_Report_EventDaten
' Report: rpt_N_EventDaten
' Beschreibung: Zeigt Eventdaten fuer eine Veranstaltung
' RecordSource: qry_N_EventDaten_Report
' KORRIGIERT: Me durch Reports-Referenz ersetzt
' =====================================================

' Oeffnet den Report mit optionalem VA_ID Filter
Public Sub OpenEventDatenReport(Optional VA_ID As Long = 0)
    On Error GoTo ErrorHandler

    Dim strFilter As String

    If VA_ID > 0 Then
        strFilter = "VA_ID = " & VA_ID
        DoCmd.OpenReport "rpt_N_EventDaten", acViewPreview, , strFilter
    Else
        DoCmd.OpenReport "rpt_N_EventDaten", acViewPreview
    End If

    Exit Sub

ErrorHandler:
    MsgBox "Fehler beim Oeffnen des Reports:" & vbCrLf & Err.Description, vbExclamation
End Sub

' Druckt den Report direkt
Public Sub PrintEventDatenReport(Optional VA_ID As Long = 0)
    On Error GoTo ErrorHandler

    Dim strFilter As String

    If VA_ID > 0 Then
        strFilter = "VA_ID = " & VA_ID
        DoCmd.OpenReport "rpt_N_EventDaten", acViewNormal, , strFilter
    Else
        DoCmd.OpenReport "rpt_N_EventDaten", acViewNormal
    End If

    Exit Sub

ErrorHandler:
    MsgBox "Fehler beim Drucken des Reports:" & vbCrLf & Err.Description, vbExclamation
End Sub

' Setzt Filter auf geoeffnetem Report (falls Report bereits offen)
Public Sub SetEventDatenFilter(VA_ID As Long)
    On Error Resume Next

    Dim rpt As Report
    Set rpt = Reports("rpt_N_EventDaten")

    If Not rpt Is Nothing Then
        If VA_ID > 0 Then
            rpt.Filter = "VA_ID = " & VA_ID
            rpt.FilterOn = True
        Else
            rpt.FilterOn = False
        End If
    End If

    Set rpt = Nothing
End Sub

' Holt aktuellen VA_ID aus TempVars oder CurrentDb.Properties
Public Function GetCurrentVA_ID() As Long
    On Error Resume Next

    ' Erst TempVars pruefen
    GetCurrentVA_ID = TempVars("VA_ID").Value

    ' Falls nicht vorhanden, CurrentDb.Properties pruefen
    If GetCurrentVA_ID = 0 Then
        GetCurrentVA_ID = CurrentDb.Properties("VA_ID").Value
    End If

    On Error GoTo 0
End Function
