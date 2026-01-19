Attribute VB_Name = "mdl_TempGeo"
Option Compare Database
Option Explicit

Public Function GeocodeLowensaal() As String
    Dim vResult As Variant
    Dim db As DAO.Database
    Dim strSQL As String
    vResult = GeocodeAdresse_OSM("Tucherstrasse 2", "90403", "Nuernberg")
    If vResult(0) = 0 And vResult(1) = 0 Then
        GeocodeLowensaal = "Fehler: Adresse nicht gefunden"
        Exit Function
    End If
    Set db = CurrentDb
    On Error Resume Next
    db.Execute "DELETE FROM tbl_OB_Geo WHERE Objekt_ID = 7", dbFailOnError
    On Error GoTo 0
    strSQL = "INSERT INTO tbl_OB_Geo (Objekt_ID, Strasse, PLZ, Ort, Land, Lat, Lon) VALUES (7, 'Tucherstrasse 2', '90403', 'Nuernberg', 'Germany', " & Replace(CStr(vResult(0)), ",", ".") & ", " & Replace(CStr(vResult(1)), ",", ".") & ")"
    db.Execute strSQL, dbFailOnError
    GeocodeLowensaal = "Lat: " & vResult(0) & " / Lon: " & vResult(1)
End Function
