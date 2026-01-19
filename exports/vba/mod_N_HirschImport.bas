Attribute VB_Name = "mod_N_HirschImport"

' ===================================================================
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
    Dim Monat As String
    Dim wsh As Object
    Dim exitCode As Long
    
    ' Konfiguration - NETZWERK-PFAD
    psScriptPath = "\\vConSYS01-NBG\Consys\Hirsch_Import\Hirsch_Import_System.ps1"
    
    ' Prüfen ob Skript existiert
    If Dir(psScriptPath) = "" Then
        MsgBox "FEHLER: PowerShell-Skript nicht gefunden!" & vbCrLf & vbCrLf & _
               "Pfad: " & psScriptPath & vbCrLf & vbCrLf & _
               "Prüfe:" & vbCrLf & _
               "- Netzwerkverbindung zu vConSYS01-NBG" & vbCrLf & _
               "- Zugriff auf \\vConSYS01-NBG\Consys\Hirsch_Import", _
               vbCritical, "Hirsch-Import"
        Exit Sub
    End If
    
    ' Monat abfragen - vereinfachter Dialog
    Monat = InputBox("Hirsch Aufträge für welches Monat anlegen?" & vbCrLf & vbCrLf & _
                     "Format: MM-YYYY (z.B. 01-2026)", _
                     "Hirsch-Import", _
                     Format(Date, "mm-yyyy"))
    
    ' Abbruch wenn leer oder Cancel
    If Monat = "" Then
        Exit Sub
    End If
    
    ' Validierung Monat-Format (MM-YYYY)
    If Not Monat Like "##-####" Then
        MsgBox "FEHLER: Ungültiges Monats-Format!" & vbCrLf & vbCrLf & _
               "Erwartet: MM-YYYY (z.B. 01-2026)" & vbCrLf & _
               "Eingegeben: " & Monat, _
               vbExclamation, "Hirsch-Import"
        Exit Sub
    End If
    
    ' Format umwandeln für PowerShell (MM-YYYY -> YYYY-MM)
    Dim monatForPS As String
    monatForPS = Right(Monat, 4) & "-" & Left(Monat, 2)
    
    ' WScript.Shell für synchrone Ausführung mit Exitcode
    Set wsh = CreateObject("WScript.Shell")
    
    ' PowerShell-Befehl zusammenbauen (versteckt ausführen)
    psCommand = "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & psScriptPath & """"
    psCommand = psCommand & " -Monat """ & monatForPS & """"
    
    ' Mauscursor auf Warten setzen
    DoCmd.Hourglass True
    DoEvents
    
    ' PowerShell starten und auf Beendigung warten (synchron)
    exitCode = wsh.Run(psCommand, 0, True)
    
    ' Mauscursor zurücksetzen
    DoCmd.Hourglass False
    
    ' Ergebnis prüfen
    If exitCode = 0 Then
        MsgBox "Aufträge Konzert und Clubbing erstellt", _
               vbInformation, "Hirsch-Import"
    Else
        MsgBox "Aufträge wurden nicht angelegt. Fehler siehe im PS Block", _
               vbCritical, "Hirsch-Import"
        
        ' PowerShell-Fenster sichtbar öffnen für Fehleranalyse
        Dim psCommandVisible As String
        psCommandVisible = "powershell.exe -ExecutionPolicy Bypass -NoExit -File """ & psScriptPath & """"
        psCommandVisible = psCommandVisible & " -Monat """ & monatForPS & """"
        Shell psCommandVisible, vbNormalFocus
    End If
    
    Set wsh = Nothing
    Exit Sub
    
Err_Handler:
    DoCmd.Hourglass False
    MsgBox "FEHLER beim Starten des Imports:" & vbCrLf & vbCrLf & _
           "Nr: " & Err.Number & vbCrLf & _
           "Beschreibung: " & Err.description, _
           vbCritical, "Hirsch-Import"
    Set wsh = Nothing
End Sub

Public Sub HirschImport_Download_Ordner_Oeffnen()
    '-------------------------------------------------------------------
    ' Öffnet den Download-Ordner im Explorer
    '-------------------------------------------------------------------
    
    Dim downloadPath As String
    downloadPath = "\\vConSYS01-NBG\Consys\Hirsch_Import\Downloads"
    
    On Error Resume Next
    If Dir(downloadPath, vbDirectory) = "" Then
        MkDir downloadPath
    End If
    On Error GoTo 0
    
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
    
    downloadPath = "\\vConSYS01-NBG\Consys\Hirsch_Import\Downloads"
    
    If Dir(downloadPath, vbDirectory) = "" Then
        MsgBox "Download-Ordner nicht gefunden:" & vbCrLf & vbCrLf & _
               downloadPath & vbCrLf & vbCrLf & _
               "Prüfe Netzwerkverbindung zu vConSYS01-NBG", _
               vbExclamation, "Hirsch-Import"
        Exit Sub
    End If
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set folder = fso.GetFolder(downloadPath)
    
    newestDate = #1/1/1900#
    
    For Each file In folder.files
        If LCase(fso.GetExtensionName(file.Name)) = "csv" Then
            If file.DateLastModified > newestDate Then
                newestDate = file.DateLastModified
                newestFile = file.path
            End If
        End If
    Next file
    
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




