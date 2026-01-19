Attribute VB_Name = "Modul18"
Option Compare Database
Option Explicit
'
'Public Function AutoGeocodeNeuesObjekt(strObjekt As String, strOrt As String) As Long
'    Dim db As DAO.Database
'    Dim rs As DAO.Recordset
'    Dim lngObjektID As Long
'    Dim varCoords As Variant
'
'    If Len(Trim(strObjekt)) = 0 Then Exit Function
'
'    Set db = CurrentDb
'    Set rs = db.OpenRecordset("SELECT ID FROM tbl_OB_Objekt WHERE Objekt = '" & Replace(strObjekt, "'", "''") & "'", dbOpenSnapshot)
'
'    If rs.EOF Then
'        db.Execute "INSERT INTO tbl_OB_Objekt (Objekt, Ort) VALUES ('" & Replace(strObjekt, "'", "''") & "', '" & Replace(strOrt, "'", "''") & "')", dbFailOnError
'        lngObjektID = DMax("ID", "tbl_OB_Objekt")
'        varCoords = GeocodeObjektByName(strObjekt, strOrt)
'        If varCoords(0) <> 0 Then
'            db.Execute "INSERT INTO tbl_OB_Geo (Objekt_ID, Lat, Lon) VALUES (" & lngObjektID & ", " & Replace(CStr(varCoords(0)), ",", ".") & ", " & Replace(CStr(varCoords(1)), ",", ".") & ")", dbFailOnError
'        End If
'    Else
'        lngObjektID = rs!ID
'        Dim rsGeo As DAO.Recordset
'        Set rsGeo = db.OpenRecordset("SELECT Objekt_ID FROM tbl_OB_Geo WHERE Objekt_ID = " & lngObjektID, dbOpenSnapshot)
'        If rsGeo.EOF Then
'            varCoords = GeocodeObjektByName(strObjekt, strOrt)
'            If varCoords(0) <> 0 Then
'                db.Execute "INSERT INTO tbl_OB_Geo (Objekt_ID, Lat, Lon) VALUES (" & lngObjektID & ", " & Replace(CStr(varCoords(0)), ",", ".") & ", " & Replace(CStr(varCoords(1)), ",", ".") & ")", dbFailOnError
'            End If
'        End If
'        rsGeo.Close
'    End If
'    rs.Close
'    AutoGeocodeNeuesObjekt = lngObjektID
'End Function
'
'Public Function GeocodeObjektByName(strObjekt As String, strOrt As String) As Variant
'    Dim strQuery As String, strURL As String, strResponse As String
'    Dim http As Object, dblLat As Double, dblLon As Double
'
'    strQuery = strObjekt & " " & strOrt & " Germany"
'    strURL = "https://nominatim.openstreetmap.org/search?q=" & URLEncodeGeo(strQuery) & "&format=json&limit=1"
'
'    On Error GoTo ErrHandler
'    Set http = CreateObject("MSXML2.XMLHTTP")
'    http.Open "GET", strURL, False
'    http.setRequestHeader "User-Agent", "ConsecGeoApp/1.0"
'    http.send
'    strResponse = http.responseText
'
'    If InStr(strResponse, Chr(34) & "lat" & Chr(34)) > 0 Then
'        dblLat = ExtractJSONValueGeo(strResponse, "lat")
'        dblLon = ExtractJSONValueGeo(strResponse, "lon")
'    End If
'    Set http = Nothing
'    GeocodeObjektByName = Array(dblLat, dblLon)
'    Exit Function
'ErrHandler:
'    GeocodeObjektByName = Array(0, 0)
'End Function
'
'Private Function URLEncodeGeo(strText As String) As String
'    Dim i As Long, c As String, encoded As String
'    For i = 1 To Len(strText)
'        c = Mid(strText, i, 1)
'        Select Case Asc(c)
'            Case 48 To 57, 65 To 90, 97 To 122, 45, 46, 95: encoded = encoded & c
'            Case 32: encoded = encoded & "+"
'            Case Else: encoded = encoded & "%" & Right("0" & Hex(Asc(c)), 2)
'        End Select
'    Next i
'    URLEncodeGeo = encoded
'End Function
'
'Private Function ExtractJSONValueGeo(strJSON As String, strKey As String) As Double
'    Dim pos As Long, posEnd As Long, strVal As String
'    pos = InStr(strJSON, Chr(34) & strKey & Chr(34) & ":" & Chr(34))
'    If pos > 0 Then
'        pos = pos + Len(strKey) + 4
'        posEnd = InStr(pos, strJSON, Chr(34))
'        strVal = Mid(strJSON, pos, posEnd - pos)
'        ExtractJSONValueGeo = CDbl(Replace(strVal, ".", ","))
'    End If
'End Function
'
'Public Function VA_AfterUpdate_AutoGeo() As Boolean
'    Dim frm As Form, strObjekt As String, strOrt As String, lngObjektID As Long
'    On Error Resume Next
'    Set frm = Screen.ActiveForm
'    strObjekt = Nz(frm!Objekt, "")
'    strOrt = Nz(frm!Ort, "")
'    If Len(strObjekt) > 0 And Len(strOrt) > 0 Then
'        lngObjektID = AutoGeocodeNeuesObjekt(strObjekt, strOrt)
'        If lngObjektID > 0 And (Nz(frm!Objekt_ID, 0) = 0) Then frm!Objekt_ID = lngObjektID
'    End If
'    VA_AfterUpdate_AutoGeo = True
'End Function
