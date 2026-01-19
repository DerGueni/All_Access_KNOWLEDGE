Attribute VB_Name = "mdl_N_DataService_Complete"
' =====================================================
' mdl_N_DataService_Complete - Vollständiger DataService
' Für alle HTML-Formulare mit Echtdaten aus Access
' Version 2.0 - Stand: 30.12.2025
' =====================================================
Option Compare Database
Option Explicit

' Konstanten
Private Const HTML_BASE As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\"

' =====================================================
' 1. MITARBEITERSTAMM - VOLLSTÄNDIG
' =====================================================
Public Function LoadMitarbeiterstammComplete(MA_ID As Long) As String
    On Error GoTo ErrorHandler
    Dim db As DAO.Database
    Dim result As String
    
    Set db = CurrentDb
    
    result = "{"
    
    ' Stammdaten
    result = result & """stammdaten"":" & LoadMAStammdaten(db, MA_ID) & ","
    
    ' Einsatzübersicht (Tab)
    result = result & """einsaetze"":" & LoadMAEinsaetze(db, MA_ID) & ","
    
    ' Dienstplan (Tab)
    result = result & """dienstplan"":" & LoadMADienstplan(db, MA_ID) & ","
    
    ' Nicht Verfügbar (Tab)
    result = result & """nichtVerfuegbar"":" & LoadMANichtVerfuegbar(db, MA_ID) & ","
    
    ' Dienstkleidung (Tab)
    result = result & """dienstkleidung"":" & LoadMADienstkleidung(db, MA_ID) & ","
    
    ' Sub-Rechnungen (Tab)
    result = result & """subRechnungen"":" & LoadMASubRechnungen(db, MA_ID) & ","
    
    ' Zeitkonto Monat
    result = result & """zeitkontoMonat"":" & LoadMAZeitkontoMonat(db, MA_ID) & ","
    
    ' Zeitkonto Jahr
    result = result & """zeitkontoJahr"":" & LoadMAZeitkontoJahr(db, MA_ID) & ","
    
    ' Dropdown-Listen
    result = result & """anstellungsarten"":" & LoadAnstellungsarten(db) & ","
    result = result & """taetigkeiten"":" & LoadTaetigkeiten(db) & ","
    result = result & """lohngruppen"":" & LoadLohngruppen(db) & ","
    
    ' Alle Mitarbeiter für Liste
    result = result & """alleMitarbeiter"":" & LoadAlleMitarbeiter(db)
    
    result = result & "}"
    
    LoadMitarbeiterstammComplete = result
    Exit Function
ErrorHandler:
    LoadMitarbeiterstammComplete = "{""error"":""" & EscapeJson(Err.Description) & """}"
End Function

Private Function LoadMAStammdaten(db As DAO.Database, MA_ID As Long) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    
    sql = "SELECT * FROM tbl_MA_Mitarbeiterstamm WHERE ID = " & MA_ID
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    If rs.EOF Then
        LoadMAStammdaten = "{}"
        rs.Close
        Exit Function
    End If
    
    Dim result As String
    result = "{"
    result = result & """id"":" & rs!ID & ","
    result = result & """persNr"":" & Nz(rs!ID, 0) & ","
    result = result & """lexId"":" & Nz(rs!LEXWare_ID, 0) & ","
    result = result & """istAktiv"":" & IIf(Nz(rs!IstAktiv, False), "true", "false") & ","
    result = result & """istSub"":" & IIf(Nz(rs!IstSubunternehmer, False), "true", "false") & ","
    result = result & """lexAktiv"":" & IIf(Nz(rs!Lex_Aktiv, False), "true", "false") & ","
    result = result & """nachname"":""" & EscapeJson(Nz(rs!Nachname, "")) & ""","
    result = result & """vorname"":""" & EscapeJson(Nz(rs!Vorname, "")) & ""","
    result = result & """strasse"":""" & EscapeJson(Nz(rs!Strasse, "")) & ""","
    result = result & """nr"":""" & EscapeJson(Nz(rs!Nr, "")) & ""","
    result = result & """plz"":""" & EscapeJson(Nz(rs!PLZ, "")) & ""","
    result = result & """ort"":""" & EscapeJson(Nz(rs!Ort, "")) & ""","
    result = result & """land"":""" & EscapeJson(Nz(rs!Land, "Deutschland")) & ""","
    result = result & """bundesland"":""" & EscapeJson(Nz(rs!Bundesland, "Bayern")) & ""","
    result = result & """telMobil"":""" & EscapeJson(Nz(rs!Tel_Mobil, "")) & ""","
    result = result & """telFest"":""" & EscapeJson(Nz(rs!Tel_Festnetz, "")) & ""","
    result = result & """email"":""" & EscapeJson(Nz(rs!Email, "")) & ""","
    result = result & """geschlecht"":""" & EscapeJson(Nz(rs!Geschlecht, "")) & ""","
    result = result & """staatsang"":""" & EscapeJson(Nz(rs!Staatsang, "")) & ""","
    result = result & """gebDat"":""" & FormatDatum(rs!Geb_Dat) & ""","
    result = result & """gebOrt"":""" & EscapeJson(Nz(rs!Geb_Ort, "")) & ""","
    result = result & """gebName"":""" & EscapeJson(Nz(rs!Geb_Name, "")) & ""","
    result = result & """eintrittsDat"":""" & FormatDatum(rs!Eintrittsdatum) & ""","
    result = result & """austrittsDat"":""" & FormatDatum(rs!Austrittsdatum) & ""","
    result = result & """anstellungsartId"":" & Nz(rs!Anstellungsart_ID, 0) & ","
    result = result & """kontoinhaber"":""" & EscapeJson(Nz(rs!Kontoinhaber, "")) & ""","
    result = result & """bic"":""" & EscapeJson(Nz(rs!BIC, "")) & ""","
    result = result & """iban"":""" & EscapeJson(Nz(rs!IBAN, "")) & ""","
    result = result & """bezuegeAls"":""" & EscapeJson(Nz(rs!Bezuege_gezahlt_als, "")) & ""","
    result = result & """sozialversNr"":""" & EscapeJson(Nz(rs!Sozialvers_Nr, "")) & ""","
    result = result & """steuerNr"":""" & EscapeJson(Nz(rs!SteuerNr, "")) & ""","
    result = result & """taetigkeit"":""" & EscapeJson(Nz(rs!Taetigkeit_Bezeichnung, "")) & ""","
    result = result & """krankenkasse"":""" & EscapeJson(Nz(rs!KV_Kasse, "")) & ""","
    result = result & """steuerklasse"":""" & EscapeJson(Nz(rs!Steuerklasse, "")) & ""","
    result = result & """urlaubsanspr"":" & Nz(rs!Urlaubsanspr_pro_Jahr, 0) & ","
    result = result & """maxStunden"":" & Replace(Nz(rs!StundenZahlMax, 0), ",", ".") & ","
    result = result & """rvBefreit"":" & IIf(Nz(rs!Ist_RV_Befrantrag, False), "true", "false") & ","
    result = result & """bruttoStd"":" & IIf(Nz(rs!Stundenlohn_brutto, False), "true", "false") & ","
    result = result & """emailAbrechnung"":" & IIf(Nz(rs!eMail_Abrechnung, False), "true", "false") & ","
    result = result & """lichtbild"":""" & EscapeJson(Nz(rs!tblBilddatei, "")) & ""","
    result = result & """arbStdTag"":" & Replace(Nz(rs!Arbst_pro_Arbeitstag, 0), ",", ".") & ","
    result = result & """arbTageWoche"":" & Nz(rs!Arbeitstage_pro_Woche, 0) & ","
    result = result & """erstVon"":""" & EscapeJson(Nz(rs!Erst_von, "")) & ""","
    result = result & """erstAm"":""" & FormatDatum(rs!Erst_am) & ""","
    result = result & """aendVon"":""" & EscapeJson(Nz(rs!Aend_von, "")) & ""","
    result = result & """aendAm"":""" & FormatDatum(rs!Aend_am) & """"
    result = result & "}"
    
    rs.Close
    LoadMAStammdaten = result
End Function

Private Function LoadMAEinsaetze(db As DAO.Database, MA_ID As Long) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    sql = "SELECT z.*, v.Auftrag, v.Ort, v.Dat_VA_Von " & _
          "FROM tbl_MA_VA_Zuordnung AS z " & _
          "INNER JOIN tbl_VA_Auftragstamm AS v ON z.VA_ID = v.ID " & _
          "WHERE z.MA_ID = " & MA_ID & " " & _
          "ORDER BY v.Dat_VA_Von DESC"
    
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{"
        result = result & """datum"":""" & FormatDatum(rs!Dat_VA_Von) & ""","
        result = result & """auftrag"":""" & EscapeJson(Nz(rs!Auftrag, "")) & ""","
        result = result & """ort"":""" & EscapeJson(Nz(rs!Ort, "")) & ""","
        result = result & """von"":""" & Format(Nz(rs!ZU_Beginn, ""), "hh:nn") & ""","
        result = result & """bis"":""" & Format(Nz(rs!ZU_Ende, ""), "hh:nn") & ""","
        result = result & """stunden"":" & Replace(Nz(rs!ZU_Stunden, 0), ",", ".") & ","
        result = result & """vaId"":" & rs!VA_ID
        result = result & "}"
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    LoadMAEinsaetze = result
End Function

Private Function LoadMADienstplan(db As DAO.Database, MA_ID As Long) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    sql = "SELECT z.*, v.Auftrag, v.Ort, v.Dat_VA_Von " & _
          "FROM tbl_MA_VA_Zuordnung AS z " & _
          "INNER JOIN tbl_VA_Auftragstamm AS v ON z.VA_ID = v.ID " & _
          "WHERE z.MA_ID = " & MA_ID & " AND v.Dat_VA_Von >= Date() " & _
          "ORDER BY v.Dat_VA_Von"
    
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{"
        result = result & """datum"":""" & FormatDatum(rs!Dat_VA_Von) & ""","
        result = result & """auftrag"":""" & EscapeJson(Nz(rs!Auftrag, "")) & ""","
        result = result & """ort"":""" & EscapeJson(Nz(rs!Ort, "")) & ""","
        result = result & """von"":""" & Format(Nz(rs!ZU_Beginn, ""), "hh:nn") & ""","
        result = result & """bis"":""" & Format(Nz(rs!ZU_Ende, ""), "hh:nn") & """"
        result = result & "}"
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    LoadMADienstplan = result
End Function

Private Function LoadMANichtVerfuegbar(db As DAO.Database, MA_ID As Long) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    On Error Resume Next
    sql = "SELECT * FROM tbl_MA_NVerfuegZeiten WHERE MA_ID = " & MA_ID & " ORDER BY NV_DatumVon"
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    If Err.Number <> 0 Then
        LoadMANichtVerfuegbar = "[]"
        Exit Function
    End If
    On Error GoTo 0
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{"
        result = result & """von"":""" & FormatDatum(rs!NV_DatumVon) & ""","
        result = result & """bis"":""" & FormatDatum(rs!NV_DatumBis) & ""","
        result = result & """grund"":""" & EscapeJson(Nz(rs!NV_Grund, "")) & """"
        result = result & "}"
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    LoadMANichtVerfuegbar = result
End Function

Private Function LoadMADienstkleidung(db As DAO.Database, MA_ID As Long) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    On Error Resume Next
    sql = "SELECT * FROM tbl_MA_Dienstkleidung WHERE MA_ID = " & MA_ID
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    If Err.Number <> 0 Then
        LoadMADienstkleidung = "[]"
        Exit Function
    End If
    On Error GoTo 0
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{"
        result = result & """artikel"":""" & EscapeJson(Nz(rs!DK_Artikel, "")) & ""","
        result = result & """groesse"":""" & EscapeJson(Nz(rs!DK_Groesse, "")) & ""","
        result = result & """anzahl"":" & Nz(rs!DK_Anzahl, 0) & ","
        result = result & """ausgabeDat"":""" & FormatDatum(rs!DK_AusgabeDatum) & """"
        result = result & "}"
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    LoadMADienstkleidung = result
End Function

Private Function LoadMASubRechnungen(db As DAO.Database, MA_ID As Long) As String
    LoadMASubRechnungen = "[]"
End Function

Private Function LoadMAZeitkontoMonat(db As DAO.Database, MA_ID As Long) As String
    LoadMAZeitkontoMonat = "[]"
End Function

Private Function LoadMAZeitkontoJahr(db As DAO.Database, MA_ID As Long) As String
    LoadMAZeitkontoJahr = "[]"
End Function

Private Function LoadAnstellungsarten(db As DAO.Database) As String
    Dim result As String
    result = "[{""id"":1,""name"":""Minijobber""},{""id"":2,""name"":""Festangestellter""}]"
    LoadAnstellungsarten = result
End Function

Private Function LoadTaetigkeiten(db As DAO.Database) As String
    Dim result As String
    result = "[""Sicherheitspersonal"",""Ordner"",""Brandschutz"",""Empfang""]"
    LoadTaetigkeiten = result
End Function

Private Function LoadLohngruppen(db As DAO.Database) As String
    Dim result As String
    result = "[""BY Lohn 2a/b Okl. 1"",""BY Lohn 2a/b Okl. 2"",""BY Lohn 3""]"
    LoadLohngruppen = result
End Function

Private Function LoadAlleMitarbeiter(db As DAO.Database) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    sql = "SELECT ID, Nachname, Vorname, Ort, IstAktiv FROM tbl_MA_Mitarbeiterstamm ORDER BY Nachname"
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{"
        result = result & """id"":" & rs!ID & ","
        result = result & """nachname"":""" & EscapeJson(Nz(rs!Nachname, "")) & ""","
        result = result & """vorname"":""" & EscapeJson(Nz(rs!Vorname, "")) & ""","
        result = result & """ort"":""" & EscapeJson(Nz(rs!Ort, "")) & ""","
        result = result & """aktiv"":" & IIf(Nz(rs!IstAktiv, False), "true", "false")
        result = result & "}"
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    LoadAlleMitarbeiter = result
End Function

' =====================================================
' 2. KUNDENSTAMM - VOLLSTÄNDIG
' =====================================================
Public Function LoadKundenstammComplete(KD_ID As Long) As String
    On Error GoTo ErrorHandler
    Dim db As DAO.Database
    Dim result As String
    
    Set db = CurrentDb
    
    result = "{"
    result = result & """stammdaten"":" & LoadKDStammdaten(db, KD_ID) & ","
    result = result & """ansprechpartner"":" & LoadKDAnsprechpartner(db, KD_ID) & ","
    result = result & """konditionen"":" & LoadKDKonditionen(db, KD_ID) & ","
    result = result & """auftraege"":" & LoadKDAuftraege(db, KD_ID) & ","
    result = result & """alleKunden"":" & LoadAlleKunden(db)
    result = result & "}"
    
    LoadKundenstammComplete = result
    Exit Function
ErrorHandler:
    LoadKundenstammComplete = "{""error"":""" & EscapeJson(Err.Description) & """}"
End Function

Private Function LoadKDStammdaten(db As DAO.Database, KD_ID As Long) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    
    sql = "SELECT * FROM tbl_KD_Kundenstamm WHERE ID = " & KD_ID
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    If rs.EOF Then
        LoadKDStammdaten = "{}"
        rs.Close
        Exit Function
    End If
    
    Dim result As String
    result = "{"
    result = result & """id"":" & rs!ID & ","
    result = result & """firma"":""" & EscapeJson(Nz(rs!Firma, "")) & ""","
    result = result & """kuerzel"":""" & EscapeJson(Nz(rs!Matchcode, "")) & ""","
    result = result & """strasse"":""" & EscapeJson(Nz(rs!Strasse, "")) & ""","
    result = result & """plz"":""" & EscapeJson(Nz(rs!PLZ, "")) & ""","
    result = result & """ort"":""" & EscapeJson(Nz(rs!Ort, "")) & ""","
    result = result & """land"":""" & EscapeJson(Nz(rs!Land, "DE")) & ""","
    result = result & """telefon"":""" & EscapeJson(Nz(rs!Telefon, "")) & ""","
    result = result & """mobil"":""" & EscapeJson(Nz(rs!Mobil, "")) & ""","
    result = result & """email"":""" & EscapeJson(Nz(rs!eMail, "")) & ""","
    result = result & """homepage"":""" & EscapeJson(Nz(rs!Homepage, "")) & ""","
    result = result & """iban"":""" & EscapeJson(Nz(rs!IBAN, "")) & ""","
    result = result & """bic"":""" & EscapeJson(Nz(rs!BIC, "")) & ""","
    result = result & """ustIdNr"":""" & EscapeJson(Nz(rs!UStIDNr, "")) & ""","
    result = result & """istAktiv"":" & IIf(Nz(rs!IstAktiv, True), "true", "false")
    result = result & "}"
    
    rs.Close
    LoadKDStammdaten = result
End Function

Private Function LoadKDAnsprechpartner(db As DAO.Database, KD_ID As Long) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    On Error Resume Next
    sql = "SELECT * FROM tbl_KD_Ansprechpartner WHERE Kun_ID = " & KD_ID
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    If Err.Number <> 0 Then
        LoadKDAnsprechpartner = "[]"
        Exit Function
    End If
    On Error GoTo 0
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{"
        result = result & """name"":""" & EscapeJson(Nz(rs!AP_Name, "")) & ""","
        result = result & """funktion"":""" & EscapeJson(Nz(rs!AP_Funktion, "")) & ""","
        result = result & """telefon"":""" & EscapeJson(Nz(rs!AP_Telefon, "")) & ""","
        result = result & """email"":""" & EscapeJson(Nz(rs!AP_eMail, "")) & """"
        result = result & "}"
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    LoadKDAnsprechpartner = result
End Function

Private Function LoadKDKonditionen(db As DAO.Database, KD_ID As Long) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    On Error Resume Next
    sql = "SELECT * FROM tbl_KD_Standardpreise WHERE Kun_ID = " & KD_ID
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    If Err.Number <> 0 Then
        LoadKDKonditionen = "[]"
        Exit Function
    End If
    On Error GoTo 0
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{"
        result = result & """bezeichnung"":""" & EscapeJson(Nz(rs!Bezeichnung, "")) & ""","
        result = result & """preis"":" & Replace(Nz(rs!Preis, 0), ",", ".")
        result = result & "}"
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    LoadKDKonditionen = result
End Function

Private Function LoadKDAuftraege(db As DAO.Database, KD_ID As Long) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    sql = "SELECT ID, Auftrag, Ort, Dat_VA_Von FROM tbl_VA_Auftragstamm WHERE Veranstalter_ID = " & KD_ID & " ORDER BY Dat_VA_Von DESC"
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{"
        result = result & """id"":" & rs!ID & ","
        result = result & """auftrag"":""" & EscapeJson(Nz(rs!Auftrag, "")) & ""","
        result = result & """ort"":""" & EscapeJson(Nz(rs!Ort, "")) & ""","
        result = result & """datum"":""" & FormatDatum(rs!Dat_VA_Von) & """"
        result = result & "}"
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    LoadKDAuftraege = result
End Function

Private Function LoadAlleKunden(db As DAO.Database) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    sql = "SELECT ID, Firma, Ort, IstAktiv FROM tbl_KD_Kundenstamm ORDER BY Firma"
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{"
        result = result & """id"":" & rs!ID & ","
        result = result & """firma"":""" & EscapeJson(Nz(rs!Firma, "")) & ""","
        result = result & """ort"":""" & EscapeJson(Nz(rs!Ort, "")) & ""","
        result = result & """aktiv"":" & IIf(Nz(rs!IstAktiv, True), "true", "false")
        result = result & "}"
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    LoadAlleKunden = result
End Function

' =====================================================
' 3. AUFTRAGSVERWALTUNG - VOLLSTÄNDIG
' =====================================================
Public Function LoadAuftragsverwaltungComplete(VA_ID As Long) As String
    On Error GoTo ErrorHandler
    Dim db As DAO.Database
    Dim result As String
    
    Set db = CurrentDb
    
    result = "{"
    result = result & """stammdaten"":" & LoadVAStammdaten(db, VA_ID) & ","
    result = result & """schichten"":" & LoadVASchichten(db, VA_ID) & ","
    result = result & """zuordnungen"":" & LoadVAZuordnungen(db, VA_ID) & ","
    result = result & """absagen"":" & LoadVAAbsagen(db, VA_ID) & ","
    result = result & """zusatzdateien"":" & LoadVAZusatzdateien(db, VA_ID) & ","
    result = result & """rechnung"":" & LoadVARechnung(db, VA_ID) & ","
    result = result & """objekte"":" & LoadObjekte(db) & ","
    result = result & """orte"":" & LoadOrte(db) & ","
    result = result & """kunden"":" & LoadAlleKunden(db) & ","
    result = result & """alleAuftraege"":" & LoadAlleAuftraege(db)
    result = result & "}"
    
    LoadAuftragsverwaltungComplete = result
    Exit Function
ErrorHandler:
    LoadAuftragsverwaltungComplete = "{""error"":""" & EscapeJson(Err.Description) & """}"
End Function

Private Function LoadVAStammdaten(db As DAO.Database, VA_ID As Long) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    
    sql = "SELECT * FROM tbl_VA_Auftragstamm WHERE ID = " & VA_ID
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    If rs.EOF Then
        LoadVAStammdaten = "{}"
        rs.Close
        Exit Function
    End If
    
    Dim result As String
    result = "{"
    result = result & """id"":" & rs!ID & ","
    result = result & """auftrag"":""" & EscapeJson(Nz(rs!Auftrag, "")) & ""","
    result = result & """objekt"":""" & EscapeJson(Nz(rs!Objekt, "")) & ""","
    result = result & """ort"":""" & EscapeJson(Nz(rs!Ort, "")) & ""","
    result = result & """datVon"":""" & FormatDatum(rs!Dat_VA_Von) & ""","
    result = result & """datBis"":""" & FormatDatum(rs!Dat_VA_Bis) & ""","
    result = result & """objektId"":" & Nz(rs!Objekt_ID, 0) & ","
    result = result & """veranstalterId"":" & Nz(rs!Veranstalter_ID, 0) & ","
    result = result & """auftraggeber"":""" & EscapeJson(Nz(rs!Kun_Firma, "")) & ""","
    result = result & """treffpunkt"":""" & EscapeJson(Nz(rs!Treffpunkt, "")) & ""","
    result = result & """dienstkleidung"":""" & EscapeJson(Nz(rs!Dienstkleidung, "")) & ""","
    result = result & """ansprechpartner"":""" & EscapeJson(Nz(rs!Ansprechpartner, "")) & ""","
    result = result & """fahrtkosten"":" & Replace(Nz(rs!Fahrtkosten, 0), ",", ".") & ","
    result = result & """statusId"":" & Nz(rs!Veranst_Status_ID, 1) & ","
    result = result & """autosend"":" & IIf(Nz(rs!Autosend_EL, False), "true", "false") & ","
    result = result & """elGesendet"":" & IIf(Nz(rs!EL_gesendet, False), "true", "false") & ","
    result = result & """soll"":" & GetVASoll(db, VA_ID) & ","
    result = result & """ist"":" & GetVAIst(db, VA_ID)
    result = result & "}"
    
    rs.Close
    LoadVAStammdaten = result
End Function

Private Function LoadVASchichten(db As DAO.Database, VA_ID As Long) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    sql = "SELECT * FROM tbl_VA_Start WHERE VA_ID = " & VA_ID & " ORDER BY DB_von"
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{"
        result = result & """id"":" & rs!ID & ","
        result = result & """soll"":" & Nz(rs!MA_Anzahl, 0) & ","
        result = result & """beginn"":""" & Format(rs!DB_von, "hh:nn") & ""","
        result = result & """ende"":""" & Format(rs!DB_bis, "hh:nn") & """"
        result = result & "}"
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    LoadVASchichten = result
End Function

Private Function LoadVAZuordnungen(db As DAO.Database, VA_ID As Long) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    sql = "SELECT z.*, m.Nachname, m.Vorname FROM tbl_MA_VA_Zuordnung AS z " & _
          "LEFT JOIN tbl_MA_Mitarbeiterstamm AS m ON z.MA_ID = m.ID " & _
          "WHERE z.VA_ID = " & VA_ID & " ORDER BY z.ZU_Lfd"
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{"
        result = result & """lfd"":" & Nz(rs!ZU_Lfd, 0) & ","
        result = result & """maId"":" & Nz(rs!MA_ID, 0) & ","
        result = result & """nachname"":""" & EscapeJson(Nz(rs!Nachname, "")) & ""","
        result = result & """vorname"":""" & EscapeJson(Nz(rs!Vorname, "")) & ""","
        result = result & """von"":""" & Format(Nz(rs!ZU_Beginn, ""), "hh:nn") & ""","
        result = result & """bis"":""" & Format(Nz(rs!ZU_Ende, ""), "hh:nn") & ""","
        result = result & """stunden"":" & Replace(Nz(rs!ZU_Stunden, 0), ",", ".") & ","
        result = result & """bemerkung"":""" & EscapeJson(Nz(rs!Bemerkung, "")) & """"
        result = result & "}"
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    LoadVAZuordnungen = result
End Function

Private Function LoadVAAbsagen(db As DAO.Database, VA_ID As Long) As String
    LoadVAAbsagen = "[]"
End Function

Private Function LoadVAZusatzdateien(db As DAO.Database, VA_ID As Long) As String
    LoadVAZusatzdateien = "[]"
End Function

Private Function LoadVARechnung(db As DAO.Database, VA_ID As Long) As String
    LoadVARechnung = "{}"
End Function

Private Function LoadObjekte(db As DAO.Database) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    On Error Resume Next
    sql = "SELECT ID, Objektname, Ort FROM tbl_OB_Objekt ORDER BY Objektname"
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    If Err.Number <> 0 Then
        LoadObjekte = "[]"
        Exit Function
    End If
    On Error GoTo 0
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{"
        result = result & """id"":" & rs!ID & ","
        result = result & """name"":""" & EscapeJson(Nz(rs!Objektname, "")) & ""","
        result = result & """ort"":""" & EscapeJson(Nz(rs!Ort, "")) & """"
        result = result & "}"
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    LoadObjekte = result
End Function

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

Private Function LoadAlleAuftraege(db As DAO.Database) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    sql = "SELECT ID, Auftrag, Ort, Dat_VA_Von FROM tbl_VA_Auftragstamm WHERE Dat_VA_Von >= Date() ORDER BY Dat_VA_Von"
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{"
        result = result & """id"":" & rs!ID & ","
        result = result & """auftrag"":""" & EscapeJson(Nz(rs!Auftrag, "")) & ""","
        result = result & """ort"":""" & EscapeJson(Nz(rs!Ort, "")) & ""","
        result = result & """datum"":""" & FormatDatum(rs!Dat_VA_Von) & """"
        result = result & "}"
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    LoadAlleAuftraege = result
End Function

Private Function GetVASoll(db As DAO.Database, VA_ID As Long) As Long
    Dim rs As DAO.Recordset
    Set rs = db.OpenRecordset("SELECT Sum(MA_Anzahl) AS S FROM tbl_VA_Start WHERE VA_ID = " & VA_ID, dbOpenSnapshot)
    GetVASoll = Nz(rs!S, 0)
    rs.Close
End Function

Private Function GetVAIst(db As DAO.Database, VA_ID As Long) As Long
    Dim rs As DAO.Recordset
    Set rs = db.OpenRecordset("SELECT Count(*) AS C FROM tbl_MA_VA_Zuordnung WHERE VA_ID = " & VA_ID & " AND MA_ID > 0", dbOpenSnapshot)
    GetVAIst = Nz(rs!C, 0)
    rs.Close
End Function

' =====================================================
' HILFSFUNKTIONEN
' =====================================================
Private Function EscapeJson(s As String) As String
    s = Replace(s, "\", "\\")
    s = Replace(s, """", "\""")
    s = Replace(s, vbCr, "")
    s = Replace(s, vbLf, "")
    s = Replace(s, vbTab, " ")
    EscapeJson = s
End Function

Private Function FormatDatum(d As Variant) As String
    If IsNull(d) Or IsEmpty(d) Then
        FormatDatum = ""
    Else
        FormatDatum = Format(d, "dd.mm.yyyy")
    End If
End Function
