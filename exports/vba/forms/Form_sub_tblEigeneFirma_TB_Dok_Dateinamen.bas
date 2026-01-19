VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_tblEigeneFirma_TB_Dok_Dateinamen"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub Docname_DblClick(Cancel As Integer)

Call vorl_DocNeu_Einles

End Sub

Private Sub DocPfad_DblClick(Cancel As Integer)

Call vorl_DocNeu_Einles

End Sub


Function vorl_DocNeu_Einles()

Dim i As Long
Dim strPfad As String

If Right(Me!DocPfad, 1) <> "\" Then Me!DocPfad = Me!DocPfad & "\"

strPfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Me!DocPfad & Me!Docname

Application.FollowHyperlink strPfad
'i = Me!ID
'
'Call WD_template_NonBookmark_Ausles(i, strPfad)
'
'DoEvents
'
'wd_Close_All

End Function
