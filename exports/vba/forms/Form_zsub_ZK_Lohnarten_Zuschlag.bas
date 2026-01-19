VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_zsub_ZK_Lohnarten_Zuschlag"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub cbNurZeitraum_AfterUpdate()

    If Me.cbNurZeitraum = True Then
        Me.filter = "DatumBis >= " & datumSQL(Now) & " AND Datumvon <= " & datumSQL(Now)
        Me.Requery
        
    Else
        Me.filter = "(DatumBis >= " & datumSQL(Now) & " AND Datumvon <= " & datumSQL(Now) & ") OR isnull(DatumBis)"
        Me.Requery
        
    End If
    
End Sub

Private Sub Form_Click()

    Me.Parent.zsub_ZK_Lohnarten_Zuschlag_Detail.Form.filter = "ID = " & Me.ID
    
End Sub


Private Sub Form_Current()

On Error Resume Next

    Me.Parent.zsub_ZK_Lohnarten_Zuschlag_Detail.Form.filter = "ID = " & Me.ID
    Me.Parent.zsub_ZK_Lohnarten_Zuschlag_Detail.Form.FilterOn = True
    
End Sub

