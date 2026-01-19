Attribute VB_Name = "mod_N_HTMLAnsicht_Watchdog"
Option Compare Database
Option Explicit

#If VBA7 Then
    Private Declare PtrSafe Sub Sleep Lib "kernel32" (ByVal ms As LongPtr)
#Else
    Private Declare Sub Sleep Lib "kernel32" (ByVal ms As Long)
#End If

Private Const WATCHDOG_PATH As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python\START_API_WATCHDOG_SILENT.vbs"
Private Const SHELL_URL As String = "http://localhost:8080/shell.html"

Public Sub HTMLAnsicht_Watchdog()
    Dim sh As Object
    Set sh = CreateObject("WScript.Shell")

    sh.Run Chr(34) & WATCHDOG_PATH & Chr(34), 0, False
    Sleep 5000
    sh.Run "cmd /c start " & Chr(34) & Chr(34) & " " & Chr(34) & SHELL_URL & Chr(34), 0, False

    Set sh = Nothing
End Sub

Public Sub Test_Server()
    Dim http As Object
    Set http = CreateObject("MSXML2.XMLHTTP")

    On Error Resume Next
    http.Open "GET", "http://localhost:5000/api/health", False
    http.Send

    If http.Status = 200 Then
        MsgBox "Server LAEUFT!", vbInformation
    Else
        MsgBox "Server NICHT erreichbar", vbExclamation
    End If

    Set http = Nothing
End Sub

Public Sub Stop_Watchdog()
    Dim sh As Object
    Set sh = CreateObject("WScript.Shell")
    sh.Run "taskkill /F /IM python.exe", 0, True
    MsgBox "Watchdog gestoppt", vbInformation
    Set sh = Nothing
End Sub
