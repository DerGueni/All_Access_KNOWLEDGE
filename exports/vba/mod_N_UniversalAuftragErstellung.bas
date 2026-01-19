Attribute VB_Name = "mod_N_UniversalAuftragErstellung"

Option Compare Database
Option Explicit

' ================================================================================================
' MODUL: mod_N_UniversalAuftragErstellung
' ZWECK: Universelle Auftragserstellung für Consys mit externem Zugriff
' VERSION: 3.1 - DATUMSFORMAT KORRIGIERT
' ================================================================================================
' ÄNDERUNGEN V3.1:
' - KRITISCHER FIX: Datumsformat für SQL korrigiert (mm/dd/yyyy)
' - Garantiert Sichtbarkeit in qry_lst_Row_Auftrag
' - Verbesserte tbl_VA_AnzTage Erstellung (TVA_Soll = 1)
' ================================================================================================

' ================================================================================================
' HILFSFUNKTION: Konvertiert Datum für Access SQL (MM/DD/YYYY)
' ================================================================================================
Private Function DatumFuerSQL(ByVal Datum As Date) As String
    DatumFuerSQL = Month(Datum) & "/" & Day(Datum) & "/" & Year(Datum)
End Function

' ================================================================================================
' HAUPTFUNKTION: Erstellt einen kompletten Auftrag mit allen Abhängigkeiten
' ================================================================================================
Public Function AuftragErstellen( _
    ByVal auftragsName As String, _
    ByVal objektName As String, _
    ByVal ortName As String, _
    ByVal DatumVon As Date, _
    Optional ByVal DatumBis As Date = 0, _
    Optional ByVal auftraggeber As String = "", _
    Optional ByVal Treffpunkt As String = "", _
    Optional ByVal schichten As String = "", _
    Optional ByVal statusID As Integer = 1, _
    Optional ByVal Ersteller As String = "" _
) As String

On Error GoTo ErrorHandler

    ' PARAMETER-VALIDIERUNG
    If Len(Trim(auftragsName)) = 0 Then
        AuftragErstellen = "FEHLER: Auftragsname ist erforderlich"
        Exit Function
    End If
    
    If Len(Trim(objektName)) = 0 Then objektName = auftragsName
    If Len(Trim(ortName)) = 0 Then ortName = "N/A"
    If DatumBis = 0 Then DatumBis = DatumVon
    If Len(Trim(Ersteller)) = 0 Then Ersteller = Environ("UserName")
    
    If DatumVon > DatumBis Then
        AuftragErstellen = "FEHLER: DatumVon muss vor DatumBis liegen"
        Exit Function
    End If
    
    Debug.Print String(60, "-")
    Debug.Print "Erstelle Auftrag: " & auftragsName
    Debug.Print "Objekt: " & objektName
    Debug.Print "Ort: " & ortName
    Debug.Print "Datum: " & Format(DatumVon, "dd.mm.yyyy") & " bis " & Format(DatumBis, "dd.mm.yyyy")
    
    ' SCHRITT 1: HAUPTAUFTRAG ERSTELLEN
    Dim anzTage As Integer
    anzTage = DateDiff("d", DatumVon, DatumBis) + 1
    
    Dim sql As String
    sql = "INSERT INTO tbl_VA_Auftragstamm " & _
          "(Auftrag, Objekt, Ort, Dat_VA_Von, Dat_VA_Bis, AnzTg, " & _
          "Veranstalter_ID, Treffpunkt, Erst_von, Erst_am, Veranst_Status_ID) " & _
          "VALUES (" & _
          "'" & SQLSafe(auftragsName) & "', " & _
          "'" & SQLSafe(objektName) & "', " & _
          "'" & SQLSafe(ortName) & "', " & _
          "#" & DatumFuerSQL(DatumVon) & "#, " & _
          "#" & DatumFuerSQL(DatumBis) & "#, " & _
          anzTage & ", "
    
    If Len(Trim(auftraggeber)) > 0 Then
        Dim kundenID As Long
        kundenID = GetKundenID(auftraggeber)
        If kundenID > 0 Then
            sql = sql & kundenID & ", "
        Else
            sql = sql & "NULL, "
        End If
    Else
        sql = sql & "NULL, "
    End If
    
    sql = sql & "'" & SQLSafe(Treffpunkt) & "', " & _
          "'" & Ersteller & "', " & _
          "Now(), " & statusID & ")"
    
    Debug.Print "Erstelle Auftragstamm-Eintrag..."
    CurrentDb.Execute sql, dbFailOnError
    Debug.Print "Auftragstamm erstellt"
    
    ' SCHRITT 2: AUFTRAG-ID ERMITTELN
    Dim rs As DAO.Recordset
    Set rs = CurrentDb.OpenRecordset( _
        "SELECT MAX(ID) AS NewID FROM tbl_VA_Auftragstamm " & _
        "WHERE Auftrag = '" & SQLSafe(auftragsName) & "' " & _
        "AND Erst_von = '" & Ersteller & "'")
    
    Dim auftragsID As Long
    If Not rs.EOF Then auftragsID = Nz(rs.fields("NewID").Value, 0)
    rs.Close
    
    If auftragsID = 0 Then
        AuftragErstellen = "FEHLER: Auftrag-ID nicht ermittelt"
        Exit Function
    End If
    
    Debug.Print "Auftrag-ID ermittelt: " & auftragsID
    
    ' SCHRITT 2a: ORT-FELD VALIDIEREN
    Call GarantiereOrtFeld(auftragsID, ortName)
    
    ' SCHRITT 2b: BOOLEAN-FELDER AKTIVIEREN
    Call AktiviereAuftragBooleanFelder(auftragsID)
    
    ' SCHRITT 3: VERANSTALTUNGSTAGE ERSTELLEN
    Debug.Print "Erstelle Veranstaltungstage (" & anzTage & " Tage)..."
    
    Dim aktDatum As Date
    Dim vaDatumIDs As Collection
    Set vaDatumIDs = New Collection
    Dim tagNr As Integer
    
    tagNr = 0
    For aktDatum = DatumVon To DatumBis
        tagNr = tagNr + 1
        
        sql = "INSERT INTO tbl_VA_AnzTage (VA_ID, VADatum, TVA_Soll, TVA_Ist) " & _
              "VALUES (" & auftragsID & ", " & _
              "#" & DatumFuerSQL(aktDatum) & "#, 1, 0)"
        CurrentDb.Execute sql, dbFailOnError
        
        Set rs = CurrentDb.OpenRecordset( _
            "SELECT ID FROM tbl_VA_AnzTage " & _
            "WHERE VA_ID = " & auftragsID & " " & _
            "AND VADatum = #" & DatumFuerSQL(aktDatum) & "#")
        
        If Not rs.EOF Then
            vaDatumIDs.Add rs.fields("ID").Value, Format(aktDatum, "yyyy-mm-dd")
            Debug.Print "    Tag " & tagNr & ": " & Format(aktDatum, "dd.mm.yyyy") & " (ID: " & rs.fields("ID").Value & ")"
        End If
        rs.Close
    Next aktDatum
    
    Debug.Print "  ? " & vaDatumIDs.Count & " Veranstaltungstage erstellt"
    
    ' SCHRITT 4: SCHICHTEN ERSTELLEN
    If Len(Trim(schichten)) > 0 Then
        Debug.Print "  ? Erstelle Schichten: " & schichten
        Call ErstelleSchichten(auftragsID, vaDatumIDs, schichten, DatumVon, Ersteller)
        Debug.Print "  ? Schichten erstellt"
    End If
    
    ' SCHRITT 5: VALIDIERUNG
    Debug.Print "  ? Finale Validierung..."
    Dim validierung As String
    validierung = ValidiereAuftrag(auftragsID)
    Debug.Print "  " & validierung
    
    Debug.Print "? Auftrag komplett erstellt (ID: " & auftragsID & ")"
    Debug.Print String(60, "-")
    
    AuftragErstellen = "SUCCESS|" & auftragsID & "|" & auftragsName
    Exit Function

ErrorHandler:
    Debug.Print "? FEHLER beim Erstellen: " & Err.Number & " - " & Err.description
    AuftragErstellen = "FEHLER: " & Err.Number & " - " & Err.description
End Function

' ================================================================================================
' HILFSFUNKTIONEN
' ================================================================================================
Private Sub GarantiereOrtFeld(ByVal auftragsID As Long, ByVal sollOrt As String)
On Error Resume Next
    Dim rs As DAO.Recordset
    Set rs = CurrentDb.OpenRecordset( _
        "SELECT Ort, Objekt FROM tbl_VA_Auftragstamm WHERE ID = " & auftragsID, dbOpenDynaset)
    
    If Not rs.EOF Then
        If Len(Trim(Nz(rs!Ort, ""))) = 0 Then
            rs.Edit
            If Len(Trim(sollOrt)) > 0 Then
                rs!Ort = sollOrt
            ElseIf Len(Trim(Nz(rs!Objekt, ""))) > 0 Then
                rs!Ort = rs!Objekt
            Else
                rs!Ort = "N/A"
            End If
            rs.update
        End If
    End If
    rs.Close
End Sub

Private Sub AktiviereAuftragBooleanFelder(ByVal auftragsID As Long)
On Error Resume Next
    Dim rs As DAO.Recordset
    Set rs = CurrentDb.OpenRecordset( _
        "SELECT * FROM tbl_VA_Auftragstamm WHERE ID = " & auftragsID, dbOpenDynaset)
    
    If Not rs.EOF Then
        Dim i As Integer
        Dim hatUpdate As Boolean
        hatUpdate = False
        
        For i = 0 To rs.fields.Count - 1
            If rs.fields(i).Type = dbBoolean Then
                If Not hatUpdate Then
                    rs.Edit
                    hatUpdate = True
                End If
                rs.fields(i).Value = True
            End If
        Next i
        
        If hatUpdate Then rs.update
    End If
    rs.Close
End Sub

Private Sub ErstelleSchichten( _
    ByVal auftragsID As Long, _
    ByVal vaDatumIDs As Collection, _
    ByVal schichtDefinition As String, _
    ByVal basisDatum As Date, _
    ByVal Ersteller As String)
    
On Error GoTo ErrorHandler
    
    Dim schichtTeile() As String
    schichtTeile = Split(schichtDefinition, ",")
    
    Dim teil As Variant
    Dim PosNr As Integer: PosNr = 1
    
    For Each teil In schichtTeile
        teil = Trim(teil)
        
        Dim Anzahl As Integer: Anzahl = 1
        Dim zeitBereich As String
        
        If InStr(teil, "x ") > 0 Then
            Anzahl = CInt(Split(teil, "x ")(0))
            zeitBereich = Trim(Split(teil, "x ")(1))
        Else
            zeitBereich = teil
        End If
        
        If InStr(zeitBereich, "-") > 0 Then
            Dim startzeit As String, endzeit As String
            startzeit = Trim(Split(zeitBereich, "-")(0))
            endzeit = Trim(Split(zeitBereich, "-")(1))
            
            Dim i As Integer, j As Integer
            For j = 0 To vaDatumIDs.Count - 1
                Dim aktDatum As Date
                aktDatum = DateAdd("d", j, basisDatum)
                Dim datumKey As String
                datumKey = Format(aktDatum, "yyyy-mm-dd")
                
                Dim vaDatumID As Long
                vaDatumID = vaDatumIDs(datumKey)
                
                For i = 1 To Anzahl
                    Dim sql As String
                    sql = "INSERT INTO tbl_VA_Start " & _
                          "(VA_ID, VADatum_ID, VADatum, MA_Anzahl, " & _
                          "VA_Start, VA_Ende, MVA_Start, MVA_Ende) " & _
                          "VALUES (" & _
                          auftragsID & ", " & vaDatumID & ", " & _
                          "#" & DatumFuerSQL(aktDatum) & "#, 1, " & _
                          "#" & startzeit & ":00#, #" & endzeit & ":00#, " & _
                          "#" & DatumFuerSQL(aktDatum) & " " & startzeit & ":00#, " & _
                          "#" & DatumFuerSQL(aktDatum) & " " & endzeit & ":00#)"
                    
                    CurrentDb.Execute sql, dbFailOnError
                    
                    Dim rs As DAO.Recordset
                    Set rs = CurrentDb.OpenRecordset( _
                        "SELECT MAX(ID) AS NewID FROM tbl_VA_Start WHERE VA_ID = " & auftragsID)
                    
                    Dim vaStartID As Long
                    If Not rs.EOF Then vaStartID = Nz(rs.fields("NewID").Value, 0)
                    rs.Close
                    
                    If vaStartID > 0 Then
                        sql = "INSERT INTO tbl_MA_VA_Zuordnung " & _
                              "(VA_ID, VADatum_ID, VAStart_ID, VADatum, PosNr, " & _
                              "MVA_Start, MVA_Ende, Erst_von, Erst_am) " & _
                              "VALUES (" & _
                              auftragsID & ", " & vaDatumID & ", " & vaStartID & ", " & _
                              "#" & DatumFuerSQL(aktDatum) & "#, " & PosNr & ", " & _
                              "#" & DatumFuerSQL(aktDatum) & " " & startzeit & ":00#, " & _
                              "#" & DatumFuerSQL(aktDatum) & " " & endzeit & ":00#, " & _
                              "'" & Ersteller & "', Now())"
                        
                        CurrentDb.Execute sql, dbFailOnError
                        PosNr = PosNr + 1
                    End If
                Next i
            Next j
        End If
    Next teil
    
    Exit Sub
ErrorHandler:
    Debug.Print "Schicht-Fehler: " & Err.description
End Sub

Private Function GetKundenID(ByVal kundenName As String) As Long
On Error Resume Next
    Dim rs As DAO.Recordset
    Set rs = CurrentDb.OpenRecordset( _
        "SELECT kun_Id FROM tbl_KD_Kundenstamm " & _
        "WHERE kun_Firma LIKE '%" & SQLSafe(kundenName) & "%'")
    
    If Not rs.EOF Then
        GetKundenID = rs.fields("kun_Id").Value
    Else
        GetKundenID = 0
    End If
    rs.Close
End Function

Private Function SQLSafe(ByVal Text As String) As String
    SQLSafe = Replace(Text, "'", "''")
End Function

Public Function ValidiereAuftrag(ByVal auftragsID As Long) As String
On Error GoTo ErrorHandler
    Dim rs As DAO.Recordset
    Dim Fehler As String: Fehler = ""
    
    Set rs = CurrentDb.OpenRecordset( _
        "SELECT Ort FROM tbl_VA_Auftragstamm WHERE ID = " & auftragsID)
    If Not rs.EOF Then
        If Len(Trim(Nz(rs!Ort, ""))) = 0 Then Fehler = Fehler & "Ort leer; "
    End If
    rs.Close
    
    Set rs = CurrentDb.OpenRecordset( _
        "SELECT COUNT(*) AS Anzahl FROM tbl_VA_AnzTage WHERE VA_ID = " & auftragsID)
    If rs!Anzahl = 0 Then Fehler = Fehler & "Keine AnzTage; "
    rs.Close
    
    If Len(Fehler) > 0 Then
        ValidiereAuftrag = "WARNUNG: " & Fehler
    Else
        ValidiereAuftrag = "SUCCESS"
    End If
    Exit Function
ErrorHandler:
    ValidiereAuftrag = "FEHLER: " & Err.description
End Function

Public Function KorrigiereAuftragBooleans(ByVal auftragsID As Long) As String
On Error GoTo ErrorHandler
    Call AktiviereAuftragBooleanFelder(auftragsID)
    Call GarantiereOrtFeld(auftragsID, "")
    
    Dim rs As DAO.Recordset
    Set rs = CurrentDb.OpenRecordset( _
        "SELECT COUNT(*) AS Anzahl FROM tbl_VA_AnzTage WHERE VA_ID = " & auftragsID)
    
    If rs!Anzahl = 0 Then
        KorrigiereAuftragBooleans = "WARNUNG: Keine AnzTage"
    Else
        KorrigiereAuftragBooleans = "SUCCESS"
    End If
    rs.Close
    Exit Function
ErrorHandler:
    KorrigiereAuftragBooleans = "FEHLER: " & Err.description
End Function

Public Function KorrigiereLetztenAuftrag() As String
On Error GoTo ErrorHandler
    Dim rs As DAO.Recordset
    Set rs = CurrentDb.OpenRecordset("SELECT MAX(ID) AS LastID FROM tbl_VA_Auftragstamm")
    If Not rs.EOF Then
        KorrigiereLetztenAuftrag = KorrigiereAuftragBooleans(rs.fields("LastID").Value)
    Else
        KorrigiereLetztenAuftrag = "FEHLER: Kein Auftrag gefunden"
    End If
    rs.Close
    Exit Function
ErrorHandler:
    KorrigiereLetztenAuftrag = "FEHLER: " & Err.description
End Function




