Public Sub LoadPositionszuordnung(lngAktKopfID As Long)
    Dim strSQL As String
    Dim iVA_ID As Long
    Dim iVADatum_ID As Long
    
    iVA_ID = Nz(DLookup("VA_ID", "tbl_VA_Akt_Objekt_Kopf", "ID = " & lngAktKopfID), 0)
    iVADatum_ID = Nz(DLookup("VADatum_ID", "tbl_VA_Akt_Objekt_Kopf", "ID = " & lngAktKopfID), 0)
    
    Call Set_Priv_Property("prp_VA_Akt_Objekt_ID", lngAktKopfID)
    
    ' Datum-Cbo befuellen mit allen Tagen des Auftrags
    strSQL = "SELECT t.ID, Format(t.VADatum,'ddd dd.mm.yyyy') AS Datum FROM tbl_VA_AnzTage t WHERE t.VA_ID = " & iVA_ID & " ORDER BY t.VADatum"
    forms!frm_N_MA_VA_Positionszuordnung!cboVADatum.RowSource = strSQL
    forms!frm_N_MA_VA_Positionszuordnung!cboVADatum = iVADatum_ID
    
    ' Mitarbeiter-Liste (links): MA_ID, Nr, von, bis, MA_Name
    strSQL = "SELECT z.MA_ID, z.PosNr AS Nr, Format(z.MVA_Start,'hh:nn') AS von, Format(z.MVA_Ende,'hh:nn') AS bis, " & _
             "m.[Nachname] & ' ' & m.[Vorname] AS MA_Name" & _
             " FROM tbl_MA_VA_Zuordnung z INNER JOIN tbl_MA_Mitarbeiterstamm m ON z.MA_ID = m.ID" & _
             " WHERE z.VA_ID = " & iVA_ID & " AND z.VADatum_ID = " & iVADatum_ID & _
             " AND z.MA_ID > 0" & _
             " AND z.MA_ID NOT IN (SELECT MA_ID FROM tbl_VA_Akt_Objekt_Pos_MA WHERE VA_Akt_Objekt_Kopf_ID = " & lngAktKopfID & " AND MA_ID > 0)" & _
             " ORDER BY m.Nachname, m.Vorname"
    
    forms!frm_N_MA_VA_Positionszuordnung!lstMA_Zusage.RowSource = strSQL
    forms!frm_N_MA_VA_Positionszuordnung!lstMA_Zusage.Requery
    
    ' Positionen-Liste (mitte)
    forms!frm_N_MA_VA_Positionszuordnung!List_Pos.RowSource = "qry_VA_Akt_Objekt_Pos"
    forms!frm_N_MA_VA_Positionszuordnung!List_Pos.Requery
    
    ' Zugewiesene Positionen (rechts)
    forms!frm_N_MA_VA_Positionszuordnung!Lst_MA_Zugeordnet.RowSource = "qry_VA_Akt_MA_Pos_Zuo_Alle"
    forms!frm_N_MA_VA_Positionszuordnung!Lst_MA_Zugeordnet.Requery
    
    ' Schichten-Liste (oben rechts) - falls vorhanden
    On Error Resume Next
    strSQL = "SELECT s.MA_Anzahl AS Anz, Format(s.VA_Start,'hh:nn') AS von, Format(s.VA_Ende,'hh:nn') AS bis " & _
             "FROM tbl_VA_Start s WHERE s.VA_ID = " & iVA_ID & " AND s.VADatum_ID = " & iVADatum_ID & _
             " ORDER BY s.VA_Start"
    forms!frm_N_MA_VA_Positionszuordnung!lstSchichten.RowSource = strSQL
    forms!frm_N_MA_VA_Positionszuordnung!lstSchichten.Requery
    forms!frm_N_MA_VA_Positionszuordnung!txtSummeAnz = Nz(DSum("MA_Anzahl", "tbl_VA_Start", "VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID), 0)
    On Error GoTo 0
End Sub

Public Sub LoadPositionszuordnungByDatum(lngVADatum_ID As Long)
    Dim lngVA_ID As Long
    Dim lngObjekt_ID As Long
    Dim lngAktKopfID As Long
    
    ' VA_ID aus aktuellem Kopf holen
    lngAktKopfID = Nz(forms!frm_N_MA_VA_Positionszuordnung!cbo_Akt_Objekt_Kopf, 0)
    If lngAktKopfID = 0 Then Exit Sub
    
    lngVA_ID = Nz(DLookup("VA_ID", "tbl_VA_Akt_Objekt_Kopf", "ID = " & lngAktKopfID), 0)
    lngObjekt_ID = Nz(DLookup("OB_Objekt_Kopf_ID", "tbl_VA_Akt_Objekt_Kopf", "ID = " & lngAktKopfID), 0)
    
    ' Pruefen ob fuer neues Datum bereits ein Kopf existiert
    lngAktKopfID = Nz(DLookup("ID", "tbl_VA_Akt_Objekt_Kopf", "VA_ID = " & lngVA_ID & " AND VADatum_ID = " & lngVADatum_ID), 0)
    
    If lngAktKopfID = 0 Then
        ' Neuen Kopf erstellen
        CurrentDb.Execute "INSERT INTO tbl_VA_Akt_Objekt_Kopf (VA_ID, VADatum_ID, VADatum, OB_Objekt_Kopf_ID) " & _
            "SELECT " & lngVA_ID & ", " & lngVADatum_ID & ", VADatum, " & lngObjekt_ID & " FROM tbl_VA_AnzTage WHERE ID = " & lngVADatum_ID
        
        lngAktKopfID = DMax("ID", "tbl_VA_Akt_Objekt_Kopf")
        
        ' Positionen kopieren
        CurrentDb.Execute "INSERT INTO tbl_VA_Akt_Objekt_Pos (VA_Akt_Objekt_Kopf_ID, OB_Objekt_Pos_ID, OB_Objekt_Kopf_ID, Sort, Gruppe, Zusatztext, Zusatztext2, Geschlecht, Anzahl, Rel_Beginn, Rel_Ende) " & _
            "SELECT " & lngAktKopfID & ", ID, OB_Objekt_Kopf_ID, Sort, Gruppe, Zusatztext, Zusatztext2, Geschlecht, Anzahl, Rel_Beginn, Rel_Ende FROM tbl_OB_Objekt_Positionen WHERE OB_Objekt_Kopf_ID = " & lngObjekt_ID
    End If
    
    ' Auftrag-Cbo aktualisieren
    forms!frm_N_MA_VA_Positionszuordnung!cbo_Akt_Objekt_Kopf.Requery
    forms!frm_N_MA_VA_Positionszuordnung!cbo_Akt_Objekt_Kopf = lngAktKopfID
    
    LoadPositionszuordnung lngAktKopfID
End Sub

Public Sub OpenPositionszuordnungFromAuftrag()
    Dim lngVA_ID As Long
    Dim lngVADatum_ID As Long
    Dim lngObjekt_ID As Long
    Dim lngAktKopfID As Long
    
    lngVA_ID = Nz(forms!frm_VA_Auftragstamm!ID, 0)
    lngVADatum_ID = Nz(forms!frm_VA_Auftragstamm!cboVADatum, 0)
    lngObjekt_ID = Nz(forms!frm_VA_Auftragstamm!Objekt_ID, 0)
    
    If lngVA_ID = 0 Then
        MsgBox "Bitte erst einen Auftrag auswaehlen!", vbExclamation
        Exit Sub
    End If
    
    If lngVADatum_ID = 0 Then
        MsgBox "Bitte erst ein Datum auswaehlen!", vbExclamation
        Exit Sub
    End If
    
    lngAktKopfID = Nz(DLookup("ID", "tbl_VA_Akt_Objekt_Kopf", "VA_ID = " & lngVA_ID & " AND VADatum_ID = " & lngVADatum_ID), 0)
    
    If lngAktKopfID = 0 Then
        If lngObjekt_ID = 0 Then
            MsgBox "Bitte erst ein Objekt auswaehlen!", vbExclamation
            Exit Sub
        End If
        
        CurrentDb.Execute "INSERT INTO tbl_VA_Akt_Objekt_Kopf (VA_ID, VADatum_ID, VADatum, OB_Objekt_Kopf_ID) " & _
            "SELECT " & lngVA_ID & ", " & lngVADatum_ID & ", VADatum, " & lngObjekt_ID & " FROM tbl_VA_AnzTage WHERE ID = " & lngVADatum_ID
        
        lngAktKopfID = DMax("ID", "tbl_VA_Akt_Objekt_Kopf")
        
        CurrentDb.Execute "INSERT INTO tbl_VA_Akt_Objekt_Pos (VA_Akt_Objekt_Kopf_ID, OB_Objekt_Pos_ID, OB_Objekt_Kopf_ID, Sort, Gruppe, Zusatztext, Zusatztext2, Geschlecht, Anzahl, Rel_Beginn, Rel_Ende) " & _
            "SELECT " & lngAktKopfID & ", ID, OB_Objekt_Kopf_ID, Sort, Gruppe, Zusatztext, Zusatztext2, Geschlecht, Anzahl, Rel_Beginn, Rel_Ende FROM tbl_OB_Objekt_Positionen WHERE OB_Objekt_Kopf_ID = " & lngObjekt_ID
    End If
    
    DoCmd.OpenForm "frm_N_MA_VA_Positionszuordnung"
    
    forms!frm_N_MA_VA_Positionszuordnung!cbo_Akt_Objekt_Kopf.Requery
    forms!frm_N_MA_VA_Positionszuordnung!cbo_Akt_Objekt_Kopf = lngAktKopfID
    
    LoadPositionszuordnung lngAktKopfID
End Sub

Public Sub OpenObjektPositionenFromAuftrag()
    Dim lngObjekt_ID As Long
    
    On Error Resume Next
    lngObjekt_ID = Nz(forms!frm_VA_Auftragstamm!Objekt_ID, 0)
    On Error GoTo 0
    
    If lngObjekt_ID = 0 Then
        MsgBox "Bitte erst ein Objekt auswaehlen!", vbExclamation
        Exit Sub
    End If
    
    ' Oeffne frm_OB_Objekt mit Filter auf das ausgewaehlte Objekt
    DoCmd.OpenForm "frm_OB_Objekt", , , "ID = " & lngObjekt_ID
    
    ' Setze Fokus auf Unterformular mit Positionen
    On Error Resume Next
    forms!frm_OB_Objekt!sub_OB_Objekt_Positionen.SetFocus
    On Error GoTo 0
End Sub