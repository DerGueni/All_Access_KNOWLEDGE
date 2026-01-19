VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmTop_BereitsVerplant"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub btnAbbruch_Click()
GL_Verpl_Uebername = False
DoCmd.Close acForm, Me.Name, acSaveNo
End Sub

Private Sub btnOK_Click()
GL_Verpl_Uebername = True
DoCmd.Close acForm, Me.Name, acSaveNo
End Sub

Private Sub Form_Timer()

Dim iMA_ID As Long
Dim iVA_Start_ID
Dim strOA As String
Dim i As Long
Dim strSQL1 As String
Dim strSQL2 As String

Me.TimerInterval = 0

If Len(Trim(Nz(Me.OpenArgs))) = 0 Then
    DoCmd.Close acForm, Me.Name, acSaveNo
    Exit Sub
End If

strOA = Me.OpenArgs

i = InStr(1, strOA, ";")
iMA_ID = Left(strOA, i - 1)
iVA_Start_ID = Mid(strOA, i + 1)

Me!cboMitarbeiter = iMA_ID
DoEvents

strSQL1 = "SELECT ID, MA_ID, MVA_Start, MVA_Ende, Grund FROM qry_Echtzeit_MA_VA_Vergleich_Alle WHERE ID = " & iVA_Start_ID & " And MA_ID = " & iMA_ID
'Lst_NAvail
Me!Lst_NAvail.RowSource = strSQL1

strSQL2 = ""
strSQL2 = strSQL2 & "SELECT tbl_VA_Start.ID, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Objekt, tbl_VA_Auftragstamm.Ort, tbl_VA_Start.VADatum, tbl_VA_Start.VA_Start, tbl_VA_Start.VA_Ende"
strSQL2 = strSQL2 & " FROM tbl_VA_Auftragstamm RIGHT JOIN tbl_VA_Start ON tbl_VA_Auftragstamm.ID = tbl_VA_Start.VA_ID"
strSQL2 = strSQL2 & " WHERE (((tbl_VA_Start.ID)= " & iVA_Start_ID & "));"
'Lst_Start
Me!Lst_Start.RowSource = strSQL2

Me.Requery

End Sub
