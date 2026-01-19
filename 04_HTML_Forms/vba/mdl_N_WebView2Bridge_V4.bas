' =====================================================
' mdl_N_WebView2Bridge - WebView2 Bridge für Access
' Version 4.0 - Mit vollständiger Auftragsverwaltung
' =====================================================
Option Compare Database
Option Explicit

' =====================================================
' KONFIGURATION
' =====================================================
Private Const EXE_PATH As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\WebView2_Access\COM_Wrapper\ConsysWebView2App\bin\Release\ConsysWebView2App.exe"
Private Const HTML_BASE_PATH As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\"

' =====================================================
' ÖFFENTLICHE FUNKTIONEN - Formulare öffnen
' =====================================================

' Öffnet die Auftragsverwaltung als HTML mit allen Daten
Public Sub OpenAuftragstammHTML_V2(Optional FilterDatum As Date = 0)
    Dim htmlPath As String
    Dim jsonData As String
    
    htmlPath = HTML_BASE_PATH & "frm_N_VA_Auftragstamm.html"
    
    If Dir(htmlPath) = "" Then
        MsgBox "HTML-Datei nicht gefunden: " & htmlPath, vbCritical
        Exit Sub
    End If
    
    ' Wenn kein Datum angegeben, ab heute
    If FilterDatum = 0 Then FilterDatum = Date
    
    ' Alle benötigten Daten laden
    jsonData = LoadAuftragstammData(FilterDatum)
    
    OpenWebViewForm htmlPath, "Auftragsverwaltung", 1600, 1000, jsonData
End Sub

' =====================================================
' KERN-FUNKTION: WebView-Formular öffnen
' =====================================================
Public Sub OpenWebViewForm(htmlPath As String, title As String, width As Long, height As Long, Optional jsonData As String = "{}")
    Dim cmd As String
    Dim dataFile As String
    
    ' Prüfe ob EXE existiert
    If Dir(EXE_PATH) = "" Then
        MsgBox "WebView2 App nicht gefunden:" & vbCrLf & EXE_PATH, vbCritical, "Fehler"
        Exit Sub
    End If
    
    ' JSON-Daten in temporäre Datei schreiben
    dataFile = Environ("TEMP") & "\consys_webview_data.json"
    WriteTextFile dataFile, jsonData
    
    ' Kommandozeile bauen
    cmd = """" & EXE_PATH & """ " & _
          "-html """ & htmlPath & """ " & _
          "-title """ & title & """ " & _
          "-width " & width & " " & _
          "-height " & height & " " & _
          "-datafile """ & dataFile & """"
    
    ' Starte den Prozess
    Shell cmd, vbNormalFocus
    
    Debug.Print "WebView gestartet mit Daten-Datei: " & dataFile
End Sub

' =====================================================
' DATEN-SERVICE: Lädt alle Daten für Auftragsverwaltung
' =====================================================

' Lädt alle benötigten Daten für die Auftragsverwaltung als JSON
Public Function LoadAuftragstammData(FilterDatum As Date) As String
    On Error GoTo ErrorHandler
    
    Dim db As DAO.Database
    Dim result As String
    
    Set db = CurrentDb
    
    result = "{"
    
    ' 1. Aufträge ab Datum
    result = result & """auftraege"":" & LoadAuftraege(db, FilterDatum) & ","
    
    ' 2. Mitarbeiter (für Dropdowns)
    result = result & """mitarbeiter"":" & LoadMitarbeiterListe(db) & ","
    
    ' 3. Orte (für Dropdown)
    result = result & """orte"":" & LoadOrte(db) & ","
    
    ' 4. Objekte (für Dropdown)
    result = result & """objekte"":" & LoadObjekte(db) & ","
    
    ' 5. Kunden/Auftraggeber (für Dropdown)
    result = result & """kunden"":" & LoadKunden(db) & ","
    
    ' 6. Dienstkleidung-Optionen
    result = result & """kleidung"":[""Consec"",""schwarz neutral"",""Anzug"",""Anzug weißes Hemd""],"
    
    ' 7. Status-Liste
    result = result & """status"":" & LoadStatusListe(db)
    
    result = result & "}"
    
    LoadAuftragstammData = result
    Exit Function
    
ErrorHandler:
    LoadAuftragstammData = "{""error"":""" & Err.Description & """}"
End Function

' Lädt Aufträge ab einem bestimmten Datum
Private Function LoadAuftraege(db As DAO.Database, FilterDatum As Date) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    sql = "SELECT a.ID, a.Auftrag, a.Objekt, a.Ort, a.Dat_VA_Von, a.Dat_VA_Bis, " & _
          "a.Veranst_Status_ID, a.Kun_Firma, a.Treffpunkt, a.Dienstkleidung, " & _
          "a.Ansprechpartner, a.Fahrtkosten, a.Objekt_ID, a.Veranstalter_ID, " & _
          "a.Autosend_EL, a.Erst_von, a.Erst_am, a.Aend_von, a.Aend_am " & _
          "FROM tbl_VA_Auftragstamm AS a " & _
          "WHERE a.Dat_VA_Von >= #" & Format(FilterDatum, "yyyy-mm-dd") & "# " & _
          "ORDER BY a.Dat_VA_Von"
    
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        
        result = result & "{"
        result = result & """id"":" & rs!ID & ","
        result = result & """auftrag"":""" & EscapeJson(Nz(rs!Auftrag, "")) & ""","
        result = result & """objekt"":""" & EscapeJson(Nz(rs!Objekt, "")) & ""","
        result = result & """ort"":""" & EscapeJson(Nz(rs!Ort, "")) & ""","
        result = result & """datVon"":""" & Format(rs!Dat_VA_Von, "dd.mm.yyyy") & ""","
        result = result & """datBis"":""" & Format(Nz(rs!Dat_VA_Bis, rs!Dat_VA_Von), "dd.mm.yyyy") & ""","
        result = result & """statusId"":" & Nz(rs!Veranst_Status_ID, 1) & ","
        result = result & """auftraggeber"":""" & EscapeJson(Nz(rs!Kun_Firma, "")) & ""","
        result = result & """treffpunkt"":""" & EscapeJson(Nz(rs!Treffpunkt, "")) & ""","
        result = result & """kleidung"":""" & EscapeJson(Nz(rs!Dienstkleidung, "")) & ""","
        result = result & """ansprech"":""" & EscapeJson(Nz(rs!Ansprechpartner, "")) & ""","
        result = result & """fahrtkosten"":" & Replace(Nz(rs!Fahrtkosten, 0), ",", ".") & ","
        result = result & """objektId"":" & Nz(rs!Objekt_ID, 0) & ","
        result = result & """veranstalterId"":" & Nz(rs!Veranstalter_ID, 0) & ","
        result = result & """autosend"":" & IIf(Nz(rs!Autosend_EL, False), "true", "false") & ","
        result = result & """soll"":" & GetAuftragSoll(db, rs!ID) & ","
        result = result & """ist"":" & GetAuftragIst(db, rs!ID) & ","
        result = result & """wochentag"":""" & GetWochentag(rs!Dat_VA_Von) & """"
        result = result & "}"
        
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    
    LoadAuftraege = result
End Function

' Ermittelt Soll-Anzahl Mitarbeiter für einen Auftrag
Private Function GetAuftragSoll(db As DAO.Database, VA_ID As Long) As Long
    Dim rs As DAO.Recordset
    Dim sql As String
    
    sql = "SELECT Sum(MA_Anzahl) AS Summe FROM tbl_VA_Start WHERE VA_ID = " & VA_ID
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    If Not rs.EOF Then
        GetAuftragSoll = Nz(rs!Summe, 0)
    Else
        GetAuftragSoll = 0
    End If
    
    rs.Close
End Function

' Ermittelt Ist-Anzahl zugeordneter Mitarbeiter
Private Function GetAuftragIst(db As DAO.Database, VA_ID As Long) As Long
    Dim rs As DAO.Recordset
    Dim sql As String
    
    sql = "SELECT Count(*) AS Anzahl FROM tbl_MA_VA_Zuordnung WHERE VA_ID = " & VA_ID & " AND MA_ID > 0"
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    If Not rs.EOF Then
        GetAuftragIst = Nz(rs!Anzahl, 0)
    Else
        GetAuftragIst = 0
    End If
    
    rs.Close
End Function

' Gibt Wochentag-String zurück
Private Function GetWochentag(d As Date) As String
    Dim wt As String
    
    Select Case Weekday(d, vbMonday)
        Case 1: wt = "Mo"
        Case 2: wt = "Di"
        Case 3: wt = "Mi"
        Case 4: wt = "Do"
        Case 5: wt = "Fr"
        Case 6: wt = "Sa"
        Case 7: wt = "So"
    End Select
    
    GetWochentag = wt & ". " & Format(d, "dd.mm.yy")
End Function

' Lädt Mitarbeiter-Liste
Private Function LoadMitarbeiterListe(db As DAO.Database) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    sql = "SELECT MA_ID, MA_Nachname, MA_Vorname, MA_Ort " & _
          "FROM tbl_MA_Mitarbeiterstamm " & _
          "WHERE MA_aktiv = True " & _
          "ORDER BY MA_Nachname, MA_Vorname"
    
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        
        result = result & "{"
        result = result & """id"":" & rs!MA_ID & ","
        result = result & """name"":""" & EscapeJson(rs!MA_Nachname & ", " & rs!MA_Vorname) & ""","
        result = result & """ort"":""" & EscapeJson(Nz(rs!MA_Ort, "")) & """"
        result = result & "}"
        
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    
    LoadMitarbeiterListe = result
End Function

' Lädt Orte
Private Function LoadOrte(db As DAO.Database) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    sql = "SELECT DISTINCT Ort FROM tbl_VA_Auftragstamm WHERE Ort Is Not Null ORDER BY Ort"
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & """" & EscapeJson(rs!Ort) & """"
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    
    LoadOrte = result
End Function

' Lädt Objekte
Private Function LoadObjekte(db As DAO.Database) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    sql = "SELECT ID, OB_Name, OB_Ort FROM tbl_OB_Objekt WHERE OB_aktiv = True ORDER BY OB_Name"
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{"
        result = result & """id"":" & rs!ID & ","
        result = result & """name"":""" & EscapeJson(rs!OB_Name) & ""","
        result = result & """ort"":""" & EscapeJson(Nz(rs!OB_Ort, "")) & """"
        result = result & "}"
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    
    LoadObjekte = result
End Function

' Lädt Kunden/Auftraggeber
Private Function LoadKunden(db As DAO.Database) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    sql = "SELECT KD_ID, KD_Firma FROM tbl_KD_Kundenstamm WHERE KD_Aktiv = True ORDER BY KD_Firma"
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{"
        result = result & """id"":" & rs!KD_ID & ","
        result = result & """firma"":""" & EscapeJson(rs!KD_Firma) & """"
        result = result & "}"
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    
    LoadKunden = result
End Function

' Lädt Status-Liste
Private Function LoadStatusListe(db As DAO.Database) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    sql = "SELECT ID, Status_Bezeichnung FROM tbl_VA_Status ORDER BY ID"
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{"
        result = result & """id"":" & rs!ID & ","
        result = result & """name"":""" & EscapeJson(rs!Status_Bezeichnung) & """"
        result = result & "}"
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    
    LoadStatusListe = result
End Function

' =====================================================
' AUFTRAG-DETAILS MIT SCHICHTEN UND ZUORDNUNGEN
' =====================================================

' Lädt Detail-Daten für einen einzelnen Auftrag
Public Function LoadAuftragDetails(VA_ID As Long, Optional VADatum As Date = 0) As String
    On Error GoTo ErrorHandler
    
    Dim db As DAO.Database
    Dim result As String
    
    Set db = CurrentDb
    
    result = "{"
    result = result & """schichten"":" & LoadSchichten(db, VA_ID, VADatum) & ","
    result = result & """zuordnungen"":" & LoadZuordnungen(db, VA_ID, VADatum)
    result = result & "}"
    
    LoadAuftragDetails = result
    Exit Function
    
ErrorHandler:
    LoadAuftragDetails = "{""error"":""" & Err.Description & """}"
End Function

' Lädt Schichten für einen Auftrag
Private Function LoadSchichten(db As DAO.Database, VA_ID As Long, VADatum As Date) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    If VADatum > 0 Then
        sql = "SELECT ID, MA_Anzahl, VA_Start, VA_Ende, MA_Anzahl_Ist, VADatum " & _
              "FROM tbl_VA_Start " & _
              "WHERE VA_ID = " & VA_ID & " AND VADatum = #" & Format(VADatum, "yyyy-mm-dd") & "# " & _
              "ORDER BY VA_Start"
    Else
        sql = "SELECT ID, MA_Anzahl, VA_Start, VA_Ende, MA_Anzahl_Ist, VADatum " & _
              "FROM tbl_VA_Start " & _
              "WHERE VA_ID = " & VA_ID & " " & _
              "ORDER BY VADatum, VA_Start"
    End If
    
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        
        result = result & "{"
        result = result & """id"":" & rs!ID & ","
        result = result & """anzahl"":" & Nz(rs!MA_Anzahl, 0) & ","
        result = result & """von"":""" & Format(rs!VA_Start, "hh:nn") & ""","
        result = result & """bis"":""" & Format(rs!VA_Ende, "hh:nn") & ""","
        result = result & """istAnzahl"":" & Nz(rs!MA_Anzahl_Ist, 0) & ","
        result = result & """datum"":""" & Format(rs!VADatum, "dd.mm.yyyy") & """"
        result = result & "}"
        
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    
    LoadSchichten = result
End Function

' Lädt Zuordnungen für einen Auftrag
Private Function LoadZuordnungen(db As DAO.Database, VA_ID As Long, VADatum As Date) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    If VADatum > 0 Then
        sql = "SELECT z.ID, z.PosNr, z.MA_ID, z.MA_Start, z.MA_Ende, z.MA_Brutto_Std, " & _
              "z.PKW, z.Bemerkungen, z.Info, z.Einsatzleitung, z.Rch_Erstellt, " & _
              "m.MA_Nachname, m.MA_Vorname " & _
              "FROM tbl_MA_VA_Zuordnung z " & _
              "LEFT JOIN tbl_MA_Mitarbeiterstamm m ON z.MA_ID = m.MA_ID " & _
              "WHERE z.VA_ID = " & VA_ID & " AND z.VADatum = #" & Format(VADatum, "yyyy-mm-dd") & "# " & _
              "ORDER BY z.PosNr"
    Else
        sql = "SELECT z.ID, z.PosNr, z.MA_ID, z.MA_Start, z.MA_Ende, z.MA_Brutto_Std, " & _
              "z.PKW, z.Bemerkungen, z.Info, z.Einsatzleitung, z.Rch_Erstellt, " & _
              "m.MA_Nachname, m.MA_Vorname, z.VADatum " & _
              "FROM tbl_MA_VA_Zuordnung z " & _
              "LEFT JOIN tbl_MA_Mitarbeiterstamm m ON z.MA_ID = m.MA_ID " & _
              "WHERE z.VA_ID = " & VA_ID & " " & _
              "ORDER BY z.VADatum, z.MA_Start"
    End If
    
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        
        result = result & "{"
        result = result & """id"":" & rs!ID & ","
        result = result & """lfd"":" & Nz(rs!PosNr, 0) & ","
        result = result & """maId"":" & Nz(rs!MA_ID, 0) & ","
        result = result & """maName"":""" & EscapeJson(Nz(rs!MA_Nachname, "") & ", " & Nz(rs!MA_Vorname, "")) & ""","
        result = result & """von"":""" & Format(rs!MA_Start, "hh:nn") & ""","
        result = result & """bis"":""" & Format(rs!MA_Ende, "hh:nn") & ""","
        result = result & """std"":" & Replace(Nz(rs!MA_Brutto_Std, 0), ",", ".") & ","
        result = result & """pkw"":" & Replace(Nz(rs!PKW, 0), ",", ".") & ","
        result = result & """bem"":""" & EscapeJson(Nz(rs!Bemerkungen, "")) & ""","
        result = result & """info"":""" & EscapeJson(Nz(rs!Info, "")) & ""","
        result = result & """einsatzleitung"":" & IIf(Nz(rs!Einsatzleitung, False), "true", "false") & ","
        result = result & """rchErstellt"":" & IIf(Nz(rs!Rch_Erstellt, False), "true", "false")
        result = result & "}"
        
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    
    LoadZuordnungen = result
End Function

' =====================================================
' JSON-HILFSFUNKTIONEN
' =====================================================

' Escaped JSON-Sonderzeichen
Private Function EscapeJson(val As String) As String
    Dim result As String
    result = val
    result = Replace(result, "\", "\\")
    result = Replace(result, """", "\""")
    result = Replace(result, vbCrLf, "\n")
    result = Replace(result, vbCr, "\n")
    result = Replace(result, vbLf, "\n")
    result = Replace(result, vbTab, "\t")
    EscapeJson = result
End Function

' =====================================================
' DATEI-HILFSFUNKTIONEN
' =====================================================

' Schreibt Text in eine UTF-8 Datei
Private Sub WriteTextFile(filePath As String, content As String)
    Dim objStream As Object
    Set objStream = CreateObject("ADODB.Stream")
    objStream.Type = 2 ' adTypeText
    objStream.Charset = "UTF-8"
    objStream.Open
    objStream.WriteText content
    objStream.SaveToFile filePath, 2 ' adSaveCreateOverWrite
    objStream.Close
    Set objStream = Nothing
End Sub
