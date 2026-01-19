Attribute VB_Name = "mdl_CONSEC_eMail_Autoimport"
Option Compare Database
Option Explicit


Function f_eMail_Test()

All_eMail_Update
If Manuelle_eMail_MA_Zuordnung() = False Then
    MsgBox "Keine manuelle eMail-Zuordnung erforderlich"
End If

End Function

Function All_eMail_Update()

Dim i As Long

'Alle einträge ohne "Intern:" im Betreff als Schrott kennzeichnen
CurrentDb.Execute ("qry_eMail_Update99_Rest_ohne_Intern")

'Alle Einträge von Consec selbst ignorieren
CurrentDb.Execute ("qry_eMail_Update90_Sender_Consec")

' Alle Einträge von Vorgestern und früher löschen - keine Leichen
CurrentDb.Execute ("qry_eMail_Delete_OldDate")

'Absage tbl_eMail_Import Feld Zu_Absage = 0
CurrentDb.Execute ("qry_Email_finden_Absage")
'Zusage tbl_eMail_Import Feld Zu_Absage = -1
CurrentDb.Execute ("qry_Email_finden_Zusage")

DoEvents
' Datensätze, die keine Zu- oder Absagen sind, löschen (Datensätze, die im Betreff kein "intern:" beinhalten)
CurrentDb.Execute ("qry_eMail_Delete_Rest")
DoEvents

'MA_ID, VA_ID, VADatum_ID, VAStart_ID setzen
CurrentDb.Execute ("qry_eMail_finden_MA_VA_Zuordnung")
DoEvents

'tbl_MA_VA_Planung update
CurrentDb.Execute ("qry_eMail_Update_Absage")

'tbl_MA_VA_Planung update
CurrentDb.Execute ("qry_eMail_Update_Zusage")

'tbl_MA_VA_Zuordnung update
All_eMail_tbl_MA_VA_Zuordnung_Merge

'Alle Zugeordneten löschen
CurrentDb.Execute ("DELETE * FROM tbl_eMail_Import WHERE MA_ID > 0 AND Zu_Absage > -2;")

'Alle Zugeordneten auf "Erledigt" setzen
CurrentDb.Execute ("qry_eMail_Update_Erledigt")

If isFormLoad("frm_VA_Auftragstamm") Then Forms!frm_VA_Auftragstamm.Requery
If isFormLoad("frm_MA_VA_Schnellauswahl") Then Forms!frm_MA_VA_Schnellauswahl.Requery

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

End Function


Function Manuelle_eMail_MA_Zuordnung() As Boolean

Dim i As Long
Dim j As Long

    Manuelle_eMail_MA_Zuordnung = False

    'Nicht zuordenbare eMails manuell zuordnen
    i = Nz(TCount("*", "qry_eMail_MA_ID_not_found"), 0)
    j = Nz(TCount("*", "tbl_eMail_Import", "IstErledigt = 0"), 0)
    
    If i > 0 Or j > 0 Then
        Manuelle_eMail_MA_Zuordnung = True
        DoCmd.OpenForm "frmTop_eMail_MA_ID_NGef"
    End If

End Function

'-------- interne Funktionen

Function All_eMail_tbl_MA_VA_Zuordnung_Merge()
Dim iZuo As Long
Dim snetto As Single
Dim iPosNr As Long
Dim iZuo1 As Long
Dim iVA_ID As Long
Dim iVADatum_ID As Long
Dim iVAStart_ID As Long
Dim iMA_ID As Long

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long

Dim strSQL As String

recsetSQL1 = "SELECT VA_ID, VADatum_ID, VAStart_ID, MA_ID FROM qry_eMail_Grouping_Zusage WHERE Zu_Absage = -1;"
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
If ArrFill_DAO_OK1 Then
    For iZl = 0 To iZLMax1

        iVA_ID = Nz(DAOARRAY1(0, iZl), 0)
        iVADatum_ID = Nz(DAOARRAY1(1, iZl), 0)
        iVAStart_ID = Nz(DAOARRAY1(2, iZl), 0)
        iMA_ID = Nz(DAOARRAY1(3, iZl), 0)

        'Zuordnung vorhanden - update
        iZuo1 = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID & " AND VAStart_ID = " & iVAStart_ID & " AND MA_ID = 0"), 0)
        If iZuo1 > 0 Then
            iZuo = Nz(TLookup("ID", "tbl_MA_VA_Zuordnung", "VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID & " AND VAStart_ID = " & iVAStart_ID & " AND MA_ID = 0"), 0)
            If iZuo1 > 0 Then
                snetto = Nz(TLookup("MA_Netto_Std2", "tbl_MA_VA_Zuordnung", "ID = " & iZuo), 0)
                iPosNr = Nz(TLookup("PosNr", "tbl_MA_VA_Zuordnung", "ID = " & iZuo), 0)
            
                strSQL = ""
                strSQL = strSQL & "UPDATE tbl_MA_VA_Zuordnung, tbl_MA_VA_Planung SET"
                strSQL = strSQL & " tbl_MA_VA_Zuordnung.MA_ID = " & iMA_ID & ", "
                strSQL = strSQL & " tbl_MA_VA_Zuordnung.RL_34a = " & str(fctround(RL34a_pro_Std(iMA_ID) * snetto)) & ", "
                strSQL = strSQL & " tbl_MA_VA_Zuordnung.Aend_von = '" & atCNames(1) & "', "
                strSQL = strSQL & " tbl_MA_VA_Zuordnung.Aend_am = Now()"
                strSQL = strSQL & " WHERE (((tbl_MA_VA_Zuordnung.ID)= " & iZuo & "));"
                
                CurrentDb.Execute (strSQL)
                
                'tbl_VA_AnzTage Updaten
                DoEvents
                Call VA_AnzTage_Upd(iVA_ID, iVADatum_ID)
                DoEvents
            End If
            
        Else
            iZuo = Nz(TLookup("ID", "tbl_MA_VA_Zuordnung", "VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID & " AND VAStart_ID = " & iVAStart_ID), 0)
            If iZuo > 0 Then
                iPosNr = Nz(TMax("PosNr", "tbl_MA_VA_Zuordnung", "VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID), 0) + 1
                strSQL = ""
                strSQL = strSQL & "INSERT INTO tbl_MA_VA_Zuordnung ( VA_ID, VADatum_ID, VAStart_ID, PosNr, MA_ID, MA_Start, MA_Ende, MA_Brutto_Std2,"
                strSQL = strSQL & " MA_Netto_Std2, RL_34a, Erst_von, Erst_am, Aend_von, Aend_am, VADatum, MVA_Start, MVA_Ende )"
                strSQL = strSQL & " SELECT tbl_MA_VA_Zuordnung.VA_ID, tbl_MA_VA_Zuordnung.VADatum_ID, tbl_MA_VA_Zuordnung.VAStart_ID, " & iPosNr & " AS Ausdr1,"
                strSQL = strSQL & " tbl_MA_VA_Zuordnung.MA_ID, tbl_MA_VA_Zuordnung.MA_Start, tbl_MA_VA_Zuordnung.MA_Ende,"
                strSQL = strSQL & " tbl_MA_VA_Zuordnung.MA_Brutto_Std2, tbl_MA_VA_Zuordnung.MA_Netto_Std2,"
                strSQL = strSQL & " tbl_MA_VA_Zuordnung.RL_34a, tbl_MA_VA_Zuordnung.Erst_von, tbl_MA_VA_Zuordnung.Erst_am, tbl_MA_VA_Zuordnung.Aend_von,"
                strSQL = strSQL & " tbl_MA_VA_Zuordnung.Aend_am , tbl_MA_VA_Zuordnung.VADatum, tbl_MA_VA_Zuordnung.MVA_Start, tbl_MA_VA_Zuordnung.MVA_Ende"
                strSQL = strSQL & " FROM tbl_MA_VA_Zuordnung WHERE (((tbl_MA_VA_Zuordnung.ID)= " & iZuo & "));"
    
                CurrentDb.Execute (strSQL)
                
                DoEvents
                iZuo = Nz(TLookup("ID", "tbl_MA_VA_Zuordnung", "VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID & " AND VAStart_ID = " & iVAStart_ID & " AND PosNr = " & iPosNr), 0)
                If iZuo > 0 Then
                    strSQL = ""
                    strSQL = strSQL & "UPDATE tbl_MA_VA_Zuordnung, tbl_MA_VA_Planung SET"
                    strSQL = strSQL & " tbl_MA_VA_Zuordnung.MA_ID = " & iMA_ID & ", "
                    strSQL = strSQL & " tbl_MA_VA_Zuordnung.RL_34a = " & str(fctround(RL34a_pro_Std(iMA_ID) * snetto)) & ", "
                    strSQL = strSQL & " tbl_MA_VA_Zuordnung.Aend_von = '" & atCNames(1) & "', "
                    strSQL = strSQL & " tbl_MA_VA_Zuordnung.Aend_am = Now()"
                    strSQL = strSQL & " WHERE (((tbl_MA_VA_Zuordnung.ID)= " & iZuo & "));"
                    
                    CurrentDb.Execute (strSQL)
                    
                    'tbl_VA_AnzTage Updaten
                    DoEvents
                    Call VA_AnzTage_Upd(iVA_ID, iVADatum_ID)
                End If
                DoEvents
            End If
        
        End If

    Next iZl
    Set DAOARRAY1 = Nothing
End If

End Function

Function xemltst()
Debug.Print eMail_Ausles(1, "RE: CONSEC Dienstanfrage -  Di 15.12.2015  - email test email test email test    - Intern: 567 - 132127 - 2215", "siegert@consec-nuernberg.de")
Debug.Print eMail_Ausles(2, "RE: CONSEC Dienstanfrage -  Di 15.12.2015  - email test email test email test    - Intern: 567 - 132127 - 2215", "siegert@consec-nuernberg.de")
Debug.Print eMail_Ausles(3, "RE: CONSEC Dienstanfrage -  Di 15.12.2015  - email test email test email test    - Intern: 567 - 132127 - 2215", "siegert@consec-nuernberg.de")
Debug.Print eMail_Ausles(4, "RE: CONSEC Dienstanfrage -  Di 15.12.2015  - email test email test email test    - Intern: 567 - 132127 - 2215", "siegert@consec-nuernberg.de")
End Function

'Function für Query qry_eMail_finden_MA_VA_Zuordnung
Function eMail_Ausles(iTyp As Long, strbody As String, strSender As String) As Variant

'ITyp = 1 = iMA_ID
'iTyp = 2 = iVA_ID
'iTyp = 3 = iVADatum_ID
'iTyp = 4 = iVAStart_ID

'Intern:  203 -  363 -  317 - kobd@gmx.de
'Intern:  iVA_ID - iVADatum_ID - iVAStart_ID

'"    - intern: " & iVA_ID & " - " & iVADatum_ID & " - " & iVAStart_ID
'"    - intern: " & 1234 & " - " & 5678 & " - " & 9012
'"    - intern: 1234 - 5678 - 9012"

Const CONST_INTERN As String = "Intern:"

Dim iMA_ID As Long
Dim iVA_ID As Long
Dim iVADatum_ID As Long
Dim iVAStart_ID As Long
Dim bIsOK As Boolean
Dim iRueck(2) As Long
Dim s As String
Dim s1 As String
Dim il As Long

Dim i As Long, j As Long, k As Long
Dim sx As String

bIsOK = False
    
il = Len(CONST_INTERN)
i = InStr(1, strbody, CONST_INTERN, vbTextCompare)

For k = 0 To 2
    iRueck(k) = 0
Next k

If i > 0 Then
    
    s = Mid(strbody, i + il, 35)
'    Debug.Print "Start: " & s
    For k = 0 To 2
        j = InStr(1, s, " - ", vbTextCompare)
        If j > 0 Then
            sx = Left(s, j)
'            Debug.Print "sx: " & sx
            iRueck(k) = CLng(Trim(sx))
            s = Mid(s, j + 3)
'            Debug.Print k, iRueck(k), s
        End If
    Next k
    iRueck(2) = s
    bIsOK = True
End If

Select Case iTyp
    Case 1
        iMA_ID = Nz(TLookup("MA_ID", "qry_ReplayEmail", "Email = '" & strSender & "'"), 0)
        eMail_Ausles = iMA_ID
    
    Case 2, 3, 4
        If bIsOK Then
            eMail_Ausles = Nz(iRueck(iTyp - 2), 0)
        End If
    
    Case Else
End Select

End Function
