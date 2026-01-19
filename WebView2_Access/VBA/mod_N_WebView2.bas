' =============================================================================
' mod_N_WebView2 - WebView2-Integration fuer Access 2021 (64-Bit)
' =============================================================================
' Steuert WebView2-Host und lokalen API-Server.
' Ermoeglicht Anzeige moderner HTML-Formulare in Access.
'
' Autor: Claude Code
' Version: 1.0
' =============================================================================

' API-Deklarationen fuer 64-Bit
#If VBA7 Then
    Private Declare PtrSafe Function ShellExecute Lib "shell32.dll" Alias "ShellExecuteA" _
        (ByVal hwnd As LongPtr, ByVal lpOperation As String, ByVal lpFile As String, _
         ByVal lpParameters As String, ByVal lpDirectory As String, ByVal nShowCmd As Long) As LongPtr

    Private Declare PtrSafe Function FindWindow Lib "user32" Alias "FindWindowA" _
        (ByVal lpClassName As String, ByVal lpWindowName As String) As LongPtr

    Private Declare PtrSafe Function SetParent Lib "user32" _
        (ByVal hWndChild As LongPtr, ByVal hWndNewParent As LongPtr) As LongPtr

    Private Declare PtrSafe Function MoveWindow Lib "user32" _
        (ByVal hwnd As LongPtr, ByVal x As Long, ByVal y As Long, _
         ByVal nWidth As Long, ByVal nHeight As Long, ByVal bRepaint As Long) As Long

    Private Declare PtrSafe Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)

    Private Declare PtrSafe Function CreateObject Lib "oleaut32" Alias "CreateObjectA" _
        (ByVal lpClassName As String) As Object
#Else
    ' 32-Bit nicht unterstuetzt
#End If

' Konstanten
Private Const API_SERVER_PATH As String = "C:\Users\guenther.siegert\Documents\WebView2_Access\API\api_server_wv2.py"
Private Const API_BASE_URL As String = "http://127.0.0.1:5000"
Private Const PYTHON_PATH As String = "python"

' Modul-Variablen
Private m_WebViewHost As Object         ' WebView2 COM-Objekt
Private m_ServerPID As Long             ' PID des API-Servers
Private m_IsServerRunning As Boolean    ' Server-Status

' =============================================================================
' SERVER-STEUERUNG
' =============================================================================

Public Sub WV2_StartServer()
    ' Startet den lokalen API-Server
    On Error GoTo ErrHandler

    If WV2_IsServerRunning() Then
        Debug.Print "API-Server laeuft bereits."
        Exit Sub
    End If

    ' Python-Prozess starten (minimiert)
    Dim cmd As String
    cmd = "cmd /c start /min python """ & API_SERVER_PATH & """"

    Shell cmd, vbMinimizedNoFocus

    ' Warten bis Server bereit
    Dim i As Integer
    For i = 1 To 30  ' Max 30 Sekunden
        Sleep 1000
        If WV2_IsServerRunning() Then
            Debug.Print "API-Server gestartet nach " & i & " Sekunden."
            m_IsServerRunning = True
            Exit Sub
        End If
    Next i

    MsgBox "API-Server konnte nicht gestartet werden!", vbCritical
    Exit Sub

ErrHandler:
    Debug.Print "Fehler in WV2_StartServer: " & Err.Description
End Sub

Public Sub WV2_StopServer()
    ' Stoppt den API-Server
    On Error Resume Next

    ' Alle Python-Prozesse mit api_server beenden
    Shell "taskkill /F /IM python.exe /FI ""WINDOWTITLE eq api_server*""", vbHide

    m_IsServerRunning = False
    Debug.Print "API-Server gestoppt."
End Sub

Public Function WV2_IsServerRunning() As Boolean
    ' Prueft ob API-Server erreichbar ist
    On Error GoTo NotRunning

    Dim http As Object
    Set http = CreateObject("MSXML2.XMLHTTP")

    http.Open "GET", API_BASE_URL & "/api/health", False
    http.setRequestHeader "Content-Type", "application/json"
    http.send

    WV2_IsServerRunning = (http.Status = 200)
    Set http = Nothing
    Exit Function

NotRunning:
    WV2_IsServerRunning = False
End Function

' =============================================================================
' WEBVIEW2-STEUERUNG (via COM-Wrapper)
' =============================================================================

Public Function WV2_CreateHost() As Object
    ' Erstellt neuen WebView2-Host
    On Error GoTo ErrHandler

    Set m_WebViewHost = CreateObject("Consys.WebView2Host")
    Set WV2_CreateHost = m_WebViewHost
    Exit Function

ErrHandler:
    Debug.Print "Fehler beim Erstellen des WebView2-Hosts: " & Err.Description
    Set WV2_CreateHost = Nothing
End Function

Public Sub WV2_Navigate(ByVal url As String)
    ' Navigiert zu URL
    If m_WebViewHost Is Nothing Then
        Set m_WebViewHost = WV2_CreateHost()
    End If

    If Not m_WebViewHost Is Nothing Then
        m_WebViewHost.Navigate url
    End If
End Sub

Public Sub WV2_NavigateToForm(ByVal formName As String, Optional ByVal params As String = "")
    ' Oeffnet HTML-Formular
    Dim url As String
    url = API_BASE_URL & "/forms/" & formName & ".html"

    If Len(params) > 0 Then
        url = url & "?" & params
    End If

    WV2_Navigate url
End Sub

' =============================================================================
' ALTERNATIVE: BROWSER-BASIERTE LOESUNG (ohne COM)
' =============================================================================

Public Sub WV2_OpenInBrowser(ByVal formName As String, Optional ByVal params As String = "")
    ' Oeffnet HTML-Formular im Standard-Browser
    ' Einfachere Alternative ohne COM-Registrierung
    On Error GoTo ErrHandler

    ' Server sicherstellen
    If Not WV2_IsServerRunning() Then
        WV2_StartServer
    End If

    Dim url As String
    url = API_BASE_URL & "/forms/" & formName & ".html"

    If Len(params) > 0 Then
        url = url & "?" & params
    End If

    ' Im Standard-Browser oeffnen
    ShellExecute 0, "open", url, vbNullString, vbNullString, 1

    Exit Sub

ErrHandler:
    MsgBox "Fehler: " & Err.Description, vbCritical
End Sub

' =============================================================================
' DATENZUGRIFF VIA REST-API
' =============================================================================

Public Function WV2_LoadData(ByVal tableName As String, Optional ByVal recordId As Variant) As String
    ' Laedt Daten via REST-API
    On Error GoTo ErrHandler

    Dim http As Object
    Dim url As String

    Set http = CreateObject("MSXML2.XMLHTTP")

    url = API_BASE_URL & "/api/load?table=" & tableName
    If Not IsMissing(recordId) Then
        url = url & "&id=" & recordId
    End If

    http.Open "GET", url, False
    http.setRequestHeader "Content-Type", "application/json"
    http.send

    If http.Status = 200 Then
        WV2_LoadData = http.responseText
    Else
        WV2_LoadData = "{""success"":false,""error"":""HTTP " & http.Status & """}"
    End If

    Set http = Nothing
    Exit Function

ErrHandler:
    WV2_LoadData = "{""success"":false,""error"":""" & Err.Description & """}"
End Function

Public Function WV2_SaveData(ByVal tableName As String, ByVal jsonData As String, Optional ByVal recordId As Variant) As String
    ' Speichert Daten via REST-API
    On Error GoTo ErrHandler

    Dim http As Object
    Dim postData As String

    Set http = CreateObject("MSXML2.XMLHTTP")

    ' JSON-Body bauen
    postData = "{""table"":""" & tableName & """,""data"":" & jsonData
    If Not IsMissing(recordId) Then
        postData = postData & ",""id"":" & recordId
    End If
    postData = postData & "}"

    http.Open "POST", API_BASE_URL & "/api/save", False
    http.setRequestHeader "Content-Type", "application/json"
    http.send postData

    WV2_SaveData = http.responseText
    Set http = Nothing
    Exit Function

ErrHandler:
    WV2_SaveData = "{""success"":false,""error"":""" & Err.Description & """}"
End Function

' =============================================================================
' HILFSFUNKTIONEN
' =============================================================================

Public Sub WV2_Test()
    ' Testfunktion
    Debug.Print "=== WebView2 Test ==="
    Debug.Print "Server laeuft: " & WV2_IsServerRunning()

    If Not WV2_IsServerRunning() Then
        Debug.Print "Starte Server..."
        WV2_StartServer
    End If

    Debug.Print "Lade Mitarbeiter..."
    Debug.Print WV2_LoadData("tbl_MA_Mitarbeiterstamm")

    Debug.Print "=== Test Ende ==="
End Sub

Public Sub WV2_OpenTestForm()
    ' Oeffnet Test-Formular im Browser
    WV2_OpenInBrowser "frm_MA_Mitarbeiterstamm"
End Sub
