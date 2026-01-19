
' VBA-Modul für Hirsch-Import-Button
' In Access: mdl_Hirsch_Import
' ===================================================================

Option Compare Database
Option Explicit

Public Sub HirschImport_Starten()
    '-------------------------------------------------------------------
    ' Startet den Hirsch-Import über PowerShell
    ' Verwendung: Button in Formular mit OnClick-Event
    '-------------------------------------------------------------------
    
    On Error GoTo Err_Handler
    
    Dim psScriptPath As String
    Dim psCommand As String
    Dim testModus As Boolean
    Dim Monat As String
    
    ' Konfiguration - NETZWERK-PFAD
    psScriptPath = "\\vConSYS01-NBG\Consys\Hirsch_Import\Hirsch_Import_System.ps1"
    
    ' Prüfen ob Skript existiert
    If Dir(psScriptPath) = "" Then
        MsgBox "FEHLER: PowerShell-Skript nicht gefunden!" & vbCrLf & vbCrLf & _
               "Pfad: " & psScriptPath & vbCrLf & vbCrLf & _
               "Prüfe:" & vbCrLf & _
               "• Netzwerkverbindung zu vConSYS01-NBG" & vbCrLf & _
               "• Zugriff auf \\vConSYS01-NBG\Consys\Hirsch_Import", _
               vbCritical, "Hirsch-Import"
        Exit Sub
    End If
    
    ' Dialog: Test-Modus oder Produktiv?
    Dim result As VbMsgBoxResult
    result = MsgBox("Hirsch-Import starten?" & vbCrLf & vbCrLf & _
                    "JA = Produktiv-Import (schreibt in Datenbank)" & vbCrLf & _
                    "NEIN = Test-Modus (nur Anzeige, kein Import)" & vbCrLf & _
                    "ABBRECHEN = Abbruch", _
                    vbQuestion + vbYesNoCancel, "Hirsch-Import")
    
    Select Case result
        Case vbYes
            testModus = False
        Case vbNo
            testModus = True
        Case vbCancel
            Exit Sub
    End Select
    
    ' Monat abfragen
    Monat = InputBox("Monat für Import:" & vbCrLf & vbCrLf & _
                     "Format: YYYY-MM (z.B. 2025-11)" & vbCrLf & _
                     "Leer = aktueller Monat", _
                     "Hirsch-Import", _
                     Format(Date, "yyyy-mm"))
    
    If Monat = "" Then
        Monat = Format(Date, "yyyy-mm")
    End If
    
    ' Validierung Monat-Format
    If Not Monat Like "####-##" Then
        MsgBox "FEHLER: Ungültiges Monats-Format!" & vbCrLf & vbCrLf & _
               "Erwartet: YYYY-MM (z.B. 2025-11)" & vbCrLf & _
               "Eingegeben: " & Monat, _
               vbExclamation, "Hirsch-Import"
        Exit Sub
    End If
    
    ' PowerShell-Befehl zusammenbauen
    psCommand = "powershell.exe -ExecutionPolicy Bypass -NoExit -File """ & psScriptPath & """"
    psCommand = psCommand & " -Monat """ & Monat & """"
    
    If testModus Then
        psCommand = psCommand & " -TestModus"
    End If
    
    ' Hinweis anzeigen
    If testModus Then
        MsgBox "Test-Modus wird gestartet..." & vbCrLf & vbCrLf & _
               "Monat: " & Monat & vbCrLf & _
               "Keine Daten werden in Access geschrieben." & vbCrLf & vbCrLf & _
               "Das PowerShell-Fenster zeigt die Ergebnisse.", _
               vbInformation, "Hirsch-Import"
    Else
        MsgBox "PRODUKTIV-Import wird gestartet..." & vbCrLf & vbCrLf & _
               "Monat: " & Monat & vbCrLf & vbCrLf & _
               "?? ACHTUNG: Aufträge werden in Datenbank erstellt!" & vbCrLf & vbCrLf & _
               "Das PowerShell-Fenster zeigt den Fortschritt.", _
               vbExclamation, "Hirsch-Import"
    End If
    
    ' PowerShell starten
    Shell psCommand, vbNormalFocus
    
    ' Erfolgs-Meldung
    MsgBox "Hirsch-Import wurde gestartet!" & vbCrLf & vbCrLf & _
           "Prüfe das PowerShell-Fenster für Details." & vbCrLf & vbCrLf & _
           "Nach Abschluss:" & vbCrLf & _
           "• Bei Test-Modus: Ergebnisse prüfen" & vbCrLf & _
           "• Bei Produktiv: Aufträge in qry_lst_Row_Auftrag prüfen", _
           vbInformation, "Import läuft..."
    
    Exit Sub
    
Err_Handler:
    MsgBox "FEHLER beim Starten des Imports:" & vbCrLf & vbCrLf & _
           "Nr: " & Err.Number & vbCrLf & _
           "Beschreibung: " & Err.description, _
           vbCritical, "Hirsch-Import"
End Sub

Public Sub HirschImport_Download_Ordner_Oeffnen()
    '-------------------------------------------------------------------
    ' Öffnet den Download-Ordner im Explorer
    '-------------------------------------------------------------------
    
    Dim downloadPath As String
    ' Download-Ordner jetzt im Netzwerk
    downloadPath = "\\vConSYS01-NBG\Consys\Hirsch_Import\Downloads"
    
    ' Ordner erstellen falls nicht vorhanden (benötigt Schreibrechte)
    On Error Resume Next
    If Dir(downloadPath, vbDirectory) = "" Then
        MkDir downloadPath
    End If
    On Error GoTo 0
    
    ' Explorer öffnen
    Shell "explorer.exe """ & downloadPath & """", vbNormalFocus
End Sub

Public Sub HirschImport_Letzten_CSV_Oeffnen()
    '-------------------------------------------------------------------
    ' Öffnet den zuletzt heruntergeladenen CSV-Export
    '-------------------------------------------------------------------
    
    On Error GoTo Err_Handler
    
    Dim downloadPath As String
    Dim fso As Object
    Dim folder As Object
    Dim file As Object
    Dim newestFile As String
    Dim newestDate As Date
    
    ' Download-Ordner jetzt im Netzwerk
    downloadPath = "\\vConSYS01-NBG\Consys\Hirsch_Import\Downloads"
    
    ' Prüfen ob Ordner existiert
    If Dir(downloadPath, vbDirectory) = "" Then
        MsgBox "Download-Ordner nicht gefunden:" & vbCrLf & vbCrLf & _
               downloadPath & vbCrLf & vbCrLf & _
               "Prüfe Netzwerkverbindung zu vConSYS01-NBG", _
               vbExclamation, "Hirsch-Import"
        Exit Sub
    End If
    
    ' FileSystemObject erstellen
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set folder = fso.GetFolder(downloadPath)
    
    ' Neueste CSV-Datei finden
    newestDate = #1/1/1900#
    
    For Each file In folder.files
        If LCase(fso.GetExtensionName(file.Name)) = "csv" Then
            If file.DateLastModified > newestDate Then
                newestDate = file.DateLastModified
                newestFile = file.path
            End If
        End If
    Next file
    
    ' Datei öffnen
    If newestFile <> "" Then
        Shell "explorer.exe """ & newestFile & """", vbNormalFocus
        MsgBox "CSV-Datei wird in Excel geöffnet:" & vbCrLf & vbCrLf & _
               fso.GetFileName(newestFile) & vbCrLf & vbCrLf & _
               "Erstellt: " & Format(newestDate, "dd.mm.yyyy hh:nn"), _
               vbInformation, "Hirsch-Import"
    Else
        MsgBox "Keine CSV-Dateien gefunden in:" & vbCrLf & vbCrLf & _
               downloadPath, _
               vbInformation, "Hirsch-Import"
    End If
    
    Exit Sub
    
Err_Handler:
    MsgBox "FEHLER beim Öffnen der CSV-Datei:" & vbCrLf & vbCrLf & _
           "Nr: " & Err.Number & vbCrLf & _
           "Beschreibung: " & Err.description, _
           vbCritical, "Hirsch-Import"
End Sub

' ===================================================================
' ANLEITUNG FÜR FORMULAR-BUTTON
' ===================================================================
'
' 1. VBA-Modul importieren:
'    - Datei öffnen: mdl_Hirsch_Import.bas
'    - In Access: Datei ? Importieren ? VBA-Modul
'
' 2. Button in Formular erstellen (z.B. frm_VA_Auftragsliste):
'    - Name: btnHirschImport
'    - Beschriftung: "?? Hirsch Import"
'    - OnClick-Event: [Event Procedure]
'
' 3. Im Code-Editor des Formulars:
'    Private Sub btnHirschImport_Click()
'        Call HirschImport_Starten
'    End Sub
'
' ===================================================================
' NETZWERK-PFAD KONFIGURATION
' ===================================================================
'
' Skript-Pfad: \\vConSYS01-NBG\Consys\Hirsch_Import\Hirsch_Import_System.ps1
' Downloads:   \\vConSYS01-NBG\Consys\Hirsch_Import\Downloads\
'
' Voraussetzungen:
' • Netzwerkverbindung zu vConSYS01-NBG
' • Leserechte für Hirsch_Import-Ordner
' • Schreibrechte für Downloads-Unterordner