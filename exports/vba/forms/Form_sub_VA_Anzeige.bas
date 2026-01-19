VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_VA_Anzeige"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub btnAnz1_Click()
f_Status_Klick 1
End Sub
Private Sub btnAnz2_Click()
f_Status_Klick 2
End Sub
Private Sub btnAnz3_Click()
f_Status_Klick 3
End Sub
Private Sub btnAnz4_Click()
f_Status_Klick 4
End Sub

Public Function f_UpdStatus()
Form_Open False
End Function

Private Sub Form_Open(Cancel As Integer)

    Me!AnzStatus1 = TCount("*", "tbl_VA_Auftragstamm", "Veranst_Status_ID = 1")
    Me!AnzStatus2 = TCount("*", "tbl_VA_Auftragstamm", "Veranst_Status_ID = 2")
    Me!AnzStatus3 = TCount("*", "tbl_VA_Auftragstamm", "Veranst_Status_ID = 3")
    Me!AnzStatus4 = TCount("*", "tbl_VA_Auftragstamm", "Veranst_Status_ID = 4")
    
End Sub


Function f_Status_Klick(i As Long)
Me.Parent!Auftraege_ab = DateSerial(2000, 1, 1)
Me.Parent!IstStatus = i
DoEvents
Form_frm_VA_Auftragstamm.f_AbWann
End Function
