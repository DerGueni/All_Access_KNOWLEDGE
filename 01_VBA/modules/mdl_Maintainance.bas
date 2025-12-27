Attribute VB_Name = "mdl_Maintainance"
Option Compare Database
Option Explicit

' 1. Schritt
Function f_Zuord_Korrektur()

Sleep 20
DoEvents

'Alle Zuordnungen ohne korrekte Schicht-Zuordnung löschen
Call CurrentDb.Execute("Delete * FROM tbl_MA_VA_Zuordnung WHERE ID IN (SELECT Zuo_ID From qry_Falsche_Nr)")
'Alle Schichten ohne korrekte Zuordnung zu Tagen löschen
Call CurrentDb.Execute("DELETE tbl_VA_AnzTage.ID, tbl_VA_Start.* FROM tbl_VA_Start LEFT JOIN tbl_VA_AnzTage ON tbl_VA_Start.VADatum_ID = tbl_VA_AnzTage.ID WHERE (((tbl_VA_AnzTage.ID) Is Null));")

Sleep 20
DoEvents

'tbl_MA_NVerfuegZeiten: Korrektur der Zusatzwerte für Zeiten
Call CurrentDb.Execute("qry_MA_NVerfueg_ZeitUpdate")

Sleep 20
DoEvents

'tbl_MA_NVerfuegZeiten: Korrektur bei Mehrtagesabwesenheiten von Zeit auf 00:00 bis Zeit auf 23:59
Call CurrentDb.Execute("qry_MA_NVerfueg_ZeitUpdate_2")

Sleep 20
DoEvents

'fVA_AnzTage_Update
'fVAUpd_AllSI

End Function

'2. Schritt
Function f_Anfangs_Ende_Zeit_korrigieren()

CurrentDb.Execute ("UPDATE tbl_MA_VA_Zuordnung SET tbl_MA_VA_Zuordnung.MVA_Start = Startzeit_G([VADatum],[MA_Start]);")
CurrentDb.Execute ("UPDATE tbl_MA_VA_Planung SET tbl_MA_VA_Planung.MVA_Start = Startzeit_G([VADatum],[VA_Start]);")
CurrentDb.Execute ("UPDATE tbl_VA_Start SET tbl_VA_Start.MVA_Start = Startzeit_G([VADatum],[VA_Start]);")

Sleep 20
DoEvents

CurrentDb.Execute ("UPDATE tbl_MA_VA_Zuordnung SET tbl_MA_VA_Zuordnung.MVA_Ende = Endezeit_G([VADatum],[MA_Start],[MA_Ende]);")
CurrentDb.Execute ("UPDATE tbl_MA_VA_Planung SET tbl_MA_VA_Planung.MVA_Ende = Endezeit_G([VADatum],[VA_Start],[VA_Ende]);")
CurrentDb.Execute ("UPDATE tbl_VA_Start SET tbl_VA_Start.MVA_Ende = Endezeit_G([VADatum],[VA_Start],[VA_Ende]);")

CurrentDb.Execute ("UPDATE tbl_MA_VA_Planung SET tbl_MA_VA_Planung.VADatum = f_VAdat_Pl([VADatum_ID])")

CurrentDb.Execute ("UPDATE tbl_MA_Mitarbeiterstamm SET tbl_MA_Mitarbeiterstamm.IstSubunternehmer = True, tbl_MA_Mitarbeiterstamm.Anstellungsart_ID = 11 WHERE (((tbl_MA_Mitarbeiterstamm.IstSubunternehmer)=True)) OR (((tbl_MA_Mitarbeiterstamm.Anstellungsart_ID)=11));")

Sleep 20
DoEvents

End Function

'3. Schritt - Ist Anzahl MA bei allen Schichten und Tagen
Function f_Schicht_Tag_Anz_Ist_Korr(Optional bIstAutoFreigabe As Boolean = True)

Dim strSQL As String

' 1. Schritt
f_Zuord_Korrektur

'2. Schritt
f_Anfangs_Ende_Zeit_korrigieren

'qry_MA_Leere_Tageszusatzwerte_loeschen
CurrentDb.Execute ("qry_MA_Leere_Tageszusatzwerte_loeschen")

'Anzahl Ist MA pro Schicht
If table_exist("tbltmp_XXX_Schicht_Ist_Anz") Then DoCmd.DeleteObject acTable, "tbltmp_XXX_Schicht_Ist_Anz"
DoEvents

strSQL = ""
strSQL = strSQL & "SELECT tbl_MA_VA_Zuordnung.VAStart_ID, Count(tbl_MA_VA_Zuordnung.ID) AS AnzahlvonID INTO tbltmp_XXX_Schicht_Ist_Anz"
strSQL = strSQL & " FROM tbl_MA_VA_Zuordnung WHERE (((tbl_MA_VA_Zuordnung.MA_ID) > 0)) GROUP BY tbl_MA_VA_Zuordnung.VAStart_ID;"
CurrentDb.Execute (strSQL)
DoEvents

'tbl_VA_Start - Anazahl Ist pro Schicht Setzen
strSQL = ""
strSQL = "UPDATE tbltmp_XXX_Schicht_Ist_Anz INNER JOIN tbl_VA_Start ON tbltmp_XXX_Schicht_Ist_Anz.VAStart_ID = tbl_VA_Start.ID SET tbl_VA_Start.MA_Anzahl_Ist = [AnzahlvonID];"
CurrentDb.Execute (strSQL)
DoEvents

If table_exist("tbltmp_XXX_Schicht_Ist_Anz") Then DoCmd.DeleteObject acTable, "tbltmp_XXX_Schicht_Ist_Anz"
DoEvents

If table_exist("tbltmp_XXX_Tag_Ist_Anz") Then DoCmd.DeleteObject acTable, "tbltmp_XXX_Tag_Ist_Anz"
DoEvents

strSQL = ""
strSQL = strSQL & "SELECT tbl_MA_VA_Zuordnung.VADatum_ID, Count(tbl_MA_VA_Zuordnung.ID) AS AnzahlvonID INTO tbltmp_XXX_Tag_Ist_Anz"
strSQL = strSQL & " FROM tbl_MA_VA_Zuordnung WHERE (((tbl_MA_VA_Zuordnung.MA_ID) > 0)) GROUP BY tbl_MA_VA_Zuordnung.VADatum_ID;"
CurrentDb.Execute (strSQL)
DoEvents

'tbl_VA_AnzTage - Anzahl Ist MA pro Tag
strSQL = ""
strSQL = "UPDATE tbltmp_XXX_Tag_Ist_Anz INNER JOIN tbl_VA_AnzTage ON tbltmp_XXX_Tag_Ist_Anz.VADatum_ID = tbl_VA_AnzTage.ID SET tbl_VA_AnzTage.TVA_Ist = [AnzahlvonID];"
CurrentDb.Execute (strSQL)
DoEvents

If table_exist("tbltmp_XXX_Tag_Ist_Anz") Then DoCmd.DeleteObject acTable, "tbltmp_XXX_Tag_Ist_Anz"
DoEvents

'Anzahl Soll MA pro Tag
If table_exist("tbltmp_XXX_Tag_Soll_Anz") Then DoCmd.DeleteObject acTable, "tbltmp_XXX_Tag_Soll_Anz"
DoEvents

strSQL = ""
strSQL = strSQL & "SELECT tbl_VA_Start.VADatum_ID, Sum(tbl_VA_Start.MA_Anzahl) AS SummevonMA_Anzahl INTO tbltmp_XXX_Tag_Soll_Anz"
strSQL = strSQL & " FROM tbl_VA_Start GROUP BY tbl_VA_Start.VADatum_ID;"
CurrentDb.Execute (strSQL)
DoEvents

'tbl_VA_AnzTage Auftrags Ist setzen
strSQL = ""
strSQL = "UPDATE tbltmp_XXX_Tag_Soll_Anz INNER JOIN tbl_VA_AnzTage ON tbltmp_XXX_Tag_Soll_Anz.VADatum_ID = tbl_VA_AnzTage.ID SET tbl_VA_AnzTage.TVA_SOll = [SummevonMA_Anzahl];"
CurrentDb.Execute (strSQL)
DoEvents
'######################

If table_exist("tbltmp_XXX_Tag_Soll_Anz") Then DoCmd.DeleteObject acTable, "tbltmp_XXX_Tag_Soll_Anz"
DoEvents

'Auftrag pro Tag abgeschlossen
'tbl_VA_AnzTage Auftrags Soll und Abgeschlossen setzen
'Alle Aufträge mit Null als Soll auf "0" setzen
CurrentDb.Execute ("UPDATE tbl_VA_AnzTage SET tbl_VA_AnzTage.TVA_Soll = 0 WHERE (((tbl_VA_AnzTage.TVA_Soll) Is Null));")

'Alle Aufträge sind offen
CurrentDb.Execute ("UPDATE tbl_VA_AnzTage SET tbl_VA_AnzTage.TVA_Offen = True;")

'Alle Aufträge pro Tag auf geschlossen setzen, wenn ist - soll >= 0 und soll > 0
CurrentDb.Execute ("UPDATE tbl_VA_AnzTage SET tbl_VA_AnzTage.TVA_Offen = False WHERE (((tbl_VA_AnzTage.TVA_Soll)>0) AND ((Nz([TVA_Ist],0)-[TVA_Soll])>=0));")
'###################

'tbltmp_XXX_Veranst_Status_Setzen

If table_exist("tbltmp_XXX_VA_Alle_Status") Then DoCmd.DeleteObject acTable, "tbltmp_XXX_VA_Alle_Status"
DoEvents

If table_exist("tbltmp_XXX_VA_Alle_Status_Aus_Tag") Then DoCmd.DeleteObject acTable, "tbltmp_XXX_VA_Alle_Status_Aus_Tag"
DoEvents

'Temp Tabelle Auftrag erzeugen
CurrentDb.Execute ("SELECT tbl_VA_Auftragstamm.ID, tbl_VA_Auftragstamm.Veranst_Status_ID, 1 AS Status_Soll, 0 AS Status_Zeit INTO tbltmp_XXX_VA_Alle_Status FROM tbl_VA_Auftragstamm;")
DoEvents

'Temp Tabelle Auftrag mit nur abgeschlossenen Schichten erzeugen
CurrentDb.Execute ("SELECT tbl_VA_AnzTage.VA_ID, Sum(tbl_VA_AnzTage.TVA_Offen) AS SummevonTVA_Offen INTO tbltmp_XXX_VA_Alle_Status_Aus_Tag FROM tbl_VA_AnzTage GROUP BY tbl_VA_AnzTage.VA_ID HAVING (((Sum(tbl_VA_AnzTage.TVA_Offen))=0));")
DoEvents

'Temp Tabelle Auftrag Update abgeschlossene Schichten
CurrentDb.Execute ("UPDATE tbltmp_XXX_VA_Alle_Status_Aus_Tag INNER JOIN tbltmp_XXX_VA_Alle_Status ON tbltmp_XXX_VA_Alle_Status_Aus_Tag.VA_ID = tbltmp_XXX_VA_Alle_Status.ID SET tbltmp_XXX_VA_Alle_Status.Status_Soll = 2;")
DoEvents

'Temp Tabelle Auftrag Update auf abgeschlossene Zeiten setzen, wenn Schichten abgeschlossen
CurrentDb.Execute ("UPDATE tbltmp_XXX_VA_Alle_Status INNER JOIN tbl_MA_VA_Zuordnung ON tbltmp_XXX_VA_Alle_Status.ID = tbl_MA_VA_Zuordnung.VA_ID SET tbltmp_XXX_VA_Alle_Status.Status_Zeit = 3 WHERE (((tbltmp_XXX_VA_Alle_Status.Status_Soll)=2) AND ((Len(Trim(Nz([MA_Ende]))))>0));")
DoEvents

'Temp Tabelle - Verhindern, dass Aufträge freigegeben werden, bei denen kein Auftraggeber eingetragen ist.
CurrentDb.Execute ("UPDATE tbltmp_XXX_VA_Alle_Status INNER JOIN tbl_VA_Auftragstamm ON tbltmp_XXX_VA_Alle_Status.ID = tbl_VA_Auftragstamm.ID SET tbltmp_XXX_VA_Alle_Status.Status_Zeit = 0 WHERE (((tbltmp_XXX_VA_Alle_Status.Status_Zeit)=3) AND ((Nz(tbl_VA_Auftragstamm.Veranstalter_ID,0)=0)));")
DoEvents

'Temp Tabelle - Verhindern, dass Aufträge freigegeben werden, bei denen noch nicht alle Zeiten gesetzt sind
CurrentDb.Execute ("UPDATE tbltmp_XXX_VA_Alle_Status INNER JOIN tbl_MA_VA_Zuordnung ON tbltmp_XXX_VA_Alle_Status.ID = tbl_MA_VA_Zuordnung.VA_ID SET tbltmp_XXX_VA_Alle_Status.Status_Zeit = 0 WHERE (((Len(Trim(Nz([MA_Start]))))=0) AND ((tbltmp_XXX_VA_Alle_Status.Status_Zeit)=3)) OR (((Len(Trim(Nz([MA_Ende]))))=0) AND ((tbltmp_XXX_VA_Alle_Status.Status_Zeit)=3));")
DoEvents

'Temp Tabelle - Verhindern, dass Aufträge freigegeben werden, bei denen noch nicht alle Tage in der Vergangenheit liegen
CurrentDb.Execute ("UPDATE tbl_VA_AnzTage INNER JOIN tbltmp_XXX_VA_Alle_Status ON tbl_VA_AnzTage.VA_ID = tbltmp_XXX_VA_Alle_Status.ID SET tbltmp_XXX_VA_Alle_Status.Status_Zeit = 0 WHERE (((tbl_VA_AnzTage.VADatum)>=Date()));")
DoEvents

'Update tbl_VA_Auftragstamm
'Auftrag auf Status 1 'in Planung' bzw 2 'abgeschlossen' setzen
CurrentDb.Execute ("UPDATE tbl_VA_Auftragstamm INNER JOIN tbltmp_XXX_VA_Alle_Status ON tbl_VA_Auftragstamm.ID = tbltmp_XXX_VA_Alle_Status.ID SET tbl_VA_Auftragstamm.Veranst_Status_ID = [Status_Soll] WHERE (((tbl_VA_Auftragstamm.Veranst_Status_ID)<4));")
DoEvents

'Update tbl_VA_Auftragstamm
'Wenn Auto-Freigabe erfolgen soll, alle abgeschlossenen Aufträge auf 'Freigabe' setzen, wenn alle Zeiten gefüllt UND der Auftraggeber gesetzt ist
If bIstAutoFreigabe Then
    CurrentDb.Execute ("UPDATE tbl_VA_Auftragstamm INNER JOIN tbltmp_XXX_VA_Alle_Status ON tbl_VA_Auftragstamm.ID = tbltmp_XXX_VA_Alle_Status.ID SET tbl_VA_Auftragstamm.Veranst_Status_ID = [Status_Zeit] WHERE (((tbl_VA_Auftragstamm.Veranst_Status_ID)<4) AND ((tbltmp_XXX_VA_Alle_Status.Status_Zeit)=3));")
    DoEvents
End If
'##########################

If table_exist("tbltmp_XXX_VA_Alle_Status") Then DoCmd.DeleteObject acTable, "tbltmp_XXX_VA_Alle_Status"
DoEvents
'
If table_exist("tbltmp_XXX_VA_Alle_Status_Aus_Tag") Then DoCmd.DeleteObject acTable, "tbltmp_XXX_VA_Alle_Status_Aus_Tag"
DoEvents

MsgBox " Alle Auftragsstati < 4 korrigiert, d.h. 'Planung' 'Vollständig Disponiert' und 'Abgeschlossen' (nur wenn gewünscht) wurden gesetzt"

End Function

Function f_KD_Adr_Korrektur()
'qry_KD_Adresse_Korr
Dim db As DAO.Database
Dim rst As DAO.Recordset

Dim s As String
Dim s1 As String

'qry_KD_Adresse_Korr
'Field Name
'==========
' 0            kun_Id         4            Long Integer
' 1            kun_Firma      10           Text
' 2            kun_Bezeichnung              10           Text
' 3            adr_Name1      10           Text
' 4            kun_Strasse    10           Text
' 5            kun_PLZ        10           Text
' 6            kun_Ort        10           Text
' 7            kun_BriefKopf  12           Memo
' 8            kun_LKZ        10           Text
' 9            Landesname_deu               10           Text

Set db = CurrentDb
Set rst = db.OpenRecordset("qry_KD_Adresse_Korr")
With rst
    Do Until .EOF
        .Edit
            s = .fields("kun_Firma")
            s1 = Nz(.fields("kun_Bezeichnung"))
            If Len(Trim(Nz(s1))) > 0 Then
                s = s & vbCrLf & s1
            End If
            s1 = Nz(.fields("adr_Name1"))
            If Len(Trim(Nz(s1))) > 0 Then
                s = s & vbCrLf & s1
            End If
            s1 = Nz(.fields("kun_Strasse"))
            If Len(Trim(Nz(s1))) > 0 Then
                s = s & vbCrLf & s1 & vbCrLf
            End If
            s1 = Nz(.fields("kun_PLZ"))
            If Len(Trim(Nz(s1))) > 0 Then
                s = s & vbCrLf & s1 & " "
            End If
            s1 = Nz(.fields("kun_Ort"))
            If Len(Trim(Nz(s1))) > 0 Then
                s = s & s1
            End If
            s1 = Nz(.fields("kun_LKZ"))
            If Len(Trim(Nz(s1))) > 0 Then
                If UCase(s1) <> "DE" Then
                    s1 = Nz(.fields("Landesname_deu"))
                    If Len(Trim(Nz(s1))) > 0 Then
                        s = s & vbCrLf & s1 & " "
                    End If
                End If
            End If
            .fields("kun_BriefKopf").Value = s
        .update
        .MoveNext
    Loop
    .Close
End With
Set rst = Nothing
MsgBox "Briefköpfe der Kunden wurden aktualisiert"

End Function

Function f_MA_Adr_Korrektur()
Dim db As DAO.Database
Dim rst As DAO.Recordset

Dim s As String
Dim s1 As String
Dim s2 As String

'qry_MA_Adresskorrektur
'Field Name
'==========
' 0            ID             4            Long Integer
' 1            Anr            10           Text
' 2            Name           10           Text
' 3            Strasse        10           Text
' 4            Nr             10           Text
' 5            PLZOrt         10           Text
' 6            Briefkopf      12           Memo
'==========
Set db = CurrentDb
Set rst = db.OpenRecordset("qry_MA_Adresskorrektur")
With rst
    Do Until .EOF
        .Edit
            s = Nz(.fields("Anr"))
            s1 = Nz(.fields("Name"))
            If Len(Trim(Nz(s1))) > 0 Then
                s = s & vbCrLf & s1
            End If
            s2 = Nz(.fields("Nr"))
            s1 = Nz(.fields("Strasse"))
            If Len(Trim(Nz(s2))) > 0 And Len(Trim(Nz(s1))) > 0 Then
                If Right(s1, Len(s2)) = s2 Then s2 = ""
            End If
            s1 = s1 + " " + s2
            If Len(Trim(Nz(s1))) > 0 Then
                s = s & vbCrLf & s1
            End If
            s1 = Nz(.fields("PLZOrt"))
            If Len(Trim(Nz(s1))) > 0 Then
                s = s & vbCrLf & vbCrLf & s1
            End If
            .fields("BriefKopf").Value = s
        .update
        .MoveNext
    Loop
    .Close
End With
Set rst = Nothing
MsgBox "Briefköpfe der Mitarbeiter wurden aktualisiert"

End Function




Function fExcel_Vorlagen_Schreiben()

Dim sysPfad As String
Dim DocPfad As String
Dim DocVorlage As String

Dim strSQL As String

DocPfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 12"))
DocVorlage = DocPfad & "VORLAGE_EINSATZLISTE.xls"
Call BinExport("___Vorlagen_einlesen", DocVorlage, "Picture", 9)
Call Set_Priv_Property("prp_XL_DocVorlage", DocVorlage)

Sleep 20
DoEvents

DocPfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 12"))
DocVorlage = DocPfad & "Vorlage_Dienstplanübersicht_Objekte.xls"
Call BinExport("___Vorlagen_einlesen", DocVorlage, "Picture", 12)
Call Set_Priv_Property("prp_XL_DienstObjVorlage", DocVorlage)

Sleep 20
DoEvents

DocPfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 12"))
DocVorlage = DocPfad & "Vorlage_Dienstplanübersicht_MA.xls"
Call BinExport("___Vorlagen_einlesen", DocVorlage, "Picture", 11)
Call Set_Priv_Property("prp_XL_DienstMAVorlage", DocVorlage)

Sleep 20
DoEvents

DocPfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 12"))
DocVorlage = DocPfad & "Vorlage_Dienstplan_Mitarbeiter_einzeln_pro_KW.xls"
Call BinExport("___Vorlagen_einlesen", DocVorlage, "Picture", 13)
Call Set_Priv_Property("prp_XL_DienstMAVorlage_Einzel", DocVorlage)

Sleep 20
DoEvents

End Function
