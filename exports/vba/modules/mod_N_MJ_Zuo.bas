Attribute VB_Name = "mod_N_MJ_Zuo"
Option Compare Database
Option Explicit

' Automatische MA-Zuordnung für Sport-Venues
' FINALE VERSION - mit korrektem Feldnamen Quali_ID
Public Function Auto_MA_Zuordnung_Sport_Venues() As Boolean
    Dim db As DAO.Database
    Dim rsAuftrag As DAO.Recordset
    Dim rsSchicht As DAO.Recordset
    Dim rsMA As DAO.Recordset
    Dim rstPlanung As DAO.Recordset
    Dim sqlAuftrag As String, sqlSchicht As String, sqlMA As String
    Dim vaID As Long, vaDatumID As Long, vaStartID As Long
    Dim VADatum As Date, dtStart As Date, dtEnde As Date
    Dim mvaStart As Date, mvaEnde As Date
    Dim maAnzahl As Integer, maID As Long, PosNr As Long
    Dim anzahlZugeordnet As Long, anzahlAuftraege As Long
    Dim DatVon As String, DatBis As String
    Dim i As Integer
    
    On Error GoTo Err_Handler
    
    Auto_MA_Zuordnung_Sport_Venues = False
    Set db = CurrentDb()
    anzahlZugeordnet = 0
    anzahlAuftraege = 0
    
    ' Datum im Access-SQL-Format (MM/DD/YYYY)
    DatVon = "#" & Month(Date) & "/" & Day(Date) & "/" & Year(Date) & "#"
    DatBis = "#" & Month(Date + 20) & "/" & Day(Date + 20) & "/" & Year(Date + 20) & "#"
    
    ' 1. Sport-Aufträge der nächsten 20 Tage finden
    sqlAuftrag = "SELECT va.ID, va.Auftrag, at.ID AS VADatum_ID, at.VADatum " & _
                 "FROM tbl_VA_Auftragstamm va " & _
                 "INNER JOIN tbl_VA_AnzTage at ON va.ID = at.VA_ID " & _
                 "WHERE at.VADatum BETWEEN " & DatVon & " AND " & DatBis & " " & _
                 "  AND (va.Objekt IN ('Max-Morlock-Stadion','Sportpark am Ronhof','PSD Bank Arena') " & _
                 "       OR va.Ort IN ('Max-Morlock-Stadion','Sportpark am Ronhof','PSD Bank Arena')) " & _
                 "ORDER BY at.VADatum"
    
    Set rsAuftrag = db.OpenRecordset(sqlAuftrag, dbOpenSnapshot)
    
    If rsAuftrag.EOF Then
        MsgBox "Keine Sport-Aufträge in den nächsten 20 Tagen gefunden.", vbInformation, "Auto-Zuordnung"
        GoTo Exit_Handler
    End If
    
    ' Recordset für Planung öffnen
    Set rstPlanung = db.OpenRecordset("SELECT TOP 1 * FROM tbl_MA_VA_Planung", dbOpenDynaset)
    
    ' 2. Jeden Auftrag durchgehen
    Do While Not rsAuftrag.EOF
        vaID = rsAuftrag!ID
        vaDatumID = rsAuftrag!VADatum_ID
        VADatum = rsAuftrag!VADatum
        
        ' 2a. Schicht mit größtem MA-Bedarf finden
        sqlSchicht = "SELECT TOP 1 s.ID, s.MA_Anzahl, s.VA_Start, s.VA_Ende, s.MVA_Start, s.MVA_Ende " & _
                     "FROM tbl_VA_Start s " & _
                     "WHERE s.VA_ID = " & vaID & " AND s.VADatum_ID = " & vaDatumID & " " & _
                     "  AND Nz(s.MA_Anzahl, 0) > 0 " & _
                     "ORDER BY s.MA_Anzahl DESC, s.MVA_Start DESC"
        
        Set rsSchicht = db.OpenRecordset(sqlSchicht, dbOpenSnapshot)
        
        If Not rsSchicht.EOF Then
            vaStartID = rsSchicht!ID
            maAnzahl = rsSchicht!MA_Anzahl
            dtStart = rsSchicht!VA_Start
            dtEnde = rsSchicht!VA_Ende
            mvaStart = rsSchicht!MVA_Start
            mvaEnde = rsSchicht!MVA_Ende
            
            ' 2b. Verfügbare MA mit Anstellungsart_ID = 5 UND Quali_ID = 9 (Fußball)
            sqlMA = "SELECT ma.ID " & _
                    "FROM tbl_MA_Mitarbeiterstamm ma " & _
                    "INNER JOIN tbl_MA_Einsatz_Zuo zuo ON ma.ID = zuo.MA_ID " & _
                    "WHERE ma.Anstellungsart_ID = 5 " & _
                    "  AND zuo.Quali_ID = 9 " & _
                    "  AND NOT EXISTS ( " & _
                    "    SELECT 1 FROM tbl_MA_VA_Planung p " & _
                    "    WHERE p.MA_ID = ma.ID " & _
                    "      AND p.VADatum = #" & Month(VADatum) & "/" & Day(VADatum) & "/" & Year(VADatum) & "# " & _
                    "      AND p.MVA_Start < #" & Month(mvaEnde) & "/" & Day(mvaEnde) & "/" & Year(mvaEnde) & " " & _
                                                   Hour(mvaEnde) & ":" & minute(mvaEnde) & ":" & Second(mvaEnde) & "# " & _
                    "      AND p.MVA_Ende > #" & Month(mvaStart) & "/" & Day(mvaStart) & "/" & Year(mvaStart) & " " & _
                                                 Hour(mvaStart) & ":" & minute(mvaStart) & ":" & Second(mvaStart) & "# " & _
                    "  ) " & _
                    "ORDER BY ma.Nachname, ma.Vorname"
            
            Set rsMA = db.OpenRecordset(sqlMA, dbOpenSnapshot)
            
            ' 2c. MA in tbl_MA_VA_Planung eintragen
            i = 0
            Do While Not rsMA.EOF And i < maAnzahl
                maID = rsMA!ID
                
                ' PosNr ermitteln
                PosNr = Nz(TMax("PosNr", "tbl_MA_VA_Planung", "VA_ID = " & vaID & " AND VADatum_ID = " & vaDatumID), 0) + 1
                
                ' MA eintragen
                With rstPlanung
                    .AddNew
                    .fields("VA_ID").Value = vaID
                    .fields("VADatum_ID").Value = vaDatumID
                    .fields("VAStart_ID").Value = vaStartID
                    .fields("PosNr").Value = PosNr
                    .fields("VA_Start").Value = dtStart
                    .fields("VA_Ende").Value = dtEnde
                    .fields("MA_ID").Value = maID
                    .fields("Status_ID").Value = 1  ' Geplant
                    .fields("Erst_von").Value = Environ("USERNAME")
                    .fields("Erst_am").Value = Now()
                    .fields("Aend_von").Value = Environ("USERNAME")
                    .fields("Aend_am").Value = Now()
                    .fields("VADatum").Value = VADatum
                    .fields("MVA_Start").Value = mvaStart
                    .fields("MVA_Ende").Value = mvaEnde
                    .fields("Bemerkungen").Value = ""
                    .update
                End With
                
                anzahlZugeordnet = anzahlZugeordnet + 1
                i = i + 1
                rsMA.MoveNext
            Loop
            
            If i > 0 Then anzahlAuftraege = anzahlAuftraege + 1
            rsMA.Close
        End If
        
        rsSchicht.Close
        rsAuftrag.MoveNext
    Loop
    
    rstPlanung.Close
    
    MsgBox "Erfolgreich " & anzahlZugeordnet & " Mitarbeiter für " & _
           anzahlAuftraege & " Sport-Aufträge eingeplant.", vbInformation, "Auto-Zuordnung"
    
    Auto_MA_Zuordnung_Sport_Venues = True
    
Exit_Handler:
    On Error Resume Next
    If Not rsAuftrag Is Nothing Then rsAuftrag.Close
    If Not rsSchicht Is Nothing Then rsSchicht.Close
    If Not rsMA Is Nothing Then rsMA.Close
    If Not rstPlanung Is Nothing Then rstPlanung.Close
    Set rsAuftrag = Nothing
    Set rsSchicht = Nothing
    Set rsMA = Nothing
    Set rstPlanung = Nothing
    Set db = Nothing
    Exit Function
    
Err_Handler:
    MsgBox "Fehler " & Err.Number & ": " & Err.description, vbCritical, "Auto-Zuordnung Fehler"
    Auto_MA_Zuordnung_Sport_Venues = False
    Resume Exit_Handler
End Function


