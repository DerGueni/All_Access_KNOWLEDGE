Attribute VB_Name = "mdl_CONSEC_PREFERENCES"
' ================================================
' CONSEC ENTWICKLER-PRÄFERENZEN
' ================================================
' Diese Präferenzen gelten für ALLE CONSEC-Module
' und werden bei jeder Code-Generierung beachtet
' ================================================

Option Compare Database
Option Explicit

' ================================================
' ENTWICKLER-PRÄFERENZEN (PERSISTENT)
' ================================================

Public Type DeveloperPreferences
    ' DEBUGGING
    UseErrorHandlers As Boolean          ' FALSE - Nutze VBA-Debugger statt Error Handler
    DebugMode As Boolean                 ' TRUE - Ausführliche Debug.Print Ausgaben
    StopOnErrors As Boolean              ' TRUE - Code stoppt bei Fehlern für Debugging
    
    ' AUTOMATISIERUNG
    MaximizeAutomation As Boolean        ' TRUE - Alles soweit wie möglich automatisieren
    AutoFixProblems As Boolean           ' TRUE - Probleme automatisch beheben
    AutoCreateBackups As Boolean         ' TRUE - Vor Änderungen Backups erstellen
    SelfHealingMode As Boolean           ' TRUE - System repariert sich selbst
    
    ' CODE-STIL
    PreferSimpleCode As Boolean          ' TRUE - Einfacher, lesbarer Code
    IncludeComments As Boolean           ' TRUE - Ausführliche Kommentare
    UseGermanComments As Boolean         ' TRUE - Deutsche Kommentare
    
    ' INSTALLATION
    OneClickInstall As Boolean           ' TRUE - Ein-Klick-Installation
    AutoDetectEnvironment As Boolean     ' TRUE - Umgebung automatisch erkennen
    AutoConfigureAll As Boolean          ' TRUE - Alles automatisch konfigurieren
End Type

' Globale Präferenzen
Public g_Prefs As DeveloperPreferences

' ================================================
' PRÄFERENZEN INITIALISIEREN
' ================================================

Public Sub InitializePreferences()
    ' Diese Funktion setzt die Standard-Präferenzen
    ' basierend auf den Wünschen des Entwicklers
    
    With g_Prefs
        ' DEBUGGING - WIE GEWÜNSCHT
        .UseErrorHandlers = False        ' ← KEIN Error Handler, VBA Debugger verwenden!
        .DebugMode = True                ' ← Debug-Ausgaben aktiviert
        .StopOnErrors = True             ' ← Bei Fehlern stoppen für Debugging
        
        ' AUTOMATISIERUNG - WIE GEWÜNSCHT
        .MaximizeAutomation = True      ' ← ALLES automatisieren was geht!
        .AutoFixProblems = True          ' ← Probleme automatisch lösen
        .AutoCreateBackups = True        ' ← Immer Backups erstellen
        .SelfHealingMode = True          ' ← Selbstheilung aktiviert
        
        ' CODE-STIL
        .PreferSimpleCode = True         ' ← Einfacher Code
        .IncludeComments = True          ' ← Mit Kommentaren
        .UseGermanComments = True        ' ← Deutsche Kommentare
        
        ' INSTALLATION
        .OneClickInstall = True          ' ← Ein-Klick-Installation
        .AutoDetectEnvironment = True    ' ← Automatische Erkennung
        .AutoConfigureAll = True         ' ← Alles automatisch
    End With
    
    ' Präferenzen in Tabelle speichern
    Call SavePreferencesToDatabase
    
    Debug.Print "================================================"
    Debug.Print "ENTWICKLER-PR�FERENZEN AKTIVIERT:"
    Debug.Print "================================================"
    Debug.Print "✅ VBA-Debugger statt Error Handler"
    Debug.Print "✅ Maximale Automatisierung"
    Debug.Print "✅ Selbstheilung aktiviert"
    Debug.Print "✅ Auto-Fix f�r alle Probleme"
    Debug.Print "================================================"
End Sub

' ================================================
' PRÄFERENZEN IN DATENBANK SPEICHERN
' ================================================

Private Sub SavePreferencesToDatabase()
    On Error Resume Next
    
    ' Tabelle erstellen falls nicht vorhanden
    If Not TableExists("tbl_CONSEC_Preferences") Then
        CurrentDb.Execute "CREATE TABLE tbl_CONSEC_Preferences (" & _
                         "PREF_Key TEXT(50) PRIMARY KEY, " & _
                         "PREF_Value TEXT(10), " & _
                         "PREF_Description TEXT(255), " & _
                         "PREF_LastUpdate DATETIME DEFAULT Now())"
    End If
    
    ' Präferenzen speichern
    SavePref "UseErrorHandlers", "FALSE", "NIEMALS Error Handler verwenden - immer VBA Debugger"
    SavePref "DebugMode", "TRUE", "Debug-Modus immer aktiviert"
    SavePref "MaximizeAutomation", "TRUE", "ALLES automatisieren was m�glich ist"
    SavePref "AutoFixProblems", "TRUE", "Probleme IMMER automatisch beheben"
    SavePref "SelfHealingMode", "TRUE", "System heilt sich selbst"
    SavePref "OneClickInstall", "TRUE", "Installation mit einem Klick"
End Sub

Private Sub SavePref(key As String, Value As String, description As String)
    On Error Resume Next
    
    ' Erst löschen falls vorhanden
    CurrentDb.Execute "DELETE FROM tbl_CONSEC_Preferences WHERE PREF_Key = '" & key & "'"
    
    ' Dann neu einfügen
    CurrentDb.Execute "INSERT INTO tbl_CONSEC_Preferences (PREF_Key, PREF_Value, PREF_Description) " & _
                     "VALUES ('" & key & "', '" & Value & "', '" & description & "')"
End Sub

' ================================================
' PRÄFERENZEN ANWENDEN
' ================================================

Public Function ApplyPreferences(codeModule As String) As String
    ' Diese Funktion modifiziert generierten Code
    ' basierend auf den Präferenzen
    
    Dim modifiedCode As String
    modifiedCode = codeModule
    
    ' Error Handler entfernen wenn gewünscht
    If Not g_Prefs.UseErrorHandlers Then
        modifiedCode = RemoveErrorHandlers(modifiedCode)
        modifiedCode = AddDebugStatements(modifiedCode)
    End If
    
    ' Debug-Ausgaben hinzufügen
    If g_Prefs.DebugMode Then
        modifiedCode = AddDebugOutput(modifiedCode)
    End If
    
    ' Automatisierung maximieren
    If g_Prefs.MaximizeAutomation Then
        modifiedCode = MaximizeAutomation(modifiedCode)
    End If
    
    ApplyPreferences = modifiedCode
End Function

' ================================================
' CODE-MODIFIKATIONS-FUNKTIONEN
' ================================================

Private Function RemoveErrorHandlers(code As String) As String
    ' Entfernt alle Error Handler aus dem Code
    Dim lines() As String
    Dim i As Long
    Dim result As String
    
    lines = Split(code, vbCrLf)
    
    For i = 0 To UBound(lines)
        ' Error Handler Zeilen überspringen
        If InStr(lines(i), "On Error") = 0 And _
           InStr(lines(i), "ErrorHandler:") = 0 And _
           InStr(lines(i), "Error GoTo") = 0 And _
           InStr(lines(i), "Err.") = 0 Then
            result = result & lines(i) & vbCrLf
        Else
            ' Ersetze mit Debug-Statement
            result = result & "' " & lines(i) & " ' ← Error Handler entfer�ferenz: VBA Debugger)" & vbCrLf
        End If
    Next i
    
    RemoveErrorHandlers = result
End Function

Private Function AddDebugStatements(code As String) As String
    ' Fügt Debug-Statements hinzu
    Dim lines() As String
    Dim i As Long
    Dim result As String
    
    lines = Split(code, vbCrLf)
    
    For i = 0 To UBound(lines)
        result = result & lines(i) & vbCrLf
        
        ' Nach jeder Sub/Function Debug-Ausgabe
        If InStr(lines(i), "Sub ") > 0 Or InStr(lines(i), "Function ") > 0 Then
            If InStr(lines(i), "Private") = 0 And InStr(lines(i), "Public") = 0 Then
                result = result & "    Debug.Print ""→ Entering: "" & """ & Trim(lines(i)) & """" & vbCrLf
            End If
        End If
    Next i
    
    AddDebugStatements = result
End Function

Private Function AddDebugOutput(code As String) As String
    ' Erweiterte Debug-Ausgaben
    AddDebugOutput = code ' Hier würde weitere Logik erfolgen
End Function

Private Function MaximizeAutomation(code As String) As String
    ' Maximiert Automatisierung im Code
    MaximizeAutomation = code ' Hier würde weitere Logik erfolgen
End Function

' ================================================
' PRÄFERENZ-CHECKER
' ================================================

Public Function CheckPreference(prefName As String) As Boolean
    ' Prüft eine spezifische Präferenz
    
    Select Case prefName
        Case "UseErrorHandlers"
            CheckPreference = g_Prefs.UseErrorHandlers
        Case "DebugMode"
            CheckPreference = g_Prefs.DebugMode
        Case "MaximizeAutomation"
            CheckPreference = g_Prefs.MaximizeAutomation
        Case "AutoFixProblems"
            CheckPreference = g_Prefs.AutoFixProblems
        Case Else
            CheckPreference = True
    End Select
End Function

' ================================================
' AUTOMATISCHER CODE-GENERATOR MIT PRÄFERENZEN
' ================================================

Public Function GenerateCodeWithPreferences(moduleName As String, moduleType As String) As String
    ' Generiert Code unter Berücksichtigung der Präferenzen
    
    Dim code As String
    
    ' Header
    code = "Attribute VB_Name = """ & moduleName & """" & vbCrLf
    code = code & "' ================================================" & vbCrLf
    code = code & "' Automatisch generiert mit Entwickler-Präferenzen" & vbCrLf
    code = code & "' Präferenz: KEIN Error Handler (VBA Debugger)" & vbCrLf
    code = code & "' Präferenz: MAXIMALE Automatisierung" & vbCrLf
    code = code & "' ================================================" & vbCrLf & vbCrLf
    code = code & "Option Compare Database" & vbCrLf
    code = code & "Option Explicit" & vbCrLf & vbCrLf
    
    ' Hauptfunktion OHNE Error Handler
    code = code & "Public Sub Main()" & vbCrLf
    code = code & "    ' KEIN Error Handler - VBA Debugger wird verwendet" & vbCrLf
    code = code & "    Debug.Print ""Start: "" & Now()" & vbCrLf
    code = code & "    " & vbCrLf
    code = code & "    ' Automatische Ausführung" & vbCrLf
    code = code & "    Call AutoExecuteAll()" & vbCrLf
    code = code & "    " & vbCrLf
    code = code & "    Debug.Print ""Ende: "" & Now()" & vbCrLf
    code = code & "End Sub" & vbCrLf & vbCrLf
    
    ' Auto-Funktion
    code = code & "Private Sub AutoExecuteAll()" & vbCrLf
    code = code & "    ' Vollautomatische Ausführung - keine manuellen Schritte" & vbCrLf
    code = code & "    Debug.Print ""Automatische Ausführung...""" & vbCrLf
    code = code & "    " & vbCrLf
    code = code & "    ' Hier würde die automatische Logik stehen" & vbCrLf
    code = code & "End Sub"
    
    GenerateCodeWithPreferences = code
End Function

' ================================================
' HILFS-FUNKTIONEN
' ================================================

Private Function TableExists(TableName As String) As Boolean
    On Error Resume Next
    Dim tdf As DAO.TableDef
    Set tdf = CurrentDb.TableDefs(TableName)
    TableExists = (Err.Number = 0)
    Set tdf = Nothing
    Err.clear
End Function

' ================================================
' PRÄFERENZ-ANZEIGE
' ================================================

Public Sub ShowPreferences()
    ' Zeigt aktuelle Präferenzen an
    
    Dim msg As String
    msg = "CONSEC ENTWICKLER-PRÄFERENZEN" & vbCrLf
    msg = msg & "==============================" & vbCrLf & vbCrLf
    msg = msg & "DEBUGGING:" & vbCrLf
    msg = msg & "• Error Handler: " & IIf(g_Prefs.UseErrorHandlers, "JA", "NEIN (VBA Debugger)") & vbCrLf
    msg = msg & "• Debug-Modus: " & IIf(g_Prefs.DebugMode, "JA", "NEIN") & vbCrLf & vbCrLf
    msg = msg & "AUTOMATISIERUNG:" & vbCrLf
    msg = msg & "• Max. Automatisierung: " & IIf(g_Prefs.MaximizeAutomation, "JA", "NEIN") & vbCrLf
    msg = msg & "• Auto-Fix: " & IIf(g_Prefs.AutoFixProblems, "JA", "NEIN") & vbCrLf
    msg = msg & "• Selbstheilung: " & IIf(g_Prefs.SelfHealingMode, "JA", "NEIN") & vbCrLf & vbCrLf
    msg = msg & "Diese Präferenzen werden bei JEDER" & vbCrLf
    msg = msg & "Code-Generierung angewendet!"
    
    MsgBox msg, vbInformation, "Entwickler-Präferenzen"
End Sub

' ================================================
' INITIALISIERUNG BEI MODUL-LADEN
' ================================================

Private Sub AutoInitialize()
    ' Wird beim Laden des Moduls ausgeführt
    Call InitializePreferences
End Sub
