VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_MA_Dienstkleidung"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub Dienstkleidung_ID_AfterUpdate()
Me!Kautionsbetrag = Me!Dienstkleidung_ID.Column(1)
End Sub


Private Sub Dienstkleidung_ID_DblClick(Cancel As Integer)
DoCmd.OpenForm "frmTop_MA_Dienstkleidung_Vorlage"
End Sub

Private Sub Form_BeforeUpdate(Cancel As Integer)
On Error Resume Next

        ' Erstellt am / von = Standardwert

        Me!Aend_am = Now()
        Me!Aend_von = atCNames(1) ' Siehe bas_Sysinfo / fdlg_sysinfo


End Sub
