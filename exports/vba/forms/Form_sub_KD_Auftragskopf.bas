VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_KD_Auftragskopf"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

' WARUM AUCH IMMER SPRINGT DER HIER REIN VOM KUNDENSTAMM ??? --> Prüfen!
Private Sub Form_Current()
'Dim s1 As String
'Dim s2 As String
'Dim s3 As String
'Dim pf As String
'Dim i As Long
'Dim iVA_ID
'
'On Error Resume Next
'Me.Parent!sub_KD_Rch_Auftragspos.Form.RecordSource = "SELECT * FROM qry_Rch_Pos_Auftrag WHERE VA_ID = " & Me!VA_ID
'DoEvents
'
'Me.Parent!PosGesamtsumme = Nz(TSum("GesPreis", "tbl_Rch_Pos_Auftrag", "VA_ID = " & Me!VA_ID), 0)
'DoEvents
'
's1 = Me!Dateiname
'iVA_ID = Me!VA_ID
'i = InStrRev(s1, "\")
'pf = Left(s1, i)
's2 = pf & "Stundenliste_Rch_" & iVA_ID & ".pdf"
's3 = pf & "Einsatz_Alle_" & iVA_ID & ".pdf"
'
'If Not File_exist(s3) Then
'    i = Get_Priv_Property("prp_Report1_Auftrag_IstTage")
'    Call Set_Priv_Property("prp_Report1_Auftrag_IstTage", -1)
'    Call Set_Priv_Property("prp_Report1_Auftrag_ID", iVA_ID)
'    'Call Set_Priv_Property("prp_Report1_Auftrag_VADatum_ID", Me!cboVADatum)
'
'    DoCmd.OutputTo acOutputReport, "rpt_Auftrag_Zusage", "PDF", s3
'    DoEvents
'    Sleep 200
'    DoEvents
'
'    Call Set_Priv_Property("prp_Report1_Auftrag_IstTage", i)
'End If
'
'Call Set_Priv_Property("prp_kun_rch_pdf_s1", s1)
'Call Set_Priv_Property("prp_kun_rch_pdf_s2", s2)
'Call Set_Priv_Property("prp_kun_rch_pdf_s3", s3)
'
''Me.Parent!btnAufRchPDF.Visible = True
''Me.Parent!btnAufRchPosPDF.Visible = True
''Me.Parent!btnAufEinsPDF.Visible = True
   
End Sub

