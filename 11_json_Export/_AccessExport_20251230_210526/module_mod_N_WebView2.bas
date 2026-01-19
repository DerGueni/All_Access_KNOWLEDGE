Option Compare Database
Option Explicit


' =====================================================
' WebView2 Browser Modul - Shell-basiert
' =====================================================
' Startet WebView2 als externe Anwendung
' Zuverlässiger als COM-Integration
' =====================================================

Private Const WEBVIEW2_EXE As String = "C:\Users\guenther.siegert\Documents\WebView2_Access\COM_Wrapper\WebView2App\bin\Release\net48\WebView2App.exe"
Private Const HTML_BASE_PATH As String = "S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\HTML\"

Public Sub WebView2_Test()
    WebView2_OpenHTML HTML_BASE_PATH & "webview2_test.html", "WebView2 Test"
End Sub

Public Sub WebView2_OpenHTML(htmlPath As String, Optional title As String = "HTML Formular")
    On Error GoTo ErrHandler

    Dim cmd As String

    If Dir(htmlPath) = "" Then
        MsgBox "Datei nicht gefunden: " & htmlPath, vbExclamation
        Exit Sub
    End If

    cmd = """" & WEBVIEW2_EXE & """ """ & htmlPath & """ --title """ & title & """"

    Debug.Print "Starte: " & cmd
    Shell cmd, vbNormalFocus

    Debug.Print "WebView2 gestartet!"
    Exit Sub

ErrHandler:
    MsgBox "Fehler: " & Err.Number & " - " & Err.description, vbCritical
End Sub

Public Sub WebView2_Dienstplan()
    WebView2_OpenHTML HTML_BASE_PATH & "frm_N_Dienstplanuebersicht.html", "Dienstplanübersicht"
End Sub

Public Sub WebView2_Mitarbeiter()
    WebView2_OpenHTML HTML_BASE_PATH & "frm_MA_Mitarbeiterstamm.html", "Mitarbeiterstamm"
End Sub

Public Sub WebView2_Kunden()
    WebView2_OpenHTML HTML_BASE_PATH & "frm_KD_Kundenstamm.html", "Kundenstamm"
End Sub

Public Sub WebView2_Auftraege()
    WebView2_OpenHTML HTML_BASE_PATH & "frm_va_Auftragstamm.html", "Auftragsstamm"
End Sub