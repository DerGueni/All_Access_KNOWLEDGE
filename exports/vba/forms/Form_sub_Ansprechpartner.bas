VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_Ansprechpartner"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Dim g_adr_ID As Long
Dim g_Name As String

Private Sub adr_Nachname_DblClick(Cancel As Integer)
If Len(Trim(Nz(Me!adr_ID))) > 0 Then
    DoCmd.OpenForm "frmStamm_KD_Ansprech", , , "adr_ID = " & Me!adr_ID, acFormEdit
Else
    MsgBox "Bitte den Namen zuerst in dieser Maske anlegen, Doppelklick nur für bestehende"
End If
End Sub

Private Sub adr_Nachname_AfterUpdate()
AdrUpd
AnrUpd
End Sub

Private Sub adr_Vorname_AfterUpdate()
AdrUpd
AnrUpd
End Sub

Private Sub adr_AnredeID_AfterUpdate()
AdrUpd
AnrUpd
End Sub


Private Sub adr_P_LKZ_AfterUpdate()
AdrUpd
End Sub

Private Sub adr_P_Ort_AfterUpdate()
AdrUpd
End Sub

Private Sub adr_P_PLZ_AfterUpdate()
AdrUpd
End Sub

Private Sub adr_P_Str_AfterUpdate()
AdrUpd
End Sub


Private Function AnrUpd()
    Me!adr_Name1 = Me!adr_AnredeID.Column(1) & " " & Trim(Trim(Nz(Me!adr_akad_Grad)) & " " & Trim(Nz(Me!adr_Vorname)) & " " & Trim(Nz(Me!adr_Nachname)))
    Me!adr_Anschreiben = Me!adr_AnredeID.Column(2) & Trim(Trim(Nz(Me!adr_akad_Grad)) & " " & Trim(Nz(Me!adr_Nachname)))
End Function

Private Function AdrUpd()

Dim strAdr As String
Dim strAnspr As String

If Me!adr_P_ans_manuell = False And Me.Dirty Then
    strAdr = Me!adr_Name1 & vbNewLine & Me!adr_P_Str & vbNewLine & vbNewLine
    If Len(Trim(Nz(Me!adr_P_LKZ))) = 0 Or Me!adr_P_LKZ = "D" Then
        strAdr = strAdr & Me!adr_P_PLZ & " " & Me!adr_P_Ort
    Else
        strAdr = strAdr & Me!adr_P_PLZ & " " & Me!adr_P_Ort & vbNewLine & Me!adr_P_LKZ.Column(1)
    End If
    Me!adr_P_Anschrift = strAdr
End If

End Function

Private Sub Form_AfterUpdate()
Dim db As DAO.Database
Dim rs As DAO.Recordset
Dim qdf As DAO.QueryDef

Set db = CurrentDb
Set qdf = db.QueryDefs("qryUpd_Anrede")
qdf.Parameters!Adress_ID = Me!adr_ID
qdf.Execute
DoEvents
'Me.Requery
End Sub

Private Sub Form_BeforeDelConfirm(Cancel As Integer, response As Integer)
Dim i As Long
If vbYes = MsgBox("Ansprechpartner incl. Verknüpfung löschen ?" & vbNewLine & "(bei 'Abbruch' wird nur die Verknüpfung gelöscht)", vbQuestion + vbYesNo + vbDefaultButton1, g_Name & " löschen") Then
    CurrentDb.Execute ("Delete * FROM tbl_KD_Ansprechpartner WHERE adr_ID = " & g_adr_ID)
End If
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

Private Sub Form_Current()
If Not IsNull(Me!adr_ID) Then
    g_adr_ID = Me!adr_ID
    g_Name = Me!adr_Nachname & ", " & Me!adr_Vorname
End If
End Sub
