VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_ZuAbsage"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub Absage_AfterUpdate()
Me!Zusage = Not Me!Absage
End Sub

Private Sub Zusage_AfterUpdate()
Me!Absage = Not Me!Zusage
End Sub
