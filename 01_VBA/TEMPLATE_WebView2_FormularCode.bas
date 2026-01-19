Attribute VB_Name = "TEMPLATE_WebView2_FormularCode"
' ========================================
' TEMPLATE - WebView2 Formular Event-Handler
' ========================================
'
' VERWENDUNG:
' 1. Diesen Code in das Formular-Modul kopieren (nicht als separates Modul!)
' 2. htmlPath anpassen auf das richtige HTML-Formular
' 3. Formular muss ein WebView2 ActiveX Control haben (Name: "webview")
'
' VORAUSSETZUNGEN:
' - mod_N_WebHost_Bridge.bas importiert
' - JsonConverter.bas importiert (https://github.com/VBA-tools/VBA-JSON)
' - Microsoft Edge WebView2 Control installiert
' ========================================

Private Sub Form_Load()
    ' WebView2 initialisieren und HTML-Formular laden
    On Error GoTo ErrorHandler

    ' ANPASSEN: Pfad zum HTML-Formular
    Dim htmlPath As String
    htmlPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\IHR_FORMULAR.html"

    ' Prüfen ob Datei existiert
    If Dir(htmlPath) = "" Then
        MsgBox "HTML-Formular nicht gefunden: " & htmlPath, vbCritical
        DoCmd.Close acForm, Me.Name
        Exit Sub
    End If

    ' WebView2 laden
    Me.webview.Navigate "file:///" & Replace(htmlPath, "\", "/")

    Debug.Print "[" & Me.Name & "] HTML geladen: " & htmlPath
    Exit Sub

ErrorHandler:
    MsgBox "Fehler beim Laden des Formulars: " & Err.Description, vbCritical
    Debug.Print "[" & Me.Name & "] ERROR: " & Err.Description
End Sub

Private Sub webview_WebMessageReceived(ByVal args As Object)
    ' Event-Handler für Messages aus dem Browser
    ' Leitet Messages an mod_N_WebHost_Bridge weiter
    On Error GoTo ErrorHandler

    ' An generischen Message-Handler delegieren
    Call mod_N_WebHost_Bridge.WebView2_MessageHandler(Me.webview, args)

    Exit Sub

ErrorHandler:
    Debug.Print "[" & Me.Name & "] ERROR in WebMessageReceived: " & Err.Description
    MsgBox "Fehler bei Message-Verarbeitung: " & Err.Description, vbExclamation
End Sub

Private Sub Form_Unload(Cancel As Integer)
    ' Cleanup beim Schließen
    On Error Resume Next
    Set Me.webview = Nothing
    Debug.Print "[" & Me.Name & "] Formular geschlossen"
End Sub

' ========================================
' OPTIONAL: Spezifische Actions für dieses Formular
' ========================================
'
' Falls das Formular eigene, spezielle Actions benötigt
' (zusätzlich zu den Standard-CRUD-Actions aus mod_N_WebHost_Bridge),
' können diese hier hinzugefügt werden:
'
' Private Sub webview_WebMessageReceived(ByVal args As Object)
'     On Error GoTo ErrorHandler
'
'     Dim jsonString As String
'     Dim data As Object
'
'     jsonString = args.WebMessageAsJson
'     Set data = JsonConverter.ParseJson(jsonString)
'
'     ' Prüfen ob spezielle Action
'     Select Case data("action")
'
'         Case "customAction1"
'             ' Eigene Logik hier
'             Call HandleCustomAction1(data)
'
'         Case "customAction2"
'             ' Eigene Logik hier
'             Call HandleCustomAction2(data)
'
'         Case Else
'             ' Standard-Handler verwenden
'             Call mod_N_WebHost_Bridge.WebView2_MessageHandler(Me.webview, args)
'
'     End Select
'
'     Exit Sub
'
' ErrorHandler:
'     Debug.Print "[" & Me.Name & "] ERROR: " & Err.Description
' End Sub
'
' Private Sub HandleCustomAction1(ByVal data As Object)
'     ' Implementierung...
' End Sub
' ========================================

' ========================================
' INSTALLATIONS-CHECKLISTE
' ========================================
'
' [ ] WebView2 Runtime installiert
'     https://developer.microsoft.com/en-us/microsoft-edge/webview2/
'
' [ ] JsonConverter.bas importiert
'     https://github.com/VBA-tools/VBA-JSON
'     Datei: JsonConverter.bas in VBA-Projekt importieren
'
' [ ] mod_N_WebHost_Bridge.bas importiert
'     Pfad: 01_VBA\mod_N_WebHost_Bridge.bas
'
' [ ] WebView2 ActiveX Control hinzugefügt
'     1. Formular in Design-Ansicht öffnen
'     2. Steuerelemente → ActiveX-Steuerelemente
'     3. "Microsoft Edge WebView2 Control" auswählen
'     4. Control einfügen und über gesamtes Formular ziehen
'     5. Control-Name setzen auf: "webview"
'
' [ ] HTML-Formular existiert
'     Pfad in Form_Load() anpassen
'
' [ ] Formular-Code eingefügt
'     Diesen Code (Form_Load, webview_WebMessageReceived, Form_Unload)
'     in das Formular-Modul kopieren
'
' ========================================
