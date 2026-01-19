Attribute VB_Name = "frm_N_Ausweis_Create_EventHandlers"
' ========================================
' frm_N_Ausweis_Create - Event Handlers
' WebView2 Event-Handler für Ausweis-Formular
' ========================================
'
' WICHTIG: Diese Event-Handler müssen im Formular
' frm_N_Ausweis_Create implementiert werden!
'
' VERWENDUNG:
' 1. Formular frm_N_Ausweis_Create öffnen in Design-Ansicht
' 2. WebView2-Control hinzufügen (Name: "webview")
' 3. Diese Events im Formular-Code einfügen
' ========================================

' Im Formular-Code:

Private Sub Form_Load()
    ' WebView2 initialisieren
    On Error GoTo ErrorHandler

    ' URL zum HTML-Formular
    Dim htmlPath As String
    htmlPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\frm_Ausweis_Create.html"

    ' Prüfen ob Datei existiert
    If Dir(htmlPath) = "" Then
        MsgBox "HTML-Formular nicht gefunden: " & htmlPath, vbCritical
        DoCmd.Close acForm, Me.Name
        Exit Sub
    End If

    ' WebView2 laden
    Me.webview.Navigate "file:///" & Replace(htmlPath, "\", "/")

    Debug.Print "[Ausweis Form] Geladen: " & htmlPath
    Exit Sub

ErrorHandler:
    MsgBox "Fehler beim Laden des Formulars: " & Err.Description, vbCritical
End Sub

Private Sub webview_WebMessageReceived(ByVal args As Object)
    ' Event-Handler für Messages aus dem Browser
    On Error GoTo ErrorHandler

    Dim jsonString As String
    Dim data As Object

    ' JSON-String extrahieren
    jsonString = args.WebMessageAsJson

    Debug.Print "[Ausweis Form] Message empfangen: " & jsonString

    ' JSON parsen (benötigt JsonConverter Modul!)
    Set data = JsonConverter.ParseJson(jsonString)

    ' Event-Type prüfen
    Select Case data("type")

        Case "loadData"
            ' Daten laden
            If data("dataType") = "mitarbeiter" Then
                Call mod_N_Ausweis_Create_Bridge.Ausweis_Create_SendMitarbeiterDaten(Me.webview)
            End If

        Case "createBadge"
            ' Ausweis erstellen
            Dim employees As Collection
            Dim badgeType As String
            Dim validUntil As String

            Set employees = data("employees")
            badgeType = data("badgeType")
            validUntil = data("validUntil")

            Call mod_N_Ausweis_Create_Bridge.Ausweis_Create_CreateBadge(employees, badgeType, validUntil)

        Case "printCard"
            ' Karte drucken
            Dim cardEmployees As Collection
            Dim cardType As String
            Dim printer As String
            Dim cardValidUntil As String

            Set cardEmployees = data("employees")
            cardType = data("cardType")
            printer = data("printer")
            cardValidUntil = data("validUntil")

            Call mod_N_Ausweis_Create_Bridge.Ausweis_Create_PrintCard(cardEmployees, cardType, printer, cardValidUntil)

        Case "refresh"
            ' Formular aktualisieren
            Me.webview.Reload

        Case "close"
            ' Formular schließen
            DoCmd.Close acForm, Me.Name

        Case Else
            Debug.Print "[Ausweis Form] Unbekanntes Event: " & data("type")

    End Select

    Exit Sub

ErrorHandler:
    Debug.Print "[Ausweis Form] Fehler: " & Err.Description
    MsgBox "Fehler bei Event-Verarbeitung: " & Err.Description, vbExclamation
End Sub

Private Sub Form_Unload(Cancel As Integer)
    ' Cleanup
    On Error Resume Next
    Set Me.webview = Nothing
    Debug.Print "[Ausweis Form] Geschlossen"
End Sub

' ========================================
' HINWEISE ZUR INSTALLATION
' ========================================
'
' 1. JsonConverter installieren:
'    https://github.com/VBA-tools/VBA-JSON
'    - JsonConverter.bas ins Projekt importieren
'
' 2. WebView2 Runtime installieren:
'    https://developer.microsoft.com/en-us/microsoft-edge/webview2/
'
' 3. WebView2 ActiveX Control hinzufügen:
'    - VBA-Editor → Tools → References
'    - "Microsoft Edge WebView2 Control" aktivieren
'
' 4. Formular erstellen:
'    - Neues Formular: frm_N_Ausweis_Create
'    - WebView2-Control einfügen (Name: "webview")
'    - Control über gesamtes Formular ziehen
'    - Formular-Code oben einfügen
'
' 5. Reports erstellen (10 Stück):
'    - rpt_Dienstausweis_Einsatzleitung
'    - rpt_Dienstausweis_Bereichsleiter
'    - rpt_Dienstausweis_Security
'    - rpt_Dienstausweis_Service
'    - rpt_Dienstausweis_Platzanweiser
'    - rpt_Dienstausweis_Staff
'    - rpt_Karte_Sicherheit
'    - rpt_Karte_Service
'    - rpt_Karte_Rueckseite
'    - rpt_Karte_Sonder
'
' 6. Temporäre Tabelle erstellen:
'    SQL aus: 02_SQL\CREATE_tbl_TEMP_AusweisListe.sql
'
' ========================================
