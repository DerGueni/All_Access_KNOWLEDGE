Attribute VB_Name = "mdl_GeoSetup"

Option Compare Database
Option Explicit

' ============================================================
' mdl_GeoSetup - Einrichtung & Automatische Updates
' Ergänzt die vorhandenen Geo-Module um Setup-Funktionen
' ============================================================

' ------------------------------------------------------------
' EINMALIGE EINRICHTUNG - Führe dies EINMAL aus!
' Im Direktfenster: ?GeoFeature_Ersteinrichtung()
' ------------------------------------------------------------
Public Function GeoFeature_Ersteinrichtung() As String
    Dim lngObjekte As Long, lngMA As Long, lngEntfernungen As Long
    Dim strResult As String
    
    On Error GoTo ErrHandler
    
    strResult = "=== GEO-FEATURE ERSTEINRICHTUNG ===" & vbCrLf & vbCrLf
    
    ' Schritt 1: Objekte geocodieren
    strResult = strResult & "Schritt 1: Objekte geocodieren..." & vbCrLf
    lngObjekte = BatchGeocodeObjekte()
    strResult = strResult & "   -> " & lngObjekte & " Objekte geocodiert" & vbCrLf & vbCrLf
    
    ' Schritt 2: Mitarbeiter geocodieren
    strResult = strResult & "Schritt 2: Mitarbeiter geocodieren..." & vbCrLf
    lngMA = BatchGeocodeMA()
    strResult = strResult & "   -> " & lngMA & " Mitarbeiter geocodiert" & vbCrLf & vbCrLf
    
    ' Schritt 3: Entfernungen berechnen
    strResult = strResult & "Schritt 3: Entfernungen berechnen..." & vbCrLf
    lngEntfernungen = BuildAllDistances()
    strResult = strResult & "   -> " & lngEntfernungen & " Entfernungen berechnet" & vbCrLf & vbCrLf
    
    strResult = strResult & "=== FERTIG ===" & vbCrLf
    strResult = strResult & "Objekte mit Koordinaten: " & DCount("*", "tbl_OB_Geo", "Lat <> 0") & vbCrLf
    strResult = strResult & "MA mit Koordinaten: " & DCount("*", "tbl_MA_Geo", "Lat <> 0") & vbCrLf
    strResult = strResult & "Entfernungen gesamt: " & DCount("*", "tbl_MA_Objekt_Entfernung")
    
    MsgBox strResult, vbInformation, "Geo-Feature Ersteinrichtung"
    GeoFeature_Ersteinrichtung = strResult
    Exit Function
    
ErrHandler:
    MsgBox "Fehler: " & Err.description, vbCritical
    GeoFeature_Ersteinrichtung = "FEHLER: " & Err.description
End Function

' ------------------------------------------------------------
' STATUS ANZEIGEN
' Im Direktfenster: ?GeoFeature_Status()
' ------------------------------------------------------------
Public Function GeoFeature_Status() As String
    Dim strStatus As String
    Dim lngObjGeo As Long, lngObjGesamt As Long
    Dim lngMAGeo As Long, lngMAGesamt As Long
    Dim lngEntf As Long
    
    lngObjGesamt = Nz(DCount("*", "tbl_OB_Objekt"), 0)
    lngObjGeo = Nz(DCount("*", "tbl_OB_Geo", "Lat <> 0"), 0)
    lngMAGesamt = Nz(DCount("*", "tbl_MA_Mitarbeiterstamm"), 0)
    lngMAGeo = Nz(DCount("*", "tbl_MA_Geo", "Lat <> 0"), 0)
    lngEntf = Nz(DCount("*", "tbl_MA_Objekt_Entfernung"), 0)
    
    strStatus = "=== GEO-FEATURE STATUS ===" & vbCrLf & vbCrLf
    If lngObjGesamt > 0 Then
        strStatus = strStatus & "Objekte: " & lngObjGeo & " von " & lngObjGesamt & " geocodiert (" & Format(lngObjGeo / lngObjGesamt * 100, "0.0") & "%)" & vbCrLf
    End If
    If lngMAGesamt > 0 Then
        strStatus = strStatus & "Mitarbeiter: " & lngMAGeo & " von " & lngMAGesamt & " geocodiert (" & Format(lngMAGeo / lngMAGesamt * 100, "0.0") & "%)" & vbCrLf
    End If
    strStatus = strStatus & "Entfernungen: " & lngEntf & " berechnet" & vbCrLf
    strStatus = strStatus & "(Maximal möglich: " & lngObjGeo * lngMAGeo & ")"
    
    MsgBox strStatus, vbInformation, "Geo-Feature Status"
    GeoFeature_Status = strStatus
End Function

' ------------------------------------------------------------
' OBJEKTE FÜR AKTUELLE AUFTRÄGE GEOCODIEREN
' Im Direktfenster: ?GeocodeObjekteFuerAktuelleAuftraege()
' ------------------------------------------------------------
Public Function GeocodeObjekteFuerAktuelleAuftraege() As Long
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim strSQL As String
    Dim lngCount As Long
    Dim vResult As Variant
    
    Set db = CurrentDb
    
    ' Finde Objekte aus Aufträgen ab heute ohne Koordinaten
    strSQL = "SELECT DISTINCT O.ID, O.Strasse, O.PLZ, O.Ort " & _
             "FROM tbl_OB_Objekt AS O " & _
             "INNER JOIN tbl_VA_Auftragstamm AS A ON A.Objekt_ID = O.ID " & _
             "INNER JOIN tbl_VA_AnzTage AS T ON T.VA_ID = A.ID " & _
             "WHERE T.VADatum >= Date() " & _
             "AND O.ID NOT IN (SELECT Objekt_ID FROM tbl_OB_Geo WHERE Lat <> 0)"
    
    Set rs = db.OpenRecordset(strSQL, dbOpenSnapshot)
    
    Do While Not rs.EOF
        If Nz(rs!Strasse, "") <> "" Or Nz(rs!PLZ, "") <> "" Or Nz(rs!Ort, "") <> "" Then
            vResult = GeocodeAdresse_OSM(Nz(rs!Strasse, ""), Nz(rs!PLZ, ""), Nz(rs!Ort, ""))
            If vResult(0) <> 0 Then
                On Error Resume Next
                db.Execute "DELETE FROM tbl_OB_Geo WHERE Objekt_ID = " & rs!ID
                On Error GoTo 0
                db.Execute "INSERT INTO tbl_OB_Geo (Objekt_ID, Strasse, PLZ, Ort, Land, Lat, Lon) VALUES (" & _
                         rs!ID & ", '" & Replace(Nz(rs!Strasse, ""), "'", "''") & "', '" & _
                         Nz(rs!PLZ, "") & "', '" & Replace(Nz(rs!Ort, ""), "'", "''") & "', 'Germany', " & _
                         Replace(vResult(0), ",", ".") & ", " & Replace(vResult(1), ",", ".") & ")", dbFailOnError
                CalcDistanceForObjekt rs!ID
                lngCount = lngCount + 1
            End If
            DoEvents
        End If
        rs.MoveNext
    Loop
    rs.Close
    
    GeocodeObjekteFuerAktuelleAuftraege = lngCount
End Function

' ------------------------------------------------------------
' NEUES OBJEKT AUTOMATISCH GEOCODIEREN
' Aufruf nach Speichern: AutoGeocode_NeuesObjekt Me.ID
' ------------------------------------------------------------
Public Sub AutoGeocode_NeuesObjekt(lngObjektID As Long)
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim vResult As Variant
    
    If lngObjektID = 0 Then Exit Sub
    
    Set db = CurrentDb
    Set rs = db.OpenRecordset("SELECT Strasse, PLZ, Ort FROM tbl_OB_Objekt WHERE ID = " & lngObjektID, dbOpenSnapshot)
    
    If Not rs.EOF Then
        If Nz(rs!Strasse, "") <> "" Or Nz(rs!PLZ, "") <> "" Or Nz(rs!Ort, "") <> "" Then
            vResult = GeocodeAdresse_OSM(Nz(rs!Strasse, ""), Nz(rs!PLZ, ""), Nz(rs!Ort, ""))
            If vResult(0) <> 0 Then
                On Error Resume Next
                db.Execute "DELETE FROM tbl_OB_Geo WHERE Objekt_ID = " & lngObjektID
                On Error GoTo 0
                db.Execute "INSERT INTO tbl_OB_Geo (Objekt_ID, Strasse, PLZ, Ort, Land, Lat, Lon) VALUES (" & _
                         lngObjektID & ", '" & Replace(Nz(rs!Strasse, ""), "'", "''") & "', '" & _
                         Nz(rs!PLZ, "") & "', '" & Replace(Nz(rs!Ort, ""), "'", "''") & "', 'Germany', " & _
                         Replace(vResult(0), ",", ".") & ", " & Replace(vResult(1), ",", ".") & ")", dbFailOnError
                CalcDistanceForObjekt lngObjektID
            End If
        End If
    End If
    rs.Close
End Sub

' ------------------------------------------------------------
' NEUER MITARBEITER AUTOMATISCH GEOCODIEREN
' Aufruf nach Speichern: AutoGeocode_NeuerMA Me.ID
' ------------------------------------------------------------
Public Sub AutoGeocode_NeuerMA(lngMA_ID As Long)
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim rsOB As DAO.Recordset
    Dim vResult As Variant
    Dim dblDist As Double
    
    If lngMA_ID = 0 Then Exit Sub
    
    Set db = CurrentDb
    Set rs = db.OpenRecordset("SELECT Strasse, PLZ, Ort FROM tbl_MA_Mitarbeiterstamm WHERE ID = " & lngMA_ID, dbOpenSnapshot)
    
    If Not rs.EOF Then
        If Nz(rs!Strasse, "") <> "" Or Nz(rs!PLZ, "") <> "" Or Nz(rs!Ort, "") <> "" Then
            vResult = GeocodeAdresse_OSM(Nz(rs!Strasse, ""), Nz(rs!PLZ, ""), Nz(rs!Ort, ""))
            If vResult(0) <> 0 Then
                On Error Resume Next
                db.Execute "DELETE FROM tbl_MA_Geo WHERE MA_ID = " & lngMA_ID
                db.Execute "DELETE FROM tbl_MA_Objekt_Entfernung WHERE MA_ID = " & lngMA_ID
                On Error GoTo 0
                
                db.Execute "INSERT INTO tbl_MA_Geo (MA_ID, Strasse, PLZ, Ort, Land, Lat, Lon) VALUES (" & _
                         lngMA_ID & ", '" & Replace(Nz(rs!Strasse, ""), "'", "''") & "', '" & _
                         Nz(rs!PLZ, "") & "', '" & Replace(Nz(rs!Ort, ""), "'", "''") & "', 'Germany', " & _
                         Replace(vResult(0), ",", ".") & ", " & Replace(vResult(1), ",", ".") & ")", dbFailOnError
                
                ' Entfernungen zu allen Objekten berechnen
                Set rsOB = db.OpenRecordset("SELECT Objekt_ID, Lat, Lon FROM tbl_OB_Geo WHERE Lat <> 0", dbOpenSnapshot)
                Do While Not rsOB.EOF
                    dblDist = DistanceKm(vResult(0), vResult(1), rsOB!Lat, rsOB!Lon)
                    db.Execute "INSERT INTO tbl_MA_Objekt_Entfernung (MA_ID, Objekt_ID, Entf_KM, LetzteAktualisierung, Quelle) " & _
                             "VALUES (" & lngMA_ID & ", " & rsOB!Objekt_ID & ", " & Replace(dblDist, ",", ".") & ", Now(), 'Auto')", dbFailOnError
                    rsOB.MoveNext
                Loop
                rsOB.Close
            End If
        End If
    End If
    rs.Close
End Sub


