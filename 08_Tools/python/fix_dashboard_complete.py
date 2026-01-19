"""
KOMPLETTER FIX - Dashboard V9
Behebt:
1. VBA-Modul war nicht aktualisiert (V7 -> V9)
2. Doppelklick auf Mitarbeiter funktioniert nicht
3. Einsatzliste nicht bearbeitbar
4. lst_MA_Auswahl Spaltenbreiten
"""
import sys
sys.path.insert(0, r'C:\Users\guenther.siegert\Documents\Access Bridge')

from access_bridge_ultimate import AccessBridge
import time

# ============================================================
# VERBESSERTER VBA-CODE V9
# ============================================================
VBA_MODULE_CODE = '''
' ============================================================
' PLANUNGS-DASHBOARD VBA-MODUL V9 - KOMPLETT UEBERARBEITET
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

    frm!sub_Einsatzliste.Form.Filter = "VA_ID = " & VA_ID & " AND VADatum_ID = " & AnzTage_ID
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
             "m.Nachname & ' ' & m.Vorname AS MA_Name, " & _
             "m.Anstellungsart_ID, " & _
             "0 AS MonatStd " & _
             "FROM tbl_MA_Mitarbeiterstamm AS m " & _
             "WHERE m.IstAktiv = True " & _
             "  AND m.Anstellungsart_ID IN (3, 5) " & _
             "  AND m.ID NOT IN (SELECT Nz(MA_ID,0) FROM tbl_MA_VA_Zuordnung WHERE VADatum = #" & strDatum & "# AND Nz(MA_ID,0) > 0) " & _
             "  AND m.ID NOT IN (SELECT MA_ID FROM tbl_MA_NVerfuegZeiten " & _
             "                   WHERE #" & strDatum & "# BETWEEN vonDat AND bisDat) " & _
             "  AND m.ID NOT IN (SELECT ID FROM ztbl_MA_Schnellauswahl) " & _
             "ORDER BY IIf(m.Anstellungsart_ID=3, 1, 2), m.Nachname, m.Vorname"

    frm!lstMA.RowSource = strSQL
    frm!lstMA.Requery

    On Error GoTo 0
End Sub

' V9: Doppelklick auf MA in der Liste
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
        ' Festangestellter -> direkt eintragen
        DP_MA_In_Slot_Eintragen MA_ID
    ElseIf Anstellungsart = 5 Then
        ' Aushilfe -> zur Anfrage-Liste
        DP_MA_Zur_Anfrage MA_ID
    End If

    Set db = Nothing
    Exit Sub

ErrHandler:
    MsgBox "Fehler: " & Err.Description, vbExclamation
End Sub

' V9: MA in freien Slot eintragen
Public Sub DP_MA_In_Slot_Eintragen(MA_ID As Long)
    On Error GoTo ErrHandler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim strSQL As String
    Dim FreeSlotID As Long
    Dim TargetStart As Date
    Dim TargetEnde As Date

    Set db = CurrentDb

    TargetStart = m_CurrentMA_Start
    TargetEnde = m_CurrentMA_Ende

    ' Wenn keine Schicht ausgewaehlt, erste freie nehmen
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
        ' Freien Slot in der gleichen Schicht suchen
        Dim strStartTime As String
        Dim strEndTime As String
        strStartTime = Format(m_CurrentMA_Start, "hh:nn:ss")
        strEndTime = Format(m_CurrentMA_Ende, "hh:nn:ss")

        strSQL = "SELECT TOP 1 ID " & _
                 "FROM tbl_MA_VA_Zuordnung " & _
                 "WHERE VA_ID = " & m_CurrentVA_ID & " AND VADatum_ID = " & m_CurrentAnzTage_ID & _
                 " AND (MA_ID = 0 OR MA_ID Is Null) " & _
                 " AND Format(MA_Start, 'hh:nn:ss') = '" & strStartTime & "'" & _
                 " AND Format(MA_Ende, 'hh:nn:ss') = '" & strEndTime & "'" & _
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

    ' Zum naechsten freien Slot der GLEICHEN Schicht navigieren
    DP_NavigateToNextFreeSlot TargetStart, TargetEnde

    DP_Aktualisiere_Verfuegbare_MA m_CurrentDatum

    Set db = Nothing
    Exit Sub

ErrHandler:
    MsgBox "Fehler beim Eintragen: " & Err.Description, vbExclamation
    Set db = Nothing
End Sub

' V9: Zum naechsten freien Slot der gleichen Schicht navigieren
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

    strSQL = "SELECT TOP 1 ID " & _
             "FROM tbl_MA_VA_Zuordnung " & _
             "WHERE VA_ID = " & m_CurrentVA_ID & " AND VADatum_ID = " & m_CurrentAnzTage_ID & _
             " AND (MA_ID = 0 OR MA_ID Is Null) " & _
             " AND Format(MA_Start, 'hh:nn:ss') = '" & strStartTime & "'" & _
             " AND Format(MA_Ende, 'hh:nn:ss') = '" & strEndTime & "'" & _
             " ORDER BY PosNr"

    Set rs = db.OpenRecordset(strSQL)

    If Not rs.EOF Then
        NextFreeID = rs!ID
        rs.Close

        Dim frm As Form
        Set frm = Forms!frm_N_DP_Dashboard
        frm!sub_Einsatzliste.Form.Recordset.FindFirst "ID = " & NextFreeID

        m_CurrentMA_Start = TargetStart
        m_CurrentMA_Ende = TargetEnde
    Else
        rs.Close
        m_CurrentMA_Start = 0
        m_CurrentMA_Ende = 0
    End If

    Set db = Nothing
    On Error GoTo 0
End Sub

' V9: MA zur Anfrage-Liste hinzufuegen
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
    MsgBox "Fehler: " & Err.Description, vbExclamation
    Set db = Nothing
End Sub

' V9: MA aus Anfrage-Liste entfernen
Public Sub DP_MA_Aus_Anfrage(MA_ID As Long)
    On Error Resume Next
    CurrentDb.Execute "DELETE FROM ztbl_MA_Schnellauswahl WHERE ID = " & MA_ID
    DP_Aktualisiere_Angefragte_MA
    DP_Aktualisiere_Verfuegbare_MA m_CurrentDatum
    On Error GoTo 0
End Sub

' V9: Angefragte MA Liste aktualisieren
Public Sub DP_Aktualisiere_Angefragte_MA()
    On Error Resume Next

    Dim frm As Form
    Set frm = Forms!frm_N_DP_Dashboard

    Dim strSQL As String
    strSQL = "SELECT s.ID AS MA_ID, " & _
             "m.Nachname & ' ' & m.Vorname AS MA_Name, " & _
             "Format(s.Beginn, 'hh:nn') AS von, " & _
             "Format(s.Ende, 'hh:nn') AS bis " & _
             "FROM ztbl_MA_Schnellauswahl AS s " & _
             "INNER JOIN tbl_MA_Mitarbeiterstamm AS m ON s.ID = m.ID " & _
             "ORDER BY m.Nachname, m.Vorname"

    frm!lst_MA_Auswahl.RowSource = strSQL
    frm!lst_MA_Auswahl.Requery

    On Error GoTo 0
End Sub

' V9: Mitarbeiter per Mail anfragen (direkt ohne externes Formular)
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

    Set rs = db.OpenRecordset( _
        "SELECT m.Email, m.Vorname, m.Nachname, s.Beginn, s.Ende " & _
        "FROM ztbl_MA_Schnellauswahl AS s " & _
        "INNER JOIN tbl_MA_Mitarbeiterstamm AS m ON s.ID = m.ID " & _
        "WHERE Nz(m.Email, '') <> ''")

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

    DP_Schnellauswahl_Leeren
    DP_Aktualisiere_Verfuegbare_MA m_CurrentDatum

    Set db = Nothing
    Exit Sub

ErrHandler:
    MsgBox "Fehler: " & Err.Description, vbExclamation
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
    DoCmd.Close acForm, "frm_N_DP_Dashboard"
    If Not CurrentProject.AllForms("frm_va_auftragstamm").IsLoaded Then
        DoCmd.OpenForm "frm_va_auftragstamm"
    End If
    On Error GoTo 0
End Sub
'''

# ============================================================
# FORMULAR-CODE fuer frm_N_DP_Dashboard
# ============================================================
FORM_CODE = '''
Private Sub lstMA_DblClick(Cancel As Integer)
    ' Doppelklick auf Mitarbeiter in der Liste
    If Not IsNull(Me!lstMA) Then
        DP_MA_Doppelklick Me!lstMA
    End If
End Sub

Private Sub lst_MA_Auswahl_DblClick(Cancel As Integer)
    ' Doppelklick auf angefragten MA -> entfernen
    If Not IsNull(Me!lst_MA_Auswahl) Then
        DP_MA_Aus_Anfrage Me!lst_MA_Auswahl
    End If
End Sub

Private Sub cmd_MA_Anfragen_Click()
    DP_Mitarbeiter_Anfragen
End Sub

Private Sub sub_lstAuftrag_Current()
    On Error Resume Next
    Dim subFrm As Form
    Set subFrm = Me!sub_lstAuftrag.Form

    If Not subFrm.Recordset.EOF And Not subFrm.Recordset.BOF Then
        Dim VA_ID As Long
        Dim AnzTage_ID As Long
        Dim VADatum As Date

        VA_ID = Nz(subFrm!VA_ID, 0)
        AnzTage_ID = Nz(subFrm!AnzTage_ID, 0)
        VADatum = Nz(subFrm!Datum, Date)

        If VA_ID > 0 And AnzTage_ID > 0 Then
            DP_Auftrag_Ausgewaehlt VA_ID, AnzTage_ID, VADatum
        End If
    End If
    On Error GoTo 0
End Sub

Private Sub Form_Load()
    On Error Resume Next
    CurrentDb.Execute "DELETE FROM ztbl_MA_Schnellauswahl"
    Me!lst_MA_Auswahl.Requery
    Me!lstMA.Requery
    On Error GoTo 0
End Sub

Private Sub btn_N_AnsichtWechseln_Click()
    On Error Resume Next
    Dim VA_ID As Long
    VA_ID = DP_Get_CurrentVA_ID()

    DoCmd.Close acForm, Me.Name, acSaveNo

    If VA_ID > 0 Then
        DoCmd.OpenForm "frm_va_auftragstamm", , , "ID = " & VA_ID
    Else
        DoCmd.OpenForm "frm_va_auftragstamm"
    End If
    On Error GoTo 0
End Sub
'''

# ============================================================
# UNTERFORMULAR-CODE fuer zsub_N_DP_Einsatzliste
# ============================================================
SUBFORM_CODE = '''
Private Sub Form_Current()
    On Error Resume Next
    If Not Me.NewRecord Then
        DP_Einsatzliste_Click Nz(Me!ID, 0), Nz(Me!VAStart_ID, 0), Nz(Me!MA_Start, 0), Nz(Me!MA_Ende, 0)
    End If
    On Error GoTo 0
End Sub

Private Sub MA_Name_DblClick(Cancel As Integer)
    On Error Resume Next
    If Nz(Me!MA_ID, 0) = 0 Then
        DP_Einsatzliste_Click Nz(Me!ID, 0), Nz(Me!VAStart_ID, 0), Nz(Me!MA_Start, 0), Nz(Me!MA_Ende, 0)
    End If
    On Error GoTo 0
End Sub
'''

print("=" * 70)
print("KOMPLETTER DASHBOARD FIX V9")
print("=" * 70)

try:
    with AccessBridge() as bridge:

        # 1. VBA-Modul aktualisieren
        print("\n[1/4] VBA-Modul mod_N_DP_Dashboard aktualisieren...")
        success = bridge.import_vba_module("mod_N_DP_Dashboard", VBA_MODULE_CODE, auto_prefix=False)
        if success:
            print("    [OK] mod_N_DP_Dashboard V9 importiert")
        else:
            print("    [!] Fehler beim VBA-Modul")

        # 2. Formular-Code aktualisieren
        print("\n[2/4] Formular-Code aktualisieren...")

        vbe = bridge.access_app.VBE
        proj = vbe.ActiveVBProject

        # Finde das richtige Form-Modul
        for comp in proj.VBComponents:
            if comp.Name == "Form_frm_N_DP_Dashboard":
                code_module = comp.CodeModule
                if code_module.CountOfLines > 0:
                    code_module.DeleteLines(1, code_module.CountOfLines)
                code_module.AddFromString(FORM_CODE)
                print("    [OK] Form_frm_N_DP_Dashboard Code aktualisiert")
                break
        else:
            print("    [!] Form_frm_N_DP_Dashboard nicht gefunden")

        # 3. Unterformular-Code aktualisieren
        print("\n[3/4] Unterformular-Code aktualisieren...")

        for comp in proj.VBComponents:
            if comp.Name == "Form_zsub_N_DP_Einsatzliste":
                code_module = comp.CodeModule
                if code_module.CountOfLines > 0:
                    code_module.DeleteLines(1, code_module.CountOfLines)
                code_module.AddFromString(SUBFORM_CODE)
                print("    [OK] Form_zsub_N_DP_Einsatzliste Code aktualisiert")
                break

        # 4. Formular-Eigenschaften korrigieren
        print("\n[4/4] Formular-Eigenschaften korrigieren...")

        # Einsatzliste - AllowEdits aktivieren
        try:
            bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 2)
        except:
            pass

        bridge.access_app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)  # acDesign
        time.sleep(0.3)
        frm = bridge.access_app.Forms("zsub_N_DP_Einsatzliste")

        frm.AllowEdits = True
        frm.AllowAdditions = False
        frm.AllowDeletions = False

        bridge.access_app.RunCommand(3)  # acCmdSave
        bridge.access_app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 1)
        print("    [OK] zsub_N_DP_Einsatzliste: AllowEdits=True")

        # Hauptformular - Listbox korrigieren
        try:
            bridge.access_app.DoCmd.Close(2, "frm_N_DP_Dashboard", 2)
        except:
            pass

        bridge.access_app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)  # acDesign
        time.sleep(0.3)
        frm = bridge.access_app.Forms("frm_N_DP_Dashboard")

        # lst_MA_Auswahl finden und korrigieren
        for i in range(frm.Controls.Count):
            ctl = frm.Controls(i)
            if ctl.Name == "lst_MA_Auswahl":
                ctl.ColumnCount = 4
                ctl.ColumnWidths = "0;2800;600;600"
                print(f"    [OK] lst_MA_Auswahl: 4 Spalten, Breiten=0;2800;600;600")
                break

        bridge.access_app.RunCommand(3)  # acCmdSave
        bridge.access_app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)
        print("    [OK] frm_N_DP_Dashboard gespeichert")

        print("\n" + "=" * 70)
        print("[OK] ALLE FIXES V9 ANGEWENDET")
        print("=" * 70)
        print("\nBitte Dashboard neu oeffnen: frm_N_DP_Dashboard")
        print("- Doppelklick auf Mitarbeiter sollte funktionieren")
        print("- Einsatzliste sollte bearbeitbar sein")
        print("- Cursor bleibt in gleicher Schicht")

except Exception as e:
    print(f"\n[!] FEHLER: {e}")
    import traceback
    traceback.print_exc()
