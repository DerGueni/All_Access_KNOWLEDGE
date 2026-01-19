VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form__frmHlp_Hilfe_Erstellen"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub btnHelp_Click()
DoCmd.OpenForm "frm_Hilfe_Anzeige", acNormal, , "Formularname = '" & Me.Name & "'"

End Sub

Private Sub Form_BeforeUpdate(Cancel As Integer)
On Error GoTo Form_BeforeUpdate_Err

' Erstellt am / von = Standardwert
        
Me!Aend_am = Now()
Me!Aend_von = atCNames(1) ' Siehe bas_Sysinfo / fdlg_sysinfo
        
Form_BeforeUpdate_Exit:
    Exit Sub

Form_BeforeUpdate_Err:
    MsgBox Error$
    Resume Form_BeforeUpdate_Exit
End Sub

Private Sub btnHilfe_Click()
DoCmd.OpenForm "frm_Hilfe_Anzeige", , , "Formularname='" & [Screen].[ActiveForm].[Name] & "'", , acDialog
End Sub


Private Sub btnEnde_Click()
On Error GoTo Err_btnEnde_Click


    DoCmd.Close

Exit_btnEnde_Click:
    Exit Sub

Err_btnEnde_Click:
    MsgBox Err.description
    Resume Exit_btnEnde_Click
    
End Sub

Private Sub cboFldname_AfterUpdate()
Me.filter = ""
Me.FilterOn = False
Me.Recordset.FindFirst "ID = " & Me!cboFldname.Column(0)
End Sub
