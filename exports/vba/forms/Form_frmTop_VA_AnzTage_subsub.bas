VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmTop_VA_AnzTage_subsub"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub Form_AfterDelConfirm(Status As Integer)

'Alle Formulare aktualisieren
'Dazu alle Formulare merken und schliessen
Dim iVA_ID As Long, iVADatum_ID As Long
Dim frm As Form, countfrm As Integer, i As Long, nix, dt As Date

iVA_ID = Me.Parent!VA_ID
iVADatum_ID = Me.Parent!VADatum_ID

countfrm = Forms.Count
If countfrm > 0 Then
    ReDim merkform(countfrm) As String
    For i = 0 To countfrm - 1
        Set frm = Forms(i)
        If Not (frm.Name = "frmTop_VA_AnzTage_sub" Or frm.Name = "frmTop_VA_AnzTage_subsub") Then
            merkform(i) = frm.Name
        End If
    Next i
    For i = 0 To countfrm - 1
        If Len(Trim(merkform(i))) > 0 Then
            nix = frmClose(merkform(i))
        End If
    Next i
End If

dt = TMax("VADatum", "tbl_VA_AnzTage", "VA_ID = " & Me!VA_ID)
CurrentDb.Execute ("UPDATE tbl_VA_Auftragstamm SET tbl_VA_Auftragstamm.Dat_VA_Bis = " & SQLDatum(dt) & " WHERE (((tbl_VA_Auftragstamm.ID)= " & Me!VA_ID & "));")
DoEvents
Call CurrentDb.Execute("DELETE tbl_VA_AnzTage.ID, tbl_VA_Start.* FROM tbl_VA_Start LEFT JOIN tbl_VA_AnzTage ON tbl_VA_Start.VADatum_ID = tbl_VA_AnzTage.ID WHERE (((tbl_VA_AnzTage.ID) Is Null));")
DoEvents

'Alle Formulare wieder öffnen
For i = 0 To countfrm - 1
    If Len(Trim(merkform(i))) > 0 Then
        nix = frmOpen(merkform(i), vbNormal)
    End If
Next i


DoCmd.OpenForm ("frm_VA_Auftragstamm")
'Call Form_frm_VA_Auftragstamm.req_rq(iVA_ID, iVADatum_ID)


    Debug.Print "AfterDelConfirm"
    Debug.Print Status
    
    
End Sub





Private Sub Form_AfterUpdate()
 Debug.Print "AfterUpdate"
End Sub

Private Sub Form_BeforeDelConfirm(Cancel As Integer, response As Integer)
    Debug.Print "Form_BeforeDelConfirm"
    Debug.Print response
    DoCmd.SetWarnings False
End Sub

Private Sub Form_DataChange(ByVal Reason As Long)
    Debug.Print "DataChange"
End Sub

Private Sub Form_DataSetChange()
    Debug.Print "DataSetChange"
End Sub

Private Sub Form_Delete(Cancel As Integer)
    Debug.Print "delete"
End Sub

Private Sub Form_Dirty(Cancel As Integer)
    Debug.Print "Dirty"
End Sub

