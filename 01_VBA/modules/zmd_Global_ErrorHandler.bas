Attribute VB_Name = "zmd_Global_ErrorHandler"
Option Compare Database
Option Explicit



' Globaler Error Handler - fängt ALLE Fehler ab
Public Function GlobalErrorHandler() As Boolean
    On Error Resume Next
    GlobalErrorHandler = True
End Function

' Auto-Execute beim Start
Public Function AutoExec()
    On Error Resume Next
    DoCmd.SetWarnings False
End Function

