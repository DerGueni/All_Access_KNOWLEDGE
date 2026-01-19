VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_Rch_Pos_Auftrag"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub EzPreis_AfterUpdate()
Me!GesPreis = Me!Menge * Me!EZPreis
End Sub

Private Sub Form_AfterUpdate()
'Me!pgPos.Requery

End Sub

Private Sub Menge_AfterUpdate()
Me!GesPreis = Me!Menge * Me!EZPreis
End Sub
