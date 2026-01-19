Attribute VB_Name = "mdl_GeoDistanz1"
Option Compare Database
Option Explicit

Private Const PI As Double = 3.14159265358979
Private Const EARTH_RADIUS_KM As Double = 6371

Public Function DistanceKm(Lat1 As Double, Lon1 As Double, Lat2 As Double, Lon2 As Double) As Double
    Dim dLat As Double, dLon As Double
    Dim a As Double, c As Double
    
    If Lat1 = 0 Or Lon1 = 0 Or Lat2 = 0 Or Lon2 = 0 Then
        DistanceKm = 9999
        Exit Function
    End If
    
    dLat = (Lat2 - Lat1) * PI / 180
    dLon = (Lon2 - Lon1) * PI / 180
    a = Sin(dLat / 2) * Sin(dLat / 2) + Cos(Lat1 * PI / 180) * Cos(Lat2 * PI / 180) * Sin(dLon / 2) * Sin(dLon / 2)
    c = 2 * Atn(Sqr(a) / Sqr(1 - a))
    DistanceKm = Round(EARTH_RADIUS_KM * c, 2)
End Function

Public Function GeoDistanz_Version() As String
    GeoDistanz_Version = "1.0 - 2025-05-30"
End Function
