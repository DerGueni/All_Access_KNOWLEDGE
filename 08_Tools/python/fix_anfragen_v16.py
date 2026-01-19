"""
FIX ANFRAGEN BUTTON V16 - MA zuerst in Planung eintragen
"""
import win32com.client
import pythoncom
import subprocess
import time
from pathlib import Path

FRONTEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT - Kopie (4).accdb"

# Neuer Code - MA zuerst in Planung eintragen, dann anfragen
NEW_ANFRAGEN_CODE = '''Public Sub DP_Mitarbeiter_Anfragen()
    On Error GoTo ErrHandler

    Dim iVA_ID As Long
    Dim iVADatum_ID As Long
    Dim iVAStart_ID As Long
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim rsSlot As DAO.Recordset
    Dim strRC As String
    Dim iCount As Long
    Dim strMA_Name As String
    Dim strSQL As String
    Dim dVADatum As Date
    Dim dMA_Start As Date
    Dim dMA_Ende As Date

    If m_CurrentVA_ID = 0 Or m_CurrentAnzTage_ID = 0 Then
        MsgBox "Bitte zuerst Auftrag auswaehlen.", vbExclamation
        Exit Sub
    End If

    If m_CurrentVAStart_ID = 0 Then
        MsgBox "Bitte zuerst eine Schicht auswaehlen (Doppelklick auf Mitarbeiter).", vbExclamation
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
    iVAStart_ID = m_CurrentVAStart_ID

    Set db = CurrentDb

    ' Hole Schicht-Daten (VA_Start, VA_Ende, VADatum)
    Set rsSlot = db.OpenRecordset("SELECT VA_Start, VA_Ende, VADatum FROM tbl_VA_Start WHERE ID = " & iVAStart_ID)
    If rsSlot.EOF Then
        MsgBox "Schicht nicht gefunden.", vbExclamation
        rsSlot.Close
        Set db = Nothing
        Exit Sub
    End If
    dMA_Start = rsSlot!VA_Start
    dMA_Ende = rsSlot!VA_Ende
    dVADatum = Nz(rsSlot!VADatum, m_CurrentDatum)
    rsSlot.Close

    ' Logdatei loeschen
    On Error Resume Next
    db.Execute "DELETE * FROM ztbl_Log"
    On Error GoTo ErrHandler

    ' Kurz warten
    Wait (1)

    ' Autowert zuruecksetzen
    On Error Resume Next
    FnSetzeAutowertZurueck "ID", "ztbl_Log"
    On Error GoTo ErrHandler

    ' Log-Formular oeffnen
    On Error Resume Next
    DoCmd.OpenForm "zfrm_Log"
    On Error GoTo ErrHandler

    ' Recordset der ausgewaehlten MA
    Set rs = db.OpenRecordset("SELECT ID, Beginn, Ende FROM ztbl_MA_Schnellauswahl", dbOpenSnapshot)

    ' Ladebalken
    SysCmd acSysCmdInitMeter, "Bitte warten...", rs.RecordCount
    DoCmd.Hourglass True

    iCount = 0

    Do While Not rs.EOF
        iCount = iCount + 1
        strMA_Name = Nz(DLookup("Nachname & ' ' & Vorname", "tbl_MA_Mitarbeiterstamm", "ID = " & rs!ID), "MA " & rs!ID)

        ' Pruefe ob MA bereits in Planung fuer diese Schicht
        Dim existingID As Variant
        existingID = DLookup("ID", "tbl_MA_VA_Planung", "MA_ID = " & rs!ID & " AND VAStart_ID = " & iVAStart_ID)

        If IsNull(existingID) Then
            ' MA in tbl_MA_VA_Planung eintragen mit Status 1 (Geplant)
            Dim dBeginn As Date, dEnde As Date
            dBeginn = Nz(rs!Beginn, dMA_Start)
            dEnde = Nz(rs!Ende, dMA_Ende)

            strSQL = "INSERT INTO tbl_MA_VA_Planung (VA_ID, VADatum_ID, VAStart_ID, MA_ID, Status_ID, " & _
                     "VADatum, MVA_Start, MVA_Ende, Erst_von, Erst_am) VALUES (" & _
                     iVA_ID & ", " & iVADatum_ID & ", " & iVAStart_ID & ", " & rs!ID & ", 1, " & _
                     "#" & Format(dVADatum, "yyyy-mm-dd") & "#, " & _
                     "#" & Format(dVADatum, "yyyy-mm-dd") & " " & Format(dBeginn, "hh:nn:ss") & "#, " & _
                     "#" & Format(dVADatum, "yyyy-mm-dd") & " " & Format(dEnde, "hh:nn:ss") & "#, " & _
                     "'" & Environ("USERNAME") & "', Now())"

            On Error Resume Next
            db.Execute strSQL, dbFailOnError
            If Err.Number <> 0 Then
                strRC = "Fehler beim Einplanen: " & Err.description
                Err.Clear
                GoTo LogEintrag
            End If
            On Error GoTo ErrHandler
        End If

        ' Texte_lesen aufrufen um Modulvariablen zu setzen
        On Error Resume Next
        Texte_lesen CStr(rs!ID), CStr(iVA_ID), CStr(iVADatum_ID), CStr(iVAStart_ID)
        On Error GoTo ErrHandler

        ' Anfragen Funktion aufrufen (aus zmd_Mail)
        On Error Resume Next
        strRC = Anfragen(CInt(rs!ID), iVA_ID, iVADatum_ID, iVAStart_ID)
        If Err.Number <> 0 Then
            strRC = "Fehler: " & Err.description
            Err.Clear
        End If
        On Error GoTo ErrHandler

LogEintrag:
        ' In Log eintragen
        On Error Resume Next
        db.Execute "INSERT INTO ztbl_Log (Mitarbeiter, Status) VALUES ('" & strMA_Name & "', '" & strRC & "')"
        On Error GoTo ErrHandler

        rs.MoveNext

        ' Ladebalken aktualisieren
        SysCmd acSysCmdUpdateMeter, iCount

        ' Log aktualisieren
        On Error Resume Next
        If fctIsFormOpen("zfrm_Log") Then
            Forms("zfrm_Log").zfrm_ufrm_Log.Requery
            Forms("zfrm_Log").zfrm_ufrm_Log.SetFocus
            DoCmd.GoToRecord , , acLast
        End If
        On Error GoTo ErrHandler
    Loop

    rs.Close
    Set rs = Nothing
    Set db = Nothing

    ' Ladebalken entfernen
    SysCmd acSysCmdRemoveMeter
    DoCmd.Hourglass False

    ' Meldung
    MsgBox TCount("ID", "ztbl_Log") & " Mitarbeiter wurden angefragt - siehe Log", vbInformation

    ' Log schliessen
    On Error Resume Next
    DoCmd.Close acForm, "zfrm_Log"
    On Error GoTo ErrHandler

    ' Schnellauswahl leeren
    CurrentDb.Execute "DELETE FROM ztbl_MA_Schnellauswahl"

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
    SysCmd acSysCmdRemoveMeter
    DoCmd.Hourglass False
    MsgBox "Fehler: " & Err.description, vbExclamation
End Sub'''

def start_killer():
    p = Path(r"C:\Users\guenther.siegert\Documents\Access Bridge\DialogKillerPermanent.ps1")
    if p.exists():
        return subprocess.Popen(["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-File", str(p), "-Minutes", "30", "-IntervalMs", "50"],
            creationflags=subprocess.CREATE_NO_WINDOW, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return None

print("=" * 70)
print("FIX ANFRAGEN BUTTON V16 - MA zuerst einplanen")
print("=" * 70)

killer = start_killer()

try:
    pythoncom.CoInitialize()

    print("[1] Access verbinden...")
    try:
        app = win32com.client.GetObject(Class="Access.Application")
    except:
        app = win32com.client.Dispatch("Access.Application")
        app.Visible = True
        app.UserControl = True
        app.OpenCurrentDatabase(FRONTEND_PATH, False)
        time.sleep(3)

    print("[OK] Access verbunden")

    # Formulare schliessen
    for form_name in ["frm_N_DP_Dashboard", "zsub_N_DP_Einsatzliste", "zfrm_Log"]:
        try:
            app.DoCmd.Close(2, form_name, 2)
        except:
            pass
    time.sleep(0.5)

    vbe = app.VBE
    proj = vbe.ActiveVBProject

    print("[2] Aktualisiere mod_N_DP_Dashboard...")

    for c in proj.VBComponents:
        if c.Name == "mod_N_DP_Dashboard":
            cm = c.CodeModule
            print(f"    Gefunden ({cm.CountOfLines} Zeilen)")

            # Versionskommentar aktualisieren
            cm.ReplaceLine(1, "' mod_N_DP_Dashboard V16 - MA in Planung eintragen vor Anfragen")

            # Finde DP_Mitarbeiter_Anfragen
            start_line = 0
            end_line = 0

            for i in range(1, cm.CountOfLines + 1):
                line = cm.Lines(i, 1)
                if "Public Sub DP_Mitarbeiter_Anfragen()" in line:
                    start_line = i
                if start_line > 0 and i > start_line and line.strip() == "End Sub":
                    end_line = i
                    break

            if start_line > 0 and end_line > 0:
                print(f"    DP_Mitarbeiter_Anfragen: Zeile {start_line}-{end_line}")

                # Loesche alte Funktion
                cm.DeleteLines(start_line, end_line - start_line + 1)
                print(f"    Alte Funktion geloescht")

                # Fuege neue Funktion ein
                cm.InsertLines(start_line, NEW_ANFRAGEN_CODE)
                print(f"    Neue Funktion eingefuegt")
                print(f"    Neue Zeilenanzahl: {cm.CountOfLines}")
            else:
                print(f"    [!] Funktion nicht gefunden!")

            break

    print("\n[OK] V16 - MA wird zuerst in tbl_MA_VA_Planung eingetragen")

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
