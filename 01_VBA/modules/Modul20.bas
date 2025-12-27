Attribute VB_Name = "Modul20"
Option Compare Database
Option Explicit

'Public Function AutoGeocodeNeuesObjekt(strObjekt As String, strOrt As String) As Long
'    Dim db As DAO.Database, rs As DAO.Recordset, lngObjektID As Long, varCoords As Variant
'    If Len(Trim(strObjekt)) = 0 Then Exit Function
'    Set db = CurrentDb
'    Set rs = db.OpenRecordset("SELECT ID FROM tbl_OB_Objekt WHERE Objekt = '" & Replace(strObjekt, "'", "''") & "'", dbOpenSnapshot)
'    If rs.EOF Then
'        db.Execute "INSERT INTO tbl_OB_Objekt (Objekt, Ort) VALUES ('" & Replace(strObjekt, "'", "''") & "', '" & Replace(strOrt, "'", "''") & "')", dbFailOnError
'        lngObjektID = DMax("ID", "tbl_OB_Objekt")
'        varCoords = GeocodeObjektByName(strObjekt, strOrt)
'        If varCoords(0) <> 0 Then db.Execute "INSERT INTO tbl_OB_Geo (Objekt_ID, Lat, Lon) VALUES (" & lngObjektID & ", " & Replace(CStr(varCoords(0)), ",", ".") & ", " & Replace(CStr(varCoords(1)), ",", ".") & ")", dbFailOnError
'    Else
'        lngObjektID = rs!ID
'    End If
'    rs.Close
'    AutoGeocodeNeuesObjekt = lngObjektID
'End Function
'
'Public Function GeocodeObjektByName(strObjekt As String, strOrt As String) As Variant
'    Dim strURL As String, strResponse As String, http As Object, dblLat As Double, dblLon As Double
'    strURL = "https://nominatim.openstreetmap.org/search?q=" & URLEncGeo(strObjekt & " " & strOrt & " Germany") & "&format=json&limit=1"
'    On Error GoTo ErrH
'    Set http = CreateObject("MSXML2.XMLHTTP")
'    http.Open "GET", strURL, False
'    http.setRequestHeader "User-Agent", "ConsecGeoApp/1.0"
'    http.send
'    strResponse = http.responseText
'    If InStr(strResponse, Chr(34) & "lat" & Chr(34)) > 0 Then
'        dblLat = ExtJSONVal(strResponse, "lat")
'        dblLon = ExtJSONVal(strResponse, "lon")
'    End If
'    GeocodeObjektByName = Array(dblLat, dblLon)
'    Exit Function
'ErrH:
'    GeocodeObjektByName = Array(0, 0)
'End Function
'
'Private Function URLEncGeo(s As String) As String
'    Dim i As Long, c As String, e As String
'    For i = 1 To Len(s)
'        c = Mid(s, i, 1)
'        Select Case Asc(c)
'            Case 48 To 57, 65 To 90, 97 To 122, 45, 46, 95: e = e & c
'            Case 32: e = e & "+"
'            Case Else: e = e & "%" & Right("0" & Hex(Asc(c)), 2)
'        End Select
'    Next
'    URLEncGeo = e
'End Function
'
'Private Function ExtJSONVal(j As String, k As String) As Double
'    Dim p As Long, pe As Long, v As String
'    p = InStr(j, Chr(34) & k & Chr(34) & ":" & Chr(34))
'    If p > 0 Then
'        p = p + Len(k) + 4
'        pe = InStr(p, j, Chr(34))
'        v = Mid(j, p, pe - p)
'        ExtJSONVal = CDbl(Replace(v, ".", ","))
'    End If
'End Function
