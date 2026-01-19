VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_OB_Objekt"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub btn_Back_akt_Pos_List_Click()
DoCmd.OpenForm "frmTop_VA_Akt_Objekt_Kopf"
Form_frmTop_VA_Akt_Objekt_Kopf.Recordset.FindFirst "ID = " & Me.OpenArgs
DoCmd.Close acForm, "frm_Ob_Objekt", acSaveNo
End Sub
Private Sub btnNeuAttach_Click()
Dim iID As Long
Dim iTable As Long
iID = Me!ID
iTable = Me!TabellenNr
Call f_btnNeuAttach(iID, iTable)
Me!sub_ZusatzDateien.Form.Requery
End Sub
Private Sub btnReport_Click()
DoCmd.OpenReport "rpt_OB_Objekt", acViewPreview, , "ID = " & Me!ID
End Sub
Private Sub btnUploadPositionen_Click()
    On Error GoTo ErrHandler
    
    Dim lngObjektID As Long
    lngObjektID = Nz(Me.ID, 0)
    
    If lngObjektID = 0 Then
        MsgBox "Bitte erst ein Objekt auswaehlen!", vbExclamation
        Exit Sub
    End If
    
    ' Import-Dialog aufrufen
    ImportPositionslisteDialog lngObjektID
    
    ' Unterformular aktualisieren
    Me.sub_OB_Objekt_Positionen.Requery
    
    Exit Sub
    
ErrHandler:
    MsgBox "Fehler: " & Err.description, vbCritical
End Sub
Private Sub Form_BeforeInsert(Cancel As Integer)
    On Error Resume Next
    Me!Zeit1_Label = "08:00"
    Me!Zeit2_Label = "12:00"
    Me!Zeit3_Label = "16:00"
    Me!Zeit4_Label = "20:00"
End Sub
Private Sub Form_BeforeUpdate(Cancel As Integer)
   On Error GoTo Form_BeforeUpdate_Error
        Me!Aend_am = Now()
        Me!Aend_von = atCNames(1)
   On Error GoTo 0
   Exit Sub
Form_BeforeUpdate_Error:
    MsgBox "Error " & Err.Number & " (" & Err.description & ") in procedure Form_BeforeUpdate of VBA Dokument Form_frm_OB_Objekt"
End Sub
Private Sub Form_Current()
    On Error Resume Next
    If Not Me!sub_OB_Objekt_Positionen.Form Is Nothing Then
        Me!sub_OB_Objekt_Positionen.Form.Requery
    End If
    
    ' Aktualisiere Zeit-Header im Unterformular
    UpdateZeitHeaderLabels Me
    UpdateSummenAnzeige Me
End Sub
Private Sub Form_Load()
DoCmd.Maximize
Me!Liste_Obj.RowSource = "SELECT tbl_OB_Objekt.ID, tbl_OB_Objekt.Objekt, tbl_OB_Objekt.Ort " & _
                          "FROM tbl_OB_Objekt " & _
                          "ORDER BY tbl_OB_Objekt.Objekt"
End Sub
Private Sub Form_Open(Cancel As Integer)
If Len(Trim(Nz(Me.OpenArgs))) > 0 Then
    Me!btn_Back_akt_Pos_List.Visible = True
Else
    Me!btn_Back_akt_Pos_List.Visible = False
End If
End Sub
Private Sub Liste_Obj_Click()
    If Not IsNull(Me!Liste_Obj) Then
        Me.Recordset.FindFirst "ID = " & Me!Liste_Obj
        Me!sub_OB_Objekt_Positionen.Requery
    End If
End Sub
Private Sub btnMoveUp_Click()
    On Error Resume Next
    Dim subFrm As Form
    Set subFrm = Me!sub_OB_Objekt_Positionen.Form
    If subFrm.Recordset.BOF Or subFrm.Recordset.RecordCount < 2 Then Exit Sub
    Dim currentSort As Long
    Dim currentID As Long
    Dim prevSort As Long
    Dim prevID As Long
    currentSort = Nz(subFrm!Sort, 0)
    currentID = subFrm!ID
    subFrm.Recordset.MovePrevious
    If subFrm.Recordset.BOF Then
        subFrm.Recordset.MoveNext
        Exit Sub
    End If
    prevSort = Nz(subFrm!Sort, 0)
    prevID = subFrm!ID
    DoCmd.SetWarnings False
    CurrentDb.Execute "UPDATE tbl_OB_Objekt_Positionen SET Sort = " & prevSort & " WHERE ID = " & currentID
    CurrentDb.Execute "UPDATE tbl_OB_Objekt_Positionen SET Sort = " & currentSort & " WHERE ID = " & prevID
    DoCmd.SetWarnings True
    subFrm.Requery
    subFrm.Recordset.FindFirst "ID = " & currentID
End Sub
Private Sub btnMoveDown_Click()
    On Error Resume Next
    Dim subFrm As Form
    Set subFrm = Me!sub_OB_Objekt_Positionen.Form
    If subFrm.Recordset.EOF Or subFrm.Recordset.RecordCount < 2 Then Exit Sub
    Dim currentSort As Long
    Dim currentID As Long
    Dim nextSort As Long
    Dim nextID As Long
    currentSort = Nz(subFrm!Sort, 0)
    currentID = subFrm!ID
    subFrm.Recordset.MoveNext
    If subFrm.Recordset.EOF Then
        subFrm.Recordset.MovePrevious
        Exit Sub
    End If
    nextSort = Nz(subFrm!Sort, 0)
    nextID = subFrm!ID
    DoCmd.SetWarnings False
    CurrentDb.Execute "UPDATE tbl_OB_Objekt_Positionen SET Sort = " & nextSort & " WHERE ID = " & currentID
    CurrentDb.Execute "UPDATE tbl_OB_Objekt_Positionen SET Sort = " & currentSort & " WHERE ID = " & nextID
    DoCmd.SetWarnings True
    subFrm.Requery
    subFrm.Recordset.FindFirst "ID = " & currentID
End Sub
Private Sub btnDaBaAus_Click()
    DoCmd.SelectObject acTable, , True
    RunCommand acCmdWindowHide
End Sub
Private Sub btnDaBaEin_Click()
    DoCmd.SelectObject acTable, , True
End Sub
Private Sub btnRibbonAus_Click()
    DoCmd.ShowToolbar "Ribbon", acToolbarNo
End Sub
Private Sub btnRibbonEin_Click()
    DoCmd.ShowToolbar "Ribbon", acToolbarYes
End Sub
Private Sub cmdGeocode_Click()
    GeocodierenObjekt Me
End Sub


Private Sub sub_OB_Objekt_Positionen_Exit(Cancel As Integer)
    ' Aktualisiere Summen wenn Unterformular verlassen wird
    On Error Resume Next
    UpdateSummenAnzeige Me
End Sub


' === NEUE BUTTON-EVENTS ===

Private Sub btnExportExcel_Click()
    On Error Resume Next
    ExportPositionslisteToExcel Nz(Me.ID, 0)
End Sub

Private Sub btnKopierePositionen_Click()
    On Error Resume Next
    KopierePositionenDialog Nz(Me.ID, 0)
    Me.sub_OB_Objekt_Positionen.Requery
End Sub

Private Sub btnVorlageSpeichern_Click()
    On Error Resume Next
    SpeichereAlsVorlage Nz(Me.ID, 0)
End Sub

Private Sub btnVorlageLaden_Click()
    On Error Resume Next
    LadeVorlageDialog Nz(Me.ID, 0)
    Me.sub_OB_Objekt_Positionen.Requery
    UpdateSummenAnzeige Me
End Sub

Private Sub btnZeitLabels_Click()
    On Error Resume Next
    BearbeiteZeitLabels Me
End Sub

Private Sub txtSuche_Change()
    On Error Resume Next
    FilterObjektListe Me, Nz(Me.txtSuche.Text, "")
End Sub
