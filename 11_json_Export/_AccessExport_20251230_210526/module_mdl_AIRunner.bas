Option Compare Database
Option Explicit

Public Sub AI_Log(ByVal msg As String)
    On Error Resume Next
    
    Dim ROOT As String, logDir As String, logFile As String
    ROOT = Environ$("USERPROFILE") & "\Documents\000_Runner"
    logDir = ROOT & "\logs"
    logFile = logDir & "\access_runner_log.txt"
    
    ' Ordner sicherstellen
    If Dir(ROOT, vbDirectory) = vbNullString Then MkDir ROOT
    If Dir(logDir, vbDirectory) = vbNullString Then MkDir logDir
    
    ' schreiben
    Dim f As Integer
    f = FreeFile
    Open logFile For Append As #f
        Print #f, Format$(Now, "dd.mm.yyyy HH:nn:ss") & "  " & msg
    Close #f
End Sub