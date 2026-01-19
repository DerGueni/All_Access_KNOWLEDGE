Attribute VB_Name = "mod_N_Report_EventDaten"
Option Compare Database
Option Explicit


' Report: rpt_N_EventDaten
' Beschreibung: Zeigt Eventdaten für eine Veranstaltung
' RecordSource: qry_N_EventDaten_Report

Private Sub Report_Open(Cancel As Integer)
    Dim VA_ID As Long

    On Error Resume Next
    VA_ID = CurrentDb.Properties("prp_EventDaten_VA_ID")
    On Error GoTo 0

    If VA_ID > 0 Then
        Me.filter = "VA_ID = " & VA_ID
        Me.FilterOn = True
    End If
End Sub

Private Sub Report_Close()
    ' Filter zurücksetzen
    On Error Resume Next
    CurrentDb.Properties.Delete "prp_EventDaten_VA_ID"
End Sub

