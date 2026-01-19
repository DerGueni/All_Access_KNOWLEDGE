' mod_N_HTML_Forms
' VBA-Modul für HTML-Formular-Integration in Access
' Ermöglicht das Öffnen von HTML-Formularen im Browser
' mit Parameterübergabe und Preloading-Unterstützung

' ============================================================
' KONFIGURATION
' ============================================================

Private Const HTML_BASE_PATH As String = "C:\Users\guenther.siegert\Documents\Consys_HTML\02_web\forms\"
Private Const BROWSER_PATH As String = "msedge.exe"  ' oder chrome.exe
Private Const API_SERVER_URL As String = "http://localhost:5000"

' Speichert Referenz auf Preloader-Shell
Private mPreloaderShell As Object
Private mPreloaderPID As Long

' ============================================================
' ÖFFENTLICHE FUNKTIONEN
' ============================================================

Public Sub HTML_Form_Oeffnen(ByVal FormName As String, Optional ByVal Parameter As String = "")
    '
    ' Öffnet ein HTML-Formular im Standard-Browser
    ' Parameter: FormName - Name der HTML-Datei (ohne .html)
    '            Parameter - URL-Parameter (z.B. "VA_ID=123&Datum=2024-12-18")
    '
    Dim sURL As String
    Dim sFullPath As String

    ' Pfad zusammenbauen
    sFullPath = HTML_BASE_PATH & FormName & ".html"

    ' Prüfen ob Datei existiert
    If Dir(sFullPath) = "" Then
        MsgBox "HTML-Formular nicht gefunden:" & vbCrLf & sFullPath, vbExclamation, "Fehler"
        Exit Sub
    End If

    ' URL mit Parametern
    If Parameter <> "" Then
        sURL = "file:///" & Replace(sFullPath, "\", "/") & "?" & Parameter
    Else
        sURL = "file:///" & Replace(sFullPath, "\", "/")
    End If

    ' Browser öffnen
    Shell "cmd /c start """" """ & sURL & """", vbNormalFocus

    ' Status loggen
    Debug.Print "[HTML] Geöffnet: " & FormName & " (" & Parameter & ")"
End Sub

Public Sub HTML_Mitarbeiterstamm(Optional ByVal MA_ID As Variant = Null)
    Dim sParam As String
    If Not IsNull(MA_ID) Then sParam = "MA_ID=" & MA_ID
    HTML_Form_Oeffnen "frm_MA_Mitarbeiterstamm", sParam
End Sub

Public Sub HTML_Kundenstamm(Optional ByVal Kunde_ID As Variant = Null)
    Dim sParam As String
    If Not IsNull(Kunde_ID) Then sParam = "Kunde_ID=" & Kunde_ID
    HTML_Form_Oeffnen "frm_KD_Kundenstamm", sParam
End Sub

Public Sub HTML_Auftragstamm(Optional ByVal VA_ID As Variant = Null)
    Dim sParam As String
    If Not IsNull(VA_ID) Then sParam = "VA_ID=" & VA_ID
    HTML_Form_Oeffnen "frm_va_Auftragstamm", sParam
End Sub

Public Sub HTML_Dienstplanuebersicht(Optional ByVal Datum As Variant = Null)
    Dim sParam As String
    If Not IsNull(Datum) Then sParam = "Datum=" & Format(Datum, "yyyy-mm-dd")
    HTML_Form_Oeffnen "frm_N_Dienstplanuebersicht", sParam
End Sub

Public Sub HTML_Planungsuebersicht(Optional ByVal VA_ID As Variant = Null, Optional ByVal Datum As Variant = Null)
    Dim sParam As String
    If Not IsNull(VA_ID) Then sParam = "VA_ID=" & VA_ID
    If Not IsNull(Datum) Then
        If sParam <> "" Then sParam = sParam & "&"
        sParam = sParam & "Datum=" & Format(Datum, "yyyy-mm-dd")
    End If
    HTML_Form_Oeffnen "frm_VA_Planungsuebersicht", sParam
End Sub

Public Sub HTML_Einsatzuebersicht(Optional ByVal Datum As Variant = Null)
    Dim sParam As String
    If Not IsNull(Datum) Then sParam = "Datum=" & Format(Datum, "yyyy-mm-dd")
    HTML_Form_Oeffnen "frm_Einsatzuebersicht", sParam
End Sub

Public Sub HTML_Abwesenheit(Optional ByVal MA_ID As Variant = Null)
    Dim sParam As String
    If Not IsNull(MA_ID) Then sParam = "MA_ID=" & MA_ID
    HTML_Form_Oeffnen "frm_MA_Abwesenheit", sParam
End Sub

Public Sub HTML_Zeitkonten(Optional ByVal MA_ID As Variant = Null)
    Dim sParam As String
    If Not IsNull(MA_ID) Then sParam = "MA_ID=" & MA_ID
    HTML_Form_Oeffnen "frm_MA_Zeitkonten", sParam
End Sub

Public Sub HTML_ObjektStamm(Optional ByVal Objekt_ID As Variant = Null)
    Dim sParam As String
    If Not IsNull(Objekt_ID) Then sParam = "Objekt_ID=" & Objekt_ID
    HTML_Form_Oeffnen "frm_OB_Objekt", sParam
End Sub

Public Sub HTML_Lohnabrechnungen(Optional ByVal Monat As Variant = Null, Optional ByVal Jahr As Variant = Null)
    Dim sParam As String
    If Not IsNull(Monat) Then sParam = "Monat=" & Monat
    If Not IsNull(Jahr) Then
        If sParam <> "" Then sParam = sParam & "&"
        sParam = sParam & "Jahr=" & Jahr
    End If
    HTML_Form_Oeffnen "zfrm_Lohnabrechnungen", sParam
End Sub

Public Sub HTML_Rueckmeldungen()
    HTML_Form_Oeffnen "zfrm_Rueckmeldungen", ""
End Sub

Public Sub HTML_BewerberVerarbeitung()
    HTML_Form_Oeffnen "frm_N_MA_Bewerber_Verarbeitung", ""
End Sub

Public Sub HTML_Dashboard()
    HTML_Form_Oeffnen "index", ""
End Sub

' ============================================================
' PRELOADING-FUNKTIONEN
' ============================================================

Public Sub HTML_Preloader_Starten()
    '
    ' Startet den HTML-Preloader im Hintergrund
    ' Lädt alle wichtigen Formulare vor für schnellere Anzeige
    '
    Dim sPreloaderPath As String
    sPreloaderPath = HTML_BASE_PATH & "..\preloader.html"

    If Dir(sPreloaderPath) = "" Then
        Debug.Print "[HTML] Preloader nicht gefunden: " & sPreloaderPath
        Exit Sub
    End If

    ' Edge im minimized Modus starten
    On Error Resume Next
    Set mPreloaderShell = CreateObject("WScript.Shell")
    mPreloaderPID = mPreloaderShell.Run(BROWSER_PATH & " --app=""file:///" & Replace(sPreloaderPath, "\", "/") & """ --window-position=10000,10000 --window-size=1,1", 7, False)
    On Error GoTo 0

    Debug.Print "[HTML] Preloader gestartet (PID: " & mPreloaderPID & ")"
End Sub

Public Sub HTML_Preloader_Beenden()
    '
    ' Beendet den HTML-Preloader
    '
    On Error Resume Next
    If mPreloaderPID > 0 Then
        mPreloaderShell.Run "taskkill /PID " & mPreloaderPID & " /F", 0, False
        mPreloaderPID = 0
    End If
    Set mPreloaderShell = Nothing
    On Error GoTo 0

    Debug.Print "[HTML] Preloader beendet"
End Sub

' ============================================================
' API-SERVER PRÜFUNG
' ============================================================

Public Function HTML_API_Server_Pruefen() As Boolean
    '
    ' Prüft ob der API-Server läuft (localhost:5000)
    '
    Dim oHTTP As Object

    On Error GoTo Fehler
    Set oHTTP = CreateObject("MSXML2.XMLHTTP")
    oHTTP.Open "GET", API_SERVER_URL & "/api/tables", False
    oHTTP.setRequestHeader "Content-Type", "application/json"
    oHTTP.send

    If oHTTP.Status = 200 Then
        HTML_API_Server_Pruefen = True
        Debug.Print "[HTML] API-Server erreichbar"
    Else
        HTML_API_Server_Pruefen = False
        Debug.Print "[HTML] API-Server nicht erreichbar (Status: " & oHTTP.Status & ")"
    End If

    Set oHTTP = Nothing
    Exit Function

Fehler:
    HTML_API_Server_Pruefen = False
    Debug.Print "[HTML] API-Server Fehler: " & Err.Description
    Set oHTTP = Nothing
End Function

Public Sub HTML_API_Server_Starten()
    '
    ' Startet den API-Server (api_server.py)
    '
    Dim sServerPath As String
    sServerPath = HTML_BASE_PATH & "..\..\03_api\api_server.py"

    If Dir(sServerPath) = "" Then
        MsgBox "API-Server nicht gefunden:" & vbCrLf & sServerPath, vbExclamation, "Fehler"
        Exit Sub
    End If

    Shell "cmd /c start /min python """ & sServerPath & """", vbMinimizedNoFocus
    Debug.Print "[HTML] API-Server wird gestartet..."

    ' Kurz warten und prüfen
    Application.Wait Now + TimeValue("00:00:02")

    If HTML_API_Server_Pruefen() Then
        Debug.Print "[HTML] API-Server erfolgreich gestartet"
    Else
        Debug.Print "[HTML] API-Server konnte nicht gestartet werden"
    End If
End Sub

' ============================================================
' UMSCHALTUNG ACCESS <-> HTML
' ============================================================

Public Sub HTML_Toggle_Ansicht(ByVal AccessFormName As String, ByVal HTMLFormName As String, Optional ByVal Parameter As String = "")
    '
    ' Wechselt zwischen Access- und HTML-Ansicht eines Formulars
    ' Schließt das Access-Formular und öffnet die HTML-Version
    '
    On Error Resume Next

    ' Access-Formular schließen falls offen
    If IsFormOpen(AccessFormName) Then
        DoCmd.Close acForm, AccessFormName
    End If

    ' HTML-Formular öffnen
    HTML_Form_Oeffnen HTMLFormName, Parameter

    On Error GoTo 0
End Sub

Private Function IsFormOpen(ByVal FormName As String) As Boolean
    Dim i As Integer
    For i = 0 To Forms.Count - 1
        If Forms(i).Name = FormName Then
            IsFormOpen = True
            Exit Function
        End If
    Next i
    IsFormOpen = False
End Function

' ============================================================
' INITIALISIERUNG (beim Frontend-Start aufrufen)
' ============================================================

Public Sub HTML_Init()
    '
    ' Initialisiert das HTML-System
    ' Sollte beim Start des Frontends aufgerufen werden
    '
    Debug.Print "========================================"
    Debug.Print "[HTML] Initialisierung..."
    Debug.Print "[HTML] Basis-Pfad: " & HTML_BASE_PATH
    Debug.Print "[HTML] API-Server: " & API_SERVER_URL

    ' API-Server prüfen
    If Not HTML_API_Server_Pruefen() Then
        Debug.Print "[HTML] WARNUNG: API-Server nicht erreichbar!"
        ' Optional: Server automatisch starten
        ' HTML_API_Server_Starten
    End If

    ' Optional: Preloader starten
    ' HTML_Preloader_Starten

    Debug.Print "[HTML] Initialisierung abgeschlossen"
    Debug.Print "========================================"
End Sub
