Attribute VB_Name = "mdl_BatchGeocode"
Option Compare Database
Option Explicit

Public Function BatchGeocodeObjekte() As Long
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim vResult As Variant
    Dim strSQL As String
    Dim lngCount As Long
    Set db = CurrentDb
    Set rs = db.OpenRecordset("SELECT ID, Strasse, PLZ, Ort FROM tbl_OB_Objekt WHERE ID NOT IN (SELECT Objekt_ID FROM tbl_OB_Geo WHERE Lat <> 0)", dbOpenSnapshot)
    Do While Not rs.EOF
        If Nz(rs!Strasse, "") <> "" Or Nz(rs!PLZ, "") <> "" Or Nz(rs!Ort, "") <> "" Then
            vResult = GeocodeAdresse_OSM(Nz(rs!Strasse, ""), Nz(rs!PLZ, ""), Nz(rs!Ort, ""))
            If vResult(0) <> 0 Or vResult(1) <> 0 Then
                On Error Resume Next
                db.Execute "DELETE FROM tbl_OB_Geo WHERE Objekt_ID = " & rs!ID
                On Error GoTo 0
                strSQL = "INSERT INTO tbl_OB_Geo (Objekt_ID, Strasse, PLZ, Ort, Land, Lat, Lon) VALUES (" & _
                         rs!ID & ", '" & Replace(Nz(rs!Strasse, ""), "'", "''") & "', '" & Nz(rs!PLZ, "") & "', '" & _
                         Replace(Nz(rs!Ort, ""), "'", "''") & "', 'Germany', " & Replace(vResult(0), ",", ".") & ", " & _
                         Replace(vResult(1), ",", ".") & ")"
                db.Execute strSQL, dbFailOnError
                lngCount = lngCount + 1
            End If
            DoEvents
        End If
        rs.MoveNext
    Loop
    rs.Close
    BatchGeocodeObjekte = lngCount
End Function

Public Function BatchGeocodeMA() As Long
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim vResult As Variant
    Dim strSQL As String
    Dim lngCount As Long
    Set db = CurrentDb
    Set rs = db.OpenRecordset("SELECT ID, Strasse, PLZ, Ort FROM tbl_MA_Mitarbeiterstamm WHERE ID NOT IN (SELECT MA_ID FROM tbl_MA_Geo WHERE Lat <> 0)", dbOpenSnapshot)
    Do While Not rs.EOF
        If Nz(rs!Strasse, "") <> "" Or Nz(rs!PLZ, "") <> "" Or Nz(rs!Ort, "") <> "" Then
            vResult = GeocodeAdresse_OSM(Nz(rs!Strasse, ""), Nz(rs!PLZ, ""), Nz(rs!Ort, ""))
            If vResult(0) <> 0 Or vResult(1) <> 0 Then
                On Error Resume Next
                db.Execute "DELETE FROM tbl_MA_Geo WHERE MA_ID = " & rs!ID
                On Error GoTo 0
                strSQL = "INSERT INTO tbl_MA_Geo (MA_ID, Strasse, PLZ, Ort, Land, Lat, Lon) VALUES (" & _
                         rs!ID & ", '" & Replace(Nz(rs!Strasse, ""), "'", "''") & "', '" & Nz(rs!PLZ, "") & "', '" & _
                         Replace(Nz(rs!Ort, ""), "'", "''") & "', 'Germany', " & Replace(vResult(0), ",", ".") & ", " & _
                         Replace(vResult(1), ",", ".") & ")"
                db.Execute strSQL, dbFailOnError
                lngCount = lngCount + 1
            End If
            DoEvents
        End If
        rs.MoveNext
    Loop
    rs.Close
    BatchGeocodeMA = lngCount
End Function

