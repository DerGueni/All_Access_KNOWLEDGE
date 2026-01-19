VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_tbl_MA_VA_Planung"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub Form_BeforeUpdate(Cancel As Integer)

On Error Resume Next

        ' Erstellt am / von = Standardwert

        Me!Aend_am = Now()
        Me!Aend_von = atCNames(1) ' Siehe bas_Sysinfo / fdlg_sysinfo

End Sub

Private Sub Status_ID_AfterUpdate()

Dim iZuo As Long
Dim snetto As Single
Dim iPosNr As Long

Dim strSQL As String

If Me!Status_ID = 3 Then
    
    iZuo = TCount("*", "tbl_MA_VA_Zuordnung", "VA_ID = " & Me!VA_ID & " AND VADatum_ID = " & Me!VADatum_ID & " AND VAStart_ID = " & Me!VAStart_ID & " AND MA_ID = 0")
    If iZuo > 0 Then
        iZuo = TLookup("ID", "tbl_MA_VA_Zuordnung", "VA_ID = " & Me!VA_ID & " AND VADatum_ID = " & Me!VADatum_ID & " AND VAStart_ID = " & Me!VAStart_ID & " AND MA_ID = 0")
        snetto = Nz(TLookup("MA_Netto_Std2", "tbl_MA_VA_Zuordnung", "ID = " & iZuo), 0)
        iPosNr = Nz(TLookup("PosNr", "tbl_MA_VA_Zuordnung", "ID = " & iZuo), 0)
    
        strSQL = ""
        strSQL = strSQL & "UPDATE tbl_MA_VA_Zuordnung, tbl_MA_VA_Planung SET"
        strSQL = strSQL & " tbl_MA_VA_Zuordnung.MA_ID = " & Me!MA_ID & ", "
        strSQL = strSQL & " tbl_MA_VA_Zuordnung.RL34a = " & str(fctround(RL34a_pro_Std(Me!MA_ID) * snetto)) & ", "
        strSQL = strSQL & " tbl_MA_VA_Zuordnung.Aend_von = '" & atCNames(1) & "', "
        strSQL = strSQL & " tbl_MA_VA_Zuordnung.Aend_am = Now()"
        strSQL = strSQL & " WHERE (((tbl_MA_VA_Zuordnung.ID)= " & iZuo & "));"
        
        CurrentDb.Execute (strSQL)
        
        'tbl_VA_AnzTage Updaten
        DoEvents
        Call VA_AnzTage_Upd(Me!VA_ID, Me!VADatum_ID)
        DoEvents
        
        MsgBox "Mitarbeiterzusage erledigt, MA hat PosNr " & iPosNr
    Else
        Me!Status_ID = Status_ID.OldValue
        MsgBox "Für diesen Zeitraum konnte kein freier Platz für den MA ermittelt werden", vbCritical, "Abbruch"
    End If
    
End If

Me.Requery

End Sub
