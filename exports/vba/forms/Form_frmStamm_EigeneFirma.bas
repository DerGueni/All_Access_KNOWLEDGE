VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmStamm_EigeneFirma"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Dim sfirst As String

Private Sub cboAufArt_AfterUpdate()
Dim strSQL As String
If Me!cboAufArt = -1 Then
    strSQL = "SELECT * FROM _tblEigeneFirma_Word_ReBlock;"
Else
    strSQL = "SELECT * FROM _tblEigeneFirma_Word_ReBlock WHERE IDVorlage = " & Me!cboAufArt & ";"
End If
Me!sub_EigeneFirma_Word_ReBlock.Form.recordSource = strSQL
End Sub

Private Sub Befehl374_Click()
DoCmd.OpenForm "frmTop_Neue_Vorlagen"
End Sub

Private Sub Form_Open(Cancel As Integer)
Me!lbl_Datum.caption = Date
Me!StartPfad = Get_Priv_Property("prp_CONSYS_GrundPfad")
End Sub


Private Sub Form_BeforeUpdate(Cancel As Integer)

On Error GoTo Form_BeforeUpdate_Err

If Me.Dirty Then
    If Not vbYes = MsgBox("Datensatz speichern, sind Sie sicher", vbQuestion + vbYesNo) Then
        Cancel = True
        DoCmd.RunCommand acCmdUndo
        Exit Sub
    End If

' Erstellt am / von = Standardwert
        
    Me!Aend_am = Now()
    Me!Aend_von = atCNames(1) ' Siehe bas_Sysinfo / fdlg_sysinfo
End If

Form_BeforeUpdate_Exit:
    Exit Sub

Form_BeforeUpdate_Err:
    MsgBox Error$
    Resume Form_BeforeUpdate_Exit

End Sub

Private Sub Fa_LKZ_AfterUpdate()
Me!Fa_land_vorwahl = Me!Fa_LKZ.Column(3)
End Sub

Private Sub RegStammEigFirma_Change()

Dim strSQL As String
Dim i As Long
Dim rst As DAO.Recordset
Dim strCriteria As String
Dim j As Long

i = Me!RegStammEigFirma
Select Case Me!RegStammEigFirma.Pages(i).Name
  

  Case "pgBemerk"
  
      Me!Fa_memo.SetFocus
      Me!Fa_memo.SelStart = Len("" & Me!Fa_memo)
  
  Case Else
  
End Select

End Sub
