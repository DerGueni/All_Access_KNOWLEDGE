# frm_MA_Maintainance

## Formular-Metadaten

| Eigenschaft | Wert |
|-------------|------|
| **Name** | frm_MA_Maintainance |
| **Datensatzquelle** | - |
| **Default View** | SingleForm |
| **Allow Edits** | Ja |
| **Allow Additions** | Ja |
| **Allow Deletions** | Ja |
| **Data Entry** | Nein |
| **Navigation Buttons** | Ja |

## Controls


### ComboBoxen (Auswahllisten)

| Name | Control Source | Position (L/T) | Groesse (W/H) | TabIndex |
|------|----------------|----------------|---------------|----------|
| cboMA_In | - | 4908 / 555 | 3168 x 315 | 0 |
| cboMA_out | - | 4908 / 1305 | 3168 x 315 | 2 |
| cboZeitraum | - | 9895 / 592 | 2565 x 315 | 6 |

### Buttons (Schaltflaechen)

| Name | Caption | Position (L/T) | Groesse (W/H) | Events |
|------|---------|----------------|---------------|--------|
| Befehl38 | btn_Formular_schliessen | 7650 / 690 | 381 x 366 | OnClick: [Eingebettetes Makro] |
| btnHilfe | Hilfe | 7125 / 690 | 426 x 366 | OnClick: [Eingebettetes Makro] |
| btnRibbonAus | Befehl179 | 851 / 340 | 283 x 223 | - |
| btnRibbonEin | Befehl179 | 851 / 670 | 283 x 223 | - |
| btnDaBaEin | Befehl179 | 1136 / 505 | 283 x 223 | - |
| btnDaBaAus | Befehl179 | 566 / 505 | 283 x 223 | - |
| btnLesen | Lesen | 14700 / 720 | 1638 x 400 | OnClick: [Event Procedure] |
| btn_Upd_MA_ID_Neu | Ändern | 14355 / 1575 | 2055 x 565 | OnClick: [Event Procedure] |
| btnNeuberech | Jahreswerte für den gewählten Zeitraum neu berechnen | 16680 / 675 | 3140 x 804 | OnClick: [Event Procedure] |
| btntmptblLoesch | Löschen | 19005 / 7935 | 885 x 360 | OnClick: [Event Procedure] |
| btnMarkAlle | Alle markieren | 9030 / 1845 | 1815 x 345 | OnClick: [Event Procedure] |
### Labels (Bezeichnungsfelder)

| Name | Position (L/T) | Groesse (W/H) | ForeColor |
|------|----------------|---------------|-----------||
| Auto_Kopfzeile0 | 2625 / 600 | 2760 x 460 | -2147483616 (Unbekannt) |
| lbl_Datum | 22050 / 765 | 1633 x 397 | -2147483616 (Unbekannt) |
| Bezeichnungsfeld5 | 3450 / 555 | 1185 x 300 | 0 (Schwarz) |
| Bezeichnungsfeld12 | 3450 / 1305 | 1410 x 300 | 0 (Schwarz) |
| Bezeichnungsfeld16 | 3360 / 1935 | 3300 x 315 | 0 (Schwarz) |
| Bezeichnungsfeld17 | 20016 / 503 | 3645 x 10080 | 0 (Schwarz) |
| Bezeichnungsfeld29 | 16800 / 120 | 2925 x 330 | 0 (Schwarz) |
| Bezeichnungsfeld31 | 4020 / 60 | 12195 x 330 | 8355711 (Grau) |
| Bezeichnungsfeld32 | 16935 / 8608 | 2985 x 1290 | 0 (Schwarz) |
| Bezeichnungsfeld366 | 8805 / 585 | 1005 x 315 | 0 (Schwarz) |
| Bezeichnungsfeld368 | 9510 / 1050 | 330 x 315 | 8355711 (Grau) |
| Bezeichnungsfeld370 | 11160 / 1050 | 285 x 315 | 8355711 (Grau) |
| Bezeichnungsfeld23 | 16800 / 1950 | 3060 x 315 | 8355711 (Grau) |
| Bezeichnungsfeld24 | 16920 / 7995 | 1974 x 284 | 0 (Schwarz) |

### ListBoxs

| Name | Caption | Position (L/T) | Groesse (W/H) |
|------|---------|----------------|---------------|
| lst_Zuo | - | 3344 / 2278 | 13203 x 8305 |

### Subforms (Unterformulare)

| Name | Source Object | Position (L/T) | Groesse (W/H) |
|------|---------------|----------------|---------------|
| sub_tbltmp_MA_Fehleingaben | - | 16725 / 2310 | 3177 x 5416 |
| frm_Menuefuehrung | - | 0 / 0 | 3223 x 10764 |

### TextBoxen

| Name | Control Source | Position (L/T) | Groesse (W/H) | TabIndex |
|------|----------------|----------------|---------------|----------||
| AU_von | - | 9930 / 1050 | 928 x 315 | 7 |
| AU_bis | - | 11505 / 1050 | 915 x 315 | 8 |

## Events

### Formular-Events
- OnOpen: [Event Procedure]
- OnLoad: [Event Procedure]
- OnClose: Keine
- OnCurrent: Keine
- BeforeUpdate: Keine
- AfterUpdate: Keine
- OnActivate: Keine
- OnDeactivate: Keine

## VBA-Code

```vba
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
End Sub```
