Option Compare Database
Option Explicit

'Me.FrozenColumns
'Me.HorizontalDatasheetGridlineStyle
'Me.RowHeight
'Me.VerticalDatasheetGridlineStyle
'RowHeight = True - Aktuelle Schrifthöhe sonst Zahl in Twips
'Private Const Twips2cm As Long = 567

'DatasheetFontName
'DatasheetFontHeight

'Me.DatasheetAlternateBackColor
'Me.DatasheetBackColor
'Me.DatasheetBorderLineStyle
'Me.DatasheetCellsEffect
'Me.DatasheetColumnHeaderUnderlineStyle
'Me.DatasheetFontHeight
'Me.DatasheetFontItalic
'Me.DatasheetFontName
'Me.DatasheetFontUnderline
'Me.DatasheetFontWeight
'Me.DatasheetForeColor
'Me.DatasheetGridlinesBehavior
'Me.DatasheetGridlinesColor
'Me.AllowDatasheetView

'Me.ColumnOrder
'Me.ColumnHidden
'Me.ColumnWidth

'Me.FitToScreen
'Me.RecordSelectors
'
'######################################################
' Größe der Tabelleanzeige in Datenblattansicht nachträglich ändern
'######################################################

Function ChgDatasheetFont(frmName As String, Optional FontSize As Long = 10, Optional FontName As String = "Arial")
  'Autor Peter Döring
  'Änderungen Klaus Oberdalhoff
  Dim frm As Form

  DoCmd.OpenForm frmName, acDesign
  Set frm = Forms(frmName)
 
  If Len(Trim(Nz(FontName))) > 0 Then
      frm.DatasheetFontName = FontName
  End If
  If FontSize > 0 Then
    frm.DatasheetFontHeight = FontSize
  End If
  DoCmd.Close acForm, frmName, acSaveYes
  Set frm = Nothing
End Function


Function ColumnWidth_Aaend(frmName As String)

  Dim frm As Form
  Dim ctl As control

  Dim i As Long
  Dim j As Long

  DoCmd.OpenForm frmName, acDesign
  Set frm = Forms(frmName)
 
  For Each ctl In frm
  
    If ctl.ControlType = 108 Then ' acTextbox
        ctl.ColumnWidth = ctl.width
    End If
  Next ctl

  DoCmd.Close acForm, frmName, acSaveYes
  Set frm = Nothing

End Function


Function f_UE_Select_Tag()

  Dim frm As Form
  Dim ctl As control
  
  Dim frmName As String

  Dim i As Long
  Dim j As Long

  frmName = "frm_UE_Uebersicht_Monat_Neu"

  DoCmd.OpenForm frmName, acDesign
  Set frm = Forms(frmName)
 
  For i = 1 To 42
    Set ctl = frm.Controls("List_Tag_" & i)
    ctl.RowSource = "SELECT VA_ID, VADatum_ID, VADatum, Obj,IstSoll FROM qry_UE_Month_Daten_Select WHERE WN_KalTag = " & i & " ORDER BY Obj;"
    ctl.ColumnCount = 5
    ctl.ColumnWidths = "0cm;0cm;0cm;4,4cm"
  Next i

  DoCmd.Close acForm, frmName, acSaveYes
  Set frm = Nothing

End Function

Function Ueschr_Aaend(frmName As String)

  Dim frm As Form
  Dim ctl As control

  Dim i As Long
  Dim j As Long

  DoCmd.OpenForm frmName, acDesign
  Set frm = Forms(frmName)
 
  j = 264
  i = 1
  For Each ctl In frm
    If ctl.Name = "Text" & j Then
        ctl.Name = "Tx" & i
        ctl.ControlSource = "=" & Chr$(34) & i & Chr$(34)
        
        i = i + 1
        j = j + 1
    End If
  Next ctl

  DoCmd.Close acForm, frmName, acSaveYes
  Set frm = Nothing

End Function

Function Ueschr_Aaend2(frmName As String)

  Dim frm As Form
  Dim ctl As control

  Dim i As Long
  Dim j As Long

  DoCmd.OpenForm frmName, acDesign
  Set frm = Forms(frmName)
 
'  i = 1
'  For Each ctl In frm
'    If Left(ctl.Name, 2) = "Tx" And ctl.ControlType = 109 Then
''        ctl.ControlSource = ""
'        ctl.ControlType = acLabel
'    End If
''    i = i + 1
'  Next ctl

'  i = 1
'  For Each ctl In frm
'    If ctl.Name = "Tx" & i Then
'        Debug.Print ctl.ControlType & " " & ctl.Name
'        ctl.Caption = i
'        i = i + 1
''        j = j + 1
'    End If
'  Next ctl

  i = 66
  j = 440
  For j = 391 To 413
    Set ctl = frm.Controls("OLEGebunden" & j)
    ctl.Name = i
    ctl.ControlSource = i
    i = i + 1
  Next j

  
  DoCmd.Close acForm, frmName, acSaveYes
  Set frm = Nothing

End Function


Function Ueschr_Aaend3(frmName As String)

  Dim frm As Form
  Dim ctl As control

  Dim i As Long
  Dim j As Long

  DoCmd.OpenForm frmName, acDesign
  Set frm = Forms(frmName)
 
'  i = 1
'  For Each ctl In frm
'    If Left(ctl.Name, 2) = "Tx" And ctl.ControlType = 109 Then
''        ctl.ControlSource = ""
'        ctl.ControlType = acLabel
'    End If
''    i = i + 1
'  Next ctl

'  i = 1
'  For Each ctl In frm
'    If ctl.Name = "Tx" & i Then
'        Debug.Print ctl.ControlType & " " & ctl.Name
'        ctl.Caption = i
'        i = i + 1
''        j = j + 1
'    End If
'  Next ctl

  i = 1
  For Each ctl In frm
'    If Left(ctl.Name, 2) = "Tx" Then
        ctl.Name = "sub_" & i
'        ctl.
        i = i + 1
'        Debug.Print ctl.ControlType & " " & ctl.Name
'        ctl.Caption = i
'        j = j + 1
'    End If
  Next ctl

  
  DoCmd.Close acForm, frmName, acSaveYes
  Set frm = Nothing

End Function


Function Ueschr_Aaend4(frmName As String)

  Dim frm As Form
  Dim ctl As control

  Dim i As Long
  Dim j As Long

  DoCmd.OpenForm frmName, acDesign
  Set frm = Forms(frmName)
 
  For Each ctl In frm
    If Left(ctl.Name, 3) = "Ole" Then
        i = ctl.ControlSource
        ctl.Name = "V" & i
        ctl.ControlSource = "V" & i
'        I = I + 1
'        Debug.Print ctl.ControlType & " " & ctl.Name
'        ctl.Caption = i
'        j = j + 1
    End If
  Next ctl

  
  DoCmd.Close acForm, frmName, acSaveYes
  Set frm = Nothing

End Function


Function ChgSaSoCondition(frmName As String, dwidth As Variant, iMon As Variant, iJahr As Variant)
  'Autor Peter Döring
  'Änderungen Klaus Oberdalhoff
  ' Bedingung: Form enthält 31 Felder: T01 bis T31
  Dim frm As Form
  Dim ctl As control

  Dim i As Long
  Dim j As Long
  Dim k As Long
  Dim L As Long
  Dim dt1 As Date
  Dim dt2 As Date
  Dim dt3 As Date
  Dim fcd As FormatCondition
  
  dt1 = DateSerial(iJahr, iMon, 1)
  dt2 = DateSerial(iJahr, iMon + 1, 0)
  j = Format(dt2, "d", 2, 2)
 
  DoCmd.OpenForm frmName, acDesign
  Set frm = Forms(frmName)
 
  For Each ctl In frm
    If Len(ctl.Name) <= 3 And Left(ctl.Name, 1) = "T" And IsNumeric(Mid(ctl.Name, 2)) Then
        ctl.ColumnHidden = False
        ctl.ColumnWidth = dwidth * 567
        i = Mid(ctl.Name, 2)
        k = Weekday(DateSerial(iJahr, iMon, i), 2)
        
        With ctl.FormatConditions
            .Delete
        
            If k = 6 Then ' Samstag
                L = TLookup("FarbNrHint", "_tblFarben", "FarbID = 7")
                Set fcd = .Add(acExpression, acEqual, "1 = 1")
                fcd.backColor = L
            
            ElseIf k = 7 Then ' Sonntag
                L = TLookup("FarbNrHint", "_tblFarben", "FarbID = 8")
                Set fcd = .Add(acExpression, acEqual, "1 = 1")
                fcd.backColor = L
            End If
        
        End With
        
        If i > j Then ' Monat weniger als 31 Tage
            ctl.ColumnHidden = True
        End If
        
    End If
  Next ctl
 
  DoCmd.Close acForm, frmName, acSaveYes
  Set frm = Nothing
End Function


Function ffixColumns(frmName As String, Optional AnzCol As Variant = 2)

' AnzCol eins größer als fixierte Spalten. AnzCol = 2 bedeutet, eine fixierte Spalte... AnzCol 3 = 2 fixierte Spalten etc.

' frmProjektIdentRisk_Sub

  'Autor Peter Döring
  'Änderungen Klaus Oberdalhoff
  Dim frm As Form
  Dim ctl As control

  DoCmd.OpenForm frmName, acDesign
  Set frm = Forms(frmName)

 frm.FrozenColumns = AnzCol

  DoCmd.Close acForm, frmName, acSaveYes
  Set frm = Nothing

End Function



Function ChgColumnWidth(frmName As String, dwidth As Variant)
  'Autor Peter Döring
  'Änderungen Klaus Oberdalhoff
  Dim frm As Form
  Dim ctl As control

  DoCmd.OpenForm frmName, acDesign
  Set frm = Forms(frmName)
 
  For Each ctl In frm
    If Len(ctl.Name) = 3 And Left(ctl.Name, 1) = "T" Then
        ctl.ColumnWidth = dwidth * 567
    End If
  Next ctl
 
  DoCmd.Close acForm, frmName, acSaveYes
  Set frm = Nothing
End Function


Function ChgDatasheetBackColor(frmName As String, backColor As Long)
  'Autor Peter Döring
  'Änderungen Klaus Oberdalhoff
  Dim frm As Form

  DoCmd.OpenForm frmName, acDesign
  Set frm = Forms(frmName)
 
 ' frm.DatasheetBackColor = BackColor
  frm.DatasheetGridlinesColor = backColor

  DoCmd.Close acForm, frmName, acSaveYes
  Set frm = Nothing
End Function


Function Change_AllDatasheetSizeFont(Optional FontName As String = "Arial", Optional FontSize As Long = 10)

'Benötigt die Abfrage qrymdbForm

Dim db As DAO.Database
Dim rst As DAO.Recordset

Dim frmName As String

Set db = CurrentDb
Set rst = db.OpenRecordset("SELECT * FROM qrymdbForm;")

With rst
    Do While Not .EOF
        frmName = rst.fields(0)
        Call ChgDatasheetFont(frmName, FontSize, FontName)
        DoEvents
        .MoveNext
    Loop
    .Close
End With

Set rst = Nothing

End Function


Function Datasheet_FontSize(frm As Form, fontHightNr As Long)
'Ändern der Datasheet-Größe zur Laufzeit
'Höhe der Datasheet Zeile mittels Fontgröße setzen
'RowHeight = True   - True verwendet die Fontgröße als Datasheet Row Height / Zahl wäre die "echte" RowHight

Const Twips2cm As Long = 567

frm.RowHeight = True
frm.DatasheetFontHeight = fontHightNr

End Function


Function Controlname_Copy(strFormName As String)

Dim strSQL As String

CurrentDb.Execute ("DELETE * FROM _tblSpaltenanzeigeDatenblattansicht WHERE Formularname = '" & strFormName & "';")

strSQL = ""
strSQL = strSQL & "INSERT INTO _tblSpaltenanzeigeDatenblattansicht ( ID, Formularname, Spaltenname, Feldtyp, FeldNr )"
strSQL = strSQL & " SELECT [_tblAlleFormularFelder].ID, [_tblAlleFormularFelder].Formularname, [_tblAlleFormularFelder].Feldname,"
strSQL = strSQL & " [_tblAlleFormularFelder].Feldtyp , [_tblAlleFormularFelder].FeldNr"
strSQL = strSQL & " FROM _tblAlleFormularFelder"
strSQL = strSQL & " WHERE ((([_tblAlleFormularFelder].Formularname)= '" & strFormName & "'));"

CurrentDb.Execute (strSQL)

End Function

Function Controlname_Copy_all()

Dim strSQL As String

CurrentDb.Execute ("DELETE * FROM _tblSpaltenanzeigeDatenblattansicht;")

strSQL = ""
strSQL = strSQL & "INSERT INTO _tblSpaltenanzeigeDatenblattansicht ( ID, Formularname, Spaltenname, Feldtyp, FeldNr )"
strSQL = strSQL & " SELECT [_tblAlleFormularFelder].ID, [_tblAlleFormularFelder].Formularname, [_tblAlleFormularFelder].Feldname,"
strSQL = strSQL & " [_tblAlleFormularFelder].Feldtyp , [_tblAlleFormularFelder].FeldNr"
strSQL = strSQL & " FROM _tblAlleFormularFelder;"

CurrentDb.Execute (strSQL)

End Function



Function Controlname_Fill_All(Optional IsNoLabel As Boolean = True)

Dim db As DAO.Database
Dim rst As DAO.Recordset
Dim rstout As DAO.Recordset

Dim iVgl As Long
Dim i As Long
Dim j As Long
Dim strFormName As String
Dim frm As Form
'Dim ctl As Control
Dim ctl As Object
    
CurrentDb.Execute ("DELETE * FROM _tblAlleFormularFelder;")
    
i = 10
Set db = CurrentDb
Set rst = db.OpenRecordset("SELECT * FROM qrymdbForm ORDER by Name;", dbOpenForwardOnly, dbReadOnly)
Set rstout = db.OpenRecordset("SELECT TOP 1 * FROM _tblAlleFormularFelder;")
With rst
    Do While Not .EOF
        strFormName = .fields(0).Value
        j = 1
        Debug.Print strFormName
        If UCase(Left(strFormName, 3)) = "frm" Then
            DoCmd.OpenForm strFormName, acDesign
            Set frm = Forms(strFormName)
            For Each ctl In frm.Controls
                If Not (ctl.ControlType = 100 And IsNoLabel = True) Then  ' Keine Labels
                    rstout.AddNew
                        rstout.fields(0) = i
                        rstout.fields(1) = strFormName
                        rstout.fields(2) = ctl.Name
                        rstout.fields(3) = ctl.ControlType
                        rstout.fields(4) = j
                    rstout.update
                    i = i + 10
                    j = j + 1
                End If
            Next ctl
            DoCmd.Close acForm, strFormName
        End If
        .MoveNext
    Loop
    .Close
End With
Set rst = Nothing
rstout.Close
Set rstout = Nothing

End Function

Function Controlname_Fill_Single(strFormName As String, Optional IsNoLabel As Boolean = True)

Dim db As DAO.Database
Dim rst As DAO.Recordset
Dim rstout As DAO.Recordset

Dim iVgl As Long
Dim i As Long
Dim j As Long
Dim frm As Form
Dim ctl As control
    
CurrentDb.Execute ("DELETE * FROM _tblAlleFormularFelder WHERE Formularname= '" & strFormName & "';")
i = Nz(TMax("ID", "_tblAlleFormularFelder"), 0) + 10
    
Set db = CurrentDb
Set rstout = db.OpenRecordset("SELECT TOP 1 * FROM _tblAlleFormularFelder;")
        j = 1
        Debug.Print strFormName
        If UCase(Left(strFormName, 3)) = "frm" Then
            DoCmd.OpenForm strFormName, acDesign
            Set frm = Forms(strFormName)
            For Each ctl In frm.Controls
                If Not (ctl.ControlType = 100 And IsNoLabel = True) Then  ' Keine Labels
                    rstout.AddNew
                        rstout.fields(0) = i
                        rstout.fields(1) = strFormName
                        rstout.fields(2) = ctl.Name
                        rstout.fields(3) = ctl.ControlType
                        rstout.fields(4) = j
                    rstout.update
                    i = i + 10
                    j = j + 1
                End If
            Next ctl
            DoCmd.Close acForm, strFormName
        End If
rstout.Close
Set rstout = Nothing

End Function


Function Set_Columns_Datasheet(frm As Form)

Dim DAOARRAY
Dim iColMax As Long
Dim iZLMax As Long
Dim bARRIstOK As Boolean
Dim strFormName As String

Dim iHidden As Long
Dim iOrder As Long
Dim iWidth As Long

Dim i As Long
Dim j As Long

Dim ctl As control
Dim fld As DAO.field


strFormName = frm.Name


Dim strSQL As String

strSQL = "SELECT * FROM _tblSpaltenanzeigeDatenblattansicht WHERE Formularname = '" & strFormName & "' ORDER BY ID;"

bARRIstOK = ArrFill_DAO(strSQL, iZLMax, iColMax, DAOARRAY)
    'Achtung Zeile und Spalte 0-basiert
    'RowArray(iFldNr,iRecNr)
    'RowArray(iSpalte,iZeile)

If bARRIstOK = True Then
    For i = 0 To iZLMax
        If Len(Trim(Nz(DAOARRAY(2, i)))) > 0 Then   ' Controlname ausgefüllt
            
            iHidden = -1
            iOrder = 0
            iWidth = 0


            Set ctl = frm.Controls(DAOARRAY(2, i))
            
            
            'Set fld = dbs.TableDefs!Products.Fields!ProductID
            Set fld = frm.Recordset.fields(ctl.Name)

            If DAOARRAY(5, i) = -1 Then  ' Control Hidden
                iHidden = -1
                iWidth = 0
                iOrder = 0
            Else
                iHidden = 0
                iWidth = DAOARRAY(6, i)
            End If

            If DAOARRAY(7, i) > 0 And DAOARRAY(5, i) <> -1 Then  ' Control Reihenfolge
                iOrder = DAOARRAY(7, i)
            End If
            
'
'            If iHidden = 0 Then
'                SetFieldProperty fld, "ColumnHidden", dbLong, iHidden
'                SetFieldProperty fld, "ColumnWidth", dbLong, iWidth
'                SetFieldProperty fld, "ColumnOrder", dbLong, iOrder
'            Else
'                SetFieldProperty fld, "ColumnHidden", dbLong, iHidden
'            End If
'            Debug.Print fld.Name, " - " & fld.Properties("ColumnHidden"), fld.Properties("ColumnWidth"), fld.Properties("ColumnOrder")
        
            If iHidden = 0 Then
                ctl.ColumnHidden = False
                ctl.ColumnWidth = iWidth
                ctl.ColumnOrder = iOrder
            Else
                ctl.ColumnHidden = True
            End If

        
        ElseIf DAOARRAY(8, i) > 1 Then  ' Formular: Anzahl fixierte Spalten > 1 (2 = 1 Spalte fixiert, 3 = 2 Spalten fixiert ...)
            frm.FrozenColumns = DAOARRAY(8, i)
             
        ElseIf DAOARRAY(9, i) <> -1 Then  ' Formular: Spaltenhöhe ungleich -1 ( -1 = Standard)
            frm.RowHeight = DAOARRAY(9, i)

        End If
    Next i
End If

End Function



Private Sub SetFieldProperty(ByRef fld As DAO.field, _
                             ByVal strPropertyName As String, _
                             ByVal intPropertyType As Integer, _
                             ByVal varPropertyValue As Variant)
    ' Set field property without producing nonrecoverable run-time error.

    Const conErrPropertyNotFound = 3270
    Dim prp As Property
    
    ' Turn off error handling.
    On Error Resume Next
    
    fld.Properties(strPropertyName) = varPropertyValue
    
    ' Check for errors in setting the property.
    If err <> 0 Then
        If err <> conErrPropertyNotFound Then
            On Error GoTo 0
            MsgBox "Couldn't set property '" & strPropertyName & _
                   "' on field '" & fld.Name & "'", vbCritical
        Else
            On Error GoTo 0
            Set prp = fld.CreateProperty(strPropertyName, intPropertyType, _
                      varPropertyValue)
            fld.Properties.append prp
        End If
    End If
    
    Set prp = Nothing
    
End Sub


Function cttest1(Optional strFormName As String = "frmSubPlanEA_SpezWeek")

Dim i As Long
Dim Anz As Long
Dim c As control

On Error Resume Next

Anz = Forms(strFormName).Controls.Count ' liefert die Anzahl Steuerelemente im Formular
If Anz <= 0 Then Exit Function ' keine Steuerelemente da
For i = 0 To Anz - 1
    Set c = Forms(strFormName).Controls(i)
        If c.ControlType = 109 Or c.ControlType = 111 Then
            Debug.Print c.ControlType, c.Name
            Debug.Print
            Debug.Print "ColumnHidden   - " & c.Properties("ColumnHidden")
            Debug.Print "ColumnWidth   - " & c.Properties("ColumnWidth")
            Debug.Print "ColumnOrder   - " & c.Properties("ColumnOrder")
            Debug.Print "======================================="
        End If
Next i


End Function