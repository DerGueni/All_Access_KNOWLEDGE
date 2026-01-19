Option Compare Database
Option Explicit

Function DelRecord()
On Error Resume Next
If vbYes = MsgBox("Datensatz löschen?", vbQuestion + vbYesNo) Then
    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents
    DoCmd.SetWarnings False
    DoCmd.RunCommand acCmdDeleteRecord
    DoCmd.SetWarnings True
End If
End Function