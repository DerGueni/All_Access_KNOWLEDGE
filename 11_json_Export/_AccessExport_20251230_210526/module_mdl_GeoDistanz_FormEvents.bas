Option Compare Database
Option Explicit

' ============================================================
' mdl_GeoDistanz_FormEvents - Button-Logik
' ============================================================

Public Sub LSTMA_SetStandard(frm As Form)
    On Error Resume Next
    frm!LSTMA.RowSource = "ztbl_MA_Schnellauswahl"
    frm!LSTMA.Requery
    MsgBox "Standard-Modus aktiviert", vbInformation
End Sub

Public Sub LSTMA_SetEntfernung(frm As Form, Optional objektID As Long = 0)
    Dim sql As String
    On Error Resume Next
    
    If objektID = 0 Then
        If Not IsNull(frm!txtObjektID) Then objektID = frm!txtObjektID
    End If
    
    If objektID = 0 Then
        MsgBox "Bitte erst ein Objekt auswählen!", vbExclamation
        Exit Sub
    End If
    
    sql = "SELECT MA.ID, MA.Nachname & ', ' & MA.Vorname & ' (' & Format(Nz(D.Entf_KM,9999),'0.0') & ' km)' AS Anzeige " & _
          "FROM (ztbl_MA_Schnellauswahl AS S INNER JOIN tbl_MA_Mitarbeiterstamm AS MA ON MA.ID=S.MA_ID) " & _
          "LEFT JOIN tbl_MA_Objekt_Entfernung AS D ON D.MA_ID=MA.ID AND D.Objekt_ID=" & objektID & " " & _
          "ORDER BY Nz(D.Entf_KM,9999), MA.Nachname"
    
    frm!LSTMA.RowSource = sql
    frm!LSTMA.Requery
    MsgBox "Entfernungs-Modus für Objekt " & objektID & " aktiviert", vbInformation
End Sub

Public Sub TestGeocode()
    Dim result As String
    result = GeocodeObjekt(1, "Messezentrum 1", "90471", "Nürnberg")
    MsgBox "Geocode-Test: " & result, vbInformation
End Sub

Public Sub RunBuildDistances()
    Dim result As String
    result = BuildAllDistances()
    MsgBox "Distanz-Batch: " & result, vbInformation
End Sub