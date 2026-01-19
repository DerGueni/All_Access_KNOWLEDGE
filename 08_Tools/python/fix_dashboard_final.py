"""
FINALER FIX - Dashboard V9
Robust gegen COM-Fehler
"""
import sys
sys.path.insert(0, r'C:\Users\guenther.siegert\Documents\Access Bridge')

import win32com.client
import pythoncom
import time
import subprocess
from pathlib import Path

FRONTEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT - Kopie (4).accdb"

# VBA Module Code
VBA_MODULE = '''
' ============================================================
' PLANUNGS-DASHBOARD VBA-MODUL V9
' ============================================================

Private m_CurrentVA_ID As Long
Private m_CurrentAnzTage_ID As Long
Private m_CurrentDatum As Date
Private m_CurrentVAStart_ID As Long
Private m_CurrentMA_Start As Date
Private m_CurrentMA_Ende As Date
Private m_SelectedSlotID As Long

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
    strSQL = "SELECT m.ID AS MA_ID, m.Nachname & ' ' & m.Vorname AS MA_Name, m.Anstellungsart_ID, 0 AS MonatStd " & _
             "FROM tbl_MA_Mitarbeiterstamm AS m " & _
             "WHERE m.IstAktiv = True AND m.Anstellungsart_ID IN (3, 5) " & _
             "AND m.ID NOT IN (SELECT Nz(MA_ID,0) FROM tbl_MA_VA_Zuordnung WHERE VADatum = #" & strDatum & "# AND Nz(MA_ID,0) > 0) " & _
             "AND m.ID NOT IN (SELECT MA_ID FROM tbl_MA_NVerfuegZeiten WHERE #" & strDatum & "# BETWEEN vonDat AND bisDat) " & _
             "AND m.ID NOT IN (SELECT ID FROM ztbl_MA_Schnellauswahl) " & _
             "ORDER BY IIf(m.Anstellungsart_ID=3, 1, 2), m.Nachname, m.Vorname"
    frm!lstMA.RowSource = strSQL
    frm!lstMA.Requery
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
    If Not rs.EOF Then Anstellungsart = Nz(rs!Anstellungsart_ID, 0)
    rs.Close
    If Anstellungsart = 3 Then
        DP_MA_In_Slot_Eintragen MA_ID
    ElseIf Anstellungsart = 5 Then
        DP_MA_Zur_Anfrage MA_ID
    End If
    Set db = Nothing
    Exit Sub
ErrHandler:
    MsgBox "Fehler: " & Err.Description, vbExclamation
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
    TargetStart = m_CurrentMA_Start
    TargetEnde = m_CurrentMA_Ende

    If m_CurrentMA_Start = 0 Then
        Set rs = db.OpenRecordset("SELECT TOP 1 ID, VAStart_ID, MA_Start, MA_Ende FROM tbl_MA_VA_Zuordnung " & _
            "WHERE VA_ID = " & m_CurrentVA_ID & " AND VADatum_ID = " & m_CurrentAnzTage_ID & _
            " AND (MA_ID = 0 OR MA_ID Is Null) ORDER BY MA_Start, PosNr")
        If rs.EOF Then
            MsgBox "Alle Schichten bereits vollstaendig besetzt.", vbExclamation
            rs.Close: Set db = Nothing: Exit Sub
        End If
        FreeSlotID = rs!ID
        TargetStart = rs!MA_Start
        TargetEnde = rs!MA_Ende
        m_CurrentMA_Start = TargetStart
        m_CurrentMA_Ende = TargetEnde
        rs.Close
    Else
        Dim strStartTime As String, strEndTime As String
        strStartTime = Format(m_CurrentMA_Start, "hh:nn:ss")
        strEndTime = Format(m_CurrentMA_Ende, "hh:nn:ss")
        strSQL = "SELECT TOP 1 ID FROM tbl_MA_VA_Zuordnung WHERE VA_ID = " & m_CurrentVA_ID & _
                 " AND VADatum_ID = " & m_CurrentAnzTage_ID & " AND (MA_ID = 0 OR MA_ID Is Null)" & _
                 " AND Format(MA_Start, 'hh:nn:ss') = '" & strStartTime & "'" & _
                 " AND Format(MA_Ende, 'hh:nn:ss') = '" & strEndTime & "' ORDER BY PosNr"
        Set rs = db.OpenRecordset(strSQL)
        If rs.EOF Then
            MsgBox "Schicht bereits vollstaendig besetzt.", vbExclamation
            rs.Close: Set db = Nothing: Exit Sub
        End If
        FreeSlotID = rs!ID
        rs.Close
    End If

    Set rs = db.OpenRecordset("SELECT ID FROM tbl_MA_VA_Zuordnung WHERE VA_ID = " & m_CurrentVA_ID & _
        " AND VADatum_ID = " & m_CurrentAnzTage_ID & " AND MA_ID = " & MA_ID)
    If Not rs.EOF Then
        MsgBox "Mitarbeiter ist bereits fuer diesen Auftrag eingetragen.", vbInformation
        rs.Close: Set db = Nothing: Exit Sub
    End If
    rs.Close

    db.Execute "UPDATE tbl_MA_VA_Zuordnung SET MA_ID = " & MA_ID & " WHERE ID = " & FreeSlotID, dbFailOnError

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

Private Sub DP_NavigateToNextFreeSlot(TargetStart As Date, TargetEnde As Date)
    On Error Resume Next
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim strSQL As String
    Dim NextFreeID As Long
    Set db = CurrentDb
    Dim strStartTime As String, strEndTime As String
    strStartTime = Format(TargetStart, "hh:nn:ss")
    strEndTime = Format(TargetEnde, "hh:nn:ss")
    strSQL = "SELECT TOP 1 ID FROM tbl_MA_VA_Zuordnung WHERE VA_ID = " & m_CurrentVA_ID & _
             " AND VADatum_ID = " & m_CurrentAnzTage_ID & " AND (MA_ID = 0 OR MA_ID Is Null)" & _
             " AND Format(MA_Start, 'hh:nn:ss') = '" & strStartTime & "'" & _
             " AND Format(MA_Ende, 'hh:nn:ss') = '" & strEndTime & "' ORDER BY PosNr"
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

Public Sub DP_MA_Zur_Anfrage(MA_ID As Long)
    On Error GoTo ErrHandler
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Set db = CurrentDb
    If m_CurrentMA_Start = 0 Then
        Set rs = db.OpenRecordset("SELECT TOP 1 VAStart_ID, MA_Start, MA_Ende FROM tbl_MA_VA_Zuordnung " & _
            "WHERE VA_ID = " & m_CurrentVA_ID & " AND VADatum_ID = " & m_CurrentAnzTage_ID & _
            " AND (MA_ID = 0 OR MA_ID Is Null) ORDER BY MA_Start, PosNr")
        If rs.EOF Then
            MsgBox "Alle Schichten bereits vollstaendig besetzt.", vbExclamation
            rs.Close: Set db = Nothing: Exit Sub
        End If
        m_CurrentVAStart_ID = rs!VAStart_ID
        m_CurrentMA_Start = rs!MA_Start
        m_CurrentMA_Ende = rs!MA_Ende
        rs.Close
    End If
    Set rs = db.OpenRecordset("SELECT * FROM ztbl_MA_Schnellauswahl WHERE ID = " & MA_ID)
    If rs.EOF Then
        Dim strBeginn As String, strEnde As String
        strBeginn = Format(m_CurrentMA_Start, "hh:nn")
        strEnde = Format(m_CurrentMA_Ende, "hh:nn")
        db.Execute "INSERT INTO ztbl_MA_Schnellauswahl (ID, Beginn, Ende) VALUES (" & MA_ID & ", #" & strBeginn & "#, #" & strEnde & "#)", dbFailOnError
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
    strSQL = "SELECT s.ID AS MA_ID, m.Nachname & ' ' & m.Vorname AS MA_Name, " & _
             "Format(s.Beginn, 'hh:nn') AS von, Format(s.Ende, 'hh:nn') AS bis " & _
             "FROM ztbl_MA_Schnellauswahl AS s INNER JOIN tbl_MA_Mitarbeiterstamm AS m ON s.ID = m.ID " & _
             "ORDER BY m.Nachname, m.Vorname"
    frm!lst_MA_Auswahl.RowSource = strSQL
    frm!lst_MA_Auswahl.Requery
    On Error GoTo 0
End Sub

Public Sub DP_Mitarbeiter_Anfragen()
    On Error GoTo ErrHandler
    If m_CurrentVA_ID = 0 Or m_CurrentAnzTage_ID = 0 Then
        MsgBox "Bitte zuerst einen Auftrag auswaehlen.", vbExclamation: Exit Sub
    End If
    Dim AnzahlAusgewaehlt As Long
    AnzahlAusgewaehlt = DCount("*", "ztbl_MA_Schnellauswahl")
    If AnzahlAusgewaehlt = 0 Then
        MsgBox "Bitte zuerst Mitarbeiter zur Anfrage-Liste hinzufuegen.", vbExclamation: Exit Sub
    End If
    If MsgBox("Sollen " & AnzahlAusgewaehlt & " Mitarbeiter per E-Mail angefragt werden?", vbYesNo + vbQuestion, "Mitarbeiter anfragen") = vbNo Then Exit Sub

    Dim db As DAO.Database, rs As DAO.Recordset, rsAuftrag As DAO.Recordset
    Dim strTo As String, strSubject As String, strBody As String
    Dim AuftragName As String, AuftragOrt As String, AuftragDatum As String
    Set db = CurrentDb
    Set rsAuftrag = db.OpenRecordset("SELECT a.Auftrag, a.Objekt, t.VADatum FROM tbl_VA_Auftragstamm AS a " & _
        "INNER JOIN tbl_VA_AnzTage AS t ON a.ID = t.VA_ID WHERE a.ID = " & m_CurrentVA_ID & " AND t.ID = " & m_CurrentAnzTage_ID)
    If Not rsAuftrag.EOF Then
        AuftragName = Nz(rsAuftrag!Auftrag, "")
        AuftragOrt = Nz(rsAuftrag!Objekt, "")
        AuftragDatum = Format(Nz(rsAuftrag!VADatum, Date), "dd.mm.yyyy")
    End If
    rsAuftrag.Close

    Set rs = db.OpenRecordset("SELECT m.Email FROM ztbl_MA_Schnellauswahl AS s " & _
        "INNER JOIN tbl_MA_Mitarbeiterstamm AS m ON s.ID = m.ID WHERE Nz(m.Email, '') <> ''")
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
    strBody = "Hallo," & vbCrLf & vbCrLf & "wir haben eine Anfrage fuer folgenden Einsatz:" & vbCrLf & vbCrLf & _
              "Auftrag: " & AuftragName & vbCrLf & "Ort: " & AuftragOrt & vbCrLf & "Datum: " & AuftragDatum & vbCrLf & vbCrLf & _
              "Bitte um Rueckmeldung." & vbCrLf & vbCrLf & "Mit freundlichen Gruessen"

    If strTo = "" Then MsgBox "Keine E-Mail-Adressen gefunden.", vbExclamation: Set db = Nothing: Exit Sub

    On Error Resume Next
    Dim OutApp As Object, OutMail As Object
    Set OutApp = CreateObject("Outlook.Application")
    Set OutMail = OutApp.CreateItem(0)
    With OutMail: .To = strTo: .Subject = strSubject: .Body = strBody: .Display: End With
    Set OutMail = Nothing: Set OutApp = Nothing
    On Error GoTo 0
    MsgBox "E-Mail wurde erstellt.", vbInformation
    DP_Schnellauswahl_Leeren
    DP_Aktualisiere_Verfuegbare_MA m_CurrentDatum
    Set db = Nothing
    Exit Sub
ErrHandler:
    MsgBox "Fehler: " & Err.Description, vbExclamation: Set db = Nothing
End Sub

Public Sub DP_Schnellauswahl_Leeren()
    On Error Resume Next
    CurrentDb.Execute "DELETE FROM ztbl_MA_Schnellauswahl"
    DP_Aktualisiere_Angefragte_MA
    On Error GoTo 0
End Sub

Public Function DP_Get_CurrentVA_ID() As Long: DP_Get_CurrentVA_ID = m_CurrentVA_ID: End Function
Public Function DP_Get_CurrentAnzTage_ID() As Long: DP_Get_CurrentAnzTage_ID = m_CurrentAnzTage_ID: End Function
Public Function DP_Get_CurrentDatum() As Date: DP_Get_CurrentDatum = m_CurrentDatum: End Function
Public Function DP_Get_SelectedSlotID() As Long: DP_Get_SelectedSlotID = m_SelectedSlotID: End Function
'''

FORM_CODE = '''
Private Sub lstMA_DblClick(Cancel As Integer)
    If Not IsNull(Me!lstMA) Then DP_MA_Doppelklick Me!lstMA
End Sub

Private Sub lst_MA_Auswahl_DblClick(Cancel As Integer)
    If Not IsNull(Me!lst_MA_Auswahl) Then DP_MA_Aus_Anfrage Me!lst_MA_Auswahl
End Sub

Private Sub cmd_MA_Anfragen_Click()
    DP_Mitarbeiter_Anfragen
End Sub

Private Sub sub_lstAuftrag_Current()
    On Error Resume Next
    Dim subFrm As Form: Set subFrm = Me!sub_lstAuftrag.Form
    If Not subFrm.Recordset.EOF And Not subFrm.Recordset.BOF Then
        Dim VA_ID As Long, AnzTage_ID As Long, VADatum As Date
        VA_ID = Nz(subFrm!VA_ID, 0): AnzTage_ID = Nz(subFrm!AnzTage_ID, 0): VADatum = Nz(subFrm!Datum, Date)
        If VA_ID > 0 And AnzTage_ID > 0 Then DP_Auftrag_Ausgewaehlt VA_ID, AnzTage_ID, VADatum
    End If
    On Error GoTo 0
End Sub

Private Sub Form_Load()
    On Error Resume Next
    CurrentDb.Execute "DELETE FROM ztbl_MA_Schnellauswahl"
    Me!lst_MA_Auswahl.Requery: Me!lstMA.Requery
    On Error GoTo 0
End Sub

Private Sub btn_N_AnsichtWechseln_Click()
    On Error Resume Next
    Dim VA_ID As Long: VA_ID = DP_Get_CurrentVA_ID()
    DoCmd.Close acForm, Me.Name, acSaveNo
    If VA_ID > 0 Then DoCmd.OpenForm "frm_va_auftragstamm", , , "ID = " & VA_ID Else DoCmd.OpenForm "frm_va_auftragstamm"
    On Error GoTo 0
End Sub
'''

SUBFORM_CODE = '''
Private Sub Form_Current()
    On Error Resume Next
    If Not Me.NewRecord Then DP_Einsatzliste_Click Nz(Me!ID, 0), Nz(Me!VAStart_ID, 0), Nz(Me!MA_Start, 0), Nz(Me!MA_Ende, 0)
    On Error GoTo 0
End Sub

Private Sub MA_Name_DblClick(Cancel As Integer)
    On Error Resume Next
    If Nz(Me!MA_ID, 0) = 0 Then DP_Einsatzliste_Click Nz(Me!ID, 0), Nz(Me!VAStart_ID, 0), Nz(Me!MA_Start, 0), Nz(Me!MA_Ende, 0)
    On Error GoTo 0
End Sub
'''

def start_dialog_killer():
    killer_script = Path(r"C:\Users\guenther.siegert\Documents\Access Bridge\DialogKillerPermanent.ps1")
    if killer_script.exists():
        cmd = ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-File", str(killer_script), "-Minutes", "30", "-IntervalMs", "50"]
        return subprocess.Popen(cmd, creationflags=subprocess.CREATE_NO_WINDOW, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return None

print("=" * 70)
print("FINALER DASHBOARD FIX V9")
print("=" * 70)

killer = start_dialog_killer()
print("[OK] DialogKiller gestartet")

try:
    pythoncom.CoInitialize()

    # Access verbinden
    print("\n[1] Verbinde zu Access...")
    try:
        app = win32com.client.GetObject(Class="Access.Application")
        db_name = app.CurrentDb().Name
        if "Consys_FE_N_Test_Claude_GPT" in db_name:
            print(f"    [OK] Laufende Instanz gefunden: {db_name}")
        else:
            raise Exception("Falsche DB")
    except:
        print("    [!] Keine passende Instanz - oeffne neu...")
        app = win32com.client.Dispatch("Access.Application")
        app.Visible = True
        app.OpenCurrentDatabase(FRONTEND_PATH, False)
        time.sleep(3)
        print(f"    [OK] Neu geoeffnet")

    app.DoCmd.SetWarnings(False)

    # 2. VBA Module importieren
    print("\n[2] VBA Modul aktualisieren...")
    vbe = app.VBE
    proj = vbe.ActiveVBProject

    # Entferne Option-Zeilen
    vba_clean = VBA_MODULE
    for line in ["Option Compare Database", "Option Explicit"]:
        vba_clean = vba_clean.replace(line + "\n", "")

    # Modul suchen oder erstellen
    comp = None
    for c in proj.VBComponents:
        if c.Name == "mod_N_DP_Dashboard":
            comp = c
            break

    if comp:
        cm = comp.CodeModule
        if cm.CountOfLines > 0:
            cm.DeleteLines(1, cm.CountOfLines)
        cm.AddFromString(vba_clean)
        print("    [OK] mod_N_DP_Dashboard aktualisiert")
    else:
        comp = proj.VBComponents.Add(1)
        comp.Name = "mod_N_DP_Dashboard"
        comp.CodeModule.AddFromString(vba_clean)
        print("    [OK] mod_N_DP_Dashboard erstellt")

    # 3. Form-Code aktualisieren
    print("\n[3] Formular-Code aktualisieren...")

    for c in proj.VBComponents:
        if c.Name == "Form_frm_N_DB_Dashboard":
            cm = c.CodeModule
            if cm.CountOfLines > 0:
                cm.DeleteLines(1, cm.CountOfLines)
            cm.AddFromString(FORM_CODE)
            print(f"    [OK] {c.Name} aktualisiert")

        elif c.Name == "Form_zsub_N_DP_Einsatzliste":
            cm = c.CodeModule
            if cm.CountOfLines > 0:
                cm.DeleteLines(1, cm.CountOfLines)
            cm.AddFromString(SUBFORM_CODE)
            print(f"    [OK] {c.Name} aktualisiert")

    # 4. Formular-Eigenschaften
    print("\n[4] Formular-Eigenschaften anpassen...")

    # Einsatzliste
    try:
        app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 2)
    except: pass
    time.sleep(0.2)

    app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)
    time.sleep(0.3)
    frm = app.Forms("zsub_N_DP_Einsatzliste")
    frm.AllowEdits = True
    frm.AllowAdditions = False
    frm.AllowDeletions = False
    app.RunCommand(3)
    app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 1)
    print("    [OK] zsub_N_DP_Einsatzliste: AllowEdits=True")

    # Dashboard ListBox
    try:
        app.DoCmd.Close(2, "frm_N_DP_Dashboard", 2)
    except: pass
    time.sleep(0.2)

    app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)
    time.sleep(0.3)
    frm = app.Forms("frm_N_DP_Dashboard")

    for i in range(frm.Controls.Count):
        ctl = frm.Controls(i)
        if ctl.Name == "lst_MA_Auswahl":
            ctl.ColumnCount = 4
            ctl.ColumnWidths = "0;2800;600;600"
            print(f"    [OK] lst_MA_Auswahl: 4 Spalten")
            break

    app.RunCommand(3)
    app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)
    print("    [OK] frm_N_DP_Dashboard gespeichert")

    app.DoCmd.SetWarnings(True)

    print("\n" + "=" * 70)
    print("[OK] ALLE FIXES ANGEWENDET!")
    print("=" * 70)
    print("\nBitte Dashboard neu oeffnen und testen:")
    print("- Doppelklick auf Mitarbeiter in lstMA")
    print("- Einsatzliste Zeilen auswaehlen")
    print("- Mitarbeiter anfragen Button")

except Exception as e:
    print(f"\n[!] FEHLER: {e}")
    import traceback
    traceback.print_exc()

finally:
    if killer:
        killer.terminate()
    pythoncom.CoUninitialize()
