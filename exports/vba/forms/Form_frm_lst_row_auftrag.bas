VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_lst_row_auftrag"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit


Sub aktualisieren()
    
On Error Resume Next

    Me.Parent.sub_MA_VA_Zuordnung.Form.Painting = False
    Me.Parent.lstRowAuftrag_Click Me.tbl_VA_Auftragstamm_ID, Me.tbl_VA_AnzTage_ID
    Me.Parent.sub_MA_VA_Zuordnung.SetFocus
    Me.Parent.sub_MA_VA_Zuordnung.Form.Painting = True
    
    
    'Check Fussball und 34a
    If Me.Parent.Form.Controls("veranstalter_id") = 20771 Or Me.Parent.Form.Controls("veranstalter_id") = 20737 Then
        Me.Parent.sub_MA_VA_Zuordnung.Form.Painting = False
        Me.Parent.sub_MA_VA_Zuordnung.Form.Recordset.MoveFirst
        Do
            Call Me.Parent.sub_MA_VA_Zuordnung.Form.check_34a_fussball
            Me.Parent.sub_MA_VA_Zuordnung.Form.Recordset.MoveNext
        Loop While Not Me.Parent.sub_MA_VA_Zuordnung.Form.Recordset.EOF

        Me.Parent.sub_MA_VA_Zuordnung.Form.Recordset.MoveFirst
        Me.Parent.sub_MA_VA_Zuordnung.Form.Painting = True
        
    End If
  
    
End Sub


Private Sub Auftrag_Click()
    DoCmd.RunCommand acCmdSelectRecord
    Call aktualisieren
End Sub

Private Sub Datum_Click()
    DoCmd.RunCommand acCmdSelectRecord
    Call aktualisieren
End Sub

Private Sub Ist_Click()
    DoCmd.RunCommand acCmdSelectRecord
    Call aktualisieren
End Sub

Private Sub Objekt_Click()
    DoCmd.RunCommand acCmdSelectRecord
    Call aktualisieren
End Sub

Private Sub Ort_Click()
    DoCmd.RunCommand acCmdSelectRecord
    Call aktualisieren
End Sub

Private Sub Soll_Click()
    DoCmd.RunCommand acCmdSelectRecord
    Call aktualisieren
End Sub

Private Sub Text29_Click()
    DoCmd.RunCommand acCmdSelectRecord
    Call aktualisieren
End Sub
