VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmTop_Login"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub btnLogin_Click()
    Call Set_Priv_Property("prp_Loginname", Me!cboLogin)
    DoEvents
    If isFormLoad("frm_UE_Uebersicht") Then
        Form_frm_UE_Uebersicht.Load_Loginname
    End If
    DoCmd.Close acForm, Me.Name, acSaveNo
End Sub

Private Sub Form_Open(Cancel As Integer)
    Dim strLogin As String
    Dim bImmer As Boolean
    Me!cboLogin.defaultValue = Chr$(34) & atCNames1(1) & Chr$(34)
    Me!cboLogin = atCNames1(1)
End Sub
