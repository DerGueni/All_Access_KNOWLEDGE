Attribute VB_Name = "mod_N_WebView2_COM"
'=====================================================
' Modul: mod_N_WebView2_COM
' Beschreibung: Oeffnet HTML-Formulare via WebView2 COM
' Version: 3.1 - NUR COM, keine EXE!
' Erstellt: 2026-01-04
'
' WICHTIG: Das COM-Objekt wird in einer Modul-Variablen
'          gehalten, damit es nicht vorzeitig disposed wird!
'=====================================================

' Pfade zu den HTML-Formularen
Private Const HTML_FORMS3 As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\"
Private Const HTML_FORMS As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\"

' Fenstergroesse
Private Const WIN_WIDTH As Long = 1600
Private Const WIN_HEIGHT As Long = 1000

' WICHTIG: COM-Objekt auf Modul-Ebene halten!
Private m_WebView As Object

'=====================================================
' OEFFENTLICHE FUNKTIONEN
'=====================================================

Public Function OpenHTML_Auftragstamm(Optional VA_ID As Long = 0) As Boolean
    OpenHTML_Auftragstamm = OpenHTMLviaCOM("frm_va_Auftragstamm", VA_ID, "Auftragsverwaltung")
End Function

Public Function OpenHTML_Mitarbeiterstamm(Optional MA_ID As Long = 0) As Boolean
    OpenHTML_Mitarbeiterstamm = OpenHTMLviaCOM("frm_MA_Mitarbeiterstamm", MA_ID, "Mitarbeiterverwaltung")
End Function

Public Function OpenHTML_Kundenstamm(Optional KD_ID As Long = 0) As Boolean
    OpenHTML_Kundenstamm = OpenHTMLviaCOM("frm_KD_Kundenstamm", KD_ID, "Kundenverwaltung")
End Function

Public Function OpenHTML_Objekt(Optional OB_ID As Long = 0) As Boolean
    OpenHTML_Objekt = OpenHTMLviaCOM("frm_OB_Objekt", OB_ID, "Objektverwaltung")
End Function

Public Function OpenHTML_Dienstplan() As Boolean
    OpenHTML_Dienstplan = OpenHTMLviaCOM("frm_N_Dienstplanuebersicht", 0, "Dienstplanuebersicht")
End Function

Public Function OpenHTML_Form(formName As String, Optional recordId As Long = 0) As Boolean
    OpenHTML_Form = OpenHTMLviaCOM(formName, recordId, formName)
End Function

'=====================================================
' HAUPTFUNKTION - Oeffnet HTML via COM
'=====================================================
Private Function OpenHTMLviaCOM(formName As String, recordId As Long, WindowTitle As String) As Boolean
    On Error GoTo ErrorHandler
    
    Dim htmlPath As String
    Dim httpUrl As String
    Dim jsonData As String
    
    ' 1. HTML-Pfad pruefen ob Datei existiert
    htmlPath = FindHTMLFile(formName)
    If Len(htmlPath) = 0 Then
        MsgBox "HTML nicht gefunden: " & formName & ".html", vbCritical, "Fehler"
        OpenHTMLviaCOM = False
        Exit Function
    End If
    
    ' 2. API-Server starten (WICHTIG fuer Daten!)
    mod_N_WebView2_forms3.StartAPIServerIfNeeded
    
    ' 3. HTTP-URL bauen statt lokaler Pfad!
    httpUrl = "http://localhost:5000/shell.html?form=" & formName
    If recordId > 0 Then httpUrl = httpUrl & "&id=" & recordId
    
    Debug.Print "[mod_N_WebView2_COM] HTTP-URL: " & httpUrl
    
    ' 4. JSON-Daten vorbereiten
    jsonData = "{""form"":""" & formName & """,""id"":" & recordId & "}"
    
    ' 5. COM-Objekt erstellen
    On Error Resume Next
    If Not m_WebView Is Nothing Then
        m_WebView.CloseForm
        Set m_WebView = Nothing
        DoEvents
    End If
    
    Set m_WebView = CreateObject("ConsysWebView2.WebFormHost")
    
    If Err.Number <> 0 Then
        Debug.Print "[mod_N_WebView2_COM] COM-Fehler: " & Err.description
        On Error GoTo 0
        ' Fallback: Im Browser oeffnen (mit HTTP-URL!)
        Shell "cmd /c start """" """ & httpUrl & """", vbHide
        OpenHTMLviaCOM = True
        Exit Function
    End If
    On Error GoTo ErrorHandler
    
    ' 6. Formular via COM mit HTTP-URL oeffnen
    Debug.Print "[mod_N_WebView2_COM] Oeffne via COM: " & httpUrl
    
    If recordId > 0 Then
        m_WebView.ShowFormWithData httpUrl, "CONSYS - " & WindowTitle, WIN_WIDTH, WIN_HEIGHT, jsonData
    Else
        m_WebView.ShowForm httpUrl, "CONSYS - " & WindowTitle, WIN_WIDTH, WIN_HEIGHT
    End If
    
    Debug.Print "[mod_N_WebView2_COM] Erfolgreich geoeffnet!"
    OpenHTMLviaCOM = True
    Exit Function
    
ErrorHandler:
    MsgBox "Fehler: " & Err.description, vbCritical, "WebView2 Fehler"
    Debug.Print "[mod_N_WebView2_COM] FEHLER: " & Err.description
    OpenHTMLviaCOM = False
End Function

'=====================================================
' SCHLIESSEN
'=====================================================
Public Sub CloseWebView()
    On Error Resume Next
    If Not m_WebView Is Nothing Then
        m_WebView.CloseForm
        Set m_WebView = Nothing
    End If
End Sub

'=====================================================
' HILFSFUNKTIONEN
'=====================================================

Private Function FindHTMLFile(formName As String) As String
    Dim testPath As String

    ' Zuerst in forms3 suchen
    testPath = HTML_FORMS3 & formName & ".html"
    If Dir(testPath) <> "" Then
        FindHTMLFile = testPath
        Exit Function
    End If

    ' Dann in forms suchen
    testPath = HTML_FORMS & formName & ".html"
    If Dir(testPath) <> "" Then
        FindHTMLFile = testPath
        Exit Function
    End If

    ' Nicht gefunden
    FindHTMLFile = ""
End Function

Private Sub OpenInBrowser(htmlPath As String, recordId As Long)
    Dim url As String

    url = "file:///" & Replace(htmlPath, "\", "/")
    If recordId > 0 Then
        url = url & "?id=" & recordId
    End If

    Shell "cmd /c start """" """ & url & """", vbHide

    MsgBox "WebView2 COM nicht verfuegbar." & vbCrLf & _
           "Formular wird im Browser geoeffnet." & vbCrLf & vbCrLf & _
           "Hinweis: Im Browser keine Echtdaten!", vbExclamation, "Fallback"
End Sub

'=====================================================
' TEST
'=====================================================
Public Sub Test_OpenHTML()
    Debug.Print "=== TEST START ==="
    OpenHTML_Auftragstamm 0
    Debug.Print "=== TEST ENDE ==="
End Sub
