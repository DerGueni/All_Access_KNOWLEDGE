VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmTop_VA_AnzTage_sub"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit


Private Sub Form_AfterUpdate()
Dim lngStore As Long

 lngStore = Me!ID

 'Bildschirmflackern reduzieren
 Me.Painting = False

 Me.Requery
 Me.Recordset.FindFirst "Id = " & lngStore

 Me.Painting = True
 
End Sub


Private Sub Form_Close()
Dim ID As Long

If isFormLoad("frm_VA_Auftragstamm") Then
    Call Form_frm_VA_Auftragstamm.req_rq(Me!VA_ID, Me!VADatum_ID)
End If
End Sub

