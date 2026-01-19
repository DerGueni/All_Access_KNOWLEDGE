VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_EventAuswahl"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'Option Compare Database
'Option Explicit
'
'' ============================================================================
'' FORMULAR: frm_EventAuswahl
'' VERSION: 3.1 - KORREKTE BEHANDLUNG VON FORMULAR-SCHLIESSUNG
'' ============================================================================
'' ÄNDERUNGEN v3.1:
'' - KRITISCHER FIX: Beim einfachen Schließen (X) wird g_UserCancelled = True
'' - Form_Unload setzt jetzt korrekt den Abbruch-Status
'' - Nur beim expliziten OK-Click wird importiert
'' ============================================================================
'
'Private Sub Form_Load()
'    On Error GoTo ErrorHandler
'
'    Debug.Print String(60, "=")
'    Debug.Print "=== Formular frm_EventAuswahl wird geladen ==="
'    Debug.Print String(60, "=")
'
'    ' Prüfe ob Daten vorhanden
'    If mod_N_Loewensaal.g_EventCount = 0 Then
'        MsgBox "Keine Events zum Anzeigen vorhanden!" & vbCrLf & vbCrLf & _
'               "Das Formular wird geschlossen.", vbExclamation, "Keine Daten"
'        Debug.Print "!!! Keine Daten - Formular wird geschlossen"
'        DoCmd.Close acForm, Me.Name
'        Exit Sub
'    End If
'
'    Debug.Print "Anzahl Events in g_EventCount: " & mod_N_Loewensaal.g_EventCount
'    Debug.Print "Array-Größe g_EventsToImport: " & (UBound(mod_N_Loewensaal.g_EventsToImport) - LBound(mod_N_Loewensaal.g_EventsToImport) + 1)
'
'    ' Listbox für tabellarische Ansicht konfigurieren
'    Call KonfiguriereListboxTabellarisch
'
'    ' Liste füllen
'    Call FuelleEventListeTabellarisch
'
'    ' Buttons aktivieren
'    Me.btnAlleAuswaehlen.Enabled = True
'    Me.btnAlleAbwaehlen.Enabled = True
'    Me.btnOK.Enabled = True
'    Me.btnAbbrechen.Enabled = True
'
'    Debug.Print "=== Formular erfolgreich geladen ==="
'    Debug.Print String(60, "=")
'
'    Exit Sub
'
'ErrorHandler:
'    MsgBox "Fehler beim Laden des Formulars:" & vbCrLf & vbCrLf & _
'           "Fehler-Nr: " & err.Number & vbCrLf & _
'           "Beschreibung: " & err.description, vbCritical, "Fehler"
'    Debug.Print "!!! FEHLER Form_Load: " & err.Number & " - " & err.description
'    DoCmd.Close acForm, Me.Name
'End Sub
'
'' ============================================================================
'' Konfiguriert Listbox für tabellarische Ansicht mit Spalten
'' ============================================================================
'Private Sub KonfiguriereListboxTabellarisch()
'    On Error Resume Next
'
'    With Me.lstEvents
'        .RowSourceType = "Value List"
'        .rowSource = ""
'
'        ' SPALTEN-KONFIGURATION
'        .ColumnCount = 4
'        .ColumnHeads = True
'        .ColumnWidths = "1400;4500;2800;1400"
'
'        ' FARBEN
'        .backColor = RGB(255, 255, 255)
'        .foreColor = RGB(0, 0, 0)
'
'        ' SCHRIFTART
'        .FontName = "Segoe UI"
'        .FontSize = 11
'        .FontBold = False
'
'        ' FORMATIERUNG
'        .BorderStyle = 1
'        .GridlineStyleTop = 1
'        .GridlineStyleBottom = 1
'        .GridlineStyleLeft = 1
'        .GridlineStyleRight = 1
'    End With
'
'    Debug.Print "Listbox konfiguriert: 4 Spalten, Weiß/Schwarz, Größe 11"
'End Sub
'
'' ============================================================================
'' Füllt die Listbox mit tabellarischer Darstellung
'' ============================================================================
'Private Sub FuelleEventListeTabellarisch()
'    On Error GoTo ErrorHandler
'
'    Debug.Print vbCrLf & ">>> Fülle Event-Liste (tabellarisch)..."
'
'    Dim i As Integer
'    Dim rowSource As String
'    Dim titelFormatiert As String
'    Dim objektFormatiert As String
'    Dim ortFormatiert As String
'
'    rowSource = ""
'
'    For i = LBound(mod_N_Loewensaal.g_EventsToImport) To UBound(mod_N_Loewensaal.g_EventsToImport)
'        With mod_N_Loewensaal.g_EventsToImport(i)
'            titelFormatiert = ToTitleCase(.titel)
'            objektFormatiert = ToTitleCase(.Objekt)
'
'            If Len(Trim(.Ort)) = 0 Then
'                ortFormatiert = ExtrahiereOrtAusObjekt(.Objekt)
'            Else
'                ortFormatiert = ToTitleCase(.Ort)
'            End If
'
'            Dim eventRow As String
'            eventRow = .DatumStr & ";" & _
'                      titelFormatiert & ";" & _
'                      objektFormatiert & ";" & _
'                      ortFormatiert
'
'            Debug.Print "  [" & i & "] " & eventRow
'
'            If Len(rowSource) > 0 Then
'                rowSource = rowSource & ";"
'            End If
'
'            eventRow = Replace(eventRow, """", """""")
'            rowSource = rowSource & """" & eventRow & """"
'        End With
'    Next i
'
'    Debug.Print vbCrLf & "RowSource-Länge: " & Len(rowSource) & " Zeichen"
'
'    Me.lstEvents.rowSource = rowSource
'
'    Debug.Print "Listbox gefüllt - ListCount: " & Me.lstEvents.ListCount
'
'    ' Alle Events vorauswählen
'    Debug.Print "Wähle alle Events vor..."
'    For i = 0 To Me.lstEvents.ListCount - 1
'        Me.lstEvents.selected(i) = True
'    Next i
'
'    Call AktualisiereAnzahl
'
'    Debug.Print "? Event-Liste erfolgreich gefüllt (tabellarisch)" & vbCrLf
'
'    Exit Sub
'
'ErrorHandler:
'    Debug.Print "!!! FEHLER FuelleEventListeTabellarisch: " & err.Number & " - " & err.description
'    MsgBox "Fehler beim Füllen der Liste:" & vbCrLf & vbCrLf & _
'           "Fehler-Nr: " & err.Number & vbCrLf & _
'           "Beschreibung: " & err.description, vbCritical, "Fehler"
'End Sub
'
'' ============================================================================
'' Extrahiert Ort aus Objektbezeichnung
'' ============================================================================
'Private Function ExtrahiereOrtAusObjekt(Objekt As String) As String
'    On Error Resume Next
'
'    Dim objektUpper As String
'    objektUpper = UCase(Trim(Objekt))
'
'    If InStr(objektUpper, "LÖWENSAAL") > 0 Or InStr(objektUpper, "LOEWENSAAL") > 0 Then
'        ExtrahiereOrtAusObjekt = "Nürnberg"
'    ElseIf InStr(objektUpper, "MARKGRAFENSAAL") > 0 Then
'        ExtrahiereOrtAusObjekt = "Nürnberg"
'    ElseIf InStr(objektUpper, "MEISTERSINGERHALLE") > 0 Then
'        ExtrahiereOrtAusObjekt = "Nürnberg"
'    ElseIf InStr(objektUpper, "HEINRICH-LADES-HALLE") > 0 Then
'        ExtrahiereOrtAusObjekt = "Erlangen"
'    ElseIf InStr(objektUpper, "STADIONPARK") > 0 Then
'        ExtrahiereOrtAusObjekt = "Nürnberg"
'    ElseIf InStr(objektUpper, "STADTHALLE") > 0 Then
'        ExtrahiereOrtAusObjekt = "Fürth"
'    ElseIf InStr(objektUpper, "SERENADENHOF") > 0 Then
'        ExtrahiereOrtAusObjekt = "Nürnberg"
'    ElseIf InStr(objektUpper, "HIRSCH") > 0 Then
'        ExtrahiereOrtAusObjekt = "Nürnberg"
'    Else
'        ExtrahiereOrtAusObjekt = "Nürnberg"
'    End If
'End Function
'
'' ============================================================================
'' Konvertiert Text in Title Case
'' ============================================================================
'Private Function ToTitleCase(inputText As String) As String
'    On Error Resume Next
'
'    If Len(Trim(inputText)) = 0 Then
'        ToTitleCase = ""
'        Exit Function
'    End If
'
'    Dim words() As String
'    Dim i As Integer
'    Dim word As String
'    Dim result As String
'    Dim kleinwoerter As String
'
'    kleinwoerter = "|der|die|das|den|dem|des|ein|eine|einer|eines|und|oder|am|im|von|zu|zur|zum|an|in|"
'
'    inputText = LCase(Trim(inputText))
'    words = Split(inputText, " ")
'    result = ""
'
'    For i = LBound(words) To UBound(words)
'        word = Trim(words(i))
'
'        If Len(word) > 0 Then
'            If i = 0 Or InStr(kleinwoerter, "|" & word & "|") = 0 Then
'                word = UCase(Left(word, 1)) & Mid(word, 2)
'            End If
'
'            If Len(result) > 0 Then
'                result = result & " " & word
'            Else
'                result = word
'            End If
'        End If
'    Next i
'
'    ToTitleCase = result
'End Function
'
'' ============================================================================
'' Aktualisiert die Anzahl-Anzeige
'' ============================================================================
'Private Sub AktualisiereAnzahl()
'    On Error Resume Next
'
'    Dim Ausgewaehlt As Integer
'    Dim i As Integer
'
'    Ausgewaehlt = 0
'
'    For i = 0 To Me.lstEvents.ListCount - 1
'        If Me.lstEvents.selected(i) Then
'            Ausgewaehlt = Ausgewaehlt + 1
'        End If
'    Next i
'
'    Me.caption = "Event Auswahl - " & Ausgewaehlt & " von " & mod_N_Loewensaal.g_EventCount & " ausgewählt"
'
'    Debug.Print "Aktualisiert: " & Ausgewaehlt & " von " & mod_N_Loewensaal.g_EventCount & " ausgewählt"
'End Sub
'
'' ============================================================================
'' Button: Alle auswählen
'' ============================================================================
'Private Sub btnAlleAuswaehlen_Click()
'    On Error Resume Next
'
'    Debug.Print "? Button 'Alle auswählen' geklickt"
'
'    Dim i As Integer
'    For i = 0 To Me.lstEvents.ListCount - 1
'        Me.lstEvents.selected(i) = True
'    Next i
'
'    Call AktualisiereAnzahl
'End Sub
'
'' ============================================================================
'' Button: Alle abwählen
'' ============================================================================
'Private Sub btnAlleAbwaehlen_Click()
'    On Error Resume Next
'
'    Debug.Print "? Button 'Alle abwählen' geklickt"
'
'    Dim i As Integer
'    For i = 0 To Me.lstEvents.ListCount - 1
'        Me.lstEvents.selected(i) = False
'    Next i
'
'    Call AktualisiereAnzahl
'End Sub
'
'' ============================================================================
'' Button: OK - Import starten
'' ============================================================================
'Private Sub btnOK_Click()
'    On Error GoTo ErrorHandler
'
'    Dim i As Integer
'    Dim Ausgewaehlt As Integer
'
'    Debug.Print String(60, "=")
'    Debug.Print "? Button 'OK' geklickt - Import wird vorbereitet"
'
'    ' Zähle ausgewählte Items
'    Ausgewaehlt = 0
'    For i = 0 To Me.lstEvents.ListCount - 1
'        If Me.lstEvents.selected(i) Then
'            Ausgewaehlt = Ausgewaehlt + 1
'        End If
'    Next i
'
'    Debug.Print "Anzahl ausgewählter Events: " & Ausgewaehlt
'
'    ' Validierung
'    If Ausgewaehlt = 0 Then
'        MsgBox "Bitte wählen Sie mindestens ein Event aus!", vbExclamation, "Keine Auswahl"
'        Debug.Print "!!! Keine Events ausgewählt - Abbruch"
'        Exit Sub
'    End If
'
'    ' Bestätigung
'    Dim antwort As VbMsgBoxResult
'    antwort = MsgBox("Möchten Sie " & Ausgewaehlt & " Event(s) importieren?", _
'                     vbQuestion + vbYesNo + vbDefaultButton1, "Import bestätigen")
'
'    If antwort = vbNo Then
'        Debug.Print "!!! Import durch Benutzer abgelehnt"
'        Exit Sub
'    End If
'
'    Debug.Print "? Import bestätigt - Übertrage Auswahl..."
'
'    ' WICHTIG: Auswahl in globales Array übertragen
'    For i = LBound(mod_N_Loewensaal.g_EventsToImport) To UBound(mod_N_Loewensaal.g_EventsToImport)
'        mod_N_Loewensaal.g_EventsToImport(i).Ausgewaehlt = Me.lstEvents.selected(i)
'
'        If Me.lstEvents.selected(i) Then
'            Debug.Print "  ? Ausgewählt [" & i & "]: " & _
'                       mod_N_Loewensaal.g_EventsToImport(i).DatumStr & " - " & _
'                       Left(mod_N_Loewensaal.g_EventsToImport(i).titel, 40)
'        End If
'    Next i
'
'    ' KRITISCH: Setze g_UserCancelled auf FALSE (Import wird durchgeführt)
'    mod_N_Loewensaal.g_UserCancelled = False
'
'    Debug.Print "? Auswahl übertragen - g_UserCancelled = False"
'    Debug.Print "? Formular wird geschlossen - Import wird fortgesetzt"
'    Debug.Print String(60, "=")
'
'    ' Formular schließen (Import läuft dann im Hauptmodul weiter)
'    DoCmd.Close acForm, Me.Name, acSaveNo
'
'    Exit Sub
'
'ErrorHandler:
'    Debug.Print "!!! FEHLER btnOK_Click: " & err.Number & " - " & err.description
'    MsgBox "Fehler beim Starten des Imports:" & vbCrLf & vbCrLf & _
'           "Fehler-Nr: " & err.Number & vbCrLf & _
'           "Beschreibung: " & err.description, vbCritical, "Fehler"
'End Sub
'
'' ============================================================================
'' Button: Abbrechen
'' ============================================================================
'Private Sub btnAbbrechen_Click()
'    On Error Resume Next
'
'    Debug.Print String(60, "=")
'    Debug.Print "? Button 'Abbrechen' geklickt"
'
'    Dim antwort As VbMsgBoxResult
'    antwort = MsgBox("Möchten Sie den Import wirklich abbrechen?", _
'                     vbQuestion + vbYesNo + vbDefaultButton2, "Abbrechen?")
'
'    If antwort = vbYes Then
'        Debug.Print "? Abbruch bestätigt - Import wird abgebrochen"
'
'        ' KRITISCH: Setze g_UserCancelled auf TRUE
'        mod_N_Loewensaal.g_UserCancelled = True
'
'        DoCmd.Close acForm, Me.Name, acSaveNo
'    Else
'        Debug.Print "? Abbruch verworfen - Formular bleibt offen"
'    End If
'
'    Debug.Print String(60, "=")
'End Sub
'
'' ============================================================================
'' Listbox: Auswahl geändert
'' ============================================================================
'Private Sub lstEvents_Click()
'    On Error Resume Next
'    Call AktualisiereAnzahl
'End Sub
'
'' ============================================================================
'' KRITISCH: Form_Unload - Wird beim Schließen (X-Button) ausgeführt
'' ============================================================================
'Private Sub Form_Unload(Cancel As Integer)
'    On Error Resume Next
'
'    Debug.Print "=== Form_Unload ausgeführt ==="
'
'    ' KRITISCHER FIX: Wenn g_UserCancelled noch nicht explizit gesetzt wurde,
'    ' bedeutet das, dass das Formular einfach geschlossen wurde (X-Button oder ESC)
'    ' In diesem Fall soll KEIN Import stattfinden!
'
'    ' Prüfe ob OK-Button geklickt wurde (dann ist g_UserCancelled = False)
'    ' Wenn nicht, setze auf True (Abbruch)
'    If mod_N_Loewensaal.g_UserCancelled <> False Then
'        ' User hat weder OK noch Abbrechen geklickt -> Formular einfach geschlossen
'        Debug.Print "? Formular wurde einfach geschlossen (X oder ESC)"
'        Debug.Print "? Setze g_UserCancelled = True (KEIN Import)"
'        mod_N_Loewensaal.g_UserCancelled = True
'    Else
'        Debug.Print "? OK-Button wurde geklickt, Import läuft weiter"
'    End If
'
'    Debug.Print "=== Formular frm_EventAuswahl wird geschlossen ==="
'    Debug.Print "g_UserCancelled = " & mod_N_Loewensaal.g_UserCancelled
'End Sub
'
