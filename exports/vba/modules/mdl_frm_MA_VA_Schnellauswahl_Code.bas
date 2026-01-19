Attribute VB_Name = "mdl_frm_MA_VA_Schnellauswahl_Code"
Public Function cmdListMA_Standard_Click() As Variant
    Dim frm As Form
    Set frm = Screen.ActiveForm
    frm!List_MA.RowSource = "ztbl_MA_Schnellauswahl"
    frm!List_MA.ColumnWidths = "0;0;2835;454;852;852"
    frm!List_MA.Requery
End Function

Public Function cmdListMA_Entfernung_Click() As Variant
    Dim frm As Form
    Dim lngObjektID As Long
    Dim lngVA_ID As Long
    Dim strSQL As String
    Dim db As DAO.Database
    Dim qdf As DAO.QueryDef
    
    Set frm = Screen.ActiveForm
    lngVA_ID = Nz(frm!VA_ID, 0)
    
    If lngVA_ID = 0 Then
        MsgBox "Kein Auftrag ausgewählt!", vbExclamation
        Exit Function
    End If
    
    lngObjektID = Nz(DLookup("Objekt_ID", "tbl_VA_Auftragstamm", "ID=" & lngVA_ID), 0)
    
    If lngObjektID = 0 Then
        MsgBox "Kein Objekt für diesen Auftrag hinterlegt!", vbExclamation
        Exit Function
    End If
    
    Set db = CurrentDb
    
    On Error Resume Next
    db.QueryDefs.Delete "ztmp_Entf_Filter"
    db.QueryDefs.Delete "ztmp_MA_Entfernung"
    On Error GoTo 0
    
    db.CreateQueryDef "ztmp_Entf_Filter", "SELECT MA_ID, Entf_KM FROM tbl_MA_Objekt_Entfernung WHERE Objekt_ID = " & lngObjektID
    
    strSQL = "SELECT S.ID, S.IstSubunternehmer, S.Name, " & _
             "Format(IIf(E.Entf_KM Is Null,999,E.Entf_KM),'0.0') & ' km' AS Std, " & _
             "S.Beginn, S.Ende, S.Grund " & _
             "FROM ztbl_MA_Schnellauswahl AS S LEFT JOIN ztmp_Entf_Filter AS E ON E.MA_ID = S.ID " & _
             "ORDER BY IIf(E.Entf_KM Is Null,999,E.Entf_KM), S.Name"
    
    db.CreateQueryDef "ztmp_MA_Entfernung", strSQL
    
    frm!List_MA.RowSource = "ztmp_MA_Entfernung"
    frm!List_MA.ColumnWidths = "0;0;2835;1417;852;852"
    frm!List_MA.Requery
End Function

