"""
================================================================================
RUN ALL FIXES - Komplettes Dashboard Fix Script V3
================================================================================
Robuster Ansatz mit korrekter Reihenfolge
"""
import win32com.client
import pythoncom
import subprocess
import time
from pathlib import Path

FRONTEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT - Kopie (4).accdb"

VBA_MODULE = '''
' mod_N_DP_Dashboard V10 FINAL
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
    m_CurrentVA_ID = VA_ID: m_CurrentAnzTage_ID = AnzTage_ID: m_CurrentDatum = VADatum
    m_CurrentVAStart_ID = 0: m_SelectedSlotID = 0: m_CurrentMA_Start = 0: m_CurrentMA_Ende = 0
    Dim frm As Form: Set frm = Forms!frm_N_DP_Dashboard
    frm!sub_Einsatzliste.Form.Filter = "VA_ID = " & VA_ID & " AND VADatum_ID = " & AnzTage_ID
    frm!sub_Einsatzliste.Form.FilterOn = True
    frm!sub_Einsatzliste.Form.Requery
    DP_Aktualisiere_Verfuegbare_MA VADatum
    DP_Aktualisiere_Angefragte_MA
    On Error GoTo 0
End Sub

Public Sub DP_Einsatzliste_Click(SlotID As Long, VAStart_ID As Long, MA_Start As Date, MA_Ende As Date)
    m_SelectedSlotID = SlotID: m_CurrentVAStart_ID = VAStart_ID
    m_CurrentMA_Start = MA_Start: m_CurrentMA_Ende = MA_Ende
End Sub

Public Sub DP_Aktualisiere_Verfuegbare_MA(VADatum As Date)
    On Error Resume Next
    Dim frm As Form: Set frm = Forms!frm_N_DP_Dashboard
    Dim strDatum As String
    strDatum = Format(VADatum, "mm") & "/" & Format(VADatum, "dd") & "/" & Format(VADatum, "yyyy")
    Dim strSQL As String
    strSQL = "SELECT m.ID AS MA_ID, m.Nachname & ' ' & m.Vorname AS MA_Name, m.Anstellungsart_ID, 0 AS MonatStd " & _
             "FROM tbl_MA_Mitarbeiterstamm AS m WHERE m.IstAktiv = True AND m.Anstellungsart_ID IN (3, 5) " & _
             "AND m.ID NOT IN (SELECT Nz(MA_ID,0) FROM tbl_MA_VA_Zuordnung WHERE VADatum = #" & strDatum & "# AND Nz(MA_ID,0) > 0) " & _
             "AND m.ID NOT IN (SELECT MA_ID FROM tbl_MA_NVerfuegZeiten WHERE #" & strDatum & "# BETWEEN vonDat AND bisDat) " & _
             "AND m.ID NOT IN (SELECT ID FROM ztbl_MA_Schnellauswahl) " & _
             "ORDER BY IIf(m.Anstellungsart_ID=3, 1, 2), m.Nachname, m.Vorname"
    frm!lstMA.RowSource = strSQL: frm!lstMA.Requery
    On Error GoTo 0
End Sub

Public Sub DP_MA_Doppelklick(MA_ID As Long)
    On Error GoTo ErrHandler
    If m_CurrentVA_ID = 0 Or m_CurrentAnzTage_ID = 0 Then
        MsgBox "Bitte zuerst einen Auftrag auswaehlen.", vbExclamation: Exit Sub
    End If
    Dim db As DAO.Database, rs As DAO.Recordset, Anstellungsart As Long
    Set db = CurrentDb
    Set rs = db.OpenRecordset("SELECT Anstellungsart_ID FROM tbl_MA_Mitarbeiterstamm WHERE ID = " & MA_ID)
    If Not rs.EOF Then Anstellungsart = Nz(rs!Anstellungsart_ID, 0)
    rs.Close
    If Anstellungsart = 3 Then DP_MA_In_Slot_Eintragen MA_ID
    If Anstellungsart = 5 Then DP_MA_Zur_Anfrage MA_ID
    Set db = Nothing: Exit Sub
ErrHandler:
    MsgBox "Fehler: " & Err.Description, vbExclamation
End Sub

Public Sub DP_MA_In_Slot_Eintragen(MA_ID As Long)
    On Error GoTo ErrHandler
    Dim db As DAO.Database, rs As DAO.Recordset, strSQL As String
    Dim FreeSlotID As Long, TargetStart As Date, TargetEnde As Date
    Set db = CurrentDb: TargetStart = m_CurrentMA_Start: TargetEnde = m_CurrentMA_Ende
    If m_CurrentMA_Start = 0 Then
        Set rs = db.OpenRecordset("SELECT TOP 1 ID, VAStart_ID, MA_Start, MA_Ende FROM tbl_MA_VA_Zuordnung " & _
            "WHERE VA_ID = " & m_CurrentVA_ID & " AND VADatum_ID = " & m_CurrentAnzTage_ID & _
            " AND (MA_ID = 0 OR MA_ID Is Null) ORDER BY MA_Start, PosNr")
        If rs.EOF Then MsgBox "Alle Schichten besetzt.", vbExclamation: rs.Close: Set db = Nothing: Exit Sub
        FreeSlotID = rs!ID: TargetStart = rs!MA_Start: TargetEnde = rs!MA_Ende
        m_CurrentMA_Start = TargetStart: m_CurrentMA_Ende = TargetEnde: rs.Close
    Else
        Dim strStartTime As String, strEndTime As String
        strStartTime = Format(m_CurrentMA_Start, "hh:nn:ss"): strEndTime = Format(m_CurrentMA_Ende, "hh:nn:ss")
        strSQL = "SELECT TOP 1 ID FROM tbl_MA_VA_Zuordnung WHERE VA_ID = " & m_CurrentVA_ID & _
                 " AND VADatum_ID = " & m_CurrentAnzTage_ID & " AND (MA_ID = 0 OR MA_ID Is Null)" & _
                 " AND Format(MA_Start, 'hh:nn:ss') = '" & strStartTime & "'" & _
                 " AND Format(MA_Ende, 'hh:nn:ss') = '" & strEndTime & "' ORDER BY PosNr"
        Set rs = db.OpenRecordset(strSQL)
        If rs.EOF Then MsgBox "Schicht besetzt.", vbExclamation: rs.Close: Set db = Nothing: Exit Sub
        FreeSlotID = rs!ID: rs.Close
    End If
    Set rs = db.OpenRecordset("SELECT ID FROM tbl_MA_VA_Zuordnung WHERE VA_ID = " & m_CurrentVA_ID & _
        " AND VADatum_ID = " & m_CurrentAnzTage_ID & " AND MA_ID = " & MA_ID)
    If Not rs.EOF Then MsgBox "MA bereits eingetragen.", vbInformation: rs.Close: Set db = Nothing: Exit Sub
    rs.Close
    db.Execute "UPDATE tbl_MA_VA_Zuordnung SET MA_ID = " & MA_ID & " WHERE ID = " & FreeSlotID, dbFailOnError
    Dim frm As Form: Set frm = Forms!frm_N_DP_Dashboard
    frm!sub_Einsatzliste.Form.Requery
    DP_NavigateToNextFreeSlot TargetStart, TargetEnde
    DP_Aktualisiere_Verfuegbare_MA m_CurrentDatum
    Set db = Nothing: Exit Sub
ErrHandler:
    MsgBox "Fehler: " & Err.Description, vbExclamation: Set db = Nothing
End Sub

Private Sub DP_NavigateToNextFreeSlot(TargetStart As Date, TargetEnde As Date)
    On Error Resume Next
    Dim db As DAO.Database, rs As DAO.Recordset, strSQL As String, NextFreeID As Long
    Set db = CurrentDb
    Dim strStartTime As String, strEndTime As String
    strStartTime = Format(TargetStart, "hh:nn:ss"): strEndTime = Format(TargetEnde, "hh:nn:ss")
    strSQL = "SELECT TOP 1 ID FROM tbl_MA_VA_Zuordnung WHERE VA_ID = " & m_CurrentVA_ID & _
             " AND VADatum_ID = " & m_CurrentAnzTage_ID & " AND (MA_ID = 0 OR MA_ID Is Null)" & _
             " AND Format(MA_Start, 'hh:nn:ss') = '" & strStartTime & "'" & _
             " AND Format(MA_Ende, 'hh:nn:ss') = '" & strEndTime & "' ORDER BY PosNr"
    Set rs = db.OpenRecordset(strSQL)
    If Not rs.EOF Then
        NextFreeID = rs!ID: rs.Close
        Dim frm As Form: Set frm = Forms!frm_N_DP_Dashboard
        frm!sub_Einsatzliste.Form.Recordset.FindFirst "ID = " & NextFreeID
        m_CurrentMA_Start = TargetStart: m_CurrentMA_Ende = TargetEnde
    Else
        rs.Close: m_CurrentMA_Start = 0: m_CurrentMA_Ende = 0
    End If
    Set db = Nothing
    On Error GoTo 0
End Sub

Public Sub DP_MA_Zur_Anfrage(MA_ID As Long)
    On Error GoTo ErrHandler
    Dim db As DAO.Database, rs As DAO.Recordset
    Set db = CurrentDb
    If m_CurrentMA_Start = 0 Then
        Set rs = db.OpenRecordset("SELECT TOP 1 VAStart_ID, MA_Start, MA_Ende FROM tbl_MA_VA_Zuordnung " & _
            "WHERE VA_ID = " & m_CurrentVA_ID & " AND VADatum_ID = " & m_CurrentAnzTage_ID & _
            " AND (MA_ID = 0 OR MA_ID Is Null) ORDER BY MA_Start, PosNr")
        If rs.EOF Then MsgBox "Alle Schichten besetzt.", vbExclamation: rs.Close: Set db = Nothing: Exit Sub
        m_CurrentVAStart_ID = rs!VAStart_ID: m_CurrentMA_Start = rs!MA_Start: m_CurrentMA_Ende = rs!MA_Ende: rs.Close
    End If
    Set rs = db.OpenRecordset("SELECT * FROM ztbl_MA_Schnellauswahl WHERE ID = " & MA_ID)
    If rs.EOF Then
        Dim strBeginn As String, strEnde As String
        strBeginn = Format(m_CurrentMA_Start, "hh:nn"): strEnde = Format(m_CurrentMA_Ende, "hh:nn")
        db.Execute "INSERT INTO ztbl_MA_Schnellauswahl (ID, Beginn, Ende) VALUES (" & MA_ID & ", #" & strBeginn & "#, #" & strEnde & "#)", dbFailOnError
    End If
    rs.Close: Set db = Nothing
    DP_Aktualisiere_Angefragte_MA: DP_Aktualisiere_Verfuegbare_MA m_CurrentDatum
    Exit Sub
ErrHandler:
    MsgBox "Fehler: " & Err.Description, vbExclamation: Set db = Nothing
End Sub

Public Sub DP_MA_Aus_Anfrage(MA_ID As Long)
    On Error Resume Next
    CurrentDb.Execute "DELETE FROM ztbl_MA_Schnellauswahl WHERE ID = " & MA_ID
    DP_Aktualisiere_Angefragte_MA: DP_Aktualisiere_Verfuegbare_MA m_CurrentDatum
    On Error GoTo 0
End Sub

Public Sub DP_Aktualisiere_Angefragte_MA()
    On Error Resume Next
    Dim frm As Form: Set frm = Forms!frm_N_DP_Dashboard
    Dim strSQL As String
    strSQL = "SELECT s.ID AS MA_ID, m.Nachname & ' ' & m.Vorname AS MA_Name, " & _
             "Format(s.Beginn, 'hh:nn') AS von, Format(s.Ende, 'hh:nn') AS bis " & _
             "FROM ztbl_MA_Schnellauswahl AS s INNER JOIN tbl_MA_Mitarbeiterstamm AS m ON s.ID = m.ID " & _
             "ORDER BY m.Nachname, m.Vorname"
    frm!lst_MA_Auswahl.RowSource = strSQL: frm!lst_MA_Auswahl.Requery
    On Error GoTo 0
End Sub

Public Sub DP_Mitarbeiter_Anfragen()
    On Error GoTo ErrHandler
    If m_CurrentVA_ID = 0 Or m_CurrentAnzTage_ID = 0 Then MsgBox "Bitte zuerst Auftrag auswaehlen.", vbExclamation: Exit Sub
    Dim AnzahlAusgewaehlt As Long: AnzahlAusgewaehlt = DCount("*", "ztbl_MA_Schnellauswahl")
    If AnzahlAusgewaehlt = 0 Then MsgBox "Bitte zuerst MA zur Anfrage hinzufuegen.", vbExclamation: Exit Sub
    If MsgBox(AnzahlAusgewaehlt & " MA per E-Mail anfragen?", vbYesNo + vbQuestion) = vbNo Then Exit Sub
    Dim db As DAO.Database, rs As DAO.Recordset, rsA As DAO.Recordset
    Dim strTo As String, strSubject As String, strBody As String
    Dim AuftragName As String, AuftragOrt As String, AuftragDatum As String
    Set db = CurrentDb
    Set rsA = db.OpenRecordset("SELECT a.Auftrag, a.Objekt, t.VADatum FROM tbl_VA_Auftragstamm AS a " & _
        "INNER JOIN tbl_VA_AnzTage AS t ON a.ID = t.VA_ID WHERE a.ID = " & m_CurrentVA_ID & " AND t.ID = " & m_CurrentAnzTage_ID)
    If Not rsA.EOF Then AuftragName = Nz(rsA!Auftrag, ""): AuftragOrt = Nz(rsA!Objekt, ""): AuftragDatum = Format(Nz(rsA!VADatum, Date), "dd.mm.yyyy")
    rsA.Close
    Set rs = db.OpenRecordset("SELECT m.Email FROM ztbl_MA_Schnellauswahl AS s INNER JOIN tbl_MA_Mitarbeiterstamm AS m ON s.ID = m.ID WHERE Nz(m.Email, '') <> ''")
    strTo = ""
    Do While Not rs.EOF: If Nz(rs!Email, "") <> "" Then If strTo <> "" Then strTo = strTo & ";": strTo = strTo & rs!Email: End If: rs.MoveNext: Loop
    rs.Close
    strSubject = "Anfrage: " & AuftragName & " - " & AuftragDatum
    strBody = "Hallo," & vbCrLf & vbCrLf & "Einsatz-Anfrage:" & vbCrLf & "Auftrag: " & AuftragName & vbCrLf & "Ort: " & AuftragOrt & vbCrLf & "Datum: " & AuftragDatum & vbCrLf & vbCrLf & "Bitte um Rueckmeldung." & vbCrLf & vbCrLf & "MfG"
    If strTo = "" Then MsgBox "Keine E-Mails.", vbExclamation: Set db = Nothing: Exit Sub
    On Error Resume Next
    Dim OutApp As Object, OutMail As Object
    Set OutApp = CreateObject("Outlook.Application"): Set OutMail = OutApp.CreateItem(0)
    With OutMail: .To = strTo: .Subject = strSubject: .Body = strBody: .Display: End With
    Set OutMail = Nothing: Set OutApp = Nothing
    On Error GoTo 0
    MsgBox "E-Mail erstellt.", vbInformation
    DP_Schnellauswahl_Leeren: DP_Aktualisiere_Verfuegbare_MA m_CurrentDatum
    Set db = Nothing: Exit Sub
ErrHandler:
    MsgBox "Fehler: " & Err.Description, vbExclamation: Set db = Nothing
End Sub

Public Sub DP_Schnellauswahl_Leeren()
    On Error Resume Next: CurrentDb.Execute "DELETE FROM ztbl_MA_Schnellauswahl": DP_Aktualisiere_Angefragte_MA: On Error GoTo 0
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

def start_killer():
    p = Path(r"C:\Users\guenther.siegert\Documents\Access Bridge\DialogKillerPermanent.ps1")
    if p.exists():
        return subprocess.Popen(["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-File", str(p), "-Minutes", "30", "-IntervalMs", "50"],
            creationflags=subprocess.CREATE_NO_WINDOW, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return None

def get_app():
    """Hole Access Application - neu erstellen oder bestehend verbinden"""
    try:
        app = win32com.client.GetObject(Class="Access.Application")
        try:
            db_name = app.CurrentProject.FullName
            if FRONTEND_PATH.lower() in db_name.lower():
                return app
        except:
            pass
    except:
        pass

    app = win32com.client.Dispatch("Access.Application")
    app.Visible = True
    app.UserControl = True
    app.OpenCurrentDatabase(FRONTEND_PATH, False)
    time.sleep(3)
    return app

def save_form(app, form_name):
    """Speichere Formular mit Fehlerbehandlung"""
    try:
        app.DoCmd.Save(2, form_name)  # acForm
        return True
    except:
        pass
    try:
        app.RunCommand(3)  # acCmdSave
        return True
    except:
        pass
    return False

print("=" * 70)
print("RUN ALL FIXES V3")
print("=" * 70)

killer = start_killer()
print("[OK] DialogKiller")

try:
    pythoncom.CoInitialize()

    print("\n[1] Access verbinden...")
    app = get_app()
    try:
        db_name = app.CurrentProject.FullName
    except:
        db_name = FRONTEND_PATH
    print(f"[OK] Access offen: {db_name}")

    try:
        app.DoCmd.SetWarnings(False)
    except:
        pass

    # Alle Formulare schliessen
    print("\n[2] Formulare schliessen...")
    for form_name in ["frm_N_DP_Dashboard", "zsub_N_DP_Einsatzliste", "zsub_lstAuftrag"]:
        try:
            app.DoCmd.Close(2, form_name, 2)
            print(f"    Geschlossen: {form_name}")
        except:
            pass
    time.sleep(1)

    # SCHRITT 1: VBA Modul aktualisieren
    print("\n[3] VBA Modul aktualisieren...")
    vbe = app.VBE
    proj = vbe.ActiveVBProject

    if proj is None:
        print("[!] VBProject nicht verfuegbar - breche ab")
        raise Exception("VBProject ist None")

    comp = None
    for c in proj.VBComponents:
        if c.Name == "mod_N_DP_Dashboard":
            comp = c
            break

    if comp:
        cm = comp.CodeModule
        if cm.CountOfLines > 0:
            cm.DeleteLines(1, cm.CountOfLines)
        cm.AddFromString(VBA_MODULE)
        print(f"[OK] mod_N_DP_Dashboard aktualisiert ({cm.CountOfLines} Zeilen)")
    else:
        comp = proj.VBComponents.Add(1)
        comp.Name = "mod_N_DP_Dashboard"
        comp.CodeModule.AddFromString(VBA_MODULE)
        print("[OK] mod_N_DP_Dashboard neu erstellt")

    # SCHRITT 2: Hauptformular - HasModule und Eigenschaften
    print("\n[4] Hauptformular frm_N_DP_Dashboard...")
    app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)  # acDesign
    time.sleep(1)

    frm = app.Forms("frm_N_DP_Dashboard")
    frm.HasModule = True
    print("    HasModule = True")

    # ListBox und Button Eigenschaften
    for i in range(frm.Controls.Count):
        ctl = frm.Controls(i)
        if ctl.Name == "lstMA":
            ctl.OnDblClick = "[Event Procedure]"
            print("    lstMA.OnDblClick = [Event Procedure]")
        if ctl.Name == "lst_MA_Auswahl":
            ctl.OnDblClick = "[Event Procedure]"
            ctl.ColumnCount = 4
            ctl.ColumnWidths = "0;2800;600;600"
            print("    lst_MA_Auswahl Eigenschaften gesetzt")
        if ctl.Name == "cmd_MA_Anfragen":
            ctl.OnClick = "[Event Procedure]"
            print("    cmd_MA_Anfragen.OnClick = [Event Procedure]")

    # Speichern um das Form-Modul zu erstellen
    time.sleep(1)  # Warten auf DialogKiller
    try:
        app.DoCmd.Save(2, "frm_N_DP_Dashboard")
        print("    Formular gespeichert (Form-Modul erstellt)")
    except Exception as e:
        print(f"    [WARN] Save-Fehler (DialogKiller sollte helfen): {e}")
        # Trotzdem weitermachen - manchmal wird gespeichert trotz Fehler
    time.sleep(1)

    # Jetzt Form-Code hinzufuegen
    print("    Form-Code hinzufuegen...")
    vbe = app.VBE
    proj = vbe.ActiveVBProject

    form_code_added = False
    if proj:
        for c in proj.VBComponents:
            if c.Name == "Form_frm_N_DP_Dashboard":
                cm = c.CodeModule
                if cm.CountOfLines > 0:
                    cm.DeleteLines(1, cm.CountOfLines)
                cm.AddFromString(FORM_CODE)
                print(f"    [OK] Form-Code ({cm.CountOfLines} Zeilen)")
                form_code_added = True
                break

    if not form_code_added:
        print("    [WARN] Form_frm_N_DP_Dashboard nicht gefunden")

    # Nochmal speichern und schliessen
    try:
        app.DoCmd.Save(2, "frm_N_DP_Dashboard")
    except:
        pass
    time.sleep(0.5)
    try:
        app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)
    except:
        pass
    print("    [OK] Hauptformular fertig")

    time.sleep(1)

    # SCHRITT 3: Unterformular zsub_N_DP_Einsatzliste
    print("\n[5] Unterformular zsub_N_DP_Einsatzliste...")

    try:
        app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)  # acDesign
    except Exception as e:
        print(f"    [!] Konnte Unterformular nicht oeffnen: {e}")
        time.sleep(2)
        try:
            app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)
        except:
            print("    [!] Ueberspringe Unterformular")
            raise

    time.sleep(0.5)

    frm = app.Forms("zsub_N_DP_Einsatzliste")
    frm.AllowEdits = True
    frm.AllowAdditions = False
    frm.AllowDeletions = False
    frm.HasModule = True
    print("    AllowEdits = True, HasModule = True")

    # Speichern um Form-Modul zu erstellen
    try:
        app.DoCmd.Save(2, "zsub_N_DP_Einsatzliste")
    except:
        pass
    time.sleep(0.5)

    # Subform-Code hinzufuegen
    print("    Subform-Code hinzufuegen...")
    vbe = app.VBE
    proj = vbe.ActiveVBProject

    subform_code_added = False
    if proj:
        for c in proj.VBComponents:
            if c.Name == "Form_zsub_N_DP_Einsatzliste":
                cm = c.CodeModule
                if cm.CountOfLines > 0:
                    cm.DeleteLines(1, cm.CountOfLines)
                cm.AddFromString(SUBFORM_CODE)
                print(f"    [OK] Subform-Code ({cm.CountOfLines} Zeilen)")
                subform_code_added = True
                break

    if not subform_code_added:
        print("    [WARN] Form_zsub_N_DP_Einsatzliste nicht gefunden")

    try:
        app.DoCmd.Save(2, "zsub_N_DP_Einsatzliste")
    except:
        pass
    try:
        app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 1)
    except:
        pass
    print("    [OK] Unterformular fertig")

    try:
        app.DoCmd.SetWarnings(True)
    except:
        pass

    print("\n" + "=" * 70)
    print("FERTIG!")
    print("=" * 70)
    print("\nBitte frm_N_DP_Dashboard oeffnen und testen:")
    print("1. Auftrag auswaehlen")
    print("2. Doppelklick auf Mitarbeiter in der linken Liste")
    print("3. Pruefen ob Einsatzliste editierbar ist")
    print("4. Button 'Mitarbeiter anfragen' testen")

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
