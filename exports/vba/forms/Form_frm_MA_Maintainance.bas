VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_MA_Maintainance"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub btn_Upd_MA_ID_Neu_Click()

Dim var As Variant
Dim strSQL As String
Dim k As Long

''-----------------------------------

'' tbl_MA_VA_Zuordnung
'...
'[MA_ID]
' ...
'[RL34a]
'...
'[Aend_von]
'[Aend_am]

'------------------------------------

''tbltmp_MA_Maint_ZuoAend
'
'   Zuo_ID
'   MA_ID_Alt
'   MA_ID_Neu
'
''-----------------------------------

'' lst_Zuo -- qry_MA_VA_Zuo_All_AufUeber_Maintain
''########
'Column(0) VA_ID
'Column(1) MA_ID
'Column(2) Zuo_ID
'Column(3) VA_Datum_ID
'Column(4) VADatum

''-----------------------------------

'################ Fehlerprüfungen

If Not IsDate(Me!AU_von) Or Not IsDate(Me!AU_bis) Then
    MsgBox "Falsches Datum"
    Exit Sub
End If

If Me!AU_von > Me!AU_bis Then
    MsgBox "Falsches Datum"
    Exit Sub
End If

If Len(Trim(Nz(Me!cboMA_In))) = 0 Or Len(Trim(Nz(Me!cboMA_out))) = 0 Then
    MsgBox "Mitarbeiter fehlt"
    Exit Sub
End If

If Me!cboMA_In = Me!cboMA_out Then
    MsgBox "Es müssen schon zwei unterschiedliche Mitarbeiter ausgewählt werden"
    Exit Sub
End If

If Me!lst_Zuo.ListCount < 2 Then
    MsgBox "Erstmal was einlesen"
    Exit Sub
End If

k = 0
For Each var In Me!lst_Zuo.ItemsSelected
    k = k + 1
Next var

If k = 0 Then
    MsgBox " Keine Zeile zum Ändern markiert"
    Exit Sub
End If

'######## Alles OK, jetzt geht's los

CurrentDb.Execute ("DELETE * FROM tbltmp_MA_Maint_ZuoAend;")
DoEvents

For Each var In Me!lst_Zuo.ItemsSelected
'  ' Listbox.column(Spalte, Zeile) <0,0>
    strSQL = "INSERT INTO tbltmp_MA_Maint_ZuoAend ( Zuo_ID, MA_ID_Alt, MA_ID_Neu ) SELECT " & Me!lst_Zuo.Column(2, var) & " AS Ausdr1, " & Me!lst_Zuo.Column(1, var) & " AS Ausdr2, " & Me!cboMA_out & " AS Ausdr3 FROM _tblInternalSystemFE;"
    CurrentDb.Execute (strSQL)
Next var

strSQL = ""
strSQL = strSQL & "UPDATE tbltmp_MA_Maint_ZuoAend INNER JOIN tbl_MA_VA_Zuordnung ON tbltmp_MA_Maint_ZuoAend.Zuo_ID = tbl_MA_VA_Zuordnung.ID "
strSQL = strSQL & " SET tbl_MA_VA_Zuordnung.MA_ID = [MA_ID_Neu], tbl_MA_VA_Zuordnung.RL_4a = fctRound(RL34a_pro_Std([MA_ID_Neu])*[MA_Netto_Std2]);"
CurrentDb.Execute (strSQL)

strSQL = ""
strSQL = strSQL & "UPDATE tbltmp_MA_Maint_ZuoAend INNER JOIN tbl_MA_VA_Zuordnung ON tbltmp_MA_Maint_ZuoAend.Zuo_ID = tbl_MA_VA_Zuordnung.ID "
strSQL = strSQL & " SET tbl_MA_VA_Zuordnung.RL34a = Null WHERE (((tbl_MA_VA_Zuordnung.RL34a)=0));"
CurrentDb.Execute (strSQL)

btnLesen_Click

MsgBox k & " Zuordnungen erfolgreich geändert, RL34a neu berechnet"

End Sub

Private Sub btnMarkAlle_Click()
Dim k As Long
Dim var As Variant

k = 0
If Me!lst_Zuo.ColumnHeads = True Then k = 1
For var = k To Me!lst_Zuo.ListCount - 1
'  ' Listbox.column(Spalte, Zeile) <0,0>
    Me!lst_Zuo.selected(var) = True
Next var

End Sub

Private Sub btntmptblLoesch_Click()
CurrentDb.Execute ("DELETE * FROM tbltmp_MA_Fehleingaben;")
Me!sub_tbltmp_MA_Fehleingaben.Requery
DoEvents
End Sub

Private Sub btnLesen_Click()
'in Abfrage qry_MA_VA_Zuo_All_AufUeber1 - VADatum - Dort ist das Datumsformat auf "ttt  tt.mm.jjjj" gesetzt
Dim strSQL As String
    strSQL = ""
    strSQL = strSQL & "SELECT * FROM qry_MA_VA_Zuo_All_AufUeber_Maintain WHERE VADatum Between " & SQLDatum(Me!AU_von) & " AND " & SQLDatum(Me!AU_bis) & " And MA_ID = " & Me!cboMA_In & " ORDER BY VADatum, Beginn"
    Me!lst_Zuo.RowSource = strSQL
    Me!lst_Zuo.Requery
    DoEvents

End Sub

Private Sub btnNeuberech_Click()

Dim iAktJahr As Long
Dim iAktMon As Long
Dim iAktlfd As Long
Dim iAktEnd As Long
Dim iAktStart As Long

Dim iAktJahr_Bis As Long
Dim iAktMon_Bis As Long

Dim iAktJahr_Von As Long
Dim iAktMon_Von As Long
Dim i As Long
Dim iMA_ID As Long

Dim iAnz As Long

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long

If Not IsDate(Me!AU_von) Or Not IsDate(Me!AU_bis) Then
    MsgBox "Falsches Datum"
    Exit Sub
End If

If Me!AU_von > Me!AU_bis Then
    MsgBox "Falsches Datum"
    Exit Sub
End If

'Zusätzlich notwendige Maintainance zu Summary-Feldern der Tabelle tbl_VA_AnzTage
VA_AnzTage_Maintainance

DoCmd.Hourglass True

iAktJahr_Von = Year(Me!AU_von)
iAktMon_Von = Month(Me!AU_von)

iAktJahr = Year(Me!AU_von)
iAktMon = Month(Me!AU_von)

iAktJahr_Bis = Year(Me!AU_bis)
iAktMon_Bis = Month(Me!AU_bis)

iAktEnd = iAktJahr_Bis * 100 + iAktMon_Bis
iAktStart = iAktJahr_Von * 100 + iAktMon_Von

iAnz = Nz(TCount("*", "tbltmp_MA_Fehleingaben"))

If iAnz > 0 Then  'MA_ID in Array einlesen
    recsetSQL1 = "SELECT * FROM tbltmp_MA_Fehleingaben"
    ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
    'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
End If

i = 0
Do While i = 0
    If iAnz > 0 Then 'Jahresübersichtswert einzeln pro Monat und selektiertem Mitarbeiter
        If ArrFill_DAO_OK1 Then
            For iZl = 0 To iZLMax1
                iMA_ID = DAOARRAY1(0, iZl)
                Call Ueberlaufstd_Berech_Neu(iAktJahr, iAktMon, iMA_ID)
            Next iZl
        End If
    Else   'Jahresübersichtswert einzeln pro Monat für alle MA
        Call Ueberlaufstd_Berech_Neu(iAktJahr, iAktMon)
    End If
    iAktMon = iAktMon + 1
    If iAktMon > 12 Then
        iAktMon = 1
        iAktJahr = iAktJahr + 1
    End If
    iAktlfd = iAktJahr * 100 + iAktMon
    If iAktlfd > iAktEnd Then
        i = 1
    End If
Loop

Set DAOARRAY1 = Nothing
DoCmd.Hourglass False
MsgBox "Werte erfolgreich neu berechnet !"
End Sub

Private Sub cboMA_In_AfterUpdate()
    Me!lst_Zuo.RowSource = ""
    Me!lst_Zuo.Requery
End Sub

Private Sub cboZeitraum_AfterUpdate()
'' Function StdZeitraum_Von_Bis(ID, von, bis)  und Tabelle _tblZeitraumAngaben (für Combobox)
Dim dtvon As Date
Dim dtbis As Date
Call StdZeitraum_Von_Bis(Me!cboZeitraum, dtvon, dtbis)
Me!AU_von = dtvon
Me!AU_bis = dtbis
DoEvents
btnLesen_Click

End Sub

Private Sub Form_Load()
DoCmd.Maximize
End Sub

Private Sub Form_Open(Cancel As Integer)
Me!lbl_Datum.caption = Date
cboZeitraum_AfterUpdate
End Sub

Private Sub Text6_DblClick(Cancel As Integer)
Set Global_AufrufCtrl = Me.ActiveControl
DoCmd.OpenForm "_frmHlp_Kalender_3Mon", , , , , , "XXXSubformXXX"
End Sub

Private Sub Text8_DblClick(Cancel As Integer)
Set Global_AufrufCtrl = Me.ActiveControl
DoCmd.OpenForm "_frmHlp_Kalender_3Mon", , , , , , "XXXSubformXXX"
End Sub
