Option Compare Database
Option Explicit

Public Sub GeocodierenObjekt(frm As Form)
    Dim strStrasse As String, strPLZ As String, strOrt As String
    Dim vResult As Variant
    Dim db As DAO.Database
    Dim strSQL As String
    Dim lngObjektID As Long
    lngObjektID = Nz(frm!ID, 0)
    If lngObjektID = 0 Then
        MsgBox "Kein Objekt ausgewaehlt!", vbExclamation
        Exit Sub
    End If
    strStrasse = Nz(frm!Strasse, "")
    strPLZ = Nz(frm!PLZ, "")
    strOrt = Nz(frm!Ort, "")
    If strStrasse = "" And strPLZ = "" And strOrt = "" Then
        MsgBox "Bitte zuerst Adresse eingeben!", vbExclamation
        Exit Sub
    End If
    vResult = GeocodeAdresse_OSM(strStrasse, strPLZ, strOrt)
    If vResult(0) = 0 And vResult(1) = 0 Then
        MsgBox "Adresse konnte nicht gefunden werden.", vbInformation
        Exit Sub
    End If
    Set db = CurrentDb
    db.Execute "DELETE FROM tbl_OB_Geo WHERE Objekt_ID = " & lngObjektID, dbFailOnError
    strSQL = "INSERT INTO tbl_OB_Geo (Objekt_ID, Strasse, PLZ, Ort, Land, Lat, Lon) VALUES (" & _
             lngObjektID & ", '" & Replace(strStrasse, "'", "''") & "', '" & strPLZ & "', '" & _
             Replace(strOrt, "'", "''") & "', 'Germany', " & Replace(vResult(0), ",", ".") & ", " & _
             Replace(vResult(1), ",", ".") & ")"
    db.Execute strSQL, dbFailOnError
    MsgBox "Koordinaten gespeichert: " & vResult(0) & " / " & vResult(1), vbInformation
End Sub

Public Sub GeocodierenMA(frm As Form)
    Dim strStrasse As String, strPLZ As String, strOrt As String
    Dim vResult As Variant
    Dim db As DAO.Database
    Dim strSQL As String
    Dim lngMA_ID As Long
    lngMA_ID = Nz(frm!ID, 0)
    If lngMA_ID = 0 Then
        MsgBox "Kein Mitarbeiter ausgewaehlt!", vbExclamation
        Exit Sub
    End If
    strStrasse = Nz(frm!Strasse, "")
    strPLZ = Nz(frm!PLZ, "")
    strOrt = Nz(frm!Ort, "")
    If strStrasse = "" And strPLZ = "" And strOrt = "" Then
        MsgBox "Bitte zuerst Adresse eingeben!", vbExclamation
        Exit Sub
    End If
    vResult = GeocodeAdresse_OSM(strStrasse, strPLZ, strOrt)
    If vResult(0) = 0 And vResult(1) = 0 Then
        MsgBox "Adresse konnte nicht gefunden werden.", vbInformation
        Exit Sub
    End If
    Set db = CurrentDb
    db.Execute "DELETE FROM tbl_MA_Geo WHERE MA_ID = " & lngMA_ID, dbFailOnError
    strSQL = "INSERT INTO tbl_MA_Geo (MA_ID, Strasse, PLZ, Ort, Land, Lat, Lon) VALUES (" & _
             lngMA_ID & ", '" & Replace(strStrasse, "'", "''") & "', '" & strPLZ & "', '" & _
             Replace(strOrt, "'", "''") & "', 'Germany', " & Replace(vResult(0), ",", ".") & ", " & _
             Replace(vResult(1), ",", ".") & ")"
    db.Execute strSQL, dbFailOnError
    MsgBox "Koordinaten gespeichert: " & vResult(0) & " / " & vResult(1), vbInformation
End Sub

Public Sub SwitchLSTMA_Standard(frm As Form)
    frm!LSTMA.RowSource = "ztbl_MA_Schnellauswahl"
    frm!LSTMA.Requery
End Sub

Public Sub SwitchLSTMA_Entfernung(frm As Form, lngObjektID As Long)
    Dim strSQL As String
    strSQL = "SELECT MA.ID AS MA_ID, MA.Nachname & ', ' & MA.Vorname & ' (' & Format(Nz(D.Entf_KM,0),'0.0') & ' km)' AS Anzeige " & _
             "FROM (ztbl_MA_Schnellauswahl AS S INNER JOIN tbl_MA_Mitarbeiterstamm AS MA ON MA.ID = S.MA_ID) " & _
             "LEFT JOIN tbl_MA_Objekt_Entfernung AS D ON D.MA_ID = MA.ID AND D.Objekt_ID = " & lngObjektID & " " & _
             "ORDER BY Nz(D.Entf_KM,9999), MA.Nachname, MA.Vorname"
    frm!LSTMA.RowSource = strSQL
    frm!LSTMA.Requery
End Sub