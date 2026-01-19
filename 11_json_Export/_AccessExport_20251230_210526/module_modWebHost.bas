Option Compare Database
Option Explicit



Public Sub WebHost_LoadPing(ByVal frm As Form)
    NavigateToLocalHtml frm, "web\ping.html"
End Sub

Public Sub WebHost_LoadIndex(ByVal frm As Form, Optional ByVal formName As String = "frm_va_Auftragstamm")
    NavigateToLocalHtml frm, "web\index.html?form=" & formName
End Sub

Public Sub NavigateToLocalHtml(ByVal frm As Form, ByVal relativePathAndQuery As String)
    Dim fullPath As String
    fullPath = CurrentProject.path & "\" & relativePathAndQuery

    If Dir(fullPath) = "" Then
        MsgBox "HTML-Datei nicht gefunden:" & vbCrLf & fullPath, vbExclamation
        Exit Sub
    End If

    ' Erwarteter Control-Name im frm_WebHost: webHost
    frm!webHost.Navigate "file:///" & ToFileUrl(fullPath)
End Sub

Private Function ToFileUrl(ByVal windowsPath As String) As String
    Dim s As String
    s = Replace(windowsPath, "\", "/")
    s = Replace(s, " ", "%20")
    ToFileUrl = s
End Function