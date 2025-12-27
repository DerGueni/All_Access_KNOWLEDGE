Attribute VB_Name = "mdl_Geocoding_DISABLED"
'Option Compare Database
'Option Explicit
'
'Private Const PI As Double = 3.14159265358979
'Private Const EARTH_RADIUS_KM As Double = 6371
'
'Public Function DistanceKm_REMOVED(Lat1 As Double, Lon1 As Double, Lat2 As Double, Lon2 As Double) As Double
'    Dim dLat As Double, dLon As Double
'    Dim a As Double, c As Double
'    dLat = (Lat2 - Lat1) * PI / 180
'    dLon = (Lon2 - Lon1) * PI / 180
'    a = Sin(dLat / 2) * Sin(dLat / 2) + Cos(Lat1 * PI / 180) * Cos(Lat2 * PI / 180) * Sin(dLon / 2) * Sin(dLon / 2)
'    c = 2 * Atn(Sqr(a) / Sqr(1 - a))
'    DistanceKm = EARTH_RADIUS_KM * c
'End Function
'
'Public Function URLEncode(strText As String) As String
'    Dim i As Long, c As String, encoded As String
'    For i = 1 To Len(strText)
'        c = Mid(strText, i, 1)
'        Select Case Asc(c)
'            Case 48 To 57, 65 To 90, 97 To 122, 45, 46, 95
'                encoded = encoded & c
'            Case 32
'                encoded = encoded & "+"
'            Case Else
'                encoded = encoded & "%" & Right("0" & Hex(Asc(c)), 2)
'        End Select
'    Next i
'    URLEncode = encoded
'End Function
'
'Public Function GeocodeAdresse_OSM(strStrasse As String, strPLZ As String, strOrt As String, Optional strLand As String = "Germany") As Variant
'    Dim strURL As String, strResponse As String
'    Dim http As Object, json As Object
'    Dim Lat As Double, Lon As Double
'    Dim strQuery As String
'    strQuery = Trim(strStrasse) & ", " & Trim(strPLZ) & " " & Trim(strOrt) & ", " & strLand
'    strURL = "https://nominatim.openstreetmap.org/search?q=" & URLEncode(strQuery) & "&format=json&limit=1"
'    Set http = CreateObject("MSXML2.XMLHTTP")
'    http.Open "GET", strURL, False
'    http.setRequestHeader "User-Agent", "ConsecGeoApp/1.0"
'    http.send
'    strResponse = http.responseText
'    If InStr(strResponse, """lat""") > 0 Then
'        Lat = ExtractJSONValue(strResponse, "lat")
'        Lon = ExtractJSONValue(strResponse, "lon")
'        GeocodeAdresse_OSM = Array(Lat, Lon)
'    Else
'        GeocodeAdresse_OSM = Array(0, 0)
'    End If
'    Set http = Nothing
'End Function
'
'Private Function ExtractJSONValue(strJSON As String, strKey As String) As Double
'    Dim pos As Long, posEnd As Long, strVal As String
'    pos = InStr(strJSON, """" & strKey & """:""")
'    If pos > 0 Then
'        pos = pos + Len(strKey) + 4
'        posEnd = InStr(pos, strJSON, """")
'        strVal = Mid(strJSON, pos, posEnd - pos)
'        ExtractJSONValue = CDbl(Replace(strVal, ".", ","))
'    Else
'        ExtractJSONValue = 0
'    End If
'End Function
'
