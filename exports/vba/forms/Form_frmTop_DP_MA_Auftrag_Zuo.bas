VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmTop_DP_MA_Auftrag_Zuo"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit


Private Function CharConv(strChar As String) As String
Dim strTmp As String

  strTmp = UCase(Left(strChar, 1))
  Select Case strTmp
    Case "Ä": strTmp = "A"
    Case "Ö": strTmp = "O"
    Case "Ü": strTmp = "U"
    Case "ß": strTmp = "S"
  End Select
  CharConv = strTmp
End Function



Private Sub btn_Auswahl_Zuo_Click()
Dim i As Long
Dim j As Long
i = Nz(Me!LstSchicht.Column(0), 0)

If i > 0 Then
    j = Nz(DMin("ID", "tbl_MA_VA_Zuordnung", "VAStart_ID = " & i & " AND MA_ID = 0"), 0)
    CurrentDb.Execute ("UPDATE tbl_MA_VA_Zuordnung SET tbl_MA_VA_Zuordnung.MA_ID = " & Me!cboMA_ID.Column(0) & " WHERE (((tbl_MA_VA_Zuordnung.ID)= " & j & "));")
    Call fTag_Schicht_Update(Me!LstSchicht.Column(1), Me!LstSchicht.Column(0))
    DoCmd.Close acForm, Me.Name, acSaveNo
    Form_frm_DP_Dienstplan_MA.btnSta
Else
    MsgBox "Bitte Schicht Auswählen"
End If

End Sub

Private Sub ListeAuft_Click()

Dim strSQL As String

'strSQL = ""
'strSQL = strSQL & "SELECT tbl_VA_AnzTage.VA_ID, tbl_VA_AnzTage.ID, tbl_VA_AnzTage.VADatum as Datum, fObjektOrt(Nz([Auftrag]),Nz([tbl_VA_Auftragstamm].[Ort]),Nz([Objekt])) AS ObjOrt, tbl_VA_AnzTage.TVA_Ist as Ist, tbl_VA_AnzTage.TVA_Soll as Soll"
'strSQL = strSQL & " FROM tbl_VA_Auftragstamm INNER JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID"
'strSQL = strSQL & " WHERE (((tbl_VA_AnzTage.VADatum)= " & SQLDatum(dtOdat) & ") AND tbl_VA_AnzTage.TVA_Offen = True);"
'frm!ListeAuft.RowSource = strSQL


strSQL = ""
strSQL = strSQL & "SELECT ID AS VAStart_ID, VADatum_ID, MA_Anzahl AS Soll, MA_Anzahl_Ist As Ist, Format([VA_Start],'hh:nn') AS von, Format([VA_Ende],'hh:nn') AS bis FROM tbl_VA_Start"
strSQL = strSQL & " WHERE VADatum_ID = " & Me!ListeAuft.Column(1) & " And VA_ID = " & Me!ListeAuft.Column(0) & " AND (MA_Anzahl > 0 AND MA_Anzahl_Ist < MA_Anzahl) order by VA_Start"
Me!LstSchicht.RowSource = strSQL

End Sub
