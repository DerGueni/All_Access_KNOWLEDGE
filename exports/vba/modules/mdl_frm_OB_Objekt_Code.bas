Attribute VB_Name = "mdl_frm_OB_Objekt_Code"
Option Compare Database
Option Explicit

Public Function cmdGeocode_Click() As Variant
    Dim frm As Form
    Dim strStrasse As String, strPLZ As String, strOrt As String
    Dim vResult As Variant
    Dim db As DAO.Database
    Dim strSQL As String
    Dim lngObjektID As Long
    Set frm = Screen.ActiveForm
    lngObjektID = Nz(frm!ID, 0)
    If lngObjektID = 0 Then
        MsgBox "Kein Objekt ausgewaehlt!", vbExclamation
        Exit Function
    End If
    strStrasse = Nz(frm!Strasse, "")
    strPLZ = Nz(frm!PLZ, "")
    strOrt = Nz(frm!Ort, "")
    If strStrasse = "" And strPLZ = "" And strOrt = "" Then
        MsgBox "Bitte zuerst Adresse eingeben!", vbExclamation
        Exit Function
    End If
    vResult = GeocodeAdresse_OSM(strStrasse, strPLZ, strOrt)
    If vResult(0) = 0 And vResult(1) = 0 Then
        MsgBox "Adresse konnte nicht gefunden werden.", vbInformation
        Exit Function
    End If
    Set db = CurrentDb
    On Error Resume Next
    db.Execute "DELETE FROM tbl_OB_Geo WHERE Objekt_ID = " & lngObjektID, dbFailOnError
    On Error GoTo 0
    strSQL = "INSERT INTO tbl_OB_Geo (Objekt_ID, Strasse, PLZ, Ort, Land, Lat, Lon) VALUES (" & _
             lngObjektID & ", '" & Replace(strStrasse, "'", "''") & "', '" & strPLZ & "', '" & _
             Replace(strOrt, "'", "''") & "', 'Germany', " & Replace(CStr(vResult(0)), ",", ".") & ", " & _
             Replace(CStr(vResult(1)), ",", ".") & ")"
    db.Execute strSQL, dbFailOnError
    MsgBox "Koordinaten gespeichert:" & vbCrLf & "Lat: " & vResult(0) & vbCrLf & "Lon: " & vResult(1), vbInformation
End Function

