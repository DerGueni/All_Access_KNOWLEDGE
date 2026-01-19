Option Compare Database
Option Explicit

' ============================================
' mod_N_HTML_Opener - HTML-Formulare oeffnen
' MIT E2E INSTRUMENTIERUNG
' ============================================

' Pfad zum Python-Hilfsskript
Private Const OPENER_SCRIPT As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\open_html_shell.pyw"
Private Const SHELL_HTML As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\shell.html"

' ============================================
' HAUPT-FUNKTION: Shell mit Formular oeffnen
' ============================================
Public Sub HTML_Shell_Oeffnen(Optional ByVal startForm As String = "auftraege")
    On Error GoTo ErrorHandler

    Dim targetUrl As String
    Dim shellCmd As String

    ' E2E: Navigate Request loggen
    targetUrl = "file:///" & Replace(SHELL_HTML, "\", "/") & "?form=" & startForm
    E2E_LogNavigateRequest targetUrl, "pythonw_shell"
    E2E_LogBetriebsart "EXTERNER_BROWSER"

    ' Python-Skript aufrufen (startet API-Server + oeffnet Browser)
    shellCmd = "pythonw """ & OPENER_SCRIPT & """ " & startForm
    Shell shellCmd, vbNormalFocus

    ' E2E: Dispatched loggen
    E2E_LogNavigateDispatched True

    Exit Sub

ErrorHandler:
    E2E_LogNavigateDispatched False, Err.description
    MsgBox "Fehler beim Oeffnen der HTML-Shell: " & Err.description, vbExclamation, "CONSYS"
End Sub

' ============================================
' SHORTCUT: Auftragstamm oeffnen (mit E2E Logging)
' ============================================
Public Sub HTML_Auftragstamm_Oeffnen()
    ' E2E: Neue Run-ID und Button-Click loggen
    E2E_NewRunId
    E2E_LogButtonClick "frm_Menuefuehrung", "btn_N_HTML_Sidebar", "Auftragstamm_html"

    ' Shell oeffnen
    HTML_Shell_Oeffnen "auftraege"
End Sub

' ============================================
' Weitere Shortcuts (ohne extra Logging)
' ============================================
Public Sub HTML_Mitarbeiterstamm_Oeffnen()
    HTML_Shell_Oeffnen "mitarbeiter"
End Sub

Public Sub HTML_Kundenstamm_Oeffnen()
    HTML_Shell_Oeffnen "kunden"
End Sub

Public Sub HTML_Objekte_Oeffnen()
    HTML_Shell_Oeffnen "objekte"
End Sub

Public Sub HTML_Dienstplan_MA_Oeffnen()
    HTML_Shell_Oeffnen "dienstplan"
End Sub

Public Sub HTML_Dienstplan_Objekt_Oeffnen()
    HTML_Shell_Oeffnen "dienstplan_objekt"
End Sub

Public Sub HTML_Planungsuebersicht_Oeffnen()
    HTML_Shell_Oeffnen "planungsuebersicht"
End Sub

Public Sub HTML_Abwesenheiten_Oeffnen()
    HTML_Shell_Oeffnen "abwesenheiten"
End Sub

Public Sub HTML_Zeitkonten_Oeffnen()
    HTML_Shell_Oeffnen "zeitkonten"
End Sub

Public Sub HTML_Lohnabrechnungen_Oeffnen()
    HTML_Shell_Oeffnen "lohnabrechnungen"
End Sub

Public Sub HTML_Dashboard_Oeffnen()
    HTML_Shell_Oeffnen "dashboard"
End Sub