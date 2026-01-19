Attribute VB_Name = "Modul1"
Option Compare Database
Option Explicit


Sub test()
Dim tbl As String
Dim ABF As String
Dim sql As String

    ABF = "zqry_ZK_Stunden_Union"
    tbl = "ztbl_zqry_ZK_Stunden_Union"
    
    sql = "SELECT * INTO " & tbl & " FROM " & ABF & " WHERE Monat = 1 And Jahr = 2023 And MA_ID = 56"
    
    If TableExists(tbl) Then DoCmd.DeleteObject acTable, tbl
    CurrentDb.Execute sql
End Sub


Function Testhyp()

Application.FollowHyperlink "C:\Kunden\CONSEC (Siegert)\PGM\Dokumente\Auftrag\Auf_Zusage_02.11.2015_415.pdf"

End Function


Function Ftest_UE()

Dim mycontrol

Dim iVADatum_ID As Long
Dim iVA_ID As Long
Dim strSQL2 As String
Dim dtsich As Date
Dim stdat As Date

Set mycontrol = Screen.ActiveForm.ActiveControl
'Debug.Print mycontrol.Name
'
'Debug.Print mycontrol.Column(0)
'Debug.Print mycontrol.Column(1)
'Debug.Print mycontrol.Column(2)
'Debug.Print mycontrol.Column(3)
'Debug.Print mycontrol.Column(4)



'Alle STunden berechnen


iVA_ID = mycontrol.Column(0)
iVADatum_ID = mycontrol.Column(1)
stdat = mycontrol.Column(2)

strSQL2 = ""
strSQL2 = strSQL2 & "SELECT tbl_MA_VA_Zuordnung.ID, tbl_MA_VA_Zuordnung.VA_ID, Nz(tbl_MA_VA_Zuordnung.MA_ID,0) AS Ausdr1, tbl_MA_VA_Zuordnung.PosNr,"
strSQL2 = strSQL2 & " [Nachname] & ', ' & [Vorname] AS Mitarbeiter, Left(Nz([VA_Start]),5) AS Start"
strSQL2 = strSQL2 & " FROM tbl_VA_Start RIGHT JOIN (tbl_MA_VA_Zuordnung LEFT JOIN tbl_MA_Mitarbeiterstamm"
strSQL2 = strSQL2 & " ON tbl_MA_VA_Zuordnung.MA_ID = tbl_MA_Mitarbeiterstamm.ID) ON tbl_VA_Start.ID = tbl_MA_VA_Zuordnung.VAStart_ID"
strSQL2 = strSQL2 & " WHERE (tbl_MA_VA_Zuordnung.VA_ID= " & iVA_ID & ") AND ((tbl_MA_VA_Zuordnung.VADatum_ID) = " & iVADatum_ID & ") Order By PosNr;"

'DoCmd.OpenForm "frm_VA_Auftragstamm", , , "ID = " & iVA_ID
DoCmd.OpenForm "frmTop_VA_Tag_sub"
Forms!frmTop_VA_Tag_sub!dtDatum = stdat
Forms!frmTop_VA_Tag_sub!VA_ID = iVA_ID
Forms!frmTop_VA_Tag_sub!lst_Ist.RowSource = strSQL2
Forms!frmTop_VA_Tag_sub!lst_Ist.Requery
Forms!frmTop_VA_Tag_sub.Requery

End Function

Function MA_Upd1()

Dim strSQL As String

strSQL = ""
strSQL = strSQL & "UPDATE tbl_MA_Mitarbeiterstamm INNER JOIN tbl_MA_Mitarbeiterstamm1 ON tbl_MA_Mitarbeiterstamm.ID = tbl_MA_Mitarbeiterstamm1.ID SET"
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.ID = [tbl_MA_Mitarbeiterstamm1].[ID], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.LEXWare_ID = [tbl_MA_Mitarbeiterstamm1].[LEXWare_ID], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.IstAktiv = [tbl_MA_Mitarbeiterstamm1].[IstAktiv], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.IstSubunternehmer = [tbl_MA_Mitarbeiterstamm1].[IstSubunternehmer], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Nachname = [tbl_MA_Mitarbeiterstamm1].[Nachname], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Vorname = [tbl_MA_Mitarbeiterstamm1].[Vorname], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Strasse = [tbl_MA_Mitarbeiterstamm1].[Strasse], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Nr = [tbl_MA_Mitarbeiterstamm1].[Nr], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.PLZ = [tbl_MA_Mitarbeiterstamm1].[PLZ], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Ort = [tbl_MA_Mitarbeiterstamm1].[Ort], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Land = [tbl_MA_Mitarbeiterstamm1].[Land], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Bundesland = [tbl_MA_Mitarbeiterstamm1].[Bundesland], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Tel_Mobil = [tbl_MA_Mitarbeiterstamm1].[Tel_Mobil], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Tel_Festnetz = [tbl_MA_Mitarbeiterstamm1].[Tel_Festnetz], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Email = [tbl_MA_Mitarbeiterstamm1].[Email], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Geschlecht = [tbl_MA_Mitarbeiterstamm1].[Geschlecht], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Staatsang = [tbl_MA_Mitarbeiterstamm1].[Staatsang], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Geb_Dat = [tbl_MA_Mitarbeiterstamm1].[Geb_Dat], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Geb_Ort = [tbl_MA_Mitarbeiterstamm1].[Geb_Ort], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Geb_Name = [tbl_MA_Mitarbeiterstamm1].[Geb_Name], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Eintrittsdatum = [tbl_MA_Mitarbeiterstamm1].[Eintrittsdatum], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Austrittsdatum = [tbl_MA_Mitarbeiterstamm1].[Austrittsdatum], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Anstellungsart_ID = [tbl_MA_Mitarbeiterstamm1].[Anstellungsart_ID], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Kostenstelle = [tbl_MA_Mitarbeiterstamm1].[Kostenstelle], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Auszahlungsart = [tbl_MA_Mitarbeiterstamm1].[Auszahlungsart], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Bankname = [tbl_MA_Mitarbeiterstamm1].[Bankname], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Bankleitzahl = [tbl_MA_Mitarbeiterstamm1].[Bankleitzahl], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Kontonummer = [tbl_MA_Mitarbeiterstamm1].[Kontonummer], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.BIC = [tbl_MA_Mitarbeiterstamm1].[BIC], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.IBAN = [tbl_MA_Mitarbeiterstamm1].[IBAN], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Kontoinhaber = [tbl_MA_Mitarbeiterstamm1].[Kontoinhaber], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Stundenlohn_brutto = [tbl_MA_Mitarbeiterstamm1].[Stundenlohn_brutto], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Bezuege_gezahlt_als = [tbl_MA_Mitarbeiterstamm1].[Bezuege_gezahlt_als], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Sozialvers_Nr = [tbl_MA_Mitarbeiterstamm1].[Sozialvers_Nr], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.SteuerNr = [tbl_MA_Mitarbeiterstamm1].[SteuerNr], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Taetigkeit_Bezeichnung = [tbl_MA_Mitarbeiterstamm1].[Taetigkeit_Bezeichnung], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Personengruppe = [tbl_MA_Mitarbeiterstamm1].[Personengruppe], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.KV_Kasse = [tbl_MA_Mitarbeiterstamm1].[KV_Kasse], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Ist_RV_Befrantrag = [tbl_MA_Mitarbeiterstamm1].[Ist_RV_Befrantrag], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Steuerklasse = [tbl_MA_Mitarbeiterstamm1].[Steuerklasse], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Arbst_pro_Arbeitstag = [tbl_MA_Mitarbeiterstamm1].[Arbst_pro_Arbeitstag], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Arbeitstage_pro_Woche = [tbl_MA_Mitarbeiterstamm1].[Arbeitstage_pro_Woche], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Resturl_Vorjahr = [tbl_MA_Mitarbeiterstamm1].[Resturl_Vorjahr], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Urlaubsanspr_pro_Jahr = [tbl_MA_Mitarbeiterstamm1].[Urlaubsanspr_pro_Jahr], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.StundenZahlMax = [tbl_MA_Mitarbeiterstamm1].[StundenZahlMax], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Hat_keine_34a = [tbl_MA_Mitarbeiterstamm1].[Hat_keine_34a], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Kleidergroesse = [tbl_MA_Mitarbeiterstamm1].[Kleidergroesse], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Fahrerlaubnis = [tbl_MA_Mitarbeiterstamm1].[Fahrerlaubnis], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Eigener_PKW = [tbl_MA_Mitarbeiterstamm1].[Eigener_PKW], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.HatSachkunde = [tbl_MA_Mitarbeiterstamm1].[HatSachkunde], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.DienstausweisNr = [tbl_MA_Mitarbeiterstamm1].[DienstausweisNr], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.tblBilddatei = [tbl_MA_Mitarbeiterstamm1].[tblBilddatei], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Bemerkungen = [tbl_MA_Mitarbeiterstamm1].[Bemerkungen], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Briefkopf = [tbl_MA_Mitarbeiterstamm1].[Briefkopf], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.IstBrfAuto = [tbl_MA_Mitarbeiterstamm1].[IstBrfAuto], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Anr = [tbl_MA_Mitarbeiterstamm1].[Anr], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Anr_Brief = [tbl_MA_Mitarbeiterstamm1].[Anr_Brief], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Anr_eMail = [tbl_MA_Mitarbeiterstamm1].[Anr_eMail], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Erst_von = [tbl_MA_Mitarbeiterstamm1].[Erst_von], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Erst_am = [tbl_MA_Mitarbeiterstamm1].[Erst_am], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Aend_von = [tbl_MA_Mitarbeiterstamm1].[Aend_von], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Aend_am = [tbl_MA_Mitarbeiterstamm1].[Aend_am], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.AUsweis_Funktion = [tbl_MA_Mitarbeiterstamm1].[AUsweis_Funktion], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.IstNSB = [tbl_MA_Mitarbeiterstamm1].[IstNSB], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Datum_34a = [tbl_MA_Mitarbeiterstamm1].[Datum_34a], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Ausweis_Endedatum = [tbl_MA_Mitarbeiterstamm1].[Ausweis_Endedatum], "
strSQL = strSQL & " tbl_MA_Mitarbeiterstamm.Kosten_pro_MAStunde = [tbl_MA_Mitarbeiterstamm1].[Kosten_pro_MAStunde];"

Call CreateQuery(strSQL, "qry_MA_Update_MA_Neu")
DoEvents
CurrentDb.Execute ("qry_MA_Update_MA_Neu")
End Function



Sub send_qr_mail()

Dim attach As String
Dim Email  As String
Dim rs As Recordset

    Set rs = CurrentDb.OpenRecordset("SELECT * FROM " & MASTAMM & " WHERE Anstellungsart_ID = 3 OR Anstellungsart_ID = 5 or Anstellungsart_ID = 4")
    'Set rs = CurrentDb.OpenRecordset("SELECT * FROM " & MASTAMM & " WHERE Nachname = 'Kuypers'")
    Do While Not rs.EOF
        Email = rs!Email
        attach = "\\vconsys01-nbg\Consys\Bilder\Mitarbeiter\QR Codes\" & rs!Nachname & "_" & rs!Vorname & ".jpg"
        If Email <> "" Then
            If Dir(attach) = "" Then
                'PDF erstellen und Verschicken !!!!!
            End If
            
            'Debug.Print sendQR_mail(Email, attach)
            'If sendQR_mail(Email, attach) <> "" Then Debug.Print rs!ID
        End If
        rs.MoveNext
    Loop

    
End Sub

Function sendQR_mail(Email As String, attach As String) As String

Dim MailText As String

    'mailtext = "Hallo zusammen," & vbCrLf & vbCrLf & "wir testen gerade unser neues QR Code Check-In System." & vbCrLf & "Deshalb würden wir Dich bitten, den beigefügten QR Code auf Deinem Handy zu speichern, um ihn beim Check In Test vor Ort verwenden zu können." & vbCrLf & vbCrLf & "Vielen lieben Dank "
        
    'sendQR_mail = send_Mail(Email, "Consec QR_Code Check In", mailtext, attach)
    
    If Dir(attach) = "" Then sendQR_mail = "nope"
      

End Function


