Attribute VB_Name = "Modul10"
Option Compare Database
Option Explicit
'
'Public Function AutoGeocodeNeuesObjekt(strObjekt As String, strOrt As String) As Long
'    Dim db As DAO.Database
'    Dim rs As DAO.Recordset
'    Dim lngObjektID As Long
'    Dim dblLat As Double
'    Dim dblLon As Double
'
'    If Len(Trim(strObjekt)) = 0 Then Exit Function
'
'    Set db = CurrentDb
'
'    Set rs = db.OpenRecordset("SELECT ID FROM tbl_OB_Objekt WHERE Objekt = '" & Replace(strObjekt, "'", "''") & "'", dbOpenSnapshot)
'
'    If rs.EOF Then
'        db.Execute "INSERT INTO tbl_OB_Objekt (Objekt, Ort) VALUES ('" & Replace(strObjekt, "'", "''") & "', '" & Replace(strOrt, "'", "''") & "')", dbFailOnError
'        lngObjektID = DMax("ID", "tbl_OB_Objekt")
'
'        If GeocodeAdresseSimple(strObjekt & " " & strOrt & " Germany", dblLat, dblLon) Then
'            db.Execute "INSERT INTO tbl_OB_Geo (Objekt_ID, Lat, Lon) VALUES (" & lngObjektID & ", " & Replace(CStr(dblLat), ",", ".") & ", " & Replace(CStr(dblLon), ",", ".") & ")", dbFailOnError
'        End If
'    Else
'        lngObjektID = rs!ID
'
'        Dim rsGeo As DAO.Recordset
'        Set rsGeo = db.OpenRecordset("SELECT Objekt_ID FROM tbl_OB_Geo WHERE Objekt_ID = " & lngObjektID, dbOpenSnapshot)
'        If rsGeo.EOF Then
'            If GeocodeAdresseSimple(strObjekt & " " & strOrt & " Germany", dblLat, dblLon) Then
'                db.Execute "INSERT INTO tbl_OB_Geo (Objekt_ID, Lat, Lon) VALUES (" & lngObjektID & ", " & Replace(CStr(dblLat), ",", ".") & ", " & Replace(CStr(dblLon), ",", ".") & ")", dbFailOnError
'            End If
'        End If
'        rsGeo.Close
'    End If
'    rs.Close
'
'    AutoGeocodeNeuesObjekt = lngObjektID
'End Function

Private Function GeocodeAdresseSimple(strQuery As String, ByRef dblLat As Double, ByRef dblLon As Double) As Boolean
    Dim http As Object
    Dim strURL As String
    Dim strResponse As String
    
    On Error GoTo ErrHandler
    
    strURL = "https://nominatim.openstreetmap.org/search?q=" & UrlEncSimple(strQuery) & "&format=json&limit=1"
    
    Set http = CreateObject("MSXML2.XMLHTTP")
    http.Open "GET", strURL, False
    http.setRequestHeader "User-Agent", "ConsecGeoApp/1.0"
    http.send
    strResponse = http.responseText
    
    If InStr(strResponse, """lat""") > 0 Then
        dblLat = ExtractJsonSimple(strResponse, "lat")
        dblLon = ExtractJsonSimple(strResponse, "lon")
        GeocodeAdresseSimple = True
    End If
    
    Set http = Nothing
    Exit Function
    
ErrHandler:
    GeocodeAdresseSimple = False
End Function

Private Function UrlEncSimple(strText As String) As String
    Dim i As Long
    Dim c As String
    Dim encoded As String
    
    For i = 1 To Len(strText)
        c = Mid(strText, i, 1)
        Select Case Asc(c)
            Case 48 To 57, 65 To 90, 97 To 122, 45, 46, 95
                encoded = encoded & c
            Case 32
                encoded = encoded & "+"
            Case Else
                encoded = encoded & "%" & Right("0" & Hex(Asc(c)), 2)
        End Select
    Next i
    UrlEncSimple = encoded
End Function

Private Function ExtractJsonSimple(strJSON As String, strKey As String) As Double
    Dim pos As Long
    Dim posEnd As Long
    Dim strVal As String
    
    pos = InStr(strJSON, """" & strKey & """:""")
    If pos > 0 Then
        pos = pos + Len(strKey) + 4
        posEnd = InStr(pos, strJSON, """")
        strVal = Mid(strJSON, pos, posEnd - pos)
        ExtractJsonSimple = val(strVal)
    Else
        ExtractJsonSimple = 0
    End If
End Function
