"""
Fix Anfragen Button - Nutze bestehende Anfrage-Logik via frm_ma_va_schnellauswahl
"""
import win32com.client
import pythoncom
import subprocess
import time
from pathlib import Path

FRONTEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT - Kopie (4).accdb"

# Komplett neues VBA-Modul mit korrigierter Anfrage-Funktion
VBA_MODULE = '''
' mod_N_DP_Dashboard V12 - Anfragen Button Fix
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
             "FROM tbl_MA_Mitarbeiterstamm AS m WHERE m.IstAktiv = True AND m.Anstellungsart_ID IN (3, 5) " & _
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
            MsgBox "Alle Schichten besetzt.", vbExclamation
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
        strSQL = "SELECT TOP 1 ID FROM tbl_MA_VA_Zuordnung WHERE VA_ID = " & m_CurrentVA_ID & _
                 " AND VADatum_ID = " & m_CurrentAnzTage_ID & " AND (MA_ID = 0 OR MA_ID Is Null)" & _
                 " AND Format(MA_Start, 'hh:nn:ss') = '" & strStartTime & "'" & _
                 " AND Format(MA_Ende, 'hh:nn:ss') = '" & strEndTime & "' ORDER BY PosNr"
        Set rs = db.OpenRecordset(strSQL)
        If rs.EOF Then
            MsgBox "Schicht besetzt.", vbExclamation
            rs.Close
            Set db = Nothing
            Exit Sub
        End If
        FreeSlotID = rs!ID
        rs.Close
    End If
    Set rs = db.OpenRecordset("SELECT ID FROM tbl_MA_VA_Zuordnung WHERE VA_ID = " & m_CurrentVA_ID & _
        " AND VADatum_ID = " & m_CurrentAnzTage_ID & " AND MA_ID = " & MA_ID)
    If Not rs.EOF Then
        MsgBox "MA bereits eingetragen.", vbInformation
        rs.Close
        Set db = Nothing
        Exit Sub
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
    MsgBox "Fehler: " & Err.Description, vbExclamation
    Set db = Nothing
End Sub

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
            MsgBox "Alle Schichten besetzt.", vbExclamation
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
        db.Execute "INSERT INTO ztbl_MA_Schnellauswahl (ID, Beginn, Ende) VALUES (" & MA_ID & ", #" & strBeginn & "#, #" & strEnde & "#)", dbFailOnError
    End If
    rs.Close
    Set db = Nothing
    DP_Aktualisiere_Angefragte_MA
    DP_Aktualisiere_Verfuegbare_MA m_CurrentDatum
    Exit Sub
ErrHandler:
    MsgBox "Fehler bei Minijobber-Anfrage: " & Err.Description, vbExclamation
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

' ============================================================================
' ANFRAGEN BUTTON - Nutzt bestehende Logik aus frm_ma_va_schnellauswahl
' ============================================================================
Public Sub DP_Mitarbeiter_Anfragen()
    On Error GoTo ErrHandler

    Dim iVA_ID As Long
    Dim iVADatum_ID As Long
    Dim strSQL As String

    If m_CurrentVA_ID = 0 Or m_CurrentAnzTage_ID = 0 Then
        MsgBox "Bitte zuerst Auftrag auswaehlen.", vbExclamation
        Exit Sub
    End If

    Dim AnzahlAusgewaehlt As Long
    AnzahlAusgewaehlt = DCount("*", "ztbl_MA_Schnellauswahl")
    If AnzahlAusgewaehlt = 0 Then
        MsgBox "Bitte zuerst MA zur Anfrage hinzufuegen (Doppelklick auf Minijobber).", vbExclamation
        Exit Sub
    End If

    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents

    iVA_ID = m_CurrentVA_ID
    iVADatum_ID = m_CurrentAnzTage_ID

    ' SQL fuer die Anfrage generieren (basierend auf ztbl_MA_Schnellauswahl)
    strSQL = "SELECT s.ID AS MA_ID, m.Nachname & ' ' & m.Vorname AS MA_Name, " & _
             "Format(s.Beginn, 'hh:nn') AS Beginn, Format(s.Ende, 'hh:nn') AS Ende, " & _
             "1 AS Status_ID " & _
             "FROM ztbl_MA_Schnellauswahl AS s " & _
             "INNER JOIN tbl_MA_Mitarbeiterstamm AS m ON s.ID = m.ID"

    ' show_requestlog aufrufen (existierende Funktion im System)
    On Error Resume Next
    show_requestlog strSQL, False
    On Error GoTo ErrHandler

    ' Dashboard schliessen
    DoCmd.Close acForm, "frm_N_DP_Dashboard", acSaveNo

    ' Auftragstamm oeffnen
    If Not DP_IsFormOpen("frm_va_auftragstamm") Then
        DoCmd.OpenForm "frm_va_auftragstamm", , , "ID = " & iVA_ID
    End If

    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents

    Exit Sub
ErrHandler:
    MsgBox "Fehler: " & Err.Description, vbExclamation
End Sub

Private Function DP_IsFormOpen(strFormName As String) As Boolean
    On Error Resume Next
    DP_IsFormOpen = (SysCmd(acSysCmdGetObjectState, acForm, strFormName) <> 0)
    On Error GoTo 0
End Function

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
'''

def start_killer():
    p = Path(r"C:\Users\guenther.siegert\Documents\Access Bridge\DialogKillerPermanent.ps1")
    if p.exists():
        return subprocess.Popen(["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-File", str(p), "-Minutes", "30", "-IntervalMs", "50"],
            creationflags=subprocess.CREATE_NO_WINDOW, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return None

print("=" * 70)
print("FIX ANFRAGEN BUTTON - Nutze show_requestlog")
print("=" * 70)

killer = start_killer()
print("[OK] DialogKiller")

try:
    pythoncom.CoInitialize()

    print("\n[1] Access verbinden...")
    try:
        app = win32com.client.GetObject(Class="Access.Application")
    except:
        app = win32com.client.Dispatch("Access.Application")
        app.Visible = True
        app.UserControl = True
        app.OpenCurrentDatabase(FRONTEND_PATH, False)
        time.sleep(3)

    print("[OK] Access verbunden")

    # VBE holen
    vbe = app.VBE
    proj = vbe.ActiveVBProject

    if proj is None:
        raise Exception("VBProject ist None")

    # VBA-Modul komplett ersetzen
    print("\n[2] Aktualisiere mod_N_DP_Dashboard...")
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
        print(f"    [OK] Code aktualisiert ({cm.CountOfLines} Zeilen)")
    else:
        print("    [!] mod_N_DP_Dashboard nicht gefunden!")

    print("\n" + "=" * 70)
    print("FERTIG!")
    print("Die Funktion DP_Mitarbeiter_Anfragen ruft jetzt show_requestlog auf")
    print("und schliesst danach das Dashboard.")
    print("=" * 70)

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
