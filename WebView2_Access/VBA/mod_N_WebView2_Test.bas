Attribute VB_Name = "mod_N_WebView2_Test"
' =====================================================
' WebView2 COM-Wrapper Test Modul
' =====================================================
' Verwendung:
'   WebView2_Test - Testet die grundlegende WebView2-Funktionalität
'   WebView2_OpenHTML - Öffnet eine lokale HTML-Datei
' =====================================================

Private wvHost As Object

Public Sub WebView2_Test()
    ' WebView2 COM-Objekt erstellen und testen

    On Error GoTo ErrHandler

    ' Objekt erstellen
    Debug.Print "Erstelle WebView2Host..."
    Set wvHost = CreateObject("Consys.WebView2Host")
    Debug.Print "Objekt erstellt!"

    ' Initialisieren (wichtig!)
    Debug.Print "Initialisiere WebView2..."
    If wvHost.Initialize() Then
        Debug.Print "WebView2 erfolgreich initialisiert!"

        ' Zu einer URL navigieren
        Debug.Print "Navigiere zu Google..."
        wvHost.Navigate "https://www.google.de"

        ' Fenster anzeigen
        Debug.Print "Zeige Fenster..."
        wvHost.Show

        Debug.Print "ERFOLG! WebView2 ist aktiv."
    Else
        Debug.Print "FEHLER bei Initialisierung: " & wvHost.LastError
    End If

    Exit Sub

ErrHandler:
    Debug.Print "VBA FEHLER: " & Err.Number & " - " & Err.Description
End Sub

Public Sub WebView2_OpenHTML(Optional htmlPath As String = "")
    ' Öffnet eine lokale HTML-Datei im WebView2

    On Error GoTo ErrHandler

    ' Standard-Pfad wenn keiner angegeben
    If htmlPath = "" Then
        htmlPath = "S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\HTML\test_ie.html"
    End If

    ' Prüfen ob Datei existiert
    If Dir(htmlPath) = "" Then
        Debug.Print "FEHLER: Datei nicht gefunden: " & htmlPath
        Exit Sub
    End If

    ' Objekt erstellen
    Debug.Print "Erstelle WebView2Host..."
    Set wvHost = CreateObject("Consys.WebView2Host")

    ' Initialisieren
    Debug.Print "Initialisiere..."
    If wvHost.Initialize() Then
        Debug.Print "Navigiere zu: " & htmlPath
        wvHost.Navigate htmlPath
        wvHost.Show
        Debug.Print "HTML-Datei wird angezeigt."
    Else
        Debug.Print "FEHLER: " & wvHost.LastError
    End If

    Exit Sub

ErrHandler:
    Debug.Print "VBA FEHLER: " & Err.Number & " - " & Err.Description
End Sub

Public Sub WebView2_Close()
    ' Schliesst das WebView2-Fenster

    On Error Resume Next
    If Not wvHost Is Nothing Then
        wvHost.Close
        Set wvHost = Nothing
        Debug.Print "WebView2 geschlossen."
    End If
End Sub

Public Sub WebView2_ExecuteJS(jsCode As String)
    ' Führt JavaScript im WebView2 aus

    On Error GoTo ErrHandler

    If wvHost Is Nothing Then
        Debug.Print "FEHLER: Erst WebView2_Test oder WebView2_OpenHTML aufrufen!"
        Exit Sub
    End If

    If Not wvHost.IsInitialized Then
        Debug.Print "FEHLER: WebView2 nicht initialisiert!"
        Exit Sub
    End If

    Dim result As String
    result = wvHost.ExecuteScript(jsCode)
    Debug.Print "JS Ergebnis: " & result

    Exit Sub

ErrHandler:
    Debug.Print "VBA FEHLER: " & Err.Number & " - " & Err.Description
End Sub
