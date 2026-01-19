Attribute VB_Name = "mdl_Distanzberechnung"
Option Compare Database
Option Explicit

'Public Function BuildAllDistances() As Long
'    Dim db As DAO.Database
'    Dim rsMA As DAO.Recordset, rsOB As DAO.Recordset
'    Dim strSQL As String
'    Dim dblDist As Double
'    Dim lngCount As Long
'    Set db = CurrentDb
'    db.Execute "DELETE * FROM tbl_MA_Objekt_Entfernung", dbFailOnError
'    Set rsMA = db.OpenRecordset("SELECT MA_ID, Lat, Lon FROM tbl_MA_Geo WHERE Lat <> 0 AND Lon <> 0", dbOpenSnapshot)
'    Set rsOB = db.OpenRecordset("SELECT Objekt_ID, Lat, Lon FROM tbl_OB_Geo WHERE Lat <> 0 AND Lon <> 0", dbOpenSnapshot)
'    Do While Not rsMA.EOF
'        rsOB.MoveFirst
'        Do While Not rsOB.EOF
'            dblDist = DistanceKm(rsMA!Lat, rsMA!Lon, rsOB!Lat, rsOB!Lon)
'            strSQL = "INSERT INTO tbl_MA_Objekt_Entfernung (MA_ID, Objekt_ID, Entf_KM, LetzteAktualisierung, Quelle) " & _
'                     "VALUES (" & rsMA!MA_ID & ", " & rsOB!Objekt_ID & ", " & Replace(dblDist, ",", ".") & ", Now(), 'Haversine')"
'            db.Execute strSQL, dbFailOnError
'            lngCount = lngCount + 1
'            rsOB.MoveNext
'        Loop
'        rsMA.MoveNext
'    Loop
'    rsMA.Close: rsOB.Close
'    Set rsMA = Nothing: Set rsOB = Nothing: Set db = Nothing
'    BuildAllDistances = lngCount
'End Function

Public Function CalcDistanceForObjekt(lngObjektID As Long) As Long
    Dim db As DAO.Database
    Dim rsMA As DAO.Recordset, rsOB As DAO.Recordset
    Dim dblDist As Double, lngCount As Long
    Dim strSQL As String
    Set db = CurrentDb
    db.Execute "DELETE * FROM tbl_MA_Objekt_Entfernung WHERE Objekt_ID = " & lngObjektID, dbFailOnError
    Set rsOB = db.OpenRecordset("SELECT Lat, Lon FROM tbl_OB_Geo WHERE Objekt_ID = " & lngObjektID, dbOpenSnapshot)
    If rsOB.EOF Then
        CalcDistanceForObjekt = 0
        Exit Function
    End If
    Set rsMA = db.OpenRecordset("SELECT MA_ID, Lat, Lon FROM tbl_MA_Geo WHERE Lat <> 0 AND Lon <> 0", dbOpenSnapshot)
    Do While Not rsMA.EOF
        dblDist = DistanceKm(rsMA!Lat, rsMA!Lon, rsOB!Lat, rsOB!Lon)
        strSQL = "INSERT INTO tbl_MA_Objekt_Entfernung (MA_ID, Objekt_ID, Entf_KM, LetzteAktualisierung, Quelle) " & _
                 "VALUES (" & rsMA!MA_ID & ", " & lngObjektID & ", " & Replace(dblDist, ",", ".") & ", Now(), 'Haversine')"
        db.Execute strSQL, dbFailOnError
        lngCount = lngCount + 1
        rsMA.MoveNext
    Loop
    rsMA.Close: rsOB.Close
    CalcDistanceForObjekt = lngCount
End Function

Public Function DistanceExists(lngMA_ID As Long, lngObjektID As Long) As Boolean
    DistanceExists = (DCount("*", "tbl_MA_Objekt_Entfernung", "MA_ID=" & lngMA_ID & " AND Objekt_ID=" & lngObjektID) > 0)
End Function

