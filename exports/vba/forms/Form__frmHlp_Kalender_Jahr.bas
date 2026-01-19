VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form__frmHlp_Kalender_Jahr"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit


Public Function Kal_refresh()
Call btnBerechnen_Click
End Function


Private Sub btnBerechnen_Click()
Dim MainForm As Form

Me.SetFocus
Set MainForm = Screen.ActiveForm
'Debug.Print MainForm.Name

Me!lbl_Jahr.caption = Me!iJahr
Call Form_Load_Year_Monat(MainForm, Me!cboBundesland, Me!iJahr, Me!JN_IstFerien)

End Sub

Private Sub btnFeierNeu_Click()
DoCmd.OpenForm "frm_Kalender_Frei", , , , , acDialog
End Sub

Private Sub btnHelp_Click()
DoCmd.OpenForm "frm_Hilfe_Anzeige", acNormal, , "Formularname = '" & Me.Name & "'"

End Sub

Private Sub btnNextYear_Click()
Me!iJahr = Me!iJahr + 1
btnBerechnen_Click
End Sub

Private Sub btnPrevYear_Click()
Me!iJahr = Me!iJahr - 1
btnBerechnen_Click
End Sub

Private Sub cboBundesland_AfterUpdate()
Call Set_Priv_Property("Default_Bundesland", Me!cboBundesland)
Call create_Default_AlleTage(Me!cboBundesland)
btnBerechnen_Click
End Sub


Private Sub Form_Open(Cancel As Integer)

Dim strJahr As String, i As Long
Dim x As String

strJahr = ""
For i = Year(Date) To Year(Date) + 6
    strJahr = strJahr & i & "; "
Next i
strJahr = Left(strJahr, Len(strJahr) - 2)
Me!iJahr.RowSource = strJahr

x = Trim(Nz(Get_Priv_Property("Default_Bundesland")))
If Len(x) = 0 Then
    Call Set_Priv_Property("Default_Bundesland", "BY")
    x = "BY"
End If
Me!cboBundesland.defaultValue = Chr(34) & x & Chr(34)

btnBerechnen_Click

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
