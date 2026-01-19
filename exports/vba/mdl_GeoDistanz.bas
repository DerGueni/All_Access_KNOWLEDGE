Attribute VB_Name = "mdl_GeoDistanz"
Option Compare Database
Option Explicit

' ============================================================
' mdl_GeoDistanz - Geocoding & Distanzberechnung
' Erstellt: 2025-11-29 | Access Bridge
' ============================================================

Private Const PI As Double = 3.14159265358979
Private Const EARTH_RADIUS_KM As Double = 6371

' ------------------------------------------------------------
' URL-Encoding für Nominatim
' ------------------------------------------------------------
Public Function URLEncode(ByVal sText As String) As String
    Dim i As Long, c As String, result As String
    For i = 1 To Len(sText)
        c = Mid$(sText, i, 1)
        Select Case Asc(c)
            Case 48 To 57, 65 To 90, 97 To 122, 45, 46, 95, 126
                result = result & c
            Case 32
                result = result & "+"
            Case Else
                result = result & "%" & Right$("0" & Hex$(Asc(c)), 2)
        End Select
    Next i
    URLEncode = result
End Function

' ------------------------------------------------------------
' JSON-Wert extrahieren (einfach)
' ------------------------------------------------------------
Public Function ExtractJSONValue(ByVal json As String, ByVal key As String) As String
    Dim pos As Long, endPos As Long, startQuote As Long
    pos = InStr(1, json, """" & key & """", vbTextCompare)
    If pos = 0 Then Exit Function
    pos = InStr(pos, json, ":")
    If pos = 0 Then Exit Function
    pos = pos + 1
    Do While Mid$(json, pos, 1) = " " Or Mid$(json, pos, 1) = """"
        pos = pos + 1
    Loop
    If Mid$(json, pos - 1, 1) = """" Then
        endPos = InStr(pos, json, """")
        ExtractJSONValue = Mid$(json, pos, endPos - pos)
    Else
        endPos = pos
        Do While IsNumeric(Mid$(json, endPos, 1)) Or Mid$(json, endPos, 1) = "." Or Mid$(json, endPos, 1) = "-"
            endPos = endPos + 1
        Loop
        ExtractJSONValue = Mid$(json, pos, endPos - pos)
    End If
End Function

' ------------------------------------------------------------
' Geocoding via Nominatim (OpenStreetMap)
' ------------------------------------------------------------
Public Function GeocodeAdresse_OSM(ByVal Strasse As String, ByVal PLZ As String, ByVal Ort As String, Optional ByVal Land As String = "Germany") As Variant
    Dim http As Object, url As String, response As String
    Dim Lat As Double, Lon As Double
    Dim adresse As String
    
    adresse = Trim$(Strasse) & ", " & Trim$(PLZ) & " " & Trim$(Ort) & ", " & Land
    url = "https://nominatim.openstreetmap.org/search?q=" & URLEncode(adresse) & "&format=json&limit=1"
    
    Set http = CreateObject("MSXML2.XMLHTTP")
    http.Open "GET", url, False
    http.setRequestHeader "User-Agent", "ConsysAccessApp/1.0"
    
    On Error Resume Next
    http.Send
    If Err.Number <> 0 Then
        GeocodeAdresse_OSM = Array(0, 0, "HTTP-Fehler: " & Err.description)
        Exit Function
    End If
    On Error GoTo 0
    
    response = http.responseText
    Set http = Nothing
    
    If Len(response) < 10 Or InStr(response, """lat""") = 0 Then
        GeocodeAdresse_OSM = Array(0, 0, "Keine Koordinaten gefunden")
        Exit Function
    End If
    
    Lat = val(ExtractJSONValue(response, "lat"))
    Lon = val(ExtractJSONValue(response, "lon"))
    
    GeocodeAdresse_OSM = Array(Lat, Lon, "OK")
End Function

' ------------------------------------------------------------
' Haversine-Distanz in km
' ------------------------------------------------------------
Public Function DistanceKm(ByVal Lat1 As Double, ByVal Lon1 As Double, ByVal Lat2 As Double, ByVal Lon2 As Double) As Double
    Dim dLat As Double, dLon As Double, a As Double, c As Double
    
    If Lat1 = 0 Or Lon1 = 0 Or Lat2 = 0 Or Lon2 = 0 Then
        DistanceKm = 9999
        Exit Function
    End If
    
    dLat = (Lat2 - Lat1) * PI / 180
    dLon = (Lon2 - Lon1) * PI / 180
    
    a = Sin(dLat / 2) ^ 2 + Cos(Lat1 * PI / 180) * Cos(Lat2 * PI / 180) * Sin(dLon / 2) ^ 2
    c = 2 * Atn(Sqr(a) / Sqr(1 - a))
    
    DistanceKm = Round(EARTH_RADIUS_KM * c, 1)
End Function

' ------------------------------------------------------------
' Prüft ob Distanz bereits existiert
' ------------------------------------------------------------
Public Function DistanceExists(ByVal maID As Long, ByVal objektID As Long) As Boolean
    DistanceExists = (DCount("*", "tbl_MA_Objekt_Entfernung", "MA_ID=" & maID & " AND Objekt_ID=" & objektID) > 0)
End Function

' ------------------------------------------------------------
' Speichert/Aktualisiert eine Distanz
' ------------------------------------------------------------
Public Sub SaveDistance(ByVal maID As Long, ByVal objektID As Long, ByVal entfKm As Double)
    Dim sql As String
    If DistanceExists(maID, objektID) Then
        sql = "UPDATE tbl_MA_Objekt_Entfernung SET Entf_KM=" & Replace(entfKm, ",", ".") & ", LetzteAktualisierung=Now(), Quelle='Haversine' WHERE MA_ID=" & maID & " AND Objekt_ID=" & objektID
    Else
        sql = "INSERT INTO tbl_MA_Objekt_Entfernung (MA_ID, Objekt_ID, Entf_KM, LetzteAktualisierung, Quelle) VALUES (" & maID & "," & objektID & "," & Replace(entfKm, ",", ".") & ",Now(),'Haversine')"
    End If
    CurrentDb.Execute sql, dbFailOnError
End Sub

' ------------------------------------------------------------
' Batch: Alle Distanzen MA x Objekt berechnen
' ------------------------------------------------------------
Public Function BuildAllDistances() As String
    Dim rsMA As DAO.Recordset, rsOB As DAO.Recordset
    Dim latMA As Double, lonMA As Double, latOB As Double, lonOB As Double
    Dim dist As Double, countNew As Long, countTotal As Long
    
    Set rsMA = CurrentDb.OpenRecordset("SELECT MA_ID, Lat, Lon FROM tbl_MA_Geo WHERE Lat<>0 AND Lon<>0", dbOpenSnapshot)
    Set rsOB = CurrentDb.OpenRecordset("SELECT Objekt_ID, Lat, Lon FROM tbl_OB_Geo WHERE Lat<>0 AND Lon<>0", dbOpenSnapshot)
    
    If rsMA.EOF Or rsOB.EOF Then
        BuildAllDistances = "Keine Geo-Daten vorhanden"
        rsMA.Close: rsOB.Close
        Exit Function
    End If
    
    Do Until rsMA.EOF
        latMA = rsMA!Lat: lonMA = rsMA!Lon
        rsOB.MoveFirst
        Do Until rsOB.EOF
            If Not DistanceExists(rsMA!MA_ID, rsOB!Objekt_ID) Then
                dist = DistanceKm(latMA, lonMA, rsOB!Lat, rsOB!Lon)
                SaveDistance rsMA!MA_ID, rsOB!Objekt_ID, dist
                countNew = countNew + 1
            End If
            countTotal = countTotal + 1
            rsOB.MoveNext
        Loop
        rsMA.MoveNext
    Loop
    
    rsMA.Close: rsOB.Close
    BuildAllDistances = countNew & " neue von " & countTotal & " Kombinationen berechnet"
End Function

' ------------------------------------------------------------
' Geocode einzelnes Objekt
' ------------------------------------------------------------
Public Function GeocodeObjekt(ByVal objektID As Long, ByVal Strasse As String, ByVal PLZ As String, ByVal Ort As String) As String
    Dim result As Variant, sql As String
    
    result = GeocodeAdresse_OSM(Strasse, PLZ, Ort)
    
    If result(2) = "OK" Then
        If DCount("*", "tbl_OB_Geo", "Objekt_ID=" & objektID) > 0 Then
            sql = "UPDATE tbl_OB_Geo SET Strasse='" & Replace(Strasse, "'", "''") & "', PLZ='" & PLZ & "', Ort='" & Replace(Ort, "'", "''") & "', Land='Germany', Lat=" & Replace(result(0), ",", ".") & ", Lon=" & Replace(result(1), ",", ".") & " WHERE Objekt_ID=" & objektID
        Else
            sql = "INSERT INTO tbl_OB_Geo (Objekt_ID, Strasse, PLZ, Ort, Land, Lat, Lon) VALUES (" & objektID & ",'" & Replace(Strasse, "'", "''") & "','" & PLZ & "','" & Replace(Ort, "'", "''") & "','Germany'," & Replace(result(0), ",", ".") & "," & Replace(result(1), ",", ".") & ")"
        End If
        CurrentDb.Execute sql, dbFailOnError
        GeocodeObjekt = "OK: " & result(0) & " / " & result(1)
    Else
        GeocodeObjekt = "Fehler: " & result(2)
    End If
End Function

' ------------------------------------------------------------
' Geocode einzelnen Mitarbeiter
' ------------------------------------------------------------
Public Function GeocodeMA(ByVal maID As Long, ByVal Strasse As String, ByVal PLZ As String, ByVal Ort As String) As String
    Dim result As Variant, sql As String
    
    result = GeocodeAdresse_OSM(Strasse, PLZ, Ort)
    
    If result(2) = "OK" Then
        If DCount("*", "tbl_MA_Geo", "MA_ID=" & maID) > 0 Then
            sql = "UPDATE tbl_MA_Geo SET Strasse='" & Replace(Strasse, "'", "''") & "', PLZ='" & PLZ & "', Ort='" & Replace(Ort, "'", "''") & "', Land='Germany', Lat=" & Replace(result(0), ",", ".") & ", Lon=" & Replace(result(1), ",", ".") & " WHERE MA_ID=" & maID
        Else
            sql = "INSERT INTO tbl_MA_Geo (MA_ID, Strasse, PLZ, Ort, Land, Lat, Lon) VALUES (" & maID & ",'" & Replace(Strasse, "'", "''") & "','" & PLZ & "','" & Replace(Ort, "'", "''") & "','Germany'," & Replace(result(0), ",", ".") & "," & Replace(result(1), ",", ".") & ")"
        End If
        CurrentDb.Execute sql, dbFailOnError
        GeocodeMA = "OK: " & result(0) & " / " & result(1)
    Else
        GeocodeMA = "Fehler: " & result(2)
    End If
End Function
