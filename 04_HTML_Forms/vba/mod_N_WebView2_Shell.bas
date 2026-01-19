Attribute VB_Name = "mod_N_WebView2_Shell"
'=====================================================
' Modul: mod_N_WebView2_Shell
' Beschreibung: Oeffnet HTML-Formulare in WebView2 mit persistenter Shell/Sidebar
' Erstellt: 2026-01-03
'
' WICHTIG: Dieses Modul startet KEINEN API-Server!
' Die Kommunikation laeuft komplett ueber WebView2 Bridge.
'=====================================================

' Pfade - ANPASSEN falls noetig
Private Const HTML_FORMS3_PATH As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\"
Private Const HTML_FORMS_PATH As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\"
Private Const HTML_SHELL_PATH As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\variante_shell\shell_webview2.html"

' Standard-Fenstergroesse
Private Const DEFAULT_WIDTH As Long = 1600
Private Const DEFAULT_HEIGHT As Long = 1000

'=====================================================
' OEFFENTLICHE FUNKTIONEN - Fuer Button-Events
'=====================================================

'------------------------------------------------------
' Oeffnet die Shell mit Auftragsverwaltung
' Aufruf: =OpenShell_Auftragstamm([ID])
'------------------------------------------------------
Public Function OpenShell_Auftragstamm(Optional VA_ID As Long = 0) As Boolean
    OpenShell_Auftragstamm = OpenWebView2Shell("frm_va_Auftragstamm", VA_ID, "Auftragsverwaltung")
End Function

'------------------------------------------------------
' Oeffnet die Shell mit Mitarbeiterverwaltung
' Aufruf: =OpenShell_Mitarbeiterstamm([ID])
'------------------------------------------------------
Public Function OpenShell_Mitarbeiterstamm(Optional MA_ID As Long = 0) As Boolean
    OpenShell_Mitarbeiterstamm = OpenWebView2Shell("frm_MA_Mitarbeiterstamm", MA_ID, "Mitarbeiterverwaltung")
End Function

'------------------------------------------------------
' Oeffnet die Shell mit Kundenverwaltung
' Aufruf: =OpenShell_Kundenstamm([kun_Id])
'------------------------------------------------------
Public Function OpenShell_Kundenstamm(Optional KD_ID As Long = 0) As Boolean
    OpenShell_Kundenstamm = OpenWebView2Shell("frm_KD_Kundenstamm", KD_ID, "Kundenverwaltung")
End Function

'------------------------------------------------------
' Oeffnet die Shell mit Objektverwaltung
' Aufruf: =OpenShell_Objekt([ID])
'------------------------------------------------------
Public Function OpenShell_Objekt(Optional OB_ID As Long = 0) As Boolean
    OpenShell_Objekt = OpenWebView2Shell("frm_OB_Objekt", OB_ID, "Objektverwaltung")
End Function

'------------------------------------------------------
' Oeffnet die Shell mit Dienstplanuebersicht
' Aufruf: =OpenShell_Dienstplan()
'------------------------------------------------------
Public Function OpenShell_Dienstplan() As Boolean
    OpenShell_Dienstplan = OpenWebView2Shell("frm_N_Dienstplanuebersicht", 0, "Dienstplanuebersicht")
End Function

'------------------------------------------------------
' Oeffnet die Shell mit Planungsuebersicht
' Aufruf: =OpenShell_Planung()
'------------------------------------------------------
Public Function OpenShell_Planung() As Boolean
    OpenShell_Planung = OpenWebView2Shell("frm_VA_Planungsuebersicht", 0, "Planungsuebersicht")
End Function

'------------------------------------------------------
' Oeffnet die Shell mit beliebigem Formular
' Aufruf: =OpenShell_Form("frm_Name", ID)
'------------------------------------------------------
Public Function OpenShell_Form(FormName As String, Optional RecordID As Long = 0) As Boolean
    OpenShell_Form = OpenWebView2Shell(FormName, RecordID, FormName)
End Function

'=====================================================
' HAUPTFUNKTION - WebView2 via COM-Komponente oeffnen
'=====================================================
Private Function OpenWebView2Shell(FormName As String, RecordID As Long, WindowTitle As String) As Boolean
    On Error GoTo ErrorHandler

    Dim webView As Object
    Dim htmlPath As String
    Dim jsonData As String

    ' HTML-Pfad zusammenbauen - zuerst forms3 pruefen, dann forms
    htmlPath = ""

    If Len(FormName) > 0 Then
        ' Zuerst in forms3 suchen
        htmlPath = HTML_FORMS3_PATH & FormName & ".html"
        Debug.Print "[mod_N_WebView2_Shell] Teste Pfad 1: " & htmlPath

        If Dir(htmlPath) = "" Then
            ' Dann in forms suchen
            htmlPath = HTML_FORMS_PATH & FormName & ".html"
            Debug.Print "[mod_N_WebView2_Shell] Teste Pfad 2: " & htmlPath
        End If
    Else
        ' Kein Formularname - Shell verwenden
        htmlPath = HTML_SHELL_PATH
    End If

    If Dir(htmlPath) = "" Then
        MsgBox "HTML-Formular nicht gefunden:" & vbCrLf & FormName & ".html" & vbCrLf & vbCrLf & _
               "Gepruefte Pfade:" & vbCrLf & _
               HTML_FORMS3_PATH & FormName & ".html" & vbCrLf & _
               HTML_FORMS_PATH & FormName & ".html", vbCritical, "Fehler"
        OpenWebView2Shell = False
        Exit Function
    End If

    Debug.Print "[mod_N_WebView2_Shell] Gefundener Pfad: " & htmlPath

    ' JSON-Daten fuer initiale Uebergabe vorbereiten
    jsonData = BuildInitialJson(FormName, RecordID)

    ' WebView2 COM-Komponente erstellen
    On Error Resume Next
    Set webView = CreateObject("ConsysWebView2.WebFormHost")

    If Err.Number <> 0 Then
        ' COM nicht verfuegbar - Fallback auf Browser
        Debug.Print "[mod_N_WebView2_Shell] COM nicht verfuegbar: " & Err.Description
        On Error GoTo 0

        ' Im Browser oeffnen
        Dim url As String
        url = "file:///" & Replace(htmlPath, "\", "/")
        If RecordID > 0 Then
            url = url & "?id=" & RecordID
        End If
        Shell "cmd /c start """" """ & url & """", vbHide

        MsgBox "WebView2 COM-Komponente nicht verfuegbar." & vbCrLf & _
               "Formular wird im Browser geoeffnet." & vbCrLf & vbCrLf & _
               "Hinweis: Fuer Echtdaten-Zugriff wird die COM-Komponente benoetigt!", _
               vbExclamation, "Fallback"

        OpenWebView2Shell = True
        Exit Function
    End If
    On Error GoTo ErrorHandler

    ' Formular via COM anzeigen
    Debug.Print "[mod_N_WebView2_Shell] Oeffne via COM: " & htmlPath

    If Len(jsonData) > 2 And jsonData <> "{}" Then
        webView.ShowFormWithData htmlPath, "CONSYS - " & WindowTitle, DEFAULT_WIDTH, DEFAULT_HEIGHT, jsonData
    Else
        webView.ShowForm htmlPath, "CONSYS - " & WindowTitle, DEFAULT_WIDTH, DEFAULT_HEIGHT
    End If

    Set webView = Nothing
    OpenWebView2Shell = True
    Exit Function

ErrorHandler:
    MsgBox "Fehler beim Oeffnen des WebView2 Formulars:" & vbCrLf & Err.Description, vbCritical, "Fehler"
    Debug.Print "[mod_N_WebView2_Shell] FEHLER: " & Err.Description
    OpenWebView2Shell = False
End Function

'=====================================================
' HILFSFUNKTIONEN
'=====================================================

'------------------------------------------------------
' Baut JSON-Daten fuer initiale Uebergabe
'------------------------------------------------------
Private Function BuildInitialJson(FormName As String, RecordID As Long) As String
    Dim json As String

    ' Basis-JSON mit Formular und ID
    json = "{""form"":""" & FormName & """,""id"":" & RecordID

    ' Je nach Formular zusaetzliche Daten laden
    Select Case FormName
        Case "frm_va_Auftragstamm"
            If RecordID > 0 Then
                json = json & ",""auftrag"":" & LoadAuftragJson(RecordID)
            End If

        Case "frm_MA_Mitarbeiterstamm"
            If RecordID > 0 Then
                json = json & ",""mitarbeiter"":" & LoadMitarbeiterJson(RecordID)
            End If

        Case "frm_KD_Kundenstamm"
            If RecordID > 0 Then
                json = json & ",""kunde"":" & LoadKundeJson(RecordID)
            End If

        Case "frm_OB_Objekt"
            If RecordID > 0 Then
                json = json & ",""objekt"":" & LoadObjektJson(RecordID)
            End If
    End Select

    json = json & "}"
    BuildInitialJson = json
End Function

'------------------------------------------------------
' Laedt Auftrags-Daten als JSON
'------------------------------------------------------
Private Function LoadAuftragJson(VA_ID As Long) As String
    On Error GoTo ErrorHandler

    Dim rs As DAO.Recordset
    Dim sql As String

    sql = "SELECT * FROM tbl_VA_Auftragstamm WHERE ID = " & VA_ID
    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)

    If Not rs.EOF Then
        LoadAuftragJson = RecordToJson(rs)
    Else
        LoadAuftragJson = "{}"
    End If

    rs.Close
    Set rs = Nothing
    Exit Function

ErrorHandler:
    LoadAuftragJson = "{}"
End Function

'------------------------------------------------------
' Laedt Mitarbeiter-Daten als JSON
'------------------------------------------------------
Private Function LoadMitarbeiterJson(MA_ID As Long) As String
    On Error GoTo ErrorHandler

    Dim rs As DAO.Recordset
    Dim sql As String

    sql = "SELECT * FROM tbl_MA_Mitarbeiterstamm WHERE ID = " & MA_ID
    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)

    If Not rs.EOF Then
        LoadMitarbeiterJson = RecordToJson(rs)
    Else
        LoadMitarbeiterJson = "{}"
    End If

    rs.Close
    Set rs = Nothing
    Exit Function

ErrorHandler:
    LoadMitarbeiterJson = "{}"
End Function

'------------------------------------------------------
' Laedt Kunden-Daten als JSON
'------------------------------------------------------
Private Function LoadKundeJson(KD_ID As Long) As String
    On Error GoTo ErrorHandler

    Dim rs As DAO.Recordset
    Dim sql As String

    sql = "SELECT * FROM tbl_KD_Kundenstamm WHERE kun_Id = " & KD_ID
    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)

    If Not rs.EOF Then
        LoadKundeJson = RecordToJson(rs)
    Else
        LoadKundeJson = "{}"
    End If

    rs.Close
    Set rs = Nothing
    Exit Function

ErrorHandler:
    LoadKundeJson = "{}"
End Function

'------------------------------------------------------
' Laedt Objekt-Daten als JSON
'------------------------------------------------------
Private Function LoadObjektJson(OB_ID As Long) As String
    On Error GoTo ErrorHandler

    Dim rs As DAO.Recordset
    Dim sql As String

    sql = "SELECT * FROM tbl_OB_Objektstamm WHERE ID = " & OB_ID
    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)

    If Not rs.EOF Then
        LoadObjektJson = RecordToJson(rs)
    Else
        LoadObjektJson = "{}"
    End If

    rs.Close
    Set rs = Nothing
    Exit Function

ErrorHandler:
    LoadObjektJson = "{}"
End Function

'------------------------------------------------------
' Konvertiert einen Recordset-Datensatz zu JSON
'------------------------------------------------------
Private Function RecordToJson(rs As DAO.Recordset) As String
    On Error GoTo ErrorHandler

    Dim json As String
    Dim fld As DAO.Field
    Dim isFirst As Boolean
    Dim fldValue As String

    json = "{"
    isFirst = True

    For Each fld In rs.Fields
        If Not isFirst Then json = json & ","
        isFirst = False

        json = json & """" & fld.Name & """:"

        If IsNull(fld.Value) Then
            json = json & "null"
        Else
            Select Case fld.Type
                Case dbBoolean
                    json = json & IIf(fld.Value, "true", "false")

                Case dbByte, dbInteger, dbLong, dbSingle, dbDouble, dbCurrency
                    json = json & fld.Value

                Case dbDate
                    json = json & """" & Format(fld.Value, "yyyy-mm-dd\Thh:nn:ss") & """"

                Case Else
                    ' Text - escapen
                    fldValue = CStr(fld.Value)
                    fldValue = Replace(fldValue, "\", "\\")
                    fldValue = Replace(fldValue, """", "\""")
                    fldValue = Replace(fldValue, vbCr, "")
                    fldValue = Replace(fldValue, vbLf, "\n")
                    fldValue = Replace(fldValue, vbTab, "\t")
                    json = json & """" & fldValue & """"
            End Select
        End If
    Next fld

    json = json & "}"
    RecordToJson = json
    Exit Function

ErrorHandler:
    RecordToJson = "{}"
End Function

'=====================================================
' TEST-FUNKTION
'=====================================================
Public Sub Test_OpenShell()
    ' Test: Shell mit Auftragsverwaltung oeffnen
    OpenShell_Auftragstamm 0
End Sub
