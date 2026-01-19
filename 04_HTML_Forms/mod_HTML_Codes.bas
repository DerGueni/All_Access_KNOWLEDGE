Attribute VB_Name = "mod_HTML_Codes"
Option Compare Database
Option Explicit

Private Const HTML_CODES_MODE As String = "external" ' set to "embedded" to use WebHost
Private Const HTML_CODES_SHELL_URL As String = "http://localhost:8080/forms/_Codes/shell.html"
Private Const OPEN_SHELL_SCRIPT As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\open_html_shell_codes.pyw"
Private Const START_API_SCRIPT As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\start_api_server_hidden.vbs"
Private Const START_HTTP_SCRIPT As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\start_http_server.bat"

Public Sub OpenHtmlShell_Codes(Optional formId As String = "auftragstamm")
    If LCase$(HTML_CODES_MODE) = "embedded" Then
        OpenHtmlShell_Codes_Embedded formId
    Else
        OpenHtmlShell_Codes_External formId
    End If
End Sub

Public Sub OpenHtmlShell_Codes_External(Optional formId As String = "auftragstamm")
    StartHtmlServers
    Shell "cmd /c start """" """ & OPEN_SHELL_SCRIPT & """ " & formId, vbHide
End Sub

Public Sub OpenHtmlShell_Codes_Embedded(Optional formId As String = "auftragstamm")
    StartHtmlServers
    EnsureWebHostCodesForm
    DoCmd.OpenForm "frm_N_WebHost_Codes", , , , , , HTML_CODES_SHELL_URL & "?form=" & formId
End Sub

Private Sub StartHtmlServers()
    Shell "cmd /c start """" """ & START_API_SCRIPT & """", vbHide
    Shell "cmd /c start """" """ & START_HTTP_SCRIPT & """", vbHide
End Sub

Public Sub EnsureWebHostCodesForm()
    Dim formName As String
    formName = "frm_N_WebHost_Codes"

    If FormExists(formName) Then Exit Sub

    Dim frm As Form
    Set frm = Application.CreateForm

    frm.Caption = "HTML WebHost (Codes)"
    frm.DefaultView = 0
    frm.ScrollBars = 0
    frm.RecordSelectors = False
    frm.NavigationButtons = False
    frm.DividingLines = False
    frm.AutoCenter = True
    frm.PopUp = False
    frm.Modal = False
    frm.BorderStyle = 1
    frm.Width = 18000
    frm.Height = 12000

    Dim ctl As Control
    Set ctl = Application.CreateControl(frm.Name, 123, 0, "", "", 0, 0, frm.InsideWidth, frm.InsideHeight)
    ctl.Name = "ctlWebBrowser"

    Dim tempName As String
    tempName = frm.Name
    DoCmd.Save acForm, tempName
    DoCmd.Close acForm, tempName, acSaveYes

    DoCmd.Rename formName, acForm, tempName

    DoCmd.OpenForm formName, acDesign
    DoCmd.Close acForm, formName, acSaveYes

    SetFormEvents formName
End Sub

Private Sub SetFormEvents(formName As String)
    On Error Resume Next
    DoCmd.OpenForm formName, acDesign
    Dim frm As Form
    Set frm = Forms(formName)
    frm.OnLoad = "=WebHostCodes_Load()"
    frm.OnResize = "=WebHostCodes_Resize()"
    DoCmd.Close acForm, formName, acSaveYes
End Sub

Public Function WebHostCodes_Load()
    On Error Resume Next
    Dim frm As Form
    Set frm = Screen.ActiveForm
    If frm Is Nothing Then Exit Function

    Dim targetUrl As String
    targetUrl = HTML_CODES_SHELL_URL
    If Len(Nz(frm.OpenArgs, "")) > 0 Then
        targetUrl = frm.OpenArgs
    End If

    frm!ctlWebBrowser.Object.Navigate targetUrl
End Function

Public Function WebHostCodes_Resize()
    On Error Resume Next
    Dim frm As Form
    Set frm = Screen.ActiveForm
    If frm Is Nothing Then Exit Function
    frm!ctlWebBrowser.Width = frm.InsideWidth
    frm!ctlWebBrowser.Height = frm.InsideHeight
End Function

Private Function FormExists(formName As String) As Boolean
    Dim obj As AccessObject
    For Each obj In CurrentProject.AllForms
        If obj.Name = formName Then
            FormExists = True
            Exit Function
        End If
    Next obj
    FormExists = False
End Function
