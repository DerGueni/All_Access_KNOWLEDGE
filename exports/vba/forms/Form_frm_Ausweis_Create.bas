VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_Ausweis_Create"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

'Prüfung auf Kartendrucker
Const checkCardPrinter = "Badgy"


Private Sub btn_ausweiseinsatzleitung_Click()
Dim strSQL As String
strSQL = ""
strSQL = strSQL & "SELECT tbl_MA_Mitarbeiterstamm.*, fKopf_Bildname([ID]) AS Kopf_Bild, fSignatur([ID]) AS Signatur, fUnterschrift_Bild() AS Unterschr, "
strSQL = strSQL & SQLDatum(Me!GueltBis) & " AS Ausw_Gueltig_Bis, [Strasse] & ' ' & [Nr] AS Strasse_nr"
strSQL = strSQL & " FROM tbltmp_AusweisMA_ID INNER JOIN tbl_MA_Mitarbeiterstamm ON tbltmp_AusweisMA_ID.MA_ID = tbl_MA_Mitarbeiterstamm.ID"
strSQL = strSQL & " ORDER BY tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname;"
Call CreateQuery(strSQL, "qry_Report_Ausweisdruck")
DoEvents

DoCmd.OpenReport "rpt_Ausweis_ohne_Namen_einsatzleitung", acViewReport
'btnDelAll_Click
End Sub

Private Sub btn_ausweisplatzanweiser_Click()
Dim strSQL As String
strSQL = ""

strSQL = strSQL & "SELECT tbl_MA_Mitarbeiterstamm.*, fKopf_Bildname([ID]) AS Kopf_Bild, fSignatur([ID]) AS Signatur, fUnterschrift_Bild() AS Unterschr, "
strSQL = strSQL & SQLDatum(Me!GueltBis) & " AS Ausw_Gueltig_Bis, [Strasse] & ' ' & [Nr] AS Strasse_nr"
strSQL = strSQL & " FROM tbltmp_AusweisMA_ID INNER JOIN tbl_MA_Mitarbeiterstamm ON tbltmp_AusweisMA_ID.MA_ID = tbl_MA_Mitarbeiterstamm.ID"
strSQL = strSQL & " ORDER BY tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname;"
Call CreateQuery(strSQL, "qry_Report_Ausweisdruck")
DoEvents

DoCmd.OpenReport "rpt_Ausweis_ohne_Namen_platzanweiser", acViewReport
'btnDelAll_Click
'Forms!frm_ausweis_create!lstMA__ausweis.Clear

End Sub

Private Sub btn_ausweisstaff_click()
Dim strSQL As String
strSQL = ""

strSQL = strSQL & "SELECT tbl_MA_Mitarbeiterstamm.*, fKopf_Bildname([ID]) AS Kopf_Bild, fSignatur([ID]) AS Signatur, fUnterschrift_Bild() AS Unterschr, "
strSQL = strSQL & SQLDatum(Me!GueltBis) & " AS Ausw_Gueltig_Bis, [Strasse] & ' ' & [Nr] AS Strasse_nr"
strSQL = strSQL & " FROM tbltmp_AusweisMA_ID INNER JOIN tbl_MA_Mitarbeiterstamm ON tbltmp_AusweisMA_ID.MA_ID = tbl_MA_Mitarbeiterstamm.ID"
strSQL = strSQL & " ORDER BY tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname;"
Call CreateQuery(strSQL, "qry_Report_Ausweisdruck")
DoEvents
DoCmd.OpenReport "rpt_Ausweis_ohne_Namen_Staff", acViewReport
'btnDelAll_Click
End Sub


Private Sub btn_ausweisBereichsleiter_Click()
Dim strSQL As String
strSQL = ""
strSQL = strSQL & "SELECT tbl_MA_Mitarbeiterstamm.*, fKopf_Bildname([ID]) AS Kopf_Bild, fSignatur([ID]) AS Signatur, fUnterschrift_Bild() AS Unterschr, "
strSQL = strSQL & SQLDatum(Me!GueltBis) & " AS Ausw_Gueltig_Bis, [Strasse] & ' ' & [Nr] AS Strasse_nr"
strSQL = strSQL & " FROM tbltmp_AusweisMA_ID INNER JOIN tbl_MA_Mitarbeiterstamm ON tbltmp_AusweisMA_ID.MA_ID = tbl_MA_Mitarbeiterstamm.ID"
strSQL = strSQL & " ORDER BY tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname;"
Call CreateQuery(strSQL, "qry_Report_Ausweisdruck")

DoEvents

DoCmd.OpenReport "rpt_Ausweis_ohne_Namen_Bereichsleiter", acViewReport
'btnDelAll_Click
End Sub

Private Sub btn_ausweissec_Click()

Dim strSQL As String
strSQL = ""

strSQL = strSQL & "SELECT tbl_MA_Mitarbeiterstamm.*, fKopf_Bildname([ID]) AS Kopf_Bild, fSignatur([ID]) AS Signatur, fUnterschrift_Bild() AS Unterschr, "
strSQL = strSQL & SQLDatum(Me!GueltBis) & " AS Ausw_Gueltig_Bis, [Strasse] & ' ' & [Nr] AS Strasse_nr"
strSQL = strSQL & " FROM tbltmp_AusweisMA_ID INNER JOIN tbl_MA_Mitarbeiterstamm ON tbltmp_AusweisMA_ID.MA_ID = tbl_MA_Mitarbeiterstamm.ID"
'strSQL = strSQL & " ORDER BY tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname;"
Call CreateQuery(strSQL, "qry_Report_Ausweisdruck")
DoEvents
DoCmd.OpenReport "rpt_Ausweis_ohne_Namen_sec", acViewReport
'btnDelAll_Click
End Sub


Private Sub btn_ausweisservice_Click()
Dim strSQL As String
strSQL = ""

strSQL = strSQL & "SELECT tbl_MA_Mitarbeiterstamm.*, fKopf_Bildname([ID]) AS Kopf_Bild, fSignatur([ID]) AS Signatur, fUnterschrift_Bild() AS Unterschr, "
strSQL = strSQL & SQLDatum(Me!GueltBis) & " AS Ausw_Gueltig_Bis, [Strasse] & ' ' & [Nr] AS Strasse_nr"
strSQL = strSQL & " FROM tbltmp_AusweisMA_ID INNER JOIN tbl_MA_Mitarbeiterstamm ON tbltmp_AusweisMA_ID.MA_ID = tbl_MA_Mitarbeiterstamm.ID"
strSQL = strSQL & " ORDER BY tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname;"
Call CreateQuery(strSQL, "qry_Report_Ausweisdruck")
DoEvents
DoCmd.OpenReport "rpt_Ausweis_ohne_Namen_service", acViewReport
'btnDelAll_Click
End Sub


'Kartendruck Servicepersonal
Private Sub btn_Karte_Service_Click()

On Error Resume Next

    If TCount("MA_ID", "tbltmp_AusweisMA_ID") <> 1 Then
        MsgBox "Ausweiskarten bitte einzeln drucken!"
        Exit Sub
    End If
    
    If InStr(Me.lbl_Kartendrucker.caption, checkCardPrinter) = 0 Then
        MsgBox "Für Kartendruck nur Kartendrucker zulässig!"
        Exit Sub
    End If
    
    create_query_Druck
    DoCmd.OpenReport "rpt_Ausweis_Karte_Vorderseite", acViewReport, , , , "Servicepersonal"
    
    'Gültig Bis
    updateGueltigkeit

    
End Sub


'Kartendruck Sicherheitspersonal
Private Sub btn_Karte_Sicherheit_Click()
    
On Error Resume Next

    If TCount("MA_ID", "tbltmp_AusweisMA_ID") <> 1 Then
        MsgBox "Ausweiskarten bitte einzeln drucken!"
        Exit Sub
    End If
    
    If InStr(Me.lbl_Kartendrucker.caption, checkCardPrinter) = 0 Then
        MsgBox "Für Kartendruck nur Kartendrucker zulässig!"
        Exit Sub
    End If
    
    'Datenbereitstellung
    create_query_Druck

    'Öffnen
    DoCmd.OpenReport "rpt_Ausweis_Karte_Vorderseite", acViewReport, , , , "Sicherheitspersonal"
    
    'Gültig Bis
    updateGueltigkeit

End Sub


'Sonderausweisdruck
Private Sub btn_Sonder_Click()

Dim zeile1 As String
Dim zeile2 As String
Dim Text As String

On Error Resume Next
    
    If TCount("MA_ID", "tbltmp_AusweisMA_ID") <> 1 Then
        MsgBox "Ausweiskarten bitte einzeln drucken!"
        Exit Sub
    End If
    
    If InStr(Me.lbl_Kartendrucker.caption, checkCardPrinter) = 0 Then
        MsgBox "Für Kartendruck nur Kartendrucker zulässig!"
        Exit Sub
    End If
    
    zeile1 = InputBox("Text Zeile1")
    zeile2 = InputBox("Text Zeile2")
    
    Text = zeile1 & "/" & zeile2
    
    create_query_Druck
    DoCmd.OpenReport "rpt_Ausweis_Karte_Vorderseite", acViewReport, , , , Text
    
    'Gültig Bis
    updateGueltigkeit

    
End Sub


'Kartendruck Rückseite
Private Sub btn_Karte_Rueck_Click()

On Error Resume Next

    If TCount("MA_ID", "tbltmp_AusweisMA_ID") <> 1 Then
        MsgBox "Ausweiskarten bitte einzeln drucken!"
        Exit Sub
    End If
    
    If InStr(Me.lbl_Kartendrucker.caption, checkCardPrinter) = 0 Then
        MsgBox "Für Kartendruck nur Kartendrucker zulässig!"
        Exit Sub
    End If

    create_query_Druck
    DoCmd.OpenReport "rpt_Ausweis_Karte_Rueckseite", acViewReport
    
End Sub


'Abfrage für Ausweisdruck erzeugen
Function create_query_Druck()

Dim strSQL As String
    strSQL = ""

    strSQL = strSQL & "SELECT tbl_MA_Mitarbeiterstamm.*, fKopf_Bildname([ID]) AS Kopf_Bild, fSignatur([ID]) AS Signatur, fUnterschrift_Bild() AS Unterschr, "
    strSQL = strSQL & SQLDatum(Me!GueltBis) & " AS Ausw_Gueltig_Bis, [Strasse] & ' ' & [Nr] AS Strasse_nr"
    strSQL = strSQL & " FROM tbltmp_AusweisMA_ID INNER JOIN tbl_MA_Mitarbeiterstamm ON tbltmp_AusweisMA_ID.MA_ID = tbl_MA_Mitarbeiterstamm.ID"
    strSQL = strSQL & " ORDER BY tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname;"
    
    Call CreateQuery(strSQL, "qry_Report_Ausweisdruck")

End Function


Private Sub btnAddAll_Click()


CurrentDb.Execute ("DELETE * FROM tbltmp_AusweisMA_ID;")
CurrentDb.Execute ("INSERT INTO tbltmp_AusweisMA_ID ( MA_ID ) SELECT tbl_MA_Mitarbeiterstamm.ID FROM tbl_MA_Mitarbeiterstamm;")
DoEvents

Me!lstMA_Ausweis.Requery
btnDeselect_Click

DoEvents

End Sub

Private Sub btnAddSelected_Click()

Dim var
Dim iMA_ID As Long

    ' Listbox.column(Spalte, Zeile) <0,0>
    ' For Each var In Me!MeineListbox.ItemsSelected

    For Each var In Me!lstMA_Alle.ItemsSelected
        iMA_ID = Me!lstMA_Alle.Column(0, var)
        
        CurrentDb.Execute ("INSERT INTO tbltmp_AusweisMA_ID ( MA_ID ) SELECT " & iMA_ID & " AS Ausdr1 FROM _tblInternalSystemFE;")
        
        'Gültigkeitsdatum im Mitarbeiterstamm anpassen
        TUpdate "Ausweis_Endedatum = " & datumSQL(Me.GueltBis), MASTAMM, "ID = " & iMA_ID
        
    Next var

DoEvents

Me.lstMA_Alle.Requery
Me!lstMA_Ausweis.Requery
Me!lstMA_Ausweis.SetFocus



'btnDeselect_Click

DoEvents

End Sub

Private Sub btnAusweisReport_Click()

Dim strSQL As String
strSQL = ""

strSQL = strSQL & "SELECT tbl_MA_Mitarbeiterstamm.*, fKopf_Bildname([ID]) AS Kopf_Bild, fSignatur([ID]) AS Signatur, fUnterschrift_Bild() AS Unterschr, "
strSQL = strSQL & SQLDatum(Me!GueltBis) & " AS Ausw_Gueltig_Bis, [Strasse] & ' ' & [Nr] AS Strasse_nr"
strSQL = strSQL & " FROM tbltmp_AusweisMA_ID INNER JOIN tbl_MA_Mitarbeiterstamm ON tbltmp_AusweisMA_ID.MA_ID = tbl_MA_Mitarbeiterstamm.ID"
strSQL = strSQL & " ORDER BY tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname;"
Call CreateQuery(strSQL, "qry_Report_Ausweisdruck")
DoEvents
DoCmd.OpenReport "rpt_Ausweis", acViewReport
'btnDelAll_Click
End Sub

Private Sub btnDelAll_Click()
CurrentDb.Execute ("DELETE * FROM tbltmp_AusweisMA_ID;")
DoEvents

Me!lstMA_Ausweis.Requery
btnDeselect_Click

DoEvents


End Sub

Private Sub btnDelSelected_Click()
    ' Listbox.column(Spalte, Zeile) <0,0>
    ' For Each var In Me!MeineListbox.ItemsSelected

Dim var
Dim iMA_ID As Long

    For Each var In Me!lstMA_Ausweis.ItemsSelected
        
        iMA_ID = Me!lstMA_Ausweis.Column(0, var)

        CurrentDb.Execute ("Delete * FROM tbltmp_AusweisMA_ID WHERE (((tbltmp_AusweisMA_ID.MA_ID)= " & iMA_ID & "));")

    Next var

DoEvents

Me!lstMA_Ausweis.Requery
btnDeselect_Click

DoEvents

End Sub

Private Sub btnDeselect_Click()

Me!lstMA_Ausweis.RowSource = Me!lstMA_Ausweis.RowSource
Me!lstMA_Ausweis.Requery
Me!lstMA_Alle.RowSource = Me!lstMA_Alle.RowSource
Me!lstMA_Alle.Requery
DoEvents
End Sub

Private Sub btnDienstauswNr_Click()

Dim strSQL As String
CurrentDb.Execute ("UPDATE tbl_MA_Mitarbeiterstamm SET tbl_MA_Mitarbeiterstamm.DienstausweisNr = [ID] WHERE Len(trim(Nz(DienstausweisNr))) = 0;")
Me!lstMA_Alle.RowSource = Me!lstMA_Alle.RowSource

End Sub


'Kartendrucker setzen
Private Sub cbo_Kartendrucker_AfterUpdate()

    If Me.cbo_Kartendrucker.Column(0) <> "" Then
        Call Set_Priv_Property("prp_Kartendrucker", Me.cbo_Kartendrucker.Column(0))
        Me.lbl_Kartendrucker.caption = Get_Priv_Property("prp_Kartendrucker")
    End If
    
End Sub


Private Sub Form_Load()
   
Dim prtloop As Printer

    Me.cbo_Kartendrucker.RowSource = ""
    Me.cbo_Kartendrucker.AddItem ""
    For Each prtloop In Application.Printers
      Me.cbo_Kartendrucker.AddItem prtloop.DeviceName
    Next prtloop
    
    DoCmd.Maximize
End Sub

Private Sub Form_Open(Cancel As Integer)
    Me!lbl_Datum.caption = Date
    Me!lstMA_Ausweis.SetFocus
    btnDelAll_Click
    Me.lbl_Kartendrucker.caption = Get_Priv_Property("prp_Kartendrucker")
    
End Sub

Private Sub GueltBis_DblClick(Cancel As Integer)
Set Global_AufrufCtrl = Me.ActiveControl
DoCmd.OpenForm "_frmHlp_Kalender_3Mon", , , , , , "XXXSubformXXX"
End Sub

Private Sub lstMA_Alle_DblClick(Cancel As Integer)
Me!lstMA_Ausweis.SetFocus
btnDelAll_Click
btnAddSelected_Click

'Sicherheitspersonal öffnen
btn_Karte_Sicherheit_Click

'Me!lstMA_Alle.SetFocus
'btn_ausweissec_Click
'Me!lstMA_Alle.SetFocus
'DoCmd.OpenForm "frm_MA_Mitarbeiterstamm", , , "ID = " & Me!lstMA_Alle.column(0)
End Sub

Private Sub lstMA_Alle_KeyDown(KeyCode As Integer, Shift As Integer)
Me!lstMA_Ausweis.SetFocus
btnDelAll_Click
btnAddSelected_Click
Me!lstMA_Alle.SetFocus
btn_ausweisservice_Click
Me!lstMA_Alle.SetFocus
End Sub


Private Sub lstMA_Ausweis_DblClick(Cancel As Integer)

'Servicepersonal öffnen
btn_Karte_Service_Click

End Sub


'Gültigkeitsdatum im Mitarbeiterstamm
Function updateGueltigkeit()

Dim ID As Integer
        
    ID = TLookup("MA_ID", "tbltmp_AusweisMA_ID")
    TUpdate "Ausweis_Endedatum = " & datumSQL(Me.GueltBis), MASTAMM, "ID = " & ID
    
End Function





    


