Attribute VB_Name = "mdlKalenderfill"
Option Compare Database
Option Explicit

Dim ifc As Long
Dim ibc As Long
Dim iJahr As Long
Dim strCaption As String
Dim Feiername As String
Global Global_mitSumme As Boolean

'Call Form_Load_Year_Monat(MainForm, Me!cboBundesland, Me!iJahr, Me!JN_IstFerien)

Function Form_Load_Year_Monat(frm As Form, XBund As String, iJahr As Long, IstFerien As Boolean)
Dim iMon As Long, i As Long, j As Long, idaymax As Long, k As Long
Dim sqlStr As String
Dim strFldName As String
Dim Monatarr

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, DAOARRAY_Name1, iZl As Long, iCol As Long
Dim ArrFill_DAO_OK2 As Boolean, recsetSQL2 As String, iZLMax2 As Long, iColMax2 As Long, DAOARRAY2, DAOARRAY_Name2, iZl2 As Long, iCol2 As Long
Dim ArrFill_DAO_OK3 As Boolean, recsetSQL3 As String, iZLMax3 As Long, iColMax3 As Long, DAOARRAY3, DAOARRAY_Name3, iZl3 As Long, iCol3 As Long

Monatarr = Array(, "Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember")

Debug.Print frm.Name

recsetSQL1 = "qryHlp_Farben_used"
ArrFill_DAO_OK1 = ArrFill_DAO(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
''Info:   'AccessArray(iSpalte,iZeile) <0, 0>       'ExcelArray(iZeile, iSpalte) <1, 1>

' zeile 4 = Werktage   3 = Feiertage    2 = Sonntage     1 = Samstage  0 = Ferientage
' Spalte = 2 = Background   3 = Foreground (Textfarbe)

For iMon = 1 To 12

    For i = 1 To 6
        strFldName = "w1w" & i
        frm("frm_Kal_" & iMon).Form!(strFldName).caption = ""
        frm("frm_Kal_" & iMon).Form!(strFldName).Visible = False
                
        For j = 1 To 7
            strFldName = "btn1Tg" & i & j
            frm("frm_Kal_" & iMon).Form!(strFldName).caption = ""
            frm("frm_Kal_" & iMon).Form!(strFldName).Visible = False
        Next j
    Next i

    
    sqlStr = ""
    sqlStr = sqlStr & "SELECT qryHlp_Kal2_Alle.dtDatum, qryHlp_Kal2_Alle.JahrNr, qryHlp_Kal2_Alle.MonatNr, qryHlp_Kal2_Alle.TagNr,"
    sqlStr = sqlStr & " qryHlp_Kal2_Alle.Wochentag, qryHlp_Kal2_Alle.KW, qryHlp_Kal2_Alle.BtnWk, qryHlp_Kal2_Alle.BtnTg,"
    sqlStr = sqlStr & " qryHlp_Kal2_Alle.B" & XBund & ", qryHlp_Kal2_Alle.F" & XBund
    sqlStr = sqlStr & " FROM qryHlp_Kal2_Alle"
    sqlStr = sqlStr & " WHERE (((qryHlp_Kal2_Alle.JahrNr)=" & iJahr & ") AND ((qryHlp_Kal2_Alle.MonatNr)=" & iMon & ")) Order By qryHlp_Kal2_Alle.dtDatum;"

    idaymax = DateSerial(iJahr, iMon + 1, 0)

    frm("frm_Kal_" & iMon).Form!iJahr = iJahr
    frm("frm_Kal_" & iMon).Form!iMon = iMon
    frm("frm_Kal_" & iMon).Form!sub_Ueberschrift.caption = "'" & Monatarr(iMon) & "'"
    
    
    ArrFill_DAO_OK2 = ArrFill_DAO(sqlStr, iZLMax2, iColMax2, DAOARRAY2)
    If ArrFill_DAO_OK2 Then
        For iZl2 = 0 To iZLMax2
        
            'Wochennr
            strFldName = DAOARRAY2(6, iZl2)
            frm("frm_Kal_" & iMon).Form!(strFldName).caption = DAOARRAY2(5, iZl2)
            frm("frm_Kal_" & iMon).Form!(strFldName).Visible = True
            
            'Tag setzen
            strFldName = DAOARRAY2(7, iZl2)
            frm("frm_Kal_" & iMon).Form!(strFldName).caption = DAOARRAY2(3, iZl2)
            frm("frm_Kal_" & iMon).Form!(strFldName).Visible = True
            
            ' DAOARRAY1 = Farben
            ' zeile 4 = Werktage   3 = Feiertage    2 = Sonntage     1 = Samstage  0 = Ferientage
            ' Spalte = 2 = Background   3 = Foreground (Textfarbe)
                
            'Werktag
            frm("frm_Kal_" & iMon).Form!(strFldName).BackColor = DAOARRAY1(2, 4)
            frm("frm_Kal_" & iMon).Form!(strFldName).ForeColor = DAOARRAY1(3, 4)
            
            'Ferien
            If IstFerien = True And DAOARRAY2(9, iZl2) = True Then
                frm("frm_Kal_" & iMon).Form!(strFldName).BackColor = DAOARRAY1(2, 0)
                frm("frm_Kal_" & iMon).Form!(strFldName).ForeColor = DAOARRAY1(3, 0)
            End If
            
            'Samstag
            If DAOARRAY2(4, iZl2) = 6 Then
                frm("frm_Kal_" & iMon).Form!(strFldName).BackColor = DAOARRAY1(2, 1)
                frm("frm_Kal_" & iMon).Form!(strFldName).ForeColor = DAOARRAY1(3, 1)
            End If
            'Sonntag
            If DAOARRAY2(4, iZl2) = 7 Then
                frm("frm_Kal_" & iMon).Form!(strFldName).BackColor = DAOARRAY1(2, 2)
                frm("frm_Kal_" & iMon).Form!(strFldName).ForeColor = DAOARRAY1(3, 2)
            End If
            
            'Feiertag
            If DAOARRAY2(8, iZl2) = True Then
                frm("frm_Kal_" & iMon).Form!(strFldName).BackColor = DAOARRAY1(2, 3)
                frm("frm_Kal_" & iMon).Form!(strFldName).ForeColor = DAOARRAY1(3, 3)
            End If

        Next iZl2
    End If

'    recsetSQL3 = "SELECT qryHlp_Kal2_Alle.dtDatum, qryHlp_Kal2_Alle.JahrNr, qryHlp_Kal2_Alle.MonatNr, qryHlp_Kal2_Alle.TagNr,"
'    recsetSQL3 = recsetSQL3 & " qryHlp_Kal2_Alle.Wochentag , qryHlp_Kal2_Alle.KW, qryHlp_Kal2_Alle.BtnWk, qryHlp_Kal2_Alle.BtnTg, [_tblFarben].FarbNrHint, [_tblFarben].FarbNrText"
'    recsetSQL3 = recsetSQL3 & " FROM qryHlp_Kal2_Alle INNER JOIN ((tblTerminEinzelTag INNER JOIN tblTerminTyp"
'    recsetSQL3 = recsetSQL3 & " ON tblTerminEinzelTag.TerminTypID = tblTerminTyp.ID) INNER JOIN _tblFarben ON tblTerminTyp.FarbNr = [_tblFarben].FarbID)"
'    recsetSQL3 = recsetSQL3 & " ON qryHlp_Kal2_Alle.dtDatum = tblTerminEinzelTag.TerminDatum"
'    recsetSQL3 = recsetSQL3 & " WHERE (((tblTerminEinzelTag.TerminMonat)= " & iMon & ") "
'    recsetSQL3 = recsetSQL3 & " AND ((tblTerminEinzelTag.TerminJahr)= " & iJahr & " )"
'    If istNurEigene = True Then
'        recsetSQL3 = recsetSQL3 & " AND ((tblTerminEinzelTag.TerminPerson)=atcnames(1))"
'    End If
'    recsetSQL3 = recsetSQL3 & " AND ((tblTerminEinzelTag.TerminTypID)= " & TerminTypID & "));"
'
'    ArrFill_DAO_OK3 = ArrFill_DAO(recsetSQL3, iZLMax3, iColMax3, DAOARRAY3)
'
'    If ArrFill_DAO_OK3 Then
'        For iZl3 = 0 To iZLMax3
'
'            strFldName = DAOARRAY3(7, iZl3)
'            frm("frm_Kal_" & iMon).Form!(strFldName).BackColor = DAOARRAY3(8, iZl3)
'            frm("frm_Kal_" & iMon).Form!(strFldName).ForeColor = DAOARRAY3(9, iZl3)
'
'        Next iZl3
'    End If

Next iMon

End Function


Function Ferien_Set(Werkid As String)

    Dim BundID As String
    Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, DAOARRAY_Name1, iZl As Long, iCol As Long
    Dim sqlStr As String
    Dim iJ As Long, i As Long
    Dim idtvon As Long
    Dim idtbis As Long

sqlStr = ""
sqlStr = sqlStr & "UPDATE _tblAlleTage SET [_tblAlleTage].FBW = 0, [_tblAlleTage].FBY = 0, [_tblAlleTage].FBE = 0, [_tblAlleTage].FBB = 0, [_tblAlleTage].FHB = 0,"
sqlStr = sqlStr & " [_tblAlleTage].FHH = 0, [_tblAlleTage].FHE = 0, [_tblAlleTage].FMV = 0, [_tblAlleTage].FNI = 0, [_tblAlleTage].FNW = 0,"
sqlStr = sqlStr & " [_tblAlleTage].FRP = 0, [_tblAlleTage].FSL = 0, [_tblAlleTage].FSN = 0, [_tblAlleTage].FST = 0, [_tblAlleTage].FSH = 0, [_tblAlleTage].FTH = 0"
sqlStr = sqlStr & " WHERE ([_tblAlleTage].Werkname ='" & Werkid & "');"
CurrentDb.Execute (sqlStr)

    'recsetSQL1 = "SELECT * FROM qry_Ferien_Meta_Kurz WHERE JahrNr = " & I & ";"
    'ArrFill_DAO_OK1 = ArrFill_DAO(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1, DAOARRAY_Name1)
    ''Info:   'AccessArray(iSpalte,iZeile) <0, 0>       'ExcelArray(iZeile, iSpalte) <1, 1>

    recsetSQL1 = "SELECT * FROM qry_Ferien_Meta_Kurz;"
    ArrFill_DAO_OK1 = ArrFill_DAO(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
    
    If ArrFill_DAO_OK1 Then
        For iZl = 0 To iZLMax1
            BundID = "F" & DAOARRAY1(0, iZl)
            i = Year(DAOARRAY1(1, iZl))
            iJ = Year(DAOARRAY1(2, iZl))
            idtvon = Format(DAOARRAY1(1, iZl), "y", 2, 2)
            idtbis = Format(DAOARRAY1(2, iZl), "y", 2, 2)
            
            sqlStr = ""
            sqlStr = sqlStr & "UPDATE _tblAlleTage SET [_tblAlleTage]." & BundID & " = True"
            sqlStr = sqlStr & " WHERE ([dtdatum] >= (dateserial(" & i & ",1," & idtvon & ")) AND ([dtdatum] <= dateserial(" & iJ & ",1," & idtbis & ")) AND ([_tblAlleTage].Werkname = '" & Werkid & "'));"
            
            CurrentDb.Execute (sqlStr)
        Next iZl
    End If


End Function


Function Einfachkl()
'MsgBox Application.Screen.ActiveForm.ActiveControl.Form.ActiveControl.Name
MsgBox Application.Screen.ActiveForm.ActiveControl.Name
End Function


Public Function Kal_Doppelklick(ibtn As Long)
Dim ctlname As String
Dim SubformName As String
Dim MainForm As Form
Dim subForm As Form
Dim Subform1 As control
Dim x As control
Dim Mainformname As String
Dim iJahr As Long
Dim iMonat As Long
Dim iWoche As Long
Dim iWochentag As Long
Dim j As Long
Dim k As Long
Dim st As String
Dim st1 As String

'w1w 1 woche   110 - 160
's1w 1 Summe   210 - 260
'btn1Tg wt     11 - 67     w = Woche t = Wochentag

k = 0
st = ibtn
st1 = ibtn
j = Len(st)
If j = 3 Then
    k = Left(st, 1)
    st1 = Mid(st, 2, 1)
End If

Select Case k
    Case 2
        's1w 1 -    Summe   210 - 260
        ctlname = "s1w" & st1
    
    Case 1
        'w1w 1 -    woche   110 - 160
        ctlname = "w1w" & st1
    
    Case 0
        'btn1Tg wt     11 - 67     w = Woche t = Wochentag
        ctlname = "btn1Tg" & st1
    Case Else
    
End Select

'Set x = Application.Screen.ActiveForm.ActiveControl
'ctlname = x.Name
Set MainForm = Application.Screen.ActiveForm
Mainformname = MainForm.Name

Set Subform1 = Application.Screen.ActiveForm.ActiveControl
SubformName = Subform1.Name
'Application.Screen.ActiveForm.ActiveControl.Form.ActiveControl.SetFocus
'Set x = Application.Screen.ActiveForm.ActiveControl.Form.ActiveControl
'ctlname = x.Name

Set x = Application.Screen.ActiveForm.ActiveControl.Form(ctlname)

Dim zwwert As String
Dim zwwert2 As String
Dim zw2 As Long
Dim zw3 As Double

zw2 = 0
zwwert = x.caption
j = InStr(zwwert, vbNewLine)
If j > 0 Then
    zw2 = Left(zwwert, j - 1)
    zwwert2 = Mid(zwwert, j + 1)
    If Len(Trim(Nz(zwwert2))) > 0 Then
        zw3 = zwwert2
    End If
Else
    If Len(Trim(Nz(zwwert))) > 0 Then
        zw2 = CLng(Nz(zwwert, 0))
    Else
        zw2 = 0
    End If
End If

''
' Dim myControl As Control
' Dim myTarget As Control
'
' Set myControl = Screen.ActiveForm.ActiveControl
'
'If myControl.ControlType = acSubform Then
''If TypeName(myControl) = "SubForm" Then
'    Set myTarget = myControl.Form.ActiveControl
'Else
'    Set myTarget = myControl
'End If
'
'ctlname = myTarget.Name
'
'Debug.Print "-------"
'Debug.Print Mainformname
'Debug.Print SubformName
'Debug.Print Application.Screen.ActiveForm.ActiveControl.Form.Name
'Debug.Print ctlname
'Debug.Print zw2
'Debug.Print zw3
'Debug.Print "-------"
'
'
'Stop
Dim xx As String

If Left(ctlname, 3) = "btn" Then
    xx = " Tag " & zw2 & " Wert " & zw3
Else
    xx = ""
End If

MsgBox "Doppelklick ct: " & ctlname & " - Jahr " & MainForm(SubformName).Form!iJahr & " - Monat " & MainForm(SubformName).Form!iMon & xx

End Function

Private Function ArrFill_DAO(ByVal recsetSQL As String, ByRef iZLMax As Long, ByRef iColMax As Long, ByRef DAOARRAY) As Boolean

Dim db As DAO.Database
Dim rst As DAO.Recordset
Dim i As Long

'Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl as long, iCol as long
'recsetSQL1 = ""
'ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1,iZLMax1,iColMax1,DAOARRAY1)
''Info:   'AccessArray(iSpalte,iZeile) <0, 0>

ArrFill_DAO = False

    Set db = CurrentDb
    Set rst = db.OpenRecordset(recsetSQL)
    If rst.RecordCount <> 0 Then
        rst.MoveLast
        i = rst.RecordCount
        rst.MoveFirst
        DAOARRAY = rst.GetRows(i)

    'Achtung Zeile und Spalte 0-basiert
    'RowArray(iFldNr,iRecNr)
    'RowArray(iSpalte,iZeile)
        iZLMax = UBound(DAOARRAY, 2)
        iColMax = UBound(DAOARRAY, 1)
        ArrFill_DAO = True
    End If
    rst.Close
    Set rst = Nothing

End Function
