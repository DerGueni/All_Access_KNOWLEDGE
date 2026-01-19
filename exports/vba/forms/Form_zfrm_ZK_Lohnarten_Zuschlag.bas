VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_zfrm_ZK_Lohnarten_Zuschlag"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database

Private Sub Form_Load()
    
    Me.zsub_ZK_Lohnarten_Zuschlag.Form.cbNurZeitraum = True

    'Me.zsub_ZK_Lohnarten_Zuschlag.Form.filter = "(DatumBis >= " & DatumSQL(Now) & " AND Datumvon <= " & DatumSQL(Now) & ") OR isnull(DatumBis)"
    Me.zsub_ZK_Lohnarten_Zuschlag.Form.filter = "DatumBis >= " & datumSQL(Now) & " AND Datumvon <= " & datumSQL(Now)
    Me.zsub_ZK_Lohnarten_Zuschlag.Form.FilterOn = True
    
End Sub
