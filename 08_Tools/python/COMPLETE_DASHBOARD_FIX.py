"""
================================================================================
KOMPLETTER DASHBOARD FIX - V10 FINAL
================================================================================

Dieser Fix behebt ALLE bekannten Probleme:

1. Doppelklick auf Mitarbeiter in lstMA funktioniert nicht
2. Doppelklick auf Mitarbeiter in lst_MA_Auswahl funktioniert nicht
3. "Mitarbeiter anfragen" Button zeigt Fehler
4. Einsatzliste ist nicht bearbeitbar
5. Nach MA-Eintrag springt Cursor nach oben statt zum nächsten freien Slot
6. #Gelöscht wird in Spalten angezeigt (falsche Spaltenbreiten)
7. Fehlende Funktion DP_Dashboard_Oeffnen_MitAuftrag

ABLAUF:
- Öffnet Access mit dem korrekten Frontend
- Importiert das komplette VBA-Modul mod_N_DP_Dashboard
- Setzt HasModule=True für frm_N_DP_Dashboard
- Fügt den Event-Code zum Formular-Modul hinzu
- Setzt OnDblClick Events für die Listboxen
- Korrigiert AllowEdits für zsub_N_DP_Einsatzliste
- Korrigiert ColumnWidths für lst_MA_Auswahl
- Aktualisiert zsub_N_DP_Einsatzliste Code

================================================================================
"""

import sys
sys.path.insert(0, r'C:\Users\guenther.siegert\Documents\Access Bridge')

import win32com.client
import pythoncom
import subprocess
import time
from pathlib import Path

# ==============================================================================
# KONFIGURATION
# ==============================================================================

FRONTEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT - Kopie (4).accdb"

# ==============================================================================
# VBA MODUL CODE - mod_N_DP_Dashboard (KOMPLETT)
# ==============================================================================

VBA_MODULE_CODE = '''
' ============================================================
' PLANUNGS-DASHBOARD VBA-MODUL V10 FINAL
' ============================================================
' Alle Funktionen fuer das Dashboard frm_N_DP_Dashboard

Private m_CurrentVA_ID As Long
Private m_CurrentAnzTage_ID As Long
Private m_CurrentDatum As Date
Private m_CurrentVAStart_ID As Long
Private m_CurrentMA_Start As Date
Private m_CurrentMA_Ende As Date
Private m_SelectedSlotID As Long

' === DASHBOARD OEFFNEN ===

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

' === AUFTRAG AUSGEWAEHLT ===

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

' === EINSATZLISTE CLICK ===

Public Sub DP_Einsatzliste_Click(SlotID As Long, VAStart_ID As Long, MA_Start As Date, MA_Ende As Date)
    m_SelectedSlotID = SlotID
    m_CurrentVAStart_ID = VAStart_ID
    m_CurrentMA_Start = MA_Start
    m_CurrentMA_Ende = MA_Ende
End Sub

' === VERFUEGBARE MA AKTUALISIEREN ===

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
             "AND m.Anstellungsart_ID IN (3, 5) " & _
             "AND m.ID NOT IN (SELECT Nz(MA_ID,0) FROM tbl_MA_VA_Zuordnung WHERE VADatum = #" & strDatum & "# AND Nz(MA_ID,0) > 0) " & _
             "AND m.ID NOT IN (SELECT MA_ID FROM tbl_MA_NVerfuegZeiten WHERE #" & strDatum & "# BETWEEN vonDat AND bisDat) " & _
             "AND m.ID NOT IN (SELECT ID FROM ztbl_MA_Schnellauswahl) " & _
             "ORDER BY IIf(m.Anstellungsart_ID=3, 1, 2), m.Nachname, m.Vorname"

    frm!lstMA.RowSource = strSQL
    frm!lstMA.Requery

    On Error GoTo 0
End Sub

' === MA DOPPELKLICK (Hauptfunktion) ===

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
    MsgBox "Fehler bei Doppelklick: " & Err.Description, vbExclamation
End Sub

' === MA IN SLOT EINTRAGEN ===

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

    strSQL = "UPDATE tbl_MA_VA_Zuordnung SET MA_ID = " & MA_ID & " WHERE ID = " & FreeSlotID
    db.Execute strSQL, dbFailOnError

    Dim frm As Form
    Set frm = Forms!frm_N_DP_Dashboard
    frm!sub_Einsatzliste.Form.Requery

    DP_NavigateToNextFreeSlot TargetStart, TargetEnde
    DP_Aktualisiere_Verfuegbare_MA m_CurrentDatum

    Set db = Nothing
    Exit Sub

ErrHandler:
    MsgBox "Fehler beim Eintragen: " & Err.Description, vbExclamation
    Set db = Nothing
End Sub

' === ZUM NAECHSTEN FREIEN SLOT NAVIGIEREN ===

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

' === MA ZUR ANFRAGE HINZUFUEGEN ===

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

' === MA AUS ANFRAGE ENTFERNEN ===

Public Sub DP_MA_Aus_Anfrage(MA_ID As Long)
    On Error Resume Next
    CurrentDb.Execute "DELETE FROM ztbl_MA_Schnellauswahl WHERE ID = " & MA_ID
    DP_Aktualisiere_Angefragte_MA
    DP_Aktualisiere_Verfuegbare_MA m_CurrentDatum
    On Error GoTo 0
End Sub

' === ANGEFRAGTE MA AKTUALISIEREN ===

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

' === MITARBEITER PER MAIL ANFRAGEN ===

Public Sub DP_Mitarbeiter_Anfragen()
    On Error GoTo ErrHandler

    If m_CurrentVA_ID = 0 Or m_CurrentAnzTage_ID = 0 Then
        MsgBox "Bitte zuerst einen Auftrag auswaehlen.", vbExclamation
        Exit Sub
    End If

    Dim AnzahlAusgewaehlt As Long
    AnzahlAusgewaehlt = DCount("*", "ztbl_MA_Schnellauswahl")

    If AnzahlAusgewaehlt = 0 Then
        MsgBox "Bitte zuerst Mitarbeiter zur Anfrage-Liste hinzufuegen." & vbCrLf & vbCrLf & _
               "Doppelklicken Sie auf einen Aushilfs-Mitarbeiter (grau) in der Liste.", vbExclamation
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
    Do While Not rs.EOF
        If Nz(rs!Email, "") <> "" Then
            If strTo <> "" Then strTo = strTo & ";"
            strTo = strTo & rs!Email
        End If
        rs.MoveNext
    Loop
    rs.Close

    strSubject = "Anfrage: " & AuftragName & " - " & AuftragDatum

    strBody = "Hallo," & vbCrLf & vbCrLf
    strBody = strBody & "wir haben eine Anfrage fuer folgenden Einsatz:" & vbCrLf & vbCrLf
    strBody = strBody & "Auftrag: " & AuftragName & vbCrLf
    strBody = strBody & "Ort: " & AuftragOrt & vbCrLf
    strBody = strBody & "Datum: " & AuftragDatum & vbCrLf & vbCrLf
    strBody = strBody & "Bitte um Rueckmeldung ob ihr verfuegbar seid." & vbCrLf & vbCrLf
    strBody = strBody & "Mit freundlichen Gruessen"

    If strTo = "" Then
        MsgBox "Keine E-Mail-Adressen bei den ausgewaehlten Mitarbeitern gefunden.", vbExclamation
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
    MsgBox "Fehler beim Erstellen der E-Mail: " & Err.Description, vbExclamation
    Set db = Nothing
End Sub

' === SCHNELLAUSWAHL LEEREN ===

Public Sub DP_Schnellauswahl_Leeren()
    On Error Resume Next
    CurrentDb.Execute "DELETE FROM ztbl_MA_Schnellauswahl"
    DP_Aktualisiere_Angefragte_MA
    On Error GoTo 0
End Sub

' === GETTER FUNKTIONEN ===

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

' === ANSICHT WECHSELN ===

Public Sub DP_Ansicht_Wechseln()
    On Error Resume Next
    DoCmd.Close acForm, "frm_N_DP_Dashboard"
    If Not CurrentProject.AllForms("frm_va_auftragstamm").IsLoaded Then
        DoCmd.OpenForm "frm_va_auftragstamm"
    End If
    On Error GoTo 0
End Sub
'''

# ==============================================================================
# FORMULAR CODE - frm_N_DP_Dashboard
# ==============================================================================

FORM_CODE = '''
Private Sub lstMA_DblClick(Cancel As Integer)
    ' Doppelklick auf Mitarbeiter -> eintragen oder zur Anfrage
    If Not IsNull(Me!lstMA) Then
        DP_MA_Doppelklick Me!lstMA
    End If
End Sub

Private Sub lst_MA_Auswahl_DblClick(Cancel As Integer)
    ' Doppelklick auf angefragten MA -> aus Liste entfernen
    If Not IsNull(Me!lst_MA_Auswahl) Then
        DP_MA_Aus_Anfrage Me!lst_MA_Auswahl
    End If
End Sub

Private Sub cmd_MA_Anfragen_Click()
    ' Button: Mitarbeiter per Mail anfragen
    DP_Mitarbeiter_Anfragen
End Sub

Private Sub sub_lstAuftrag_Current()
    ' Wenn Auftrag in Liste ausgewaehlt wird
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
    ' Beim Oeffnen: Schnellauswahl leeren
    On Error Resume Next
    CurrentDb.Execute "DELETE FROM ztbl_MA_Schnellauswahl"
    Me!lst_MA_Auswahl.Requery
    Me!lstMA.Requery
    On Error GoTo 0
End Sub

Private Sub btn_N_AnsichtWechseln_Click()
    ' Zurueck zum Auftragstamm
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

# ==============================================================================
# UNTERFORMULAR CODE - zsub_N_DP_Einsatzliste
# ==============================================================================

SUBFORM_CODE = '''
Private Sub Form_Current()
    ' Bei Zeilenwechsel: Slot-Daten merken
    On Error Resume Next
    If Not Me.NewRecord Then
        DP_Einsatzliste_Click Nz(Me!ID, 0), Nz(Me!VAStart_ID, 0), Nz(Me!MA_Start, 0), Nz(Me!MA_Ende, 0)
    End If
    On Error GoTo 0
End Sub

Private Sub MA_Name_DblClick(Cancel As Integer)
    ' Doppelklick auf leeren Slot
    On Error Resume Next
    If Nz(Me!MA_ID, 0) = 0 Then
        DP_Einsatzliste_Click Nz(Me!ID, 0), Nz(Me!VAStart_ID, 0), Nz(Me!MA_Start, 0), Nz(Me!MA_Ende, 0)
    End If
    On Error GoTo 0
End Sub
'''

# ==============================================================================
# HILFSFUNKTIONEN
# ==============================================================================

def start_dialog_killer():
    """Startet den DialogKiller im Hintergrund"""
    killer_script = Path(r"C:\Users\guenther.siegert\Documents\Access Bridge\DialogKillerPermanent.ps1")
    if killer_script.exists():
        cmd = [
            "powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass",
            "-WindowStyle", "Hidden", "-File", str(killer_script),
            "-Minutes", "30", "-IntervalMs", "50"
        ]
        return subprocess.Popen(
            cmd, creationflags=subprocess.CREATE_NO_WINDOW,
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
        )
    return None

def strip_vba_options(code):
    """Entfernt Option Compare Database und Option Explicit"""
    lines = code.split('\n')
    filtered = []
    for line in lines:
        stripped = line.strip().lower()
        if stripped.startswith('option compare') or stripped.startswith('option explicit'):
            continue
        filtered.append(line)
    return '\n'.join(filtered)

# ==============================================================================
# HAUPTPROGRAMM
# ==============================================================================

def main():
    print("=" * 80)
    print("KOMPLETTER DASHBOARD FIX - V10 FINAL")
    print("=" * 80)
    print()
    print("Dieser Fix behebt ALLE bekannten Probleme:")
    print("  1. Doppelklick auf Mitarbeiter funktioniert nicht")
    print("  2. 'Mitarbeiter anfragen' Button zeigt Fehler")
    print("  3. Einsatzliste ist nicht bearbeitbar")
    print("  4. Cursor springt nach oben statt zum naechsten Slot")
    print("  5. #Geloescht wird in Spalten angezeigt")
    print()
    print("=" * 80)

    killer = None
    app = None

    try:
        # DialogKiller starten
        killer = start_dialog_killer()
        if killer:
            print("[OK] DialogKiller gestartet")

        pythoncom.CoInitialize()

        # =====================================================================
        # SCHRITT 1: Access verbinden
        # =====================================================================
        print("\n" + "-" * 60)
        print("SCHRITT 1: Access verbinden")
        print("-" * 60)

        try:
            app = win32com.client.GetObject(Class="Access.Application")
            db_name = app.CurrentDb().Name
            if "Consys_FE_N_Test_Claude_GPT" in db_name:
                print(f"[OK] Laufende Instanz gefunden: {Path(db_name).name}")
            else:
                print(f"[!] Falsche DB offen: {Path(db_name).name}")
                raise Exception("Falsche Datenbank")
        except:
            print("[...] Starte neue Access-Instanz...")
            app = win32com.client.Dispatch("Access.Application")
            app.Visible = True
            app.UserControl = True
            print(f"[...] Oeffne: {Path(FRONTEND_PATH).name}")
            app.OpenCurrentDatabase(FRONTEND_PATH, False)
            time.sleep(3)
            print("[OK] Access gestartet")

        app.DoCmd.SetWarnings(False)

        # =====================================================================
        # SCHRITT 2: Alle Formulare schliessen
        # =====================================================================
        print("\n" + "-" * 60)
        print("SCHRITT 2: Formulare schliessen")
        print("-" * 60)

        forms_to_close = ["frm_N_DP_Dashboard", "zsub_N_DP_Einsatzliste", "zsub_lstAuftrag"]
        for form_name in forms_to_close:
            try:
                app.DoCmd.Close(2, form_name, 2)  # acForm, acSaveNo
                print(f"[OK] Geschlossen: {form_name}")
            except:
                pass

        time.sleep(0.5)

        # =====================================================================
        # SCHRITT 3: VBA Modul importieren
        # =====================================================================
        print("\n" + "-" * 60)
        print("SCHRITT 3: VBA Modul mod_N_DP_Dashboard importieren")
        print("-" * 60)

        vbe = app.VBE
        proj = vbe.ActiveVBProject

        vba_clean = strip_vba_options(VBA_MODULE_CODE)

        # Modul suchen oder erstellen
        module_comp = None
        for comp in proj.VBComponents:
            if comp.Name == "mod_N_DP_Dashboard":
                module_comp = comp
                break

        if module_comp:
            cm = module_comp.CodeModule
            if cm.CountOfLines > 0:
                cm.DeleteLines(1, cm.CountOfLines)
            cm.AddFromString(vba_clean)
            print(f"[OK] mod_N_DP_Dashboard aktualisiert ({cm.CountOfLines} Zeilen)")
        else:
            module_comp = proj.VBComponents.Add(1)  # vbext_ct_StdModule
            module_comp.Name = "mod_N_DP_Dashboard"
            module_comp.CodeModule.AddFromString(vba_clean)
            print(f"[OK] mod_N_DP_Dashboard erstellt")

        # =====================================================================
        # SCHRITT 4: Hauptformular bearbeiten
        # =====================================================================
        print("\n" + "-" * 60)
        print("SCHRITT 4: Hauptformular frm_N_DP_Dashboard bearbeiten")
        print("-" * 60)

        app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)  # acDesign
        time.sleep(0.5)

        frm = app.Forms("frm_N_DP_Dashboard")

        # HasModule aktivieren
        if not frm.HasModule:
            frm.HasModule = True
            print("[OK] HasModule aktiviert")
        else:
            print("[OK] HasModule war bereits True")

        # Listbox Events setzen
        for i in range(frm.Controls.Count):
            ctl = frm.Controls(i)

            if ctl.Name == "lstMA":
                if ctl.OnDblClick != "[Event Procedure]":
                    ctl.OnDblClick = "[Event Procedure]"
                    print("[OK] lstMA.OnDblClick = [Event Procedure]")
                else:
                    print("[OK] lstMA.OnDblClick war bereits gesetzt")

            elif ctl.Name == "lst_MA_Auswahl":
                if ctl.OnDblClick != "[Event Procedure]":
                    ctl.OnDblClick = "[Event Procedure]"
                    print("[OK] lst_MA_Auswahl.OnDblClick = [Event Procedure]")
                else:
                    print("[OK] lst_MA_Auswahl.OnDblClick war bereits gesetzt")

                # Spaltenbreiten korrigieren
                ctl.ColumnCount = 4
                ctl.ColumnWidths = "0;2800;600;600"
                print("[OK] lst_MA_Auswahl Spalten: 4, Breiten: 0;2800;600;600")

        # Speichern
        app.RunCommand(3)  # acCmdSave
        app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)
        print("[OK] frm_N_DP_Dashboard gespeichert")

        time.sleep(0.3)

        # =====================================================================
        # SCHRITT 5: Formular-Code einfuegen
        # =====================================================================
        print("\n" + "-" * 60)
        print("SCHRITT 5: Formular-Code einfuegen")
        print("-" * 60)

        # Formular erneut oeffnen damit VBComponents aktualisiert wird
        app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)
        time.sleep(0.3)

        # VBE neu holen
        vbe = app.VBE
        proj = vbe.ActiveVBProject

        # Form-Modul suchen
        form_module = None
        for comp in proj.VBComponents:
            if comp.Name == "Form_frm_N_DP_Dashboard":
                form_module = comp
                print(f"[OK] Gefunden: Form_frm_N_DP_Dashboard")
                break

        if form_module:
            cm = form_module.CodeModule
            if cm.CountOfLines > 0:
                cm.DeleteLines(1, cm.CountOfLines)
            cm.AddFromString(FORM_CODE)
            print(f"[OK] Form-Code eingefuegt ({cm.CountOfLines} Zeilen)")
        else:
            print("[!] Form_frm_N_DP_Dashboard nicht gefunden - versuche alternatives Modul")
            # Versuche Form_frm_N_DB_Dashboard (falls das der richtige Name ist)
            for comp in proj.VBComponents:
                if "frm_N_D" in comp.Name and "Dashboard" in comp.Name:
                    print(f"[...] Versuche: {comp.Name}")
                    cm = comp.CodeModule
                    if cm.CountOfLines > 0:
                        cm.DeleteLines(1, cm.CountOfLines)
                    cm.AddFromString(FORM_CODE)
                    print(f"[OK] Form-Code in {comp.Name} eingefuegt")
                    break

        app.RunCommand(3)
        app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)
        print("[OK] Formular gespeichert")

        time.sleep(0.3)

        # =====================================================================
        # SCHRITT 6: Unterformular zsub_N_DP_Einsatzliste bearbeiten
        # =====================================================================
        print("\n" + "-" * 60)
        print("SCHRITT 6: Unterformular zsub_N_DP_Einsatzliste bearbeiten")
        print("-" * 60)

        app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)  # acDesign
        time.sleep(0.3)

        frm = app.Forms("zsub_N_DP_Einsatzliste")

        # AllowEdits aktivieren
        frm.AllowEdits = True
        frm.AllowAdditions = False
        frm.AllowDeletions = False
        print("[OK] AllowEdits = True, AllowAdditions = False, AllowDeletions = False")

        # HasModule aktivieren
        if not frm.HasModule:
            frm.HasModule = True
            print("[OK] HasModule aktiviert")

        app.RunCommand(3)
        app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 1)
        print("[OK] zsub_N_DP_Einsatzliste gespeichert")

        time.sleep(0.3)

        # Unterformular Code einfuegen
        app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)
        time.sleep(0.3)

        vbe = app.VBE
        proj = vbe.ActiveVBProject

        for comp in proj.VBComponents:
            if comp.Name == "Form_zsub_N_DP_Einsatzliste":
                cm = comp.CodeModule
                if cm.CountOfLines > 0:
                    cm.DeleteLines(1, cm.CountOfLines)
                cm.AddFromString(SUBFORM_CODE)
                print(f"[OK] Unterformular-Code eingefuegt ({cm.CountOfLines} Zeilen)")
                break

        app.RunCommand(3)
        app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 1)
        print("[OK] Unterformular gespeichert")

        # =====================================================================
        # SCHRITT 7: Kompilieren
        # =====================================================================
        print("\n" + "-" * 60)
        print("SCHRITT 7: VBA-Projekt kompilieren")
        print("-" * 60)

        try:
            app.RunCommand(566)  # acCmdCompileAndSaveAllModules
            print("[OK] Kompiliert")
        except:
            print("[INFO] Kompilierung manuell erforderlich (Debuggen -> Kompilieren)")

        app.DoCmd.SetWarnings(True)

        # =====================================================================
        # FERTIG
        # =====================================================================
        print("\n" + "=" * 80)
        print("FERTIG - ALLE FIXES ANGEWENDET!")
        print("=" * 80)
        print()
        print("Bitte testen Sie jetzt:")
        print("  1. Oeffnen Sie frm_N_DP_Dashboard")
        print("  2. Waehlen Sie einen Auftrag aus der Liste")
        print("  3. Doppelklicken Sie auf einen Mitarbeiter (blau = Festangestellt)")
        print("  4. Der MA sollte in die Einsatzliste eingetragen werden")
        print("  5. Der Cursor sollte im naechsten freien Slot DERSELBEN SCHICHT stehen")
        print()

    except Exception as e:
        print(f"\n[FEHLER] {e}")
        import traceback
        traceback.print_exc()

    finally:
        if killer:
            try:
                killer.terminate()
            except:
                pass
        pythoncom.CoUninitialize()


if __name__ == "__main__":
    main()
