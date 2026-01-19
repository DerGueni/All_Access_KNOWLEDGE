
' =====================================================
' WebView2 COM-Wrapper Test Modul
' =====================================================

Private wvHost As Object

Public Sub WebView2_Test()
    On Error GoTo ErrHandler

    Debug.Print "Erstelle WebView2Host..."
    Set wvHost = CreateObject("Consys.WebView2Host")
    Debug.Print "Objekt erstellt!"

    Debug.Print "Initialisiere WebView2..."
    If wvHost.Initialize() Then
        Debug.Print "WebView2 erfolgreich initialisiert!"

        Debug.Print "Navigiere zu Test-Seite..."
        wvHost.Navigate "S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\HTML\webview2_test.html"

        Debug.Print "Zeige Fenster..."
        wvHost.Show

        Debug.Print "ERFOLG! WebView2 ist aktiv."
    Else
        Debug.Print "FEHLER bei Initialisierung: " & wvHost.LastError
    End If
    Exit Sub

ErrHandler:
    Debug.Print "VBA FEHLER: " & Err.Number & " - " & Err.description
End Sub

Public Sub WebView2_OpenHTML(htmlPath As String)
    On Error GoTo ErrHandler

    If Dir(htmlPath) = "" Then
        Debug.Print "FEHLER: Datei nicht gefunden: " & htmlPath
        Exit Sub
    End If

    Debug.Print "Erstelle WebView2Host..."
    Set wvHost = CreateObject("Consys.WebView2Host")

    Debug.Print "Initialisiere..."
    If wvHost.Initialize() Then
        Debug.Print "Navigiere zu: " & htmlPath
        wvHost.Navigate htmlPath
        wvHost.Show
        Debug.Print "HTML-Formular wird angezeigt."
    Else
        Debug.Print "FEHLER: " & wvHost.LastError
    End If
    Exit Sub

ErrHandler:
    Debug.Print "VBA FEHLER: " & Err.Number & " - " & Err.description
End Sub

Public Sub WebView2_Close()
    On Error Resume Next
    If Not wvHost Is Nothing Then
        wvHost.Close
        Set wvHost = Nothing
        Debug.Print "WebView2 geschlossen."
    End If
End Sub

Public Function WebView2_IsReady() As Boolean
    On Error Resume Next
    If wvHost Is Nothing Then
        WebView2_IsReady = False
    Else
        WebView2_IsReady = wvHost.IsInitialized
    End If
End Function