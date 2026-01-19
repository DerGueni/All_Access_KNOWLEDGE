VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_VA_Akt_Objekt_Pos"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub Anzahl_Exit(Cancel As Integer)

On Error Resume Next
Dim strSuch As String
Dim i As Long
Dim j As Long

DoCmd.RunCommand acCmdSaveRecord
DoEvents

i = Me!VA_Akt_Objekt_Kopf_ID
strSuch = "VA_Akt_Objekt_Kopf_ID = " & i
j = Nz(TSum("Anzahl", "tbl_VA_Akt_Objekt_Pos", strSuch), 0)
DoEvents

Forms!frmTop_VA_Akt_Objekt_Kopf!AnzMA_Obj = j
DoEvents

End Sub
