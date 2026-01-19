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

Public Function OpenHTML_Form(FormName As String, Optional RecordID As Long = 0) As Boolean
    OpenHTML_Form = OpenHTMLviaCOM(FormName, RecordID, FormName)
End Function

'=====================================================
' HAUPTFUNKTION - Oeffnet HTML via COM
'=====================================================
Private Function OpenHTMLviaCOM(FormName As String, RecordID As Long, WindowTitle As String) As Boolean
    On Error GoTo ErrorHandler

    Dim htmlPath As String
    Dim jsonData As String

    ' 1. HTML-Pfad finden
    htmlPath = FindHTMLFile(FormName)
    If Len(htmlPath) = 0 Then
        MsgBox "HTML nicht gefunden: " & FormName & ".html", vbCritical, "Fehler"
        OpenHTMLviaCOM = False
        Exit Function
    End If

    Debug.Print "[mod_N_WebView2_COM] HTML gefunden: " & htmlPath

    ' 2. JSON-Daten vorbereiten
    jsonData = "{""form"":""" & FormName & """,""id"":" & RecordID & "}"

    ' 3. COM-Objekt erstellen (in Modul-Variable!)
    On Error Resume Next

    ' Vorheriges schliessen falls vorhanden
    If Not m_WebView Is Nothing Then
        m_WebView.CloseForm
        Set m_WebView = Nothing
        DoEvents
    End If

    Set m_WebView = CreateObject("ConsysWebView2.WebFormHost")

    If Err.Number <> 0 Then
        Debug.Print "[mod_N_WebView2_COM] COM-Fehler: " & Err.Description
        On Error GoTo 0

        ' Fallback: Im Browser oeffnen
        OpenInBrowser htmlPath, RecordID
        OpenHTMLviaCOM = True
        Exit Function
    End If
    On Error GoTo ErrorHandler

    ' 4. Formular anzeigen
    Debug.Print "[mod_N_WebView2_COM] Oeffne via COM: " & htmlPath

    If RecordID > 0 Then
        m_WebView.ShowFormWithData htmlPath, "CONSYS - " & WindowTitle, WIN_WIDTH, WIN_HEIGHT, jsonData
    Else
        m_WebView.ShowForm htmlPath, "CONSYS - " & WindowTitle, WIN_WIDTH, WIN_HEIGHT
    End If

    ' WICHTIG: m_WebView NICHT auf Nothing setzen!
    ' Das Objekt muss leben bleiben damit das Fenster funktioniert

    Debug.Print "[mod_N_WebView2_COM] Erfolgreich geoeffnet!"
    OpenHTMLviaCOM = True
    Exit Function

ErrorHandler:
    MsgBox "Fehler: " & Err.Description, vbCritical, "WebView2 Fehler"
    Debug.Print "[mod_N_WebView2_COM] FEHLER: " & Err.Description
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

Private Function FindHTMLFile(FormName As String) As String
    Dim testPath As String

    ' Zuerst in forms3 suchen
    testPath = HTML_FORMS3 & FormName & ".html"
    If Dir(testPath) <> "" Then
        FindHTMLFile = testPath
        Exit Function
    End If

    ' Dann in forms suchen
    testPath = HTML_FORMS & FormName & ".html"
    If Dir(testPath) <> "" Then
        FindHTMLFile = testPath
        Exit Function
    End If

    ' Nicht gefunden
    FindHTMLFile = ""
End Function

Private Sub OpenInBrowser(htmlPath As String, RecordID As Long)
    Dim url As String

    url = "file:///" & Replace(htmlPath, "\", "/")
    If RecordID > 0 Then
        url = url & "?id=" & RecordID
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

Public Sub Test_SimpleHTML()
    ' Testet mit der einfachen Test-Seite
    Debug.Print "=== SIMPLE TEST START ==="
    OpenHTML_Form "simple_test", 0
    Debug.Print "=== SIMPLE TEST ENDE ==="
End Sub

Public Sub OpenDevTools()
    ' Oeffnet DevTools im aktuellen WebView2-Fenster
    On Error Resume Next
    If Not m_WebView Is Nothing Then
        m_WebView.OpenDevTools
        Debug.Print "[mod_N_WebView2_COM] DevTools geoeffnet"
    Else
        Debug.Print "[mod_N_WebView2_COM] Kein WebView aktiv"
    End If
End Sub
