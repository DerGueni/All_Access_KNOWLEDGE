Attribute VB_Name = "mod_N_Report_Eventdaten"
' ========================================================================
' Modul: mod_N_Report_Eventdaten
' Report: rpt_N_EventDaten
' Beschreibung: Zeigt Eventdaten fuer eine Veranstaltung
' RecordSource: qry_N_EventDaten_Report
' Korrigiert: 2026-01-05
' ========================================================================

' ========================================================================
' Report oeffnen mit VA_ID
' ========================================================================
Public Sub OpenEventDatenReport(VA_ID As Long)
    On Error GoTo ErrorHandler

    ' VA_ID als Property speichern fuer Report
    On Error Resume Next
    CurrentDb.Properties.Delete "prp_EventDaten_VA_ID"
    On Error GoTo ErrorHandler

    CurrentDb.Properties.Append CurrentDb.CreateProperty("prp_EventDaten_VA_ID", dbLong, VA_ID)

    ' Report oeffnen
    DoCmd.OpenReport "rpt_N_EventDaten", acViewPreview

    Exit Sub

ErrorHandler:
    MsgBox "Fehler beim Oeffnen des Reports: " & Err.Description, vbExclamation
End Sub

' ========================================================================
' Report_Open Event (Code fuer Report-Klassenmodul)
' Hinweis: Dieser Code muss in das Klassenmodul des Reports kopiert werden
' ========================================================================
' Private Sub Report_Open(Cancel As Integer)
'     Dim VA_ID As Long
'
'     On Error Resume Next
'     VA_ID = CurrentDb.Properties("prp_EventDaten_VA_ID")
'     On Error GoTo 0
'
'     If VA_ID > 0 Then
'         Me.Filter = "VA_ID = " & VA_ID
'         Me.FilterOn = True
'     End If
' End Sub

' ========================================================================
' Report_Close Event (Code fuer Report-Klassenmodul)
' Hinweis: Dieser Code muss in das Klassenmodul des Reports kopiert werden
' ========================================================================
' Private Sub Report_Close()
'     ' Filter zuruecksetzen
'     On Error Resume Next
'     CurrentDb.Properties.Delete "prp_EventDaten_VA_ID"
' End Sub

' ========================================================================
' Direkter Aufruf ohne Property (Alternative)
' ========================================================================
Public Sub OpenEventDatenReportDirect(VA_ID As Long)
    On Error GoTo ErrorHandler

    Dim strFilter As String

    If VA_ID > 0 Then
        strFilter = "VA_ID = " & VA_ID
    End If

    DoCmd.OpenReport "rpt_N_EventDaten", acViewPreview, , strFilter

    Exit Sub

ErrorHandler:
    MsgBox "Fehler beim Oeffnen des Reports: " & Err.Description, vbExclamation
End Sub
