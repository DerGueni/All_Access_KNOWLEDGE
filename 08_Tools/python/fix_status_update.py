"""
Fix Status Update - Nach Anfrage Status auf "Benachrichtigt" setzen
"""
import win32com.client
import pythoncom
import subprocess
import time
from pathlib import Path

FRONTEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT - Kopie (4).accdb"

# Aktualisierte Funktion - setzt Status auf 2 (Benachrichtigt) nach Anfrage
NEW_MITARBEITER_ANFRAGEN = '''Public Sub DP_Mitarbeiter_Anfragen()
    On Error GoTo ErrHandler
    Dim frm As Form
    Set frm = Forms!frm_N_DP_Dashboard

    ' Pruefe ob Schicht ausgewaehlt
    If m_CurrentVAStart_ID = 0 Then
        MsgBox "Bitte zuerst eine Schicht auswaehlen!", vbExclamation
        Exit Sub
    End If

    ' Pruefe ob MA in der Planungsliste sind (Status 1 = Geplant)
    Dim lngCount As Long
    lngCount = DCount("*", "tbl_MA_VA_Planung", "VAStart_ID = " & m_CurrentVAStart_ID & " AND Status_ID = 1")

    If lngCount = 0 Then
        MsgBox "Keine Mitarbeiter zum Anfragen vorhanden!" & vbCrLf & _
               "(Nur MA mit Status 'Geplant' werden angefragt)", vbExclamation
        Exit Sub
    End If

    ' Texte laden fuer Anfragen-Funktion
    Texte_lesen m_CurrentVA_ID

    ' Anfragen senden (verwendet zmd_Mail.Anfragen)
    Anfragen

    ' Nach erfolgreicher Anfrage: Status auf 2 (Benachrichtigt) setzen
    Dim strSQL As String
    strSQL = "UPDATE tbl_MA_VA_Planung SET Status_ID = 2 " & _
             "WHERE VAStart_ID = " & m_CurrentVAStart_ID & " AND Status_ID = 1"
    CurrentDb.Execute strSQL, dbFailOnError

    ' Listenfeld aktualisieren
    DP_Aktualisiere_Angefragte_MA

    ' Erfolgsmeldung
    MsgBox lngCount & " Mitarbeiter wurden angefragt." & vbCrLf & _
           "Status wurde auf 'Benachrichtigt' gesetzt.", vbInformation

    Exit Sub

ErrHandler:
    MsgBox "Fehler beim Anfragen: " & Err.Description, vbCritical
End Sub'''

def start_killer():
    p = Path(r"C:\Users\guenther.siegert\Documents\Access Bridge\DialogKillerPermanent.ps1")
    if p.exists():
        return subprocess.Popen(["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-File", str(p), "-Minutes", "30", "-IntervalMs", "50"],
            creationflags=subprocess.CREATE_NO_WINDOW, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return None

print("=" * 70)
print("FIX STATUS UPDATE - Benachrichtigt nach Anfrage")
print("=" * 70)

killer = start_killer()

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

    # Formulare schliessen
    for form_name in ["frm_N_DP_Dashboard"]:
        try:
            app.DoCmd.Close(2, form_name, 2)
        except:
            pass
    time.sleep(0.5)

    vbe = app.VBE
    proj = vbe.ActiveVBProject

    print("\n[2] Aktualisiere mod_N_DP_Dashboard...")

    for c in proj.VBComponents:
        if c.Name == "mod_N_DP_Dashboard":
            cm = c.CodeModule
            print(f"    Gefunden ({cm.CountOfLines} Zeilen)")

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

                # Zeige alte Funktion
                print("\n    Alte Funktion:")
                old_code = cm.Lines(start_line, end_line - start_line + 1)
                for ln in old_code.split('\n')[:10]:
                    print(f"        {ln}")
                print("        ...")

                # Loesche alte Funktion
                cm.DeleteLines(start_line, end_line - start_line + 1)
                print(f"\n    Alte Funktion geloescht")

                # Fuege neue Funktion ein
                cm.InsertLines(start_line, NEW_MITARBEITER_ANFRAGEN)
                print(f"    Neue Funktion eingefuegt")
                print(f"    Neue Zeilenanzahl: {cm.CountOfLines}")
            else:
                print(f"    [!] Funktion nicht gefunden!")

            break

    print("\n[3] Teste Formular...")
    app.DoCmd.OpenForm("frm_N_DP_Dashboard", 0)
    time.sleep(1)
    print("    [OK] Formular geöffnet")

    print("\n" + "=" * 70)
    print("FERTIG - Status wird nach Anfrage auf 'Benachrichtigt' gesetzt")
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
