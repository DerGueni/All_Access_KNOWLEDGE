VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Report_rptObjektkosten_Bild"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub Detailbereich_Format(Cancel As Integer, FormatCount As Integer)
Dim strPath

strPath = ""
DoEvents
strPath = Get_Priv_Property("prp_Uebersichten_JPG_File")

'strPath = Left(CurrentDb.Name, Len(CurrentDb.Name) - Len(Dir(CurrentDb.Name))) & "Temp.bmp"
Sleep 20
Me!Bild0.Picture = strPath
DoEvents

End Sub


Private Sub Report_Open(Cancel As Integer)
DoCmd.OpenForm "_frmHlp_rptClose", , , , , , Me.Name
'DoCmd.Close acForm, "_frmHlp_rptClose", acSaveNo

End Sub

Private Sub Report_Close()
DoCmd.Close acForm, "_frmHlp_rptClose", acSaveNo
End Sub
