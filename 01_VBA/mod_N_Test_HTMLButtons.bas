Attribute VB_Name = "mod_N_Test_HTMLButtons"
' =====================================================
' mod_N_Test_HTMLButtons
' Test-Modul fuer HTML Ansicht Buttons
' Erstellt: 13.01.2026
' =====================================================

' AUSFUEHRUNG: Im VBA-Editor Direktfenster eingeben:
' Test_Alle_HTMLButtons

Public Sub Test_Alle_HTMLButtons()
    On Error GoTo ErrorHandler

    Debug.Print String(70, "=")
    Debug.Print "HTML ANSICHT BUTTONS - FUNKTIONSTEST"
    Debug.Print String(70, "=")
    Debug.Print ""

    Dim erfolge As Integer
    Dim fehler As Integer
    erfolge = 0
    fehler = 0

    ' TEST 1: HTMLAnsichtOeffnen
    Debug.Print "[TEST 1] HTMLAnsichtOeffnen()"
    Debug.Print String(70, "-")
    On Error Resume Next
    Dim result1 As Boolean
    result1 = HTMLAnsichtOeffnen()
    If Err.Number = 0 Then
        Debug.Print "[OK] ERFOLGREICH! Rueckgabe: " & result1
        Debug.Print "[INFO] Browser sollte shell.html oeffnen"
        erfolge = erfolge + 1
    Else
        Debug.Print "[FEHLER] " & Err.Description & " (Fehler: " & Err.Number & ")"
        fehler = fehler + 1
    End If
    Err.Clear
    Debug.Print ""

    ' Kurze Pause
    DoEvents
    Application.Wait Now + TimeValue("0:00:02")

    ' TEST 2: OpenAuftragsverwaltungHTML(1)
    Debug.Print "[TEST 2] OpenAuftragsverwaltungHTML(1)"
    Debug.Print String(70, "-")
    On Error Resume Next
    Dim result2 As Boolean
    result2 = OpenAuftragsverwaltungHTML(1)
    If Err.Number = 0 Then
        Debug.Print "[OK] ERFOLGREICH! Rueckgabe: " & result2
        Debug.Print "[INFO] Browser sollte Auftragstamm mit ID=1 oeffnen"
        erfolge = erfolge + 1
    Else
        Debug.Print "[FEHLER] " & Err.Description & " (Fehler: " & Err.Number & ")"
        fehler = fehler + 1
    End If
    Err.Clear
    Debug.Print ""

    DoEvents
    Application.Wait Now + TimeValue("0:00:02")

    ' TEST 3: OpenMitarbeiterstammHTML(707)
    Debug.Print "[TEST 3] OpenMitarbeiterstammHTML(707)"
    Debug.Print String(70, "-")
    On Error Resume Next
    Dim result3 As Boolean
    result3 = OpenMitarbeiterstammHTML(707)
    If Err.Number = 0 Then
        Debug.Print "[OK] ERFOLGREICH! Rueckgabe: " & result3
        Debug.Print "[INFO] Browser sollte Mitarbeiterstamm mit ID=707 oeffnen"
        erfolge = erfolge + 1
    Else
        Debug.Print "[FEHLER] " & Err.Description & " (Fehler: " & Err.Number & ")"
        fehler = fehler + 1
    End If
    Err.Clear
    Debug.Print ""

    DoEvents
    Application.Wait Now + TimeValue("0:00:02")

    ' TEST 4: OpenKundenstammHTML(1)
    Debug.Print "[TEST 4] OpenKundenstammHTML(1)"
    Debug.Print String(70, "-")
    On Error Resume Next
    Dim result4 As Boolean
    result4 = OpenKundenstammHTML(1)
    If Err.Number = 0 Then
        Debug.Print "[OK] ERFOLGREICH! Rueckgabe: " & result4
        Debug.Print "[INFO] Browser sollte Kundenstamm mit ID=1 oeffnen"
        erfolge = erfolge + 1
    Else
        Debug.Print "[FEHLER] " & Err.Description & " (Fehler: " & Err.Number & ")"
        fehler = fehler + 1
    End If
    Err.Clear
    Debug.Print ""

    DoEvents
    Application.Wait Now + TimeValue("0:00:02")

    ' TEST 5: OpenHTMLMenu()
    Debug.Print "[TEST 5] OpenHTMLMenu()"
    Debug.Print String(70, "-")
    On Error Resume Next
    Dim result5 As Boolean
    result5 = OpenHTMLMenu()
    If Err.Number = 0 Then
        Debug.Print "[OK] ERFOLGREICH! Rueckgabe: " & result5
        Debug.Print "[INFO] Browser sollte shell.html oeffnen"
        erfolge = erfolge + 1
    Else
        Debug.Print "[FEHLER] " & Err.Description & " (Fehler: " & Err.Number & ")"
        fehler = fehler + 1
    End If
    Err.Clear
    Debug.Print ""

    ' ZUSAMMENFASSUNG
    Debug.Print String(70, "=")
    Debug.Print "ZUSAMMENFASSUNG"
    Debug.Print String(70, "=")
    Debug.Print "[OK] Erfolgreiche Tests: " & erfolge & "/5"
    Debug.Print "[!!] Fehlgeschlagene Tests: " & fehler & "/5"
    Debug.Print ""

    If erfolge = 5 Then
        Debug.Print "[SUCCESS] ALLE TESTS BESTANDEN!"
        Debug.Print "[INFO] Alle HTML Ansicht Buttons funktionieren!"
        MsgBox "ERFOLG!" & vbCrLf & vbCrLf & _
               "Alle 5 HTML Ansicht Buttons funktionieren!" & vbCrLf & vbCrLf & _
               "Bitte pruefen Sie die geoeffneten Browser-Tabs.", _
               vbInformation, "HTML Ansicht Test"
    Else
        Debug.Print "[WARNUNG] Einige Tests sind fehlgeschlagen"
        Debug.Print "[INFO] Siehe Fehlermeldungen oben"
        MsgBox "WARNUNG!" & vbCrLf & vbCrLf & _
               fehler & " von 5 Tests sind fehlgeschlagen." & vbCrLf & vbCrLf & _
               "Bitte pruefen Sie das Direktfenster (Strg+G) fuer Details.", _
               vbExclamation, "HTML Ansicht Test"
    End If

    Exit Sub

ErrorHandler:
    Debug.Print "[KRITISCHER FEHLER] " & Err.Description & " (Fehler: " & Err.Number & ")"
    MsgBox "Kritischer Fehler beim Testen:" & vbCrLf & vbCrLf & _
           Err.Description, vbCritical, "Test Fehler"
End Sub

' Schnelltest: Nur HTMLAnsichtOeffnen
Public Sub Quick_Test()
    Debug.Print "Quick Test: HTMLAnsichtOeffnen()"
    Dim result As Boolean
    result = HTMLAnsichtOeffnen()
    Debug.Print "Ergebnis: " & result
    MsgBox "Test abgeschlossen. Browser sollte geoeffnet sein.", vbInformation
End Sub
