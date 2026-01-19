Option Compare Database
Option Explicit

Public Sub RunBatchGeocodeObjekte()
    Dim lngCount As Long
    If MsgBox("Alle Objekte ohne Koordinaten geocodieren?", vbYesNo + vbQuestion) = vbYes Then
        lngCount = BatchGeocodeObjekte()
        MsgBox lngCount & " Objekte geocodiert.", vbInformation
    End If
End Sub

Public Sub RunBatchGeocodeMA()
    Dim lngCount As Long
    If MsgBox("Alle Mitarbeiter ohne Koordinaten geocodieren?", vbYesNo + vbQuestion) = vbYes Then
        lngCount = BatchGeocodeMA()
        MsgBox lngCount & " Mitarbeiter geocodiert.", vbInformation
    End If
End Sub

Public Sub RunBuildAllDistances()
    Dim lngCount As Long
    If MsgBox("Entfernungsmatrix komplett neu berechnen?", vbYesNo + vbQuestion) = vbYes Then
        lngCount = BuildAllDistances()
        MsgBox lngCount & " Entfernungen berechnet.", vbInformation
    End If
End Sub

Public Sub ShowGeoStats()
    Dim strMsg As String
    strMsg = "GEO-STATISTIK:" & vbCrLf & vbCrLf
    strMsg = strMsg & "Objekte mit Koordinaten: " & DCount("*", "tbl_OB_Geo", "Lat <> 0") & vbCrLf
    strMsg = strMsg & "Mitarbeiter mit Koordinaten: " & DCount("*", "tbl_MA_Geo", "Lat <> 0") & vbCrLf
    strMsg = strMsg & "Entfernungen berechnet: " & DCount("*", "tbl_MA_Objekt_Entfernung") & vbCrLf
    MsgBox strMsg, vbInformation, "Geo-Status"
End Sub