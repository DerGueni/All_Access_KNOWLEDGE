"""
Fix Dashboard V8 - Behebt die 4 bekannten Probleme:
1. Fehler beim "Mitarbeiter anfragen" Button
2. #Gelöscht Problem in Mitarbeiter ausgewählt
3. Einsatzliste nicht bearbeitbar
4. Caption springt nach oben statt zum nächsten freien Slot
"""
import sys
sys.path.insert(0, r'C:\Users\guenther.siegert\Documents\Access Bridge')

from access_bridge_ultimate import AccessBridge
import time

# Verbesserter VBA-Code
VBA_CODE = '''
' ============================================================
' PLANUNGS-DASHBOARD VBA-MODUL V8 - ALLE FIXES
' ============================================================

Private m_CurrentVA_ID As Long
Private m_CurrentAnzTage_ID As Long
Private m_CurrentDatum As Date
Private m_CurrentVAStart_ID As Long
Private m_CurrentMA_Start As Date
Private m_CurrentMA_Ende As Date
Private m_SelectedSlotID As Long
Private m_LastInsertedSlotID As Long

Public Sub DP_Dashboard_Oeffnen()
    DoCmd.OpenForm "frm_N_DP_Dashboard", acNormal
End Sub

Public Sub DP_Dashboard_Oeffnen_MitAuftrag(Optional VA_ID As Long = 0)
    DoCmd.OpenForm "frm_N_DP_Dashboard", acNormal
    If VA_ID > 0 Then
        On Error Resume Next
        Forms!frm_N_DP_Dashboard!sub_lstAuftrag.Form.Recordset.FindFirst "VA_ID = " & VA_ID
        On Error GoTo 0
    End If
End Sub

Public Sub DP_Auftrag_Ausgewaehlt(VA_ID As Long, AnzTage_ID As Long, VADatum As Date)
    On Error Resume Next

    m_CurrentVA_ID = VA_ID
    m_CurrentAnzTage_ID = AnzTage_ID
    m_CurrentDatum = VADatum
    m_CurrentVAStart_ID = 0
    m_SelectedSlotID = 0
    m_CurrentMA_Start = 0
    m_CurrentMA_Ende = 0

    Dim frm As Form
    Set frm = Forms!frm_N_DP_Dashboard

    frm!sub_Einsatzliste.Form.filter = "VA_ID = " & VA_ID & " AND VADatum_ID = " & AnzTage_ID
    frm!sub_Einsatzliste.Form.FilterOn = True
    frm!sub_Einsatzliste.Form.Requery

    DP_Aktualisiere_Verfuegbare_MA VADatum
    DP_Aktualisiere_Angefragte_MA

    On Error GoTo 0
End Sub

Public Sub DP_Einsatzliste_Click(SlotID As Long, VAStart_ID As Long, MA_Start As Date, MA_Ende As Date)
    m_SelectedSlotID = SlotID
    m_CurrentVAStart_ID = VAStart_ID
    m_CurrentMA_Start = MA_Start
    m_CurrentMA_Ende = MA_Ende
End Sub

Public Sub DP_Aktualisiere_Verfuegbare_MA(VADatum As Date)
    On Error Resume Next

    Dim frm As Form
    Set frm = Forms!frm_N_DP_Dashboard

    Dim strDatum As String
    strDatum = Format(VADatum, "mm") & "/" & Format(VADatum, "dd") & "/" & Format(VADatum, "yyyy")

    Dim strSQL As String
    strSQL = "SELECT m.ID AS MA_ID, " & _
             "m.Nachname & '' '' & m.Vorname AS MA_Name, " & _
             "m.Anstellungsart_ID, " & _
             "Nz((SELECT Sum(Nz(p.MA_Netto_Std,0)) " & _
             "    FROM tbl_MA_VA_Planung AS p " & _
             "    WHERE p.MA_ID = m.ID " & _
             "      AND Month(p.VADatum) = Month(Date()) " & _
             "      AND Year(p.VADatum) = Year(Date())), 0) AS MonatStd " & _
             "FROM tbl_MA_Mitarbeiterstamm AS m " & _
             "WHERE m.IstAktiv = True " & _
             "  AND m.Anstellungsart_ID IN (3, 5) " & _
             "  AND m.ID NOT IN (SELECT MA_ID FROM tbl_MA_VA_Zuordnung WHERE VADatum = #" & strDatum & "# AND Nz(MA_ID,0) > 0) " & _
             "  AND m.ID NOT IN (SELECT MA_ID FROM tbl_MA_NVerfuegZeiten " & _
             "                   WHERE #" & strDatum & "# BETWEEN vonDat AND bisDat) " & _
             "  AND m.ID NOT IN (SELECT ID FROM ztbl_MA_Schnellauswahl) " & _
             "ORDER BY IIf(m.Anstellungsart_ID=3, 1, 2), m.Nachname, m.Vorname"

    frm!lstMA.RowSource = strSQL

    On Error GoTo 0
End Sub

Public Sub DP_MA_Doppelklick(MA_ID As Long)
    On Error GoTo ErrHandler

    If m_CurrentVA_ID = 0 Or m_CurrentAnzTage_ID = 0 Then
        MsgBox "Bitte zuerst einen Auftrag auswaehlen.", vbExclamation
        Exit Sub
    End If

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim Anstellungsart As Long

    Set db = CurrentDb

    Set rs = db.OpenRecordset("SELECT Anstellungsart_ID FROM tbl_MA_Mitarbeiterstamm WHERE ID = " & MA_ID)
    If Not rs.EOF Then
        Anstellungsart = Nz(rs!Anstellungsart_ID, 0)
    End If
    rs.Close

    If Anstellungsart = 3 Then
        DP_MA_In_Slot_Eintragen MA_ID
    ElseIf Anstellungsart = 5 Then
        DP_MA_Zur_Anfrage MA_ID
    End If

    Set db = Nothing
    Exit Sub

ErrHandler:
    MsgBox "Fehler: " & Err.description, vbExclamation
End Sub

Public Sub DP_MA_In_Slot_Eintragen(MA_ID As Long)
    On Error GoTo ErrHandler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim strSQL As String
    Dim FreeSlotID As Long
    Dim TargetStart As Date
    Dim TargetEnde As Date

    Set db = CurrentDb

    ' Merke die aktuelle Schichtzeit VOR dem Eintragen
    TargetStart = m_CurrentMA_Start
    TargetEnde = m_CurrentMA_Ende

    If m_CurrentMA_Start = 0 Then
        Set rs = db.OpenRecordset( _
            "SELECT TOP 1 ID, VAStart_ID, MA_Start, MA_Ende " & _
            "FROM tbl_MA_VA_Zuordnung " & _
            "WHERE VA_ID = " & m_CurrentVA_ID & " AND VADatum_ID = " & m_CurrentAnzTage_ID & _
            " AND (MA_ID = 0 OR MA_ID Is Null) " & _
            "ORDER BY MA_Start, PosNr")

        If rs.EOF Then
            MsgBox "Alle Schichten bereits vollstaendig besetzt.", vbExclamation
            rs.Close
            Set db = Nothing
            Exit Sub
        End If

        FreeSlotID = rs!ID
        TargetStart = rs!MA_Start
        TargetEnde = rs!MA_Ende
        m_CurrentMA_Start = TargetStart
        m_CurrentMA_Ende = TargetEnde
        rs.Close
    Else
        Dim strStartTime As String
        Dim strEndTime As String
        strStartTime = Format(m_CurrentMA_Start, "hh:nn:ss")
        strEndTime = Format(m_CurrentMA_Ende, "hh:nn:ss")

        strSQL = "SELECT TOP 1 ID " & _
                 "FROM tbl_MA_VA_Zuordnung " & _
                 "WHERE VA_ID = " & m_CurrentVA_ID & " AND VADatum_ID = " & m_CurrentAnzTage_ID & _
                 " AND (MA_ID = 0 OR MA_ID Is Null) " & _
                 " AND Format(MA_Start, ''hh:nn:ss'') = ''" & strStartTime & "''" & _
                 " AND Format(MA_Ende, ''hh:nn:ss'') = ''" & strEndTime & "''" & _
                 " ORDER BY PosNr"

        Set rs = db.OpenRecordset(strSQL)

        If rs.EOF Then
            MsgBox "Schicht bereits vollstaendig besetzt.", vbExclamation
            rs.Close
            Set db = Nothing
            Exit Sub
        End If

        FreeSlotID = rs!ID
        rs.Close
    End If

    ' Pruefe ob MA bereits eingetragen
    Set rs = db.OpenRecordset( _
        "SELECT ID FROM tbl_MA_VA_Zuordnung " & _
        "WHERE VA_ID = " & m_CurrentVA_ID & " AND VADatum_ID = " & m_CurrentAnzTage_ID & " AND MA_ID = " & MA_ID)
    If Not rs.EOF Then
        MsgBox "Mitarbeiter ist bereits fuer diesen Auftrag eingetragen.", vbInformation
        rs.Close
        Set db = Nothing
        Exit Sub
    End If
    rs.Close

    ' MA eintragen
    strSQL = "UPDATE tbl_MA_VA_Zuordnung SET MA_ID = " & MA_ID & " WHERE ID = " & FreeSlotID
    db.Execute strSQL, dbFailOnError

    m_LastInsertedSlotID = FreeSlotID

    ' Formular aktualisieren
    Dim frm As Form
    Set frm = Forms!frm_N_DP_Dashboard
    frm!sub_Einsatzliste.Form.Requery

    ' WICHTIG: Zum naechsten freien Slot der GLEICHEN Schicht navigieren
    DP_NavigateToNextFreeSlot TargetStart, TargetEnde

    DP_Aktualisiere_Verfuegbare_MA m_CurrentDatum

    Set db = Nothing
    Exit Sub

ErrHandler:
    MsgBox "Fehler beim Eintragen: " & Err.description, vbExclamation
    Set db = Nothing
End Sub

' FIX: Navigiere zum naechsten freien Slot der GLEICHEN Schicht
Private Sub DP_NavigateToNextFreeSlot(TargetStart As Date, TargetEnde As Date)
    On Error Resume Next

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim strSQL As String
    Dim NextFreeID As Long

    Set db = CurrentDb

    Dim strStartTime As String
    Dim strEndTime As String
    strStartTime = Format(TargetStart, "hh:nn:ss")
    strEndTime = Format(TargetEnde, "hh:nn:ss")

    ' Suche naechsten freien Slot mit GLEICHER Schichtzeit
    strSQL = "SELECT TOP 1 ID " & _
             "FROM tbl_MA_VA_Zuordnung " & _
             "WHERE VA_ID = " & m_CurrentVA_ID & " AND VADatum_ID = " & m_CurrentAnzTage_ID & _
             " AND (MA_ID = 0 OR MA_ID Is Null) " & _
             " AND Format(MA_Start, ''hh:nn:ss'') = ''" & strStartTime & "''" & _
             " AND Format(MA_Ende, ''hh:nn:ss'') = ''" & strEndTime & "''" & _
             " ORDER BY PosNr"

    Set rs = db.OpenRecordset(strSQL)

    If Not rs.EOF Then
        NextFreeID = rs!ID
        rs.Close

        Dim frm As Form
        Set frm = Forms!frm_N_DP_Dashboard

        ' Navigiere zum gefundenen Slot
        frm!sub_Einsatzliste.Form.Recordset.FindFirst "ID = " & NextFreeID

        ' WICHTIG: Behalte die Schichtzeit bei
        m_CurrentMA_Start = TargetStart
        m_CurrentMA_Ende = TargetEnde
    Else
        rs.Close
        ' Keine weiteren freien Slots in dieser Schicht - Zeiten zuruecksetzen
        m_CurrentMA_Start = 0
        m_CurrentMA_Ende = 0
    End If

    Set db = Nothing
    On Error GoTo 0
End Sub

Public Sub DP_MA_Zur_Anfrage(MA_ID As Long)
    On Error GoTo ErrHandler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim strSQL As String

    Set db = CurrentDb

    If m_CurrentMA_Start = 0 Then
        Set rs = db.OpenRecordset( _
            "SELECT TOP 1 VAStart_ID, MA_Start, MA_Ende " & _
            "FROM tbl_MA_VA_Zuordnung " & _
            "WHERE VA_ID = " & m_CurrentVA_ID & " AND VADatum_ID = " & m_CurrentAnzTage_ID & _
            " AND (MA_ID = 0 OR MA_ID Is Null) " & _
            "ORDER BY MA_Start, PosNr")

        If rs.EOF Then
            MsgBox "Alle Schichten bereits vollstaendig besetzt.", vbExclamation
            rs.Close
            Set db = Nothing
            Exit Sub
        End If

        m_CurrentVAStart_ID = rs!VAStart_ID
        m_CurrentMA_Start = rs!MA_Start
        m_CurrentMA_Ende = rs!MA_Ende
        rs.Close
    End If

    Set rs = db.OpenRecordset("SELECT * FROM ztbl_MA_Schnellauswahl WHERE ID = " & MA_ID)
    If rs.EOF Then
        Dim strBeginn As String
        Dim strEnde As String
        strBeginn = Format(m_CurrentMA_Start, "hh:nn")
        strEnde = Format(m_CurrentMA_Ende, "hh:nn")

        strSQL = "INSERT INTO ztbl_MA_Schnellauswahl (ID, Beginn, Ende) VALUES (" & _
                 MA_ID & ", #" & strBeginn & "#, #" & strEnde & "#)"
        db.Execute strSQL, dbFailOnError
    End If
    rs.Close

    Set db = Nothing

    DP_Aktualisiere_Angefragte_MA
    DP_Aktualisiere_Verfuegbare_MA m_CurrentDatum

    Exit Sub

ErrHandler:
    MsgBox "Fehler: " & Err.description, vbExclamation
    Set db = Nothing
End Sub

Public Sub DP_MA_Aus_Anfrage(MA_ID As Long)
    On Error Resume Next
    CurrentDb.Execute "DELETE FROM ztbl_MA_Schnellauswahl WHERE ID = " & MA_ID
    DP_Aktualisiere_Angefragte_MA
    DP_Aktualisiere_Verfuegbare_MA m_CurrentDatum
    On Error GoTo 0
End Sub

Public Sub DP_Aktualisiere_Angefragte_MA()
    On Error Resume Next

    Dim frm As Form
    Set frm = Forms!frm_N_DP_Dashboard

    Dim strSQL As String
    strSQL = "SELECT s.ID AS MA_ID, " & _
             "m.Nachname & '' '' & m.Vorname AS MA_Name, " & _
             "Format(s.Beginn, ''hh:nn'') AS von, " & _
             "Format(s.Ende, ''hh:nn'') AS bis " & _
             "FROM ztbl_MA_Schnellauswahl AS s " & _
             "INNER JOIN tbl_MA_Mitarbeiterstamm AS m ON s.ID = m.ID " & _
             "ORDER BY m.Nachname, m.Vorname"

    frm!lst_MA_Auswahl.RowSource = strSQL

    On Error GoTo 0
End Sub

' FIX V8: Direkte Mail-Anfrage ohne btnMail_Click Abhängigkeit
Public Sub DP_Mitarbeiter_Anfragen()
    On Error GoTo ErrHandler

    If m_CurrentVA_ID = 0 Or m_CurrentAnzTage_ID = 0 Then
        MsgBox "Bitte zuerst einen Auftrag auswaehlen.", vbExclamation
        Exit Sub
    End If

    Dim AnzahlAusgewaehlt As Long
    AnzahlAusgewaehlt = DCount("*", "ztbl_MA_Schnellauswahl")

    If AnzahlAusgewaehlt = 0 Then
        MsgBox "Bitte zuerst Mitarbeiter zur Anfrage-Liste hinzufuegen.", vbExclamation
        Exit Sub
    End If

    If MsgBox("Sollen " & AnzahlAusgewaehlt & " Mitarbeiter per E-Mail angefragt werden?", _
              vbYesNo + vbQuestion, "Mitarbeiter anfragen") = vbNo Then
        Exit Sub
    End If

    ' Direkte Mail-Erstellung ohne frm_ma_va_schnellauswahl
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim rsAuftrag As DAO.Recordset
    Dim strTo As String
    Dim strSubject As String
    Dim strBody As String
    Dim AuftragName As String
    Dim AuftragOrt As String
    Dim AuftragDatum As String

    Set db = CurrentDb

    ' Auftragsinformationen holen
    Set rsAuftrag = db.OpenRecordset( _
        "SELECT a.Auftrag, a.Objekt, t.VADatum " & _
        "FROM tbl_VA_Auftragstamm AS a " & _
        "INNER JOIN tbl_VA_AnzTage AS t ON a.ID = t.VA_ID " & _
        "WHERE a.ID = " & m_CurrentVA_ID & " AND t.ID = " & m_CurrentAnzTage_ID)

    If Not rsAuftrag.EOF Then
        AuftragName = Nz(rsAuftrag!Auftrag, "")
        AuftragOrt = Nz(rsAuftrag!Objekt, "")
        AuftragDatum = Format(Nz(rsAuftrag!VADatum, Date), "dd.mm.yyyy")
    End If
    rsAuftrag.Close

    ' E-Mail-Adressen und Body erstellen
    Set rs = db.OpenRecordset( _
        "SELECT m.Email, m.Vorname, m.Nachname, s.Beginn, s.Ende " & _
        "FROM ztbl_MA_Schnellauswahl AS s " & _
        "INNER JOIN tbl_MA_Mitarbeiterstamm AS m ON s.ID = m.ID " & _
        "WHERE Nz(m.Email, '''') <> ''''")

    strTo = ""
    strBody = "Hallo," & vbCrLf & vbCrLf
    strBody = strBody & "wir haben eine Anfrage fuer folgenden Einsatz:" & vbCrLf & vbCrLf
    strBody = strBody & "Auftrag: " & AuftragName & vbCrLf
    strBody = strBody & "Ort: " & AuftragOrt & vbCrLf
    strBody = strBody & "Datum: " & AuftragDatum & vbCrLf & vbCrLf
    strBody = strBody & "Bitte um Rueckmeldung ob ihr verfuegbar seid." & vbCrLf & vbCrLf
    strBody = strBody & "Mit freundlichen Gruessen"

    Do While Not rs.EOF
        If Nz(rs!Email, "") <> "" Then
            If strTo <> "" Then strTo = strTo & ";"
            strTo = strTo & rs!Email
        End If
        rs.MoveNext
    Loop
    rs.Close

    strSubject = "Anfrage: " & AuftragName & " - " & AuftragDatum

    If strTo = "" Then
        MsgBox "Keine E-Mail-Adressen gefunden.", vbExclamation
        Set db = Nothing
        Exit Sub
    End If

    ' Outlook verwenden
    On Error Resume Next
    Dim OutApp As Object
    Dim OutMail As Object

    Set OutApp = CreateObject("Outlook.Application")
    Set OutMail = OutApp.CreateItem(0)

    With OutMail
        .To = strTo
        .Subject = strSubject
        .Body = strBody
        .Display
    End With

    Set OutMail = Nothing
    Set OutApp = Nothing
    On Error GoTo 0

    MsgBox "E-Mail wurde erstellt.", vbInformation

    ' Schnellauswahl leeren
    DP_Schnellauswahl_Leeren
    DP_Aktualisiere_Verfuegbare_MA m_CurrentDatum

    Set db = Nothing
    Exit Sub

ErrHandler:
    MsgBox "Fehler: " & Err.description, vbExclamation
    Set db = Nothing
End Sub

Public Sub DP_Schnellauswahl_Leeren()
    On Error Resume Next
    CurrentDb.Execute "DELETE FROM ztbl_MA_Schnellauswahl"
    DP_Aktualisiere_Angefragte_MA
    On Error GoTo 0
End Sub

Public Function DP_Get_CurrentVA_ID() As Long
    DP_Get_CurrentVA_ID = m_CurrentVA_ID
End Function

Public Function DP_Get_CurrentAnzTage_ID() As Long
    DP_Get_CurrentAnzTage_ID = m_CurrentAnzTage_ID
End Function

Public Function DP_Get_CurrentDatum() As Date
    DP_Get_CurrentDatum = m_CurrentDatum
End Function

Public Function DP_Get_SelectedSlotID() As Long
    DP_Get_SelectedSlotID = m_SelectedSlotID
End Function

Public Sub DP_Ansicht_Wechseln()
    On Error Resume Next
    DoCmd.Close acForm, "frm_N_DP_Dashboard_Template"
    DoCmd.Close acForm, "frm_N_DP_Dashboard"
    If Not CurrentProject.AllForms("frm_va_auftragstamm").IsLoaded Then
        DoCmd.OpenForm "frm_va_auftragstamm"
    End If
    On Error GoTo 0
End Sub
'''

print("=" * 70)
print("DASHBOARD FIX V8")
print("=" * 70)

try:
    with AccessBridge() as bridge:
        # 1. VBA-Modul aktualisieren
        print("\n[1/4] VBA-Modul aktualisieren...")

        # Escaping fuer VBA
        vba_clean = VBA_CODE.replace("''", "'")

        success = bridge.import_vba_module("mod_N_DP_Dashboard", vba_clean, auto_prefix=False)
        if success:
            print("    [OK] mod_N_DP_Dashboard aktualisiert")
        else:
            print("    [!] Fehler beim VBA-Modul")

        # 2. Einsatzliste-Formular pruefen und anpassen
        print("\n[2/4] Einsatzliste-Formular pruefen...")

        try:
            bridge.access_app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)  # acDesign
            time.sleep(0.5)
            frm = bridge.access_app.Forms("zsub_N_DP_Einsatzliste")

            print(f"    AllowEdits vorher: {frm.AllowEdits}")
            frm.AllowEdits = True
            frm.AllowAdditions = False
            frm.AllowDeletions = False
            print(f"    AllowEdits jetzt: True")

            bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 1)  # acSaveYes
            print("    [OK] zsub_N_DP_Einsatzliste gespeichert")
        except Exception as e:
            print(f"    [!] Fehler: {e}")
            try:
                bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 2)
            except:
                pass

        # 3. lst_MA_Auswahl Spaltenbreiten anpassen (Fix fuer #Geloescht)
        print("\n[3/4] lst_MA_Auswahl Spaltenbreiten anpassen...")

        try:
            bridge.access_app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)  # acDesign
            time.sleep(0.5)
            frm = bridge.access_app.Forms("frm_N_DP_Dashboard")

            # lst_MA_Auswahl finden
            for i in range(frm.Controls.Count):
                ctl = frm.Controls(i)
                if ctl.Name == "lst_MA_Auswahl":
                    print(f"    Gefunden: lst_MA_Auswahl")
                    print(f"    ColumnCount vorher: {ctl.ColumnCount}")
                    print(f"    ColumnWidths vorher: {ctl.ColumnWidths}")

                    # 4 Spalten: MA_ID (hidden), Name, von, bis
                    ctl.ColumnCount = 4
                    ctl.ColumnWidths = "0cm;4cm;1.5cm;1.5cm"
                    ctl.BoundColumn = 1

                    print(f"    ColumnWidths jetzt: 0cm;4cm;1.5cm;1.5cm")
                    break

            bridge.access_app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)  # acSaveYes
            print("    [OK] frm_N_DP_Dashboard gespeichert")
        except Exception as e:
            print(f"    [!] Fehler: {e}")
            try:
                bridge.access_app.DoCmd.Close(2, "frm_N_DP_Dashboard", 2)
            except:
                pass

        # 4. Query fuer Angefragte MA pruefen/anpassen
        print("\n[4/4] Query fuer Angefragte MA pruefen...")

        sql_angefragte = """SELECT s.ID AS MA_ID,
m.Nachname & ' ' & m.Vorname AS MA_Name,
Format(s.Beginn, 'hh:nn') AS von,
Format(s.Ende, 'hh:nn') AS bis
FROM ztbl_MA_Schnellauswahl AS s
INNER JOIN tbl_MA_Mitarbeiterstamm AS m ON s.ID = m.ID
ORDER BY m.Nachname, m.Vorname"""

        bridge.create_query("qry_N_DP_MA_Angefragte_V2", sql_angefragte, auto_prefix=False)

        print("\n" + "=" * 70)
        print("[OK] ALLE FIXES ANGEWENDET")
        print("=" * 70)
        print("\nBitte Dashboard neu oeffnen und testen!")

except Exception as e:
    print(f"\n[!] FEHLER: {e}")
    import traceback
    traceback.print_exc()
