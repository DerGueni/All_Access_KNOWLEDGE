Attribute VB_Name = "zmd_qry_frm_Funktionen"
Option Compare Database

'= = = = = = = = = = = = = = = = = = = =
' FRM_Zeiterfassiung
'= = = = = = = = = = = = = = = = = = = =

' VADatum_ID aus Combobox für lstZuo
Public Function get_frm_cmbVADatum_ID() As Long
On Error Resume Next
    get_frm_cmbVADatum_ID = Forms("frm_Zeiterfassung").get_cmbVADatum_ID()
End Function


' Überschuss in sub_MA_VA_Zuordnung
Public Function check_soll_ist_zuo(VAStart_ID As Long, PosNr As Integer) As Boolean
Dim Soll        As Integer
Dim sst         As Integer
Dim sql         As String
Dim startPos    As Integer

    Soll = Nz(TLookup("MA_Anzahl", VASTART, "ID=" & VAStart_ID), 0)
    Ist = Nz(TCount("*", ZUORDNUNG, "VAStart_ID=" & VAStart_ID), 0)
    sql = "SELECT MIN (PosNr) FROM " & ZUORDNUNG & " WHERE VAStart_ID=" & VAStart_ID
    startPos = DBEngine(0)(0).OpenRecordset(sql, dbOpenSnapshot)(0)
    
    If Soll = Ist Then
        check_soll_ist_zuo = True
    Else
        If PosNr <= startPos + Soll - 1 Then check_soll_ist_zuo = True
    End If
    
End Function


'= = = = = = = = = = = = = = = = = = = =
' zqry_Rch_Report_Anz_Pers
'= = = = = = = = = = = = = = = = = = = =


''Anzahl Stunden Rechnungsposition
'Function f_get_rch_std(VAStart_ID As Long, typ As String) As Double
'Dim std As VA_Stunden
'
'    std = get_std_VAStart(VAStart_ID)
'    Select Case typ
'        Case "Sicherheitspersonal"
'            f_get_rch_std = std.sicherheit
'
'        Case "Leitungspersonal"
'            f_get_rch_std = std.leitung
'
'        Case "Bereichsleitung"
'            f_get_rch_std = std.bereichsleitung
'
'        Case "Nacht"
'            f_get_rch_std = std.nacht
'
'        Case "Sonntag"
'            f_get_rch_std = std.sonntag
'
'        Case "Feiertag"
'            f_get_rch_std = std.feiertag
'
'    End Select
'
'End Function

